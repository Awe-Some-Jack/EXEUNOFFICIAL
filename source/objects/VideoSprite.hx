package objects;

#if VIDEOS_ALLOWED
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import hxvlc.flixel.FlxVideoSprite;

class VideoSprite extends FlxSpriteGroup
{
	public static final ARG_LOOPING:String = ':input-repeat=2147483647';
	public static final ARG_MUTED:String = ':no-audio';
	public static final ARG_HW_ACCEL:String = ':avcodec-hw=any';

	public var video:FlxVideoSprite;

	public var isStateAffected:Bool = true;
	public var autoDestroyOnComplete:Bool = true;

	public var canSkip:Bool = false;
	public var skipHold:Float = 0;
	public var skipNeed:Float = 1;
	public var pie:FlxSprite;
	public var pieTrack:FlxSprite;

	private static final SKIP_RING_SCALE:Float = 0.35;
	private static final SKIP_RING_MARGIN_X:Float = 24;
	private static final SKIP_RING_MARGIN_Y:Float = 70;

	public var onSkip:Void->Void = null;

	private var wasPlayingBeforeFocusLost:Bool = false;

	public function new(x:Float = 0, y:Float = 0, autoDestroy:Bool = true)
	{
		super(x, y);

		autoDestroyOnComplete = autoDestroy;

		video = new FlxVideoSprite(0, 0);
		add(video);

		if (autoDestroy)
			video.bitmap.onEndReached.add(onVideoComplete, true, -10);

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
		video.play();

	public inline function pause():Void
		video.bitmap?.pause();

	public inline function resume():Void
		video.bitmap?.resume();

	public inline function stop():Void
		video.bitmap?.stop();

	public function onComplete(callback:Void->Void):VideoSprite
	{
		video.bitmap.onEndReached.add(callback, true);
		return this;
	}

	public function onStart(callback:Void->Void):VideoSprite
	{
		video.bitmap.onOpening.add(callback, true);
		return this;
	}

	public function onFormat(callback:Void->Void):VideoSprite
	{
		video.bitmap.onFormatSetup.add(callback, true);
		return this;
	}

	public function onEnd(func:Void->Void, once:Bool = false, priority:Int = 0):Void
		video.bitmap.onEndReached.add(func, once, priority);

	public function onStartEvent(func:Void->Void, once:Bool = false, priority:Int = 0):Void
		video.bitmap.onOpening.add(func, once, priority);

	public function onFormatEvent(func:Void->Void, once:Bool = false, priority:Int = 0):Void
		video.bitmap.onFormatSetup.add(func, once, priority);

	public function setTime(time:Float):Void
	{
		if (video.bitmap != null)
			video.bitmap.time = haxe.Int64.fromFloat(time * 1000);
	}

	public function getTime():Float
	{
		if (video.bitmap != null)
		{
			final time64 = video.bitmap.time;
			final microSeconds:Float = (time64.high * 4294967296.0) + time64.low;
			return microSeconds / 1000;
		}

		return 0;
	}

	public function setVideoPercent(percent:Float):Void
	{
		if (video.bitmap != null)
		{
			video.bitmap.position = Math.max(0, Math.min(1, percent));

			if (!video.bitmap.isPlaying)
				video.bitmap.play();
		}
	}

	public function getVideoPercent():Float
		return video.bitmap != null ? video.bitmap.position : 0;

	public function seekToMs(ms:Float):Void
	{
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
	}

	public function seekToSeconds(seconds:Float):Void
		seekToMs(seconds * 1000);

	public function isPlaying():Bool
		return video.bitmap != null && video.bitmap.isPlaying;

	private function setupEventListeners():Void
	{
		if (video.bitmap != null && isStateAffected)
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
			wasPlayingBeforeFocusLost = isPlaying();
			
			if (wasPlayingBeforeFocusLost)
				video.bitmap?.pause();
		}
	}

	private function onFocusGained():Void
	{
		if (FlxG.autoPause && wasPlayingBeforeFocusLost)
			video.bitmap?.resume();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (canSkip)
		{
			pieTrack.visible = true;
			pieTrack.alpha = 0.35;

			if (FlxG.keys.pressed.SPACE)
			{
				skipHold += elapsed;
				var progress:Float = skipHold / skipNeed;
				pie.scale.set(SKIP_RING_SCALE * progress, SKIP_RING_SCALE * progress);
				pie.alpha = FlxMath.remapToRange(progress, 0.025, 1, 0, 1);

				if (skipHold >= skipNeed)
				{
					if (onSkip != null)
						onSkip();

					video.bitmap?.stop();
					destroy();
				}
			}
			else
			{
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

		super.destroy();
	}
}
#end