package states.extras.achievements;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;

@:access(flixel.FlxGame)
class AchievementPopup extends Sprite
{
    static inline final POP_W:Int            = 450;
    static inline final POP_H:Int            = 86;
    static inline final ICON_SIZE:Int        = 60;
    static inline final MARGIN:Int           = 14;
    static inline final SLIDE_DURATION:Float = 0.55;
    static inline final STAY_DURATION:Float  = 3.0;
    static inline final HIDE_DURATION:Float  = 0.4;
    static inline final TEXT_SCALE:Float     = 0.5;
    static inline final V_SPACING:Int        = 5;

    static var queue:Array<AchievementPopup> = [];
    static var showing:Bool = false;

    public static function show(achievementId:String):Void
    {
        var achieve = backend.EXEAchievements.get(achievementId);
        if (achieve == null) return;

        var pop = new AchievementPopup(achievementId, achieve.name);
        if(queue.length != 0) for(popup in queue) popup.slideUp();
        queue.push(pop);
    }

    var _bitmaps:Array<BitmapData> = [];
    var _lastScale:Float = 1;
    var _timePassed:Float = -1;
    var _state:Int = 0;
    var _slideProgress:Float = 0;
    var _slideUpProgress:Float = 0;
    var _stayTimer:Float = 0;
    var _targetX:Float;
    var _targetY:Float;
    var _startX:Float;
    var _startY:Float;

    public function new(id:String, achieveName:String)
    {
        super();

        _lastScale = FlxG.stage.stageHeight / FlxG.height;
        _startY    = FlxG.height - POP_H - 16;
        _targetY   = _startY; 
        _targetX   = FlxG.width - POP_W - 16;
        _startX    = FlxG.width + 10;

        _build(id, achieveName);

        x      = _startX * _lastScale;
        y      = _startY * _lastScale;
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

        final iconX:Int = MARGIN + 4;
        final iconY:Int = (POP_H - ICON_SIZE) >> 1;

        graphics.beginFill(0xFFFFFF, 0.2);
        graphics.drawRect(iconX, iconY, ICON_SIZE, ICON_SIZE);
        graphics.endFill();

        final iconPath = 'assets/exe/extras/achievements/icons/$id.webp';
        if (openfl.Assets.exists(iconPath))
        {
            final bmd:BitmapData = openfl.Assets.getBitmapData(iconPath);
            if (bmd != null)
            {
                final sw = ICON_SIZE / bmd.width;
                final sh = ICON_SIZE / bmd.height;
                
                final iconBmp = new Bitmap(bmd);
                iconBmp.x = iconX;
                iconBmp.y = iconY;
                iconBmp.scaleX = sw;
                iconBmp.scaleY = sh;
                iconBmp.smoothing = ClientPrefs.data.antialiasing;
                addChild(iconBmp);
            }
        }

        final textX:Int = MARGIN + 4 + ICON_SIZE + 10;
        final textW:Int = POP_W - ICON_SIZE - MARGIN * 2 - 20;

        _drawText(Language.get('popup_achievement_unlocked', 'ACHIEVEMENT UNLOCKED'), 18, 0xBD0033, 0xFFFFFF,
                  textX, (POP_H >> 1) - 22, textW);

        _drawText(Language.upper(Language.getPhrase('achievement_' + id, achieveName)), 24, 0xFFFFFF, 0x000000,
                  textX, (POP_H >> 1) + 2, textW);
    }

    function _drawText(str:String, size:Int, color:Int, outlineColor:Int,
                       tx:Float, ty:Float, maxW:Int):Void
    {
        final renderSize = Std.int(size / TEXT_SCALE);
        final renderW    = Std.int(maxW  / TEXT_SCALE);

        final t = new FlxText(0, 0, 0, str, renderSize);
        t.font = Paths.font('NiseSega.ttf');
        t.color = color;
        t.setBorderStyle(FlxTextBorderStyle.OUTLINE, outlineColor, 2);
        t.antialiasing = ClientPrefs.data.antialiasing;
        t.updateHitbox();
        t.drawFrame(true);

        while(t.width >= renderW) t.size -= 1;

        final bmd:BitmapData = t.graphic.bitmap.clone();
        _bitmaps.push(bmd);

        final textBmp = new Bitmap(bmd);
        textBmp.x = tx;
        textBmp.y = ty;
        textBmp.scaleX = TEXT_SCALE;
        textBmp.scaleY = TEXT_SCALE;
        textBmp.smoothing = ClientPrefs.data.antialiasing;
        addChild(textBmp);

        t.destroy();
    }

    var activateOnce:Bool = true;
    function _update(e:Event):Void
    {
        if (_timePassed < 0) { _timePassed = FlxG.game.getTimer(); return; }

        var now     = FlxG.game.getTimer();
        var elapsed = (now - _timePassed) / 1000;
        _timePassed = now;

        if (elapsed >= 0.5) return;

        _targetX   = FlxG.width - POP_W - 16;
        _startX    = FlxG.width + 10;

        if(_slideUp)
        {
            _slideUpProgress = Math.min(1, _slideUpProgress + elapsed / SLIDE_DURATION);
            y = (_startY + (_targetY - _startY) * FlxEase.expoOut(_slideUpProgress) * _lastScale);

            if(_slideUpProgress >= 1) _slideUp = false;
        }

        switch (_state)
        {
            case 0:
                _slideProgress = Math.min(1, _slideProgress + elapsed / SLIDE_DURATION);
                x = (_startX + (_targetX - _startX) * FlxEase.expoOut(_slideProgress)) * _lastScale;
                if (_slideProgress >= 1) _state = 1;
                
                if (activateOnce) { FlxG.sound.play(Paths.sound('achievement')).persist = true; activateOnce = false;}

            case 1:
                _stayTimer += elapsed;
                if (_stayTimer >= STAY_DURATION) { _state = 2; _slideProgress = 0; }

            case 2:
                _slideProgress = Math.min(1, _slideProgress + elapsed / HIDE_DURATION);
                x = (_targetX + (_startX - _targetX) * FlxEase.expoIn(_slideProgress)) * _lastScale;
                if (_slideProgress >= 1) _destroy();
        }
    }

    var _slideUp:Bool = false;
    public function slideUp():Void
    {
        _startY = y;
        _targetY -= (POP_H + V_SPACING) * _lastScale;
        _slideUpProgress = 0;
        _slideUp = true;
    }

    function _onResize(e:Event):Void
    {
        var mult   = FlxG.stage.stageHeight / FlxG.height;
        scaleX     = mult;
        scaleY     = mult;
        y          = _startY * mult;
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

        AchievementPopup.queue.remove(this);
    }
}
