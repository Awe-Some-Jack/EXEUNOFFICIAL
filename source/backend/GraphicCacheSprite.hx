package backend;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;

class GraphicCacheSprite extends FlxSprite
{
	public var cachedGraphics:Array<FlxGraphic> = [];
	public var nonRenderedCachedGraphics:Array<FlxGraphic> = [];

	public function new()
	{
		super();
		alpha = 0.00001;
	}

	public function cache(path:String):Void
		cacheGraphic(FlxG.bitmap.add(path));

	public function cacheGraphic(graphic:FlxGraphic):Void
	{
		if (graphic == null) return;
		graphic.useCount++;
		graphic.destroyOnNoUse = false;
		cachedGraphics.push(graphic);
		nonRenderedCachedGraphics.push(graphic);
	}

	override public function destroy():Void
	{
		for (g in cachedGraphics)
		{
			g.destroyOnNoUse = true;
			g.useCount--;
		}
		graphic = null;
		super.destroy();
	}

	override public function draw():Void
	{
		while (nonRenderedCachedGraphics.length > 0)
		{
			loadGraphic(nonRenderedCachedGraphics.shift());
			drawComplex(FlxG.camera);
		}
	}
}
