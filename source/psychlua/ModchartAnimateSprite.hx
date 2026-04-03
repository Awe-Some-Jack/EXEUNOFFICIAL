package psychlua;

#if flxanimate
class ModchartAnimateSprite extends FlxAnimate
{
	public var animOffsets:Map<String, Array<Float>> = new Map();

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override public function playAnim(name:String, forced:Bool = false, reverse:Bool = false, startFrame:Int = 0):Void
	{
		anim.play(name, forced, reverse, startFrame);
		var offset = animOffsets.get(name);
		if (offset != null) this.offset.set(offset[0], offset[1]);
	}

	public function addOffset(name:String, x:Float, y:Float):Void
	{
		animOffsets.set(name, [x, y]);
	}
}
#end
