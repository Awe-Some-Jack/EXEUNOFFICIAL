package backend;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
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
	public static final SOUND_EXTS:Array<String> = ["ogg", "mp3", "wav", "flac", "opus"];
	public static final VIDEO_EXTS:Array<String> = ["mp4", "avi", "mkv", "mov", "wmv", "flv", "webm"];
	public static final IMAGE_EXTS:Array<String> = [
		#if mobile "astc", #end
		"png", "jpg", "jpeg", "bmp", "tga", "webp", "avif", "tif", "tiff", "gif",
		"jxl", "pcx", "xcf", "xpm", "qoi", "lbm", "iff", "pnm", "ppm", "pgm", "pbm",
	];

	//for backward compatibility
    public static final VIDEO_EXT = VIDEO_EXTS[0];
	public static final SOUND_EXT = SOUND_EXTS[0];

	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

	static final resolvedImageKeys:Map<String, String> = [];
	static final resolvedSoundFiles:Map<String, String> = [];

	public static function clearResolvedPaths():Void
	{
		gpuBitmaps.clear();
		resolvedImageKeys.clear();
		resolvedSoundFiles.clear();
	}

	public static function initStateSignals():Void
	{
		FlxG.signals.preStateSwitch.add(() -> {
			tempFramesCache.clear();
			clearResolvedPaths();
		});
	}

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];
	// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		dropUnusedGraphics();
		purgeBitmapCache();

		MemoryUtil.clearMinor();
		FlxG.bitmap.clearUnused();
	}

	static function dropUnusedGraphics():Void
	{
		for (key in [for (k in currentTrackedAssets.keys()) k])
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}
	}

	static function purgeSoundCache():Void
	{
		final cache = Std.downcast(openfl.Assets.cache, openfl.utils.AssetCache);
		if (cache == null || cache.sound == null) return;

		for (id in [for (k in cache.sound.keys()) k])
		{
			if (!isLargeAudioKey(id) || dumpExclusions.contains(id)) continue;

			final snd:Sound = cache.sound.get(id);
			if (isSoundPlaying(snd)) continue;

			cache.removeSound(id);
			closeSound(snd);
		}
	}

	static function purgeBitmapCache():Void
	{
		final cache = Std.downcast(openfl.Assets.cache, openfl.utils.AssetCache);
		if (cache == null || cache.bitmapData == null) return;

		final live:Array<BitmapData> = [for (graphic in currentTrackedAssets) graphic.bitmap];
		for (id in [for (k in cache.bitmapData.keys()) k])
		{
			if (!live.contains(cache.bitmapData.get(id)))
				cache.removeBitmapData(id);
		}
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory()
	{
		clearResolvedPaths();
		
		// clear anything not in the tracked assets list
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}
		#if flixel_animate
		@:privateAccess FlxAnimateFrames._cachedAtlases.clear();
		#end

		// clear all sounds that are cached
		final staleSounds:Array<String> = [];
		for (key => asset in currentTrackedSounds)
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null && !isSoundPlaying(asset))
				staleSounds.push(key);
		}

		for (key in staleSounds)
		{
			final snd:Sound = currentTrackedSounds.get(key);
			currentTrackedSounds.remove(key);
			Assets.cache.clear(key);
			if (isLargeAudioKey(key)) closeSound(snd);
		}
		closeStreamedSounds();
		purgeSoundCache();
		localTrackedAssets = [];
		#if !html5
		openfl.Assets.cache.clear("songs");
		openfl.Assets.cache.clear("music");
		openfl.Assets.cache.clear("sounds");
		#end

		dropUnusedGraphics();
		purgeBitmapCache();
		FlxG.bitmap.clearUnused();

		MemoryUtil.clearMajor();
		#if (!js && !html5)
		openfl.display.Shader.__pruneUnusedPrograms(FlxG.stage?.context3D);
		#end
	}

	static inline function isLargeAudioKey(key:String):Bool
		return key.indexOf("songs/") != -1 || key.indexOf("music/") != -1;

	static function closeSound(snd:Sound):Void
	{
		if (snd == null) return;
		try snd.close() catch (e:Dynamic) {}
	}

	public static function isSoundTracked(snd:Sound):Bool
	{
		for (tracked in currentTrackedSounds)
			if (tracked == snd) return true;
		for (tracked in streamedSounds)
			if (tracked == snd) return true;
		return false;
	}

	public static function releaseUnusedSound(snd:Sound):Void
	{
		if (snd == null || isSoundPlaying(snd) || isSoundTracked(snd)) return;
		closeSound(snd);
	}

	static function isSoundPlaying(snd:Sound):Bool
	{
		if (snd == null) return false;

		final music = FlxG.sound.music;
		if (music != null && (music.playing || @:privateAccess music._paused) && @:privateAccess music._sound == snd) return true;

		if (FlxG.sound.list != null)
			for (s in FlxG.sound.list.members)
				if (s != null && s.exists && (s.playing || @:privateAccess s._paused) && @:privateAccess s._sound == snd) return true;

		return false;
	}

	public static function releaseSound(snd:Sound):Void
	{
		if (snd == null) return;

		var tracked:Bool = orphanedStreamedSounds.remove(snd);

		for (key in [for (k => v in streamedSounds) if (v == snd) k])
		{
			streamedSounds.remove(key);
			tracked = true;
		}

		for (key in [for (k => v in currentTrackedSounds) if (v == snd) k])
		{
			if (dumpExclusions.contains(key)) return;
			currentTrackedSounds.remove(key);
			Assets.cache.clear(key);
			tracked = true;
		}

		if (!tracked) return;

		final music = FlxG.sound.music;
		if (music != null && @:privateAccess music._sound == snd) music.stop();

		closeSound(snd);
	}

	static var streamedSounds:Map<String, Sound> = [];
	static var orphanedStreamedSounds:Array<Sound> = [];

	static function isStreamedSoundInUse(snd:Sound):Bool
	{
		if (snd == null) return false;

		final music = FlxG.sound.music;
		if (music != null && @:privateAccess music._sound == snd) return true;

		return isStreamedSoundUsedByOther(snd);
	}

	static function isStreamedSoundUsedByOther(snd:Sound):Bool
	{
		if (snd == null || FlxG.sound.list == null) return false;

		for (s in FlxG.sound.list.members)
			if (s != null && s != FlxG.sound.music && @:privateAccess s._sound == snd) return true;

		return false;
	}

	static function closeStreamedSounds():Void
	{
		for (key in [for (k => v in streamedSounds) if (!dumpExclusions.contains(k) && !isSoundPlaying(v)) k])
		{
			closeSound(streamedSounds.get(key));
			streamedSounds.remove(key);
		}

		final stillOrphaned:Array<Sound> = [];
		for (snd in orphanedStreamedSounds)
		{
			if (isSoundPlaying(snd)) stillOrphaned.push(snd);
			else closeSound(snd);
		}
		orphanedStreamedSounds = stillOrphaned;
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

	static var imageTrims:Map<String, Array<Float>> = null;
	static final trimmedFrames:Map<String, FlxAtlasFrames> = [];

	static function loadImageTrims():Void
	{
		imageTrims = [];
		for (path in [getPath('data/image_trims.json', TEXT, null, false), mods('shared/data/image_trims.json', true)])
		{
			final content:String = getContent(path);
			if (content == null)
				continue;

			try
			{
				final data:Dynamic = Json.parse(content);
				for (field in Reflect.fields(data))
					imageTrims.set(field, Reflect.field(data, field));
			}
			catch (e:Dynamic)
			{
				trace('Error parsing image_trims.json at $path ($e)');
			}
		}
	}

	static function trimOf(file:String, bitmap:BitmapData):Array<Float>
	{
		if (file == null || bitmap == null)
			return null;

		var start:Int = -1;
		if (file.startsWith('assets/'))
			start = 7;
		else
		{
			final idx:Int = file.lastIndexOf('contents/');
			start = idx < 0 ? -1 : idx + 9;
		}

		if (start < 0)
			return null;

		if (imageTrims == null)
			loadImageTrims();

		final dot:Int = file.lastIndexOf('.');
		final trim:Array<Float> = imageTrims.get(file.substring(start, dot > start ? dot : file.length));
		if (trim == null || bitmap.width != trim[4] || bitmap.height != trim[5])
			return null;

		return trim;
	}

	static function restoreTrimmed(bitmap:BitmapData, trim:Array<Float>):BitmapData
	{
		if (bitmap.image == null || trim.length > 6)
			return bitmap;

		final full:BitmapData = new BitmapData(Std.int(trim[2]), Std.int(trim[3]), true, 0);
		full.copyPixels(bitmap, bitmap.rect, new openfl.geom.Point(trim[0], trim[1]));
		return full;
	}

	static function registerImageTrim(graph:FlxGraphic, file:String, bitmap:BitmapData):Void
	{
		final trim:Array<Float> = trimOf(file, bitmap);
		if (trim == null)
			return;

		final atlas:FlxAtlasFrames = new FlxAtlasFrames(graph);
		final frame:FlxFrame = atlas.addAtlasFrame(FlxRect.get(0, 0, trim[4], trim[5]), FlxPoint.get(trim[2], trim[3]), FlxPoint.get(trim[0], trim[1]), 'trimmed');
		if (trim.length > 6)
		{
			frame.texScale = trim[6];
			frame.cacheFrameMatrix();
		}

		trimmedFrames.set(graph.key, atlas);
	}

	static function trimmedFramesOf(graph:FlxGraphic):FlxAtlasFrames
	{
		final trimmed:FlxAtlasFrames = trimmedFrames.get(graph.key);
		if (trimmed != null && trimmed.parent != graph)
		{
			trimmedFrames.remove(graph.key);
			return null;
		}
		return trimmed;
	}

	public static function imageFramesOf(graph:FlxGraphic):FlxFramesCollection
	{
		final trimmed:FlxAtlasFrames = trimmedFramesOf(graph);
		return trimmed != null ? trimmed : graph.imageFrame;
	}

	inline static function destroyGraphic(graphic:FlxGraphic)
	{
		trimmedFrames.remove(graphic?.key);
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
		if (key.startsWith('../'))
		{
			final relative:String = key.substr(3);
			for (ext in VIDEO_EXTS)
			{
				final path:String = getPath('$relative.$ext');
				if (#if sys FileSystem.exists(path) || #end OpenFlAssets.exists(path)) return path;
			}
		}

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
		return returnVorbisSound('music/$key', modsAllowed);

	inline static public function inst(song:String, ?modsAllowed:Bool = true):Sound
		return returnVorbisSound('${formatToSongPath(song)}/Inst', 'songs', modsAllowed);

	inline static public function voices(song:String, postfix:String = null, ?modsAllowed:Bool = true):Sound
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if(postfix != null) songKey += '-' + postfix;
		//trace('songKey test: $songKey');
		return returnVorbisSound(songKey, 'songs', modsAllowed, false);
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
		final resolveId:String = Mods.currentModDirectory + '|' + parentFolder + '|' + translatedKey;
		var finalKey:String = resolvedImageKeys.get(resolveId);

		if (finalKey == null)
		{
			finalKey = translatedKey + '.webp';

			for (ext in IMAGE_EXTS)
			{
				if (fileExists(translatedKey + '.' + ext, IMAGE, false, parentFolder))
				{
					finalKey = translatedKey + '.' + ext;
					break;
				}
			}

			resolvedImageKeys.set(resolveId, finalKey);
		}

		var bitmap:BitmapData = null;
		if (currentTrackedAssets.exists(finalKey))
		{
			localTrackedAssets.push(finalKey);
			return currentTrackedAssets.get(finalKey);
		}
		return cacheBitmap(finalKey, parentFolder, bitmap, allowGPU);
	}

	public static function uploadBitmap(bitmap:BitmapData):BitmapData
	{
		#if (!js && !html5)
		if (bitmap != null && bitmap.image != null && FlxG.stage.context3D != null)
			uploadToGPU(bitmap);
		#end
		return bitmap;
	}

	static function uploadToGPU(bitmap:BitmapData):Void
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

	public static function cacheBitmap(key:String, ?parentFolder:String = null, ?bitmap:BitmapData, ?allowGPU:Bool = true):FlxGraphic
	{
		var trimFile:String = null;
		if (bitmap == null)
		{
			var file:String = getPath(key, IMAGE, parentFolder, true);
			trimFile = file;
			#if (!js && !html5)
			final useOptimized:Bool = allowGPU && ClientPrefs.data.cacheOnGPU && FlxG.stage.context3D != null;
			#else
			final useOptimized:Bool = false;
			#end

			var fileExistsSys:Bool = false;
			#if sys
			if (sys.FileSystem.exists(file)) fileExistsSys = true;
			#end

			final isASTC:Bool = haxe.io.Path.extension(file) == "astc";

			if (isASTC)
			{
				#if sys
				if (fileExistsSys && FlxG.stage.context3D?.isASTCSupported())
				{
					try
					{
						var astcBytes = openfl.utils.ByteArray.fromBytes(sys.io.File.getBytes(file));
						bitmap = BitmapData.fromTexture(FlxG.stage.context3D.createASTCTexture(astcBytes), false);
					}
					catch (e:Dynamic)
					{
						trace('Error loading ASTC from sys: $file ($e)');
					}
				}
				else #end if (OpenFlAssets.exists(file))
				{
					bitmap = OpenFlAssets.getBitmapData(file, false);
				}
			}
			else if (fileExistsSys)
			{
				#if sys
				final absFile:String = sys.FileSystem.fullPath(file);
				bitmap = useOptimized ? OptimizedBitmapData.fromFile(absFile) : BitmapData.fromFile(absFile);
				#end
			}
			else if (OpenFlAssets.exists(file))
			{
				bitmap = useOptimized ? OptimizedBitmapData.fromOpenFlAssets(file) : OpenFlAssets.getBitmapData(file, false);
			}

			if (bitmap == null)
			{
				// is necesary?? hehe...., creo q takes a lot of ms on game 
				// trace('Bitmap not found: $file | key: $key');
				return null;
			}
		}

		var trimmedBitmap:Bool = false;
		final trim:Array<Float> = trimOf(trimFile, bitmap);
		if (trim != null)
		{
			final restored:BitmapData = restoreTrimmed(bitmap, trim);
			trimmedBitmap = restored == bitmap;
			bitmap = restored;
		}

		if (allowGPU && ClientPrefs.data.cacheOnGPU && bitmap.image != null && FlxG.stage.context3D != null)
		{
			uploadToGPU(bitmap);
		}

		final graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;
		if (trimmedBitmap)
			registerImageTrim(graph, trimFile, bitmap);

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}

	inline static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		final path:String = getPath(key, TEXT, !ignoreMods);
		return getContent(path);
	}

	static public function getContent(path:String):String
	{
		if (OpenFlAssets.exists(path)) return OpenFlAssets.getText(path);
		#if sys
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#end
		#if (mobile || switch)
		final deviceRoot = #if mobile MobileUtil.getDirectory() #else SwitchStorage.ROOT #end;
		if (path.startsWith(deviceRoot))
		{
			final relative = path.substr(deviceRoot.length);
			if (OpenFlAssets.exists(relative)) return OpenFlAssets.getText(relative);
		}
		#end
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

	static final bitmapTrimKeys:haxe.ds.WeakMap<BitmapData, String> = new haxe.ds.WeakMap();

	static final gpuBitmaps:Map<String, BitmapData> = [];

	public static function getBitmapData(key:String, ?useCache:Bool = true, ?gpuOnly:Bool = false) {
		#if (!js && !html5)
		if (gpuOnly)
		{
			final shared:BitmapData = gpuBitmaps.get(key);
			if (shared != null && shared.width > 0) return shared;
		}
		#end

		final bitmap:BitmapData = loadBitmapData(key, useCache);
		if (bitmap != null)
		{
			bitmapTrimKeys.set(bitmap, key);
			#if (!js && !html5)
			if (gpuOnly && bitmap.image != null && FlxG.stage.context3D != null)
			{
				uploadToGPU(bitmap);
				gpuBitmaps.set(key, bitmap);
			}
			#end
		}
		return bitmap;
	}

	public static function registerBitmapTrim(graph:FlxGraphic, bitmap:BitmapData):Void
	{
		if (graph == null || trimmedFramesOf(graph) != null)
			return;

		final key:String = bitmapTrimKeys.get(bitmap);
		if (key != null)
			registerImageTrim(graph, key, bitmap);
	}

	static function loadBitmapData(key:String, ?useCache:Bool = true) {
		var lastDot:Int = key.lastIndexOf('.');
		var baseKey:String = lastDot != -1 ? key.substr(0, lastDot) : key;

		for (ext in IMAGE_EXTS) 
		{
			var testPath:String = '$baseKey.$ext';
			final isASTC:Bool = ext == "astc";

			if (isASTC)
			{
				#if sys
				if (sys.FileSystem.exists(testPath) && FlxG.stage.context3D != null && FlxG.stage.context3D.isASTCSupported())
				{
					try {
						var astcBytes = openfl.utils.ByteArray.fromBytes(sys.io.File.getBytes(testPath));
						final astc:BitmapData = BitmapData.fromTexture(FlxG.stage.context3D.createASTCTexture(astcBytes), false);
						if (astc != null) return astc;
						trace('ASTC load returned null: $testPath');
					} catch (e:Dynamic) {
						trace('Error loading ASTC from sys: $testPath ($e)');
					}
				}
				#end

				if (OpenFlAssets.exists(testPath))
				{
					try {
						final astcAsset:BitmapData = OpenFlAssets.getBitmapData(testPath, useCache);
						if (astcAsset != null) return astcAsset;
						trace('ASTC load from OpenFL Assets returned null: $testPath');
					} catch (e:Dynamic) {
						trace('Error loading ASTC from OpenFL Assets: $testPath ($e)');
					}
				}

				continue;
			}

			#if sys
			if (sys.FileSystem.exists(testPath))
			{
				try {
					final fromDisk:BitmapData = BitmapData.fromFile(sys.FileSystem.fullPath(testPath));
					if (fromDisk != null) return fromDisk;
					trace('Bitmap load from disk returned null: $testPath');
				} catch (e:Dynamic) {
					trace('Error loading bitmap from sys: $testPath ($e)');
				}
			}
			#end

			if (OpenFlAssets.exists(testPath))
			{
				try {
					final fromAssets:BitmapData = OpenFlAssets.getBitmapData(testPath, useCache);
					if (fromAssets != null) return fromAssets;
					trace('Bitmap load from OpenFL Assets returned null: $testPath');
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
				#if sys
				if (sys.FileSystem.exists(modPath)) return true;
				#end
				if (OpenFlAssets.exists('contents/$mod/$modKey')) return true;
			}

			final currentModPath:String = mods(Mods.currentModDirectory + '/' + modKey);
			final baseModPath:String = mods(modKey);

			#if sys
			if (sys.FileSystem.exists(currentModPath) || sys.FileSystem.exists(baseModPath)) return true;
			#end
			if (OpenFlAssets.exists('contents/' + Mods.currentModDirectory + '/' + modKey) || OpenFlAssets.exists('contents/' + modKey)) return true;
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
			try {
				for (file in sys.FileSystem.readDirectory(scanFolder))
					if (!scannedFiles.contains(file)) scannedFiles.push(file);
			} catch (e:Dynamic) {
				trace('Could not read directory: $scanFolder ($e)');
			}
		}
		#end

		var manifestScanFolder = scanFolder;
		#if (mobile || switch)
		final deviceRoot = #if mobile MobileUtil.getDirectory() #else SwitchStorage.ROOT #end;
		if (manifestScanFolder.startsWith(deviceRoot))
			manifestScanFolder = manifestScanFolder.substr(deviceRoot.length);
		#end

		for (file in OpenFlAssets.list()) {
			var cleanFile = file;
			final colonIndex = cleanFile.indexOf(":");
			if (colonIndex != -1) cleanFile = cleanFile.substring(colonIndex + 1);

			if (cleanFile.indexOf(manifestScanFolder) == 0) {
				final rest = cleanFile.substr(manifestScanFolder.length);

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
			return FlxAtlasFrames.fromSparrow(imageLoaded, (useMod ? getContent(myXml) : myXml));
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
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (useMod ? getContent(myJson) : myJson));
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
		xmlContent = getContent(xmlPath);
			
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
		txtContent = getContent(txtPath);
			
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
		jsonContent = getContent(jsonPath);
			
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

	static public function resolveSoundFile(key:String, ?path:String, ?modsAllowed:Bool = true):String
	{
		final translatedKey:String = Language.getFileTranslation(key);
		final resolveId:String = Mods.currentModDirectory + '|' + path + '|' + modsAllowed + '|' + translatedKey;
		final cached:String = resolvedSoundFiles.get(resolveId);
		if (cached != null) return cached;

		final file:String = findSoundFile(translatedKey, path, modsAllowed);
		resolvedSoundFiles.set(resolveId, file);
		return file;
	}

	static function findSoundFile(translatedKey:String, path:String, modsAllowed:Bool):String
	{
		var file:String = getPath('$translatedKey.$SOUND_EXT', SOUND, path, modsAllowed);
		if (#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file)) return file;

		for (ext in SOUND_EXTS)
		{
			if (ext == SOUND_EXT) continue;

			file = getPath('$translatedKey.$ext', SOUND, path, modsAllowed);
			if (#if sys FileSystem.exists(file) || #end OpenFlAssets.exists(file)) return file;
		}

		return getPath('$translatedKey.$SOUND_EXT', SOUND, path, modsAllowed);
	}

	static function loadSoundFromFile(file:String):Sound
	{
		final buffer = lime.media.AudioBuffer.fromFile(file);
		if (buffer != null) 
			return Sound.fromAudioBuffer(buffer);
		
		return Sound.fromFile(file);
	}

	static function loadSoundFromAssets(file:String):Sound
	{
		final bytes = OpenFlAssets.getBytes(file);
		if (bytes != null)
		{
			final buffer = lime.media.AudioBuffer.fromBytes(bytes);
			if (buffer != null) 
				return Sound.fromAudioBuffer(buffer);
		}

		return OpenFlAssets.getSound(file);
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true)
	{
		var file:String = resolveSoundFile(key, path, modsAllowed);

		//trace('precaching sound: $file');
		if(!currentTrackedSounds.exists(file))
		{
			var loaded:Bool = false;
			#if sys
			if(sys.FileSystem.exists(file)) {
				var decoded:Sound = null;
				try {
					decoded = loadSoundFromFile(sys.FileSystem.fullPath(file));
				} catch (e:Dynamic) {
					decoded = null;
				}
				if (decoded != null) {
					currentTrackedSounds.set(file, decoded);
					loaded = true;
				} else {
					trace('SOUND FAILED TO DECODE: $file');
					FlxG.log.error('SOUND FAILED TO DECODE: $file');
				}
			}
			#end
			if(!loaded && OpenFlAssets.exists(file)) {
				var decoded:Sound = null;
				try {
					decoded = loadSoundFromAssets(file);
				} catch (e:Dynamic) {
					decoded = null;
				}
				if (decoded != null) {
					currentTrackedSounds.set(file, decoded);
					loaded = true;
				} else {
					trace('SOUND FAILED TO DECODE FROM ASSETS: $file');
					FlxG.log.error('SOUND FAILED TO DECODE FROM ASSETS: $file');
				}
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

	/**
	 * Streams an audio file straight off disk instead of decoding it fully into memory,
	 * giving much faster load times for large song audio (inst/voices).
	 *
	 * Falls back to `returnSound` if streaming is disabled or the file can't be opened.
	 */
	public static function returnVorbisSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true):Sound
	{
		#if lime_vorbis
		if (ClientPrefs.data.streamedAudio)
		{
			var file:String = resolveSoundFile(key, path, modsAllowed);
			var ext = haxe.io.Path.extension(file).toLowerCase();

			if (SOUND_EXTS.contains(ext))
			{
				final cached:Sound = streamedSounds.get(file);
				if (cached != null && !isStreamedSoundInUse(cached)) return cached;

				var buffer:lime.media.AudioBuffer = null;

				#if sys
				if (sys.FileSystem.exists(file))
				{
					buffer = lime.media.AudioBuffer.fromFile(file, true);
				}
				#end

				if (buffer == null && OpenFlAssets.exists(file))
				{
					var bytes = OpenFlAssets.getBytes(file);
					if (bytes != null) buffer = lime.media.AudioBuffer.fromBytes(bytes, true);
				}

				if (buffer != null)
				{
					final snd:Sound = Sound.fromAudioBuffer(buffer);
					final old:Sound = streamedSounds.get(file);
					if (old != null)
					{
						if (isStreamedSoundUsedByOther(old)) orphanedStreamedSounds.push(old);
						else try old.close() catch (e:Dynamic) {}
					}
					streamedSounds.set(file, snd);
					return snd;
				}
			}
		}
		#end

		return returnSound(key, path, modsAllowed, beepOnNull);
	}

	#if MODS_ALLOWED
    inline static public function mods(key:String = '', ?embed:Bool = false):String {
		if(embed) return 'contents/' + key;
        return #if (mobile && sys) MobileUtil.getDirectory() + #elseif switch SwitchStorage.ROOT + #end 'contents/' + key;
    }

    inline static public function modsJson(key:String):String
        return modFolders('data/' + key + '.json');

    static public function modsVideo(key:String):String
    {
        for (ext in VIDEO_EXTS)
        {
            final path:String = modFolders('videos/' + key + '.' + ext);
            if (#if sys FileSystem.exists(path) || #end OpenFlAssets.exists(path))
                return path;
        }

        return modFolders('videos/' + key + '.' + VIDEO_EXT);
    }

    inline static public function modsSounds(path:String, key:String):String
        return modFolders(path + '/' + key + '.' + SOUND_EXT);

    static public function modsImages(key:String):String
    {
        for (ext in IMAGE_EXTS)
        {
            final fileToCheck:String = modFolders('images/' + key + '.' + ext);
            if (#if sys sys.FileSystem.exists(fileToCheck) || #end OpenFlAssets.exists(fileToCheck)) return fileToCheck;
        }
        
        return modFolders('images/' + key + '.webp');
    }

    inline static public function modsXml(key:String):String
        return modFolders('images/' + key + '.xml');

    inline static public function modsTxt(key:String):String
        return modFolders('images/' + key + '.txt');

    inline static public function modsImagesJson(key:String):String
        return modFolders('images/' + key + '.json');

    static public function modFolders(key:String):String
    {
        if(Mods.currentModDirectory?.length > 0)
        {
            var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
            #if sys
            if(sys.FileSystem.exists(fileToCheck)) return fileToCheck;
            #end
            var assetKey:String = 'contents/' + Mods.currentModDirectory + '/' + key;
            if(OpenFlAssets.exists(assetKey)) return assetKey;
        }

        for(mod in Mods.getGlobalMods())
        {
            var fileToCheck:String = mods(mod + '/' + key);
            #if sys
            if(sys.FileSystem.exists(fileToCheck)) return fileToCheck;
            #end
            var assetKey:String = 'contents/' + mod + '/' + key;
            if(OpenFlAssets.exists(assetKey)) return assetKey;
        }

        var defaultFile:String = mods(key);
        #if sys
        if(sys.FileSystem.exists(defaultFile)) return defaultFile;
        #end
        
        var defaultAssetKey:String = 'contents/' + key;
        if(OpenFlAssets.exists(defaultAssetKey)) return defaultAssetKey;

        return defaultFile;
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