package minigame.thevalley;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class TVHitboxMap
{
	public var solidTiles:FlxTypedGroup<FlxSprite>;
	public var platformTiles:FlxTypedGroup<FlxSprite>;
	public var launchpads:FlxTypedGroup<FlxSprite>;

	public function new()
	{
		solidTiles    = new FlxTypedGroup<FlxSprite>();
		platformTiles = new FlxTypedGroup<FlxSprite>();
		launchpads    = new FlxTypedGroup<FlxSprite>();
	}

	public function loadFromBitmap(bmd:BitmapData):Void
	{
		var bw = bmd.width;
		var bh = bmd.height;

		var raw    = bmd.getVector(bmd.rect);
		var grid   = new haxe.ds.Vector<Int>(bw * bh);
		for (i in 0...raw.length)
			grid[i] = _colorToType(raw[i]);

		var done = new haxe.ds.Vector<Bool>(bw * bh);
		for (i in 0...done.length) done[i] = false;

		for (row in 0...bh)
		{
			var col = 0;
			while (col < bw)
			{
				var idx = row * bw + col;
				if (done[idx] || grid[idx] == 0) { col++; continue; }

				var type = grid[idx];

				var runW = 0;
				var c    = col;
				while (c < bw && !done[row * bw + c] && grid[row * bw + c] == type)
				{ runW++; c++; }

				var runH = 1;
				var r    = row + 1;
				var keepGoing = true;
				while (r < bh && keepGoing)
				{
					for (dc in 0...runW)
					{
						var ni = r * bw + (col + dc);
						if (done[ni] || grid[ni] != type) { keepGoing = false; break; }
					}
					if (keepGoing) { runH++; r++; }
				}

				for (dr in 0...runH)
					for (dc in 0...runW)
						done[(row + dr) * bw + (col + dc)] = true;

				_addTile(col, row, runW, runH, type);
				col += runW;
			}
		}
	}

	function _addTile(x:Int, y:Int, w:Int, h:Int, type:Int):Void
	{
		var tile = new FlxSprite(x, y);
		tile.makeGraphic(w, h, FlxColor.TRANSPARENT);
		tile.immovable = true;
		tile.moves     = false;

		if (type == TVSlopeMap.T_SOLID)
		{
			tile.allowCollisions = flixel.util.FlxDirectionFlags.ANY;
			solidTiles.add(tile);
		}
		else if (type == TVSlopeMap.T_PLATFORM || type == TVSlopeMap.T_NARROW_SLOPE)
		{
			tile.allowCollisions = flixel.util.FlxDirectionFlags.UP;
			platformTiles.add(tile);
		}
		else if (type == TVSlopeMap.T_LAUNCHPAD)
		{
			tile.allowCollisions = flixel.util.FlxDirectionFlags.UP;
			launchpads.add(tile);
		}
	}

	inline function _colorToType(argb:Int):Int
	{
		if (((argb >> 24) & 0xFF) == 0) return 0;
		return switch (argb & 0x00FFFFFF)
		{
			case 0xFF0000 | 0x010000 | 0xFF00F5 | 0xFFFE00: TVSlopeMap.T_SOLID;
			case 0x00FF03 | 0x00F101 | 0x00FFEF:            TVSlopeMap.T_PLATFORM;
			case 0xFF8F00:                                   TVSlopeMap.T_NARROW_SLOPE;
			case 0x000FFF | 0x0001FD:                        TVSlopeMap.T_LAUNCHPAD;
			default: 0;
		};
	}
}
