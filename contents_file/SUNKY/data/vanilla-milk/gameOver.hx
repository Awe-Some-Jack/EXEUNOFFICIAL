import states.substates.GameOverSubstate;
import objects.Character;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;

var inGameOver:Bool = false;
var deadMusic:FlxSound;
var daGameOver:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null) GameOverSubstate.instance.boyfriend.visible = false;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.play();
	deadMusic.looped = true;

	daGameOver = new FlxSprite();
	daGameOver.frames = Paths.getSparrowAtlas('characters/Bf_dancin-vanilla');
	daGameOver.animation.addByPrefix('loop', 'Dance', 24, true);
	daGameOver.animation.play('loop');
	daGameOver.screenCenter();
	daGameOver.scrollFactor.set();
	GameOverSubstate.instance.add(daGameOver);
}

var toggleOnce:Bool = false;
var handSin:Float = 0;
function onUpdatePost(elapsed:Float)
{
	if (!inGameOver) return;

	if (GameOverSubstate.instance.boyfriend.animation.curAnim.name == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			FlxG.sound.music.volume = 0;
		}
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		daGameOver.destroy();
		deadMusic.stop();
	}
}