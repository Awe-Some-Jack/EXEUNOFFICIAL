package backend;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.utils.AssetCache;
import backend.GifCache;

class FunkinCache extends AssetCache
{
	public static var instance:FunkinCache;

	@:noCompletion @:dox(hide) public var bitmapData2:Map<String, BitmapData> = [];
	@:noCompletion @:dox(hide) public var font2:Map<String, Font> = [];
	@:noCompletion @:dox(hide) public var sound2:Map<String, Sound> = [];

	public function new()
	{
		super();
		moveToSecondLayer();
		instance = this;
	}

	public static function init():Void
	{
		openfl.utils.Assets.cache = new FunkinCache();

		FlxG.signals.preStateSwitch.add(() -> instance.moveToSecondLayer());
		FlxG.signals.postStateSwitch.add(() -> {
			instance.clearSecondLayer();
			GifCache.flushRawBytes();
		});
	}

	public function moveToSecondLayer():Void
	{
		bitmapData2 = bitmapData;
		font2       = font;
		sound2      = sound;
		bitmapData  = [];
		font        = [];
		sound       = [];
	}

	public function clearSecondLayer():Void
	{
		for (k => b in bitmapData2)
			FlxG.bitmap.removeByKey(k);

		bitmapData2 = [];
		font2       = [];
		sound2      = [];

		MemoryUtil.clearMajor();
	}

	public override function getBitmapData(id:String):BitmapData
	{
		var s = bitmapData.get(id);
		if (s != null) return s;
		var s2 = bitmapData2.get(id);
		if (s2 != null)
		{
			bitmapData2.remove(id);
			bitmapData.set(id, s2);
		}
		return s2;
	}

	public override function getFont(id:String):Font
	{
		var s = font.get(id);
		if (s != null) return s;
		var s2 = font2.get(id);
		if (s2 != null)
		{
			font2.remove(id);
			font.set(id, s2);
		}
		return s2;
	}

	public override function getSound(id:String):Sound
	{
		var s = sound.get(id);
		if (s != null) return s;
		var s2 = sound2.get(id);
		if (s2 != null)
		{
			sound2.remove(id);
			sound.set(id, s2);
		}
		return s2;
	}

	public override function hasBitmapData(id:String):Bool
		return bitmapData.exists(id) || bitmapData2.exists(id);

	public override function hasFont(id:String):Bool
		return font.exists(id) || font2.exists(id);

	public override function hasSound(id:String):Bool
		return sound.exists(id) || sound2.exists(id);

	public override function removeBitmapData(id:String):Bool
		return bitmapData.remove(id) || bitmapData2.remove(id);

	public override function removeFont(id:String):Bool
		return font.remove(id) || font2.remove(id);

	public override function removeSound(id:String):Bool
		return sound.remove(id) || sound2.remove(id);
}
