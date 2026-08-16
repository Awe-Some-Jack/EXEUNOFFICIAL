import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import openfl.system.System;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

var star1:FlxSprite;
var star2:FlxSprite;
var countdownText:FlxText;
var countdownTimer:FlxTimer;

var secondsLeft:Int = 10;
var actuallynotfuckd:Bool = false;

var reqLine:FlxSound;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;

function onCreate()
{
	GameOverSubstate.characterName = 'bfreq-dead';
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	gameOverHUD = new FlxCamera();
	gameOverHUD.bgColor = 0x0;
	FlxG.cameras.add(gameOverHUD, false);
	gameOverHUD.alpha = 0;

	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(150, 0);

	FlxTween.cancelTweensOf(FlxG.camera);
	FlxG.camera.follow();
	FlxG.camera.zoom = 1.3;
	FlxG.camera.scroll.set(0, 0);

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.play();

	scream = new hxvlc.flixel.FlxVideoSprite(0, 0);
	scream.bitmap.onFormatSetup.add(() -> {
		scream.scale.set(0.6, 0.6);
		scream.updateHitbox();
		scream.screenCenter();
	});
	scream.bitmap.onEndReached.add(() -> {System.exit(0);});
	GameOverSubstate.instance.add(scream);
	GameOverSubstate.instance.canRestart = false;

	addPixelStuff();

	var voiceLine = FlxG.random.int(1,5);
	makeSubtitle(voiceLine);

	reqLine = new FlxSound();
	reqLine.load(Paths.sound('fddl/' + voiceLine), true);
	reqLine.onComplete = function() {
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(reqLine);
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "I'm not sonic...",
		"2" => "I'm not sonic...",
		"3" => "*laughter*",
		"4" => "*laughter*",
		"5" => "*laughter*"
	];

	subtitle = new FlxText(0, Std.int(FlxG.height * 0.8), Std.int(FlxG.width * 0.75), subtitles.get(daLine));
	subtitle.setFormat(Paths.font("vcr.ttf"), 25, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	subtitle.borderSize = 2;
	subtitle.camera = gameOverHUD;
	subtitle.screenCenter(0x01);

	subtitleBG = new FlxSprite(0, Std.int(FlxG.height * 0.8)).makeGraphic(subtitle.textField.textWidth + 8, subtitle.height + 2, 0xFF000000);
	subtitleBG.screenCenter(0x01);
	subtitleBG.alpha = 0.6;
	subtitleBG.camera = gameOverHUD;

	GameOverSubstate.instance.add(subtitleBG);
	GameOverSubstate.instance.add(subtitle);
}

var timer:Float = 0;
var timerStatus:String = 'intro';
var toggleOnce:Bool = false;
function onUpdatePost(elapsed:Float)
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

function onUpdate(elapsed:Float)
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	timer += elapsed;
	if (timer > 2 && timerStatus == 'intro') {
		timerStatus = 'countdown';
		GameOverSubstate.instance.canRestart = true;
		reqLine.play();
		for (assets in [star1, star2, countdownText]) if (assets != null) FlxTween.tween(assets, {alpha: 1}, 1);
		startCountDownPixel();
		gameOverHUD.alpha = 1;
	}
	if (timer > 12 && timerStatus == 'countdown') {
		timerStatus = 'youfucked';
		GameOverSubstate.instance.canRestart = false;
		deadBoyfriend.playAnim('deathConfirm', true);
		FlxTween.tween(deadBoyfriend, {alpha: 0}, 1);
		for (assets in [star1, star2, countdownText]) if (assets != null) FlxTween.tween(assets, {alpha: 0}, 1);
	}
	if (timer > 13 && timerStatus == 'youfucked')
	{
		timerStatus = 'scream';
		for (pixelAssets in [star1, star2, countdownText]) pixelAssets.destroy();
		if (scream?.load(Paths.video('scream'))) scream?.play();
	}
}

function addPixelStuff() {
	countdownText = new FlxText(FlxG.width / 2 - 10, 0, FlxG.width, '10', 36);
	countdownText.setFormat(Paths.font('SonicCD.ttf'), 36, FlxColor.WHITE, FlxTextAlign.CENTER);
	countdownText.alpha = 0;
	countdownText.screenCenter();
    GameOverSubstate.instance.add(countdownText);
    countdownText.camera = FlxG.camera;

	star1 = new FlxSprite().loadGraphic(Paths.image('star'));
	star1.alpha = 0;
	star1.scale.set(3, 3);
	star1.screenCenter();
	star1.antialiasing = false;
	star1.x = countdownText.x + (countdownText.width - countdownText.textField.textWidth) / 2 - star1.width - 30;
	GameOverSubstate.instance.add(star1);

	star2 = new FlxSprite().loadGraphic(Paths.image('star'));
	star2.alpha = 0;
	star2.scale.set(3, 3);
	star2.screenCenter();
	star2.antialiasing = false;
	star2.x = countdownText.x + (countdownText.width - countdownText.textField.textWidth) / 2 + countdownText.textField.textWidth + 30;
	GameOverSubstate.instance.add(star2);
}

function startCountDownPixel() {
	countdownTimer = new FlxTimer().start(1, (tmr:FlxTimer) -> {
        secondsLeft--;
        if (countdownText != null) {
            countdownText.text = Std.string(secondsLeft);
            var t:Float = 1.0 - (secondsLeft / 10.0);
            var r:Int = 255;
            var g:Int = Std.int(255 * (1.0 - t));
            var b:Int = Std.int(255 * (1.0 - t));
            countdownText.color = FlxColor.fromRGB(r, g, b);
        }
    }, 10);
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		
		FlxG.cameras.remove(gameOverHUD, true);
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		timer = -999;
		if (countdownTimer != null) countdownTimer.cancel();
		for (pixelAssets in [star1, star2, countdownText]) pixelAssets.destroy();
		reqLine.stop();
	}
}