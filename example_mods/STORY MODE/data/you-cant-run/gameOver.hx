import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.characterName = 'bfexe-dead';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(400, 350);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (deadBoyfriend.animation.curAnim.name == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			FlxG.sound.music.volume = 0;
		}
	}

	if (deadBoyfriend.animation.curAnim.name == 'deathConfirm' && deadBoyfriend.animation.curAnim.finished && deadBoyfriend.visible)
	{
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		deadBoyfriend.visible = false;
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
	}
}