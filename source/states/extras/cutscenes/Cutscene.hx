package states.extras.cutscenes;

import backend.MusicBeatSubstate;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;

import sys.FileSystem;
import sys.io.File;

class Cutscene extends MusicBeatSubstate
{
    static inline final MENU_START_Y:Float          = 180.0;
    static inline final MENU_SPACING:Float          = 58.0;
    static inline final MENU_START_X:Float          = 50.0;
    static inline final MENU_FONT_SIZE:Int          = 88;
    static inline final MENU_SCALE_DURATION:Float   = 0.2;
    static inline final SELECTION_TWEEN_DURATION:Float = 0.2;
    static inline final VISIBLE_COUNT:Int           = 6;
    static inline final SCROLL_LERP:Float           = 0.12;
    static inline final BORDER:Float                = 6.0;
    static inline final BOX_FINAL_X:Float           = 750.0;
    static inline final BOX_FINAL_Y:Float           = 120.0;
    static inline final BOX_FINAL_SCALE:Float       = 0.3;
    static inline final BOX_ANIM_DURATION:Float     = 0.5;
    static inline final SLIDE_DURATION:Float        = 0.35;
    static inline final HUD_H:Float                 = 52.0;
    static inline final BAR_PAD:Float               = 14.0;
    static inline final BTN_SIZE:Float              = 32.0;
    static inline final KNOB_R:Float                = 7.0;
    static inline final HUD_FADE_TIME:Float         = 0.22;
    static inline final HUD_IDLE_TIME:Float         = 2.5;

    var checkers:FlxBackdrop;
    var box:FlxSprite;
    var disco:FlxSprite;
    var discoShadows:Array<FlxSprite> = [];
    var titleText:FlxText;
    var nowPlaying:FlxText;
    var nowPlayingSong:FlxText;

    var _debugMode:Bool      = false;
    var _debugSelected:FlxSprite = null;
    var _debugDragging:Bool  = false;
    var _debugDragOffX:Float = 0;
    var _debugDragOffY:Float = 0;
    var _debugRotating:Bool  = false;
    var _debugOpacity:Bool   = false;
    var _debugLabel:FlxText;

    var videoEntries:Array<{name:String, displayName:String, path:String}> = [];
    var menuItems:Array<FlxText> = [];
    var selectBox:FlxSprite;
    var curSelected:Int = 0;
    var canMove:Bool    = true;

    var scrollY:Float       = 0.0;
    var scrollYTarget:Float = 0.0;

    var _vidBorder:FlxSprite = null;
    var _vidDim:FlxSprite    = null;
    #if VIDEOS_ALLOWED
    var _vidSprite:hxvlc.flixel.FlxVideoSprite = null;
    #end
    var _vidOpen:Bool   = false;
    var _vidPaused:Bool = false;

    var _hud:FlxSpriteGroup  = null;
    var _hudBar:FlxSprite    = null;
    var _hudFill:FlxSprite   = null;
    var _hudKnob:FlxSprite   = null;
    var _hudBtn:FlxSprite    = null;
    var _hudTimeTxt:FlxText  = null;

    var _hudVisible:Bool    = false;
    var _hudIdleTimer:Float = 0.0;
    var _seekDragging:Bool  = false;
    var _lastMouseX:Float   = -1;
    var _lastMouseY:Float   = -1;

    var _leftOrigX:Map<flixel.FlxBasic, Float> = new Map();

    override public function create():Void
    {
        super.create();
        
        createBackground();
        createBox();
        createDisco();
        _scanVideos();
        _buildMenu();
        changeSelection(0);

        titleText = new FlxText(49, 68, 0, Language.getArray('extras.menu.cutscenes', ['CUTSCENES', ''])[0], 88);
        titleText.setFormat("assets/fonts/bigass.otf", 88, 0xFFf48000, LEFT);
        titleText.setBorderStyle(OUTLINE_FAST, 0xFF510500, 8);
        titleText.scale.set(0.66, 0.66);
        titleText.updateHitbox();
        titleText.antialiasing = ClientPrefs.data.antialiasing;
        add(titleText);

        final gradientHeight:Int = 30;
        final descBar = new FlxSprite(0, 670 - gradientHeight);
        descBar.makeGraphic(FlxG.width, 100 + gradientHeight, FlxColor.TRANSPARENT, true);
        for (i in 0...gradientHeight)
        {
            final a:Float = (i / gradientHeight) * 0.3;
            descBar.pixels.fillRect(new openfl.geom.Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGBFloat(0, 0, 0, a));
        }
        descBar.pixels.fillRect(new openfl.geom.Rectangle(0, gradientHeight, FlxG.width, 100), FlxColor.fromRGBFloat(0, 0, 0, 0.3));
        add(descBar);

        final descTemp = new FlxText(0, 0, 0, Language.getArray('extras.menu.cutscenes', ['', 'In here you can rewatch cutscenes used in gameplay! Just that!'])[1], 56);
        descTemp.setFormat("assets/fonts/smallass.ttf", 56, FlxColor.WHITE, LEFT);
        descTemp.antialiasing = ClientPrefs.data.antialiasing;
        descTemp.updateHitbox();
        descTemp.drawFrame(true);
        
        final descBackdrop = new FlxBackdrop(descTemp.graphic, X, 0, 0);
        descBackdrop.scale.set(0.5, 0.5);
        descBackdrop.updateHitbox();
        descBackdrop.y = 675;
        descBackdrop.velocity.x = -30;
        add(descBackdrop);
        descTemp.destroy();

        nowPlaying = new FlxText(169, 558, 0, Language.get('extras.menu.nowplaying', 'NOW PLAYING:'), 60);
        nowPlaying.setFormat("assets/fonts/bigass.otf", 60, FlxColor.BLACK, LEFT);
        nowPlaying.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, 6);
        nowPlaying.scale.set(0.22, 0.22);
        nowPlaying.updateHitbox();
        nowPlaying.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlaying);

        final daName = states.extras.dagarden.DAGarden.currentSong;
        final songName = daName != '' ? daName.toUpperCase() : 'EXTRAS MENU';
        nowPlayingSong = new FlxText(169, 587.72, 0, songName, 60);
        nowPlayingSong.setFormat("assets/fonts/bigass.otf", 60, FlxColor.BLACK, LEFT);
        nowPlayingSong.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, 6);
        nowPlayingSong.scale.set(0.22, 0.22);
        nowPlayingSong.updateHitbox();
        nowPlayingSong.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlayingSong);

        _debugLabel = new FlxText(4, 4, 0, "", 14);
        _debugLabel.setFormat(null, 14, FlxColor.WHITE, LEFT);
        _debugLabel.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        _debugLabel.scrollFactor.set(0, 0);
        _debugLabel.visible = false;
        add(_debugLabel);

    }

    function createBackground():Void
    {
        final w:Int = FlxG.width;
        final h:Int = FlxG.height;
        final bmd = new openfl.display.BitmapData(w, h, false, 0xFF003380);
        final left  = {r: 0x00, g: 0x33, b: 0x80};
        final right = {r: 0x00, g: 0x0b, b: 0x3a};
        for (x in 0...w)
        {
            final t:Float = x / (w - 1);
            final r:Int = Math.round(left.r + (right.r - left.r) * t);
            final g:Int = Math.round(left.g + (right.g - left.g) * t);
            final b:Int = Math.round(left.b + (right.b - left.b) * t);
            bmd.fillRect(new openfl.geom.Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | (g << 8) | b);
        }
        final background = new FlxSprite(0, 0).loadGraphic(bmd);
        add(background);

        final tileSize:Int = 40;
        final cbmd = new openfl.display.BitmapData(tileSize * 2, tileSize * 2, true, 0x00000000);
        cbmd.fillRect(new openfl.geom.Rectangle(0,        0,        tileSize, tileSize), 0xFF00073d);
        cbmd.fillRect(new openfl.geom.Rectangle(tileSize, 0,        tileSize, tileSize), 0xFF001865);
        cbmd.fillRect(new openfl.geom.Rectangle(0,        tileSize, tileSize, tileSize), 0xFF001865);
        cbmd.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF00073d);
        checkers = new FlxBackdrop(cbmd, XY, 0, 0);
        checkers.alpha = 0.10;
        checkers.velocity.x = -60;
        add(checkers);
    }

    function createBox():Void
    {
        box = new FlxSprite(BOX_FINAL_X, BOX_FINAL_Y).loadGraphic(Assets.getBitmapData("assets/exe/extras/box.png"));
        box.scale.set(BOX_FINAL_SCALE, BOX_FINAL_SCALE);
        box.updateHitbox();
        add(box);
    }

    function createDisco():Void
    {
        final shadowOffsets = [
            {x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2},
            {x: -2, y: 0},                  {x: 2, y: 0},
            {x: -2, y: 2},  {x: 0, y: 2},  {x: 2, y: 2}
        ];
        final discoBmp = Assets.getBitmapData("assets/exe/extras/disco.png");
        for (offset in shadowOffsets)
        {
            final s = new FlxSprite(61 + offset.x, 541 + offset.y).loadGraphic(discoBmp);
            s.scale.set(0.29, 0.29);
            s.updateHitbox();
            s.color = FlxColor.BLACK;
            s.alpha = 0.3;
            add(s);
            discoShadows.push(s);
        }
        disco = new FlxSprite(61, 541).loadGraphic(discoBmp);
        disco.scale.set(0.29, 0.29);
        disco.updateHitbox();
        add(disco);
        FlxTween.angle(disco, 0, 360, 3.0, {type: LOOPING});
    }

    function animateBox():Void
    {
        FlxTween.cancelTweensOf(box);
        FlxTween.cancelTweensOf(box.scale);

        box.scale.set(0.6, 0.6);
        box.updateHitbox();
        box.x     = 200.0;
        box.y     = BOX_FINAL_Y;
        box.alpha = 0;

        FlxTween.tween(box, {x: BOX_FINAL_X}, BOX_ANIM_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(box, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
        FlxTween.tween(box.scale, {x: BOX_FINAL_SCALE, y: BOX_FINAL_SCALE}, BOX_ANIM_DURATION, {
            ease: FlxEase.expoOut,
            onUpdate: (_) -> {
                final cx = box.x; final cy = box.y;
                box.updateHitbox();
                box.x = cx; box.y = cy;
            }
        });
    }

    function _scanVideos():Void
    {
        videoEntries = [];
        final jsonPath = 'assets/exe/video.json';
        if (FileSystem.exists(jsonPath))
        {
            try
            {
                final json:Dynamic = haxe.Json.parse(File.getContent(jsonPath));
                final arr:Array<Dynamic> = cast json.videos;
                if (arr != null)
                {
                    for (v in arr)
                        videoEntries.push({name: Std.string(v.name), displayName: Std.string(v.displayName), path: Std.string(v.path)});
                    return;
                }
            }
            catch (_:Dynamic) {}
        }
        _scanDir('assets/exe/extras/cutscenes');
        _saveJson();
    }

    function _scanDir(dir:String):Void
    {
        if (!FileSystem.exists(dir)) return;
        try
        {
            for (entry in FileSystem.readDirectory(dir))
            {
                final full = '$dir/$entry';
                if (FileSystem.isDirectory(full))
                    _scanDir(full);
                else if (entry.toLowerCase().endsWith('.mp4'))
                {
                    final noExt = entry.substr(0, entry.length - 4);
                    videoEntries.push({name: noExt, displayName: _toDisplayName(noExt), path: full});
                }
            }
        }
        catch (_:Dynamic) {}
    }

    function _toDisplayName(name:String):String
    {
        var s = name.split('-').join(' ').split('_').join(' ');
        final words = s.split(' ');
        final result = [];
        for (w in words)
            if (w.length > 0)
                result.push(w.charAt(0).toUpperCase() + w.substr(1).toLowerCase());
        return result.join(' ');
    }

    function _saveJson():Void
    {
        final arr = [];
        for (e in videoEntries)
            arr.push({name: e.name, displayName: e.displayName, path: e.path});
        final json = haxe.Json.stringify({videos: arr}, null, '  ');
        try { File.saveContent('assets/exe/video.json', json); } catch (_:Dynamic) {}
    }

    function _buildMenu():Void
    {
        if (videoEntries.length == 0)
        {
            final lbl = new FlxText(MENU_START_X, MENU_START_Y, 0, Language.get('cutscenes.empty', 'NO VIDEOS FOUND'), MENU_FONT_SIZE);
            lbl.setFormat("assets/fonts/bigass.otf", MENU_FONT_SIZE, FlxColor.WHITE, LEFT);
            lbl.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 8);
            lbl.scale.set(0.5, 0.5);
            lbl.updateHitbox();
            add(lbl);
            menuItems.push(lbl);
        }
        else
        {
            for (i in 0...videoEntries.length)
            {
                final lbl = new FlxText(MENU_START_X, MENU_START_Y + (i * MENU_SPACING), 0, videoEntries[i].displayName.toUpperCase(), MENU_FONT_SIZE);
                lbl.setFormat("assets/fonts/bigass.otf", MENU_FONT_SIZE, FlxColor.WHITE, LEFT);
                lbl.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 8);
                lbl.antialiasing = ClientPrefs.data.antialiasing;
                lbl.pixelPerfectRender = false;
                lbl.scale.set(0.5, 0.5);
                lbl.updateHitbox();
                lbl.ID = i;
                add(lbl);
                menuItems.push(lbl);
            }
        }

        selectBox = new FlxSprite(0, 0).loadGraphic("assets/exe/extras/select.png");
        selectBox.scale.set(0.31, 0.28);
        selectBox.updateHitbox();
        add(selectBox);
    }

    function _scrollTargetFor(index:Int):Float
    {
        final ideal = (index - Std.int(VISIBLE_COUNT / 2)) * MENU_SPACING;
        final maxScroll = Math.max(0.0, (menuItems.length - VISIBLE_COUNT) * MENU_SPACING);
        return FlxMath.bound(ideal, 0, maxScroll);
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected += change;
        final maxIdx = menuItems.length - 1;
        if (curSelected < 0) curSelected = maxIdx;
        if (curSelected > maxIdx) curSelected = 0;

        if (change != 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            animateBox();
        }

        scrollYTarget = _scrollTargetFor(curSelected);

        for (i in 0...menuItems.length)
        {
            FlxTween.cancelTweensOf(menuItems[i].scale);
            if (i == curSelected)
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, 0xFF3a6bc9, 10);
                FlxTween.tween(menuItems[i].scale, {x: 0.525, y: 0.525}, MENU_SCALE_DURATION, {ease: FlxEase.smootherStepInOut});
            }
            else
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 8);
                FlxTween.tween(menuItems[i].scale, {x: 0.5, y: 0.5}, MENU_SCALE_DURATION, {ease: FlxEase.smootherStepInOut});
            }
        }

        _updateSelectBox();
    }

    function _updateSelectBox():Void
    {
        final targetY = MENU_START_Y + (curSelected * MENU_SPACING) - scrollYTarget;
        FlxTween.cancelTweensOf(selectBox);
        FlxTween.cancelTweensOf(selectBox.scale);
        FlxTween.tween(selectBox, {x: MENU_START_X - 10, y: targetY - 10}, SELECTION_TWEEN_DURATION, {ease: FlxEase.smootherStepInOut});
        FlxTween.tween(selectBox.scale, {x: 0.33, y: 0.30}, MENU_SCALE_DURATION, {ease: FlxEase.smootherStepInOut});
    }

    function _applyScroll():Void
    {
        for (i in 0...menuItems.length)
        {
            final rawY = MENU_START_Y + (i * MENU_SPACING) - scrollY;
            menuItems[i].y = rawY;

            final topEdge    = MENU_START_Y - MENU_SPACING;
            final bottomEdge = MENU_START_Y + VISIBLE_COUNT * MENU_SPACING;
            if (rawY < topEdge || rawY > bottomEdge)
                menuItems[i].alpha = 0;
            else if (rawY < MENU_START_Y)
                menuItems[i].alpha = (rawY - topEdge) / MENU_SPACING;
            else if (rawY > MENU_START_Y + (VISIBLE_COUNT - 1) * MENU_SPACING)
                menuItems[i].alpha = 1.0 - (rawY - (MENU_START_Y + (VISIBLE_COUNT - 1) * MENU_SPACING)) / MENU_SPACING;
            else
                menuItems[i].alpha = 1.0;
        }

        if (selectBox != null)
            selectBox.y = menuItems[curSelected].y - 10;
    }

    function _openVideo(path:String):Void
    {
        #if VIDEOS_ALLOWED
        if (_vidOpen) _closeVideo();

        _vidOpen   = true;
        _vidPaused = false;
        canMove    = false;

        _vidBorder = new FlxSprite(0, 0);
        _vidBorder.makeGraphic(1, 1, 0xFF3a6bc9);
        _vidBorder.alpha = 0;
        add(_vidBorder);

        _vidSprite = new hxvlc.flixel.FlxVideoSprite(0, 0);
        _vidSprite.bitmap.onFormatSetup.add(() -> {
            final maxW = FlxG.width  * 0.7;
            final maxH = FlxG.height * 0.65;
            final s    = Math.min(maxW / _vidSprite.width, maxH / _vidSprite.height);
            final fw   = Math.floor(_vidSprite.width  * s);
            final fh   = Math.floor(_vidSprite.height * s);
            _vidSprite.setGraphicSize(fw, fh);
            _vidSprite.updateHitbox();
            _vidSprite.screenCenter();
            _vidSprite.y -= HUD_H * 0.5;
            final finalY = _vidSprite.y;

            _vidSprite.y = -fh - 50;

            final vidShader = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000);
            vidShader.setSize(fw, fh);
            _vidSprite.shader = vidShader;

            final bw = fw + Std.int(BORDER * 2);
            final bh = fh + Std.int(BORDER * 2);
            _vidBorder.makeGraphic(bw, bh, 0xFF3a6bc9);
            _vidBorder.setPosition(_vidSprite.x - BORDER, _vidSprite.y - BORDER);
            final borderShader = new shaders.RoundedBorderShader(16.0 + BORDER, 0.0, 0xFF000000);
            borderShader.setSize(bw, bh);
            _vidBorder.shader = borderShader;

            FlxTween.tween(_vidSprite,  {y: finalY},                    SLIDE_DURATION, {ease: FlxEase.expoOut});
            FlxTween.tween(_vidBorder,  {y: finalY - BORDER, alpha: 1}, SLIDE_DURATION, {ease: FlxEase.expoOut});

            _buildHud(fw, finalY + fh);
        });
        _vidSprite.bitmap.onEndReached.add(() -> { _vidSprite.play(); _vidPaused = false; _hudUpdateBtn(); });

        final extrasMenu = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
        if (extrasMenu?._orphanPlayer != null)
            extrasMenu._orphanPlayer.setVolume(0.1);
        else if (FlxG.sound.music != null)
        {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 0.1}, 0.5, {ease: FlxEase.quadOut});
        }
        add(_vidSprite);

        if (_vidSprite.load(path, [':input-repeat=65535', ':avcodec-hw=any']))
            new flixel.util.FlxTimer().start(0.001, (_) -> {
                _vidSprite.play();
                _vidSprite.bitmap.rate = 1.0;
            });
        #end
    }

    function _buildHud(vidW:Float, hudTopY:Float):Void
    {
        if (_hud != null) { remove(_hud, true); _hud.destroy(); _hud = null; }

        _hud = new FlxSpriteGroup();
        _hud.alpha = 0;

        final hudX = _vidSprite.x;
        final hudY = hudTopY + 8;
        final w    = vidW;

        final bg = new FlxSprite(hudX, hudY).makeGraphic(Std.int(w), Std.int(HUD_H), 0x00000000, true);
        bg.pixels.fillRect(new openfl.geom.Rectangle(0, 0, w, HUD_H), 0xBB000000);

        final hudShader = new shaders.RoundedBorderShader(HUD_H * 0.5, 0.0, 0xFF000000);
        hudShader.setSize(Std.int(w), Std.int(HUD_H));
        bg.shader = hudShader;
        _hud.add(bg);

        _hudBtn = new FlxSprite(0, 0).loadGraphic('assets/exe/extras/credits/pause.png');
        final btnScale = BTN_SIZE / Math.max(_hudBtn.width, _hudBtn.height);
        _hudBtn.scale.set(btnScale, btnScale);
        _hudBtn.updateHitbox();
        _hudBtn.x = hudX + BAR_PAD;
        _hudBtn.y = hudY + (HUD_H - _hudBtn.height) * 0.5;
        _hudBtn.color = 0xFFFFFFFF;
        _hud.add(_hudBtn);

        final barX = _hudBtn.x + _hudBtn.width + BAR_PAD;
        final barY = hudY + HUD_H * 0.5 - 3;
        final barW = w - (barX - hudX) - BAR_PAD * 2 - 60;

        _hudBar = new FlxSprite(barX, barY);
        _hudBar.makeGraphic(Std.int(barW), 6, 0xFF555577);
        final barShader = new shaders.RoundedBorderShader(3.0, 0.0, 0xFF000000);
        barShader.setSize(Std.int(barW), 6);
        _hudBar.shader = barShader;
        _hud.add(_hudBar);

        _hudFill = new FlxSprite(barX, barY);
        _hudFill.makeGraphic(1, 6, 0xFF5a8fff);
        _hudFill.scale.x = 1;
        _hudFill.updateHitbox();
        _hud.add(_hudFill);

        final knobD = Std.int(KNOB_R * 2);
        _hudKnob = new FlxSprite(0, 0);
        _hudKnob.makeGraphic(knobD, knobD, 0x00000000, true);
        final cx = KNOB_R; final cy = KNOB_R;
        for (py in 0...knobD)
            for (px in 0...knobD)
                if (Math.sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy)) <= KNOB_R)
                    _hudKnob.pixels.setPixel32(px, py, 0xFFFFFFFF);
        _hudKnob.x = barX - KNOB_R;
        _hudKnob.y = barY + 3 - KNOB_R;
        _hud.add(_hudKnob);

        _hudTimeTxt = new FlxText(0, 0, 55, "0:00", 14);
        _hudTimeTxt.setFormat("assets/fonts/bigass.otf", 14, FlxColor.WHITE, RIGHT);
        _hudTimeTxt.antialiasing = ClientPrefs.data.antialiasing;
        _hudTimeTxt.x = hudX + w - BAR_PAD - 55;
        _hudTimeTxt.y = hudY + (HUD_H - _hudTimeTxt.height) * 0.5;
        _hud.add(_hudTimeTxt);

        add(_hud);

        _hudVisible   = false;
        _hudIdleTimer = 0.0;
        _seekDragging = false;
    }

    function _hudUpdateBtn():Void
    {
        if (_hudBtn == null) return;
        _hudBtn.loadGraphic(_vidPaused
            ? 'assets/exe/extras/credits/play.png'
            : 'assets/exe/extras/credits/pause.png');
        final btnScale = BTN_SIZE / Math.max(_hudBtn.frameWidth, _hudBtn.frameHeight);
        _hudBtn.scale.set(btnScale, btnScale);
        _hudBtn.updateHitbox();
        if (_hud != null && _hud.members.length > 0)
        {
            final bg = _hud.members[0];
            _hudBtn.y = bg.y + (HUD_H - _hudBtn.height) * 0.5;
        }
    }

    function _hudSetVisible(v:Bool):Void
    {
        if (_hud == null) return;
        if (_hudVisible == v) return;
        _hudVisible = v;
        FlxTween.cancelTweensOf(_hud);
        FlxTween.tween(_hud, {alpha: v ? 1.0 : 0.0}, HUD_FADE_TIME, {ease: FlxEase.quadInOut});
    }

    function _hudFmtTime(ms:Int):String
    {
        final s = Std.int(ms / 1000);
        final m = Std.int(s / 60);
        return '$m:${StringTools.lpad(Std.string(s % 60), "0", 2)}';
    }

    function _updateHud(elapsed:Float):Void
    {
        #if VIDEOS_ALLOWED
        if (_hud == null || _vidSprite == null) return;

        final mx = FlxG.mouse.x;
        final my = FlxG.mouse.y;
        final moved = (mx != _lastMouseX || my != _lastMouseY);
        _lastMouseX = mx; _lastMouseY = my;

        if (moved || _seekDragging) { _hudIdleTimer = 0.0; _hudSetVisible(true); }
        else if (_hudVisible && !_seekDragging)
        {
            _hudIdleTimer += elapsed;
            if (_hudIdleTimer >= HUD_IDLE_TIME) _hudSetVisible(false);
        }

        if (_hudBar != null && _hudFill != null && _hudKnob != null)
        {
            final pct   = FlxMath.bound(_vidSprite.bitmap.position, 0, 1);
            final dur   = _vidSprite.bitmap.duration;
            final barW  = _hudBar.width;
            final fillW = Math.max(1, barW * pct);
            _hudFill.scale.x = fillW;
            _hudFill.updateHitbox();
            _hudKnob.x = _hudBar.x + barW * pct - KNOB_R;
            if (_hudTimeTxt != null) _hudTimeTxt.text = _hudFmtTime(Std.int(pct * haxe.Int64.toInt(dur)));
        }

        if (_hudBar != null)
        {
            final barX = _hudBar.x;
            final barW = _hudBar.width;

            if (FlxG.mouse.justPressed && my >= _hudBar.y - 8 && my <= _hudBar.y + 14
                && mx >= barX - 4 && mx <= barX + barW + 4)
                _seekDragging = true;

            if (_seekDragging)
                _vidSprite.bitmap.position = FlxMath.bound((mx - barX) / barW, 0, 1);

            if (FlxG.mouse.justReleased) _seekDragging = false;
        }

        if (_hudBtn != null && FlxG.mouse.justPressed && _vidSprite != null && FlxG.mouse.overlaps(_hudBtn))
        {
            _vidPaused = !_vidPaused;
            if (_vidPaused) _vidSprite.pause(); else _vidSprite.resume();
            _hudUpdateBtn();
        }
        #end
    }

    function _closeVideo():Void
    {
        #if VIDEOS_ALLOWED
        if (!_vidOpen) return;
        _vidOpen   = false;
        _vidPaused = false;

        if (_hud != null) { FlxTween.cancelTweensOf(_hud); remove(_hud, true); _hud.destroy(); _hud = null; }
        _hudBar = null; _hudFill = null; _hudKnob = null; _hudBtn = null; _hudTimeTxt = null;

        final extrasMenuClose = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
        if (extrasMenuClose?._orphanPlayer != null)
            extrasMenuClose._orphanPlayer.setVolume(1.0);
        else if (FlxG.sound.music != null)
        {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 1.0}, 0.5, {ease: FlxEase.quadOut});
        }

        final vidRef    = _vidSprite;
        final borderRef = _vidBorder;
        final dimRef    = _vidDim;

        _vidSprite = null;
        _vidBorder = null;
        _vidDim    = null;

        if (vidRef != null)
        {
            vidRef.bitmap.onEndReached.removeAll();
            vidRef.bitmap.onFormatSetup.removeAll();
            vidRef.bitmap.stop();

            final targetY = -vidRef.height - 50;
            FlxTween.tween(vidRef,    {y: targetY}, SLIDE_DURATION, {ease: FlxEase.expoIn});
            FlxTween.tween(borderRef, {y: targetY - BORDER, alpha: 0}, SLIDE_DURATION, {
                ease: FlxEase.expoIn,
                onComplete: (_) -> {
                    remove(vidRef,    true); vidRef.destroy();
                    remove(borderRef, true); borderRef.destroy();
                    if (dimRef != null) { remove(dimRef, true); dimRef.destroy(); }
                    _slideBackIn();
                    canMove = true;
                }
            });
        }
        else
        {
            if (borderRef != null) { remove(borderRef, true); borderRef.destroy(); }
            if (dimRef    != null) { remove(dimRef,    true); dimRef.destroy(); }
            _slideBackIn();
            canMove = true;
        }
        #end
    }

    function _updateDebug():Void
    {
        final mx:Float = FlxG.mouse.x;
        final my:Float = FlxG.mouse.y;

        if (FlxG.keys.justPressed.T)
        {
            if (_debugSelected != null)
            {
                var n = _debugSelected == titleText ? "titleText" : (_debugSelected == box ? "box" : "unknown");
                trace('$n | x:${_debugSelected.x} y:${_debugSelected.y} scale:${_debugSelected.scale.x} angle:${_debugSelected.angle} alpha:${_debugSelected.alpha}');
            }
            else trace('DEBUG | nothing selected');
        }

        if (FlxG.mouse.justPressed)
        {
            _debugSelected = null;
            _debugDragging = false;
            _debugRotating = false;
            _debugOpacity  = false;
            final debugSprites:Array<FlxSprite> = [cast titleText, box, disco];
            for (s in debugSprites)
            {
                if (s != null && s.overlapsPoint(new flixel.math.FlxPoint(mx, my)))
                {
                    _debugSelected = s;
                    _debugDragOffX = mx - s.x;
                    _debugDragOffY = my - s.y;
                    _debugDragging = true;
                    break;
                }
            }
        }

        if (FlxG.mouse.justReleased) _debugDragging = false;

        if (_debugSelected != null)
        {
            _debugRotating = FlxG.keys.pressed.R;
            _debugOpacity  = FlxG.keys.pressed.O;
        }

        if (_debugDragging && _debugSelected != null && !_debugRotating && !_debugOpacity)
        {
            _debugSelected.x = mx - _debugDragOffX;
            _debugSelected.y = my - _debugDragOffY;
        }

        if (_debugSelected != null && FlxG.mouse.wheel != 0)
        {
            if (_debugRotating)
                _debugSelected.angle += FlxG.mouse.wheel * 2.0;
            else if (_debugOpacity)
                _debugSelected.alpha = Math.max(0, Math.min(1, _debugSelected.alpha + FlxG.mouse.wheel * 0.05));
            else
            {
                final delta:Float = FlxG.mouse.wheel * 0.01;
                _debugSelected.scale.x = Math.max(0.01, _debugSelected.scale.x + delta);
                _debugSelected.scale.y = Math.max(0.01, _debugSelected.scale.y + delta);
                _debugSelected.updateHitbox();
            }
        }

        var selName = "none";
        if (_debugSelected == cast titleText) selName = "titleText";
        else if (_debugSelected == box) selName = "box";
        else if (_debugSelected == disco) selName = "disco";
        final modeStr = _debugRotating ? " [R=rotate]" : (_debugOpacity ? " [O=opacity]" : " [scroll=scale]");
        if (_debugSelected != null)
            _debugLabel.text = '[F3] DEBUG$modeStr  |  $selName\nx: ${Math.round(_debugSelected.x)}  y: ${Math.round(_debugSelected.y)}  scale: ${Math.round(_debugSelected.scale.x * 1000) / 1000}  angle: ${Math.round(_debugSelected.angle)}  alpha: ${Math.round(_debugSelected.alpha * 100)}%';
        else
            _debugLabel.text = '[F3] DEBUG  |  click sprite | hold R+scroll=rotate | hold O+scroll=opacity';
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (nowPlayingSong != null)
        {
            final daName = states.extras.dagarden.DAGarden.currentSong;
            final displayName = daName != '' ? daName.toUpperCase() : 'EXTRAS MENU';
            if (nowPlayingSong.text != displayName) nowPlayingSong.text = displayName;
        }

        if (disco != null && discoShadows != null)
            for (s in discoShadows) s.angle = disco.angle;

        if (FlxG.keys.justPressed.F3)
        {
            _debugMode = !_debugMode;
            _debugLabel.visible = _debugMode;
            if (!_debugMode) { _debugSelected = null; _debugDragging = false; }
        }

        if (_debugMode)
        {
            _updateDebug();
            return;
        }

        if (_vidOpen)
        {
            _updateHud(elapsed);
            if (controls.BACK && !_seekDragging) _closeVideo();
            return;
        }

        scrollY = FlxMath.lerp(scrollY, scrollYTarget, SCROLL_LERP);
        _applyScroll();

        if (!canMove) return;

        if (controls.UI_UP_P)   changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        if (controls.ACCEPT && videoEntries.length > 0)
            _selectCurrent();

        if (FlxG.mouse.justPressed && disco != null
            && disco.overlapsPoint(new flixel.math.FlxPoint(FlxG.mouse.x, FlxG.mouse.y)))
        {
            final extrasMenu = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
            if (extrasMenu != null && extrasMenu._orphanPlayer != null)
            {
                final op = extrasMenu._orphanPlayer;
                if (op.isPlaying) op.pause();
                else op.playAudio(states.extras.dagarden.DAGarden.currentSong, states.extras.dagarden.DAGarden.currentSongMod);
            }
            else if (FlxG.sound.music != null)
            {
                if (FlxG.sound.music.playing) FlxG.sound.music.pause();
                else FlxG.sound.music.resume();
            }
        }

        if (controls.BACK)
            close();
    }

    function _slideOutAndOpenVideo():Void
    {
        final path = videoEntries[curSelected].path;
        var completed = 0;
        final total = 2;
        final onDone = (_:FlxTween) -> {
            completed++;
            if (completed >= total) _openVideo(path);
        };

        FlxTween.cancelTweensOf(box);
        FlxTween.tween(box, {x: FlxG.width + 50}, SLIDE_DURATION, {ease: FlxEase.expoIn, onComplete: onDone});

        final leftItems:Array<flixel.FlxObject> = [];
        for (item in menuItems) if (item != null) leftItems.push(item);
        if (selectBox      != null) leftItems.push(selectBox);
        if (titleText      != null) leftItems.push(titleText);
        if (disco          != null) leftItems.push(disco);
        for (s in discoShadows) if (s != null) leftItems.push(s);
        if (nowPlaying     != null) leftItems.push(nowPlaying);
        if (nowPlayingSong != null) leftItems.push(nowPlayingSong);

        _leftOrigX = new Map();
        for (item in leftItems)
            _leftOrigX.set(item, item.x);

        var leftDone = false;
        for (item in leftItems)
        {
            FlxTween.cancelTweensOf(item);
            final target = -item.width - 100;
            FlxTween.tween(item, {x: target}, SLIDE_DURATION, {
                ease: FlxEase.expoIn,
                onComplete: (_) -> {
                    if (!leftDone) { leftDone = true; onDone(null); }
                }
            });
        }
    }

    function _slideBackIn():Void
    {
        if (box != null)
        {
            FlxTween.cancelTweensOf(box);
            box.x = FlxG.width + 50;
            FlxTween.tween(box, {x: BOX_FINAL_X}, SLIDE_DURATION, {ease: FlxEase.expoOut});
        }

        final leftItems:Array<flixel.FlxObject> = [];
        for (item in menuItems) if (item != null) leftItems.push(item);
        if (selectBox      != null) leftItems.push(selectBox);
        if (titleText      != null) leftItems.push(titleText);
        if (disco          != null) leftItems.push(disco);
        for (s in discoShadows) if (s != null) leftItems.push(s);
        if (nowPlaying     != null) leftItems.push(nowPlaying);
        if (nowPlayingSong != null) leftItems.push(nowPlayingSong);

        for (item in leftItems)
        {
            final origX = _leftOrigX.exists(item) ? _leftOrigX.get(item) : item.x;
            item.x = -item.width - 100;
            FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {x: origX}, SLIDE_DURATION, {ease: FlxEase.expoOut});
        }
    }

    function _selectCurrent():Void
    {
        canMove = false;
        FlxG.sound.play(Paths.sound('confirmMenu'));

        FlxTween.cancelTweensOf(menuItems[curSelected].scale);
        FlxTween.tween(menuItems[curSelected].scale, {x: 0.575, y: 0.575}, 0.1, {
            ease: FlxEase.backOut,
            onComplete: (_) -> {
                FlxTween.tween(menuItems[curSelected].scale, {x: 0.525, y: 0.525}, 0.15, {
                    ease: FlxEase.smootherStepInOut,
                    onComplete: (_) -> _slideOutAndOpenVideo()
                });
            }
        });
    }

    override public function destroy():Void
    {
        #if VIDEOS_ALLOWED
        if (_vidSprite != null)
        {
            _vidSprite.bitmap.onEndReached.removeAll();
            _vidSprite.bitmap.onFormatSetup.removeAll();
            _vidSprite.bitmap.stop();
            _vidSprite.destroy();
            _vidSprite = null;
        }
        if (_vidBorder != null) { _vidBorder.destroy(); _vidBorder = null; }
        if (_vidDim    != null) { _vidDim.destroy();    _vidDim    = null; }
        #end
        if (_hud != null) { FlxTween.cancelTweensOf(_hud); _hud.destroy(); _hud = null; }
        _hudBar = null; _hudFill = null; _hudKnob = null; _hudBtn = null; _hudTimeTxt = null;
        if (box   != null) { FlxTween.cancelTweensOf(box);  FlxTween.cancelTweensOf(box.scale); }
        if (disco != null) FlxTween.cancelTweensOf(disco);
        titleText      = null;
        disco          = null;
        nowPlaying     = null;
        nowPlayingSong = null;
        if (selectBox != null) { FlxTween.cancelTweensOf(selectBox); FlxTween.cancelTweensOf(selectBox.scale); }
        if (menuItems != null)
            for (item in menuItems)
                if (item != null) { FlxTween.cancelTweensOf(item); FlxTween.cancelTweensOf(item.scale); }
        box          = null;
        menuItems    = null;
        selectBox    = null;
        videoEntries = null;
        _leftOrigX   = null;
        super.destroy();
    }
}
