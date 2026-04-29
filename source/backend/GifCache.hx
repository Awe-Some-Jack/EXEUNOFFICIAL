package backend;

import com.yagp.GifDecoder;
import com.yagp.GifPlayer;
import openfl.utils.Assets;
import openfl.utils.ByteArray;

class GifCache
{
	static var byteCache:Map<String, ByteArray> = [];

	static var activeSprites:Map<String, flxgif.FlxGifSprite> = [];

	public static function makeSprite(path:String):flxgif.FlxGifSprite
	{
		var existing = activeSprites.get(path);
		if (existing != null && existing.alive)
			return existing;

		var bytes = byteCache.get(path);
		if (bytes == null)
		{
			bytes = Assets.getBytes(path);
			byteCache.set(path, bytes);
		}

		var sprite = new flxgif.FlxGifSprite();
		sprite.loadGif(bytes);
		activeSprites.set(path, sprite);
		return sprite;
	}

	public static function remove(path:String):Void
	{
		byteCache.remove(path);
		activeSprites.remove(path);
	}

	public static function clearAll():Void
	{
		byteCache.clear();
		activeSprites.clear();
		MemoryUtil.clearMajor();
	}

	public static function flushRawBytes():Void
	{
		byteCache.clear();
	}
}
