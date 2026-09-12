var positions = [
    {x: 2100, y: 1000},
    {x: 2200, y: 1000},
    {x: 2300, y: 1000},
    {x: 2400, y: 1000},
    {x: 2500, y: 1000},
    {x: 2600, y: 1000},
    {x: 2700, y: 1000}
];

var missedEmeralds:Int = 0;
var collectedEmeralds:Int = 0;
var emeraldsAmount:Int = 7;
var emeralds:Array = [];
var emeraldsMoving:Array = [];
var muteOpponentVocals:Bool = false;

// Properties
var velocityMult:Float = 0.5;
var MOVEMENT_RADIUS:Float = 190;
var LERP_VELOCITY:Float = 15;
var BASE_SCALE:Float = 1.5;

function onCreatePost()
{
    for(i in 0...7)
    {
        var emerald = new FlxSprite().loadGraphic(Paths.image('emeralds/placeholder'));
        emerald.setPosition(positions[i].x, positions[i].y);
        emerald.scale.set(BASE_SCALE, BASE_SCALE);
        emerald.updateHitbox();
        insert(members.indexOf(boyfriendGroup) - 1, emerald);
        emeralds.push(emerald);

        FlxTween.tween(emerald.offset, {y: 45}, 2, {ease: FlxEase.sineInOut, type: 4, startDelay: 0.2 * i});
    }

    setVar('canTransform', false);
}

var _time:Float = 0;
function onUpdate(e) 
{
    _time += e * velocityMult;

    for(idx => em in emeraldsMoving)
    {
        var sine = FlxMath.fastSin(Math.PI * (_time - (idx + 1)/emeraldsMoving.length) * 2); // WE LOVE TRYGONOMETRICAL FUNCTIONS :] -rema
        var circularMovement = sine * MOVEMENT_RADIUS;
        
        if(curStep < 954 || !getVar('canTransform')) {
            var isBehindBF = members.indexOf(em) < members.indexOf(boyfriendGroup);
            var scaleFactor = BASE_SCALE + (isBehindBF ?  -(1 - Math.abs(sine)) : 1 - Math.abs(sine)) * 0.45;
            em.scale.set(scaleFactor, scaleFactor); // Modify the scale depending of its position to make a 3d illusion
        }
        
        if(circularMovement >= MOVEMENT_RADIUS - 5) // Place this emerald in front of bf if its approximately in the right limit
        {
            remove(em);
            insert(members.indexOf(boyfriendGroup) + 1, em);
        }
        else if(circularMovement <= -MOVEMENT_RADIUS + 5) // Place this emerald behind bf if its approximately the left limit
        {
            remove(em);
            insert(members.indexOf(boyfriendGroup) - 1, em);
        }
        em.x = FlxMath.lerp(em.x, boyfriend.x + 100 + circularMovement, LERP_VELOCITY * e);
    }
}

function onUpdatePost()
{
    if(muteOpponentVocals) opponentVocals.volume = 0;
}

function goodNoteHit(note:Note)
{
    var curEmeraldIndex:Int = collectedEmeralds + missedEmeralds;
    if(curEmeraldIndex > 6) return;

    if(note.noteType == 'emerald') 
    {
        var curEmerald = emeralds[curEmeraldIndex];
        if(curEmerald == null) return;
        FlxG.sound.play(Paths.sound('emerald'));

        FlxTween.tween(curEmerald, {x: boyfriend.x, y: boyfriend.y + boyfriend.height/6}, 2, {ease: FlxEase.cubeInOut, onComplete: () -> emeraldsMoving.push(curEmerald)});
        collectedEmeralds++;
    }

    if(collectedEmeralds >= 7) setVar('canTransform', true);
}

function noteMiss(note:Note)
{
    if(note.noteType == 'emerald') missedEmeralds++;
}

function onSpawnNote(note:Note)
{
    if(!note.mustPress) return;

    if(!getVar('canTransform')) note.animSuffix = '';
}

function onStepHit()
{
    switch(curStep) {
        case 954:
            if(collectedEmeralds == emeraldsAmount)
            {
                FlxTween.num(MOVEMENT_RADIUS, MOVEMENT_RADIUS * 0.1, 4, {ease: FlxEase.backIn}, v -> MOVEMENT_RADIUS = v);
                FlxTween.num(velocityMult, 3.5, 4, null, v -> velocityMult = v);
                for(em in emeraldsMoving) {
                    FlxTween.num(0, 255, 4, null, v -> em.colorTransform.redOffset = em.colorTransform.greenOffset = em.colorTransform.blueOffset = v);
                    FlxTween.tween(em.scale, {x: 0, y: 0}, 0.5, {startDelay: 3.5});
                }
            }
            else
            {
                FlxTween.num(MOVEMENT_RADIUS, MOVEMENT_RADIUS * 0.1, 3, {
                    ease: FlxEase.backIn, 
                    onComplete: () -> FlxTween.num(MOVEMENT_RADIUS, 225, 1, null, v -> MOVEMENT_RADIUS = v)
                }, v -> MOVEMENT_RADIUS = v);
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
        
        case 1040: muteOpponentVocals = false;
        case 1221: if(!getVar('canTransform')) triggerEvent('Change Health Damage', '0.035');
        case 1328: if(!getVar('canTransform')) triggerEvent('Change Health Damage', '0.05');
    }
}