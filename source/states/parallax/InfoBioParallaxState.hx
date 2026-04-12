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
		grid.velocity.set(40, 40);
		add(grid);

		var spikestop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/spike.png'), X);
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.x = 60;
		spikestop.flipY = true;
		add(spikestop);

		var spikesbot:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/spike.png'), X);
		spikesbot.antialiasing = ClientPrefs.data.antialiasing;
		spikesbot.y = FlxG.height - spikesbot.height;
		spikesbot.velocity.x = -60;
		add(spikesbot);

		ringdown = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/ringdown.png'));
		ringdown.antialiasing = ClientPrefs.data.antialiasing;
		ringdown.scale.set(0.25, 0.25);
		ringdown.updateHitbox();
		ringdown.x = (FlxG.width - ringdown.width) + 100;
		add(ringdown);

		ring = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/ring.png'));
		ring.antialiasing = ClientPrefs.data.antialiasing;
		ring.scale.set(0.25, 0.25);
		ring.updateHitbox();
		ring.x = (FlxG.width - ring.width) + 100;
		add(ring);

		charBG = new FlxSprite(0, 0).makeGraphic(1, 1, 0x77000000);
		add(charBG);

		charName = new FlxText(40, 90, 0, '');
		charName.setFormat("assets/fonts/Plaza Regular.ttf", 100, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charName.borderSize = 2;
		charName.antialiasing = ClientPrefs.data.antialiasing;
		add(charName);

		charInfo = new FlxText(40, 200, 580, '');
		charInfo.setFormat("assets/fonts/Plaza Regular.ttf", 50, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charInfo.borderSize = 2;
		charInfo.antialiasing = ClientPrefs.data.antialiasing;
		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;
		add(charInfo);

		if (chars.length > 0)
			loadChar(0);
	}

	function loadCharData():Void
	{
		var basePath:String = 'assets/exe/parallax/info/';
		var folders:Array<String> = sys.FileSystem.readDirectory(basePath);

		for (folder in folders)
		{
			var folderPath:String = basePath + folder;
			if (!sys.FileSystem.isDirectory(folderPath)) continue;

			var jsonPath:String = folderPath + '/info-' + folder + '.json';
			if (!sys.FileSystem.exists(jsonPath)) continue;

			var json:Dynamic = haxe.Json.parse(sys.io.File.getContent(jsonPath));
			var renderArray:Array<RenderData> = [];

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
				name:   (json.name   != null) ? json.name   : 'Unknown',
				info:   (json.info   != null) ? json.info   : 'No info.',
				render: renderArray,
				order:  (json.order  != null) ? json.order  : 999,
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
			var spr:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/' + data.folder + '/' + renders.asset + '.png'));
			spr.antialiasing = ClientPrefs.data.antialiasing;
			spr.scale.set(0.25, 0.25);
			spr.updateHitbox();
			spr.setPosition(ring.x + renders.offset.x, ((FlxG.height - ring.height) / 2) + renders.offset.y);
			renderBasePos.push({x: spr.x, y: spr.y});
			charRenders.push(spr);
			if (renders.front) insert(members.indexOf(ring) + 1, spr);
			else insert(members.indexOf(ring), spr);
		}

		charName.text = data.name;
		charInfo.text = data.info;

		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
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

		if (!transitioning)
		{
			if (Controls.instance.BACK)
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

