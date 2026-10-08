package psychlua;

class DebugLuaText extends FlxText
{
	public var disableTime:Float = 6;

	public function new()
	{
		super(10, 10, FlxG.width - 20, '', 16);
		var fontPath = Paths.font('vcr.ttf');
		if (fontPath != null) {
			setFormat(fontPath, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		disableTime = Math.max(0, disableTime - elapsed);
		if (disableTime < 1) alpha = disableTime;
		if (alpha == 0 || y >= FlxG.height) kill();
	}
}
