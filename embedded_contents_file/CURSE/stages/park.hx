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

var sad:Bool = false;
var happy:Bool = false;

var sky:FlxSprite;
var city:FlxSprite;
var floor:FlxSprite;
var trees2:FlxSprite;
var trees1:FlxSprite;
var tails:FlxSprite;
var fuente:FlxSprite;
var menuSTATIC:VideoSprite;

final bgSprites:Array<FlxSprite> = [];

var speedTween:FlxTween = null;

function onCreate()
{
    sky = new FlxSprite(-700, -370).loadGraphic(Paths.image('Park/sky'));
    sky.scale.set(0.8, 0.8);
    sky.updateHitbox();
    sky.scrollFactor.set(0.5, 0.5);
    addBehindGF(sky);
    bgSprites.push(sky);

    city = new FlxSprite(-800, -370).loadGraphic(Paths.image('Park/city'));
    city.scale.set(0.8, 0.8);
    city.updateHitbox();
    city.scrollFactor.set(0.7, 0.7);
    addBehindGF(city);
    bgSprites.push(city);

    floor = new FlxSprite(-900, -370).loadGraphic(Paths.image('Park/floor'));
    floor.scale.set(0.8, 0.8);
    floor.updateHitbox();
    addBehindGF(floor);
    bgSprites.push(floor);

    trees2 = new FlxSprite(-900, -370).loadGraphic(Paths.image('Park/trees2'));
    trees2.scale.set(0.8, 0.8);
    trees2.updateHitbox();
    addBehindGF(trees2);
    bgSprites.push(trees2);

    trees1 = new FlxSprite(-900, -370).loadGraphic(Paths.image('Park/trees1'));
    trees1.scale.set(0.8, 0.8);
    trees1.updateHitbox();
    addBehindGF(trees1);
    bgSprites.push(trees1);
    
    tails = new FlxSprite(-1796, 100);
    tails.frames = Paths.getSparrowAtlas('Park/tails');
    tails.animation.addByPrefix('anim', 'tails instancia 1', 24, false);
    tails.scale.set(0.37, 0.37);
    tails.updateHitbox();
    tails.visible = false;
    addBehindGF(tails);

    fuente = new FlxSprite(-50, 50);
    fuente.frames = Paths.getSparrowAtlas('Park/fuente');
    fuente.animation.addByIndices('idle', 'anim instancia 1', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], "", 24, true);
    fuente.animation.addByPrefix('anim', 'anim instancia 1', 24, false);
    fuente.animation.play('idle', true);
    fuente.scale.set(0.37, 0.37);
    fuente.updateHitbox();
    addBehindGF(fuente);

    menuSTATIC = new VideoSprite();
    if (menuSTATIC.loadVideo(Paths.video('STATIC'), [VideoSprite.ARG_LOOPING, VideoSprite.ARG_MUTED])) menuSTATIC.playDelayed();
    menuSTATIC.scale.set((FlxG.width / menuSTATIC.width) * 1.5, (FlxG.height / menuSTATIC.height) * 1.5);
    menuSTATIC.screenCenter();
    menuSTATIC.x -= 650;
    menuSTATIC.y -= 50;
    menuSTATIC.alpha = 0.00001;
    addBehindGF(menuSTATIC);

    wavyShader = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment("wavyDistortion")));
}

function onCreatePost()
{
    if (FlxG.random.bool(50)) 
        game.triggerEvent('Change Character', 'gf', 'gfc2');
}

function onEvent(name:String, value1:String, value2:String)
{
    if (name == 'curseEvent') 
    {
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