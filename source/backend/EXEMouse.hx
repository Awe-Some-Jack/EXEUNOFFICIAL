package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.input.mouse.FlxMouse;

import openfl.display.BitmapData;
import openfl.display.Sprite;
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
class EXEMouse extends FlxMouse
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

    public var cursorType(default, set):CustomCursorType = CustomCursorType.ARROW;
    public var forceSystemCursor(default, set):Bool = false;

    var _sourceCache:Map<String, BitmapData> = [];
    var _activeBitmap:BitmapData;
    
    var _lastAppliedType:String = "";
    var _lastScale:Float = -1;

    public function new(cursorContainer:Sprite)
    {
        super(cursorContainer);

        #if mobile
        useSystemCursor = true;
        #else
        visible = true;
        applyCursor(normalizeType(Std.string(Mouse.__cursor)), true);
        #end
    }

    override public function update():Void
    {
        super.update();

        #if !mobile
        if (!visible)
            visible = true;

        final requested = normalizeType(Std.string(Mouse.__cursor));
        applyCursor(requested);
        #end
    }

    @:keep function set_forceSystemCursor(value:Bool):Bool
    {
        if (forceSystemCursor == value) return value;
        
        forceSystemCursor = value;
        
        #if !mobile
        applyCursor(normalizeType(Std.string(Mouse.__cursor)), true);
        #end
        
        return value;
    }

    function set_cursorType(val:CustomCursorType):CustomCursorType
    {
        Mouse.cursor = cast val;
        applyCursor(val, true);
        return cursorType = val;
    }

    function normalizeType(type:String):CustomCursorType
    {
        return switch (type)
        {
            case "button", "hand", "finger": CustomCursorType.FINGER;
            case "crosshair": CustomCursorType.CROSSHAIR;
            default: CustomCursorType.ARROW;
        }
    }

    function getScreenScale():Float
    {
        final scale:Float = FlxG.scaleMode.scale.y;
        if (scale <= 0 || Math.isNaN(scale)) return 1;
        return scale;
    }

    public function applyCursor(type:CustomCursorType, force:Bool = false):Void
    {
        #if mobile
        useSystemCursor = true;
        return;
        #else

        if (forceSystemCursor)
        {
            useSystemCursor = true;
            visible = true;
            return;
        }

        final normType:String = normalizeType(type);
        final screenScale:Float = getScreenScale();

        if (!force && normType == _lastAppliedType && Math.abs(screenScale - _lastScale) < 0.01)
            return;

        final params = CURSOR_CONFIGS.get(normType);
        if (params == null) return;

        final source = getSource(normType, params);

        if (source == null)
        {
            Sys.println('[EXEMouse] Failed to load cursor: ${params.key}');

            _lastAppliedType = normType;
            _lastScale = screenScale;

            useSystemCursor = true;
            visible = true;
            return;
        }

        final scale:Float = params.scale * screenScale;
        final bitmap = smoothScale(source, scale);

        if (bitmap == null)
        {
            useSystemCursor = true;
            visible = true;
            return;
        }

        final previousBitmap = _activeBitmap;
        useSystemCursor = false;

        load(bitmap, 1, Std.int(Math.round(params.offsetX * screenScale)), Std.int(Math.round(params.offsetY * screenScale)));

        if (this.cursor != null)
            this.cursor.smoothing = true;

        visible = true;

        _activeBitmap = bitmap;
        _lastAppliedType = normType;
        _lastScale = screenScale;

        previousBitmap?.dispose();
        #end
    }

    function smoothScale(source:BitmapData, scale:Float):BitmapData
    {
        if (source == null || source.width <= 0 || source.height <= 0) return null;
        if (scale <= 0 || Math.isNaN(scale)) scale = 1;

        final width:Int = Std.int(Math.max(1, Math.ceil(source.width * scale)));
        final height:Int = Std.int(Math.max(1, Math.ceil(source.height * scale)));

        final result = new BitmapData(width, height, true, 0x00000000);
        final matrix = new Matrix();
        matrix.scale(scale, scale);

        result.draw(source, matrix, null, null, null, true);
        return result;
    }

    function getSource(type:String, params:CursorParams):BitmapData
    {
        var source = _sourceCache.get(type);
        if (source != null) return source;

        source = loadBitmap(params.key, params.folder);
        if (source != null) _sourceCache.set(type, source);

        return source;
    }

    function loadBitmap(key:String, folder:String):BitmapData
    {
        final graphic:FlxGraphic = Paths.image(key, folder, false) ?? Paths.image(key, null, false);

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
                if (bitmap != null) return bitmap;
            }
            #end

            if (openfl.Assets.exists(fullPath))
            {
                final bitmap = openfl.Assets.getBitmapData(fullPath, false);
                if (bitmap != null) return bitmap.clone();
            }
        }

        final fallback = Paths.getPath("cursor.webp", IMAGE, "exe", true);

        #if sys
        if (sys.FileSystem.exists(fallback))
        {
            final bitmap = BitmapData.fromFile(sys.FileSystem.fullPath(fallback));
            if (bitmap != null) return bitmap;
        }
        #end

        if (openfl.Assets.exists(fallback))
        {
            final bitmap = openfl.Assets.getBitmapData(fallback, false);
            if (bitmap != null) return bitmap.clone();
        }

        return null;
    }
}