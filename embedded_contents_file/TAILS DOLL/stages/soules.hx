import openfl.display.BlendMode;

var bg:FlxSprite;
var sombra2:FlxSprite;
function onCreatePost()
{
	PlayState.instance.boyfriend.alpha = 0;

	bg = new FlxSprite(-800, -500).loadGraphic(Paths.image('soullessbg/bgclean'));
	bg.scrollFactor.set(0.6, 0.6);
	addBehindDad(bg);

	sombra2 = new FlxSprite(-600).loadGraphic(Paths.image('soullessbg/sombra2'));
	sombra2.scale.set(1.643, 1.643);
	sombra2.updateHitbox();
	sombra2.alpha = 1;
	add(sombra2);

	var sombra:FlxSprite = new FlxSprite(-600).loadGraphic(Paths.image('soullessbg/sombra'));
	sombra.scale.set(1.643, 1.643);
	sombra.updateHitbox();
	sombra.alpha = 0.8;
	sombra.blend = BlendMode.MULTIPLY;
	add(sombra);
}

function onEvent(n,v1,v2)
{
	if (n == 'soullesEvents')
	{
		var duration:Int = v2 == '' ? 2 : Std.int(v2);
		switch(v1)
		{
			case 'dark':
				FlxTween.tween(sombra2, {alpha: 0.8}, Conductor.crochet / (1000 / duration) / PlayState.instance.playbackRate, {ease: FlxEase.cubeOut});
			case 'light':
				FlxTween.tween(sombra2, {alpha: 0}, Conductor.crochet / (1000 / duration) / PlayState.instance.playbackRate, {ease: FlxEase.cubeOut});
			case 'newbg':
				bg.loadGraphic(Paths.image('soullessbg/bg'));
		}
	}
}

function opponentNoteHitPre(note)
{
	switch(note.noteData)
	{
		case 1:
			game.triggerEvent('Set Character Offset', 'dad', '200', Conductor.songPosition);
		case 2:
			game.triggerEvent('Set Character Offset', 'dad', '100', Conductor.songPosition);
		default:
			game.triggerEvent('Set Character Offset', 'dad', '50', Conductor.songPosition);
	}
}