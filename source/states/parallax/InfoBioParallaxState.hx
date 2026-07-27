package states.parallax;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

typedef RenderData = {
	var asset:String;
	var offset:{x:Float, y:Float};
	var front:Bool;
}

typedef CharData = {
	var name:String;
	var info:String;
	var render:Array<RenderData>;
	var order:Int;
	var folder:String;
}

class InfoBioParallaxState extends MusicBeatState
{
	var ringdown:FlxSprite;
	var charRenders:Array<FlxSprite> = [];
	var ring:FlxSprite;

	var charBG:FlxSprite;
	var charName:FlxText;
	var charInfo:FlxText;

	var chars:Array<CharData> = [];
	var currentIndex:Int = 0;

	override function create()
	{
		super.create();

		loadCharData();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFDE3F3F, 0xFF92454C));
		grid.antialiasing = false;
		grid.velocity.set(40, 40);
		add(grid);

		var spikestop:FlxBackdrop = new FlxBackdrop(Paths.getBitmapData('assets/exe/parallax/spike.webp'), X);
		spikestop.velocity.x = 60;
		spikestop.flipY = true;
		add(spikestop);

		var spikesbot:FlxBackdrop = new FlxBackdrop(Paths.getBitmapData('assets/exe/parallax/spike.webp'), X);
		spikesbot.y = FlxG.height - spikesbot.height;
		spikesbot.velocity.x = -60;
		add(spikesbot);

		ringdown = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/info/ringdown.webp'));
		ringdown.scale.set(0.25, 0.25);
		ringdown.updateHitbox();
		ringdown.x = (FlxG.width - ringdown.width) + 100;
		add(ringdown);

		ring = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/info/ring.webp'));
		ring.scale.set(0.25, 0.25);
		ring.updateHitbox();
		ring.x = (FlxG.width - ring.width) + 100;
		add(ring);

		charBG = new FlxSprite(0, 0).makeGraphic(1, 1, 0x77000000);
		add(charBG);

		charName = new FlxText(40, 90, 0, '');
		charName.setFormat(Paths.font("Plaza Regular.ttf"), 100, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charName.borderSize = 2;
		charName.antialiasing = ClientPrefs.data.antialiasing;
		add(charName);

		charInfo = new FlxText(40, 200, 580, '');
		charInfo.setFormat(Paths.font("Plaza Regular.ttf"), 50, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charInfo.borderSize = 2;
		charInfo.antialiasing = ClientPrefs.data.antialiasing;

		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;
		add(charInfo);

		if (chars.length > 0)
			loadChar(0);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Parallax Menus", 'Checking Info Bios');
		#end
	}

	function loadCharData():Void
	{
		var basePath:String = 'assets/exe/parallax/info/';
		var folders:Array<String> = Paths.readDirectory(basePath);

		for (folder in folders)
		{
			if (folder.contains('.')) continue; 

			var jsonPath:String = basePath + folder + '/info-' + folder + '.json';
			var jsonContent:String = Paths.getTextFromFile(jsonPath, true);

			if (jsonContent == null) continue;

			var json:Dynamic = haxe.Json.parse(jsonContent);
			var renderArray:Array<RenderData> = [];

			if (json.render != null)
			{
				var rawRender:Array<Dynamic> = cast json.render;
				for (r in rawRender)
				{
					renderArray.push({
						asset: r[0],
						offset: {
							x: r[1][0],
							y: r[1][1]
						},
						front: r[2] == true
					});
				}
			}
			else
			{
				renderArray.push({
					asset: folder,
					offset: {x: 0, y: 0},
					front: false
				});
			}

			chars.push({
				name:   json.name ?? 'Unknown',
				info:   json.info ?? 'No info.',
				render: renderArray,
				order:  json.order ?? 999,
				folder: folder
			});
		}

		chars.sort((a, b) -> a.order - b.order);
	}

	var renderBasePos:Array<{x:Float, y:Float}> = [];
	function loadChar(index:Int):Void
	{
		currentIndex = index;
		var data:CharData = chars[index];

		for (spr in charRenders)
			remove(spr);

		charRenders = [];
		renderBasePos = [];

		for (renders in data.render)
		{
			final basePath = 'assets/exe/parallax/info/' + data.folder + '/' + renders.asset;
			final bitmap = Paths.getBitmapData(basePath);

			if (bitmap != null)
			{
				final spr:FlxSprite = new FlxSprite();
				spr.loadGraphic(bitmap);
				spr.scale.set(0.25, 0.25);
				spr.updateHitbox();
				spr.setPosition(ring.x + renders.offset.x, ((FlxG.height - ring.height) / 2) + renders.offset.y);

				renderBasePos.push({x: spr.x, y: spr.y});
				charRenders.push(spr);

				final targetIndex = members.indexOf(ring);
				insert(renders.front ? targetIndex + 1 : targetIndex, spr);
			}
			else
			{
				trace('Render asset not found: $basePath');
			}
		}

		charName.text = data.name;
		charInfo.text = data.info;

		final fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;

		charBG.setPosition(charInfo.x - 10, charInfo.y - 10);
		charBG.makeGraphic(Std.int(charInfo.width + 20), Std.int(charInfo.height + 20), 0x77000000);
	}

	var characterSine:Float = 0;
	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (subState != null) return;

		if (!transitioning)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new states.parallax.ParallaxState());
			}

			if (chars.length > 1)
			{
				if (controls.UI_LEFT_P)
					loadChar(FlxMath.wrap(currentIndex - 1, 0, chars.length - 1));
				if (controls.UI_RIGHT_P)
					loadChar(FlxMath.wrap(currentIndex + 1, 0, chars.length - 1));
			}
		}

		characterSine += elapsed;

		for (i in 0...charRenders.length) { charRenders[i].y = renderBasePos[i].y + Math.sin(characterSine) * 10; }
		ringdown.y = ((FlxG.height - ringdown.height) / 2) + (Math.sin(characterSine - 0.2) * 10);
		ring.y = ((FlxG.height - ring.height) / 2) + (Math.sin(characterSine - 0.2) * 10);
	}
}

