import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.visible = false;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(-FlxG.width / 2, -FlxG.height / 2);
	FlxG.camera.zoom = 0.6;

	var animToPlay:String = 'intro-reverse';
	if (PlayState.instance.dad.animation.curAnim.name.indexOf('-alt') != -1) animToPlay = 'shadows-alt';
	PlayState.instance.dad.playAnim(animToPlay, true);
	PlayState.instance.dad.specialAnim = true;
	PlayState.instance.dad.animation.finishCallback = function(n:String){if (n == animToPlay){PlayState.instance.dad.visible = false; PlayState.instance.dad.animation.finishCallback = null;}};
	PlayState.instance.camHUD.alpha = 0; PlayState.instance.camOther.alpha = 0; PlayState.instance.camVideo.alpha = 0;
	PlayState.instance.persistentDraw = true;
	PlayState.instance.persistentUpdate = true;
	PlayState.instance.camZoomingMult = 0;
	new FlxTimer().start(2, (_) -> {FlxG.resetState();});
	GameOverSubstate.instance.canRestart = false;
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;

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
		for (sound in FlxG.sound.list) sound.volume = 0;
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}