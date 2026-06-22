import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import openfl.system.System;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var daGameOver:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.visible = false;

	daGameOver = new FlxSprite();
	daGameOver.frames = Paths.getSparrowAtlas('characters/black');
	daGameOver.animation.addByPrefix('intro', 'a', 24, false);
	daGameOver.animation.addByPrefix('loop', 'scremer', 24, false);
	daGameOver.animation.play('intro');
	daGameOver.screenCenter();
	daGameOver.scrollFactor.set();
	GameOverSubstate.instance.add(daGameOver);
	daGameOver.alpha = 0;
	daGameOver.scale.set(0.95, 0.95);
	FlxTween.tween(daGameOver, {alpha: 1}, 5); FlxTween.tween(daGameOver.scale, {x: 1, y: 1}, 5, {ease: FlxEase.cubeOut});

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;
}

var toggleOnce:Bool = false;
var triggerOnce:Bool = false;
var timer:Float = 10;
function onUpdate(elapsed:Float)
{
	if (!inGameOver) return;

	if (deadBoyfriend.animation.curAnim.name == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			FlxG.sound.music.volume = 0;
		}
	}

	if (timer > 0) timer -= elapsed;
	if (timer < 0) {
		timer = 0;
		daGameOver.animation.play('loop');
		GameOverSubstate.instance.canRestart = false;
		FlxG.sound.play(Paths.sound('scream'));
	}

	if (daGameOver.animation.curAnim.name == 'loop' && daGameOver.animation.curAnim.finished) System.exit(0);
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing) sound.volume = 0;
	}
	daGameOver.destroy();
}