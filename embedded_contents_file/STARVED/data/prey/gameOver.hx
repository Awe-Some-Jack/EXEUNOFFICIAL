import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import minigames.preymini.PreyMini;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.characterName = 'sonic-dead';
	GameOverSubstate.deathSoundName = 'prey-death';
	setVar('preyLives', PreyMini.songLives);
}

var backToMinigame:Bool = false;
function onGameOver()
{
	if (backToMinigame) return Function_Stop;
	if (PreyMini.songLives <= 0) return Function_Continue;
	PreyMini.songLives--;
	setVar('preyLives', PreyMini.songLives);
	if (PreyMini.songLives > 0) return Function_Continue;

	backToMinigame = true;
	final game = PlayState.instance;
	game.canPause = false;
	game.boyfriend.stunned = true;
	game.paused = true;
	if (FlxG.sound.music != null) FlxG.sound.music.pause();
	if (game.vocals != null) game.vocals.pause();
	if (game.opponentVocals != null) game.opponentVocals.pause();
	FlxG.sound.play(Paths.sound('minigame/preymini/death'));
	camOther.fade(0xFF000000, 0.8, false, () -> FlxG.switchState(() -> new PreyMini()));
	return Function_Stop;
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
	FlxTween.num(0, 1, 2, {ease: FlxEase.cubeInOut}, n -> {
		deadBoyfriend.setPosition(
			980 - (n * 50),
			430 - (n * 100)
		);
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
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}