package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class InfoBioParallaxState extends MusicBeatState
{
	override function create()
	{
		super.create();

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
				FlxG.switchState(() -> new ParallaxState());
				transitioning = true;
			}
		}
	}
}