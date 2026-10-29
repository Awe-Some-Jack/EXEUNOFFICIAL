import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

import objects.VideoSprite;

final dancerValues:Array<Int> = [32, 28, 24, 20, 16, 12, 8];

var randomDancer:Int = 32;
var beats:Int = 0;
var wavyShader:FlxRuntimeShader;
var wavyness:Float = 0.0;

var brightnessShader:FlxRuntimeShader;
var brightnessPulseTime:Float = -1;

var chromaticShader:FlxRuntimeShader;
var chromaticPulseTime:Float = -1;
var chromaticIntensity:Float = 0;

var contrastShader:FlxRuntimeShader;
var contrastValue:Float = 0;
var contrastTarget:Float = 0;
var contrastFrom:Float = 0;
var contrastTweenTime:Float = -1;

var sad:Bool = false;
var happy:Bool = false;

var floor:FlxSprite;
var tails:FlxSprite;
var fuente:FlxSprite;
var menuSTATIC:VideoSprite;

var blackFade:FlxSprite;
var blackFadeTween:FlxTween = null;

final bgSprites:Array<FlxSprite> = [];

var speedTween:FlxTween = null;

var dadPhase:String = 'happy';

// DANCERS (gente del fondo) - { spr, name, alt, step }
var dancers:Array<Dynamic> = [];

function makeDancer(name:String, alt:String, x:Float, y:Float, step:Int, scale:Float = 1)
{
    var spr:FlxAnimate = new FlxAnimate(x, y);
    spr.frames = Paths.getAnimateAtlas('Park/Characters');
    spr.antialiasing = ClientPrefs.data.antialiasing;

    spr.anim.addBySymbol(name, name, 24, true);
    if (alt != null) spr.anim.addBySymbol(alt, alt, 24, true);
    spr.anim.play(name, true);

    spr.scale.set(scale, scale);
    spr.updateHitbox();

    insert(game.members.indexOf(fuente), spr);

    dancers.push({ spr: spr, name: name, alt: alt, step: step });
    return spr;
}

function onCreate()
{
    var sky:FlxSprite = new FlxSprite(-950, -450).loadGraphic(Paths.image('Park/city'));
    sky.scale.set(0.86, 0.86); sky.updateHitbox();
    sky.scrollFactor.set(0.6, 0.6);
    addBehindGF(sky);

    floor = new FlxSprite(-1240, -365).loadGraphic(Paths.image('Park/bg'));
    floor.scale.set(0.86, 0.86); floor.updateHitbox();
    addBehindGF(floor);

    fuente = new FlxSprite(-80, -90);
    fuente.frames = Paths.getSparrowAtlas('Park/fountain');
    fuente.animation.addByPrefix('idle', 'fountain', 12, true);
    fuente.animation.play('idle', true);
    fuente.scale.set(1.2, 1.2);
    addBehindGF(fuente);

    //320

    menuSTATIC = new VideoSprite();
    if (menuSTATIC.loadVideo(Paths.video('STATIC'), [VideoSprite.ARG_LOOPING, VideoSprite.ARG_MUTED])) menuSTATIC.playDelayed();
    menuSTATIC.scale.set((FlxG.width / menuSTATIC.width) * 1.5, (FlxG.height / menuSTATIC.height) * 1.5);
    menuSTATIC.screenCenter();
    menuSTATIC.x -= 650;
    menuSTATIC.y -= 50;
    menuSTATIC.alpha = 0.00001;
    addBehindGF(menuSTATIC);

    var fore:FlxSprite = new FlxSprite(-1500, 600).loadGraphic(Paths.image('Park/foreground'));
    fore.scale.set(0.6, 0.6); fore.updateHitbox();
    fore.scrollFactor.set(1.25, 1.25);
    add(fore);

    wavyShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("wavyDistortion")));

    brightnessShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("brightness")));
    brightnessShader.setFloat('contrast', 1);
    brightnessShader.setFloat('saturation', 1);
    brightnessShader.setFloat('brightness', 0);

    chromaticShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("chromatic")));
    chromaticShader.setFloatArray('rOffset', [0, 0]);
    chromaticShader.setFloatArray('gOffset', [0, 0]);
    chromaticShader.setFloatArray('bOffset', [0, 0]);

    contrastShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("contrast")));
    contrastShader.setFloat('contrast', 0);

    FlxG.camera.filters = [new ShaderFilter(brightnessShader), new ShaderFilter(chromaticShader), new ShaderFilter(contrastShader)];
    camHUD.filters = [new ShaderFilter(chromaticShader)];

    makeCloud();
    new FlxTimer().start(10, (_) -> { makeCloud(); }, 0);
}

function onCreatePost()
{
    if (FlxG.random.bool(50))
        game.triggerEvent('Change Character', 'gf', 'gfc2');

    gfGroup.scrollFactor.set(1, 1);

    blackFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    blackFade.scrollFactor.set();
    blackFade.camera = camHUD;
    blackFade.alpha = 0;
    add(blackFade);
}

function makeCloud()
{
    var cloud:FlxSprite = new FlxSprite(-100, -200).loadGraphic(Paths.image('Park/nube' + FlxG.random.int(1,3)));
    final randomSize:Float = FlxG.random.float(1.5, 2.5);
    cloud.scale.set(randomSize, randomSize); cloud.updateHitbox();
    cloud.alpha = 0.6;
    cloud.scrollFactor.set(0.6, 0.6);
    cloud.velocity.x = FlxG.random.float(40,80);
    insert(game.members.indexOf(floor), cloud);
    new FlxTimer().start(20, (_) -> { cloud.destroy(); });
}

function onEvent(name:String, value1:String, value2:String)
{
    if (name == 'curseContrast')
    {
        var intensity:Float = Std.parseFloat(value1);
        if (Math.isNaN(intensity)) intensity = 0;
        pulseContrast(intensity);
    }
    else if (name == 'curse3d')
    {
        var intensity:Float = Std.parseFloat(value1);
        if (Math.isNaN(intensity)) intensity = 0;
        pulseChromatic(intensity);
    }
    else if (name == 'curseEvent') 
    {
        pulseBrightness();

        switch (value1) 
        {
            case 'tails':
                tails?.animation?.play('anim', true);
                if (tails != null) tails.visible = true;
                fuente?.animation?.play('anim', true);

            case 'noteeffect':
                speedTween?.cancel();
                game.songSpeed = PlayState.SONG.speed * 0.75;
                speedTween = FlxTween.tween(game, {songSpeed: PlayState.SONG.speed}, Conductor.crochet / 2000, {ease: FlxEase.cubeOut});

            case 'evil':
                for (spr in bgSprites) 
                {
                    if (spr != null) 
                    {
                        spr.shader = wavyShader;
                        spr.shader.setFloat('amount', 0.1);
                    }
                }
                if (menuSTATIC != null) menuSTATIC.alpha = 0.4;
                FlxG.camera.flash(0xFF5D4493, 1, null, true);

            case 'normal':
                if (menuSTATIC != null) 
                {
                    remove(menuSTATIC, true);
                    menuSTATIC.destroy();
                    menuSTATIC = null;
                }
                for (spr in bgSprites) 
                {
                    if (spr != null) spr.shader = null;
                }
                FlxG.camera.flash(0xFF5D4493, 1, null, true);
            case 'fadeHUD':
                FlxTween.tween(camHUD, {alpha: 0}, 2);
        }
    }
    else if (name == 'CurseHudFinal')
    {
        if (value1 == 'fadeHUD')
            FlxTween.tween(camHUD, {alpha: 0}, 2);
    }
}

function onUpdatePost(elapsed:Float) 
{
    wavyness += (elapsed * 10);
    
    for (i in 0...bgSprites.length) 
    {
        final spr = bgSprites[i];
        spr?.shader?.setFloat('iTime', wavyness + (i + 1));
    }

    if (tails?.animation?.curAnim?.finished == true && tails?.visible == true) 
    {
        remove(tails, true);
        tails.destroy();
        tails = null;
    }

    if (fuente?.animation?.curAnim?.finished == true && fuente?.animation?.curAnim?.name == 'anim') 
        fuente.animation.play('idle', true);

    if (curBeat >= 180 && curBeat < 244 && !sad) 
    {
        sad = true;
        if (boyfriend != null) boyfriend.idleSuffix = '-sad';
        updateNotesSuffix('-sad');
    }
    
    if (curBeat >= 244 && !happy) 
    {
        happy = true; 
        sad = false;
        if (boyfriend != null) boyfriend.idleSuffix = '-happy';
        updateNotesSuffix('-happy');
    }

    if (boyfriend != null) 
    {
        final curAnim = boyfriend.animation.curAnim;
        if (curAnim?.name == 'idle' && curAnim.curFrame == 0) 
        {
            if (sad) boyfriend.playAnim('idle-sad');
            else if (happy) boyfriend.playAnim('idle-happy');
        }
    }

    updateDadIdle();
    updateBrightnessPulse(elapsed);
    updateChromaticPulse(elapsed);
    updateContrastPulse(elapsed);
}

function updateNotesSuffix(suffix:String):Void 
{
    for (note in game.unspawnNotes) 
        if (note?.mustPress) note.animSuffix = suffix;
        
    for (note in game.notes) 
        if (note?.mustPress) note.animSuffix = suffix;
}

function onSongStart() 
{
    gf?.playAnim('danceLeft', true);
    if (gf != null) gf.danced = false;
}

function onBeatHit() 
{
    beats++;
    if (beats == randomDancer) beats = 0;
    
    if (gf != null) 
    {
        if (beats % randomDancer == 2) 
            gf.playAnim('danceLeftALT', true);
        else if (beats % randomDancer == 3) 
        {
            gf.playAnim('danceRightALT', true);
            randomDancer = dancerValues[FlxG.random.int(0, dancerValues.length - 1)];
        }
        
        if (curBeat >= 180 && curBeat < 244) 
        {
            final animName = 'dance' + ((curBeat % 2 == 0) ? 'Left' : 'Right') + '-sad';
            gf.playAnim(animName, true);
        }
    }
}

function onStepHit()
{
    // negro
    if (curStep == 717)
    {
        blackFadeTween?.cancel();
        blackFadeTween = FlxTween.tween(blackFade, {alpha: 1}, 0.2);
    }
    else if (curStep == 720)
    {
        blackFadeTween?.cancel();
        blackFadeTween = null;
        if (blackFade != null) blackFade.alpha = 0;
    }

    if (curStep == 558)
    {
        dadPhase = 'nervioso';
        if (dad != null) dad.playAnim('2idle', true);
    }
    else if (curStep == 720)
    {
        dadPhase = 'enojado';
        if (dad != null) dad.playAnim('3idle', true);
    }
    else if (curStep == 977)
    {
        dadPhase = 'phase4';
        if (dad != null) dad.playAnim('idle4', true);
    }
    else if (curStep == 1232)
    {
        dadPhase = 'happy';
        if (dad != null) dad.playAnim('idle', true);
    }
    for (d in dancers)
    {
        if (curStep == d.step)
        {
            var anim:String = (d.alt != null) ? d.alt : d.name;
            d.spr.anim.play(anim, true);
        }
    }
}

function getDadIdleAnim():String
{
    if (dadPhase == 'nervioso') return '2idle';
    if (dadPhase == 'enojado') return '3idle';
    if (dadPhase == 'phase4') return 'idle4';
    return 'idle';
}

function updateDadIdle()
{
    if (dad == null || dadPhase == 'happy') return;
    if (dad.specialAnim) return;
    if (dad.getAnimationName() == 'idle')
        dad.playAnim(getDadIdleAnim(), true);
}

function getDadSingAnim(noteData:Int):String
{
    var d:Int = Std.int(Math.abs(noteData)) % 4;
    if (dadPhase == 'nervioso') return ['sing2LEFT', 'sing2DOWN', 'sing2UP', 'sing2RIGHT'][d];
    if (dadPhase == 'enojado') return ['sing3LEFT', 'sing3DOWN', 'sing3UP', 'sing3RIGHT'][d];
    if (dadPhase == 'phase4') return ['sing4LEFT', 'sing4DOWN', 'sing4UP', 'sing4RIGHT'][d];
    return ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][d];
}

function opponentNoteHit(note)
{
    if (dad == null || dadPhase == 'happy') return;
    if (note.gfNote || note.noAnimation || note.noteType == 'Hey!' || note.noteType == 'GF2Sing') return;

    var anim:String = getDadSingAnim(note.noteData);
    if (dad.hasAnimation(anim)) dad.playAnim(anim, true);
}

function pulseBrightness()
{
    brightnessPulseTime = 0;
    if (brightnessShader != null) brightnessShader.setFloat('brightness', 0.3);
}

function updateBrightnessPulse(elapsed:Float)
{
    if (brightnessShader == null || brightnessPulseTime < 0) return;

    brightnessPulseTime += elapsed;

    final peak:Float = 0.3;
    final downTime:Float = 0.7;

    var val:Float = 0;
    if (brightnessPulseTime < downTime)
        val = peak * (1.0 - (brightnessPulseTime / downTime));
    else
        brightnessPulseTime = -1;

    brightnessShader.setFloat('brightness', val);
}

function pulseChromatic(intensity:Float)
{
    chromaticIntensity = intensity;
    chromaticPulseTime = 0;
    if (chromaticShader != null)
    {
        chromaticShader.setFloatArray('rOffset', [intensity, 0]);
        chromaticShader.setFloatArray('gOffset', [0, 0]);
        chromaticShader.setFloatArray('bOffset', [-intensity, 0]);
    }
}

function updateChromaticPulse(elapsed:Float)
{
    if (chromaticShader == null || chromaticPulseTime < 0) return;

    chromaticPulseTime += elapsed;

    final downTime:Float = 0.7;

    var val:Float = 0;
    if (chromaticPulseTime < downTime)
        val = chromaticIntensity * (1.0 - (chromaticPulseTime / downTime));
    else
        chromaticPulseTime = -1;

    chromaticShader.setFloatArray('rOffset', [val, 0]);
    chromaticShader.setFloatArray('gOffset', [0, 0]);
    chromaticShader.setFloatArray('bOffset', [-val, 0]);
}

function pulseContrast(intensity:Float)
{
    contrastTarget = intensity;
    contrastFrom = contrastValue;
    contrastTweenTime = 0;
}

function updateContrastPulse(elapsed:Float)
{
    if (contrastShader == null || contrastTweenTime < 0) return;

    contrastTweenTime += elapsed;

    final tweenDur:Float = 0.2;

    var p:Float = contrastTweenTime / tweenDur;
    if (p >= 1.0)
    {
        p = 1.0;
        contrastTweenTime = -1;
    }

    contrastValue = contrastFrom + (contrastTarget - contrastFrom) * p;
    contrastShader.setFloat('contrast', contrastValue);
}