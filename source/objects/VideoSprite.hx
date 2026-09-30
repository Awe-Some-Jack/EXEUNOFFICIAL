package objects;

#if VIDEOS_ALLOWED
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

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

	#if switch
	public var video:SwitchVideo;
	#else
	public var video:FlxVideoSprite;
	#end

	public var isStateAffected:Bool = true;
	public var autoDestroyOnComplete:Bool = true;

	public var canSkip:Bool = false;
	public var skipHold:Float = 0;
	public var skipNeed:Float = 1;
	public var pie:FlxSprite;
	public var pieTrack:FlxSprite;

	var skipKeyReleasedOnce:Bool = false;

	private static final SKIP_RING_SCALE:Float = 0.35;
	private static final SKIP_RING_MARGIN_X:Float = 24;
	private static final SKIP_RING_MARGIN_Y:Float = 70;

	public var onSkip:Void->Void = null;

	private var wasPlayingBeforeFocusLost:Bool = false;
	private var _shouldBePlaying:Bool = false;

	public var playStateSrc:Bool = false;

	#if switch
	var _endCallbacks:Array<Void->Void> = [];
	var _formatCallbacks:Array<Void->Void> = [];
	#end

	public function new(x:Float = 0, y:Float = 0, autoDestroy:Bool = true, ?playStateSrc:Bool = false)
	{
		super(x, y);

		autoDestroyOnComplete = autoDestroy;
		this.playStateSrc = playStateSrc;

		#if switch
		video = new SwitchVideo();
		video.setPosition(0, 0);
		video.onEndReached = function():Void
		{
			for (cb in _endCallbacks)
				cb();
		};
		video.onFormatSetup = function():Void
		{
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
		pieTrack.frames = FlxAtlasFrames.fromSparrow('assets/exe/ring.webp', 'assets/exe/ring.xml');
		pieTrack.animation.addByPrefix('idle', 'idle', 60, true);
		pieTrack.animation.play('idle', true);
		pieTrack.scale.set(SKIP_RING_SCALE, SKIP_RING_SCALE);
		pieTrack.updateHitbox();
		pieTrack.setPosition(SKIP_RING_MARGIN_X, FlxG.height - pieTrack.height - SKIP_RING_MARGIN_Y);
		pieTrack.color = FlxColor.BLACK;
		pieTrack.alpha = 0;
		add(pieTrack);

		pie = new FlxSprite(0, 0);
		pie.frames = FlxAtlasFrames.fromSparrow('assets/exe/ring.webp', 'assets/exe/ring.xml');
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

	public function loadVideo(videoPath:String, ?args:Array<String>):Bool
	{
		if (videoPath == null || videoPath == "")
		{
			trace("Video path is empty!");
			return false;
		}

		try
		{
			var loadArgs:Array<String> = args != null ? args.copy() : [];

			#if switch
			var wantsLoop:Bool = loadArgs.remove(ARG_LOOPING);
			loadArgs.remove(ARG_MUTED);
			loadArgs.remove(ARG_HW_ACCEL);
			if (wantsLoop)
				video.setLooping(true);

			var success = video.load(videoPath, wantsLoop ? ['input-repeat=65545'] : null);

			if (success && args != null && args.contains(ARG_MUTED))
				video.setVolume(0);
			#else
			if (!loadArgs.contains(ARG_HW_ACCEL))
				loadArgs.push(ARG_HW_ACCEL);

			var success = video.load(videoPath, loadArgs);

			if (success)
			{
				#if FLX_PITCH
				if (video.bitmap != null && FlxG.sound.music != null)
					video.bitmap.rate = FlxG.sound.music.pitch;
				#end
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

	public function playDelayed(delay:Float = 0):Void
	{
		_shouldBePlaying = true;

		if (delay <= 0)
			video.play();
		else
			new FlxTimer().start(delay, _ -> video.play());

		#if FLX_PITCH
		if (video.bitmap != null)
			video.bitmap.rate = PlayState.instance != null ? PlayState.instance.playbackRate : 1.0;
		#end
	}

    override public function setGraphicSize(width:Float = 0, height:Float = 0):Void
    {
        video.setGraphicSize(width, height);
        video.updateHitbox();
    }

	public inline function play():Void
	{
		_shouldBePlaying = true;
		video.play();
	}

	public inline function pause():Void
		#if switch video?.pause(); #else video.bitmap?.pause(); #end

	public inline function resume():Void
		#if switch video?.resume(); #else video.bitmap?.resume(); #end

	public inline function stop():Void
	{
		_shouldBePlaying = false;
		#if switch video?.stop(); #else video.bitmap?.stop(); #end
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
			video.bitmap.time = haxe.Int64.fromFloat(time * 1000);
		#end
	}

	public function getTime():Float
	{
		#if switch
		return video != null ? video.time : 0;
		#else
		if (video.bitmap != null)
		{
			final time64 = video.bitmap.time;
			final microSeconds:Float = (time64.high * 4294967296.0) + time64.low;
			return microSeconds / 1000;
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
				video.play();
		}
		#else
		if (video.bitmap != null)
		{
			video.bitmap.position = Math.max(0, Math.min(1, percent));

			if (!video.bitmap.isPlaying)
				video.bitmap.play();
		}
		#end
	}

	public function getVideoPercent():Float
		#if switch
		return video != null ? video.position : 0;
		#else
		return video.bitmap != null ? video.bitmap.position : 0;
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

		final durationMicro = video.bitmap.length;

		if (haxe.Int64.compare(durationMicro, haxe.Int64.ofInt(0)) <= 0)
		{
			setTime(ms);
			return;
		}

		final targetMicro = haxe.Int64.fromFloat(ms * 1000);
		final durationFloat = haxe.Int64.toInt(durationMicro);
		final targetFloat = haxe.Int64.toInt(targetMicro);

		if (durationFloat > 0)
			setVideoPercent(targetFloat / durationFloat);
		#end
	}

	public function seekToSeconds(seconds:Float):Void
		seekToMs(seconds * 1000);

	public function isPlaying():Bool
		#if switch
		return video != null && video.isPlaying;
		#else
		return video.bitmap != null && video.bitmap.isPlaying;
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
			#if switch
			video?.pause();
			#else
			video.bitmap?.pause();
			#end
		}
	}

	private function onFocusGained():Void
	{
		if ((playStateSrc && !PlayState.instance.paused) && FlxG.autoPause && wasPlayingBeforeFocusLost)
		{
			#if switch
			video?.resume();
			#else
			video.bitmap?.play(); // sure???????'
			#end
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if switch
		#if FLX_SOUND_SYSTEM
		if (video != null)
			video.setVolume((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
		#end
		#end

		if (canSkip)
		{
			pieTrack.visible = true;
			pieTrack.alpha = 0.35;

			if ((FlxG.keys.pressed.SPACE || #if mobile PlayState.instance.pressHolding #else false #end) && skipKeyReleasedOnce)
			{
				skipHold += elapsed;
				var progress:Float = skipHold / skipNeed;
				pie.scale.set(SKIP_RING_SCALE * progress, SKIP_RING_SCALE * progress);
				pie.alpha = FlxMath.remapToRange(progress, 0.025, 1, 0, 1);

				if (skipHold >= skipNeed)
				{
					if (onSkip != null)
						onSkip();

					#if switch
					video?.stop();
					#else
					video.bitmap?.stop();
					#end
					destroy();
				}
			}
			else
			{
				if (!FlxG.keys.pressed.SPACE && !(#if mobile PlayState.instance.pressHolding #else false #end))
					skipKeyReleasedOnce = true;

				skipHold = 0;
				pie.scale.set(0, 0);
			}
		}
		else
		{
			pie.visible = false;
			pieTrack.visible = false;
		}
	}

	override public function destroy():Void
	{
		#if switch
		if (video != null)
		{
			_endCallbacks = [];
			_formatCallbacks = [];

			if (isStateAffected)
			{
				FlxG.signals.focusGained.remove(onFocusGained);
				FlxG.signals.focusLost.remove(onFocusLost);
			}

			video.stop();
		}
		#else
		if (video != null && video.bitmap != null)
		{
			video.bitmap.onEndReached.removeAll();
			video.bitmap.onOpening.removeAll();
			video.bitmap.onFormatSetup.removeAll();

			if (isStateAffected)
			{
				FlxG.signals.focusGained.remove(onFocusGained);
				FlxG.signals.focusLost.remove(onFocusLost);
			}

			video.bitmap.stop();
		}
		#end

		super.destroy();
	}
}
#end
