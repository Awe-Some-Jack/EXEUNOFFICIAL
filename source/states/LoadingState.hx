package states;

import haxe.Json;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import flixel.util.typeLimit.NextState;

import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.media.Sound;

import lime.utils.Assets;
import lime.app.Future;

import backend.Song;
import backend.StageData;
import objects.Character;

import sys.thread.FixedThreadPool;
import sys.thread.Thread;
import sys.thread.Mutex;

import objects.Note;

typedef GPUUploadTask = {
	var origKey:String;
	var bitmap:BitmapData;
}

#if cpp
@:headerCode('
#include <iostream>
#include <thread>
')
#end
class LoadingState extends MusicBeatState
{
	public static var loaded:Int = 0;
	public static var loadMax:Int = 0;

	static var gpuQueue:Array<GPUUploadTask> = [];
	
	static var mutex:Mutex;
	static var threadPool:FixedThreadPool = null;

	function new(target:NextState, stopMusic:Bool)
	{
		this.target = target;
		this.stopMusic = stopMusic;
		
		super();
	}

	var target:NextState = null;
	var stopMusic:Bool = false;
	var dontUpdate:Bool = false;

	var intendedPercent:Float = 0;
	var curPercent:Float = 0;

	var newBar:FlxSprite;
	var loadedTxt:FlxText;
	var blackFadeScreen:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		var logo:FlxSprite = new FlxSprite();
		logo.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/ring.webp'), 'assets/exe/ring.xml');
		logo.animation.addByPrefix('idle', 'idle', 60, true);
		logo.animation.play('idle', true);
		logo.scale.set(0.35, 0.35);
		logo.updateHitbox();

		logo.setPosition(FlxG.width - logo.width - 35, FlxG.height - logo.height - 35);
		add(logo);

		newBar = new FlxSprite(50, FlxG.height - 90).makeGraphic(Std.int(FlxG.width * 0.8), 40, 0xFFFFFFFF);
		add(newBar);

		loadedTxt = new FlxText(50, newBar.y - 50, 0, 'Loading... (?/?)', 40);
		loadedTxt.setFormat(Paths.font("visitor1.ttf"), 40);
		add(loadedTxt);

		blackFadeScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackFadeScreen.alpha = 0;
		add(blackFadeScreen);

		FlxTransitionableState.skipNextTransOut = true;
		super.create();

		if (checkLoaded())
		{
			dontUpdate = true;
			onLoad();
		}
	}

	var dotsCount:Int = 1;
	var dotsHold:Float = 0;

	var timeTaken:Float = 0;
	var isDoneLoading:Bool = false;
	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (dontUpdate || subState != null) return;

		var uploadsThisFrame = 0;
		while (gpuQueue.length > 0 && uploadsThisFrame < 2) 
		{
			mutex?.acquire();

			final task = gpuQueue.shift();
			mutex?.release();

			if (task?.bitmap != null)
				Paths.cacheBitmap(task.origKey, task.bitmap);
			
			mutex?.acquire();
			loaded++;
			mutex?.release();
			
			uploadsThisFrame++;
		}

		if (!transitioning)
			intendedPercent = loaded / loadMax;

		if (curPercent != intendedPercent)
		{
			if (Math.abs(curPercent - intendedPercent) < 0.001) curPercent = intendedPercent;
			else curPercent = FlxMath.lerp(intendedPercent, curPercent, Math.exp(-elapsed * 15));

			timeTaken += elapsed;

			dotsHold += elapsed;
			if (dotsHold >= 0.3)
			{
				dotsHold = 0;
				dotsCount = FlxMath.wrap(dotsCount + 1, 1, 3);
			}

			loadedTxt.text = "Loading" + StringTools.lpad("", ".", dotsCount) + " (" + loaded + "/" + loadMax + ") " + Math.floor(curPercent * 100) + "%";
			newBar.setGraphicSize(Std.int((FlxG.width * 0.8) * curPercent), 40);
			newBar.updateHitbox();
		}

		if (!finishedLoading && checkLoaded() && !transitioning)
		{
			loadedTxt.text = "Done! (Took " + (Math.round(timeTaken * 1000) / 1000) + " s)";
			FlxTween.tween(blackFadeScreen, {alpha: 1}, 1, {
				onComplete: function(_) {
					transitioning = true;
					onLoad();
					return;
				}
			});
			FlxTween.tween(FlxG.sound.music, {volume: 0}, 1);
		}
	}
	
	var finishedLoading:Bool = false;
	function onLoad()
	{
		_loaded();

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.camera.visible = false;
		
		FlxG.switchState(target);
		transitioning = true;
		finishedLoading = true;
		
		backend.MemoryUtil.clearMinor();
	}

	static function _loaded()
	{
		loaded = 0;
		loadMax = 0;
		initialThreadCompleted = true;
		isIntrusive = false;

		gpuQueue = [];

		threadPool?.shutdown();

		// kill all workers safely
		threadPool = null;
		mutex = null;
	}

	public static function checkLoaded():Bool
	{
		return (loaded >= loadMax && initialThreadCompleted && gpuQueue.length == 0);
	}

	public static function loadNextDirectory()
	{
		var directory:String = 'shared';

		final weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if (weekDir?.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
	}

	static var isIntrusive:Bool = false;
	public static function loadAndSwitchState(target:NextState, stopMusic = false, intrusive:Bool = true)
	{
		#if !SHOW_LOADING_SCREEN
		intrusive = false;
		#end

		LoadingState.isIntrusive = intrusive;
		_startPool();
		loadNextDirectory();

		if(intrusive)
			FlxG.switchState(() -> new LoadingState(target, stopMusic));
		
		if (stopMusic)
			FlxG.sound.music?.stop();

		while(true)
		{
			if(checkLoaded())
			{
				_loaded();
				break;
			}
			else Sys.sleep(0.001);
		}

		FlxG.switchState(target);
	}

	static var imagesToPrepare:Array<String> = [];
	static var soundsToPrepare:Array<String> = [];
	static var musicToPrepare:Array<String> = [];
	static var songsToPrepare:Array<String> = [];

	public static function prepare(images:Array<String> = null, sounds:Array<String> = null, music:Array<String> = null)
	{
		if (images != null) imagesToPrepare = imagesToPrepare.concat(images);
		if (sounds != null) soundsToPrepare = soundsToPrepare.concat(sounds);
		if (music != null) musicToPrepare = musicToPrepare.concat(music);
	}

	static var initialThreadCompleted:Bool = true;
	static var dontPreloadDefaultVoices:Bool = false;
	
	static function _startPool()
	{
		#if MULTITHREADED_LOADING
		var threads:Int = 4;
		#if cpp
		threads = getCPUThreadsCount();
		if (threads <= 0) threads = 4;
		#end
		
		var threadCount:Int = Std.int(Math.max(2, threads - 1));
		#else
		var threadCount:Int = 1;
		#end
		
		threadPool = new FixedThreadPool(threadCount);
	}

	public static function prepareToSong()
	{
		if(PlayState.SONG == null)
		{
			imagesToPrepare = [];
			soundsToPrepare = [];
			musicToPrepare = [];
			songsToPrepare = [];
			loaded = 0;
			loadMax = 0;
			initialThreadCompleted = true;
			isIntrusive = false;
			return;
		}

		Paths.localTrackedAssets = [];
		_startPool();
		imagesToPrepare = [];
		soundsToPrepare = [];
		musicToPrepare = [];
		songsToPrepare = [];

		initialThreadCompleted = false;
		var threadsCompleted:Int = 0;
		var threadsMax:Int = 0;

		function completedThread()
		{
			threadsCompleted++;
			if(threadsCompleted == threadsMax)
			{
				clearInvalids();
				startThreads();
				initialThreadCompleted = true;
			}
		}

		var song:SwagSong = PlayState.SONG;
		var folder:String = Paths.formatToSongPath(Song.loadedSongName);

		new Future<Bool>(() -> {
			var noteSkin:String = Note.defaultNoteSkin;
			if(PlayState.SONG.arrowSkin?.length > 1) noteSkin = PlayState.SONG.arrowSkin;
	
			final customSkin:String = noteSkin + Note.getNoteSkinPostfix();
			for (exts in Paths.IMAGE_EXTS) {
				if(Paths.fileExists('images/$customSkin.$exts', IMAGE)) noteSkin = customSkin;
				break;
			}

			imagesToPrepare.push(noteSkin);

			try
			{
				var path:String = Paths.json('$folder/preload');
				var json:Dynamic = null;

				var moddyFile:String = Paths.modsJson('$folder/preload');
				if (#if sys FileSystem.exists(moddyFile) || #end OpenFlAssets.exists(moddyFile)) json = Json.parse(Paths.getContent(moddyFile));
				else json = Json.parse(Paths.getContent(path));

				if(json != null)
				{
					var imgs:Array<String> = [];
					var snds:Array<String> = [];
					var mscs:Array<String> = [];
					for (asset in Reflect.fields(json))
					{
						var filters:Int = Reflect.field(json, asset);
						var asset:String = asset.trim();

						if(filters < 0 || StageData.validateVisibility(filters))
						{
							if(asset.startsWith('images/'))
								imgs.push(asset.substr('images/'.length));
							else if(asset.startsWith('sounds/'))
								snds.push(asset.substr('sounds/'.length));
							else if(asset.startsWith('music/'))
								mscs.push(asset.substr('music/'.length));
						}
					}
					prepare(imgs, snds, mscs);
				}
			}
			catch(e:Dynamic) {}
			return true;

		}, isIntrusive)
		.then((_) -> new Future<Bool>(() -> {
			if (song.stage == null || song.stage.length < 1)
				song.stage = StageData.vanillaSongStage(folder);

			var stageData:StageFile = StageData.getStageFile(song.stage);
			if (stageData != null)
			{
				var imgs:Array<String> = [];
				var snds:Array<String> = [];
				var mscs:Array<String> = [];
				if(stageData.preload != null)
				{
					for (asset in Reflect.fields(stageData.preload))
					{
						var filters:Int = Reflect.field(stageData.preload, asset);
						var asset:String = asset.trim();

						if(filters < 0 || StageData.validateVisibility(filters))
						{
							if(asset.startsWith('images/'))
								imgs.push(asset.substr('images/'.length));
							else if(asset.startsWith('sounds/'))
								snds.push(asset.substr('sounds/'.length));
							else if(asset.startsWith('music/'))
								mscs.push(asset.substr('music/'.length));
						}
					}
				}
				
				if (stageData.objects != null)
				{
					for (sprite in stageData.objects)
					{
						if(sprite.type == 'sprite' ||
						sprite.type == 'animatedSprite')
							if((sprite.filters < 0 || StageData.validateVisibility(sprite.filters)) && !imgs.contains(sprite.image))
								imgs.push(sprite.image);
					}
				}
				prepare(imgs, snds, mscs);
			}

			songsToPrepare.push('$folder/Inst');

			var player1:String = song.player1;
			var player2:String = song.player2;
			var gfVersion:String = song.gfVersion;
			var prefixVocals:String = song.needsVoices ? '$folder/Voices' : null;

			gfVersion ??= 'gf';

			dontPreloadDefaultVoices = false;
			preloadCharacter(player1, prefixVocals);
			if (!dontPreloadDefaultVoices && prefixVocals != null)
			{
				if(Paths.fileExists('$prefixVocals-Player.${Paths.SOUND_EXT}', SOUND, false, 'songs') && Paths.fileExists('$prefixVocals-Opponent.${Paths.SOUND_EXT}', SOUND, false, 'songs'))
				{
					songsToPrepare.push('$prefixVocals-Player');
					songsToPrepare.push('$prefixVocals-Opponent');

				}
				else if(Paths.fileExists('$prefixVocals.${Paths.SOUND_EXT}', SOUND, false, 'songs'))
					songsToPrepare.push(prefixVocals);
			}

			if (player2 != player1)
			{
				threadsMax++;
				threadPool.run(() -> {
					try { preloadCharacter(player2, prefixVocals); } catch (e:Dynamic) {}
					completedThread();
				});

			}
			if (!stageData.hide_girlfriend && gfVersion != player2 && gfVersion != player1)
			{
				threadsMax++;
				threadPool.run(() -> {
					try { preloadCharacter(gfVersion); } catch (e:Dynamic) {}
					completedThread();
				});

			}

			if(threadsCompleted == threadsMax)
			{
				clearInvalids();
				startThreads();
				initialThreadCompleted = true;
			}
			return true;
		}, isIntrusive))
		.onError((err:Dynamic) -> {
			trace('ERROR! while preparing song: $err');
		});

	}

	public static function clearInvalids()
	{
		clearInvalidFrom(imagesToPrepare, 'images', '.webp', IMAGE);
		clearInvalidFrom(soundsToPrepare, 'sounds', '.${Paths.SOUND_EXT}', SOUND);
		clearInvalidFrom(musicToPrepare, 'music', '.${Paths.SOUND_EXT}', SOUND);
		clearInvalidFrom(songsToPrepare, 'songs', '.${Paths.SOUND_EXT}', SOUND, 'songs');

		for (arr in [imagesToPrepare, soundsToPrepare, musicToPrepare, songsToPrepare])
			while (arr.contains(null))
				arr.remove(null);
	}

	static function clearInvalidFrom(arr:Array<String>, prefix:String, ext:String, type:AssetType, ?parentFolder:String = null)
	{
		for (folder in arr.copy())
		{
			var nam:String = folder.trim();

			if(nam.endsWith('/'))
			{
				for (subfolder in Mods.directoriesWithFile(Paths.getSharedPath(), '$prefix/$nam'))
				{
					for (file in FileSystem.readDirectory(subfolder))
					{
						if(file.endsWith(ext))
						{
							var toAdd:String = nam + haxe.io.Path.withoutExtension(file);
							if(!arr.contains(toAdd)) arr.push(toAdd);
						}
					}
				}
			}
		}

		var i:Int = 0;

		while(i < arr.length)
		{
			var member:String = arr[i];
			var myKey = '$prefix/$member$ext';
			if(parentFolder == 'songs') myKey = '$member$ext';
			var doTrace:Bool = false;

			if(member.endsWith('/') || (!Paths.fileExists(myKey, type, false, parentFolder) && (doTrace = true)))
			{
				arr.remove(member);
			}
			else i++;
		}
	}

	public static function startThreads()
	{
		mutex = new Mutex();

		loadMax = imagesToPrepare.length + soundsToPrepare.length + musicToPrepare.length + songsToPrepare.length;
		loaded = 0;

		_threadFunc();
	}

	static function _threadFunc()
	{
		_startPool();

		for (sound in soundsToPrepare) initThread(() -> preloadSound('sounds/$sound'), 'sound $sound', false);
		for (music in musicToPrepare) initThread(() -> preloadSound('music/$music'), 'music $music', false);
		for (song in songsToPrepare) initThread(() -> { preloadSongPath(song); return true; }, 'song $song', false);
		for (image in imagesToPrepare) initThread(() -> { preloadGraphic(image); return true; }, 'image $image', true);
	}

	static function initThread(func:Void->Dynamic, traceData:String, isGraphic:Bool = false)
	{
		threadPool.run(() -> {
			try {
				func();
			}
			catch(e:Dynamic) {
				trace('ERROR! fail on preloading $traceData: $e');
			}
			
			if (!isGraphic) {
				mutex.acquire();
				loaded++;
				mutex.release();
			}
		});

	}

	inline private static function preloadCharacter(char:String, ?prefixVocals:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			var character:Dynamic = Json.parse(Paths.getContent(path));

			var isAnimateAtlas:Bool = false;
			var img:String = character.image;
			img = img.trim();
			
			#if flixel_animate
			var animToFind:String = Paths.getPath('images/$img/Animation.json', TEXT);
			if (#if sys FileSystem.exists(animToFind) || #end OpenFlAssets.exists(animToFind))
				isAnimateAtlas = true;
				trace(isAnimateAtlas);
			#end
	
			if (prefixVocals != null && character.vocals_file?.length > 0)
			{
				songsToPrepare.push(prefixVocals + "-" + character.vocals_file);

				if(char == PlayState.SONG.player1) dontPreloadDefaultVoices = true;
			}
		}
		catch(e:haxe.Exception)
		{
			trace(e.details());
		}
	}

	static function preloadSound(key:String, ?path:String, ?modsAllowed:Bool = true, ?beepOnNull:Bool = true):Null<Sound>
	{
		var file:String = Paths.getPath(Language.getFileTranslation(key) + '.${Paths.SOUND_EXT}', SOUND, path, modsAllowed);

		if(!Paths.currentTrackedSounds.exists(file))
		{
			#if sys
			final onDisk:Bool = FileSystem.exists(file);
			#else
			final onDisk:Bool = false;
			#end
			if (onDisk || OpenFlAssets.exists(file, SOUND))
			{
				var sound:Sound = #if sys onDisk ? Sound.fromFile(file) : #end OpenFlAssets.getSound(file, false);
				mutex.acquire();
				Paths.currentTrackedSounds.set(file, sound);

				mutex.release();
			}
			else if (beepOnNull)
			{
				return FlxAssets.getSoundAddExtension('flixel/sounds/beep');
			}
		}
		mutex.acquire();
		Paths.localTrackedAssets.push(file);
		mutex.release();

		return Paths.currentTrackedSounds.get(file);

	}

	static function preloadSongPath(key:String):Void
	{
		var file:String = Paths.getPath(Language.getFileTranslation(key) + '.${Paths.SOUND_EXT}', SOUND, 'songs', true);
		#if sys
		if (FileSystem.exists(file))
		{
			mutex.acquire();
			Paths.localTrackedAssets.push(file);
			mutex.release();
		}
		else
		#end
		if (OpenFlAssets.exists(file, SOUND))
		{
			mutex.acquire();
			Paths.localTrackedAssets.push(file);

			mutex.release();
		}
	}

	static function preloadGraphic(key:String):Void
	{
		try {
			var requestKey:String = 'images/$key';
			#if TRANSLATIONS_ALLOWED requestKey = Language.getFileTranslation(requestKey);
			#end
			
			if (requestKey.endsWith('.webp'))
				requestKey = requestKey.substr(0, requestKey.length - 4);

			if (!Paths.currentTrackedAssets.exists(requestKey))
			{
				final graphic:FlxGraphic = Paths.cacheBitmap(requestKey, null, null);
				
				if (graphic?.bitmap != null)
				{
					mutex.acquire();
					gpuQueue.push({origKey: requestKey, bitmap: graphic.bitmap});
					mutex.release();
					return;
				}
			}

			mutex.acquire();
			loaded++;
			mutex.release();
		}
		catch(e:haxe.Exception)
		{
			trace('ERROR! fail on preloading image $key: ${e.message}');
			mutex.acquire();
			loaded++;
			mutex.release();
		}
	}
	
	#if cpp
	@:functionCode('
		return std::thread::hardware_concurrency();
    ')
	@:noCompletion
    public static function getCPUThreadsCount():Int
    {
        return -1;

    }
    #end
}