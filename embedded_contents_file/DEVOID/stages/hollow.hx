import openfl.display.BlendMode;
import flixel.tweens.FlxTween.FlxTweenType;

final bg:Array<BackgroundSprite> = [
	{path: 'hollow/sky', position: [-800, -500], scroll: [0.35, 0.35]},
	{path: 'hollow/cloud1', position: [-800, -500], scroll: [0.35, 0.35], backdrop: ['x', [50, 0]]},
	{path: 'hollow/cloud2', position: [-800, -500], scroll: [0.35, 0.35], backdrop: ['x', [50, 0]]},
	{path: 'hollow/city', position: [-400, -100], scroll: [0.7, 0.7]},
	{path: 'hollow/falsebot', position: [1600, 0], scale: [0.5, 0.5], isAtlas: true, animation: [{name: 'falseappear'}, {name: 'idle', looped: true}], alpha: 0.0001}
	{path: 'hollow/floor'},
	{path: 'hollow/fg', position: [300, 300], scroll: [1.2, 1.2], front: true}
];

function onCreate()
{
	makeBackground(bg);

	var overlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF060d94);
	overlay.alpha = 0.25;
	overlay.blend = BlendMode.MULTIPLY;
	overlay.camera = camVideo;
	add(overlay);
}

var _startSpawning:Bool = false;
function onEvent(n, v1)
{
	if (n == 'Dadbattle Spotlight')
	{
		if (!_startSpawning) _startSpawning = true;
		spawnBadnick();
	}
	if (n == 'Trigger BG Ghouls')
	{
		bg[4].sprite.animation.play('falseappear', true);
		bg[4].sprite.offset.set(0, 0);
		bg[4].sprite.alpha = 1;
		FlxTween.tween(bg[4].sprite, {y: bg[4].sprite.y + 20}, Conductor.crochet / 250, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
		bg[4].sprite.animation.onFinish.addOnce(function(_)
		{
			bg[4].sprite.animation.play('idle', true);
			bg[4].sprite.offset.set(-25, -199);
		});
	}
}

function onSectionHit()
{
	if (_startSpawning && FlxG.random.bool(25)) spawnBadnick();
}

function spawnBadnick()
{
	final t:Int = FlxG.random.int(0,3);
	final setupBadnick:Array<BackgroundSprite> = [{path: 'hollow/badnick', position: [500, 0], scale: [0.5, 0.5], scroll: [0.7, 0.7], isAtlas: true, animation: [{name: 'visorappear'}, {name: 'idlevisor', looped: true}, {name: 'murcielgao', looped: true}, {name: 'Símbolo 23', looped: true}, {name: 'abejorro', looped: true}], layer: (PlayState.instance.members.indexOf(bg[4].sprite))}];
	makeBackground(setupBadnick);
	var badnick:FlxSprite = setupBadnick[0].sprite;
	badnick.flipX = FlxG.random.bool();
	badnick.y = FlxG.random.int(50, 350);
	FlxTween.tween(badnick, {y: badnick.y + 20}, Conductor.crochet / 250, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
	badnick.x = (t == 0 || t == 3) ? (badnick.flipX ? (t == 3 ? 100 : -100) : (t == 3 ? 1700 : 2800)) : (badnick.flipX ? 2800 : -150);
	if (t < 3)
	{
		badnick.animation.play(['abejorro', 'Símbolo 23', 'murcielgao'][t], true);
		badnick.velocity.x = FlxG.random.int(100, 200) * (badnick.flipX ? -1 : 1) * (t == 0 ? -1 : 1);
	}
	else
	{
		badnick.animation.play('visorappear', true);
		badnick.offset.set(0, 0);
		badnick.animation.onFinish.addOnce(function(_)
		{
			badnick.animation.play('idlevisor', true);
			badnick.acceleration.x = FlxG.random.int(50, 100) * (badnick.flipX ? 1 : -1);
			if (badnick.flipX) badnick.offset.set(-218, -63);
			else badnick.offset.set(-25, -63);
		});
	}
}