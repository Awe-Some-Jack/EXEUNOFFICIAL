import states.substates.GameOverSubstate;
import flixel.sound.FlxSound;
import flixel.FlxCameraFollowStyle;

import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;

import openfl.utils.Assets;
import backend.Paths;

var exeGameOvers:Bool = false;
var songs:Array<String> = ["yourself", "cycles", "hellbent", "fate", "endless-us", 'hollow'];
var voicelineSongs:Array<String> = ["cycles", "hellbent", "fate"];
var countdownSongs:Array<String> = ["endless-us"];

var deadChar:Character;
var deadMusic:FlxSound;
var voiceline:FlxSound;

var hasVoicelines:Bool = false;

var initialDeathZoom:Float;

var charPositions:Array<Float> = [];
var maxVoicelines:Int = 0;

var hasCountDown:Bool = false;
var countdown:FlxTimer;
var secondsUntilTragedy:Int = 0;
var countdownText:FlxText;

var majin:FlxSprite;

var songShaders:Array<String> = ['yourself'];

var pixel:ShaderFilter;

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
            GameOverSubstate.deathSoundName = "deathSounds/endless-us-sfx";
            GameOverSubstate.loopSoundName = "deathSongs/endless-us";
            charPositions = [370, 150];
            hasCountdown = true;
            secondsUntilTragedy = 10;

            initialDeathZoom = 1;
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
                //FlxG.sound.music.volume = 0;
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

    if (deadChar.animation.curAnim.name == 'deathLoop')
    {
        if (!toggleOnce) {
            toggleOnce = true;
            for (i in countdownSongs) if (songName == i) setCountDown();
            if (songName == 'endless-us') createMajinAssets(20);
        }
    }
}

function createMajinAssets(amount:Int) {
    for (i in 0...amount) {
        majin = new FlxSprite();
        majin.loadGraphic(Paths.image("gameovers/evil majin"));
        majin.flipX = FlxG.random.int(1, 2) == 1 ? true : false;
        majin.setPosition(deadChar.x + FlxG.random.float(-100, 100), deadChar.y + FlxG.random.float(-50, 50));
        GameOverSubstate.instance.add(majin);

        majin.camera = FlxG.camera;
        majin.scrollFactor.set();

        majin.alpha = 0;
        FlxTween.tween(majin, {alpha: 1}, 1 * (i + 0.2));
    }

    countdownText  = new FlxText(0, 0, 0, secondsUntilTragedy,  44);
    countdownText.font = 'assets/fonts/sonicfree.otf';
    countdownText.color = FlxColor.WHITE;
    countdownText.size = 44;
    countdownText.antialiasing = false;
    countdownText.borderSize = 3;
    countdownText.setPosition(deadChar.getGraphicMidpoint().x + deadChar.cameraPosition[0], deadChar.getGraphicMidpoint().y - 90);
    countdownText.alpha = 0;
    add(countdownText);
    countdownText.camera = FlxG.camera;
    countdownText.scrollFactor.set();
    FlxTween.tween(countdownText, {alpha: 1}, 1);
}

function setCountDown() {
    countdown = new FlxTimer().start(1, (tmr:FlxTimer) -> {
        secondsUntilTragedy = secondsUntilTragedy - 1; //Idk why this works better than secondsUntilTragedy--
        trace("Seconds Left: " + secondsUntilTragedy);

        if (secondsUntilTragedy <= 0)
            tragedyTime();
        else
            tmr.reset(1);
    });
}

function tragedyTime() {
    switch(songName){
        case "endless-us":
            trace("Endless US Time's Over!");
            //GameOverSubstate.instance.boyfriend.visible = false;
    }
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic && exeGameOvers) sound.volume = 0;
        
        if (countdown != null) { 
            countdown.cancel();
            countdownText.destroy();
        }
        switch(songName){
            case "yourself":
                new FlxTimer().start(0.7, (_) -> 
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
}