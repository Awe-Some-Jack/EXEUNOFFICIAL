package states;

import flixel.math.FlxMath;
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

	var curSelected:Int = 0;

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

		barstory = new FlxSprite(-80).loadGraphic(Assets.getBitmapData('assets/exe/parallax/tile.png'));
		barstory.antialiasing = ClientPrefs.data.antialiasing;
		barstory.y = (FlxG.height / 2) - barstory.height - 20;
		add(barstory);

		barinfo = new FlxSprite(-140).loadGraphic(Assets.getBitmapData('assets/exe/parallax/tile.png'));
		barinfo.antialiasing = ClientPrefs.data.antialiasing;
		barinfo.y = (FlxG.height / 2) + 20;
		add(barinfo);

		textstory = new FlxSprite(barstory.x + 140, barstory.y + 28).loadGraphic(Assets.getBitmapData('assets/exe/parallax/story.png'));
		textstory.antialiasing = ClientPrefs.data.antialiasing;
		add(textstory);

		textinfo = new FlxSprite(barinfo.x + 140, barinfo.y + 32).loadGraphic(Assets.getBitmapData('assets/exe/parallax/info-bio.png'));
		textinfo.antialiasing = ClientPrefs.data.antialiasing;
		add(textinfo);
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
				FlxG.switchState(() -> new Exetitle());
				transitioning = true;
			}

			if (controls.UI_UP_P)
				changeSelect(-1);
			else if (controls.UI_DOWN_P)
				changeSelect(1);
		}

		textstory.x = barstory.x + 140;
		textinfo.x = barinfo.x + 140;
	}

	function changeSelect(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		
		FlxTween.cancelTweensOf(barstory);
		FlxTween.cancelTweensOf(barinfo);

		FlxTween.tween(((curSelected == 0) ? barstory : barinfo), {x: -80}, 0.3, {ease: FlxEase.cubeOut});
		FlxTween.tween(((curSelected == 0) ? barinfo : barstory), {x: -140}, 0.3, {ease: FlxEase.cubeOut});
	}
}