import flixel.FlxCamera;
import states.SoundTest;

var active:Bool = false;
var released:Bool = false;
var bsodGone:Bool = false;
var camBSOD:FlxCamera;
var camStrums:FlxCamera;
var bluescreen:FlxSprite;
var bsodPercent:FlxText;
var bsodGlitch:ErrorHandledRuntimeShader;
var percent:Int = 0;
var percentTimer:Float = 0.8;
var glitchTime:Float = 0;
var glitchBase:Float = 0;
var glitchBurst:Float = 0;

function onCreate()
{
    active = (SoundTest.fromSoundTest || PlayState.isStoryMode) && !PlayState.seenCutscene;
}

function onCreatePost()
{
    if (!active) return;

    camBSOD = new FlxCamera();
    camBSOD.bgColor = 0x0;
    FlxG.cameras.add(camBSOD, false);

    camStrums = new FlxCamera();
    camStrums.bgColor = 0x0;
    FlxG.cameras.add(camStrums, false);

    bluescreen = new FlxSprite(0, 0, Paths.image('fate/bluescreen', 'LORD X'));
    bluescreen.updateHitbox();
    bluescreen.scrollFactor.set();
    bluescreen.setGraphicSize(FlxG.width, FlxG.height);
    bluescreen.screenCenter();
    bluescreen.camera = camBSOD;
    add(bluescreen);

    bsodPercent = new FlxText(136.67, 401.67, 0, '0% complete', 28);
    bsodPercent.font = Paths.font('UbuntuSans.ttf');
    bsodPercent.scrollFactor.set();
    bsodPercent.camera = camBSOD;
    bsodPercent.antialiasing = ClientPrefs.data.antialiasing;
    add(bsodPercent);

    if (ClientPrefs.data.shaders)
    {
        bsodGlitch = new ErrorHandledRuntimeShader('bsodGlitch', Paths.getContent(Paths.shaderFragment('bsodGlitch')));
        bsodGlitch.setFloat('uIntensity', 0);
        FilterPruner.add(camBSOD, bsodGlitch, 'uIntensity', 0);
    }
}

function onStartCountdown()
{
    if (active && !released) return Function_Stop;
    return Function_Continue;
}

function onUpdate(elapsed:Float)
{
    if (!active) return;

    if (!bsodGone && !FlxG.fullscreen) FlxG.fullscreen = true;

    if (!released)
    {
        percentTimer -= elapsed;
        if (percentTimer <= 0)
        {
            if (percent >= 100) release();
            else
            {
                percent = Std.int(Math.min(100, percent + FlxG.random.int(2, 14)));
                bsodPercent.text = percent + '% complete';
                percentTimer = percent >= 100 ? 0.6 : (FlxG.random.bool(15) ? FlxG.random.float(0.5, 0.9) : FlxG.random.float(0.08, 0.3));
            }
        }
    }

    if (bsodGlitch != null && (glitchBase > 0 || glitchBurst > 0))
    {
        glitchTime += elapsed;
        glitchBurst = Math.max(0, glitchBurst - elapsed * 2.5);
        bsodGlitch.setFloat('uTime', glitchTime);
        bsodGlitch.setFloat('uIntensity', Math.max(glitchBase, glitchBurst));
    }
}

function release()
{
    released = true;
    glitchBase = 0.35;
    glitchBurst = 1;
    camBSOD.shake(0.01, 0.25);

    game.startCountdown();

    for (i in 0...playerStrums.length)
    {
        var strum = playerStrums.members[i];
        var targetY:Float = strum.y;
        strum.camera = camStrums;
        strum.y = -strum.height - 60;
        FlxTween.tween(strum, {y: targetY}, 0.7, {ease: FlxEase.backOut, startDelay: 0.12 * i});
    }
}

function onSongStart()
{
    if (!active) return;

    glitchBase = 0;
    glitchBurst = 1;
    camBSOD.shake(0.015, 0.3);
    FlxTween.tween(camBSOD, {alpha: 0}, 0.4, {onComplete: _ -> {
        for (strum in playerStrums.members) strum.camera = camHUD;
        glitchBurst = 0;
        bsodGlitch?.setFloat('uIntensity', 0);
        bsodGone = true;
        FlxG.cameras.remove(camBSOD, false);
        FlxG.cameras.remove(camStrums, false);
        bluescreen.destroy();
        bsodPercent.destroy();
    }});
}
