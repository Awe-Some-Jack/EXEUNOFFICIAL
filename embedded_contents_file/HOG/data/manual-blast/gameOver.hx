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

function onCreate()
{
	GameOverSubstate.characterName = 'bfh-dead';
	GameOverSubstate.deathSoundName = '../music/gameOverStart-mb';
}

function onGameOverStart()
{
	GameOverSubstate.instance.canRestart = false;
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(-50, -700);
	deadBoyfriend.alpha = 0;
	deadBoyfriend.animation.paused = true;
	new FlxTimer().start(1.2, _ -> {
		deadBoyfriend.alpha = 1;
		deadBoyfriend.animation.play('firstDeath', true);
	});

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver-mb'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	addPixelStuff();
}

var timer:Float = 0;
var timerStatus:String = 'intro';
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

		deadBoyfriend.visible = false;
		deadMusic.stop();
		timer = -999;
		if (countdownTimer != null) countdownTimer.cancel();
		for (pixelAssets in [star1, star2, countdownText]) pixelAssets.destroy();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}

function onUpdate(elapsed:Float)
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	timer += elapsed;
	if (timer > 2 && timerStatus == 'intro') {
		timerStatus = 'countdown';
		GameOverSubstate.instance.canRestart = true;
		for (assets in [star1, star2, countdownText]) if (assets != null) FlxTween.tween(assets, {alpha: 1}, 1);
		startCountDownPixel();
	}
	if (timer > 13 && timerStatus == 'countdown') {
		timerStatus = 'youfucked';
		GameOverSubstate.instance.canRestart = false;
		deadBoyfriend.alpha = 0;
		for (pixelAssets in [star1, star2, countdownText]) pixelAssets.destroy();
	}
	if (timer > 14 && timerStatus == 'youfucked')
	{
		timerStatus = 'end';
		System.exit(0);
	}
}

function addPixelStuff() {
	countdownText = new FlxText(FlxG.width / 2 - 10, -70 + 200, FlxG.width, '10', 100);
	countdownText.setFormat(Paths.font('SonicCD.ttf'), 100, FlxColor.WHITE, FlxTextAlign.CENTER);
	countdownText.alpha = 0;
	countdownText.screenCenter(0x01);
    GameOverSubstate.instance.add(countdownText);

	star1 = new FlxSprite().loadGraphic(Paths.image('star'));
	star1.alpha = 0;
	star1.scale.set(8, 8);
	star1.screenCenter(0x01);
	star1.antialiasing = false;
	star1.x = countdownText.x + (countdownText.width - countdownText.textField.textWidth) / 2 - star1.width - 30;
	star1.y += 200;
	GameOverSubstate.instance.add(star1);

	star2 = new FlxSprite().loadGraphic(Paths.image('star'));
	star2.alpha = 0;
	star2.scale.set(8, 8);
	star2.screenCenter(0x01);
	star2.antialiasing = false;
	star2.x = countdownText.x + (countdownText.width - countdownText.textField.textWidth) / 2 + countdownText.textField.textWidth + 30;
	star2.y += 200;
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