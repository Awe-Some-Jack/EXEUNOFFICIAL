import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var pixelTime:Bool = false;

var continuePixel:FlxSprite;
var star1:FlxSprite;
var star2:FlxSprite;
var countdownText:FlxText;
var countdownTimer:FlxTimer;

var actuallynotfuckd:Bool = false;
var secondsLeft:Int = 10;

function onCreate()
	GameOverSubstate.characterName = 'bfexe-dead';

function onStepHit() {
	if (curStep >= 528 && curStep < 800){
		pixelTime = true;
		GameOverSubstate.characterName = "bf-dead-ycr";
	}else{
		pixelTime = false;
		GameOverSubstate.characterName = "bfexe-dead";
	}
}
function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	if (pixelTime) deadBoyfriend.setPosition(600, 500);
	else deadBoyfriend.setPosition(320, 200);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;
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
			if (pixelTime) addPixelStuff();
		}
	}

	if (deadBoyfriend.getAnimationName() == 'deathConfirm' && deadBoyfriend.isAnimationFinished() && deadBoyfriend.visible)
	{
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		deadBoyfriend.visible = false;
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		if (pixelTime) for (pixelAssets in [continuePixel, star1, star2, countdownText]) pixelAssets.destroy();
	}
}

function addPixelStuff() {
	continuePixel = new FlxSprite();
	continuePixel.loadGraphic(Paths.image('gameovers/youcantrun/continue'));
	continuePixel.setPosition(FlxG.width / 2 - 40, FlxG.height / 2 - 50);
	continuePixel.antialiasing = false;
	continuePixel.alpha = 0;
	continuePixel.scale.set(3, 3);
	GameOverSubstate.instance.add(continuePixel);
	
	star1 = new FlxSprite();
	star1.loadGraphic(Paths.image('gameovers/youcantrun/star'));
	star1.setPosition(FlxG.width / 2 - 40, FlxG.height / 2 + 40);
	star1.antialiasing = false;
	star1.alpha = 0;
	star1.scale.set(3, 3);
	GameOverSubstate.instance.add(star1);

	star2 = new FlxSprite();
	star2.loadGraphic(Paths.image('gameovers/youcantrun/star'));
	star2.setPosition(FlxG.width / 2 + 50, FlxG.height / 2 + 40);
	star2.antialiasing = false;
	star2.alpha = 0;
	star2.scale.set(3, 3);
	GameOverSubstate.instance.add(star2);

	countdownText = new FlxText(FlxG.width / 2 - 10, FlxG.height / 2 + 20, 0, '10', 36);
	countdownText.setFormat(Paths.font('SonicCD.ttf'), 36, FlxColor.WHITE);
    countdownText.scrollFactor.set();
	countdownText.alpha = 0;
    GameOverSubstate.instance.add(countdownText);
    countdownText.camera = FlxG.camera;
	
	for (assets in [continuePixel, star1, star2, countdownText]) FlxTween.tween(assets, {alpha: 1}, 1);

	startCountDownPixel();
}

function startCountDownPixel() {
	countdownTimer = new FlxTimer().start(1, (tmr:FlxTimer) -> {
        secondsLeft--;
        if (countdownText != null) {
            countdownText.text = Std.string(secondsLeft);
            countdownText.x = FlxG.width / 2 + 2;
            var t:Float = 1.0 - (secondsLeft / 10.0);
            var r:Int = 255;
            var g:Int = Std.int(255 * (1.0 - t));
            var b:Int = Std.int(255 * (1.0 - t));
            countdownText.color = FlxColor.fromRGB(r, g, b);
        }
        if (secondsLeft <= 0) {
            if (!actuallynotfuckd) skillIssue();
        } else {
            tmr.reset(1);
        }
    });
}

function skillIssue(){
	for (sound in FlxG.sound.list) if (sound.playing) sound.volume = 0;
	FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
	{
		for (tweens in [FlxG.camera]) FlxTween.cancelTweensOf(tweens);
		Sys.exit(0);
	});
}

function onGameOverConfirm(retry)
{
	actuallynotfuckd = true;
	if (retry) { for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0; }
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
	if (countdownTimer != null) countdownTimer.cancel();
}