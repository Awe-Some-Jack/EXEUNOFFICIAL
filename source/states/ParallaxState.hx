package states;

import objects.GifSprite;
import flixel.addons.display.FlxBackdrop;
import states.Exetitle;
import openfl.Assets;

class ParallaxState extends MusicBeatState
{
	var barstory:FlxSprite;
	var barinfo:FlxSprite;
	var textstory:FlxSprite;
	var textinfo:FlxSprite;

	var curSelected:Int;

	override function create()
	{
		super.create();

		var paraBg:GifSprite = new GifSprite();
		paraBg.loadGif('assets/exe/parallax/bg.gif');
		paraBg.antialiasing = ClientPrefs.data.antialiasing;
		paraBg.setGraphicSize(FlxG.width, FlxG.height);
		paraBg.updateHitbox();
		paraBg.screenCenter();
		add(paraBg);

		var spikestop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/blackspikes.png'), X);
		spikestop.updateHitbox();
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.x = 50;
		spikestop.flipY = true;
		add(spikestop);

		var spikesbot:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/blackspikes.png'), X);
		spikesbot.updateHitbox();
		spikesbot.antialiasing = ClientPrefs.data.antialiasing;
		spikesbot.y = FlxG.height - spikesbot.height;
		spikesbot.velocity.x = -50;
		add(spikesbot);

		barstory = new FlxSprite(-100).loadGraphic(Assets.getBitmapData('assets/exe/parallax/tile.png'));
		barstory.antialiasing = ClientPrefs.data.antialiasing;
		barstory.y = (FlxG.height / 2) - barstory.height - 20;
		add(barstory);

		barinfo = new FlxSprite(-100).loadGraphic(Assets.getBitmapData('assets/exe/parallax/tile.png'));
		barinfo.antialiasing = ClientPrefs.data.antialiasing;
		barinfo.y = (FlxG.height / 2) + 20;
		add(barinfo);

		textstory = new FlxSprite(barstory.x + 120, barstory.y + 28).loadGraphic(Assets.getBitmapData('assets/exe/parallax/story.png'));
		textstory.antialiasing = ClientPrefs.data.antialiasing;
		add(textstory);

		textinfo = new FlxSprite(barinfo.x + 120, barinfo.y + 28).loadGraphic(Assets.getBitmapData('assets/exe/parallax/info-bio.png'));
		textinfo.antialiasing = ClientPrefs.data.antialiasing;
		add(textinfo);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.instance.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new Exetitle());
			return;
		}
	}
}