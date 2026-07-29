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
    sky = new FlxSprite(-700, -800).loadGraphic(Paths.image('Park/cielo'));
    sky.scale.set(1.4, 1.4);
    sky.scrollFactor.set(1, 1);
    sky.antialiasing = true;
    sky.visible = true;
    addBehindGF(sky);

    var nube1:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Park/nube1'));
    nube1.scrollFactor.set(0.2, 0.2);
    nube1.antialiasing = true;
    nube1.visible = false;
    addBehindGF(nube1);

    var nube2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Park/nube2'));
    nube2.scrollFactor.set(0.25, 0.25);
    nube2.antialiasing = true;
    nube2.visible = false;
    addBehindGF(nube2);

    var nube3:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Park/nube3'));
    nube3.scrollFactor.set(0.3, 0.3);
    nube3.antialiasing = true;
    nube3.visible = false;
    addBehindGF(nube3);

    var edificios:FlxSprite = new FlxSprite(-700, -300).loadGraphic(Paths.image('Park/Edificios'));
    edificios.scrollFactor.set(1, 1);
    edificios.scale.set(1.4, 1.4);
    edificios.antialiasing = true;
    edificios.visible = true;
    addBehindGF(edificios);

    var postes:FlxSprite = new FlxSprite(-700, -200).loadGraphic(Paths.image('Park/postes'));
    postes.scrollFactor.set(1, 1);
    postes.scale.set(2.5, 2.5);
    postes.antialiasing = true;
    postes.visible = false;
    addBehindGF(postes);

    var fondodetrasarboles:FlxSprite = new FlxSprite(-700, 125).loadGraphic(Paths.image('Park/fondodetrasarboles'));
    fondodetrasarboles.scrollFactor.set(1, 1);
    fondodetrasarboles.scale.set(1.6, 1.6);
    fondodetrasarboles.antialiasing = true;
    fondodetrasarboles.visible = true;
    addBehindGF(fondodetrasarboles);

    var suelo:FlxSprite = new FlxSprite(-700, 200).loadGraphic(Paths.image('Park/Suelo'));
    suelo.scale.set(1.4, 1.4);
    suelo.scrollFactor.set(1, 1);
    suelo.antialiasing = true;
    addBehindGF(suelo);

    var arbolesfondo:FlxSprite = new FlxSprite(-330, -30).loadGraphic(Paths.image('Park/ArbolesFondo'));
    arbolesfondo.scrollFactor.set(1, 1);
    arbolesfondo.scale.set(1.4, 1.4);
    arbolesfondo.antialiasing = true;
    arbolesfondo.visible = true;
    addBehindGF(arbolesfondo);

    var arbolesatras:FlxSprite = new FlxSprite(-360, -100).loadGraphic(Paths.image('Park/ArbolesAtras'));
    arbolesatras.scrollFactor.set(1, 1);
    arbolesatras.scale.set(1.4, 1.4);
    arbolesatras.antialiasing = true;
    arbolesatras.visible = true;
    addBehindGF(arbolesatras);

    var arbustoatras:FlxSprite = new FlxSprite(-700, -150).loadGraphic(Paths.image('Park/Arbustos atras'));
    arbustoatras.scrollFactor.set(1, 1);
    arbustoatras.scale.set(1.4, 1.4);
    arbustoatras.antialiasing = true;
    arbustoatras.visible = true;
    addBehindGF(arbustoatras);

    var arboles:FlxSprite = new FlxSprite(-700, -260).loadGraphic(Paths.image('Park/Arboles'));
    arboles.scrollFactor.set(1, 1);
    arboles.scale.set(1.4, 1.4);
    arboles.antialiasing = true;
    arboles.visible = true;
    addBehindGF(arboles);

    var arbusto:FlxSprite = new FlxSprite(-700, 183).loadGraphic(Paths.image('Park/arbusto'));
    arbusto.scrollFactor.set(1, 1);
    arbusto.scale.set(1.4, 1.4);
    arbusto.antialiasing = true;
    arbusto.visible = true;
    addBehindGF(arbusto);

    fuente = new FlxSprite(-50, -90);
    fuente.frames = Paths.getSparrowAtlas('Park/fountain');
    fuente.animation.addByPrefix('idle', 'fountain', 12, true);
    fuente.animation.play('idle', true);
    fuente.scale.set(1.4, 1.4);
    fuente.antialiasing = true;
    fuente.visible = true;
    addBehindGF(fuente);

    var arbustoderecha:FlxSprite = new FlxSprite(832, 655).loadGraphic(Paths.image('Park/arbustoederecha'));
    arbustoderecha.scrollFactor.set(1.0, 1.0);
    arbustoderecha.scale.set(1.4, 1.4);
    arbustoderecha.antialiasing = true;
    arbustoderecha.visible = true;
    game.add(arbustoderecha);

    var arbustoizquierda:FlxSprite = new FlxSprite(-955, 655).loadGraphic(Paths.image('Park/arbustoizquierda'));
    arbustoizquierda.scrollFactor.set(1.0, 1.0);
    arbustoizquierda.scale.set(1.4, 1.4);
    arbustoizquierda.antialiasing = true;
    arbustoizquierda.visible = true;
    game.add(arbustoizquierda);

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

    gfGroup.scrollFactor.set(1, 1);
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