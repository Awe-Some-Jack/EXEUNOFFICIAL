import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import backend.Controls;

var inGameOver:Bool = false;
var menuVideo:hxvlc.flixel.FlxVideoSprite;
var gameOverHUD:FlxCamera;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	gameOverHUD = new FlxCamera();
	gameOverHUD.bgColor = 0x0;
	FlxG.cameras.add(gameOverHUD, false);

	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null) GameOverSubstate.instance.boyfriend.visible = false;
	GameOverSubstate.instance.canRestart = false;

	dieVideo = new hxvlc.flixel.FlxVideoSprite(0, 0);
	dieVideo.bitmap.onFormatSetup.add(() -> {
		dieVideo.setGraphicSize(FlxG.width, FlxG.height);
		dieVideo.updateHitbox();
		dieVideo.screenCenter();
	});
	dieVideo.camera = gameOverHUD;
	dieVideo.bitmap.onEndReached.add(() -> {FlxG.cameras.remove(gameOverHUD, true); FlxG.resetState();});
	if (dieVideo?.load(Paths.video('gameovers/' + FlxG.random.int(1,7))) ?? false) dieVideo?.play();
	GameOverSubstate.instance.add(dieVideo);
}

function onUpdate()
{
	if (!inGameOver) return;

	if (Controls.instance.ACCEPT)
	{
		dieVideo?.destroy();
		FlxG.cameras.remove(gameOverHUD, true);
		FlxG.resetState();
	}
}