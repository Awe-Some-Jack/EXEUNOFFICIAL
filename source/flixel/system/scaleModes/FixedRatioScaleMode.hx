package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * This lets a stage render at its own native resolution, letterboxed to
 * fit the real window or fullscreen without resizing or moving the window.
 */
class FixedRatioScaleMode extends RatioScaleMode
{
	var refWidth:Int;
	var refHeight:Int;

	public function new(refWidth:Int, refHeight:Int, fillScreen:Bool = false)
	{
		super(fillScreen);
		this.refWidth = refWidth;
		this.refHeight = refHeight;
	}

	override function setGlobalSize(width:Int, height:Int):Void
	{
		FlxG.width = refWidth;
		FlxG.height = refHeight;
	}
}
