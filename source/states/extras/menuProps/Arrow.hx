package states.extras.menuProps;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class ArrowEvent 
{
    public var sprite:FlxSprite;
    public var arrowScale:Float = 0.44;
    public var twn:FlxTween;
    public var eventCanceled:Bool = false;

    public function new(sprite:FlxSprite, twn:FlxTween = null) 
    {
        this.sprite = sprite;
        this.twn = twn;
    }

    public function cancel():Void
    {
        eventCanceled = true;
    }

    public function toString():String{
        return "ArrowEvent: [sprite: "+sprite+", twn: "+twn+"]";
    }
}

class Arrow extends FlxSprite 
{
    public var key:FlxKey = RIGHT;
    public var onUp:FlxTypedSignal<ArrowEvent->Void>;
    public var onDown:FlxTypedSignal<ArrowEvent->Void>;
    public var arrowTwn:FlxTween;
    public var isLeft:Bool = false;
    public var angleDir:Float = 0;
    public var arrowScale:Float = 0.44;

    /**
        @angleDir 0 = right dir
    **/
    public function new(nX:Float = 0.0, nY:Float = 0.0, assignedKey:FlxKey, angleDir:Float = 0)
    {
        super(nX, nY);

        this.key = assignedKey;
        this.angleDir = angleDir;
        isLeft = (angleDir == 180);

        onUp = new FlxTypedSignal<ArrowEvent->Void>();
        onDown = new FlxTypedSignal<ArrowEvent->Void>();

        loadGraphic(Paths.getBitmapData("assets/exe/extras/arrow.jxl"));
        setGraphicSize(Std.int(width * arrowScale));
        updateHitbox();
        offset.set(0,0);
        angle = angleDir;
        if (isLeft){
            flipY = true;
        }
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
        var justPressed = (FlxG.mouse.justPressed && overlapsPoint(new flixel.math.FlxPoint(FlxG.mouse.x, FlxG.mouse.y))) || (key != FlxKey.NONE && FlxG.keys.anyJustPressed([key]));
        var justReleased = (FlxG.mouse.justReleased && overlapsPoint(new flixel.math.FlxPoint(FlxG.mouse.x, FlxG.mouse.y))) || (key != FlxKey.NONE && FlxG.keys.anyJustReleased([key]));

        if (this == null) return;
 
        if (justPressed) 
        {
            if (arrowTwn != null)
            {
                arrowTwn.cancel();
                arrowTwn = null;
            }
            
            final rad:Float = angleDir * (Math.PI / 180);
            final distance:Float = 5.0 * arrowScale;
            
            final event = new ArrowEvent(this, arrowTwn);

            onDown.dispatch(event);

            if (event.eventCanceled) return;

            offset.x = Math.cos(rad) * distance;
            offset.y = Math.sin(rad) * distance;
            alpha = 0.7;
        }
    
        if (justReleased)
        {
            final event = new ArrowEvent(this, arrowTwn);

            onUp.dispatch(event);
            
            if (event.eventCanceled) return;

            if (arrowTwn != null) {
                arrowTwn.cancel();
            }

            arrowTwn = FlxTween.tween(this, {alpha: 1, "offset.x": 0, "offset.y": 0}, 0.23, {
                ease: FlxEase.quadOut,
                onComplete: twn -> {
                    arrowTwn = null;
                }
            });
        }
    }
}