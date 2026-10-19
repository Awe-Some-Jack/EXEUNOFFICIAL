package backend;

import openfl.utils.Assets;
import haxe.io.Bytes;

import haxe.Json;

typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};

class Mods
{
	static public var currentModDirectory:String = '';

	public static final CONTENTS_LIST:String = 'contentsList.dat';

	public static function contentsListReadPath():String
	{
		#if switch
		if (FileSystem.exists(contentsListSavePath())) return contentsListSavePath();
		#end
		return CONTENTS_LIST;
	}

	inline public static function contentsListSavePath():String
		return #if switch SwitchStorage.ROOT + #end CONTENTS_LIST;

	public static final ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	inline public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		for(mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if(pack != null && pack.runsGlobally) globalMods.push(mod);
		}
		return globalMods;
	}

	inline public static function getModDirectories():Array<String>
	{
		var list:Array<String> = [];
		for (folder in Paths.readDirectory(Paths.mods()))
		{
			if (!folder.contains('.') && !ignoreModFolders.contains(folder.toLowerCase()) && !list.contains(folder))
				list.push(folder);
		}

		#if mobile
		for (folder in getEmbeddedModFolders())
			if (!list.contains(folder))
				list.push(folder);
		#end

		return list;
	}

	#if mobile
	inline static function getEmbeddedModFolders():Array<String>
	{
		var list:Array<String> = [];
		for (key in OpenFlAssets.list())
		{
			var cleanKey = key;
			var colonIndex = cleanKey.indexOf(":");
			if (colonIndex != -1) cleanKey = cleanKey.substring(colonIndex + 1);

			if (cleanKey.indexOf('contents/') == 0)
			{
				var rest = cleanKey.substr('contents/'.length);
				var folder = rest.indexOf('/') != -1 ? rest.substr(0, rest.indexOf('/')) : rest;
				if (folder.length > 0 && !folder.contains('.') && !ignoreModFolders.contains(folder.toLowerCase()) && !list.contains(folder))
					list.push(folder);
			}
		}
		return list;
	}
	#end

	static function modFolderExists(folder:String):Bool
	{
		if (FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)))
			return true;

		#if mobile
		if (getEmbeddedModFolders().contains(folder))
			return true;
		#end

		return false;
	}
	
	inline public static function mergeAllTextsNamed(path:String, ?defaultDirectory:String = null, allowDuplicates:Bool = false)
	{
		if(defaultDirectory == null) defaultDirectory = Paths.getSharedPath();
		defaultDirectory = defaultDirectory.trim();
		if(!defaultDirectory.endsWith('/')) defaultDirectory += '/';
		if(!defaultDirectory.startsWith('assets/')) defaultDirectory = 'assets/$defaultDirectory';

		var mergedList:Array<String> = [];
		var paths:Array<String> = directoriesWithFile(defaultDirectory, path);

		var defaultPath:String = defaultDirectory + path;
		if(paths.contains(defaultPath))
		{
			paths.remove(defaultPath);
			paths.insert(0, defaultPath);
		}

		for (file in paths)
		{
			var list:Array<String> = CoolUtil.coolTextFile(file);
			for (value in list)
				if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
	}

	public static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true):Array<String>
	{
		var foldersToCheck:Array<String> = [];
		final embeddedRoot:Bool = #if switch false #else true #end;
		
		final checkFile = (folderPath:String) -> {
			final fullPath = folderPath + fileToFind;
			
			#if sys
			if (sys.FileSystem.exists(fullPath)) return true;
			#end
			
			if (fullPath.endsWith('/')) {
				for (file in OpenFlAssets.list())
					if (file.indexOf(fullPath) == 0) {
						trace(file);
						return true;
					}
			} else {
				if (OpenFlAssets.exists(fullPath)) {
					trace(fullPath);
					return true;
				}
			}
			
			return false;
		};

		if(checkFile(path)) foldersToCheck.push(path + fileToFind);

		#if MODS_ALLOWED
		if(mods)
		{
			for(mod in Mods.getGlobalMods())
			{
				final folder:String = Paths.mods(mod + '/', embeddedRoot);
				if(checkFile(folder) && !foldersToCheck.contains(folder + fileToFind)) 
					foldersToCheck.push(folder + fileToFind);
			}

			if(Mods.currentModDirectory?.length > 0)
			{
				final folder:String = Paths.mods(Mods.currentModDirectory + '/', embeddedRoot);
				if(checkFile(folder) && !foldersToCheck.contains(folder + fileToFind)) 
					foldersToCheck.push(folder + fileToFind);
			}

			final folder:String = Paths.mods('', embeddedRoot);
			if(checkFile(folder) && !foldersToCheck.contains(folder + fileToFind)) 
				foldersToCheck.push(folder + fileToFind);
		}
		#end
		
		return foldersToCheck;
	}

	public static function getPack(?folder:String = null):Dynamic
	{
		#if MODS_ALLOWED
		if(folder == null) folder = Mods.currentModDirectory;

		var path = Paths.mods(folder + '/pack.json');
		var rawJson:String = null;

		rawJson = Paths.getContent(path);

		if(rawJson != null && rawJson.length > 0) {
			try {
				return tjson.TJSON.parse(rawJson);
			} catch(e:Dynamic) {
				trace(e);
			}
		}
		#end
		return null;
	}

	public static var updatedOnState:Bool = false;
	inline public static function parseList():ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		#if MODS_ALLOWED
		try {
			for (mod in CoolUtil.coolTextFile(contentsListReadPath()))
			{
				//trace('Mod: $mod');
				if(mod.trim().length < 1) continue;

				var dat = mod.split("|");
				list.all.push(dat[0]);
				if(dat[1] == "1")
					list.enabled.push(dat[0]);
				else
					list.disabled.push(dat[0]);
			}
		} catch(e) {
			trace(e);
		}
		#end
		return list;
	}
	
	private static function updateModList()
	{
		#if MODS_ALLOWED
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		try {
			for (mod in CoolUtil.coolTextFile(contentsListReadPath()))
			{
				var dat:Array<String> = mod.split("|");
				var folder:String = dat[0];
				
				if(folder.trim().length > 0 && modFolderExists(folder) && !added.contains(folder))
				{
					added.push(folder);
					list.push([folder, (dat[1] == "1")]);
				}
			}
		} catch(e) {
			trace(e);
		}
		
		// Scan for folders that aren't on contentsList.dat yet
		for (folder in getModDirectories())
		{
			var trimmed = folder.trim();
			if(trimmed.length > 0 && !added.contains(trimmed))
			{
				added.push(trimmed);
				list.push([trimmed, true]);
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}

		/*#if mobile
		File.saveBytes('contentsList.dat', Assets.getBytes('contentsList.dat'));
		#else*/
		try {
			File.saveContent(#if mobile MobileUtil.getDirectory() + #end contentsListSavePath(), fileStr);
		} catch(e) {
			trace(e);
		}
		//#end

		updatedOnState = true;
		//trace('Saved contentsList.dat');
		#end
	}

	public static function loadTopMod()
	{
		Mods.currentModDirectory = '';
		
		#if MODS_ALLOWED
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			Mods.currentModDirectory = list[0];
		#end
	}
}