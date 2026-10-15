package minigames.preymini.map;

import openfl.display.BitmapData;

class SongFloors
{
	static final _ramps:Map<Int, Array<Array<Int>>> = [];
	static final _clear:Map<Int, Array<Array<Int>>> = [];
	static var _count:Int = -1;

	public static function count():Int
	{
		if (_count < 0)
		{
			_count = 0;
			while (Paths.fileExists('images/prey/floor-variants/${_count + 1}/floor1.webp', IMAGE)) _count++;
		}
		return _count;
	}

	public static function ramps(id:Int):Array<Array<Int>>
	{
		_analyze(id);
		return _ramps.get(id);
	}

	public static function clear(id:Int):Array<Array<Int>>
	{
		_analyze(id);
		return _clear.get(id);
	}

	public static function levelAt(id:Int, tex:Float, margin:Float):Float
	{
		var level:Float = 0;
		for (ramp in ramps(id))
		{
			if (tex < ramp[0] - margin) return level;
			if (tex < ramp[0] + 142 + margin) return Math.NaN;
			level = ramp[2];
		}
		return level;
	}

	static function _analyze(id:Int):Void
	{
		if (_ramps.exists(id)) return;

		final front = _load(id, "floor1");
		final back = _load(id, "floor2");
		if (front == null || back == null)
		{
			front?.dispose();
			back?.dispose();
			_ramps.set(id, []);
			_clear.set(id, []);
			return;
		}

		final width = front.width;
		final frontPx = front.getVector(front.rect);
		final backPx = back.getVector(back.rect);
		final backWidth = back.width;
		front.dispose();
		back.dispose();

		inline function frontAt(x:Int, y:Int):Bool return (frontPx[y * width + x] >>> 24) & 0xFF > 0;
		inline function backAt(x:Int, y:Int):Bool return x < backWidth && (backPx[y * backWidth + x] >>> 24) & 0xFF > 0;

		final rails = [for (row in [480, 416, 352]) [for (x in 0...width) {
			var solid = true;
			for (k in 0...6) if (!frontAt(x, row + k) && !backAt(x, row + k)) { solid = false; break; }
			solid;
		}]];
		inline function rail(level:Int, x:Int):Bool return rails[level + 1][x];

		final events:Array<Array<Int>> = [];
		var level = 0;
		var x = 0;
		while (x < width)
		{
			if (rail(level, x))
			{
				x++;
				continue;
			}

			final gone = x;
			var foundX = -1;
			var foundLevel = 0;
			var scan = gone;
			while (foundX < 0 && scan < Std.int(Math.min(width, gone + 260)))
			{
				for (next in [1, 0, -1])
				{
					if (next == level || scan + 40 > width) continue;
					var stable = true;
					for (k in 0...40) if (!rail(next, scan + k) || rail(level, scan + k)) { stable = false; break; }
					if (stable)
					{
						foundX = scan;
						foundLevel = next;
						break;
					}
				}
				scan++;
			}

			if (foundX < 0)
			{
				x++;
				continue;
			}
			events.push([foundLevel > level ? foundX - 141 : gone, level, foundLevel]);
			level = foundLevel;
			x = foundX;
		}
		_ramps.set(id, events);

		final ranges:Array<Array<Int>> = [];
		var start = -1;
		for (cx in 0...width + 1)
		{
			var good = false;
			if (cx < width)
			{
				final at = levelAt(id, cx, 24);
				if (!Math.isNaN(at))
				{
					final surface = 416 - 64 * Std.int(at);
					var covered = false;
					for (y in surface - 32...surface) if (frontAt(cx, y)) { covered = true; break; }
					good = !covered && (frontAt(cx, surface) || backAt(cx, surface));
				}
			}
			if (good && start < 0) start = cx;
			else if (!good && start >= 0)
			{
				if (cx - start >= 8) ranges.push([start, cx]);
				start = -1;
			}
		}
		_clear.set(id, ranges);
	}

	static function _load(id:Int, name:String):BitmapData
	{
		return Paths.getBitmapData(Paths.getPath('images/prey/floor-variants/$id/$name.webp', IMAGE));
	}
}
