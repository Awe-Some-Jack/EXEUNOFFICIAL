package states;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import objects.GifSprite;
import flixel.addons.display.FlxBackdrop;
import states.Exetitle;
import openfl.Assets;

import states.InfoBioParallaxState;

class ParallaxState extends MusicBeatState
{
	var barstory:FlxSprite;
	var barinfo:FlxSprite;
	var textstory:FlxSprite;
	var textinfo:FlxSprite;
	var sonic:FlxSprite;
	var whiteBG:FlxSprite;

	var spikestop:FlxBackdrop;
	var spikesbot:FlxBackdrop;

	public static var curSelected:Int = 0;

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

		spikestop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/spike.png'), X);
		spikestop.updateHitbox();
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.x = 50;
		spikestop.flipY = true;
		add(spikestop);

		spikesbot = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/spike.png'), X);
		spikesbot.updateHitbox();
		spikesbot.antialiasing = ClientPrefs.data.antialiasing;
		spikesbot.y = FlxG.height - spikesbot.height;
		spikesbot.velocity.x = -50;
		add(spikesbot);

		barstory = new FlxSprite(((curSelected == 0) ? -80 : -140)).loadGraphic(Assets.getBitmapData('assets/exe/parallax/tile.png'));
		barstory.antialiasing = ClientPrefs.data.antialiasing;
		barstory.y = (FlxG.height / 2) - barstory.height - 20;
		add(barstory);

		barinfo = new FlxSprite(((curSelected == 0) ? -140 : -80)).loadGraphic(Assets.getBitmapData('assets/exe/parallax/tile.png'));
		barinfo.antialiasing = ClientPrefs.data.antialiasing;
		barinfo.y = (FlxG.height / 2) + 20;
		add(barinfo);

		textstory = new FlxSprite(barstory.x + 140, barstory.y + 28).loadGraphic(Assets.getBitmapData('assets/exe/parallax/story.png'));
		textstory.antialiasing = ClientPrefs.data.antialiasing;
		add(textstory);

		textinfo = new FlxSprite(barinfo.x + 140, barinfo.y + 32).loadGraphic(Assets.getBitmapData('assets/exe/parallax/info-bio.png'));
		textinfo.antialiasing = ClientPrefs.data.antialiasing;
		add(textinfo);

		sonic = new FlxSprite();
		sonic.frames = FlxAtlasFrames.fromSparrow('assets/exe/parallax/satanos.png', 'assets/exe/parallax/satanos.xml');
		sonic.animation.addByPrefix('idle', 'Símbolo 27 instancia 1', 24, true);
		sonic.animation.addByPrefix('selected', 'satanos instancia 1', 24, false);
		sonic.animation.play('idle');
		sonic.updateHitbox();
		sonic.x = (FlxG.width * 0.715) - (sonic.width / 2);
		sonic.screenCenter(Y);
		sonic.antialiasing = ClientPrefs.data.antialiasing;
		add(sonic);

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		whiteBG.alpha = 0;
		whiteBG.screenCenter();
		add(whiteBG);
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

			if (Controls.instance.ACCEPT)
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				sonic.animation.play('selected');
				sonic.offset.set(sonic.offset.x, sonic.offset.y + 40);

				spikesbot.acceleration.x = -1000;
				spikestop.acceleration.x = 1000;

				FlxTween.cancelTweensOf(barstory);
				FlxTween.cancelTweensOf(barinfo);

				FlxTween.tween(barstory, {x: -240}, 1.2, {ease: FlxEase.cubeOut});
				FlxTween.tween(barinfo, {x: -240}, 1.2, {ease: FlxEase.cubeOut});

				FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.6, {ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween){
					FlxTween.tween(FlxG.camera, {zoom: 2}, 0.75, {ease: FlxEase.expoIn});
					FlxTween.tween(whiteBG, {alpha: 1}, 0.6);
				}});

				if (curSelected == 0) FlxG.sound.play(Paths.sound('storyparalax'));

				new FlxTimer().start(1.4, function(tmr:FlxTimer){
					if (curSelected == 0) MusicBeatState.switchState(new StoryParallaxState());
					else MusicBeatState.switchState(new InfoBioParallaxState());
				});
			}
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