package backend;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.geom.Rectangle;

import lime.utils.Assets;
import openfl.media.Sound;

import haxe.Json;


#if MODS_ALLOWED
import backend.Mods;
#end

import backend.AtlasSpriteSettings;

@:access(openfl.display.BitmapData)
class Paths
{
	public static final SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static final VIDEO_EXTS:Array<String> = ["mp4", "avi", "mkv", "mov", "wmv", "flv", "webm"];
	public static final IMAGE_EXTS:Array<String> = [
		"png", "jpg", "jpeg", "bmp", "tga", "webp", "avif", "tif", "tiff", 
		"jxl", "pcx", "xcf", "xpm", "qoi", "lbm", "iff", "pnm", "ppm", "pgm", "pbm",
		#if mobile ".astc" #end
	];

	//for backward compatibility
    public static final VIDEO_EXT = VIDEO_EXTS[0];

	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

	public static function initStateSignals():Void
	{
		FlxG.signals.preStateSwitch.add(() -> tempFramesCache.clear());
	}

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];
	// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				destroyGraphic(currentTrackedAssets.get(key)); // get rid of the graphic
				currentTrackedAssets.remove(key); // and remove the key from local cache map
			}
		}

		MemoryUtil.clearMinor();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory()
	{
		MemoryUtil.clearMajor();
		
		// clear anything not in the tracked assets list
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		#if !html5
		openfl.Assets.cache.clear("songs");
		openfl.Assets.cache.clear("music");
		openfl.Assets.cache.clear("sounds");
		#end
	}

	public static function freeGraphicsFromMemory()
	{
		final protectedGfx:Array<FlxGraphic> = [];
		function checkForGraphics(spr:Dynamic)
		{
			try
			{
				final grp:Array<Dynamic> = Reflect.getProperty(spr, 'members');
				if(grp != null)
				{
					//trace('is actually a group');
					for (member in grp)
					{
						checkForGraphics(member);
					}
					return;
				}
			}

			//trace('check...');
			try
			{
				final gfx:FlxGraphic = Reflect.getProperty(spr, 'graphic');
				if(gfx != null)
				{
					protectedGfx.push(gfx);
					//trace('gfx added to the list successfully!');
				}
			}
			//catch(haxe.Exception) {}
		}

		for (member in FlxG.state.members)
			checkForGraphics(member);

		if(FlxG.state.subState != null)
			for (member in FlxG.state.subState.members)
				checkForGraphics(member);

		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!dumpExclusions.contains(key))
			{
				var graphic:FlxGraphic = currentTrackedAssets.get(key);
				if(!protectedGfx.contains(graphic))
				{
					destroyGraphic(graphic); // get rid of the graphic
					currentTrackedAssets.remove(key); // and remove the key from local cache map
					//trace('deleted $key');
				}
			}
		}
	}

	inline static function destroyGraphic(graphic:FlxGraphic)
	{
		// free some gpu memory
		graphic?.bitmap?.__texture?.dispose();
		FlxG.bitmap.remove(graphic);
	}

	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
		currentLevel = name.toLowerCase();

	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentfolder:String, ?modsAllowed:Bool = true):String
	{
		#if MODS_ALLOWED
		if(modsAllowed)
		{
			var customFile:String = file;
			if (parentfolder != null) customFile = '$parentfolder/$file';

			final modded:String = modFolders(customFile);
			#if sys
			if (sys.FileSystem.exists(modded)) return modded;
			#end
			if (OpenFlAssets.exists(modded)) return modded;
		}
		#end

		if (parentfolder != null)
			return getFolderPath(file, parentfolder);

		if (currentLevel != null && currentLevel != 'shared')
		{
			final levelPath = getFolderPath(file, currentLevel);
			if (OpenFlAssets.exists(levelPath))
				return levelPath;
		}
		
		return getSharedPath(file);
	}

	inline static public function getFolderPath(file:String, folder = "shared")
		return 'assets/$folder/$file';

	inline public static function getSharedPath(file:String = '')
		return 'assets/shared/$file';

	inline static public function txt(key:String, ?folder:String)
		return getPath('data/$key.txt', TEXT, folder, true);

	inline static public function xml(key:String, ?folder:String)
		return getPath('data/$key.xml', TEXT, folder, true);

	inline static public function json(key:String, ?folder:String)
		return getPath('data/$key.json', TEXT, folder, true);

	inline static public function shaderFragment(key:String, ?folder:String)
		return getPath('shaders/$key.frag', TEXT, folder, true);

	inline static public function shaderVertex(key:String, ?folder:String)
		return getPath('shaders/$key.vert', TEXT, folder, true);

	inline static public function lua(key:String, ?folder:String)
		return getPath('$key.lua', TEXT, folder, true);

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		final file:String = modsVideo(key);
		if(#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file)) return file;
		#end

		for (ext in VIDEO_EXTS)
		{
			final path = getFolderPath('$key.$ext', 'videos');
			if (#if sys FileSystem.exists(path) || #end OpenFlAssets.exists(path)) return path;
		}

		trace('VIDEO NOT FOUND: $key');
		return null;
	}

	inline static public function sound(key:String, ?modsAllowed:Bool = true):Sound
		return returnSound('sounds/$key', modsAllowed);

	inline static public function music(key:String, ?modsAllowed:Bool = true):Sound
		return returnSound('music/$key', modsAllowed);

	inline static public function inst(song:String, ?modsAllowed:Bool = true):Sound
		return returnSound('${formatToSongPath(song)}/Inst', 'songs', modsAllowed);

	inline static public function voices(song:String, postfix:String = null, ?modsAllowed:Bool = true):Sound
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if(postfix != null) songKey += '-' + postfix;
		//trace('songKey test: $songKey');
		return returnSound(songKey, 'songs', modsAllowed, false);
	}

	static public function instPath(song:String, ?modsAllowed:Bool = true):String
		return getSoundPath('${formatToSongPath(song)}/Inst', 'songs', modsAllowed);

	static public function voicesPath(song:String, postfix:String = null, ?modsAllowed:Bool = true):String
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if(postfix != null) songKey += '-' + postfix;
		return getSoundPath(songKey, 'songs', modsAllowed);
	}

	static public function getSoundPath(key:String, ?path:String, ?modsAllowed:Bool = true):String
	{
		final file:String = getPath(Language.getFileTranslation(key) + '.$SOUND_EXT', SOUND, path, modsAllowed);
		if (#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file)) return file;
		return null;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?modsAllowed:Bool = true)
		return sound(key + FlxG.random.int(min, max), modsAllowed);

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	static public function image(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxGraphic
	{
		var translatedKey:String = Language.getFileTranslation('images/$key');
		var finalKey:String = translatedKey + '.webp';

		for (ext in IMAGE_EXTS)
		{
			if (fileExists(translatedKey + '.' + ext, IMAGE, false, parentFolder))
			{
				finalKey = translatedKey + '.' + ext;
				break;
			}
		}

		var bitmap:BitmapData = null;
		if (currentTrackedAssets.exists(finalKey))
		{
			localTrackedAssets.push(finalKey);
			return currentTrackedAssets.get(finalKey);
		}
		return cacheBitmap(finalKey, parentFolder, bitmap, allowGPU);
	}

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic
	{
		if (bitmap == null)
		{
			var file:String = getPath(key, IMAGE, parentFolder, true);
			#if (!js && !html5)
			final useOptimized:Bool = allowGPU && ClientPrefs.data.cacheOnGPU && FlxG.stage.context3D != null;
			#else
			final useOptimized:Bool = false;
			#end
			
			var fileExistsSys:Bool = false;
			#if sys
			if (sys.FileSystem.exists(file)) fileExistsSys = true;
			#end

			if (fileExistsSys)
			{
				#if sys
				bitmap = useOptimized ? OptimizedBitmapData.fromFile(file) : BitmapData.fromFile(file);
				#end
			}
			else if (OpenFlAssets.exists(file))
			{
				bitmap = useOptimized ? OptimizedBitmapData.fromOpenFlAssets(file) : OpenFlAssets.getBitmapData(file);
			}

			if (bitmap == null)
			{
				trace('Bitmap not found: $file | key: $key');
				return null;
			}
		}

		if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null && FlxG.stage.context3D != null)
		{
			bitmap.lock();
			if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}

		final graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}

	inline static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		final path:String = getPath(key, TEXT, !ignoreMods);
		#if sys
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#end
		if (OpenFlAssets.exists(path)) return OpenFlAssets.getText(path);
		return null;
	}

	inline static public function font(key:String)
	{
		final folderKey:String = Language.getFileTranslation('fonts/$key');
		#if MODS_ALLOWED
		final file:String = modFolders(folderKey);
		if(#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file)) return file;
		#end
		return 'assets/$folderKey';
	}

	public static function getBitmapData(key:String, ?useCache:Bool = true) {
		var lastDot:Int = key.lastIndexOf('.');
		var baseKey:String = lastDot != -1 ? key.substr(0, lastDot) : key;

		for (ext in IMAGE_EXTS) 
		{
			var testPath:String = '$baseKey.$ext';

			#if sys
			if (sys.FileSystem.exists(testPath)) 
			{
				try {
					return BitmapData.fromFile(testPath);
				} catch (e:Dynamic) {
					trace('Error loading bitmap from sys: $testPath ($e)');
				}
			}
			#end

			if (OpenFlAssets.exists(testPath)) 
			{
				try {
					return OpenFlAssets.getBitmapData(testPath, useCache);
				} catch (e:Dynamic) {
					trace('Error loading bitmap from OpenFL Assets: $testPath ($e)');
				}
			}
		}

		trace('BitmapData not found for key: $key');
		return null;
	}

	public static function fileExists(key:String, ?type:AssetType, ?ignoreMods:Bool = false, ?parentFolder:String = null)
	{
		if(!ignoreMods)
		{
			var modKey:String = key;
			if(parentFolder == 'songs') modKey = 'songs/$key';

			for(mod in Mods.getGlobalMods())
			{
				final modPath:String = mods('$mod/$modKey');
				if (#if sys sys.FileSystem.exists(modPath) || #end OpenFlAssets.exists(modPath)) return true;
			}

			final currentModPath:String = mods(Mods.currentModDirectory + '/' + modKey);
			final baseModPath:String = mods(modKey);
			
			#if sys
			if (sys.FileSystem.exists(currentModPath) || sys.FileSystem.exists(baseModPath)) return true;
			#end
			if (OpenFlAssets.exists(currentModPath) || OpenFlAssets.exists(baseModPath)) return true;
		}
		
		final defaultPath:String = getPath(key, type, parentFolder, false);
		#if sys
		if (sys.FileSystem.exists(defaultPath)) return true;
		#end
		
		return OpenFlAssets.exists(defaultPath);
	}

	public static function readDirectory(folder:String):Array<String> {
		final scannedFiles:Array<String> = [];
		final scanFolder:String = folder.endsWith('/') ? folder : folder + '/';
		
		#if sys
		if (sys.FileSystem.exists(scanFolder) && sys.FileSystem.isDirectory(scanFolder)) {
			for (file in sys.FileSystem.readDirectory(scanFolder))
				if (!scannedFiles.contains(file)) scannedFiles.push(file);
		}
		#end
		
		for (file in OpenFlAssets.list()) {
			if (file.indexOf(scanFolder) == 0) {
				final rest = file.substr(scanFolder.length);

				var item = rest;
				if (rest.indexOf('/') != -1)
					item = rest.substr(0, rest.indexOf('/')); 

				if (item.length > 0 && !scannedFiles.contains(item))
					scannedFiles.push(item);
			}
		}
		
		return scannedFiles;
	}

	static public function getAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var useMod:Bool = false;

		final imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		final myXml:Dynamic = getPath('images/$key.xml', TEXT, parentFolder, true);
		if(OpenFlAssets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod = true)) || #end (OpenFlAssets.exists(myXml) && (useMod = true)))
		{
			#if MODS_ALLOWED
			return FlxAtlasFrames.fromSparrow(imageLoaded, (useMod ? File.getContent(myXml) : myXml));
			#else
			return FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
			#end
		}
		else
		{
			final myJson:Dynamic = getPath('images/$key.json', TEXT, parentFolder, true);
			if(OpenFlAssets.exists(myJson) #if MODS_ALLOWED || (FileSystem.exists(myJson) && (useMod = true)) || #end (OpenFlAssets.exists(myJson) && (useMod = true)))
			{
				#if MODS_ALLOWED
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (useMod ? File.getContent(myJson) : myJson));
				#else
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, myJson);
				#end
			}
		}
		return getPackerAtlas(key, parentFolder);
	}
	
	static public function getMultiAtlas(keys:Array<String>, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var parentFrames:FlxAtlasFrames = Paths.getAtlas(keys[0].trim());
		if(keys.length > 1)
		{
			final original:FlxAtlasFrames = parentFrames;
			parentFrames = new FlxAtlasFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);
			for (i in 1...keys.length)
			{
				final extraFrames:FlxAtlasFrames = Paths.getAtlas(keys[i].trim(), parentFolder, allowGPU);
				if(extraFrames != null)
					parentFrames.addAtlas(extraFrames, true);
			}
		}
		return parentFrames;
	}

	inline static public function getSparrowAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		final cacheKey:String = 'sparrow:$key:$parentFolder';

		if (tempFramesCache.exists(cacheKey)) return cast tempFramesCache.get(cacheKey);
		var imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		
		var xmlPath:String = modsXml(key);
		var xmlContent:String = null;
		
		#if sys
		if (sys.FileSystem.exists(xmlPath))
			xmlContent = sys.io.File.getContent(xmlPath);
		#end
		
		if (xmlContent == null && OpenFlAssets.exists(xmlPath))
			xmlContent = OpenFlAssets.getText(xmlPath);
			
		if (xmlContent == null)
			xmlPath = getPath(Language.getFileTranslation('images/$key') + '.xml', TEXT, parentFolder);
		else
			xmlPath = xmlContent;

		final frames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(imageLoaded, xmlPath);
		tempFramesCache.set(cacheKey, frames);
		return frames;
	}

	inline static public function getPackerAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		final cacheKey:String = 'packer:$key:$parentFolder';

		if (tempFramesCache.exists(cacheKey)) return cast tempFramesCache.get(cacheKey);

		final imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		
		var txtPath:String = modsTxt(key);
		var txtContent:String = null;
		
		#if sys
		if (sys.FileSystem.exists(txtPath))
			txtContent = sys.io.File.getContent(txtPath);
		#end
		
		if (txtContent == null && OpenFlAssets.exists(txtPath))
			txtContent = OpenFlAssets.getText(txtPath);
			
		if (txtContent == null)
			txtPath = getPath(Language.getFileTranslation('images/$key') + '.txt', TEXT, parentFolder);
		else
			txtPath = txtContent; 

		final frames:FlxAtlasFrames = FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, txtPath);
		tempFramesCache.set(cacheKey, frames);
		return frames;
	}

	inline static public function getAsepriteAtlas(key:String, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		final cacheKey:String = 'aseprite:$key:$parentFolder';
		
		if (tempFramesCache.exists(cacheKey)) return cast tempFramesCache.get(cacheKey);

		final imageLoaded:FlxGraphic = image(key, parentFolder, allowGPU);
		
		var jsonPath:String = modsImagesJson(key);
		var jsonContent:String = null;
		
		#if sys
		if (sys.FileSystem.exists(jsonPath))
			jsonContent = sys.io.File.getContent(jsonPath);
		#end
		
		if (jsonContent == null && OpenFlAssets.exists(jsonPath))
			jsonContent = OpenFlAssets.getText(jsonPath);
			
		if (jsonContent == null)
			jsonPath = getPath(Language.getFileTranslation('images/$key') + '.json', TEXT, parentFolder);
		else
			jsonPath = jsonContent; 

		final frames:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(imageLoaded, jsonPath);
		tempFramesCache.set(cacheKey, frames);
		return frames;
	}

	inline static public function formatToSongPath(path:String) {
		final invalidChars = ~/[~&;:<>#\s]/g;
		final hideChars = ~/[.,'"%?!]/g;

		return hideChars.replace(invalidChars.replace(path, '-'), '').trim().toLowerCase();
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true)
	{
		var file:String = getPath(Language.getFileTranslation(key) + '.$SOUND_EXT', SOUND, path, modsAllowed);

		//trace('precaching sound: $file');
		if(!currentTrackedSounds.exists(file))
		{
			var loaded:Bool = false;
			#if sys
			if(sys.FileSystem.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
				loaded = true;
			}
			#end
			if(!loaded && OpenFlAssets.exists(file)) {
				currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
				loaded = true;
			}
			
			if(!loaded && beepOnNull)
			{
				trace('SOUND NOT FOUND: $key, PATH: $path');
				FlxG.log.error('SOUND NOT FOUND: $key, PATH: $path');
				return FlxAssets.getSoundAddExtension('flixel/sounds/beep');
			}
		}
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '')
		return 'contents/' + key;

	inline static public function modsJson(key:String)
		return modFolders('data/' + key + '.json');

	static public function modsVideo(key:String)
	{
		for (ext in VIDEO_EXTS)
		{
			final path:String = modFolders('videos/' + key + '.' + ext);
			if (#if sys FileSystem.exists(path) || #end OpenFlAssets.exists(path))
				return path;
		}

		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsSounds(path:String, key:String)
		return modFolders(path + '/' + key + '.' + SOUND_EXT);

	static public function modsImages(key:String)
	{
		for (ext in IMAGE_EXTS)
		{
			final fileToCheck:String = modFolders('images/' + key + '.' + ext);
			if (#if sys sys.FileSystem.exists(fileToCheck) || #end OpenFlAssets.exists(fileToCheck)) return fileToCheck;
		}
		
		return modFolders('images/' + key + '.webp');
	}

	inline static public function modsXml(key:String)
		return modFolders('images/' + key + '.xml');

	inline static public function modsTxt(key:String)
		return modFolders('images/' + key + '.txt');

	inline static public function modsImagesJson(key:String)
		return modFolders('images/' + key + '.json');

	static public function modFolders(key:String)
	{
		if(Mods.currentModDirectory?.length > 0)
		{
			var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			#if sys
			if(sys.FileSystem.exists(fileToCheck)) return fileToCheck;
			#end
			if(OpenFlAssets.exists(fileToCheck)) return fileToCheck;
		}

		for(mod in Mods.getGlobalMods())
		{
			var fileToCheck:String = mods(mod + '/' + key);
			#if sys
			if(sys.FileSystem.exists(fileToCheck)) return fileToCheck;
			#end
			if(OpenFlAssets.exists(fileToCheck)) return fileToCheck;
		}
		return 'contents/' + key;
	}
	#end

	#if flixel_animate
	static public function getAnimateAtlas(key:String, ?library:String = null, ?settings:AtlasSpriteSettings):FlxAnimateFrames
	{
		final validatedSettings:AtlasSpriteSettings =
		{
			swfMode: settings?.swfMode ?? false,
			cacheOnLoad: settings?.cacheOnLoad ?? ClientPrefs.data.cacheOnGPU,
			filterQuality: settings?.filterQuality ?? (!ClientPrefs.data.lowQuality ? MEDIUM : LOW),
			spritemaps: settings?.spritemaps ?? null,
			metadataJson: settings?.metadataJson ?? null,
			cacheKey: settings?.cacheKey ?? null,
			uniqueInCache: settings?.uniqueInCache ?? false,
			onSymbolCreate: settings?.onSymbolCreate ?? null,
			applyStageMatrix: settings?.applyStageMatrix ?? false,
			useRenderTexture: settings?.useRenderTexture ?? false
		};

		var path = getPath('images/$key', TEXT, library, true);

		#if MODS_ALLOWED
		final animJsonPath = library != null ? modFolders('$library/images/$key/Animation.json') : modFolders('images/$key/Animation.json');
		final modPath = animJsonPath.substring(0, animJsonPath.lastIndexOf('/'));
		final isValidFolder:Bool = #if sys (sys.FileSystem.exists(modPath) && sys.FileSystem.isDirectory(modPath)) || #end OpenFlAssets.exists(animJsonPath);
		
		if (isValidFolder)
			path = modPath;
		#end

		trace(isValidFolder);

		return FlxAnimateFrames.fromAnimate(path, validatedSettings.spritemaps, validatedSettings.metadataJson, validatedSettings.cacheKey,
			validatedSettings.uniqueInCache, {
				swfMode: validatedSettings.swfMode,
				cacheOnLoad: validatedSettings.cacheOnLoad,
				filterQuality: validatedSettings.filterQuality,
				onSymbolCreate: validatedSettings.onSymbolCreate
			}
		);
	}
	#end
}