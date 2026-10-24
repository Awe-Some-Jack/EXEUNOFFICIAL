import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.characterName = 'bft-dead';
	GameOverSubstate.deathSoundName = 'die';
	Paths.getSparrowAtlas('characters/GameOver');
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(-20, -10);
	deadBoyfriend.alpha = 0;
	FlxTween.tween(deadBoyfriend, {alpha: 1}, 0.3);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;
}

var toggleOnce:Bool = false;
function onUpdatePost(elapsed:Float)
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
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		//FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		FlxTween.cancelTweensOf(deadBoyfriend);
		deadBoyfriend.alpha = 1;
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}