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
    "white",
    "cyan",
    "red"
];

var emeralds:Array = [];

// Properties
var scaleMult:Float = 1;
var velocityMult:Float = 0.6;
var radiusMult:Float = 1;
var LERP_VELOCITY:Float = 15;
var INITIAL_SCALE:Float = 0.6;

var emeraldsData:Array<EmeraldData> = [];

function onCreatePost()
{
    for(i in 0...7)
    {
        var emerald = new FlxSprite(-1000, 300);
        emerald.frames = Paths.getSparrowAtlas('emeralds/${colors[i]}');
        emerald.animation.addByPrefix('anim', colors[i], 24, true);
        emerald.animation.play('anim');
        emerald.scale.set(INITIAL_SCALE, INITIAL_SCALE);
        emerald.updateHitbox();
        add(emerald);
        emeralds.push(emerald);
        emeraldsData.push({
            sprite: emerald,
            moving: false,
            movingRadius: 290,
            target: dad,
            targetRef: dadGroup,
            xOffset: 225
        });
    }
}

var _time:Float = 0;
var waveAmplitude:Float = 30;
var waveFrequency:Float = 3;
var wavePhaseShift:Float = 0.6;

function onUpdate(e:Float) 
{
    _time += e * velocityMult;

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
        emerald.sprite.x = FlxMath.lerp(emerald.sprite.x, emerald.xOffset + emerald.target.x + circularMovement, LERP_VELOCITY * e);

        var waveSine = FlxMath.fastSin((_time * waveFrequency) + (idx * wavePhaseShift));
        emerald.sprite.offset.y = (waveSine * waveAmplitude) + 50;
    }
}

var emeraldIdx:Int = 0;
function onBeatHit()
{
    //256 transforms
    if(curBeat == 256)
        for(idx => curEmerald in emeraldsData)
        {
            curEmerald.moving = false;

            FlxTween.tween(curEmerald.sprite, {x: dad.x}, 0.5, {startDelay: 0.1 * idx, ease: FlxEase.cubeInOut, onComplete: () -> {
                curEmerald.moving = true;
            }});
        }
}