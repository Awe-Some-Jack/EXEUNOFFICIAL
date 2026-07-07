
var grad:FlxSprite;
function onCreatePost()
{
	camGame.bgColor = 0xFFFFFFFF;

	grad = new FlxSprite().loadGraphic(Paths.image('grad'));
	grad.scale.set(3000, 1.5); grad.updateHitbox();
	grad.screenCenter();
	addBehindDad(grad);
}

function onSectionHit()
{
	FlxTween.cancelTweensOf(grad);
	grad.color = 0xFFFFB5F0;
	FlxTween.color(grad, 1, 0xFFFFB5F0, 0xFFFFFFFF, {ease: FlxEase.cubeOut});
}

function onDestroy()
{
	camGame.bgColor = 0x0;
}