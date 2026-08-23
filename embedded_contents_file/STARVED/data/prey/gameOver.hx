import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.characterName = 'sonic-dead';
	GameOverSubstate.deathSoundName = 'prey-death';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(980, 430);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.5;
	FlxTween.tween(FlxG.camera, {zoom: 1.2}, 2, {ease: FlxEase.cubeInOut});
	FlxTween.num(1, 0, 3, {ease: FlxEase.cubeInOut}, n -> {
		FlxG.camera.targetOffset.x = n * 100;
		FlxG.camera.targetOffset.y = n * 100;
		FlxG.camera.snapToTarget();
	});

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverPrey'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (deadBoyfriend.getAnimationName() == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			FlxG.sound.music.volume = 0;
		}
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.sound.play(Paths.music('gameOverPreyEnd'));
		deadMusic.stop();
	}
}