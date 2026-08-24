package states;

class SonichuUnlockState extends MusicBeatState
{
	override function create()
	{
		super.create();
	}

	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (transitioning) return;

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			transitioning = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}
	}
}