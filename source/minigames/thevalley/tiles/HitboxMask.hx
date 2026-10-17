package minigames.thevalley.tiles;

enum abstract HitKind(Int) to Int
{
	var Solid    = 0;
	var Platform = 1;
	var Support  = 2;
	var Zone     = 3;
	var Art      = 4;
}

typedef HitRect = { x:Int, y:Int, w:Int, h:Int };

class HitboxMask
{
	static final _cache:Map<String, HitboxMask> = [];

	public final width:Int;
	public final height:Int;

	final _tops:Array<Array<Int>>;
	final _bounds:Array<HitRect>;

	public static function get(key:String):HitboxMask
	{
		var mask = _cache.get(key);
		if (mask == null)
		{
			mask = new HitboxMask(key);
			_cache.set(key, mask);
		}
		return mask;
	}

	function new(key:String)
	{
		final graphic = Paths.image(key, false);
		final bmd = graphic != null ? graphic.bitmap : null;

		width = bmd != null ? bmd.width : 0;
		height = bmd != null ? bmd.height : 0;
		_tops = [for (_ in 0...5) [for (_ in 0...width) -1]];
		_bounds = [for (_ in 0...5) null];
		if (bmd == null) return;

		final pixels = bmd.getVector(bmd.rect);
		final minX = [for (_ in 0...5) width], maxX = [for (_ in 0...5) -1];
		final minY = [for (_ in 0...5) height], maxY = [for (_ in 0...5) -1];

		function mark(k:Int, x:Int, y:Int)
		{
			if (_tops[k][x] < 0) _tops[k][x] = y;
			if (x < minX[k]) minX[k] = x;
			if (x > maxX[k]) maxX[k] = x;
			if (y < minY[k]) minY[k] = y;
			if (y > maxY[k]) maxY[k] = y;
		}

		for (i in 0...pixels.length)
		{
			final argb = pixels[i];
			final a = (argb >>> 24) & 0xFF;
			if (a < 30) continue;

			final x = i % width;
			final y = Std.int(i / width);
			final kind = _classify((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);
			if (kind >= 0) mark(kind, x, y);
			if (a >= 60) mark(Art, x, y);
		}

		for (k in 0...5)
			if (maxX[k] >= 0)
				_bounds[k] = { x: minX[k], y: minY[k], w: maxX[k] - minX[k] + 1, h: maxY[k] - minY[k] + 1 };
	}

	static inline function _classify(r:Int, g:Int, b:Int):Int
	{
		if (r > 200 && g < 60 && b < 60) return Solid;
		if (r < 60 && g > 180 && b < 60) return Platform;
		if (r < 60 && g < 60 && b > 150) return Support;
		if (r > 200 && g > 200 && b < 80) return Zone;
		return -1;
	}

	public inline function has(kind:HitKind):Bool return _bounds[kind] != null;

	public function bounds(kind:HitKind, ?fallback:HitRect):HitRect
	{
		final b = _bounds[kind];
		return b != null ? b : (fallback != null ? fallback : { x: 0, y: 0, w: width, h: height });
	}

	public inline function top(kind:HitKind, column:Int):Int
	{
		return column < 0 || column >= width ? -1 : _tops[kind][column];
	}
}
