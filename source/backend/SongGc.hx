package backend;

import flixel.FlxG;
import states.PlayState;

class SongGc
{
	static inline var CAP_BYTES:Float = 120 * 1048576;

	static var active:Bool = false;
	static var suspended:Bool = false;
	static var baseMem:Float = 0;

	public static function start():Void
	{
		#if mobile
		if (active) return;
		active = true;
		baseMem = MemoryUtil.heapInUse();
		setSuspended(true);
		FlxG.signals.postUpdate.add(onPostUpdate);
		#end
	}

	public static function stop():Void
	{
		#if mobile
		if (!active) return;
		active = false;
		FlxG.signals.postUpdate.remove(onPostUpdate);
		setSuspended(false);
		#end
	}

	static function setSuspended(value:Bool):Void
	{
		if (suspended == value) return;
		suspended = value;
		if (value) MemoryUtil.disable();
		else MemoryUtil.enable();
	}

	static function onPostUpdate():Void
	{
		final game:PlayState = PlayState.instance;
		if (game == null)
		{
			stop();
			return;
		}

		final shouldSuspend:Bool = !game.paused && !game.endingSong;
		final grown:Float = MemoryUtil.heapInUse() - baseMem;
		if (shouldSuspend && grown > CAP_BYTES)
		{
			trace('SongGc: heap grew ${Math.round(grown / 1048576)} MB past the song baseline (cap ${Math.round(CAP_BYTES / 1048576)} MB), collecting');
			setSuspended(false);
			MemoryUtil.clearMinor();
			baseMem = MemoryUtil.heapInUse();
			trace('SongGc: collected, heap now ${Math.round(baseMem / 1048576)} MB');
			setSuspended(true);
			return;
		}
		setSuspended(shouldSuspend);
	}
}
