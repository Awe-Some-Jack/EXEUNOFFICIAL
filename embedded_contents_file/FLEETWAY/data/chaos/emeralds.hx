typedef EmeraldData = {         // Had to make a typedef since there arent custom scripted classes :(
    var sprite:FlxSprite;
    var moving:Bool;
    var movingRadius:Float;
    var target:FlxObject;
    var targetRef:FlxObject;    // The reference object for the zIndexing cuz boyfriend's index doesnt work but boyfriendGroup's does.
    var xOffset:Float;
}

var colors = [  // Colors in order
    "green",
    "yellow",
    "blue",
    "purple",
    "gray",
    "cyan",
    "red"
];

var colorsHex = [  // Colors in order
    0xFF00FF44,
    0xFFFFFF00,
    0xFF2736FF,
    0xFFFF35E4,
    0xFFCECECE,
    0xFF32FFFF,
    0xFFFF0000
];

var masterEmerald:FlxSprite;
var missedEmeralds:Int = 0;
var collectedEmeralds:Int = 0;
var emeraldsAmount:Int = 7;
var emeralds:Array = [];
var emeraldsMoving:Array = [];
var muteOpponentVocals:Bool = false;

// Properties
var scaleMult:Float = 1;
var velocityMult:Float = 0.5;
var radiusMult:Float = 1;
var LERP_VELOCITY:Float = 15;
var INITIAL_SCALE:Float = 0.45;

var emeraldsData:Array<EmeraldData> = [];

function onCreatePost()
{
    var guh = FlxG.random.bool(1);
    masterEmerald = new FlxSprite();
    masterEmerald.setPosition(1925, 1050);
    masterEmerald.scale.set(0.4, 0.4);
    if(guh) 
    {
        masterEmerald.loadGraphic(Paths.image('bg/emerals/placeholder'));
        masterEmerald.scale.set(9, 9);
        masterEmerald.x += 550;
        masterEmerald.y += 150;
    }
    else 
    {
        masterEmerald.frames = Paths.getSparrowAtlas('bg/emerals/master');
        masterEmerald.animation.addByPrefix('anim', 'Símbolo', 24, true);
        masterEmerald.animation.play('anim');
    }
    insert(5, masterEmerald);   // In front of the beam and behind the beam blend

    for(i in 0...7)
    {
        var emerald = new FlxSprite(0, 1450);
        emerald.frames = Paths.getSparrowAtlas('bg/emerals/${colors[i]}');
        emerald.animation.addByPrefix('anim', 'Símbolo', 24, true);
        emerald.animation.play('anim');
        //emerald.setPosition(positions[i].x, positions[i].y);
        emerald.scale.set(INITIAL_SCALE, INITIAL_SCALE);
        emerald.updateHitbox();
        insert(members.indexOf(boyfriendGroup) - 1, emerald);
        emeralds.push(emerald);
        emeraldsData.push({
            sprite: emerald,
            moving: true,
            movingRadius: 325,
            target: masterEmerald,
            targetRef: masterEmerald,
            xOffset: guh ? -25 : 475
        });

        // FlxTween.tween(emerald.offset, {y: 45}, 2, {ease: FlxEase.sineInOut, type: 4, startDelay: 0.2 * i});
    }

    setVar('canTransform', false);

    gradient = new FlxSprite().loadGraphic(Paths.image('grad'));
    gradient.cameras = [camHUD];
    gradient.alpha = 0;
    gradient.y = ClientPrefs.data.downScroll ? -gradient.height/2 : FlxG.height - gradient.height/2;
    game.insert(0, gradient);
}

var _time:Float = 0;
var _masterTime:Float = 0;
var waveAmplitude:Float = 30;
var waveFrequency:Float = 3;
var wavePhaseShift:Float = 0.6;

function onUpdate(e:Float) 
{
    _time += e * velocityMult;
    _masterTime += e * velocityMult * 0.4;

    masterEmerald.offset.y = -FlxMath.fastSin(Math.PI * _masterTime) * 80;

    for(idx => emerald in emeraldsData)
    {
        if(!emerald.moving) continue;

        var sine = FlxMath.fastSin(Math.PI * (_time - (idx + 1)/emeralds.length) * 2); // WE LOVE TRYGONOMETRICAL FUNCTIONS :] -rema
        var circularMovement = sine * emerald.movingRadius * radiusMult;
        
        var isBehind = members.indexOf(emerald.sprite) < members.indexOf(emerald.targetRef);
        var scaleFactor = INITIAL_SCALE + (isBehind ? -(1 - Math.abs(sine)) : 1 - Math.abs(sine)) * 0.175;
        emerald.sprite.scale.set(scaleFactor * scaleMult, scaleFactor * scaleMult); // Modify the scale depending of its position to make a 3d illusion
        
        if(isBehind && sine >= 0.95) // Place this emerald in front of bf if its approximately in the right limit
        {
            remove(emerald.sprite);
            insert(members.indexOf(emerald.targetRef) + 1, emerald.sprite);
        }
        else if(!isBehind && sine <= -0.95) // Place this emerald behind bf if its approximately the left limit
        {
            remove(emerald.sprite);
            insert(members.indexOf(emerald.targetRef), emerald.sprite);
        }
        emerald.sprite.x = emerald.xOffset + emerald.target.x + circularMovement;

        var waveSine = FlxMath.fastSin((_time * waveFrequency) + (idx * wavePhaseShift));
        emerald.sprite.offset.y = (waveSine * waveAmplitude)+50;
    }
}

function goodNoteHit(note:Note)
{
    var curEmeraldIndex:Int = collectedEmeralds + missedEmeralds;
    if(curEmeraldIndex > 6) return;

    if(note.noteType == 'emerald') 
    {
        var curEmerald = emeraldsData[curEmeraldIndex];
        if(curEmerald == null) return;

        FlxG.sound.play(Paths.sound('emerald'));
        curEmerald.moving = false;

        FlxTween.tween(curEmerald.sprite, {x: boyfriend.x, y: boyfriend.y + boyfriend.height/6}, 2, {ease: FlxEase.cubeInOut, onComplete: () -> {
            curEmerald.target = boyfriend;
            curEmerald.targetRef = boyfriendGroup;
            curEmerald.moving = true;
            curEmerald.movingRadius = 190;
            curEmerald.xOffset = 100;
        }});
        collectedEmeralds++;

        FlxTween.cancelTweensOf(gradient);
        gradient.alpha = 1;
        FlxTween.tween(gradient, {alpha: 0}, 0.4);
    }

    if(collectedEmeralds >= 7 || game.cpuControlled) setVar('canTransform', true);
}

function onUpdatePost()
{
    if(muteOpponentVocals) opponentVocals.volume = 0;
}

function noteMiss(note:Note)
{
    if(note.noteType == 'emerald') {
        missedEmeralds++;

        FlxTween.cancelTweensOf(gradient);
        FlxTween.tween(gradient, {alpha: 0}, 0.25);
    }
}

function onCountdownStarted()
{
    FlxTween.num(4, 0.55, 4, null, v -> velocityMult = v);
}

/**
 * Transform and events change stuff, here i change the events if the user is superbf or not along with the chaosEvent.lua script
 */

 var spawnCount:Int = 0;
function onSpawnNote(note:Note)
{
    if(!note.mustPress) return;

    if(note.noteType == 'emerald') 
    {
        gradient.color = colorsHex[spawnCount];
        gradient.scale.set(1, 1);
        gradient.x = note.x - 25;
        FlxTween.tween(gradient, {alpha: 0.6, "scale.y": 8}, 1.75);
        spawnCount++;
    }
    if(!getVar('canTransform')) note.animSuffix = '';
}

function onStepHit()
{
    switch(curStep) {
        case 954:
            if(getVar('canTransform'))
            {
                FlxTween.num(radiusMult, 0.1, 4, {ease: FlxEase.backIn}, v -> radiusMult = v);
                FlxTween.num(velocityMult, 3.5, 4, {
                    onComplete: () -> FlxTween.num(velocityMult, 0.1, 1, null, v -> velocityMult = v)
                }, v -> velocityMult = v);
                FlxTween.num(scaleMult, 0, 0.5, {startDelay: 3.5, onComplete: () -> {
                    for(em in emeraldsMoving) {
                        emeraldsMoving.remove(em);
                        remove(em);
                        em.destroy();
                    }
                }}, v -> scaleMult = v);
                for(em in emeralds) 
                    FlxTween.num(0, 255, 4, null, v -> em.colorTransform.redOffset = em.colorTransform.greenOffset = em.colorTransform.blueOffset = v);
            }
            else
            {
                FlxTween.num(velocityMult, 3.5, 3, {
                    onComplete: () -> FlxTween.num(velocityMult, 0.1, 1, null, v -> velocityMult = v)
                }, v -> velocityMult = v);
            }

        case 1034:
            if(getVar('canTransform')) {
                dad.playAnim('what', true);
                triggerEvent('Normal Lyrics', 'lyrics.chaos.6', '1');
                dad.specialAnim = true;
            }
            else
                muteOpponentVocals = true;

        case 1216: //lyric 4 steps ahead
            if(getVar('canTransform')) {
                dad.playAnim('grrr', true);
                triggerEvent('Normal Lyrics', 'lyrics.chaos.16', '1');
                triggerEvent('Tween Camera Zoom', '0.8, true', '0.75, sineInOut');
                dad.specialAnim = true;
            }
            else
                muteOpponentVocals = true;

        case 1322: //lyric 2 steps ahead
            if(getVar('canTransform')) {
                dad.playAnim('showyou', true);
                triggerEvent('Normal Lyrics', 'lyrics.chaos.8', '1');
                triggerEvent("Tween Camera Zoom", "1, true", "0.9, smootherStepInOut");
                dad.specialAnim = true;
            }
            else
                muteOpponentVocals = true;
        case 1345: 
            if(getVar('canTransform')) {
                triggerEvent('Normal Lyrics', 'lyrics.chaos.8', '2');
            }
        case 1347: 
            if(getVar('canTransform')) {
                triggerEvent('Normal Lyrics', 'lyrics.chaos.8', '3');
            }
        case 1352: 
            if(getVar('canTransform')) {
                triggerEvent('Normal Lyrics', 'lyrics.chaos.8', '4');
            }
        case 1356: 
            if(getVar('canTransform')) {
                triggerEvent('Normal Lyrics', 'lyrics.chaos.8', '5');
            }
        case 1999: 
            if(!getVar('canTransform')) {
                game.health = -10;
            }
        
        case 1040, 1230, 1359: muteOpponentVocals = false;
        case 1221: if(!getVar('canTransform')) triggerEvent('Change Health Damage', '0.035');
        case 1328: if(!getVar('canTransform')) triggerEvent('Change Health Damage', '0.045');
    }
}