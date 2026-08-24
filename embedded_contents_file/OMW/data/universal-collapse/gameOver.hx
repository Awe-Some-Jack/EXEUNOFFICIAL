import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import objects.VideoSprite;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

var introDead:VideoSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'die';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.alpha = 0;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;
	FlxG.camera.alpha = 1;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverUC'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	introDead = new VideoSprite(0, 0, false);
	introDead.onFormat(() -> {
		introDead.scale.set(1.5, 1.5);
		introDead.screenCenter();
	});
	GameOverSubstate.instance.add(introDead);
	if (introDead?.loadVideo(Paths.video('gameover'))) introDead.playDelayed();
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
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverUCEnd'));
		deadMusic.stop();
		introDead?.destroy();
	}
}