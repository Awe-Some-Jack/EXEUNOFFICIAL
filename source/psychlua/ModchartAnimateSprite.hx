package psychlua;

#if flxanimate
class ModchartAnimateSprite extends flxanimate.PsychFlxAnimate
{
	public var animOffsets:Map<String, Array<Float>> = new Map();

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override public function loadAtlasEx(img:flixel.system.FlxAssets.FlxGraphicAsset, pathOrStr:String = null, myJson:Dynamic = null):Void
	{
		super.loadAtlasEx(img, pathOrStr, myJson);
		if (anim != null && anim.stageInstance != null)
			origin.copyFrom(anim.stageInstance.symbol.transformationPoint);
	}

	override public function playAnim(name:String, forced:Bool = false, reverse:Bool = false, startFrame:Int = 0):Void
	{
		super.playAnim(name, forced, reverse, startFrame);
		var offset = animOffsets.get(name);
		if (offset != null) this.offset.set(offset[0], offset[1]);
	}

	public function addOffset(name:String, x:Float, y:Float):Void
	{
		animOffsets.set(name, [x, y]);
	}
}
#end
