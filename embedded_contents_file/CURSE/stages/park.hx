import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

import psychlua.LuaUtils;

final dancerValues:Array<Int> = [32, 28, 24, 20, 16, 12, 8];

var randomDancer:Int = 32;
var beats:Int = 0;
var wavyShader:FlxRuntimeShader;
var wavyShaderHUD:FlxRuntimeShader;
var wavyness:Float = 0.0;
var wavynessMult:Float = 1;

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

var glitchShader:FlxRuntimeShader;
var glitchTime:Float = 0;
var glitchAMT:Float = 0;
var glitchPhase:Int = -1;
var glitchPhaseTime:Float = 0;
var glitchFrom:Float = 0;
var glitchTarget:Float = 0;
var glitchInDur:Float = 0;
var glitchOutDur:Float = 0;

var sad:Bool = false;
var happy:Bool = false;

var sky:FlxSprite;
var floor:FlxSprite;
var tails:FlxSprite;
var fuente:FlxSprite;
var fore:FlxSprite;

var cstatic:FlxSprite;
var vinete:FlxSprite;
var bv:FlxSprite;

var blackFade:FlxSprite;
var blackFadeTween:FlxTween = null;

var colorPulse:FlxSprite;
var colorPulseTween:FlxTween = null;

final bgSprites:Array<FlxSprite> = [];
var clouds:Array<FlxSprite> = [];
var cloudsAlpha:Float = 0.6;

var speedTween:FlxTween = null;

var dadPhase:String = 'happy';

// BG chars
var dancers:Array<Dynamic> = [];
var tails1:FlxAnimate;
var tails2:FlxAnimate;
var knux:FlxAnimate;
var rata:FlxAnimate;
var vieja:FlxAnimate;
var idle:FlxAnimate;
var idleconejos:FlxAnimate;
var oso:FlxAnimate;
var eggman:FlxAnimate;
var phase4Copy:Character = null;
var phase4DadTween:FlxTween = null;
var phase4CopyTween:FlxTween = null;
var phase4Active:Bool = false;
var cursetweenSprites:Array<FlxSprite> = [];
var cursetweenTweens:Array<FlxTween> = [];
var vineteTween:FlxTween = null;
var vineteTarget:Float = 0;
var vineteUpDur:Float = 1;
var vineteDownDur:Float = 0.2;

var talkOffsetX:Float = 65;
var talkOffsetY:Float = 6;
var conversandoOffsetX:Float = 0;
var conversandoOffsetY:Float = 8;
var idleBaseOffX:Float = 0;
var idleBaseOffY:Float = 0;
var idleconejosBaseOffX:Float = 0;
var idleconejosBaseOffY:Float = 0;
var lastTalker:String = 'idleconejos';

function makeDancer(name:String, alt:String, x:Float, y:Float, step:Int, scale:Float = 1, alpha:Float = 1)
{
    var spr:FlxAnimate = new FlxAnimate(x, y);
    spr.frames = Paths.getAnimateAtlas('Park/Characters');
    spr.antialiasing = ClientPrefs.data.antialiasing;

    spr.anim.addBySymbol(name, name, 24, true);
    if (alt != null) spr.anim.addBySymbol(alt, alt, 24, false);
    spr.anim.play(name, true);

    spr.scale.set(scale, scale);
    spr.updateHitbox();
    spr.alpha = alpha;

    insert(game.members.indexOf(fuente), spr);

    dancers.push({ spr: spr, name: name, alt: alt, step: step });
    return spr;
}

function playDancerAnim(spr:FlxAnimate, anim:String)
{
    if (spr == null) return;
    spr.anim.play(anim, true);
    if (spr == idleconejos)
    {
        if (anim == 'talk') spr.offset.set(idleconejosBaseOffX + talkOffsetX, idleconejosBaseOffY + talkOffsetY);
        else spr.offset.set(idleconejosBaseOffX, idleconejosBaseOffY);
    }
    else if (spr == idle)
    {
        if (anim == 'conversando') spr.offset.set(idleBaseOffX + conversandoOffsetX, idleBaseOffY + conversandoOffsetY);
        else spr.offset.set(idleBaseOffX, idleBaseOffY);
    }
}

function isTalking():Bool
{
    return (idle != null && idle.anim.curAnim != null && idle.anim.curAnim.name == 'conversando')
        || (idleconejos != null && idleconejos.anim.curAnim != null && idleconejos.anim.curAnim.name == 'talk');
}

function startTalk()
{
    if (isTalking()) return;

    if (lastTalker == 'idleconejos')
    {
        lastTalker = 'idle';
        if (idle != null) playDancerAnim(idle, 'conversando');
    }
    else
    {
        lastTalker = 'idleconejos';
        if (idleconejos != null) playDancerAnim(idleconejos, 'talk');
    }
}

function updateTalkRevert()
{
    if (idle != null && idle.anim.curAnim != null && idle.anim.curAnim.name == 'conversando' && idle.anim.curAnim.finished)
    {
        playDancerAnim(idle, 'idle');
        startTalk();
    }
    if (idleconejos != null && idleconejos.anim.curAnim != null && idleconejos.anim.curAnim.name == 'talk' && idleconejos.anim.curAnim.finished)
    {
        playDancerAnim(idleconejos, 'idleconejos');
        startTalk();
    }
}

function onCreate()
{
    dadPhase = 'nervioso';
    if (dad != null) dad.playAnim('2idle', true);

    sky = new FlxSprite(-950, -450).loadGraphic(Paths.image('Park/city'));
    sky.scale.set(0.86, 0.86); sky.updateHitbox();
    sky.scrollFactor.set(0.6, 0.6);
    addBehindGF(sky);
    bgSprites.push(sky);

    floor = new FlxSprite(-1240, -365).loadGraphic(Paths.image('Park/bg'));
    floor.scale.set(0.86, 0.86); floor.updateHitbox();
    addBehindGF(floor);
    bgSprites.push(floor);

    fuente = new FlxSprite(-80, -90);
    fuente.frames = Paths.getSparrowAtlas('Park/fountain');
    fuente.animation.addByPrefix('idle', 'fountain', 12, true);
    fuente.animation.play('idle', true);
    fuente.scale.set(1.2, 1.2);
    addBehindGF(fuente);

    rata = makeDancer('rata', null, 1150, 140, 100, 0.4, 1);
    oso = makeDancer('oso', null, 650, 50, 100, 0.725, 1);
    vieja = makeDancer('vieja', null, 1230, 200, 20, 0.6, 1);
    idle = makeDancer('idle', 'conversando', -1050, 140, 20, 0.6, 1);
    idleconejos = makeDancer('idleconejos', 'talk', -780, 160, 70, 0.56, 1);
    tails1 = makeDancer('tails1', null, -370, 70, 20, 0.6, 1);
    tails2 = makeDancer('tails2', null, -378, 59, 0, 0.6, 0);
    eggman = makeDancer('eggman', null, -1030, 30, 0, 0.85, 0);
    knux = makeDancer('knux', null, 824, 56, 0, 0.8, 0);

    idleBaseOffX = idle.offset.x; idleBaseOffY = idle.offset.y;
    idleconejosBaseOffX = idleconejos.offset.x; idleconejosBaseOffY = idleconejos.offset.y;

    cstatic = new FlxSprite();
    cstatic.frames = Paths.getSparrowAtlas('Park/staticurse');
    cstatic.animation.addByPrefix('menuSTATICNEW instance 1', 'menuSTATICNEW instance 1', 24, true);
    cstatic.animation.play('menuSTATICNEW instance 1', true);
    cstatic.scale.set((FlxG.width / cstatic.width) * 2.4, (FlxG.height / cstatic.height) * 2.4);
    cstatic.updateHitbox();
    cstatic.screenCenter();
    cstatic.x -= 380;
    cstatic.y -= -120;
    cstatic.alpha = 0.00001;
    addBehindGF(cstatic);

    fore = new FlxSprite(-1500, 600).loadGraphic(Paths.image('Park/foreground'));
    fore.scale.set(0.6, 0.6); fore.updateHitbox();
    fore.scrollFactor.set(1.25, 1.25);
    add(fore);

    wavyShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("wavyDistortion")));
    wavyShaderHUD = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("wavyDistortion")));

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

    glitchShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("glitch")));
    glitchShader.setFloat('AMT', 0);
    glitchShader.setFloat('SPEED', 1);
    glitchShader.setFloat('iTime', 0);

    FlxG.camera.filters = [new ShaderFilter(wavyShader), new ShaderFilter(brightnessShader), new ShaderFilter(chromaticShader), new ShaderFilter(contrastShader), new ShaderFilter(glitchShader)];
    camHUD.filters = [new ShaderFilter(chromaticShader), new ShaderFilter(wavyShaderHUD)];

    makeCloud();
    new FlxTimer().start(10, (_) -> { makeCloud(); }, 0);
    startTalk();
}

function onCreatePost()
{
    if (FlxG.random.bool(50))
        game.triggerEvent('Change Character', 'gf', 'gfc2');

    gfGroup.scrollFactor.set(1, 1);
    gf.updateHitbox();

    blackFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    blackFade.scrollFactor.set();
    blackFade.camera = camHUD;
    blackFade.alpha = 0;
    add(blackFade);

    vinete = new FlxSprite().loadGraphic(Paths.image('Park/vg'));
    vinete.setGraphicSize(FlxG.width, FlxG.height);
    vinete.updateHitbox();
    vinete.scrollFactor.set();
    vinete.camera = camHUD;
    vinete.alpha = 0.00001;
    vinete.screenCenter();
    insert(game.members.indexOf(blackFade), vinete);

    bv = new FlxSprite().loadGraphic(Paths.image('Park/black_vignette'));
    bv.setGraphicSize(FlxG.width, FlxG.height);
    bv.updateHitbox();
    bv.scrollFactor.set();
    bv.camera = camHUD;
    bv.alpha = 0.00001;
    bv.screenCenter();
    insert(game.members.indexOf(blackFade), bv);

    colorPulse = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
    colorPulse.scrollFactor.set();
    colorPulse.camera = camHUD;
    colorPulse.alpha = 0;
    colorPulse.screenCenter();
    insert(game.members.indexOf(blackFade), colorPulse);

    makePhase4Copy();
}

function makePhase4Copy()
{
    if (dad == null || phase4Copy != null) return;

    phase4Copy = new Character(dad.x - dadGroup.x, dad.y - dadGroup.y, dad.curCharacter, false);
    phase4Copy.scale.set(dad.scale.x, dad.scale.y);
    phase4Copy.flipX = dad.flipX;
    phase4Copy.scrollFactor.set(dad.scrollFactor.x, dad.scrollFactor.y);
    phase4Copy.alpha = 0.00001;
    dadGroup.add(phase4Copy);
    phase4Copy.playAnim('idle4', true);
    if (phase4Copy.anim.curAnim != null) phase4Copy.anim.curAnim.looped = true;
    phase4Copy.singDuration = 999999.0;
}
function phase4(dadAlpha:Float, copyAlpha:Float, duration:Float)
{
    if (dad == null) return;
    if (phase4Copy == null) makePhase4Copy();
    if (phase4Copy == null) return;

    if (phase4DadTween != null && phase4DadTween.active) phase4DadTween.cancel();
    if (phase4CopyTween != null && phase4CopyTween.active) phase4CopyTween.cancel();

    if (duration <= 0)
    {
        dad.alpha = dadAlpha;
        phase4Copy.alpha = copyAlpha;
        phase4DadTween = null;
        phase4CopyTween = null;
    }
    else
    {
        phase4DadTween = FlxTween.tween(dad, {alpha: dadAlpha}, duration, {ease: FlxEase.linear});
        phase4CopyTween = FlxTween.tween(phase4Copy, {alpha: copyAlpha}, duration, {ease: FlxEase.linear});
    }

    phase4Active = (copyAlpha > 0.5);
    if (phase4Active && phase4Copy.getAnimationName() != 'idle4')
        phase4Copy.playAnim('idle4', true);
}

function updatePhase4Idle()
{
    if (phase4Copy == null || phase4Copy.alpha <= 0.01) return;
    if (phase4Copy.specialAnim) return;

    final n:String = phase4Copy.getAnimationName();
    if (n == 'idle' || (n == 'idle4' && phase4Copy.isAnimationFinished()))
        phase4Copy.playAnim('idle4', true);
    else if ((n == 'sing4LEFT' || n == 'sing4DOWN' || n == 'sing4UP' || n == 'sing4RIGHT') && phase4Copy.isAnimationFinished())
        phase4Copy.playAnim('idle4', true);
}

function getPhase4SingAnim(noteData:Int):String
{
    var d:Int = Std.int(Math.abs(noteData)) % 4;
    return ['sing4LEFT', 'sing4DOWN', 'sing4UP', 'sing4RIGHT'][d];
}

function cursetween(spr:FlxSprite, alpha:Float, duration:Float, ?color:Int)
{
    if (spr == null) return;

    final idx:Int = cursetweenSprites.indexOf(spr);
    if (idx >= 0)
    {
        final prev:FlxTween = cursetweenTweens[idx];
        if (prev != null && prev.active) prev.cancel();
        cursetweenSprites.splice(idx, 1);
        cursetweenTweens.splice(idx, 1);
    }

    if (color != null) spr.color = color;

    if (alpha > 0) spr.visible = true;

    final t:FlxTween = FlxTween.tween(spr, {alpha: alpha}, duration, {
        ease: FlxEase.linear,
        onComplete: (_) -> { if (alpha <= 0) spr.visible = false; }
    });
    cursetweenSprites.push(spr);
    cursetweenTweens.push(t);
}

function cursetween2(target:Float, upDuration:Float, downDuration:Float, ?color:Int)
{
    if (vinete == null) return;
    if (vineteTween != null && vineteTween.active) vineteTween.cancel();

    vineteTarget = target;
    vineteUpDur = upDuration;
    vineteDownDur = downDuration;

    if (color != null) vinete.color = color;

    if (vineteUpDur <= 0)
    {
        vinete.alpha = vineteTarget;
        tweenVineteDown();
    }
    else
    {
        tweenVineteUp();
    }
}

function tweenVineteUp()
{
    vineteTween = FlxTween.tween(vinete, {alpha: vineteTarget}, vineteUpDur, {
        ease: FlxEase.linear,
        onComplete: (_) -> { tweenVineteDown(); }
    });
}

function tweenVineteDown()
{
    if (vineteDownDur <= 0)
    {
        vinete.alpha = 0;
        vineteTween = null;
        return;
    }

    vineteTween = FlxTween.tween(vinete, {alpha: 0}, vineteDownDur, {
        ease: FlxEase.linear,
        onComplete: (_) -> { vineteTween = null; }
    });
}

function makeCloud()
{
    var cloud:FlxSprite = new FlxSprite(-100, -200).loadGraphic(Paths.image('Park/nube' + FlxG.random.int(1,3)));
    final randomSize:Float = FlxG.random.float(1.5, 2.5);
    cloud.scale.set(randomSize, randomSize); cloud.updateHitbox();
    cloud.alpha = cloudsAlpha;
    cloud.scrollFactor.set(0.6, 0.6);
    cloud.velocity.x = FlxG.random.float(40,80);
    insert(game.members.indexOf(floor), cloud);
    clouds.push(cloud);
    new FlxTimer().start(20, (_) -> { clouds.remove(cloud); cloud.destroy(); });
}

function cursetweenClouds(alpha:Float, duration:Float, ?color:Int)
{
    cloudsAlpha = alpha;
    for (c in clouds)
        if (c != null && c.exists) cursetween(c, alpha, duration, color);
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
    else if (name == 'curseglitch')
    {
        var parts:Array<String> = value1.split(',');
        var intensity:Float = 0;
        var inDur:Float = 0;
        var outDur:Float = 0;
        if (parts.length > 0) intensity = Std.parseFloat(StringTools.trim(parts[0]));
        if (parts.length > 1) inDur = Std.parseFloat(StringTools.trim(parts[1]));
        if (parts.length > 2) outDur = Std.parseFloat(StringTools.trim(parts[2]));
        if (Math.isNaN(intensity)) intensity = 0;
        if (Math.isNaN(inDur)) inDur = 0;
        if (Math.isNaN(outDur)) outDur = 0;
        pulseGlitch(intensity, inDur, outDur);
    }
    else if (name == 'curseEvent') 
    {
        switch (value1) 
        {
            case '':
            pulseBrightness();
            
            case 'tails': //scrapped
                tails?.animation?.play('anim', true);
                if (tails != null) tails.visible = true;
                fuente?.animation?.play('anim', true);
                pulseBrightness();
            case 'noteeffect':
                speedTween?.cancel();
                game.songSpeed = PlayState.SONG.speed * 0.75;
                speedTween = FlxTween.tween(game, {songSpeed: PlayState.SONG.speed}, Conductor.crochet / 2000, {ease: FlxEase.cubeOut});
                pulseBrightness();
            case 'evil':
                if (cstatic != null) cstatic.alpha = 1;
                FlxG.camera.flash(0xFF5D4493, 1, null, true);

            case 'normal':
                if (cstatic != null) 
                {
                    remove(cstatic, true);
                    cstatic.destroy();
                    cstatic = null;
                }
                FlxG.camera.flash(0xFF5D4493, 1, null, true);
            case 'fadeHUD':
                FlxTween.tween(camHUD, {alpha: 0}, 2);
                pulseBrightness();
        }
    }
    else if (name == 'curseEvent2') 
    {
        switch (value1) 
        {
            case 'noteeffect':
                speedTween?.cancel();
                game.songSpeed = PlayState.SONG.speed * 0.75;
                speedTween = FlxTween.tween(game, {songSpeed: PlayState.SONG.speed}, Conductor.crochet / 2000, {ease: FlxEase.cubeOut});
                cursetween2(0.7, 0, 0.6, 0xFF5100FF);
                pulseColor(0xFF4600DE, 0.25, 0.7);
        }
    }

    else if (name == 'cursetweencamera')
    {
        var split = value1.split(',');
        if (split.length >= 2)
        {
            var camx = Std.parseFloat(StringTools.trim(split[0]));
            var camy = Std.parseFloat(StringTools.trim(split[1]));
            if (Math.isNaN(camx)) camx = 0;
            if (Math.isNaN(camy)) camy = 0;

            var split2 = value2.split(',');
            if (split2.length >= 2)
            {
                var time = Std.parseFloat(StringTools.trim(split2[0]));
                var ease = StringTools.trim(split2[1]);
                if (Math.isNaN(time)) time = 0;

                FlxTween.tween(camGame.targetOffset, {x: camx, y: camy}, time, {ease: LuaUtils.getTweenEaseByString(ease)});
            }
        }
        gameplayCam.customCameraEnabled = false;
        gameplayCam.isCameraOnForcedPos = true;
    }
    else if (name == 'CurseHudFinal')
    {
        if (value1 == 'fadeHUD')
            FlxTween.tween(camHUD, {alpha: 0}, 2);
    }
}

function onUpdatePost(elapsed:Float) 
{
    wavyness += (elapsed * wavynessMult);
    wavyShader.setFloat('iTime', wavyness);
    wavyShaderHUD.setFloat('iTime', wavyness);

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
    updatePhase4Idle();
    updateTalkRevert();
    updateBrightnessPulse(elapsed);
    updateChromaticPulse(elapsed);
    updateContrastPulse(elapsed);
    updateGlitch(elapsed);
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
    updateDadHold();

    switch (curStep)
    {
        // negro
        case 717:
            blackFadeTween?.cancel();
            blackFadeTween = FlxTween.tween(blackFade, {alpha: 1}, 0.2);

        case 720: //720
            blackFadeTween?.cancel();
            blackFadeTween = null;
            if (blackFade != null) blackFade.alpha = 0;

            dadPhase = 'enojado';
            if (dad != null) dad.playAnim('3idle', true);

            cursetween(tails1, 0, 0.1);
            cursetween(vieja, 0, 0.1);
            cursetween(idle, 0, 0.1);
            cursetween(idleconejos, 0, 0.1);
            cursetween(oso, 0, 0.1);
            cursetween(rata, 0, 0.1);
            cursetween(fuente, 0.1, 0.2);
            cursetween(floor, 0.2, 0.2);
            cursetween(sky, 0, 0.2);
            cursetween(fore, 0, 0.2);
            cursetween(bv, 0.2, 1, 0xFF5100FF);
            cursetween2(1, 0.2, 1, 0xFF5100FF);
            cursetweenClouds(0.1, 0.2);

        case 780:
        cursetween(bv, 0.5, 0.2, 0xFF5100FF);

        case 832:
        cursetween(bv, 0.7, 0.2, 0xFF5100FF);

        case 848:
        cursetween(bv, 0.5, 0.1, 0xFF5100FF);

        case 908:
        cursetween(bv, 0.7, 0.1, 0xFF5100FF);

        case 944:
        cursetween(bv, 0.9, 0.2, 0xFF5100FF);

        case 960:
        cursetween(bv, 0.5, 0.2, 0xFF5100FF);
            
        case 558:
            dadPhase = 'nervioso';
            if (dad != null) dad.playAnim('2idle', true);
            FlxTween.num(0.0, 0.3, 2, null, val -> wavyShader.setFloat('amount', val));
            FlxTween.num(0.0, 0.3, 2, null, val -> wavyShaderHUD.setFloat('amount', val));

        case 752:
            cursetween(cstatic, 0.6, 0.7);

        case 784:
            cursetween(cstatic, 1, 0.7);

        case 816:
            cursetween(cstatic, 0.5, 0.5);
            
        case 847:
            cursetween(cstatic, 1, 0.7);

        case 878:
            cursetween(cstatic, 0.5, 0.5);

        case 910:
            cursetween(cstatic, 1, 0.7);

        case 976:
            phase4(0, 1, 0.01);
            cursetween(cstatic, 0.5, 0.1);
            cursetween(eggman, 1, 0.1);
            cursetween(knux, 1, 0.1);
            cursetween(tails2, 1, 0.1);
            cursetween(fuente, 0.1, 0.2);
            cursetween(floor, 0.2, 0.2);
            cursetween(fore, 0.1, 0.2);
            cursetween(bv, 1, 1, 0xFF7029FF);
            cursetween2(1, 0.2, 1, 0xFF31009C);
            cursetweenClouds(0.2, 0.3);

        case 992, 1024, 1056, 1088, 1120, 1152, 1184:
            cursetween(cstatic, 0.9, 0.7);

        case 1008, 1040, 1072, 1104, 1136, 1168, 1200:
            cursetween(cstatic, 0.5, 0.6);

        case 1170:
            dadPhase = 'happy';
            if (dad != null) dad.playAnim('idle', true);


        case 1231:
            phase4(1, 0, 0.1);
            cursetween(eggman, 0, 0.1);
            cursetween(knux, 0, 0.1);
            cursetween(tails2, 0, 0.1);

            FlxTween.num(0.3, 0.0, 0.2, null, val -> wavyShader.setFloat('amount', val));
            FlxTween.num(0.3, 0.0, 0.2, null, val -> wavyShaderHUD.setFloat('amount', val));
            cursetween(cstatic, 0, 0.1);
            cursetween(vieja, 1, 0.1);
            cursetween(idle, 1, 0.1);
            cursetween(idleconejos, 1, 0.1);
            cursetween(oso, 1, 0.1);
            cursetween(rata, 1, 0.1);
            cursetween(fuente, 1, 0.1);
            cursetween(floor, 1, 0.1);
            cursetween(sky, 1, 0.1);
            cursetween(fore, 1, 0.1);
            cursetween(bv, 0, 0.1, 0xFF7029FF);
            cursetweenClouds(1, 0.1);

        case 1216:
            pulseBrightness();
    }

    var talkTriggered:Bool = false;
    for (d in dancers)
    {
        if (curStep == d.step)
        {
            if (d.spr == idle || d.spr == idleconejos)
            {
            if (!talkTriggered)
            {
                startTalk();
                talkTriggered = true;
            }
            }
            else
            {
                var anim:String = (d.alt != null) ? d.alt : d.name;
                playDancerAnim(d.spr, anim);
            }
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
    if (note.gfNote || note.noAnimation || note.noteType == 'Hey!' || note.noteType == 'GF2Sing') return;
    if (phase4Copy != null && phase4Copy.alpha > 0.01)
    {
        var p4anim:String = getPhase4SingAnim(note.noteData);
        if (phase4Copy.hasAnimation(p4anim))
        {
            phase4Copy.playAnim(p4anim, true);
            phase4Copy.holdTimer = 0;
        }
    }
    if (dad != null && dadPhase != 'happy' && dad.alpha > 0.01)
    {
        var anim:String = getDadSingAnim(note.noteData);
        if (dad.hasAnimation(anim)) dad.playAnim(anim, true);
    }
}

function pulseBrightness()
{
    brightnessPulseTime = 0;
    if (brightnessShader != null) brightnessShader.setFloat('brightness', 0.3);
}

function pulseColor(color:Int = 0xFF5100FF, alpha:Float = 0.3, duration:Float = 0.7)
{
    if (colorPulse == null) return;
    if (colorPulseTween != null && colorPulseTween.active) colorPulseTween.cancel();

    colorPulse.color = color;
    colorPulse.alpha = alpha;
    if (duration > 0)
        colorPulseTween = FlxTween.tween(colorPulse, {alpha: 0}, duration, {ease: FlxEase.linear});
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

function pulseGlitch(intensity:Float, inDur:Float, outDur:Float)
{
    if (glitchShader == null) return;

    if (intensity <= 0)
    {
        glitchPhase = -1;
        glitchPhaseTime = 0;
        glitchAMT = 0;
        glitchFrom = 0;
        glitchTarget = 0;
        glitchInDur = 0;
        glitchOutDur = 0;
        glitchShader.setFloat('AMT', 0);
        return;
    }

    glitchTarget = intensity;
    glitchInDur = inDur;
    glitchOutDur = outDur;
    glitchFrom = glitchAMT;
    glitchPhaseTime = 0;

    if (inDur <= 0)
    {
        glitchAMT = intensity;
        glitchShader.setFloat('AMT', glitchAMT);

        if (outDur > 0)
        {
            glitchPhase = 1;
            glitchFrom = intensity;
            glitchPhaseTime = 0;
        }
        else
        {
            glitchPhase = -1;
        }
    }
    else
    {
        glitchPhase = 0;
    }
}

function updateGlitch(elapsed:Float)
{
    if (glitchShader == null) return;

    glitchTime += elapsed;
    glitchShader.setFloat('iTime', glitchTime);

    if (glitchPhase < 0) return;

    glitchPhaseTime += elapsed;

    if (glitchPhase == 0)
    {
        final p:Float = (glitchInDur <= 0) ? 1.0 : (glitchPhaseTime / glitchInDur);
        if (p >= 1.0)
        {
            glitchAMT = glitchTarget;
            if (glitchOutDur > 0)
            {
                glitchPhase = 1;
                glitchPhaseTime = 0;
                glitchFrom = glitchTarget;
            }
            else
            {
                glitchPhase = -1;
            }
        }
        else
        {
            glitchAMT = glitchFrom + (glitchTarget - glitchFrom) * p;
        }
        glitchShader.setFloat('AMT', glitchAMT);
    }
    else if (glitchPhase == 1)
    {
        final p:Float = (glitchOutDur <= 0) ? 1.0 : (glitchPhaseTime / glitchOutDur);
        if (p >= 1.0)
        {
            glitchAMT = 0;
            glitchPhase = -1;
        }
        else
        {
            glitchAMT = glitchFrom * (1.0 - p);
        }
        glitchShader.setFloat('AMT', glitchAMT);
    }
}

function updateDadHold()
{
    if (phase4Copy != null) phase4Copy.singDuration = 999999.0;
}
