package states.extras.menuProps;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import hxvlc.flixel.FlxVideoSprite;

class CardSprite extends FlxVideoSprite
{
    public var finalX:Float = 0;
    public var finalY:Float = 0;
    public var targetAlpha:Float = 0.67;
    public var introDone:Bool = false;

    public var borderSprite:FlxSprite;
    public var borderWidth:Int = 6; 

    public function new(x:Float = 0, y:Float = 0)
    {
        super(null, x, y);
        borderSprite = new FlxSprite();
    }

    public function loadVideoCard(path:String):Void
    {
        if (load(path, [':input-repeat=2147483647', ':no-audio', ':avcodec-hw=any']))
        {
            bitmap.onFormatSetup.add(function():Void {
                scale.set(0.85, 0.85);
                updateHitbox();

                if (bitmap != null && bitmap.bitmapData != null)
                {
                    final vWidth:Int = bitmap.bitmapData.width;
                    final vHeight:Int = bitmap.bitmapData.height;

                    final bWidth:Int = vWidth + (borderWidth * 2);
                    final bHeight:Int = vHeight + (borderWidth * 2);

                    final frameBmd = new BitmapData(bWidth, bHeight, true, FlxColor.TRANSPARENT);

                    frameBmd.fillRect(new openfl.geom.Rectangle(0, 0, bWidth, bHeight), FlxColor.WHITE);

                    frameBmd.fillRect(new openfl.geom.Rectangle(borderWidth, borderWidth, vWidth, vHeight), FlxColor.TRANSPARENT);

                    borderSprite.loadGraphic(frameBmd);
                    // borderSprite.ignoreDrawDebug = true;
                }
            });
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