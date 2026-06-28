import states.substates.GameOverSubstate;
import flixel.sound.FlxSound;
import flixel.FlxCameraFollowStyle;

import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;

import openfl.utils.Assets;
import backend.Paths;

var exeGameOvers:Bool = false;
var songs:Array<String> = ["yourself", "cycles", "hellbent", "fate", 'hollow', 'endless-us'];
var voicelineSongs:Array<String> = ["cycles", "hellbent", "fate"];

var deadChar:Character;
var deadMusic:FlxSound;
var voiceline:FlxSound;

var hasVoicelines:Bool = false;

var initialDeathZoom:Float;

var charPositions:Array<Float> = [];
var maxVoicelines:Int = 0;

var songShaders:Array<String> = ['yourself'];
var pixel:ShaderFilter;

var majinPairs:Array<Array<FlxSprite>> = [];
var toolateurfucked:Bool = false;
var actuallynotfuckd:Bool = false;
var countdown:FlxTimer;
var secondsLeft:Int = 10;
var countdownText:FlxText;

function onCreate()
    for (song in songs) if (songName == song) setCustomGameOvers();



function setCustomGameOvers() {
    GameOverSubstate.resetVariables();
    switch(songName){
        case "cycles", "hellbent", "fate":
            exeGameOvers = true;
            GameOverSubstate.characterName = "lordx-death";
            charPositions = [400, 450];

            initialDeathZoom = 0.7;

            maxVoicelines = 5;
        case "yourself":
            exeGameOvers = false;
            GameOverSubstate.characterName = "bfyourself-dead";
            GameOverSubstate.deathSoundName = "deathSounds/yourself-sfx";
            GameOverSubstate.loopSoundName = "deathSongs/yourself";
            GameOverSubstate.endSoundName = "deathSongs/yourself-retry";
            charPositions = [500, 250];

            initialDeathZoom = 1.2;
        case "hollow":
            exeGameOvers = false;
            GameOverSubstate.loopSoundName = "deathSongs/hollow";
            GameOverSubstate.endSoundName = "deathSongs/hollow-retry";

            charPositions = [400, 50];
            initialDeathZoom = 1.2;
        case "endless-us":
            exeGameOvers = false;
            GameOverSubstate.deathSoundName = "deathSounds/endless-us-sfx";
            GameOverSubstate.loopSoundName = "deathSongs/endless-us";
            charPositions = [400, 150];
            initialDeathZoom = 0.85;
    }
}

function setCamEvents() {
    FlxG.camera.follow();
    FlxG.camera.scroll.set(0, 0);
    FlxG.camera.zoom = initialDeathZoom;
    switch(songName){
        case "yourself":
            new FlxTimer().start(0.3, (_) -> FlxTween.tween(FlxG.camera, {zoom: 0.9, y: FlxG.camera.y - 90}, 2, {ease: FlxEase.sineInOut}));
    }
}

//Base of this code by dudu. I'll try to make this my own.
var inGameOver:Bool = false;
function onGameOverStart()
{
    for (song in songs)  {
        if (songName == song) {
            inGameOver = true;
            if (GameOverSubstate.instance.boyfriend != null && deadChar == null) deadChar = GameOverSubstate.instance.boyfriend;
            deadChar.scrollFactor.set();
            deadChar.setPosition(charPositions[0], charPositions[1]);

            setCamEvents();

            deadMusic = new FlxSound();
            deadMusic.load(GameOverSubstate.loopSoundName, true);
            FlxG.sound.list.add(deadMusic);
            deadMusic.looped = true;

            for (i in voicelineSongs) if (songName == i) addVoiceLines();
            for (i in songShaders)    if (songName == i) addShaders();

        }
    }
}

function addVoiceLines() {
    voiceline = new FlxSound();
    voiceline.load(Paths.sound("voicelines/" + Std.string(FlxG.random.int(1, maxVoicelines))), true);
    FlxG.sound.list.add(voiceline);
}

function addShaders() {
    switch(songName){
        case "yourself":
            pixel = game.createRuntimeShader('pixelsplash');
            pixel.setFloat("pixelsize", 0.1);

            FlxG.camera.filters = [new ShaderFilter(pixel)];
    }
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadChar == null) deadChar = GameOverSubstate.instance.boyfriend;

    if (exeGameOvers){
        if (deadChar.animation.curAnim.name == 'deathLoop')
        {
            if (!toggleOnce) {
                toggleOnce = true;
                deadMusic.play();
                voiceline.play();
            }
        }

        if (deadChar.animation.curAnim.name == 'deathConfirm' && deadChar.animation.curAnim.finished && deadChar.visible)
        {
            FlxG.camera.flash(0xFFFF0000, 1, null, true);
            deadChar.visible = false;
            FlxG.sound.play(Paths.music('gameOverEnd'));
            deadMusic.stop();
            voiceline.stop();
        }
    }

    if (songName == 'endless-us' && deadChar.animation.curAnim.name == 'deathLoop')
    {
        if (!toggleOnce) {
            toggleOnce = true;
            deadMusic.play();
            startCountdown();
        }
    }
}

function startCountdown()
{
    var baseLeft:Float = 100;
    var baseRight:Float = 750;
    var spacing:Float = 50;

    var indices = [5, 4, 3, 2, 1];
    for (i in indices) {
        var scale:Float = 1.0 - (i * 0.05);

        var left = new FlxSprite();
        left.loadGraphic(Paths.image('gameovers/us/evil majin'));
        left.flipX = true;
        var bell:Float = 1.0 - Math.abs(i - 3) * 0.2;
        var dynamicSpacing:Float = spacing * (1.0 + bell);
        var leftX:Float = i >= 3 ? baseLeft + ((i - 3) * (i - 3) * 30) : baseLeft - (i * dynamicSpacing);
        var yOffset:Float = i == 1 ? 15 : 0;
        left.setPosition(leftX, deadChar.y + yOffset);
        left.scrollFactor.set(0, 0);
        left.scale.set(scale, scale);
        left.alpha = 0;
        if (i >= 3) GameOverSubstate.instance.insert(0, left) else GameOverSubstate.instance.add(left);

        var right = new FlxSprite();
        right.loadGraphic(Paths.image('gameovers/us/evil majin'));
        var rightX:Float = i >= 3 ? baseRight - ((i - 3) * (i - 3) * 30) : baseRight + (i * dynamicSpacing);
        right.setPosition(rightX, deadChar.y + yOffset);
        right.scrollFactor.set(0, 0);
        right.scale.set(scale, scale);
        right.alpha = 0;
        if (i >= 3) GameOverSubstate.instance.insert(0, right) else GameOverSubstate.instance.add(right);

        majinPairs.push([left, right]);
        var targetAlpha:Float = Math.max(0.5, 1.0 - (i * 0.08));
        var tweenTime:Float = 2.0 + (i * 0.3);
        FlxTween.tween(left, {alpha: targetAlpha}, tweenTime);
        FlxTween.tween(right, {alpha: targetAlpha}, tweenTime);
    }

    var left0 = new FlxSprite();
    left0.loadGraphic(Paths.image('gameovers/us/evil majin'));
    left0.flipX = true;
    left0.setPosition(baseLeft, deadChar.y + 20);
    left0.scrollFactor.set(0, 0);
    left0.alpha = 0;
    GameOverSubstate.instance.add(left0);

    var right0 = new FlxSprite();
    right0.loadGraphic(Paths.image('gameovers/us/evil majin'));
    right0.setPosition(baseRight, deadChar.y + 20);
    right0.scrollFactor.set(0, 0);
    right0.alpha = 0;
    GameOverSubstate.instance.add(right0);

    majinPairs.push([left0, right0]);
    FlxTween.tween(left0, {alpha: 1}, 1.5);
    FlxTween.tween(right0, {alpha: 1}, 1.5);

    countdownText = new FlxText(FlxG.width / 2 - 20, FlxG.height / 2 - 280, 0, '10', 36);
    countdownText.font = Paths.font('SonicCD.ttf');
    countdownText.color = FlxColor.WHITE;
    countdownText.scrollFactor.set(0, 0);
    GameOverSubstate.instance.add(countdownText);
    countdownText.camera = FlxG.camera;

    countdownText.alpha = 1;
    FlxTween.tween(FlxG.camera, {zoom: initialDeathZoom + 0.3}, 10, {ease: FlxEase.sineIn});

    countdown = new FlxTimer().start(1, (tmr:FlxTimer) -> {
        secondsLeft--;
        if (countdownText != null) {
            countdownText.text = Std.string(secondsLeft);
            countdownText.x = FlxG.width / 2 - 20;
            var t:Float = 1.0 - (secondsLeft / 10.0);
            var r:Int = 255;
            var g:Int = Std.int(255 * (1.0 - t));
            var b:Int = Std.int(255 * (1.0 - t));
            countdownText.color = FlxColor.fromRGB(r, g, b);
        }
        if (secondsLeft <= 0) {
            if (!actuallynotfuckd) youFuckedUp();
        } else {
            tmr.reset(1);
        }
    });
}

function youFuckedUp()
{
    toolateurfucked = true;

    deadMusic.stop();
    FlxTween.cancelTweensOf(FlxG.camera);
    if (countdownText != null) countdownText.destroy();
    if (countdown != null) countdown.cancel();
    for (pair in majinPairs) { GameOverSubstate.instance.remove(pair[0]); GameOverSubstate.instance.remove(pair[1]); }
}

function onGameOverConfirm(retry)
{
	actuallynotfuckd = true;

	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic && exeGameOvers) sound.volume = 0;
	}

    if (countdown != null) countdown.cancel();
    if (countdownText != null) countdownText.destroy();
    FlxTween.cancelTweensOf(FlxG.camera);
    for (pair in majinPairs) { pair[0].destroy(); pair[1].destroy(); }

    switch(songName){
        case "yourself":
            if (retry) new FlxTimer().start(0.7, (_) ->
            {
                FlxTween.num(0.1, 50, 4, {ease:FlxEase.sineInOut}, (val:Float) -> pixel.setFloat("pixelsize", val));
                FlxTween.tween(FlxG.camera, {zoom: 0.5, y: FlxG.camera.y - 90}, 4, {ease: FlxEase.smootherStepInOut});
                FlxG.camera.stopFade();
                FlxG.camera.fade(FlxColor.BLACK, 4, false, function()
                {
                    for (tweens in [pixel, FlxG.camera]) FlxTween.cancelTweensOf(tweens);
                    FlxG.resetState();
                });
            });
    }
}
