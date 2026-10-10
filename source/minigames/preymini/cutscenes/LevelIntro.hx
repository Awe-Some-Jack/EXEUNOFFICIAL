package minigames.preymini.cutscenes;

class LevelIntro extends FlxSprite
{
	public var onFade:Void->Void = null;
	public var onDone:Void->Void = null;

	var _time:Float = 0;

	public function new(cam:FlxCamera)
	{
		super();
		makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		scrollFactor.set(0, 0);
		cameras = [cam];
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		final before = _time;
		_time += elapsed;
		if (before < 1.0 && _time >= 1.0 && onFade != null) onFade();

		final t = Math.min(Math.max((_time - 1.0) / 0.35, 0), 1);
		alpha = 1 - Math.floor(t * 7) / 7;
		if (t >= 1)
		{
			if (onDone != null) onDone();
			kill();
		}
	}
}
