import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import backend.Controls;
import states.SoundTest;
import states.EXEFreeplay;
import backend.Mods;

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
	if (dieVideo?.load(Paths.video('gameovers/' + FlxG.random.int(1,8))) ?? false) dieVideo?.play();
	GameOverSubstate.instance.add(dieVideo);
}

var once:Bool = false;
function onUpdate()
{
	if (!inGameOver) return;

	if (!once && controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end)
	{
		once = true;
		dieVideo?.destroy();
		FlxG.cameras.remove(gameOverHUD, true);
		FlxG.resetState();
	}

	if (!once && controls.BACK #if mobile || backPressed #end)
	{
		once = true;
		dieVideo?.destroy();
		FlxG.cameras.remove(gameOverHUD, true);
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		PlayState.deathCounter = 0;
		PlayState.resetSunkyHelp();
		PlayState.seenCutscene = false;
		PlayState.firstPlay = false;
		PlayState.chartingMode = false;

		Mods.loadTopMod();
		if (SoundTest.fromSoundTest) { SoundTest.fromSoundTest = false; FlxG.switchState(() -> new SoundTest()); }
		else FlxG.switchState(() -> new EXEFreeplay());
	}
}