import openfl.display.BlendMode;

var sombra2:FlxSprite;
function onCreatePost()
{
	PlayState.instance.boyfriend.alpha = 0;

	var bg:FlxSprite = new FlxSprite(-800, -500).loadGraphic(Paths.image('soullessbg/bg'));
	addBehindDad(bg);

	sombra2 = new FlxSprite(-550).loadGraphic(Paths.image('soullessbg/sombra2'));
	sombra2.scale.set(1.643, 1.643);
	sombra2.updateHitbox();
	sombra2.alpha = 0.8;
	add(sombra2);

	var sombra:FlxSprite = new FlxSprite(-550).loadGraphic(Paths.image('soullessbg/sombra'));
	sombra.scale.set(1.643, 1.643);
	sombra.updateHitbox();
	sombra.alpha = 0.8;
	sombra.blend = BlendMode.MULTIPLY;
	add(sombra);
}

function onEvent(n,v1)
{
	if (n == 'soullesEvent')
	{
		switch(v1)
		{
			case 'dark':
				FlxTween.tween(sombra2, {alpha: 0.7}, Conductor.crochet / (1000 / 2) / PlayState.instance.playbackRate, {ease: FlxEase.cubeOut});
			case 'light':
				FlxTween.tween(sombra2, {alpha: 0}, Conductor.crochet / (1000 / 2) / PlayState.instance.playbackRate, {ease: FlxEase.cubeOut});
		}
	}
}