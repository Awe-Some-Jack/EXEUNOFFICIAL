import states.substates.GameOverSubstate;
import objects.Character;
import objects.VideoSprite;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

var introDead:VideoSprite;
var loopDead:VideoSprite;

function onCreate() GameOverSubstate.deathSoundName = 'empty';

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.visible = false;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;
	GameOverSubstate.instance.canRestart = false;

	loopDead = new VideoSprite();
	loopDead.onFormat(() -> {
		loopDead.screenCenter();
	});
	loopDead.camera = camVideo;
	loopDead.visible = false;
	GameOverSubstate.instance.add(loopDead);

	introDead = new VideoSprite();
	introDead.onFormat(() -> {
		introDead.screenCenter();
	});
	introDead.onComplete(() -> {
		GameOverSubstate.instance.canRestart = true;
		deadMusic.play();
		loopDead.visible = true;
		if (loopDead?.loadVideo(Paths.video('loop'), [VideoSprite.ARG_LOOPING])) loopDead.playDelayed();
	});
	introDead.camera = camVideo;
	GameOverSubstate.instance.add(introDead);
	if (introDead?.loadVideo(Paths.video('death'))) introDead.playDelayed();
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
		deadMusic.stop();
		introDead.destroy(); loopDead.destroy();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}