package states.extras.bios;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import objects.Character;

#if (mobile && flixel_animate)
import animate.internal.FilterRenderer;
import flixel.math.FlxMatrix;
#end

class BIOSCharacter
{
	public static inline function atlasPng():String
		return atlasDir() + 'idle_atlas.png';

	public static inline function atlasJson():String
		return atlasDir() + 'idle_atlas.json';

	public static inline function atlasKeys():String
		return atlasDir() + 'idle_atlas.keys';

	static final ATLAS_VERSION:Int = 2;

	public static function keysOf(pairs:Array<{mod:String, charId:String}>):String
	{
		final keys = [for (p in pairs) '${p.mod}|${p.charId}'];
		keys.sort((a, b) -> a < b ? -1 : (a > b ? 1 : 0));
		final appVersion:String = lime.app.Application.current?.meta?.get('version') ?? '';
		return 'v$ATLAS_VERSION|$appVersion\n' + keys.join('\n');
	}

	public static function captureOne(mod:String, charId:String):{key:String, bmp:BitmapData, offX:Float, offY:Float}
	{
		final prevGPU:Bool = ClientPrefs.data.cacheOnGPU;
		ClientPrefs.data.cacheOnGPU = false;
		Paths.tempFramesCache.clear();
		Paths.freeGraphicsFromMemory();

		var result:{key:String, bmp:BitmapData, offX:Float, offY:Float} = null;
		var ch:Character = null;
		try
		{
			Mods.currentModDirectory = mod;
			ch = new Character(0, 0, charId, false);
			if (!ch.missingCharacter)
			{
				ch.update(1 / 60);
				ch.update(1 / 60);
				ch.update(1 / 60);

				var animName:String = null;
				if (ch.danceIdle && ch.hasAnimation('danceLeft')) animName = 'danceLeft';
				else if (ch.hasAnimation('idle')) animName = 'idle';
				else if (ch.hasAnimation('danceLeft')) animName = 'danceLeft';

				if (animName != null) ch.playAnim(animName, true, false, 0);
				final fp = capture(ch);
				if (fp != null && fp.width > 0 && fp.height > 0 && !isBlank(fp))
				{
					final owned = new BitmapData(fp.width, fp.height, true, 0x00000000);
					owned.copyPixels(fp, fp.rect, new Point(0, 0));
					result = {key: '$mod|$charId', bmp: owned, offX: ch.offset.x, offY: ch.offset.y};
				}
			}
		}
		catch (e:Dynamic)
		{
			trace('BIOS: failed to capture $mod|$charId: $e');
		}

		ch?.destroy();
		Paths.tempFramesCache.clear();
		Paths.freeGraphicsFromMemory();
		ClientPrefs.data.cacheOnGPU = prevGPU;
		return result;
	}

	public static function upToDate(pairs:Array<{mod:String, charId:String}>):Bool
		return exists() && FileSystem.exists(atlasKeys()) && File.getContent(atlasKeys()) == keysOf(pairs);

	static function atlasDir():String
	{
		#if mobile
		return MobileUtil.getAssetDirectory() + 'assets/exe/extras/bios/';
		#elseif desktop
		final dir:String = haxe.io.Path.addTrailingSlash(lime.system.System.applicationStorageDirectory) + 'bios/';
		if (!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
		return dir;
		#else
		return 'assets/exe/extras/bios/';
		#end
	}

	public static function capture(ch:Character):BitmapData
	{
		ch.updateFramePixels();
		final fp = ch.framePixels;

		#if (mobile && flixel_animate)
		if (!ch.isAnimateAtlas && ch.frame != null && (fp == null || fp.width <= 0 || fp.height <= 0 || isBlank(fp)))
		{
			final gpu = renderFrame(ch);
			if (gpu != null) return gpu;
		}
		#end

		return fp;
	}

	static function isBlank(bmp:BitmapData):Bool
		return bmp.getColorBoundsRect(0xFF000000, 0x00000000, false).width == 0;

	#if (mobile && flixel_animate)
	@:access(animate.internal.FilterRenderer)
	@:access(flixel.FlxCamera)
	@:access(openfl.display.Graphics)
	static function renderFrame(ch:Character):BitmapData
	{
		final fr = ch.frame;
		final w:Float = Math.ceil(fr.sourceSize.x);
		final h:Float = Math.ceil(fr.sourceSize.y);

		return FilterRenderer.renderToBitmap((cam:flixel.FlxCamera, mat:FlxMatrix) ->
		{
			fr.prepareMatrix(mat);
			cam.drawPixels(fr, null, mat, null, NORMAL, false, null);
			cam.render();
			if (cam.canvas.graphics.__bounds != null)
				cam.canvas.graphics.__bounds.setTo(0, 0, w, h);
		});
	}
	#end

	public static function exists():Bool
		return FileSystem.exists(atlasPng()) && FileSystem.exists(atlasJson());

	public static function generate(pairs:Array<{mod:String, charId:String}>):Void
	{
		final prevMod = Mods.currentModDirectory;

		final captured:Array<{key:String, bmp:BitmapData, offX:Float, offY:Float}> = [];

		for (p in pairs)
		{
			final c = captureOne(p.mod, p.charId);
			if (c != null) captured.push(c);
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
		File.saveBytes(atlasPng(), bytes);
		File.saveContent(atlasJson(), Json.stringify(manifest, null, '\t'));
		File.saveContent(atlasKeys(), keysOf(pairs));
		atlas.dispose();
	}
}
