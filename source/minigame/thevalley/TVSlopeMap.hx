package minigame.thevalley;

import openfl.display.BitmapData;

class TVSlopeMap
{
	var pixels:openfl.Vector<UInt>;
	public var width:Int  = 0;
	public var height:Int = 0;

	public static inline final T_EMPTY:Int        = 0;
	public static inline final T_SOLID:Int        = 1;
	public static inline final T_PLATFORM:Int     = 2;
	public static inline final T_NARROW_SLOPE:Int = 3;
	public static inline final T_LAUNCHPAD:Int    = 4;

	public static inline final C_SOLID_A:Int    = 0xFF0000;
	public static inline final C_SOLID_B:Int    = 0x010000;
	public static inline final C_SOLID_C:Int    = 0xFF00F5;
	public static inline final C_SOLID_D:Int    = 0xFFFE00;
	public static inline final C_PLAT_A:Int     = 0x01FF03;
	public static inline final C_PLAT_B:Int     = 0x00F101;
	public static inline final C_PLAT_C:Int     = 0x00FFEF;
	public static inline final C_NARROW:Int     = 0xFF8F00;
	public static inline final C_LAUNCH_A:Int   = 0x000FFF;
	public static inline final C_LAUNCH_B:Int   = 0x0001FD;

	public function new() {}

	public function loadFromBitmap(bmd:BitmapData):Void
	{
		width  = bmd.width;
		height = bmd.height;
		pixels = bmd.getVector(bmd.rect);
	}

	public inline function typeAt(x:Int, y:Int):Int
	{
		if (x < 0 || x >= width || y < 0 || y >= height) return T_EMPTY;
		var px  = pixels[y * width + x];
		if (((px >> 24) & 0xFF) == 0) return T_EMPTY;
		var rgb = px & 0x00FFFFFF;
		return switch (rgb) {
			case C_SOLID_A | C_SOLID_B | C_SOLID_C | C_SOLID_D: T_SOLID;
			case C_PLAT_A  | C_PLAT_B  | C_PLAT_C:              T_PLATFORM;
			case C_NARROW:                                        T_NARROW_SLOPE;
			case C_LAUNCH_A | C_LAUNCH_B:                        T_LAUNCHPAD;
			default: T_EMPTY;
		};
	}

	public inline function isSolidAt(x:Int, y:Int):Bool
	{
		var t = typeAt(x, y);
		return t == T_SOLID || t == T_PLATFORM || t == T_NARROW_SLOPE;
	}

	public inline function isHardSolidAt(x:Int, y:Int):Bool
		return typeAt(x, y) == T_SOLID;

	public inline function isNarrowSlopeAt(x:Int, y:Int):Bool
		return typeAt(x, y) == T_NARROW_SLOPE;

	public static inline final MISS_DIST:Int = 0x7FFF;
	public static inline final SCAN_UP:Int   = 6;
	public static inline final WALL_SCAN:Int = 3;

	public function findFloor(px:Int, footY:Int, scanDown:Int, outAngle:Array<Float>):Int
	{
		if (px < 0 || px >= width) { outAngle[0] = 0; return MISS_DIST; }

		var startY = footY - SCAN_UP;
		var endY   = footY + scanDown;
		if (endY >= height) endY = height - 1;

		var y = startY;
		while (y <= endY)
		{
			if (y >= 0 && isSolidAt(px, y))
			{
				outAngle[0] = _slopeAngleAt(px, y);
				return y - footY;
			}
			y++;
		}
		outAngle[0] = 0;
		return MISS_DIST;
	}

	public function findWallRight(wallX:Int, midY:Int):Int
	{
		if (wallX < 0) return MISS_DIST;
		var x = wallX;
		var end = wallX + WALL_SCAN;
		if (end >= width) end = width - 1;
		while (x <= end)
		{
			if (isHardSolidAt(x, midY))
				return x - wallX + 1;
			x++;
		}
		return MISS_DIST;
	}

	public function findWallLeft(wallX:Int, midY:Int):Int
	{
		if (wallX >= width) return MISS_DIST;
		var x = wallX;
		var end = wallX - WALL_SCAN;
		if (end < 0) end = 0;
		while (x >= end)
		{
			if (isHardSolidAt(x, midY))
				return wallX - x + 1;
			x--;
		}
		return MISS_DIST;
	}

	public static inline function s1ToDeg(s1:Float):Float
		return (s1 / 256.0) * 360.0;

	public static inline function s1ToRad(s1:Float):Float
		return (s1 / 256.0) * (Math.PI * 2.0);

	public static inline function degToS1(deg:Float):Float
		return (deg / 360.0) * 256.0;

	function _slopeAngleAt(px:Int, py:Int):Float
	{
		var half = 8;
		var lx = px - half; if (lx < 0) lx = 0;
		var rx = px + half; if (rx >= width) rx = width - 1;

		var ly = _surfaceYAt(lx, py);
		var ry = _surfaceYAt(rx, py);

		var dx = (rx - lx);
		if (dx == 0) return 0;
		var deg = Math.atan2(ry - ly, dx) * (180.0 / Math.PI);
		return degToS1(deg);
	}

	function _surfaceYAt(x:Int, refY:Int):Int
	{
		var search = 12;
		var y = refY - search;
		if (y < 0) y = 0;
		var end = refY + search;
		if (end >= height) end = height - 1;
		while (y <= end)
		{
			if (isSolidAt(x, y)) return y;
			y++;
		}
		return refY;
	}

}
