package minigame.thevalley;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class TVNapeDebugDraw extends FlxSprite
{
	public function new(w:Int, h:Int)
	{
		super(0, 0);
		makeGraphic(w, h, FlxColor.TRANSPARENT);
		scrollFactor.set(1, 1);
	}

	public function redraw():Void
	{
		pixels.fillRect(pixels.rect, 0x00000000);

		if (FlxNapeSpace.space == null)
			return;

		for (body in FlxNapeSpace.space.bodies)
		{
			for (shape in body.shapes)
			{
				if (!shape.isPolygon())
					continue;

				var poly = shape.castPolygon;
				var verts = poly.worldVerts;

				if (verts.length < 2)
					continue;

				var prev = verts.at(verts.length - 1);

				for (i in 0...verts.length)
				{
					var cur = verts.at(i);

					drawLine(
						Std.int(prev.x),
						Std.int(prev.y),
						Std.int(cur.x),
						Std.int(cur.y),
						0xFFFF00FF
					);

					prev = cur;
				}
			}
		}

		dirty = true;
	}

	function drawLine(x0:Int, y0:Int, x1:Int, y1:Int, color:Int):Void
	{
		var dx = Math.abs(x1 - x0);
		var sx = x0 < x1 ? 1 : -1;
		var dy = -Math.abs(y1 - y0);
		var sy = y0 < y1 ? 1 : -1;
		var err = dx + dy;

		while (true)
		{
			if (x0 >= 0 && y0 >= 0 && x0 < pixels.width && y0 < pixels.height)
				pixels.setPixel32(x0, y0, color);

			if (x0 == x1 && y0 == y1)
				break;

			var e2 = 2 * err;

			if (e2 >= dy)
			{
				err += dy;
				x0 += sx;
			}

			if (e2 <= dx)
			{
				err += dx;
				y0 += sy;
			}
		}
	}
}