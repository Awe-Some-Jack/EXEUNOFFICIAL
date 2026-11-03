package objects;

#if VIDEOS_ALLOWED
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

#if switch
import switchvideo.SwitchVideo;
#else
import hxvlc.flixel.FlxVideoSprite;
#end

class VideoSprite extends FlxSpriteGroup
{
	public static final ARG_LOOPING:String = ':input-repeat=2147483647';
	public static final ARG_MUTED:String = ':no-audio';
	public static final ARG_HW_ACCEL:String = ':avcodec-hw=any';
	public static final ARG_DROP_LATE:String = ':drop-late-frames';
    public static final ARG_SKIP_FRAMES:String = ':skip-frames';

	#if switch
	public var video:SwitchVideo;
	#else
	public var video:FlxVideoSprite;
	#end

	public var isStateAffected(default, set):Bool = true;
	public var autoDestroyOnComplete:Bool = true;

	public var canSkip:Bool = false; // Deprecated?
	public var skipHold:Float = 0;
	public var skipNeed:Float = 1.5;
	public var pie:FlxSprite;
	public var pieTrack:FlxSprite;

	private static final SKIP_RING_SCALE:Float = 0.35;
	private static final SKIP_RING_MARGIN_X:Float = 24;
	private static final SKIP_RING_MARGIN_Y:Float = 70;

	private var syncLeniency:Float = 600.0;

	public var onSkip:Void->Void = null;

	public var initialConductTime:Float = 0;

	private var wasPlayingBeforeFocusLost:Bool = false;
	private var skipKeyReleasedOnce:Bool = false;

	private var _shouldBePlaying:Bool = false;
	private var _isLooped:Bool = false;
	private var _preloadKey:String = null;

	#if switch
	var _endCallbacks:Array<Void->Void> = [];
	var _formatCallbacks:Array<Void->Void> = [];
	#end

	public function new(x:Float = 0, y:Float = 0, autoDestroy:Bool = true)
	{
		super(x, y);

		autoDestroyOnComplete = autoDestroy;

		#if switch
		video = new SwitchVideo();
		video.setPosition(0, 0);
		video.onEndReached = () ->
		{
			final callbacks:Array<Void->Void> = _endCallbacks.copy();
			new FlxTimer().start(0.25, _ ->
			{
				for (cb in callbacks)
					cb();
			});
		};
		video.onFormatSetup = () ->
		{
			video.visible = true;
			for (cb in _formatCallbacks)
				cb();
		};
		#else
		video = new FlxVideoSprite(0, 0);
		#end
		add(video);

		#if switch
		if (autoDestroy)
			_endCallbacks.push(onVideoComplete);
		#else
		if (autoDestroy)
			video.bitmap.onEndReached.add(onVideoComplete, true, -10);
		#end

		pieTrack = new FlxSprite(0, 0);
		pieTrack.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/ring.webp'), 'assets/exe/ring.xml');
		pieTrack.animation.addByPrefix('idle', 'idle', 60, true);
		pieTrack.animation.play('idle', true);
		pieTrack.scale.set(SKIP_RING_SCALE, SKIP_RING_SCALE);
		pieTrack.updateHitbox();
		pieTrack.setPosition(SKIP_RING_MARGIN_X, FlxG.height - pieTrack.height - SKIP_RING_MARGIN_Y);
		pieTrack.color = FlxColor.BLACK;
		pieTrack.alpha = 0;
		add(pieTrack);

		pie = new FlxSprite(0, 0);
		pie.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/ring.webp'), 'assets/exe/ring.xml');
		pie.animation.addByPrefix('idle', 'idle', 60, true);
		pie.animation.play('idle', true);
		pie.scale.set(SKIP_RING_SCALE, SKIP_RING_SCALE);
		pie.updateHitbox();
		pie.setPosition(SKIP_RING_MARGIN_X, FlxG.height - pie.height - SKIP_RING_MARGIN_Y);
		pie.scale.set(0, 0);
		pie.alpha = 0;
		add(pie);

		setupEventListeners();
	}

	static function shouldMute(path:String):Bool
	{
		if (FlxG.sound.muted || FlxG.sound.volume <= 0)
			return true;

		#if sys
		try
		{
			if (!sys.FileSystem.exists(path))
				return false;

			final total:Int = sys.FileSystem.stat(path).size;
			final f = sys.io.File.read(path, true);
			f.bigEndian = true;
			var pos:Int = 0;
			var result:Bool = false;
			while (pos + 8 <= total)
			{
				f.seek(pos, SeekBegin);
				var size:Int = f.readInt32();
				final type:String = f.readString(4);
				var header:Int = 8;
				if (pos == 0 && type != 'ftyp')
					break;
				if (size == 1)
				{
					f.readInt32();
					size = f.readInt32();
					header = 16;
				}
				else if (size == 0)
					size = total - pos;
				if (size < header)
					break;
				if (type == 'moov')
				{
					final len:Int = size - header;
					result = f.read(len).toString().indexOf('soun') == -1;
					break;
				}
				pos += size;
			}
			f.close();
			return result;
		}
		catch (e:Dynamic) {}
		#end
		return false;
	}

	public function loadVideo(videoPath:String, ?args:Array<String>):Bool
	{
		if (videoPath == null || videoPath == "")
		{
			trace("Video path is empty!");
			return false;
		}

		try
		{
			var loadArgs:Array<String> = args?.copy() ?? [];

			#if !switch
			if (_preloadKey != null)
			{
				if (_preloadKey == preloadKeyOf(videoPath, args))
				{
					_isLooped = args?.contains(ARG_LOOPING) ?? false;
					return true;
				}
				_preloadKey = null;
			}
			#end

			#if switch
			final wantsLoop:Bool = loadArgs.remove(ARG_LOOPING);
			loadArgs.remove(ARG_MUTED);
			loadArgs.remove(ARG_HW_ACCEL);
			loadArgs.remove(ARG_DROP_LATE);
			loadArgs.remove(ARG_SKIP_FRAMES);

			if (wantsLoop)
				video.setLooping(true);

			video.visible = false;
			final success = video.load(backend.SwitchStorage.toDevicePath(videoPath), wantsLoop ? ['input-repeat=65545'] : null);
			if (success && args?.contains(ARG_MUTED))
				video.setVolume(0);
			#else
			if (!loadArgs.contains(ARG_MUTED) && shouldMute(videoPath))
				loadArgs.push(ARG_MUTED);
			if (!loadArgs.contains(ARG_HW_ACCEL))
				loadArgs.push(ARG_HW_ACCEL);
			if (!loadArgs.contains(ARG_DROP_LATE))
				loadArgs.push(ARG_DROP_LATE);
			if (!loadArgs.contains(ARG_SKIP_FRAMES))
				loadArgs.push(ARG_SKIP_FRAMES);

			_isLooped = args?.contains(ARG_LOOPING) ?? false;

			final success = video.load(videoPath, loadArgs);
			if (success)
			{
				if (video.bitmap != null && FlxG.sound.music != null)
					video.bitmap.rate = FlxG.sound.music.pitch;
			}
			#end

			return success;
		}
		catch (e:Dynamic)
		{
			trace('Exception loading video: $e | Path: $videoPath');
			return false;
		}
	}

	public function precacheVideo(videoPath:String, ?args:Array<String>):Bool
	{
		if (videoPath == null || videoPath == "")
		{
			trace("Video path is empty!");
			return false;
		}

		try
		{
			var loadArgs:Array<String> = args?.copy() ?? [];

			#if switch
			return true;
			#else
			if (!loadArgs.contains(ARG_MUTED) && shouldMute(videoPath))
				loadArgs.push(ARG_MUTED);
			if (!loadArgs.contains(ARG_HW_ACCEL))
				loadArgs.push(ARG_HW_ACCEL);
			if (!loadArgs.contains(ARG_DROP_LATE))
				loadArgs.push(ARG_DROP_LATE);
			if (!loadArgs.contains(ARG_SKIP_FRAMES))
				loadArgs.push(ARG_SKIP_FRAMES);

			final cached:Bool = video.precache(videoPath, loadArgs);
			_preloadKey = cached ? preloadKeyOf(videoPath, args) : null;
			return cached;
			#end
		}
		catch (e:Dynamic)
		{
			trace('Exception occurred while precaching video: $e | Path: $videoPath');
			return false;
		}
	}

	override public function setGraphicSize(width:Float = 0, height:Float = 0):Void
	{
		video.setGraphicSize(width, height);
		video.updateHitbox();
	}

	public function playDelayed(delay:Float = 0):Void
	{
		_shouldBePlaying = true;

		if (delay <= 0)
			play();
		else
			new FlxTimer().start(delay, _ -> play());

		#if !switch
		if (video.bitmap != null)
			video.bitmap.rate = PlayState.instance?.playbackRate ?? 1.0;
		#end
	}

	public function play():Void
	{
		_shouldBePlaying = true;
		initialConductTime = Conductor.songPosition;

		#if !switch
		if (_preloadKey != null)
		{
			_preloadKey = null;
			video.resume();
			new FlxTimer().start(0.15, _ -> {
				if (alive && _shouldBePlaying && !isPlaying())
					video.play();
			});
			return;
		}
		#end

		video.play();
	}

	static function preloadKeyOf(path:String, args:Array<String>):String
		return path + '|' + (args ?? []).join(',');

	public inline function pause():Void
		video?.pause();

	public inline function resume():Void
		video?.resume();

	public inline function stop():Void
	{
		_shouldBePlaying = false;
		video?.stop();
	}

	public function onComplete(callback:Void->Void):VideoSprite
	{
		#if switch
		_endCallbacks.push(callback);
		#else
		video.bitmap.onEndReached.add(callback, true);
		#end
		return this;
	}

	public function onStart(callback:Void->Void):VideoSprite
	{
		#if switch
		_formatCallbacks.push(callback);
		#else
		video.bitmap.onOpening.add(callback, true);
		#end
		return this;
	}

	public function onFormat(callback:Void->Void):VideoSprite
	{
		#if switch
		_formatCallbacks.push(callback);
		#else
		video.bitmap.onFormatSetup.add(callback, true);
		#end
		return this;
	}

	public function onEnd(func:Void->Void, once:Bool = false, priority:Int = 0):Void
		#if switch _endCallbacks.push(func); #else video.bitmap.onEndReached.add(func, once, priority); #end

	public function onStartEvent(func:Void->Void, once:Bool = false, priority:Int = 0):Void
		#if switch _formatCallbacks.push(func); #else video.bitmap.onOpening.add(func, once, priority); #end

	public function onFormatEvent(func:Void->Void, once:Bool = false, priority:Int = 0):Void
		#if switch _formatCallbacks.push(func); #else video.bitmap.onFormatSetup.add(func, once, priority); #end

	public function setTime(time:Float):Void
	{
		#if switch
		if (video != null)
			video.time = Std.int(time);
		#else
		if (video.bitmap != null)
			video.bitmap.time = haxe.Int64.fromFloat(time);
		#end
	}

	public function getTime():Float
	{
		#if switch
		return video?.time ?? 0;
		#else
		if (video.bitmap != null)
		{
			final time64 = video.bitmap.time;
			return (time64.high * 4294967296.0) + time64.low;
		}

		return 0;
		#end
	}

	public function setVideoPercent(percent:Float):Void
	{
		#if switch
		if (video != null)
		{
			video.position = Math.max(0, Math.min(1, percent));

			if (!video.isPlaying)
				play();
		}
		#else
		if (video.bitmap != null)
		{
			video.bitmap.position = Math.max(0, Math.min(1, percent));

			if (!video.bitmap.isPlaying)
				play();
		}
		#end
	}

	public function getVideoPercent():Float
		#if switch
		return video?.position ?? 0;
		#else
		return video.bitmap?.position ?? 0;
		#end

	public function seekToMs(ms:Float):Void
	{
		#if switch
		if (video == null)
			return;

		final durationMs = video.duration;
		if (durationMs <= 0)
		{
			setTime(ms);
			return;
		}

		setVideoPercent(ms / durationMs);
		#else
		if (video.bitmap == null) return;

		final durationMs = video.bitmap.length;
		if (haxe.Int64.compare(durationMs, haxe.Int64.ofInt(0)) <= 0)
		{
			setTime(ms);
			return;
		}

		final durFloat = (durationMs.high * 4294967296.0) + durationMs.low;

		if (durFloat > 0)
			setVideoPercent(ms / durFloat);
		#end
	}

	public function seekToSeconds(seconds:Float):Void
		seekToMs(seconds * 1000);

	public function isPlaying():Bool
		#if switch
		return video?.isPlaying;
		#else
		return video.bitmap?.isPlaying;
		#end

	private function setupEventListeners():Void
	{
		#if switch
		if (isStateAffected)
		#else
		if (video.bitmap != null && isStateAffected)
		#end
		{
			FlxG.signals.focusGained.add(onFocusGained);
			FlxG.signals.focusLost.add(onFocusLost);
		}
	}

	private function set_isStateAffected(value:Bool):Bool
	{
		isStateAffected = value;
		FlxG.signals.focusGained.remove(onFocusGained);
		FlxG.signals.focusLost.remove(onFocusLost);
		if (value)
		{
			FlxG.signals.focusGained.add(onFocusGained);
			FlxG.signals.focusLost.add(onFocusLost);
		}
		return value;
	}

	private function onVideoComplete():Void
	{
		if (autoDestroyOnComplete)
		{
			new FlxTimer().start(0.1, function(_)
			{
				destroy();
			});
		}
	}

	private function onFocusLost():Void
	{
		if (FlxG.autoPause)
		{
			wasPlayingBeforeFocusLost = isPlaying() || _shouldBePlaying;
			pause();
		}
	}

	private function onFocusGained():Void
	{
		if ((PlayState.instance != null && !PlayState.instance.paused || PlayState.instance == null) && FlxG.autoPause && wasPlayingBeforeFocusLost)
		{
			resume(); // sure???????'
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if switch
		if (video != null && (video.graphic == null || video.graphic.isDestroyed))
			video.visible = false;
		#end

		#if (switch && FLX_SOUND_SYSTEM)
		video?.setVolume((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
		#end

		final isGamePaused:Bool = PlayState.instance?.paused ?? true;
		if (isPlaying() && !isGamePaused && !PlayState.instance.inCutscene && ClientPrefs.data?.freezeSyncDelay && !_isLooped && Conductor.songPosition > 0)
		{
			final targetTime:Float = Conductor.songPosition - initialConductTime - Conductor.offset;
			if (targetTime >= 0)
			{
				final drift:Float = Math.abs(getTime() - targetTime);
				if (drift > syncLeniency)
					setTime(targetTime);
			}
		}

		if(canSkip) 
		{
			if ((FlxG.keys.pressed.SPACE #if mobile || PlayState.instance?.pressHolding #end) && skipKeyReleasedOnce)
			{
				skipHold += elapsed;

				final progress:Float = skipHold / skipNeed;
				pie.scale.set(SKIP_RING_SCALE * progress, SKIP_RING_SCALE * progress);
				pie.alpha = FlxMath.remapToRange(progress, 0.025, 1, 0, 1);
				pieTrack.alpha = FlxMath.lerp(pieTrack.alpha, 0.35, 15 * elapsed);

				if (skipHold >= skipNeed)
				{
					if (onSkip != null)
						onSkip();

					stop();
					destroy();
				}
			}
			else
			{
				if (!FlxG.keys.pressed.SPACE #if mobile && PlayState.instance != null && !PlayState.instance.pressHolding #end)
					skipKeyReleasedOnce = true;

				skipHold = 0;

				pieTrack.alpha = FlxMath.lerp(pieTrack.alpha, 0, 22 * elapsed);
				pie.scale.x = FlxMath.lerp(pie.scale.x, 0, 22 * elapsed);
				pie.scale.y = FlxMath.lerp(pie.scale.y, 0, 22 * elapsed);
			}
		}
	}

	override public function destroy():Void
	{
		#if !switch
		final player = video?.bitmap;
		#end

		#if switch
		if (video != null)
		{
			_endCallbacks = [];
			_formatCallbacks = [];

			FlxG.signals.focusGained.remove(onFocusGained);
			FlxG.signals.focusLost.remove(onFocusLost);

			stop();

			remove(video, true);
			video.destroy();
			video = null;
		}
		#else
		if (video?.bitmap != null)
		{
			video.bitmap.onEndReached.removeAll();
			video.bitmap.onOpening.removeAll();
			video.bitmap.onFormatSetup.removeAll();

			FlxG.signals.focusGained.remove(onFocusGained);
			FlxG.signals.focusLost.remove(onFocusLost);

			stop();
		}
		#end

		super.destroy();

		#if !switch
		if (player != null)
		{
			@:privateAccess player.videoOutput = null;
			@:privateAccess player.mediaEvents = null;
		}
		#end
	}
}
#end