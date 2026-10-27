package backend.system;

import flixel.FlxG;
import flixel.system.scaleModes.BaseScaleMode;

/**
 * `WideScaleMode` is a custom scale mode that expands the game's field of view (FOV) 
 * to fill the entire screen without stretching the graphics or 
 * adding black bars (letterboxing).
 */
class WideScaleMode extends BaseScaleMode
{
	public var baseWidth:Int;
	public var baseHeight:Int;

	public function new(baseWidth:Int, baseHeight:Int)
	{
		super();
		this.baseWidth = baseWidth;
		this.baseHeight = baseHeight;
	}

	override public function onMeasure(Width:Int, Height:Int):Void
	{
		final zoom:Float = Math.min(Width / baseWidth, Height / baseHeight);

		final newWidth:Int = Math.ceil(Width / zoom);
        final newHeight:Int = Math.ceil(Height / zoom);

        if (FlxG.cameras != null)
        {
            for (cam in FlxG.cameras.list)
            {
                if (cam != null && (cam.width >= baseWidth || cam.width == FlxG.width))
                {
                    cam.setSize(newWidth, newHeight);
                    
                    if (cam.target == null)
                    {
                        cam.scroll.x = (baseWidth - newWidth) / 2;
                        cam.scroll.y = (baseHeight - newHeight) / 2;
                    }
                }
            }
        }
        
        updateGameSize(Width, Height);
        updateDeviceSize(Width, Height);

        scale.x = zoom;
        scale.y = zoom;
        
        offset.x = Math.round((Width - newWidth * zoom) / 2);
        offset.y = Math.round((Height - newHeight * zoom) / 2);

        updateGamePosition();
    }
}