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

var floor:FlxSprite;
var tails:FlxSprite;
var fuente:FlxSprite;
var menuSTATIC:VideoSprite;

final bgSprites:Array<FlxSprite> = [];

var speedTween:FlxTween = null;

function onCreate()
{
    var sky:FlxSprite = new FlxSprite(-750, -350).loadGraphic(Paths.image('Park/city'));
    sky.scale.set(1.2, 1.2); sky.updateHitbox();
    sky.scrollFactor.set(0.6, 0.6);
    addBehindGF(sky);

    floor = new FlxSprite(-900, -250).loadGraphic(Paths.image('Park/bg'));
    floor.scale.set(1.2, 1.2); floor.updateHitbox();
    addBehindGF(floor);

    fuente = new FlxSprite(-80, -90);
    fuente.frames = Paths.getSparrowAtlas('Park/fountain');
    fuente.animation.addByPrefix('idle', 'fountain', 12, true);
    fuente.animation.play('idle', true);
    fuente.scale.set(1.2, 1.2);
    addBehindGF(fuente);

    menuSTATIC = new VideoSprite();
    if (menuSTATIC.loadVideo(Paths.video('STATIC'), [VideoSprite.ARG_LOOPING, VideoSprite.ARG_MUTED])) menuSTATIC.playDelayed();
    menuSTATIC.scale.set((FlxG.width / menuSTATIC.width) * 1.5, (FlxG.height / menuSTATIC.height) * 1.5);
    menuSTATIC.screenCenter();
    menuSTATIC.x -= 650;
    menuSTATIC.y -= 50;
    menuSTATIC.alpha = 0.00001;
    addBehindGF(menuSTATIC);

    var fore:FlxSprite = new FlxSprite(-1000, -200).loadGraphic(Paths.image('Park/foreground'));
    fore.scale.set(1.2, 1.2); fore.updateHitbox();
    fore.scrollFactor.set(1.3, 1.3);
    add(fore);

    wavyShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment("wavyDistortion")));

    makeCloud();
    new FlxTimer().start(10, (_) -> { makeCloud(); }, 0);
}

function onCreatePost()
{
    if (FlxG.random.bool(50))
        game.triggerEvent('Change Character', 'gf', 'gfc2');

    gfGroup.scrollFactor.set(1, 1);
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