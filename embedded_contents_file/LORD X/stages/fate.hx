import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import backend.Song;
import states.LoadingState;
import states.PlayState;
import states.SoundTest;

var stat:FlxSprite;
var bgGraphic:FlxSprite;
var blackGraphic:FlxSprite;
var whiteGraphic:FlxSprite;
var eas:FlxSprite;
var bluescreen:FlxSprite;
var bsodPercent:FlxText;

var glitchShader:ErrorHandledRuntimeShader;
var shaderTime:Float = 0;
var glitchBase:Float = 0;
var glitchBurst:Float = 0;

var sceneGlitch:ErrorHandledRuntimeShader;
var sceneTime:Float = 0;
var sceneBase:Float = 0;
var sceneBurst:Float = 0;
var sceneSpikeTimer:Float = 0;
var jaronaFrame:Int = -1;

function onCreate() {
    setVar('wasFPSActive', false);
    setVar('wasFullscreen', false);

    trace(getVar('wasFullscreen'));

    if (Main.fpsVar.visible) setVar('wasFPSActive', true);
    if (FlxG.fullscreen) setVar('wasFullscreen', true);
    trace("BEFORE "+getVar('wasFullscreen'));

    bgGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    bgGraphic.scale.set(2, 2);
    bgGraphic.screenCenter();
    bgGraphic.scrollFactor.set();

    eas = new FlxSprite(0, 0, Paths.image('fate/eas', 'LORD X'));
    eas.updateHitbox();
    eas.scrollFactor.set(0, 0);
    eas.setGraphicSize(FlxG.width, FlxG.height);
    eas.screenCenter();
    add(eas);

    stat = new FlxSprite(0, 0);
    stat.frames = Paths.getSparrowAtlas('daSTAT', 'LORD X');
    stat.animation.addByPrefix('idle', 'staticFLASH', 24, true);
    stat.animation.play('idle',true);
    stat.screenCenter();
    stat.scale.set(3.4, 3.4);
    stat.antialiasing = false;
    add(stat);

    whiteGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    whiteGraphic.scale.set(2, 2);
    whiteGraphic.screenCenter();
    whiteGraphic.scrollFactor.set();
    add(whiteGraphic);

    bluescreen = new FlxSprite(0, 0, Paths.image('fate/bluescreen', 'LORD X'));
    bluescreen.updateHitbox();
    bluescreen.scrollFactor.set();
    bluescreen.setGraphicSize(FlxG.width, FlxG.height);
    bluescreen.screenCenter();
    add(bluescreen);

    bsodPercent = new FlxText(136.67, 401.67, 0, '0% complete', 28);
    bsodPercent.font = Paths.font('UbuntuSans.ttf');
    bsodPercent.scrollFactor.set();
    bsodPercent.antialiasing = ClientPrefs.data.antialiasing;
    add(bsodPercent);

    blackGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackGraphic.scale.set(2, 2);
    blackGraphic.screenCenter();
    blackGraphic.scrollFactor.set();
    add(blackGraphic);

    whiteGraphic.cameras = blackGraphic.cameras = bluescreen.cameras = bsodPercent.cameras = eas.cameras = stat.cameras = [camOther];
    blackGraphic.alpha = bgGraphic.alpha = whiteGraphic.alpha = bluescreen.alpha = bsodPercent.alpha = eas.alpha = stat.alpha = 0.00001;

    //ссанина
    final fragCode:String = Paths.getContent(Paths.shaderFragment('bsodGlitch'));
    
    glitchShader = new ErrorHandledRuntimeShader("GottaGoGlitch", fragCode);
    glitchShader.setFloat('uIntensity', 0);
    if (ClientPrefs.data.shaders) FilterPruner.add(camOther, glitchShader, 'uIntensity', 0);

    sceneGlitch = new ErrorHandledRuntimeShader("FateSceneGlitch", fragCode);
    sceneGlitch.setFloat('uIntensity', 0);
}

function onCreatePost()
{
    if (!ClientPrefs.data.shaders) return;

    FilterPruner.add(camGame, sceneGlitch, 'uIntensity', 0);
    FilterPruner.add(camHUD, sceneGlitch, 'uIntensity', 0);
}

function jaronaHit(frame:Int)
{
    sceneBase = 0.08;
    if (frame >= 92 && frame < 117) sceneBase += (frame - 92) / 25 * 0.4;
    if (frame >= 161 && frame < 185) sceneBase = 0.3;

    switch (frame)
    {
        case 0:
            sceneBurst = 1;
            camGame.shake(0.01, 0.3);
        case 25:
            sceneBurst = 0.9;
            glitchBurst = 0.9;
        case 43:
            sceneBurst = 0.5;
            glitchBurst = 0.6;
        case 55:
            sceneBurst = 0.8;
        case 117:
            sceneBurst = 1;
            camGame.shake(0.015, 0.2);
        case 125, 139:
            sceneBurst = 0.85;
        case 131, 144:
            sceneBurst = 0.6;
        case 161:
            sceneBurst = 1;
            camGame.shake(0.02, 0.25);
        case 185:
            sceneBurst = 0.9;
        case 230:
            sceneBurst = 0.7;
            glitchBurst = 1;
        case 243:
            glitchBurst = 0.6;
        case 256:
            sceneBurst = 0.8;
            glitchBurst = 0.9;
    }
}

// all squished together for you
function onUpdate(elapsed:Float) {
    if(curStep >= 68 && dad.animation.curAnim.name == 'jarona') //JARONA JAJAJAJAJAJA
    {
        switch(dad.animation.curAnim.curFrame) 
        {
            case 25: stat.alpha = 1;
            case 43: stat.alpha = 0;
            case 92:
                addBehindDad(bgGraphic);
                FlxTween.tween(bgGraphic, {alpha: 1}, 0.78, {ease: FlxEase.linear});
            case 117, 185: bgGraphic.alpha = 0;
            case 161: bgGraphic.alpha = 1;
            case 230: eas.alpha = 1;
            case 256: eas.alpha = 0;
        }

        final frame:Int = dad.animation.curAnim.curFrame;
        if (frame != jaronaFrame && bluescreen.alpha != 1)
        {
            jaronaFrame = frame;
            jaronaHit(frame);
        }
    }

    if (sceneGlitch != null && (sceneBase > 0 || sceneBurst > 0))
    {
        sceneTime += elapsed;
        sceneBurst = Math.max(0, sceneBurst - elapsed * 2.5);

        sceneSpikeTimer -= elapsed;
        if (sceneBase > 0 && sceneSpikeTimer <= 0)
        {
            sceneSpikeTimer = FlxG.random.float(0.4, 1.5);
            sceneBurst = Math.max(sceneBurst, FlxG.random.float(0.3, 0.6));
        }

        sceneGlitch.setFloat('uTime', sceneTime);
        sceneGlitch.setFloat('uIntensity', Math.max(sceneBase, sceneBurst));
    }
    
    if (glitchShader != null && (glitchBase > 0 || glitchBurst > 0))
    {
        shaderTime += elapsed;
        glitchBurst = Math.max(0, glitchBurst - elapsed * 2.5);

        glitchShader.setFloat('uTime', shaderTime);
        glitchShader.setFloat('uIntensity', Math.max(glitchBase, glitchBurst));
    }
}

function onStepHit() {
    switch(curStep) {
        case 3428:
            FlxTween.tween(whiteGraphic, {alpha: 0.4}, 0.4, {ease: FlxEase.linear});
            glitchBurst = 0.45;
        case 3462:
            bluescreen.alpha = bsodPercent.alpha = 1;
            sceneBase = sceneBurst = glitchBase = glitchBurst = 0;
            sceneGlitch.setFloat('uIntensity', 0);
            glitchShader.setFloat('uIntensity', 0);
    }
}

function onPause()
{
    glitchShader?.setFloat('uIntensity', 0);
    sceneGlitch?.setFloat('uIntensity', 0);
}

function onGameOverStart()
{
    glitchShader?.setFloat('uIntensity', 0);
    sceneGlitch?.setFloat('uIntensity', 0);
}

function onEndSong() {
    if (SoundTest.fromSoundTest && PlayState.storyPlaylist.length <= 0) 
    {      
        // for a best blue screen crash experience hehehe
        trace("FULL SCREEN 1 "+FlxG.fullscreen);
        if (Main.fpsVar.visible) Main.fpsVar.visible = false;
        if (!FlxG.fullscreen) FlxG.fullscreen = true;
        trace("FULL SCREEN 2 "+FlxG.fullscreen);

        PlayState.campaignScore += score;
		PlayState.campaignMisses += misses;

        camGame.alpha = 0.000001;
        bluescreen.alpha = bsodPercent.alpha = 1;

        final formattedSong = Paths.formatToSongPath(PlayState.SONG.song);
        game.checkSavedSongs(formattedSong);
        
        PlayState.storyPlaylist.shift();
        
        //ну крч вас нахуй без выбора в gotta goon отправят
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], PlayState.storyPlaylist[0]);
        PlayState.isStoryMode = false;
        
        LoadingState.prepareToSong();
        LoadingState.loadAndSwitchState(new PlayState(), false, false);

        return Function_Stop;
    }

    return Function_Continue;
}