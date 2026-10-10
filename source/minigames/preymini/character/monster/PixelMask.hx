package minigames.preymini.character.monster;

import haxe.io.Bytes;

class PixelMask
{
	final _masks:Array<Bytes> = [];
	final _w:Int;
	final _h:Int;

	public function new(sprite:FlxSprite, anim:String)
	{
		_w = sprite.frameWidth;
		_h = sprite.frameHeight;
		final bitmap = sprite.frames.parent.bitmap;
		for (index in sprite.animation.getByName(anim).frames)
		{
			final frame = sprite.frames.frames[index];
			final mask = Bytes.alloc(_w * _h);
			final fx = Std.int(frame.frame.x), fy = Std.int(frame.frame.y);
			final ox = Std.int(frame.offset.x), oy = Std.int(frame.offset.y);
			for (y in 0...Std.int(frame.frame.height))
				for (x in 0...Std.int(frame.frame.width))
				{
					final cx = ox + x, cy = oy + y;
					if (cx < _w && cy < _h && (bitmap.getPixel32(fx + x, fy + y) >>> 24) & 0xFF >= 128) mask.set(cy * _w + cx, 1);
				}
			_masks.push(mask);
		}
	}

	public function touches(frame:Int, x:Float, y:Float, flipX:Bool, cx:Float, cy:Float, rx:Float, ry:Float):Bool
	{
		final mask = _masks[frame % _masks.length];
		final x0 = Std.int(Math.max(0, Math.floor(cx - rx - x))), x1 = Std.int(Math.min(_w, Math.ceil(cx + rx - x)));
		final y0 = Std.int(Math.max(0, Math.floor(cy - ry - y))), y1 = Std.int(Math.min(_h, Math.ceil(cy + ry - y)));
		for (py in y0...y1)
			for (px in x0...x1)
				if (mask.get(py * _w + (flipX ? _w - 1 - px : px)) == 1) return true;
		return false;
	}
}
