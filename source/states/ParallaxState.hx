package states;

import objects.GifSprite;
import states.Exetitle;

class ParallaxState extends MusicBeatState
{
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