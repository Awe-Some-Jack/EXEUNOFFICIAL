import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.characterName = 'bffe-dead';
	GameOverSubstate.deathSoundName = 'dead';
}

var blackScreen:FlxSprite;
var datimer:FlxTimer;
function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(300, 260);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverFE'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.volume = 0;
	deadMusic.play();
	deadMusic.looped = true;

	blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackScreen.scrollFactor.set();
	blackScreen.screenCenter();
	GameOverSubstate.instance.add(blackScreen);
	datimer = new FlxTimer().start(1, _ -> {
		deadMusic.fadeIn(3);
		FlxTween.tween(blackScreen, {alpha: 0}, 3);
	});
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;
	blackScreen.scale.set(1 / FlxG.camera.zoom, 1 / FlxG.camera.zoom);
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (deadBoyfriend.getAnimationName() == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			FlxG.sound.music.volume = 0;
		}
	}

	if (deadBoyfriend.getAnimationName() == 'deathConfirm' && deadBoyfriend.isAnimationFinished() && deadBoyfriend.visible)
	{
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		deadBoyfriend.visible = false;
		FlxG.sound.play(Paths.music('gameOverEndFE'));
		deadMusic.stop();
		datimer.cancel();
		datimer.destroy();
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
	}
}