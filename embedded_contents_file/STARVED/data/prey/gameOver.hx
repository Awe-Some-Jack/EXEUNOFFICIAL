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
	if (PreyMini.songLives <= 0) return;
	for (part in ['game', 'over']) Paths.image('minigame/preymini/hud/gameover/' + part);
	for (sound in ['death', 'gameover']) Paths.sound('minigame/preymini/' + sound);
}

var backToMinigame:Bool = false;
var deathFall:Bool = false;
var gameOverShown:Bool = false;
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

	setVar('preyDead', true);
	setVar('isJumping', true);
	game.callOnLuas('freezeHazards', []);
	game.callOnHScript('freezeStage', []);
	FlxTween.tween(game.camHUD, {alpha: 0}, 0.4);

	final bf = game.boyfriend;
	bf.alpha = 1;
	bf.playAnim('death', true);
	bf.specialAnim = true;
	bf.acceleration.set(0, 4725);
	bf.velocity.set(0, -2520);
	FlxG.sound.play(Paths.sound('minigame/preymini/death'));
	deathFall = true;
	return Function_Stop;
}

function showGameOver()
{
	gameOverShown = true;
	final top = Math.round(FlxG.height / 3 / 2 - 8) * 3;
	final gameX = Math.round((FlxG.width / 3 - 140) / 2) * 3;
	final gameText = makeGameOverPart('game', top);
	final overText = makeGameOverPart('over', top);
	gameText.x = -gameText.width;
	overText.x = FlxG.width;
	FlxTween.tween(gameText, {x: gameX}, 0.5);
	FlxTween.tween(overText, {x: gameX + 79 * 3}, 0.5);
	FlxG.sound.play(Paths.sound('minigame/preymini/gameover'), 1, false, null, true, () -> camOther.fade(0xFF000000, 1, false, () -> FlxG.switchState(() -> new PreyMini())));
}

function makeGameOverPart(name:String, top:Float):FlxSprite
{
	final part = new FlxSprite(0, top).loadGraphic(Paths.image('minigame/preymini/hud/gameover/' + name));
	part.antialiasing = false;
	part.scale.set(3, 3);
	part.updateHitbox();
	part.cameras = [camOther];
	add(part);
	return part;
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
	if (deathFall && !gameOverShown && PlayState.instance.boyfriend.y > camGame.viewBottom + 150) showGameOver();
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