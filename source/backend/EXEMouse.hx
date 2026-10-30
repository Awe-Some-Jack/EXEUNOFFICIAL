
package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

enum abstract CustomCursorType(String) from String to String from MouseCursor to MouseCursor
{
	var ARROW = "arrow";
	var CROSSHAIR = "crosshair";
	var FINGER = "button";
	var HAND = "hand";
}

private typedef CursorParams = {
	var key:String;
	var folder:String;
	var scale:Float;
	var offsetX:Int;
	var offsetY:Int;
}

@:access(openfl.ui.Mouse)
class EXEMouse
{
	static final CURSOR_CONFIGS:Map<String, CursorParams> = [
		CustomCursorType.ARROW => {
			key: "arrow",
			folder: "exe/cursor",
			scale: 0.05,
			offsetX: -8,
			offsetY: -2
		},
		CustomCursorType.CROSSHAIR => {
			key: "crosshair",
			folder: "exe/cursor",
			scale: 0.06,
			offsetX: -19,
			offsetY: -13
		},
		CustomCursorType.FINGER => {
			key: "finger",
			folder: "exe/cursor",
			scale: 0.04,
			offsetX: -11,
			offsetY: -2
		}
	];

	public static var cursorType(get, set):CustomCursorType;

	static var _currentType:CustomCursorType = CustomCursorType.ARROW;

	static var _sourceCache:Map<String, BitmapData> = [];

	static var _activeBitmap:BitmapData;

	static var _initialized:Bool = false;
	static var _lastAppliedType:String = "";
	static var _lastScale:Float = -1;

	public static function init():Void
	{
		#if !mobile
		if (_initialized) return;
		_initialized = true;

		FlxG.signals.postGameStart.add(() -> {
			if (FlxG.mouse == null) return;

			FlxG.mouse.visible = true;
			applyCursor(normalizeType(Std.string(Mouse.__cursor)), true);
		});

		FlxG.signals.postUpdate.add(() -> {
			if (FlxG.mouse == null) return;

			if (!FlxG.mouse.visible)
				FlxG.mouse.visible = true;

			final requested = normalizeType(Std.string(Mouse.__cursor));
			applyCursor(requested);
		});
		#else
		FlxG.mouse.useSystemCursor = true;
		#end
	}

	static function get_cursorType():CustomCursorType
		return _currentType;

	static function set_cursorType(val:CustomCursorType):CustomCursorType
	{
		Mouse.cursor = cast val;
		applyCursor(val, true);
		return _currentType;
	}

	static function normalizeType(type:String):CustomCursorType
	{
		return switch (type)
		{
			case "button", "hand", "finger":
				CustomCursorType.FINGER;

			case "crosshair":
				CustomCursorType.CROSSHAIR;

			default:
				CustomCursorType.ARROW;
		}
	}

	static function getScreenScale():Float
	{
		final scale:Float = FlxG.scaleMode.scale.y;

		if (scale <= 0 || Math.isNaN(scale))
			return 1;

		return scale;
	}

	public static function applyCursor(type:CustomCursorType, force:Bool = false):Void
	{
		#if mobile
		FlxG.mouse.useSystemCursor = true;
		return;
		#else
		if (FlxG.mouse == null) return;

		final normType:String = normalizeType(type);
		final screenScale:Float = getScreenScale();

		if (!force
			&& normType == _lastAppliedType
			&& Math.abs(screenScale - _lastScale) < 0.01)
			return;

		final params = CURSOR_CONFIGS.get(normType);

		if (params == null) return;

		final source = getSource(normType, params);

		if (source == null)
		{
			Sys.println('[EXEMouse] Failed to load cursor: ${params.key}');

			_currentType = normType;
			_lastAppliedType = normType;
			_lastScale = screenScale;

			FlxG.mouse.useSystemCursor = true;
			FlxG.mouse.visible = true;
			return;
		}

		final scale:Float = params.scale * screenScale;
		final bitmap = smoothScale(source, scale);

		if (bitmap == null)
		{
			FlxG.mouse.useSystemCursor = true;
			FlxG.mouse.visible = true;
			return;
		}

		final previousBitmap = _activeBitmap;

		FlxG.mouse.useSystemCursor = false;

		FlxG.mouse.load(
			bitmap,
			1,
			Std.int(Math.round(params.offsetX * screenScale)),
			Std.int(Math.round(params.offsetY * screenScale))
		);

		if (FlxG.mouse.cursor != null)
			FlxG.mouse.cursor.smoothing = true;

		FlxG.mouse.visible = true;

		_activeBitmap = bitmap;
		_currentType = normType;
		_lastAppliedType = normType;
		_lastScale = screenScale;

		previousBitmap?.dispose();
		#end
	}

	static function smoothScale(source:BitmapData, scale:Float):BitmapData
	{
		if (source == null || source.width <= 0 || source.height <= 0)
			return null;

		if (scale <= 0 || Math.isNaN(scale))
			scale = 1;

		final width:Int = Std.int(Math.max(1, Math.ceil(source.width * scale)));
		final height:Int = Std.int(Math.max(1, Math.ceil(source.height * scale)));

		final result = new BitmapData(width, height, true, 0x00000000);

		final matrix = new Matrix();
		matrix.scale(scale, scale);

		result.draw(source, matrix, null, null, null, true);

		return result;
	}

	static function getSource(type:String, params:CursorParams):BitmapData
	{
		var source = _sourceCache.get(type);

		if (source != null)
			return source;

		source = loadBitmap(params.key, params.folder);

		if (source != null)
			_sourceCache.set(type, source);

		return source;
	}

	static function loadBitmap(key:String, folder:String):BitmapData
	{
		final graphic:FlxGraphic =
			Paths.image(key, folder, false) ??
			Paths.image(key, null, false);

		if (graphic?.bitmap != null)
		{
			Paths.excludeAsset(graphic.key);
			return graphic.bitmap.clone();
		}

		for (ext in Paths.IMAGE_EXTS)
		{
			if (ext == "astc") continue;

			final fullPath = Paths.getPath('$key.$ext', IMAGE, folder, true);

			#if sys
			if (sys.FileSystem.exists(fullPath))
			{
				final bitmap = BitmapData.fromFile(sys.FileSystem.fullPath(fullPath));

				if (bitmap != null)
					return bitmap;
			}
			#end

			if (openfl.Assets.exists(fullPath))
			{
				final bitmap = openfl.Assets.getBitmapData(fullPath, false);

				if (bitmap != null)
					return bitmap.clone();
			}
		}

		final fallback = Paths.getPath("cursor.webp", IMAGE, "exe", true);

		#if sys
		if (sys.FileSystem.exists(fallback))
		{
			final bitmap = BitmapData.fromFile(sys.FileSystem.fullPath(fallback));

			if (bitmap != null)
				return bitmap;
		}
		#end

		if (openfl.Assets.exists(fallback))
		{
			final bitmap = openfl.Assets.getBitmapData(fallback, false);

			if (bitmap != null)
				return bitmap.clone();
		}

		return null;
	}
}
