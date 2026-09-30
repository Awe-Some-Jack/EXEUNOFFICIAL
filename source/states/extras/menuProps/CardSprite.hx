package states.extras.menuProps;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
#if switch
import switchvideo.SwitchVideo;
private typedef VideoBase = SwitchVideo;
#else
import hxvlc.flixel.FlxVideoSprite;
private typedef VideoBase = FlxVideoSprite;
#end

class CardSprite extends VideoBase
{
    public var finalX:Float = 0;
    public var finalY:Float = 0;
    public var targetAlpha:Float = 0.67;
    public var introDone:Bool = false;

    public var borderSprite:FlxSprite;
    public var borderWidth:Int = 6;

    public function new(x:Float = 0, y:Float = 0)
    {
        #if switch
        super();
        setPosition(x, y);
        #else
        super(null, x, y);
        #end
        borderSprite = new FlxSprite();
    }

    public function loadVideoCard(path:String):Void
    {
        #if switch
        final loaded = load(path, ['input-repeat=65545']);
        if (loaded)
            setLooping(true);
        #else
        final loaded = load(path, [':input-repeat=2147483647', ':no-audio', ':avcodec-hw=any']);
        #end

        if (loaded)
        {
            final onReady = function():Void
            {
                scale.set(0.85, 0.85);
                updateHitbox();

                #if switch
                final vWidth:Int = frameWidth;
                final vHeight:Int = frameHeight;
                #else
                var vWidth:Int = 0;
                var vHeight:Int = 0;
                if (bitmap != null && bitmap.bitmapData != null)
                {
                    vWidth = bitmap.bitmapData.width;
                    vHeight = bitmap.bitmapData.height;
                }
                #end

                final bWidth:Int = vWidth + (borderWidth * 2);
                final bHeight:Int = vHeight + (borderWidth * 2);

                final frameBmd = new BitmapData(bWidth, bHeight, true, FlxColor.TRANSPARENT);

                frameBmd.fillRect(new openfl.geom.Rectangle(0, 0, bWidth, bHeight), FlxColor.WHITE);

                frameBmd.fillRect(new openfl.geom.Rectangle(borderWidth, borderWidth, vWidth, vHeight), FlxColor.TRANSPARENT);

                borderSprite.loadGraphic(frameBmd);
            };

            #if switch
            onFormatSetup = onReady;
            #else
            bitmap.onFormatSetup.add(onReady);
            #end

            play();
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (borderSprite != null && borderSprite.graphic != null)
        {
            // 1. Sincronizar transformaciones
            borderSprite.scale.set(scale.x, scale.y);
            borderSprite.angle = angle;
            borderSprite.alpha = alpha;
            borderSprite.visible = visible;

            // 2. Centrar el punto de origen del marco para que la rotación/escala sea uniforme
            borderSprite.centerOrigin();

            // 3. Alinear el centro del marco con el centro del video
            final videoCenter = getGraphicMidpoint();
            borderSprite.x = videoCenter.x - (borderSprite.width * 0.5);
            borderSprite.y = videoCenter.y - (borderSprite.height * 0.5);
            
            videoCenter.put(); // Liberar el punto de memoria para optimizar rendimiento
        }
    }

    override public function draw():Void
    {
        super.draw();
        if (borderSprite != null && borderSprite.graphic != null && borderSprite.visible)
            borderSprite.draw();
    }

    override public function destroy():Void
    {
        if (borderSprite != null)
            borderSprite.destroy();

        super.destroy();
    }
}