package minigames.preymini.tiles;

import flixel.group.FlxGroup.FlxTypedGroup;
import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Spikes
{
	public var onHurt:Float->Void = null;

	public final art:FlxTypedGroup<FlxSprite>;

	final _blocks:Array<Rectangle> = [];

	public function new(terrain:Terrain, key:String)
	{
		final bmd = Paths.getBitmapData(Paths.getPath('images/$key.png', IMAGE));
		_findBlocks(bmd);
		for (b in _blocks) terrain.fill(Std.int(b.x), Std.int(b.y), Std.int(b.right), Std.int(b.bottom), Solid);
		art = terrain.addArt(bmd);
	}

	public function update(sonic:Sonic):Void
	{
		if (onHurt == null || sonic.dead || sonic.leaving || sonic.grabbed || sonic.hurting || sonic.invulnerable) return;
		if (!sonic.grounded || sonic.mode != 0) return;
		final foot = sonic.posY + sonic.hitRadiusY + 3;
		for (b in _blocks)
			if (foot >= b.y - 2 && foot <= b.y + 3 && sonic.posX + 9 >= b.x && sonic.posX - 9 < b.right)
			{
				onHurt(b.x + b.width / 2);
				return;
			}
	}

	function _findBlocks(bmd:BitmapData):Void
	{
		var cx = 0;
		while (cx < bmd.width)
		{
			final w = Std.int(Math.min(512, bmd.width - cx));
			final pixels = bmd.getVector(new Rectangle(cx, 0, w, bmd.height));
			for (lx in 0...w)
			{
				var y = 0;
				while (y < bmd.height)
				{
					if ((pixels[y * w + lx] >>> 24) & 0xFF < 128)
					{
						y++;
						continue;
					}
					final top = y;
					while (y < bmd.height && (pixels[y * w + lx] >>> 24) & 0xFF >= 128) y++;
					_addRun(cx + lx, top, y);
				}
			}
			cx += w;
		}
	}

	function _addRun(x:Int, top:Int, bottom:Int):Void
	{
		for (b in _blocks)
			if (x <= b.right + 12 && top <= b.bottom + 12 && bottom >= b.y - 12)
			{
				final right = Math.max(b.right, x + 1);
				final newTop = Math.min(b.y, top);
				final newBottom = Math.max(b.bottom, bottom);
				b.width = right - b.x;
				b.y = newTop;
				b.height = newBottom - newTop;
				return;
			}
		_blocks.push(new Rectangle(x, top, 1, bottom - top));
	}
}
