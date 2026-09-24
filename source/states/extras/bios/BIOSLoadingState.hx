package states.extras.bios;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Point;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class BIOSLoadingState extends SonicSubState
{
	public var progressBar:FlxSprite;
	public var loadingTxt:FlxText;

	var isDone:Bool = false;
	var simulatedProgress:Float = 0;
	var fillSpeed:Float = 1.25;

	var pairsToProcess:Array<{mod:String, charId:String}> = [];
	var captured:Array<{key:String, bmp:BitmapData, offX:Float, offY:Float}> = [];
	var totalPairs:Int = 0;
	var currentIndex:Int = 0;
	var isGeneratingByFrames:Bool = false;
	var prevMod:String = "";

	public function new()
	{
		super();
	}

	override function create():Void
	{
		super.create();

        FlxG.autoPause = false;

		isDone = false;

		final bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		add(bg);

		var logo:FlxSprite = new FlxSprite();
		logo.frames = FlxAtlasFrames.fromSparrow('assets/exe/ring.jxl', 'assets/exe/ring.xml');
		logo.animation.addByPrefix('idle', 'idle', 60, true);
		logo.animation.play('idle', true);
		logo.scale.set(0.35, 0.35);
		logo.updateHitbox();

		logo.setPosition(FlxG.width - logo.width - 35, FlxG.height - logo.height - 35);
		add(logo);

		final maxBarWidth:Int = Std.int(FlxG.width * 0.8);
		final barHeight:Int = 40;

		progressBar = new FlxSprite();
		progressBar.makeGraphic(maxBarWidth, barHeight, FlxColor.WHITE);
		progressBar.setPosition(50, FlxG.height - 90);

		progressBar.scale.x = 0;
		progressBar.origin.x = 0;

		add(progressBar);

		loadingTxt = new FlxText(50, progressBar.y - 50, 0, 'Loading...', 40);
		loadingTxt.setFormat(Paths.font("visitor1.ttf"), 40, FlxColor.WHITE, LEFT);
		add(loadingTxt);

		if (BIOSCharacter.exists())
		{
			isDone = true;
		}
		else
		{
			var tempBios = new BIOS();
			@:privateAccess
			tempBios.loadEntries();

			pairsToProcess = Reflect.callMethod(tempBios, Reflect.field(tempBios, "_collectModCharPairs"), []);
			totalPairs = pairsToProcess.length;

			if (totalPairs > 0)
			{
				prevMod = Mods.currentModDirectory;
				currentIndex = 0;
				
				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
					isGeneratingByFrames = true;
				});
			}
			else
			{
				isDone = true;
			}
		}
	}

	var uuh:Bool = false;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (isGeneratingByFrames)
		{
			if (currentIndex < totalPairs)
			{
				var p = pairsToProcess[currentIndex];
				try
				{
					Mods.currentModDirectory = p.mod;
					final ch = new objects.Character(0, 0, p.charId, false);
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

				currentIndex++;
				
				simulatedProgress = currentIndex / totalPairs;
			}
			else
			{
				finalizeAtlas();
				isGeneratingByFrames = false;
				isDone = true;
			}
		}
		else if (isDone)
		{
			simulatedProgress += elapsed * fillSpeed;
		}

		progressBar.scale.x = flixel.math.FlxMath.bound(simulatedProgress, 0, 1);

		if (!uuh && (simulatedProgress >= 1.0 || (isDone && (1.0 - simulatedProgress < 0.01))))
		{
            FlxG.autoPause = true;
			loadingTxt.text = "Done!";
			new FlxTimer().start(1, tmr -> {
				SonicRetroTransition.openSubState(new BIOS(), 0.5, function() {
				});
			});
			uuh = true;
		}
	}

	function finalizeAtlas():Void
	{
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