package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class InfoBioParallaxState extends MusicBeatState
{
	var ringdown:FlxSprite;
	var educator:FlxSprite;
	var ring:FlxSprite;

	var charBG:FlxSprite;
	var charName:FlxText;
	var charInfo:FlxText;

	var name:String = 'Null';
	var info:String = 'No Info added.';

	override function create()
	{
		super.create();

		var json:Dynamic = haxe.Json.parse(sys.io.File.getContent('assets/exe/parallax/info/educator/info-educator.json'));
		if (json.name != null && json.name.length > 0) name = json.name;
		if (json.info != null && json.info.length > 0) info = json.info;

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFDE3F3F , 0xFF92454C));
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

		educator = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/educator/educator.png'));
		educator.antialiasing = ClientPrefs.data.antialiasing;
		educator.scale.set(0.25, 0.25);
		educator.updateHitbox();
		add(educator);

		ring = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/ring.png'));
		ring.antialiasing = ClientPrefs.data.antialiasing;
		ring.scale.set(0.25, 0.25);
		ring.updateHitbox();
		add(ring);

		charName = new FlxText(40, 90, 0, name);
		charName.setFormat("assets/fonts/Plaza Regular.ttf", 100, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charName.borderSize = 2;
		charName.antialiasing = ClientPrefs.data.antialiasing;

		charInfo = new FlxText(40, 200, 580, info);
		charInfo.setFormat("assets/fonts/Plaza Regular.ttf", 50, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charInfo.borderSize = 2;
		charInfo.antialiasing = ClientPrefs.data.antialiasing;
		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;

		charBG = new FlxSprite(charInfo.x - 10, charInfo.y - 10).makeGraphic(Std.int(charInfo.width + 20), Std.int(charInfo.height + 20), 0x77000000);

		add(charBG);
		add(charName);
		add(charInfo);
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
				FlxG.switchState(() -> new ParallaxState());
				transitioning = true;
			}
		}

		characterSine += elapsed;
		educator.setPosition((FlxG.width * 0.7) - (educator.width / 2), ((FlxG.height - educator.height) / 2) + (Math.sin(characterSine) * 10) - 40);
		ringdown.setPosition(educator.x - (1032 * 0.25), (((FlxG.height - educator.height) / 2) - (358 * 0.25)) + (Math.sin(characterSine - 0.2) * 10) - 40);
		ring.setPosition(educator.x - (1032 * 0.25), (((FlxG.height - educator.height) / 2) - (358 * 0.25)) + (Math.sin(characterSine - 0.2) * 10) - 40);
	}
}