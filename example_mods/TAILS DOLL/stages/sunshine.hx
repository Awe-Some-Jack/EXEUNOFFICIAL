import openfl.display.BlendMode;

function onCreatePost()
{
	var floor:FlxSprite = new FlxSprite(-400, -150).loadGraphic(Paths.image('bg/new_floor'));
	addBehindDad(floor);

	var spotlight:FlxSprite = new FlxSprite(-400, -450).loadGraphic(Paths.image('bg/spotlight'));
	spotlight.scale.y = 1.3;
	spotlight.updateHitbox();
	spotlight.alpha = 0.5;
	spotlight.blend = BlendMode.SCREEN;
	add(spotlight);

	PlayState.instance.uiPostfix = '-lq';
}