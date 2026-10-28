package backend;

import lime.graphics.Image;
import lime.graphics.cairo.CairoImageSurface;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

@:access(openfl.display.BitmapData)
class OptimizedBitmapData extends BitmapData
{
	#if (!js && !html5)
	public static function fromFile(path:String):OptimizedBitmapData
	{
		var bitmapData = new OptimizedBitmapData(0, 0, true, 0);
		@:privateAccess bitmapData.__fromFile(path);
		return (bitmapData.image != null || bitmapData.__texture != null) ? bitmapData : null;
	}
	#end

	public static function fromOpenFlAssets(id:String):OptimizedBitmapData
	{
		var src:BitmapData = OpenFlAssets.getBitmapData(id, false);
		if (src == null) return null;
		var bitmapData = new OptimizedBitmapData(0, 0, true, 0);
		@:privateAccess bitmapData.__fromImage(@:privateAccess src.image);
		return (bitmapData.__texture != null || bitmapData.image != null) ? bitmapData : null;
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:noCompletion
	private override function __fromImage(image:#if lime Image #else Dynamic #end, hardware:Bool = false):Void
	{
		#if lime
		if (image != null && image.buffer != null)
		{
			this.image = image;

			width  = image.width;
			height = image.height;
			rect   = new Rectangle(0, 0, image.width, image.height);

			__textureWidth  = width;
			__textureHeight = height;

			#if sys
			if (!hardware)
			{
				image.format = BGRA32;
			}

			image.premultiplied = true;
			#end

			readable = !hardware;

			__isValid = true;

			if (FlxG.stage.context3D != null)
			{
				lock();
				getTexture(FlxG.stage.context3D);
				getSurface();

				readable   = !hardware;
				this.image = null;
			}
		}
		#end
	}

	@SuppressWarnings("checkstyle:Dynamic")
	@:dox(hide)
	public override function getSurface():#if lime CairoImageSurface #else Dynamic #end
	{
		#if lime
		if (__surface == null)
			__surface = CairoImageSurface.fromImage(image);
		return __surface;
		#else
		return null;
		#end
	}
}
