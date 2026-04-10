package states.parallax;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

typedef CharData = {
	var name:String;
	var info:String;
	var render:String;
	var order:Int;
	var folder:String;
}

class InfoBioParallaxState extends MusicBeatState
{
	var ringdown:FlxSprite;
	var charRender:FlxSprite;
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
		add(ringdown);

		charRender = new FlxSprite();
		charRender.antialiasing = ClientPrefs.data.antialiasing;
		add(charRender);

		ring = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/ring.png'));
		ring.antialiasing = ClientPrefs.data.antialiasing;
		ring.scale.set(0.25, 0.25);
		ring.updateHitbox();
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
			chars.push({
				name:   (json.name   != null) ? json.name   : 'Unknown',
				info:   (json.info   != null) ? json.info   : 'No info.',
				render: (json.render != null) ? json.render : folder,
				order:  (json.order  != null) ? json.order  : 999,
				folder: folder
			});
		}

		chars.sort((a, b) -> a.order - b.order);
	}

	function loadChar(index:Int):Void
	{
		currentIndex = index;
		var data:CharData = chars[index];

		var renderPath:String = 'assets/exe/parallax/info/' + data.folder + '/' + data.render + '.png';
		charRender.loadGraphic(Assets.getBitmapData(renderPath));
		charRender.scale.set(0.25, 0.25);
		charRender.updateHitbox();

		charName.text = data.name;
		charInfo.text = data.info;

		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;

		charBG.setPosition(charInfo.x - 10, charInfo.y - 10);
		charBG.makeGraphic(Std.int(charInfo.width + 20), Std.int(charInfo.height + 20), 0x77000000);
	}

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
	}

}

