import states.substates.GameOverSubstate;
import flixel.sound.FlxSound;
import flixel.FlxCameraFollowStyle;
import flixel.tweens.FlxTween.FlxTweenType;
import backend.MusicBeatState;

import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;

import openfl.utils.Assets;
import backend.Paths;

import psychlua.ModchartAnimateSprite;
import psychlua.FlxAnimateFunctions;
import psychlua.CustomSubstate;

import lime.app.Application as Application;

import objects.VideoSprite;

import animate.FlxAnimate;

var exeGameOvers:Bool = false;
var songs:Array<String> = ["yourself", "cycles", "hellbent", "fate", 'hollow', 'endless-us', 'starline', 'uh-oh', 'sharpy-showdown', 'substantial'];
var voicelineSongs:Array<String> = ["cycles", "hellbent", "fate"];
var diffGameOverSongs:Array<String> = ["starline"];

var gameOverChangeStep:Int = null;

var head:FlxSprite;
var deadChar:Character;
var deadMusic:FlxSound;
var voiceline:FlxSound;

var hasVoicelines:Bool = false;

var initialDeathZoom:Float;

var charPositions:Array<Float> = [];
var maxVoicelines:Int = 0;

var songShaders:Array<String> = ['yourself'];
var pixel     :ShaderFilter;
var pseudo    :ShaderFilter;
var wave      :ShaderFilter;

var majinPairs:Array<Array<FlxSprite>> = [];
var toolateurfucked:Bool = false;
var actuallynotfuckd:Bool = false;
var countdown:FlxTimer;
var secondsLeft:Int = 10;
var countdownText:FlxText;
var majinBF:ModchartAnimateSprite;
var blueVG:FlxSprite;

var subsDeath:FlxVideoSprite;

function onCreate(){
    for (song in songs) 
        if (songName == song) setCustomGameOvers();
}

function setCustomGameOvers() {
    GameOverSubstate.resetVariables();
    switch(songName){
        case "cycles", "hellbent", "fate":
            exeGameOvers = true;
            GameOverSubstate.characterName  = "lordx-death";
            GameOverSubstate.deathSoundName = "crushDeath";
            charPositions = [480, 350];

            initialDeathZoom = 0.7;

            trace('Lord X death animation loaded');

            maxVoicelines = 5;
        case "yourself":
            exeGameOvers = false;
            GameOverSubstate.characterName  = "bfyourself-dead";
            GameOverSubstate.deathSoundName = "deathSounds/yourself-sfx";
            GameOverSubstate.loopSoundName  = "deathSongs/yourself";
            GameOverSubstate.endSoundName   = "deathSongs/yourself-retry";
        case "hollow":
            exeGameOvers = false;
            GameOverSubstate.loopSoundName = "deathSongs/hollow";
            GameOverSubstate.endSoundName  = "deathSongs/hollow-retry";

            charPositions = [400, 50];
            initialDeathZoom = 1.2;
        case "endless-us":
            exeGameOvers = false;
            GameOverSubstate.deathSoundName = "deathSounds/endless-us-sfx";
            GameOverSubstate.loopSoundName  = "deathSongs/endless-us";
            charPositions = [320, 80];
            initialDeathZoom = 0.85;
        case "starline":
            gameOverChangeStep = 1088;
            exeGameOvers = false;
            GameOverSubstate.characterName  = "chaotixbfdeath";
            GameOverSubstate.deathSoundName = "deathSounds/glitch-chaotix";
            GameOverSubstate.loopSoundName  = "deathSongs/chaotix-beast-sfx";
            charPositions = [590, 350];
            initialDeathZoom = 0.7;
        case "uh-oh":
            GameOverSubstate.loopSoundName = "deathSongs/uh-oh-sfx";
            GameOverSubstate.endSoundName  = "deathSongs/retry";
            charPositions = [310, 100];
            initialDeathZoom = 0.9;
        case "sharpy-showdown":
            GameOverSubstate.loopSoundName = "deathSongs/exetior";
            GameOverSubstate.endSoundName  = "deathSongs/exetior-retry";
            charPositions = [400, 50];
            initialDeathZoom = 1.2;
        case "substantial":
            initialDeathZoom = 0.9;
            GameOverSubstate.loopSoundName =   "deathSongs/xterion-loop";
            GameOverSubstate.endSoundName  = "deathSounds/xterion-retry";
    }
}

function onStepHit() {
    if (gameOverChangeStep != null && curStep >= gameOverChangeStep) changeGameOvers();
}

function changeGameOvers() {
    switch(songName){
        case "starline":
            exeGameOvers = true;
            GameOverSubstate.characterName  = "chaotixbeastdeath";
            GameOverSubstate.deathSoundName = "deathSounds/gore-chaotix";
            charPositions = [460, 250];
            initialDeathZoom = 0.7;
    }
}

function setCamEvents() {
    if (exeGameOvers)
    {
        FlxTween.cancelTweensOf(FlxG.camera); //Just in case, heh.
        FlxG.camera.follow();
        FlxG.camera.scroll.set(0, 0);
        FlxG.camera.zoom = initialDeathZoom;
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
            if (exeGameOvers)
            {
                deadChar.scrollFactor.set();
                deadChar.setPosition(charPositions[0], charPositions[1]);
            }

            setCamEvents();

            setCustomEvents();

            deadMusic = new FlxSound();
            deadMusic.load(GameOverSubstate.loopSoundName, true);
            FlxG.sound.list.add(deadMusic);
            deadMusic.looped = true;

            for (i in voicelineSongs) if (songName == i) addVoiceLines();
            for (i in songShaders)    if (songName == i) addShaders();

        }
    }
}

function setCustomEvents() {
    switch(songName){
        case "hollow":
            Conductor.bpm = 138;
            FlxTween.tween(FlxG.camera, {zoom: 0.8}, 2, {ease: FlxEase.sineInOut});
        case "substantial":
            GameOverSubstate.instance.boyfriend.visible = false;
            subsDeath = new VideoSprite(-520, -250, false);
            subsDeath.loadVideo(Paths.video("substantialDeath"));
            subsDeath.canSkip = false;
            subsDeath.alpha = 0.0001;
            subsDeath.scale.set(0.55, 0.688);
            subsDeath.onEnd(() -> {
                subsDeath.loadVideo(Paths.video("substantialDeath"));
                subsDeath.play();
            });
            GameOverSubstate.instance.add(subsDeath);
        case "starline":
            FlxG.cameras.flash(FlxColor.RED, 1);
        case "cycles", "hellbent", "fate":
            head = new FlxAnimate(480, 50);
            head.frames = Paths.getAnimateAtlas('gameovers/LORD-X-DEATH-HEAD');
            head.anim.addBySymbol('deathstart', 'deahrt', 24, false);
            head.anim.addBySymbol('deathloop', 'loop', 24, true);
            head.anim.play('deathstart');
            head.scale.set(1.7, 1.7);
            head.anim.onFinish.add( name -> {
                head.anim.play('deathloop');
            });
            GameOverSubstate.instance.add(head);
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
            var fragSrc:String = Assets.getText(Paths.shaderFragment('pixelsplash'));
            pixel = new FlxRuntimeShader(fragSrc);
            pixel.setFloat("pixelsize", 0.1);

            FlxG.camera.filters = [new ShaderFilter(pixel)];
    }
}

var toggleOnce:Bool = false;
var curBeat:Int = 0;
var oldBeat:Int = 0;
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
            if(head != null) head.visible = false;
            FlxG.sound.play(Paths.music('gameOverEnd'));
            deadMusic.stop();
            voiceline.stop();
        }
    }

    if (songName == 'hollow' && deadChar.animation.curAnim.name == 'deathLoop')
    {
        Conductor.songPosition = FlxG.sound.music.time;
        curBeat = GameOverSubstate.instance.curBeat;
        if (!toggleOnce) {
            if (Conductor.songPosition >= 6900){
                if (oldBeat != curBeat)
                {
                    trace("It's bumping!");
                    FlxTween.num(0.9, 0.8, (Conductor.crochet / 1000), {ease: FlxEase.circOut, type: FlxTweenType.LOOPING}, (val:Float) -> FlxG.camera.zoom = val);
                    oldBeat = curBeat;
                }
                toggleOnce = true;
            }
            
        }
    }

    if (songName == 'endless-us' && deadChar.animation.curAnim.name == 'deathLoop')
    {
        if (!toggleOnce) {
            toggleOnce = true;
            deadMusic.play();
            startCountdownMajin();
        }
    }
    if (songName == 'substantial' && deadChar.animation.curAnim.name == 'deathLoop')
    {
        if (!toggleOnce) {
            toggleOnce = true;
            deadMusic.play();
            subsDeath.play();
            FlxTween.tween(subsDeath, {alpha: 1}, 3);
        }
    }
}

function startCountdownMajin()
{
    var baseLeft:Float = 100;
    var baseRight:Float = 750;
    var spacing:Float = 50;

    //Majin BF
    majinBF = new ModchartAnimateSprite(0, 0);
    majinBF.frames = Paths.getAnimateAtlas('gameovers/us/us');
    majinBF.anim.addBySymbol('dying', 'majinbf', 24, false);
    majinBF.active = true;
    majinBF.setPosition(deadChar.x - 520, deadChar.y - 520);
    majinBF.scale.set(0.7, 0.7);
    majinBF.alpha = 0;
    GameOverSubstate.instance.add(majinBF);

    //Blue VG
    blueVG = new FlxSprite();
    blueVG.loadGraphic(Paths.image('hud/blueVg'));
    blueVG.scrollFactor.set();
    blueVG.alpha = 0;
    GameOverSubstate.instance.add(blueVG);

    var indices = [5, 4, 3, 2, 1];
    for (i in indices) {
        var scale:Float = 1.0 - (i * 0.05);

        var left = new FlxSprite();
        left.loadGraphic(Paths.image('gameovers/us/evil majin'));
        left.flipX = true;
        var bell:Float = 1.0 - Math.abs(i - 3) * 0.2;
        var dynamicSpacing:Float = spacing (1.0 + bell);
        var leftX:Float = i >= 3 ? baseLeft + ((i - 3) (i - 3) * 30) : baseLeft - (i * dynamicSpacing);
        var yOffset:Float = i == 1 ? 70 : 65;
        left.setPosition(leftX, deadChar.y + yOffset);
        left.scrollFactor.set(0, 0);
        left.scale.set(scale, scale);
        left.alpha = 0;
        if (i >= 3) GameOverSubstate.instance.insert(0, left) else GameOverSubstate.instance.add(left);

        var right = new FlxSprite();
        right.loadGraphic(Paths.image('gameovers/us/evil majin'));
        var rightX:Float = i >= 3 ? baseRight - ((i - 3) (i - 3) * 30) : baseRight + (i * dynamicSpacing);
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
    left0.setPosition(baseLeft, deadChar.y + 70);
    left0.scrollFactor.set(0, 0);
    left0.alpha = 0;
    GameOverSubstate.instance.add(left0);

    var right0 = new FlxSprite();
    right0.loadGraphic(Paths.image('gameovers/us/evil majin'));
    right0.setPosition(baseRight, deadChar.y + 70);
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
            var g:Int = Std.int(255 (1.0 - t));
            var b:Int = Std.int(255 (1.0 - t));
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
    GameOverSubstate.instance.canRestart = false;
    toolateurfucked = true;

    deadMusic.stop();
    if (countdownText != null) countdownText.destroy();
    if (countdown != null) countdown.cancel();
    for (pair in majinPairs) { GameOverSubstate.instance.remove(pair[0]); GameOverSubstate.instance.remove(pair[1]); }

    deadChar.visible = false;
    majinBF.alpha = 1;
    blueVG.alpha  = 1;
    FlxTween.tween(blueVG, {alpha: 0}, 1);
    majinBF.animation.play('dying', true);
    for (sound in FlxG.sound.list) if (sound.playing) sound.volume = 0;
    FlxTween.cancelTweensOf(FlxG.camera);
    FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.6}, 1, {ease: FlxEase.circOut});
    FlxG.sound.play(Paths.sound('deathSounds/firstLOOK'));

    new FlxTimer().start(2.45, (_) -> {
        FlxG.sound.play(Paths.sound('deathSounds/secondLOOK'));
        FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.2}, 0.5, {ease: FlxEase.circOut});

        new FlxTimer().start(6, (_) -> Application.current.window.close());
    });

}

function onGameOverConfirm(retry)
{

	actuallynotfuckd = true;

	if (retry) {
        for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic && exeGameOvers) sound.volume = 0;
    }
    
    //FlxTween.cancelTweensOf(FlxG.camera);
    if (countdown     != null) countdown.cancel();
    if (countdownText != null) countdownText.destroy();
    for (pair in majinPairs) { pair[0].destroy(); pair[1].destroy(); }

    switch(songName){
        case "hollow":
            FlxTween.cancelTweensOf(FlxG.camera);
            FlxTween.num(1, 0.8, 1, {ease: FlxEase.circOut,  onComplete: () -> FlxTween.tween(FlxG.camera, {zoom: 1.4}, 2, {ease: FlxEase.circIn})}, (val:Float) -> FlxG.camera.zoom = val);
        case "substantial":
            FlxG.cameras.flash(FlxColor.BLUE, 2);
            subsDeath.destroy();

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

//Haze Gameover. I believe this one is more tricky.

final hazeBG:Array<String> = [
    'redSun', 
    'bg', 'ola', 'trees3', 'trees2', 'trees', 'floor', 'fore', 
    'sky3', 'montains', 'lol', 'suelo', 'totem', 'm', 't',
    'overlay', 'sun-clouds', 'cloudFront', 'water2', 'waterfall1', 'waterfall2', 'groundShit', 'dedplants', 'k',
    'sky', 'clouds1', 'clouds2', 'clouds-mountains', 'clouds3', 'ground', 'thomas', 'kyle'
];

var canPress:Bool = false;

function onGameOver() {
    if (songName == 'haze'){
        persistentDraw = false;
        CustomSubstate.openCustomSubstate("hazeGameOver", true);
        return Function_Stop;
    }
}

var redGraphicShit:FlxSprite;
var bfEerie:FlxSprite;
var griatosScream:FlxSprite;
var hazeSound:FlxSound;
var camHaze:FlxCamera;

function onCustomSubstateCreate(n)
{
    if (n == "hazeGameOver") {
        camHaze = new FlxCamera();
        camHaze.bgColor = 0x0;
        FlxG.cameras.add(camHaze);
        
        redGraphicShit = new FlxSprite(0, 0);
        redGraphicShit.makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFFFF0000);
        redGraphicShit.scrollFactor.set(0, 0);
        redGraphicShit.screenCenter();
        redGraphicShit.cameras = [FlxG.camera];
        CustomSubstate.instance.insert(members.indexOf(boyfriendGroup), redGraphicShit);
        
        bfEerie = new FlxSprite(0, 0);
        bfEerie.loadGraphic(Paths.image("gameovers/eerie"));
        bfEerie.scrollFactor.set(0, 0);
        bfEerie.cameras = [FlxG.camera];
        bfEerie.screenCenter();
        bfEerie.alpha = 0;
        CustomSubstate.instance.add(bfEerie);
        
        if(PlayState.instance.curStep >= 384) {FlxG.camera.scroll.set(-400, -400); FlxG.camera.zoom = 0.8;}
        if(PlayState.instance.curStep >= 1600) {FlxG.camera.scroll.set(300, 100); FlxG.camera.zoom = 0.6;}
        setupHazeGameOver();
    }
}

var holdTime:Float;
function onCustomSubstateUpdate(n)
{
    if (n == "hazeGameOver")
    {
        holdTime++;
        if (canPress){
            if (controls.ACCEPT){
                FlxG.camera.fade(FlxColor.BLACK, 3, false, () -> FlxG.resetState());
                canPress = false;
            }
        }
        boyfriend.animation.paused = true;
        dad.animation.paused = true;

        pseudo.setFloat("iTime", holdTime);
        wave.setFloat("iTime", holdTime * 2);
    }
}

function setupHazeGameOver() {
    FlxG.stage.window.title = PlayState.instance.appName + " | Was Playing: " + PlayState.SONG.song;
    //Shader shit
    for (guys in [boyfriend, dad]) guys.shader = null;
    
    var fragSrc:String = Assets.getText(Paths.shaderFragment('pseudo'));
    pseudo = new FlxRuntimeShader(fragSrc);
    pseudo.setFloat("sort", 0);
    var fragSrc2:String = Assets.getText(Paths.shaderFragment('wavyDistortion'));
    wave = new FlxRuntimeShader(fragSrc2);
    wave.setFloat("amount", 0);

    FlxG.camera.filters = [new ShaderFilter(pseudo), new ShaderFilter(wave)];
    
    PlayState.instance.camHUD.visible = false;
    FlxTween.cancelTweensOf(FlxG.camera);

    for (bgStuff in hazeBG) {
        var bgObject:Dynamic = getVar(bgStuff);
        if (bgObject != null) bgObject.visible = false;
    }

    for (guys in [boyfriend, dad]) guys.alpha = 0;

    new FlxTimer().start(0.6, () -> startScreamShit());

    hazeSound = new FlxSound();
    hazeSound.load(Paths.sound("deathSounds/hazeScream"));
    hazeSound.play();
    hazeSound.onComplete = () -> bfCreepy();
}

function startScreamShit() {
    configureChars();
    
    new FlxTimer().start(2.5, () -> showJumpscare());

    wave.setFloat("amount", 0.2);

    new FlxTimer().start(0.6, () -> pseudo.setFloat("sort", 0.4));
}

function configureChars()
{
    //PlayState.instance.triggerEvent("Change Character", "dad", "griatos");
    for (guys in [boyfriend, dad]){
        guys.color = FlxColor.BLACK;
        guys.alpha = 1;
    }
    
    //boyfriend.setPosition(670, 200);
    //boyfriend.scale.set(0.6, 0.6);
    boyfriend.specialAnim = true;
    boyfriend.animation.pause();
    boyfriend.cameras = [FlxG.camera];
    //dad.setPosition(-370, -260);
    //dad.scale.set(0.6, 0.6);
    dad.animation.play('singRIGHT');
    dad.cameras = [FlxG.camera];
    dad.specialAnim = true;
    dad.animation.pause();
    CustomSubstate.instance.add(dadGroup);
    CustomSubstate.instance.add(boyfriendGroup);
}

function showJumpscare() {
    griatosScream = new FlxSprite();
    griatosScream.frames = Paths.getSparrowAtlas("gameovers/Griatos_Scream");
    griatosScream.animation.addByPrefix('idle', 'Griatos_Scream scream', 24, true);
    griatosScream.animation.play('idle', true);
    griatosScream.scrollFactor.set(0, 0);
    griatosScream.scale.set(1.35, 1.35);
    griatosScream.cameras = [camHaze];
    griatosScream.screenCenter();
    griatosScream.alpha = 0;
    CustomSubstate.instance.add(griatosScream);

    griatosScream.alpha += 0.2;
    for (guys in [boyfriend, dad]) guys.alpha -= 0.2;

    new FlxTimer().start(1.4,   () -> {griatosScream.alpha += 0.2; for (guys in [boyfriend, dad]) guys.alpha -= 0.2;});
    new FlxTimer().start(1.8,   () -> {griatosScream.alpha += 0.2; for (guys in [boyfriend, dad]) guys.alpha -= 0.2; pseudo.setFloat("sort", 0.6);});
    new FlxTimer().start(2.4,   () -> {griatosScream.alpha += 0.6; for (guys in [boyfriend, dad]) guys.alpha -= 0.6; pseudo.setFloat("sort", 0.9);});
    
    new FlxTimer().start(3.3,   () -> hideThem());
}

function hideThem() {
    for (guys in [boyfriend, dad, griatosScream, redGraphicShit])
        guys.alpha = 0;
    pseudo.setFloat("sort", 0);
}

function bfCreepy() {
    FlxG.camera.zoom = 1.1;
    wave.setFloat("amount", 0.6);
    FlxG.sound.play(Paths.sound("deathSounds/hazeLoop", 1, true));
    FlxTween.tween(bfEerie, {alpha: 1}, 3, {onComplete: () -> canPress = true});
}