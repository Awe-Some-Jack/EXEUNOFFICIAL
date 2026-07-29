import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import objects.VideoSprite;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

var introDead:VideoSprite;
var loopDead:VideoSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = '../music/gameOverStart';
}

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

	loopDead = new VideoSprite();
	loopDead.onFormat(() -> {
		loopDead.scale.set(0.71, 0.71);
		loopDead.screenCenter();
	});
	loopDead.camera = camVideo;
	loopDead.visible = false;
	GameOverSubstate.instance.add(loopDead);

	introDead = new VideoSprite();
	introDead.onFormat(() -> {
		introDead.scale.set(0.71, 0.71);
		introDead.screenCenter();
	});
	introDead.onComplete(() -> {
		deadMusic.play();
		loopDead.visible = true;
		if (loopDead?.loadVideo(Paths.video('loopgameover'), [VideoSprite.ARG_LOOPING])) loopDead.playDelayed();
	});
	introDead.camera = camVideo;
	GameOverSubstate.instance.add(introDead);
	if (introDead?.loadVideo(Paths.video('introgameover'))) introDead.playDelayed();
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
}