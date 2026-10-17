package minigames.thevalley.map;

import flixel.FlxSprite;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
#if lime
import lime.graphics.PixelFormat;
#end

class AlphaMask
{
	static final _cache:Map<String, AlphaMask> = [];

	public final width:Int;
	public final height:Int;

	final _stride:Int;
	final _bits:Bytes;

	public static function of(spr:FlxSprite):Null<AlphaMask>
	{
		final g = spr != null ? spr.graphic : null;
		if (g == null || g.bitmap == null || spr.numFrames > 1) return null;
		if (g.key == null) return g.bitmap.image != null ? new AlphaMask(g.bitmap) : null;

		var mask = _cache.get(g.key);
		if (mask == null)
		{
			final fresh = g.bitmap.image == null ? Paths.getBitmapData(g.key) : null;
			mask = new AlphaMask(fresh ?? g.bitmap);
			fresh?.dispose();
			_cache.set(g.key, mask);
		}
		return mask;
	}

	function new(bmd:BitmapData)
	{
		width = bmd.width;
		height = bmd.height;
		_stride = (width + 7) >> 3;
		_bits = Bytes.alloc(_stride * height);
		_bits.fill(0, _bits.length, 0);
		if (!_readImage(bmd)) _readPixels(bmd);
	}

	public inline function opaque(x:Int, y:Int):Bool
	{
		return x >= 0 && y >= 0 && x < width && y < height && (_bits.get(y * _stride + (x >> 3)) & (1 << (x & 7))) != 0;
	}

	public inline function opaqueAt(spr:FlxSprite, wx:Float, wy:Float):Bool
	{
		return opaque(Math.floor(wx - spr.x), Math.floor(wy - spr.y));
	}

	inline function _set(x:Int, y:Int):Void
	{
		final i = y * _stride + (x >> 3);
		_bits.set(i, _bits.get(i) | (1 << (x & 7)));
	}

	function _readImage(bmd:BitmapData):Bool
	{
		#if lime
		final img = bmd.image;
		if (img == null || img.buffer == null || img.buffer.data == null || img.buffer.bitsPerPixel != 32) return false;

		final buf = img.buffer;
		final data = buf.data;
		final rowBytes = buf.stride;
		final alpha = buf.format == PixelFormat.ARGB32 ? 0 : 3;
		for (y in 0...height)
		{
			var i = (y + img.offsetY) * rowBytes + img.offsetX * 4 + alpha;
			for (x in 0...width)
			{
				if (data[i] > 30) _set(x, y);
				i += 4;
			}
		}
		return true;
		#else
		return false;
		#end
	}

	function _readPixels(bmd:BitmapData):Void
	{
		if (!bmd.readable) return;

		final rect = new Rectangle();
		var y0 = 0;
		while (y0 < height)
		{
			final rows = height - y0 < 64 ? height - y0 : 64;
			rect.setTo(0, y0, width, rows);
			final pixels = bmd.getVector(rect);
			for (i in 0...pixels.length)
			{
				final argb = pixels[i];
				if (((argb >>> 24) & 0xFF) > 30) _set(i % width, y0 + Std.int(i / width));
			}
			y0 += rows;
		}
	}
}
