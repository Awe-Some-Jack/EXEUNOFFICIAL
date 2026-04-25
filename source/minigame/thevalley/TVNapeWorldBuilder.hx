package minigame.thevalley;

import flixel.addons.nape.FlxNapeSpace;
import openfl.display.BitmapData;

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

	public static function buildFromBitmap(bmd:BitmapData):Void
	{
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

                var cutTop = 0;

                while (cutTop < h)
                {
                    var hasSurfaceNear = false;

                    for (dx in 0...w)
                    {
                        var px = x + dx;
                        var py = y + cutTop;

                        for (oy in -4...5)
                        {
                            var sy = py + oy;

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

        for (x in 0...bw)
        {
            var foundY = -1;
            for (y in 0...bh)
            {
                if (pixelType(bmd, x, y) == SURFACE)
                {
                    if ((y == 0 || pixelType(bmd, x, y - 1) == EMPTY) && hasSupportBelow(bmd, x, y))
                    {
                        foundY = y;
                        break;
                    }
                }
            }

            if (foundY != -1)
            {
                if (points.length > 0)
                {
                    var last = points[points.length - 1];

                    if (Math.abs(foundY - last.y) > 16)
                    {
                        if (points.length > 1)
                            flushSurface(points);
                        else
                            for (p in points) p.dispose();

                        points = [];
                    }
                }

                points.push(Vec2.get(x, foundY));
            }
            else
            {
                if (points.length > 1)
                {
                    flushSurface(points);
                    points = [];
                }
            }
        }

        if (points.length > 1)
            flushSurface(points);
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

        var start = points[0];
        var last = points[1];

        var lastDX = sign(points[1].x - points[0].x);
        var lastDY = sign(points[1].y - points[0].y);

        for (i in 2...points.length)
        {
            var p = points[i];

            var dx = sign(p.x - last.x);
            var dy = sign(p.y - last.y);

            if (dx != lastDX || dy != lastDY)
            {
                addSegmentPoly(start.x, start.y, last.x, last.y, 2);
                start = last;
                lastDX = dx;
                lastDY = dy;
            }

            last = p;
        }

        addSegmentPoly(start.x, start.y, last.x, last.y, 2);

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