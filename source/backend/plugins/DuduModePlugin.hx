package backend.plugins;

import flixel.FlxG;
import flixel.FlxBasic;
import openfl.display.Bitmap;
import openfl.Assets;

@:nullSafety
class DuduModePlugin extends FlxBasic
{
	public static var instance:Null<DuduModePlugin> = null;
	public var duduOverlay:Bitmap;

	public static function init()
	{
		if (instance == null) 
		{
			instance = new DuduModePlugin();
			FlxG.plugins.addPlugin(instance);
		}
	}

	public function new()
	{
		super();

		duduOverlay = new Bitmap(Assets.getBitmapData('assets/exe/codearduele.png'));
		duduOverlay.width = FlxG.width; 
		duduOverlay.height = FlxG.height;
		duduOverlay.alpha = 0.2;
		duduOverlay.visible = false;
		
		FlxG.stage.addChild(duduOverlay);

        FlxG.signals.gameResized.add((w, h) -> {
            duduOverlay.width = w;
            duduOverlay.height = h;
        });
	}

	public function applyDuduMode():Void
	{
		if (duduOverlay != null) 
		{
			duduOverlay.visible = ClientPrefs.data.duduMode;
            duduOverlay.smoothing = ClientPrefs.data.antialiasing;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		applyDuduMode();
	}
}