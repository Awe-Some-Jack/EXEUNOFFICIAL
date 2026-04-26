package minigame.thevalley;

import flixel.addons.nape.FlxNapeSpace;
import openfl.display.BitmapData;

import nape.callbacks.CbType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;

class TVNapeWorldBuilder
{
	static inline final EMPTY:Int = 0;
	static inline final SOLID:Int = 1;
	static inline final SURFACE:Int = 2;
    static inline final WALL:Int = 3;
    static inline final SURFACE_STEP:Int = 4;

    static inline final MAX_SURFACE_STEP:Int = 32;
    static inline final MIN_SURFACE_POINTS:Int = 2;

    public static final SURFACE_CB:CbType = new CbType();

	public static function buildFromBitmap(bmd:BitmapData):Void
	{
		buildWallRects(bmd);
        buildSolidRects(bmd);
        buildSurfaceSegments(bmd);
	}

	static function buildSolidRects(bmd:BitmapData):Void
	{
		var bw = bmd.width;
		var bh = bmd.height;

		var done = new haxe.ds.Vector<Bool>(bw * bh);

		for (y in 0...bh)
		{
			var x = 0;

			while (x < bw)
			{
				var idx = y * bw + x;

				if (done[idx] || pixelType(bmd, x, y) != SOLID)
				{
					x++;
					continue;
				}

				var w = 0;
				while (x + w < bw && !done[y * bw + x + w] && pixelType(bmd, x + w, y) == SOLID)
					w++;

				var h = 1;
				var keep = true;

				while (y + h < bh && keep)
				{
					for (dx in 0...w)
					{
						var ni = (y + h) * bw + x + dx;

						if (done[ni] || pixelType(bmd, x + dx, y + h) != SOLID)
						{
							keep = false;
							break;
						}
					}

					if (keep)
						h++;
				}

				for (dy in 0...h)
                    for (dx in 0...w)
                        done[(y + dy) * bw + x + dx] = true;

                var isYellowSolid:Bool = false;
                for (dy in 0...h)
                {
                    for (dx in 0...w)
                    {
                        if ((bmd.getPixel32(x + dx, y + dy) & 0x00FFFFFF) == TVSlopeMap.C_SOLID_D)
                        {
                            isYellowSolid = true;
                            break;
                        }
                    }

                    if (isYellowSolid)
                        break;
                }

                var cutTop = 0;
                if (!isYellowSolid)
                {
                    while (cutTop < h)
                    {
                        var hasSurfaceNear:Bool = false;
                        for (dx in 0...w)
                        {
                            final px = x + dx;
                            final py = y + cutTop;

                            for (oy in -4...5)
                            {
                                final sy = py + oy;
                                if (sy >= 0 && sy < bh && pixelType(bmd, px, sy) == SURFACE)
                                {
                                    hasSurfaceNear = true;
                                    break;
                                }
                            }

                            if (hasSurfaceNear)
                                break;
                        }

                        if (!hasSurfaceNear)
                            break;

                        cutTop++;
                    }
                }

                var boxY = y + cutTop;
                var boxH = h - cutTop;

                if (boxH > 0)
                    addStaticBox(x, boxY, w, boxH, new Material(0, 0.25, 0.6, 1, 0));

                x += w;
			}
		}
	}

	static function buildSurfaceSegments(bmd:BitmapData):Void
    {
        var bw = bmd.width;
        var bh = bmd.height;

        var points:Array<Vec2> = [];
        var prevY:Int = -1;

        for (x in 0...bw)
        {
            var columnPoints:Array<Int> = [];

            for (y in 0...bh)
            {
                if (pixelType(bmd, x, y) != SURFACE)
                    continue;

                if (y > 0 && pixelType(bmd, x, y - 1) == SURFACE)
                    continue;

                columnPoints.push(y);
            }

            var chosenY = -1;
            for (cy in columnPoints)
            {
                if (prevY == -1 || Math.abs(cy - prevY) <= MAX_SURFACE_STEP)
                {
                    chosenY = cy;
                    break;
                }
            }

            if (chosenY == -1)
            {
                if (points.length >= MIN_SURFACE_POINTS)
                    flushSurface(points);
                else
                    for (p in points) p.dispose();

                points = [];
                prevY = -1;
                continue;
            }

            points.push(Vec2.get(x, chosenY));
            prevY = chosenY;
        }

        if (points.length >= MIN_SURFACE_POINTS)
            flushSurface(points);
        else
            for (p in points) p.dispose();
    }

    static function buildWallRects(bmd:BitmapData):Void
    {
        var bw = bmd.width;
        var bh = bmd.height;
        var done = new haxe.ds.Vector<Bool>(bw * bh);

        for (y in 0...bh)
        {
            var x = 0;

            while (x < bw)
            {
                var idx = y * bw + x;

                if (done[idx] || pixelType(bmd, x, y) != WALL)
                {
                    x++;
                    continue;
                }

                var w = 0;
                while (x + w < bw && !done[y * bw + x + w] && pixelType(bmd, x + w, y) == WALL)
                    w++;

                var h = 1;
                var keep = true;

                while (y + h < bh && keep)
                {
                    for (dx in 0...w)
                    {
                        var ni = (y + h) * bw + x + dx;

                        if (done[ni] || pixelType(bmd, x + dx, y + h) != WALL)
                        {
                            keep = false;
                            break;
                        }
                    }

                    if (keep)
                        h++;
                }

                for (dy in 0...h)
                    for (dx in 0...w)
                        done[(y + dy) * bw + x + dx] = true;

                addStaticBox(x, y, w, h, new Material(0, 0.0, 0.0, 1, 0));

                x += w;
            }
        }
    }

    static function hasSupportBelow(bmd:BitmapData, x:Int, y:Int):Bool
    {
        var bh = bmd.height;

        for (dy in 1...24)
        {
            var yy = y + dy;
            if (yy >= bh) return false;

            var t = pixelType(bmd, x, yy);

            if (t == SOLID || t == SURFACE)
                return true;
        }

        return false;
    }

	static function flushSurface(points:Array<Vec2>):Void
    {
        if (points.length < 2)
            return;

        var i = 0;

        while (i < points.length - 1)
        {
            var a = points[i];
            var endIndex = Std.int(Math.min(i + SURFACE_STEP, points.length - 1));
            var b = points[endIndex];

            var dx = b.x - a.x;
            var dy = b.y - a.y;

            if (Math.abs(dx) >= 1)
            {
                var slope = Math.abs(dy / dx);

                if (slope <= 4)
                    addSegmentPoly(a.x, a.y, b.x, b.y, 1.5);
                else
                    addStaticBox(Math.min(a.x, b.x) - 2, Math.min(a.y, b.y), 4, Math.abs(dy), new Material(0, 0.0, 0.0, 1, 0));
            }

            i = endIndex;
        }

        for (p in points)
            p.dispose();
    }

    static inline function sign(v:Float):Int
    {
        return v > 0 ? 1 : (v < 0 ? -1 : 0);
    }

    static function addSegmentPoly(x1:Float, y1:Float, x2:Float, y2:Float, thickness:Float):Void
    {
        var dx = x2 - x1;
        var dy = y2 - y1;
        var len = Math.sqrt(dx * dx + dy * dy);

        if (len < 2)
            return;

        var nx = -dy / len;
        var ny = dx / len;

        var hx = dx * 0.5;
        var hy = dy * 0.5;

        var tx = nx * thickness * 0.5;
        var ty = ny * thickness * 0.5;

        var body = new Body(BodyType.STATIC);
        body.position.setxy((x1 + x2) * 0.5, (y1 + y2) * 0.5);

        var verts = [
            Vec2.get(-hx - tx, -hy - ty),
            Vec2.get( hx - tx,  hy - ty),
            Vec2.get( hx + tx,  hy + ty),
            Vec2.get(-hx + tx, -hy + ty)
        ];

        var poly = new Polygon(verts);
        poly.material = new Material(0, 0.0, 0.0, 1, 0);
        poly.cbTypes.add(SURFACE_CB);

        body.shapes.add(poly);
        body.space = FlxNapeSpace.space;

        for (v in verts)
            v.dispose();
    }

	static function addStaticBox(x:Float, y:Float, w:Float, h:Float, material:Material):Void
	{
		if (w <= 0 || h <= 0)
			return;

		var body = new Body(BodyType.STATIC);
		body.position.setxy(x + w * 0.5, y + h * 0.5);

		var poly = new Polygon(Polygon.box(w, h));
		poly.material = material;

		body.shapes.add(poly);
		body.space = FlxNapeSpace.space;
	}

	static inline function pixelType(bmd:BitmapData, x:Int, y:Int):Int
	{
		var argb = bmd.getPixel32(x, y);

		if (((argb >> 24) & 0xFF) == 0)
			return EMPTY;

		var rgb = argb & 0x00FFFFFF;

		return switch (rgb)
        {
            case TVSlopeMap.C_SOLID_A | TVSlopeMap.C_SOLID_B:
                SOLID;

            case TVSlopeMap.C_SOLID_C
                | TVSlopeMap.C_SOLID_D
                | TVSlopeMap.C_PLAT_A
                | TVSlopeMap.C_PLAT_B
                | TVSlopeMap.C_PLAT_C
                | TVSlopeMap.C_NARROW:
                SURFACE;

            default:
                EMPTY;
        };
	}
}