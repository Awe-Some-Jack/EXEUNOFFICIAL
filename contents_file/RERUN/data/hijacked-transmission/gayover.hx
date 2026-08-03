import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var gameoverIdle:FlxSprite;
var blackfuck:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'die';
}

function onGameOverStart()
{
	inGameOver = true;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('spookysounds'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.screenCenter();
	deadBoyfriend.scrollFactor.set();
	
	// blackfuck = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	// blackfuck.scrollFactor.set();
	// blackfuck.screenCenter();
	// GameOverSubstate.instance.add(blackfuck);
	// FlxTween.tween(blackfuck, {alpha: 0}, 3, {ease: FlxEase.smootherStepInOut});

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 3;

	FlxG.sound.music.volume = 0;
	deadMusic.fadeIn(3, 0, 1);
	deadMusic.play();
}

function onUpdatePost()
{
	if (!inGameOver) return;

	// if(deadBoyfriend != null) deadBoyfriend.alpha = 0;

	if(deadBoyfriend.animation.curAnim.curFrame >= 34)
		deadBoyfriend.active = false;
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.sound.play(Paths.sound('rety'));
		deadMusic.stop();
	}
}