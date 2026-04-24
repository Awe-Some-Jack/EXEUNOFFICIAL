package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import backend.GifDecoder;

class GifSprite extends FlxSprite
{
	var gifFrames:Array<BitmapData> = [];
	var gifDelays:Array<Float>      = [];
	var gifTimer:Float  = 0;
	var gifIndex:Int    = 0;
	var gifPlaying:Bool = false;
	var gifLoop:Bool    = true;
	var gifWidth:Int    = 0;
	var gifHeight:Int   = 0;

	static var _zero:Point = new Point(0, 0);

	public var gifFrameCount(get, never):Int;
	inline function get_gifFrameCount():Int return gifFrames.length;

	public var onComplete:Void->Void;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
	}

	public function loadGif(path:String, loop:Bool = true):GifSprite
	{
		var decoder = GifDecoder.fromFile(path);
		if (decoder == null || decoder.frames.length == 0)
		{
			trace('GifSprite: Failed to load GIF: $path');
			return this;
		}
		return loadGifFromDecoder(decoder, loop);
	}

	public function loadGifFromDecoder(decoder:GifDecoder, loop:Bool = true):GifSprite
	{
		_clearFrames();

		gifDelays  = [];
		gifIndex   = 0;
		gifTimer   = 0;
		gifLoop    = loop;
		gifWidth   = decoder.width;
		gifHeight  = decoder.height;

		for (i in 0...decoder.frames.length)
		{
			var frame = decoder.frames[i];

			var bmd = new BitmapData(gifWidth, gifHeight, true, 0x00000000);
			bmd.copyPixels(frame.bitmapData, frame.bitmapData.rect, _zero);
			gifFrames.push(bmd);

			var delay = frame.delay / 100.0;
			gifDelays.push(delay > 0.0 ? delay : 0.1);
		}

		if (gifFrames.length > 0)
		{
			makeGraphic(gifWidth, gifHeight, 0x00000000);
			_blitFrame(0);
			gifPlaying = true;
		}

		return this;
	}

	// ── Playback controls ───────────────────────────────────────────────────

	public function playGif():Void
	{
		gifIndex   = 0;
		gifTimer   = 0;
		gifPlaying = true;
	}

	public function stopGif():Void
	{
		gifPlaying = false;
		gifIndex   = 0;
		gifTimer   = 0;
	}

	public function pauseGif():Void  gifPlaying = false;
	public function resumeGif():Void gifPlaying = true;

	// ── Update ──────────────────────────────────────────────────────────────

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!gifPlaying || gifFrames.length <= 1)
			return;

		gifTimer += elapsed;

		var advanced = false;
		while (gifTimer >= gifDelays[gifIndex])
		{
			gifTimer -= gifDelays[gifIndex];
			gifIndex++;

			if (gifIndex >= gifFrames.length)
			{
				if (gifLoop)
				{
					gifIndex = 0;
				}
				else
				{
					gifIndex   = gifFrames.length - 1;
					gifPlaying = false;
					advanced   = true;
					if (onComplete != null) onComplete();
					break;
				}
			}
			advanced = true;
		}

		if (advanced)
			_blitFrame(gifIndex);
	}

	// ── Internal helpers ────────────────────────────────────────────────────

	inline function _blitFrame(index:Int):Void
	{
		if (pixels == null || gifFrames[index] == null) return;
		pixels.fillRect(pixels.rect, 0x00000000);
		pixels.copyPixels(gifFrames[index], gifFrames[index].rect, _zero);
		dirty = true;
	}

	function _clearFrames():Void
	{
		if (gifFrames == null) return;
		for (bmd in gifFrames)
			if (bmd != null) bmd.dispose();
		gifFrames = [];
	}

	override public function destroy():Void
	{
		_clearFrames();
		gifDelays  = null;
		onComplete = null;
		super.destroy();
	}
}
