package states.extras.bios;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import objects.Character;

class BIOSCharacter
{
	public static function exists():Bool
		return FileSystem.exists('assets/exe/extras/bios/idle_atlas.png') && FileSystem.exists('assets/exe/extras/bios/idle_atlas.json');

	public static function generate(pairs:Array<{mod:String, charId:String}>):Void
	{
		final prevMod = Mods.currentModDirectory;

		final captured:Array<{key:String, bmp:BitmapData, offX:Float, offY:Float}> = [];

		for (p in pairs)
		{
			try
			{
				Mods.currentModDirectory = p.mod;
				final ch = new Character(0, 0, p.charId, false);
				ch.update(1 / 60);
				ch.update(1 / 60);
				ch.update(1 / 60);

				var animName:String = null;
				if (ch.danceIdle && ch.hasAnimation('danceLeft')) animName = 'danceLeft';
				else if (ch.hasAnimation('idle')) animName = 'idle';
				else if (ch.hasAnimation('danceLeft')) animName = 'danceLeft';

				if (animName != null) ch.playAnim(animName, true, false, 0);
				ch.updateFramePixels();

				final fp = ch.framePixels;
				if (fp != null && fp.width > 0 && fp.height > 0)
				{
					final owned = new BitmapData(fp.width, fp.height, true, 0x00000000);
					owned.copyPixels(fp, fp.rect, new Point(0, 0));
					captured.push({key: '${p.mod}|${p.charId}', bmp: owned, offX: ch.offset.x, offY: ch.offset.y});
				}

				ch.destroy();
				Paths.freeGraphicsFromMemory();
			}
			catch (e:Dynamic) {}
		}

		Mods.currentModDirectory = prevMod;

		if (captured.length == 0) return;

		captured.sort((a, b) -> Std.int(b.bmp.height) - Std.int(a.bmp.height));

		var totalArea:Float = 0;
		for (c in captured) totalArea += c.bmp.width * c.bmp.height;
		final targetWidth:Int = Std.int(Math.max(1024, Math.min(8192, Math.ceil(Math.sqrt(totalArea)))));

		var shelfX = 0, shelfY = 0, shelfH = 0;
		var atlasW = 0, atlasH = 0;
		final placements:Array<{c:{key:String, bmp:BitmapData, offX:Float, offY:Float}, x:Int, y:Int}> = [];

		for (c in captured)
		{
			if (shelfX + c.bmp.width > targetWidth && shelfX > 0)
			{
				shelfY += shelfH + 2;
				shelfX = 0;
				shelfH = 0;
			}
			placements.push({c: c, x: shelfX, y: shelfY});
			atlasW = Std.int(Math.max(atlasW, shelfX + c.bmp.width));
			shelfH = Std.int(Math.max(shelfH, c.bmp.height));
			shelfX += c.bmp.width + 2;
		}
		atlasH = shelfY + shelfH;

		final atlas = new BitmapData(atlasW, atlasH, true, 0x00000000);
		final manifest:Dynamic = {};

		for (pl in placements)
		{
			atlas.copyPixels(pl.c.bmp, pl.c.bmp.rect, new Point(pl.x, pl.y), null, null, true);
			Reflect.setField(manifest, pl.c.key, {
				x: pl.x, y: pl.y, w: pl.c.bmp.width, h: pl.c.bmp.height,
				offX: pl.c.offX, offY: pl.c.offY
			});
			pl.c.bmp.dispose();
		}

		final bytes = atlas.encode(atlas.rect, new PNGEncoderOptions());
		File.saveBytes('assets/exe/extras/bios/idle_atlas.png', bytes);
		File.saveContent('assets/exe/extras/bios/idle_atlas.json', Json.stringify(manifest, null, '\t'));
		atlas.dispose();
	}
}
