package states.extras.achievements;

import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.Lib;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;

class AchievementPopup extends Sprite
{
    static inline final POP_W:Int            = 420;
    static inline final POP_H:Int            = 86;
    static inline final ICON_SIZE:Int        = 60;
    static inline final MARGIN:Int           = 14;
    static inline final SLIDE_DURATION:Float = 0.55;
    static inline final STAY_DURATION:Float  = 3.0;
    static inline final HIDE_DURATION:Float  = 0.4;
    static inline final TEXT_SCALE:Float     = 0.5;

    static var queue:Array<String> = [];
    static var showing:Bool = false;

    public static function show(achievementId:String):Void
    {
        queue.push(achievementId);
        if (!showing) next();
    }

    public static function clearQueue():Void
    {
        queue = [];
        showing = false;
    }

    static function next():Void
    {
        if (queue.length == 0) { showing = false; return; }
        showing = true;

        var id = queue.shift();
        var achieve = backend.EXEAchievements.get(id);
        if (achieve == null) { next(); return; }

        new AchievementPopup(id, achieve.name);
    }

    var _bitmaps:Array<BitmapData> = [];
    var _lastScale:Float = 1;
    var _timePassed:Float = -1;
    var _state:Int = 0;
    var _slideProgress:Float = 0;
    var _stayTimer:Float = 0;
    var _targetX:Float;
    var _startX:Float;
    var _posY:Float;

    public function new(id:String, achieveName:String)
    {
        super();

        _lastScale = FlxG.stage.stageHeight / FlxG.height;
        _targetX   = FlxG.width - POP_W - 16;
        _startX    = FlxG.width + 10;
        _posY      = FlxG.height - POP_H - 16;

        _build(id, achieveName);

        x      = _startX * _lastScale;
        y      = _posY   * _lastScale;
        scaleX = _lastScale;
        scaleY = _lastScale;

        FlxG.stage.addEventListener(Event.RESIZE, _onResize);
        addEventListener(Event.ENTER_FRAME, _update);
        FlxG.game.addChild(this);
    }

    function _build(id:String, achieveName:String):Void
    {
        graphics.beginFill(0x000000, 0.82);
        graphics.drawRect(0, 0, POP_W, POP_H);
        graphics.endFill();

        graphics.beginFill(0xBD0033);
        graphics.drawRect(0, 0, 4, POP_H);
        graphics.endFill();

        var iconX:Int = MARGIN + 4;
        var iconY:Int = (POP_H - ICON_SIZE) >> 1;

        graphics.beginFill(0xFFFFFF, 0.2);
        graphics.drawRect(iconX, iconY, ICON_SIZE, ICON_SIZE);
        graphics.endFill();

        var iconPath = 'assets/exe/extras/achievements/icons/$id.webp';
        if (openfl.Assets.exists(iconPath))
        {
            var bmd:BitmapData = openfl.Assets.getBitmapData(iconPath);
            if (bmd != null)
            {
                var sw = ICON_SIZE / bmd.width;
                var sh = ICON_SIZE / bmd.height;
                graphics.beginBitmapFill(bmd, new Matrix(sw, 0, 0, sh, iconX, iconY), false, true);
                graphics.drawRect(iconX, iconY, ICON_SIZE, ICON_SIZE);
                graphics.endFill();
            }
        }

        var textX:Int = MARGIN + 4 + ICON_SIZE + 10;
        var textW:Int = POP_W - ICON_SIZE - MARGIN * 2 - 20;

        _drawText('ACHIEVEMENT UNLOCKED', 18, 0xBD0033, 0xFFFFFF,
                  textX, (POP_H >> 1) - 22, textW);

        _drawText(achieveName.toUpperCase(), 24, 0xFFFFFF, 0x000000,
                  textX, (POP_H >> 1) + 2, textW);
    }

    function _drawText(str:String, size:Int, color:Int, outlineColor:Int,
                       tx:Float, ty:Float, maxW:Int):Void
    {
        var renderSize = Std.int(size / TEXT_SCALE);
        var renderW    = Std.int(maxW  / TEXT_SCALE);

        var t = new FlxText(0, 0, renderW, str, renderSize);
        t.font = Paths.font('NiseSega.ttf');
        t.color = color;
        t.setBorderStyle(FlxTextBorderStyle.OUTLINE, outlineColor, 2);
        t.antialiasing = true;
        t.updateHitbox();
        t.drawFrame(true);

        var bmd:BitmapData = t.graphic.bitmap.clone();
        _bitmaps.push(bmd);

        graphics.beginBitmapFill(bmd, new Matrix(TEXT_SCALE, 0, 0, TEXT_SCALE, tx, ty), false, true);
        graphics.drawRect(tx, ty, bmd.width * TEXT_SCALE, bmd.height * TEXT_SCALE);
        graphics.endFill();

        t.destroy();
    }

    var activateOnce:Bool = true;
    function _update(e:Event):Void
    {
        if (_timePassed < 0) { _timePassed = Lib.getTimer(); return; }

        var now     = Lib.getTimer();
        var elapsed = (now - _timePassed) / 1000;
        _timePassed = now;

        if (elapsed >= 0.5) return;

        switch (_state)
        {
            case 0:
                _slideProgress = Math.min(1, _slideProgress + elapsed / SLIDE_DURATION);
                x = (_startX + (_targetX - _startX) * FlxEase.expoOut(_slideProgress)) * _lastScale;
                if (_slideProgress >= 1) _state = 1;
                
                if (activateOnce) { FlxG.sound.play(Paths.sound('achievement')); activateOnce = false;}

            case 1:
                _stayTimer += elapsed;
                if (_stayTimer >= STAY_DURATION) { _state = 2; _slideProgress = 0; }

            case 2:
                _slideProgress = Math.min(1, _slideProgress + elapsed / HIDE_DURATION);
                x = (_targetX + (_startX - _targetX) * FlxEase.expoIn(_slideProgress)) * _lastScale;
                if (_slideProgress >= 1) _destroy();
        }
    }

    function _onResize(e:Event):Void
    {
        var mult   = FlxG.stage.stageHeight / FlxG.height;
        scaleX     = mult;
        scaleY     = mult;
        y          = _posY * mult;
        var logX:Float = switch (_state)
        {
            case 0:  _startX  + (_targetX - _startX)  * FlxEase.expoOut(_slideProgress);
            case 2:  _targetX + (_startX  - _targetX) * FlxEase.expoIn(_slideProgress);
            default: _targetX;
        };
        x          = logX * mult;
        _lastScale = mult;
    }

    function _destroy():Void
    {
        FlxG.stage.removeEventListener(Event.RESIZE, _onResize);
        removeEventListener(Event.ENTER_FRAME, _update);

        for (bmd in _bitmaps)
            if (bmd != null) { bmd.dispose(); bmd.disposeImage(); }
        _bitmaps = null;

        if (FlxG.game.contains(this)) FlxG.game.removeChild(this);

        next();
    }
}
