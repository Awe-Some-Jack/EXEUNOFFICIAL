import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import animate.FlxAnimate;
import openfl.filters.ShaderFilter;

// Lo que costo hacer esta mierdaaaaa GAAAAAAA
// By Kophy232

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var deadMusicTimer:FlxTimer;

var deadBF:FlxAnimate;
var blackfuck:FlxSprite;
var blackfuck2:FlxSprite;
var blackoutDone:Bool = false;
var camGameOver:FlxCamera;
var miasmaAtlas:FlxGraphic;
var oneEnter:Bool = true; // Por si quieren skipearlo rapido, ponen False.

var kf1X = -700; var kf1Y = 250; var kf1Zoom = 0.9; var kf1Dur = 0.3; var kf1Ease = FlxEase.cubeOut;
var kf2X = 90; var kf2Y = 100; var kf2Zoom = 0.65; var kf2Dur = 0.4; var kf2Ease = FlxEase.smoothStepInOut;
var kf3X = 180; var kf3Y = 440; var kf3Zoom = 1; var kf3Delay = 0.5; var kf3Dur = 1.4; var kf3Ease = FlxEase.cubeOut;
// deadMusic
var kf4X = 190; var kf4Y = 450; var kf4Zoom = 1.05; var kf4Dur = 2; var kf4Ease = FlxEase.cubeOut;
// enter
var kf5X = 185; var kf5Y = 440; var kf5Zoom = 0.95; var kf5Dur = 1.7; var kf5Ease = FlxEase.elasticOut;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'bfmacheteado';

	Paths.sound('bfmacheteado');
	Paths.music('miasma');
	Paths.music('miasma-retry');
	Paths.getAnimateAtlas('game over/miasmadead');
	miasmaAtlas = Paths.getAnimateAtlas('game over/miasmadead');
}

function onGameOverStart()
{
	inGameOver = true;

	camGameOver = new FlxCamera();
	camGameOver.bgColor = 0x00000000;
	FlxG.cameras.add(camGameOver, false);

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('miasma'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	if(GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.screenCenter();
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.visible = false;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;
	FlxG.camera.bgColor = 0x00000000;

	game.persistentDraw = true;
	game.camHUD.alpha = 0;
	game.camOther.alpha = 0;

	FlxG.sound.music.volume = 0;
	deadMusicTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
		deadMusic.play();
		deadMusic.volume = 1;
		FlxTween.cancelTweensOf(FlxG.camera.scroll);
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera.scroll, {x: kf4X, y: kf4Y}, kf4Dur, {ease: kf4Ease});
		FlxTween.tween(FlxG.camera, {zoom: kf4Zoom}, kf4Dur, {ease: kf4Ease});
	});

	blackfuck = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackfuck.scrollFactor.set();
	blackfuck.screenCenter();
	blackfuck.setGraphicSize(Std.int(blackfuck.width * 2));
    blackfuck.alpha = 1;
	GameOverSubstate.instance.add(blackfuck);
	blackfuck.cameras = [camGameOver];

	deadBF = new FlxAnimate(-446, 8);
	deadBF.frames = Paths.getAnimateAtlas('game over/miasmadead');
    deadBF.anim.addBySymbol('deathstart', 'deathstart', 24, false);
    deadBF.anim.addBySymbol('deathloop', 'deathloop', 24, true);
    deadBF.anim.addBySymbol('deathconfirm', 'deathconfirm', 24, false);
	deadBF.anim.play('deathstart', true);
	deadBF.setGraphicSize(Std.int(deadBF.width * 1.3));
	deadBF.updateHitbox();
	deadBF.cameras = [camGameOver];
	GameOverSubstate.instance.add(deadBF);

	blackfuck2 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackfuck2.scrollFactor.set();
	blackfuck2.screenCenter();
	blackfuck2.alpha = 0;
	GameOverSubstate.instance.add(blackfuck2);
	blackfuck2.cameras = [camGameOver];

	var shaderSpr = game.getLuaObject('shaderSprite_camGame');
	if(shaderSpr != null && shaderSpr.shader != null) {
		var filterObj = new ShaderFilter(shaderSpr.shader);
		camGameOver.filters = [filterObj];
	}

	FlxTween.cancelTweensOf(FlxG.camera.scroll);
	FlxTween.cancelTweensOf(FlxG.camera);
	FlxTween.tween(FlxG.camera.scroll, {x: kf1X, y: kf1Y}, kf1Dur, {ease: kf1Ease});
	FlxTween.tween(FlxG.camera, {zoom: kf1Zoom}, kf1Dur, {ease: kf1Ease});
	new FlxTimer().start(kf1Dur, function(tmr:FlxTimer) {
		FlxTween.cancelTweensOf(FlxG.camera.scroll);
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera.scroll, {x: kf2X, y: kf2Y}, kf2Dur, {ease: kf2Ease});
		FlxTween.tween(FlxG.camera, {zoom: kf2Zoom}, kf2Dur, {ease: kf2Ease});

		new FlxTimer().start(kf3Delay, function(tmr2:FlxTimer) {
			FlxTween.cancelTweensOf(FlxG.camera.scroll);
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.tween(FlxG.camera.scroll, {x: kf3X, y: kf3Y}, kf3Dur, {ease: kf3Ease});
			FlxTween.tween(FlxG.camera, {zoom: kf3Zoom}, kf3Dur, {ease: kf3Ease});
		});
	});
}

function onUpdate(elapsed)
{
	if(!inGameOver) return;

	if(camGameOver != null) {
		camGameOver.scroll.x = FlxG.camera.scroll.x;
		camGameOver.scroll.y = FlxG.camera.scroll.y;
		camGameOver.zoom = FlxG.camera.zoom;
	}
}

function onUpdatePost()
{
	if(!inGameOver) return;

	if(deadBoyfriend.animation.curAnim.curFrame >= 34)
		deadBoyfriend.active = false;
}

function onGameOverConfirm(retry)
{
	if(retry) {
		for(sound in FlxG.sound.list) if(sound.playing) sound.volume = 0;
		FlxG.sound.play(Paths.music('miasma-retry'));
		if(deadBF != null) {
			deadBF.x += 745;
			deadBF.y += 633;
			deadBF.anim.play('deathconfirm', true);
		}
		if(deadMusicTimer != null) { deadMusicTimer.cancel(); deadMusicTimer = null; }
		deadMusic.stop();

		FlxTween.cancelTweensOf(FlxG.camera.scroll);
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera.scroll, {x: kf5X, y: kf5Y}, kf5Dur, {ease: kf5Ease});
		FlxTween.tween(FlxG.camera, {zoom: kf5Zoom}, kf5Dur, {ease: kf5Ease});
		if(oneEnter) GameOverSubstate.instance.canRestart = false;

		if(!blackoutDone) {
			blackoutDone = true;
			new FlxTimer().start(kf5Dur, function(tmr:FlxTimer) {
				if(blackfuck2 != null) FlxTween.tween(blackfuck2, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
			});
		}
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}
