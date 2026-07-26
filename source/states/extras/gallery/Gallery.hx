package states.extras.gallery;

import backend.MusicBeatSubstate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;

import openfl.display.BitmapData;

#if sys
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
import objects.VideoSprite;
#end

//literally recicled code from other mod i did lmao.
//just added new assets and changed some stuff to make it work with UNOFICIAL GOD
// JDIAJIDJASDJIADJAd sex

class Gallery extends MusicBeatSubstate
{
    static final CATEGORIES:Array<{name:String, labelKey:Int}> = [
        {name: 'wips',     labelKey: 0},
        {name: 'memes',    labelKey: 1},
        {name: 'scrapped', labelKey: 2},
    ];

    var checkers:FlxBackdrop;
    var box:FlxSprite;
    var disco:FlxSprite;
    var discoShadows:Array<FlxSprite> = [];
    var titleText:FlxText;
    var nowPlaying:FlxText;
    var nowPlayingSong:FlxText;

    var menuItems:Array<FlxText> = [];
    var _selLeft:FlxSprite;
    var _selMid:FlxSprite;
    var _selRight:FlxSprite;
    var curSelected:Int  = 0;
    var canMove:Bool     = true;
    var scrollY:Float       = 0.0;
    var scrollYTarget:Float = 0.0;

    var _mode:Int = 0; 
    var _curCategory:Int = 0;
    var _subfolders:Array<{name:String, path:String}> = [];
    var _curSubfolder:Int = 0;
    var _subSubfolders:Array<{name:String, path:String}> = [];
    var _curSubSubfolder:Int = 0;
    var _images:Array<String> = [];
    var _curImage:Int = 0;

    var _imgSprite:FlxSprite  = null;
    var _imgBorder:FlxSprite  = null;
    var _imgCounter:FlxText   = null;
    var _imgOpen:Bool         = false;

    #if VIDEOS_ALLOWED
    var _vidSprite:VideoSprite = null;
    var _vidBorder:FlxSprite = null;
    var _vidOpen:Bool = false;
    #end

    var _leftOrigX:Map<flixel.FlxBasic, Float> = new Map();
    var _leftOrigY:Map<flixel.FlxBasic, Float> = new Map();

    override public function create():Void
    {
        super.create();

        createBackground();
        createBox();
        createDisco();
        _buildMenu();
        changeSelection(0);

        titleText = new FlxText(49, 68, 0, Language.getArray('extras.menu.gallery', ['GALLERY', ''])[0], Language.cjkSize(88));
        titleText.setFormat(Paths.font("bigass.otf"), Language.cjkSize(88), 0xFFf48000, LEFT);
        titleText.setBorderStyle(OUTLINE_FAST, 0xFF510500, Language.cjkBorder(8));
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

        final descTemp = new FlxText(0, 0, 0, Language.getArray('extras.menu.gallery', ['', 'Browse WIPs, memes and scrapped content from the team!'])[1], Language.cjkSize(56));
        descTemp.setFormat(Paths.font(Language.fontOrCJK("smallass.ttf")), Language.cjkSize(56), FlxColor.WHITE, LEFT);
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
        nowPlaying.setFormat(Paths.font("bigass.otf"), 60, FlxColor.BLACK, LEFT);
        nowPlaying.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        nowPlaying.scale.set(0.22, 0.22);
        nowPlaying.updateHitbox();
        nowPlaying.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlaying);

        final daName = states.extras.dagarden.DAGarden.currentSong;
        nowPlayingSong = new FlxText(169, nowPlaying.y + nowPlaying.height + 6, 0, daName != '' ? daName.toUpperCase() : 'EXTRAS MENU', 60);
        nowPlayingSong.setFormat(Paths.font("bigass.otf"), 60, FlxColor.BLACK, LEFT);
        nowPlayingSong.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        nowPlayingSong.scale.set(0.22, 0.22);
        nowPlayingSong.updateHitbox();
        nowPlayingSong.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlayingSong);
    }

    function createBackground():Void
    {
        final w:Int = FlxG.width;
        final h:Int = FlxG.height;
        final bmd = new BitmapData(w, h, false, 0xFFbd0033);
        final left  = {r: 0xbd, g: 0x00, b: 0x33};
        final right = {r: 0x57, g: 0x00, b: 0x0b};
        for (x in 0...w)
        {
            final t:Float = x / (w - 1);
            final r:Int = Math.round(left.r + (right.r - left.r) * t);
            final g:Int = Math.round(left.g + (right.g - left.g) * t);
            final b:Int = Math.round(left.b + (right.b - left.b) * t);
            bmd.fillRect(new openfl.geom.Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | (g << 8) | b);
        }
        add(new FlxSprite(0, 0).loadGraphic(bmd));

        final tileSize:Int = 40;
        final cbmd = new BitmapData(tileSize * 2, tileSize * 2, true, 0x00000000);
        cbmd.fillRect(new openfl.geom.Rectangle(0,        0,        tileSize, tileSize), 0xFF3d0008);
        cbmd.fillRect(new openfl.geom.Rectangle(tileSize, 0,        tileSize, tileSize), 0xFF831826);
        cbmd.fillRect(new openfl.geom.Rectangle(0,        tileSize, tileSize, tileSize), 0xFF831826);
        cbmd.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF3d0008);
        checkers = new FlxBackdrop(cbmd, XY, 0, 0);
        checkers.alpha      = 0.10;
        checkers.velocity.x = -60;
        add(checkers);
    }

    function createBox():Void
    {
        box = new FlxSprite(750.0, 120.0);
        box.loadGraphic(Paths.getBitmapData("assets/exe/extras/box.png"));
        box.scale.set(0.3, 0.3);
        box.updateHitbox();
        add(box);
    }

    function animateBox():Void
    {
        FlxTween.cancelTweensOf(box);
        FlxTween.cancelTweensOf(box.scale);
        box.scale.set(0.6, 0.6);
        box.updateHitbox();
        box.x     = 200.0;
        box.y     = 120.0;
        box.alpha = 0;
        FlxTween.tween(box, {x: 750.0}, 0.5, {ease: FlxEase.expoOut});
        FlxTween.tween(box, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
        FlxTween.tween(box.scale, {x: 0.3, y: 0.3}, 0.5, {
            ease: FlxEase.expoOut,
            onUpdate: (_) -> {
                final cx = box.x; final cy = box.y;
                box.updateHitbox();
                box.x = cx; box.y = cy;
            }
        });
    }

    function createDisco():Void
    {
        final shadowOffsets = [
            {x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2},
            {x: -2, y: 0},                  {x: 2, y: 0},
            {x: -2, y: 2},  {x: 0, y: 2},  {x: 2, y: 2}
        ];
        final discoBmp = Paths.getBitmapData("assets/exe/extras/disco.png");
        for (offset in shadowOffsets)
        {
            final s = new FlxSprite(61 + offset.x, 541 + offset.y);
            s.loadGraphic(discoBmp);
            s.scale.set(0.29, 0.29);
            s.updateHitbox();
            s.color = FlxColor.BLACK;
            s.alpha  = 0.3;
            add(s);
            discoShadows.push(s);
        }
        disco = new FlxSprite(61, 541);
        disco.loadGraphic(discoBmp);
        disco.scale.set(0.29, 0.29);
        disco.updateHitbox();
        add(disco);
        FlxTween.angle(disco, 0, 360, 3.0, {type: LOOPING});
    }

    function _buildMenu():Void
    {
        for (item in menuItems) if (item != null) { FlxTween.cancelTweensOf(item); FlxTween.cancelTweensOf(item.scale); remove(item, true); item.destroy(); }
        menuItems = [];
        if (_selLeft  != null) { remove(_selLeft,  true); _selLeft.destroy();  _selLeft  = null; }
        if (_selMid   != null) { remove(_selMid,   true); _selMid.destroy();   _selMid   = null; }
        if (_selRight != null) { remove(_selRight, true); _selRight.destroy(); _selRight = null; }

        var items:Array<String> = [];
        switch (_mode)
        {
            case 0:
                final catLabels = Language.getArray('extras.gallery.categories', ['WIPS', 'MEMES', 'SCRAPPED']);
                items = [for (c in CATEGORIES) catLabels[c.labelKey]];
            case 1: items = [for (s in _subfolders) s.name.toUpperCase()];
            case 2: items = [for (s in _subSubfolders) s.name.toUpperCase()];
            default:
        }

        if (items.length == 0)
        {
            final lbl = new FlxText(50.0, 180.0, 0, Language.get('extras.gallery.empty', 'NOTHING HERE'), Language.cjkSize(88));
            lbl.setFormat(Paths.font("bigass.otf"), Language.cjkSize(88), FlxColor.WHITE, LEFT);
            lbl.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, Language.cjkBorder(8));
            lbl.scale.set(0.5, 0.5);
            lbl.updateHitbox();
            add(lbl);
            menuItems.push(lbl);
        }
        else
        {
            for (i in 0...items.length)
            {
                final lbl = new FlxText(50.0, 180.0 + (i * 58.0), 0, items[i], Language.cjkSize(88));
                lbl.setFormat(Paths.font("bigass.otf"), Language.cjkSize(88), FlxColor.WHITE, LEFT);
                lbl.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, Language.cjkBorder(8));
                lbl.antialiasing = ClientPrefs.data.antialiasing;
                lbl.pixelPerfectRender = false;
                lbl.scale.set(0.5, 0.5);
                lbl.updateHitbox();
                lbl.ID = i;
                add(lbl);
                menuItems.push(lbl);
            }
        }

        final selBmp = Paths.getBitmapData("assets/exe/extras/select.png");
        final capW = 80;
        final selH = selBmp.height;
        final midW = selBmp.width - capW * 2;

        final leftBmp = new BitmapData(capW, selH, true, 0);
        leftBmp.copyPixels(selBmp, new openfl.geom.Rectangle(0, 0, capW, selH), new openfl.geom.Point(0, 0));
        _selLeft = new FlxSprite(0, 0);
        _selLeft.loadGraphic(leftBmp);
        _selLeft.antialiasing = ClientPrefs.data.antialiasing;
        _selLeft.origin.set(0, 0);

        final midBmp = new BitmapData(midW, selH, true, 0);
        midBmp.copyPixels(selBmp, new openfl.geom.Rectangle(capW, 0, midW, selH), new openfl.geom.Point(0, 0));
        _selMid = new FlxSprite(0, 0);
        _selMid.loadGraphic(midBmp);
        _selMid.antialiasing = ClientPrefs.data.antialiasing;
        _selMid.origin.set(0, 0);

        final rightBmp = new BitmapData(capW, selH, true, 0);
        rightBmp.copyPixels(selBmp, new openfl.geom.Rectangle(selBmp.width - capW, 0, capW, selH), new openfl.geom.Point(0, 0));
        _selRight = new FlxSprite(0, 0);
        _selRight.loadGraphic(rightBmp);
        _selRight.antialiasing = ClientPrefs.data.antialiasing;
        _selRight.origin.set(0, 0);

        add(_selLeft);
        add(_selMid);
        add(_selRight);

        curSelected   = 0;
        scrollY       = 0;
        scrollYTarget = 0;
        _snapSelectBox();
    }

    function _scanSubfolders(categoryPath:String):Void
    {
        _subfolders = [];
        #if sys
        if (!FileSystem.exists(categoryPath)) return;
        try
        {
            for (entry in FileSystem.readDirectory(categoryPath))
            {
                final full = categoryPath + '/' + entry;
                if (FileSystem.isDirectory(full))
                    _subfolders.push({name: entry, path: full});
            }
        }
        catch (_:Dynamic) {}
        _subfolders.sort((a, b) -> a.name < b.name ? -1 : 1);
        #end
    }

    function _scanSubSubfolders(subfolderPath:String):Void
    {
        _subSubfolders = [];
        #if sys
        if (!FileSystem.exists(subfolderPath)) return;
        try
        {
            for (entry in FileSystem.readDirectory(subfolderPath))
            {
                final full = subfolderPath + '/' + entry;
                if (FileSystem.isDirectory(full))
                    _subSubfolders.push({name: entry, path: full});
            }
        }
        catch (_:Dynamic) {}
        _subSubfolders.sort((a, b) -> a.name < b.name ? -1 : 1);
        #end
    }

    function _scanImages(folderPath:String):Void
    {
        _images = [];
        #if sys
        if (!FileSystem.exists(folderPath)) return;
        try
        {
            for (entry in FileSystem.readDirectory(folderPath))
            {
                if (_isImage(entry))
                    _images.push(folderPath + '/' + entry);
            }
        }
        catch (_:Dynamic) {}
        _images.sort((a, b) -> a < b ? -1 : 1);
        #end
    }

    inline function _isImage(name:String):Bool
    {
        final l = name.toLowerCase();
        return l.endsWith('.png') || l.endsWith('.jpg') || l.endsWith('.jpeg') || l.endsWith('.mp4');
    }

    inline function _isVideo(path:String):Bool
    {
        return path.toLowerCase().endsWith('.mp4');
    }

    function _scrollTargetFor(index:Int):Float
    {
        final ideal     = (index - Std.int(6 / 2)) * 58.0;
        final maxScroll = Math.max(0.0, (menuItems.length - 6) * 58.0);
        return FlxMath.bound(ideal, 0, maxScroll);
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected += change;
        final maxIdx = menuItems.length - 1;
        if (curSelected < 0)       curSelected = maxIdx;
        if (curSelected > maxIdx)  curSelected = 0;

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
                menuItems[i].setBorderStyle(OUTLINE_FAST, 0xFF3a6bc9, Language.cjkBorder(10));
                FlxTween.tween(menuItems[i].scale, {x: 0.525, y: 0.525}, 0.2, {ease: FlxEase.smootherStepInOut});
            }
            else
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, Language.cjkBorder(8));
                FlxTween.tween(menuItems[i].scale, {x: 0.5, y: 0.5}, 0.2, {ease: FlxEase.smootherStepInOut});
            }
        }

        _updateSelectBox();
    }

    function _calcSelectLayout():{targetX:Float, targetY:Float, capPx:Float, midPx:Float, midScaleX:Float, scaleY:Float}
    {
        final item      = menuItems[curSelected];
        final itemW     = item.frameWidth * 0.525 + 46;
        final scaleY    = 0.28;
        final capPx     = _selLeft.frameWidth * scaleY;
        final minMidPx  = _selMid.frameWidth * scaleY;
        final midPx     = Math.max(minMidPx, itemW - capPx * 2);
        final midScaleX = midPx / _selMid.frameWidth;
        final targetY   = 180.0 + (curSelected * 58.0) - scrollYTarget - 16;
        return {targetX: 50.0 - 18, targetY: targetY, capPx: capPx, midPx: midPx, midScaleX: midScaleX, scaleY: scaleY};
    }

    function _snapSelectBox():Void
    {
        if (_selLeft == null || _selMid == null || _selRight == null) return;
        final l = _calcSelectLayout();
        for (s in [_selLeft, _selMid, _selRight]) { FlxTween.cancelTweensOf(s); FlxTween.cancelTweensOf(s.scale); }
        _selLeft.setPosition(l.targetX, l.targetY);
        _selLeft.scale.set(l.scaleY, l.scaleY);
        _selMid.setPosition(l.targetX + l.capPx, l.targetY);
        _selMid.scale.set(l.midScaleX, l.scaleY);
        _selRight.setPosition(l.targetX + l.capPx + l.midPx, l.targetY);
        _selRight.scale.set(l.scaleY, l.scaleY);
    }

    function _updateSelectBox():Void
    {
        if (_selLeft == null || _selMid == null || _selRight == null) return;
        final l = _calcSelectLayout();
        for (s in [_selLeft, _selMid, _selRight]) { FlxTween.cancelTweensOf(s); FlxTween.cancelTweensOf(s.scale); }
        FlxTween.tween(_selLeft,        {x: l.targetX,                    y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selLeft.scale,  {x: l.scaleY,    y: l.scaleY},                  0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selMid,         {x: l.targetX + l.capPx,          y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selMid.scale,   {x: l.midScaleX, y: l.scaleY},                  0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selRight,       {x: l.targetX + l.capPx + l.midPx, y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selRight.scale, {x: l.scaleY,    y: l.scaleY},                  0.35, {ease: FlxEase.expoOut});
    }

    function _applyScroll():Void
    {
        for (i in 0...menuItems.length)
        {
            final rawY = 180.0 + (i * 58.0) - scrollY;
            menuItems[i].y = rawY;
            final topEdge    = 180.0 - 58.0;
            final bottomEdge = 180.0 + 6 * 58.0;
            if (rawY < topEdge || rawY > bottomEdge)
                menuItems[i].alpha = 0;
            else if (rawY < 180.0)
                menuItems[i].alpha = (rawY - topEdge) / 58.0;
            else if (rawY > 180.0 + (6 - 1) * 58.0)
                menuItems[i].alpha = 1.0 - (rawY - (180.0 + (6 - 1) * 58.0)) / 58.0;
            else
                menuItems[i].alpha = 1.0;
        }
    }

    function _leftItems():Array<flixel.FlxObject>
    {
        final arr:Array<flixel.FlxObject> = [];
        for (item in menuItems) if (item != null) arr.push(item);
        if (_selLeft  != null) arr.push(_selLeft);
        if (_selMid   != null) arr.push(_selMid);
        if (_selRight != null) arr.push(_selRight);
        if (titleText      != null) arr.push(titleText);
        if (disco          != null) arr.push(disco);
        for (s in discoShadows) if (s != null) arr.push(s);
        if (nowPlaying     != null) arr.push(nowPlaying);
        if (nowPlayingSong != null) arr.push(nowPlayingSong);
        return arr;
    }

    function _lowerMusic():Void
    {
        final extrasMenu = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
        if (extrasMenu != null && extrasMenu._orphanPlayer != null)
            extrasMenu._orphanPlayer.setVolume(0.1);
        else if (FlxG.sound.music != null)
        {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 0.1}, 0.5, {ease: FlxEase.quadOut});
        }
    }

    function _restoreMusic():Void
    {
        final extrasMenu = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
        if (extrasMenu != null && extrasMenu._orphanPlayer != null)
            extrasMenu._orphanPlayer.setVolume(1.0);
        else if (FlxG.sound.music != null)
        {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 1.0}, 0.5, {ease: FlxEase.quadOut});
        }
    }

    function _slideOutLeft(onDone:Void->Void):Void
    {
        _lowerMusic();
        final left = _leftItems();
        _leftOrigX = new Map();
        _leftOrigY = new Map();
        for (item in left) { _leftOrigX.set(item, item.x); _leftOrigY.set(item, item.y); }

        var done = false;
        for (item in left)
        {
            FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {x: -item.width - 100}, 0.3, {
                ease: FlxEase.expoIn,
                onComplete: (_) -> { if (!done) { done = true; onDone(); } }
            });
        }
        FlxTween.cancelTweensOf(box);
        FlxTween.tween(box, {x: FlxG.width + 50}, 0.3, {ease: FlxEase.expoIn});
    }

    function _slideInLeft():Void
    {
        _restoreMusic();
        final left = _leftItems();
        for (item in left)
        {
            final origX = _leftOrigX.exists(item) ? _leftOrigX.get(item) : item.x;
            final origY = _leftOrigY.exists(item) ? _leftOrigY.get(item) : item.y;
            item.x = -item.width - 100;
            item.y = origY;
            FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {x: origX}, 0.3, {ease: FlxEase.expoOut});
        }
        if (box != null)
        {
            box.x = FlxG.width + 50;
            FlxTween.cancelTweensOf(box);
            FlxTween.tween(box, {x: 750.0}, 0.3, {ease: FlxEase.expoOut});
        }
    }

    function _openViewer():Void
    {
        final folderPath = _mode >= 2 ? _subSubfolders[_curSubSubfolder].path : _subfolders[_curSubfolder].path;
        _scanImages(folderPath);
        if (_images.length == 0) { canMove = true; return; }
        _curImage = 0;
        _imgOpen  = true;
        canMove   = false;
        _slideOutLeft(() -> _showImage(0, 0));
    }

    function _showImage(index:Int, direction:Int):Void
    {
        _curImage = index;
        final path = _images[index];

        #if VIDEOS_ALLOWED
        if (_isVideo(path))
        {
            _clearImageSprites();
            _openVideoItem(path, index, direction);
            return;
        }
        #end

        var bmp:BitmapData = null;
        try
        {
            #if mobile
            bmp = Paths.getBitmapData(path, false);
            #else
            bmp = BitmapData.fromFile(path);
            #end
        }
        catch (_:Dynamic) {}

        if (bmp == null)
            bmp = new BitmapData(4, 4, false, 0xFF888888);

        final maxW = FlxG.width  * 0.72;
        final maxH = FlxG.height * 0.68;
        final s    = Math.min(maxW / bmp.width, maxH / bmp.height);
        final fw   = Math.floor(bmp.width  * s);
        final fh   = Math.floor(bmp.height * s);

        final oldSprite  = _imgSprite;
        final oldBorder  = _imgBorder;
        final oldCounter = _imgCounter;

        _imgBorder = new FlxSprite(0, 0);
        _imgBorder.makeGraphic(fw + Std.int(6.0 * 2), fh + Std.int(6.0 * 2), 0xFFf48000);
        final bsh = new shaders.RoundedBorderShader(16.0 + 6.0, 0.0, 0xFF000000);
        bsh.setSize(fw + Std.int(6.0 * 2), fh + Std.int(6.0 * 2));
        _imgBorder.shader = bsh;
        add(_imgBorder);

        _imgSprite = new FlxSprite(0, 0);
        _imgSprite.loadGraphic(bmp);
        _imgSprite.setGraphicSize(fw, fh);
        _imgSprite.updateHitbox();
        _imgSprite.antialiasing = ClientPrefs.data.antialiasing;
        final ish = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000);
        ish.setSize(fw, fh);
        _imgSprite.shader = ish;
        add(_imgSprite);

        final cx = (FlxG.width  - fw) * 0.5;
        final cy = (FlxG.height - fh) * 0.5 - 20;

        _imgBorder.setPosition(cx - 6.0, cy - 6.0);
        _imgSprite.setPosition(cx, cy);
        _imgBorder.alpha = 0;
        _imgSprite.alpha = 0;

        final slideOffset:Float = FlxG.width * 0.18;
        final startX = cx + (direction >= 0 ? slideOffset : -slideOffset);
        _imgSprite.x = startX;
        _imgBorder.x = startX - 6.0;

        if (oldSprite != null)
        {
            final exitX = cx + (direction >= 0 ? -slideOffset : slideOffset);
            FlxTween.cancelTweensOf(oldSprite);
            FlxTween.cancelTweensOf(oldBorder);
            FlxTween.tween(oldSprite, {x: exitX, alpha: 0}, 0.3, {ease: FlxEase.expoIn, onComplete: (_) -> {
                remove(oldSprite, true); oldSprite.destroy();
            }});
            FlxTween.tween(oldBorder, {x: exitX - 6.0, alpha: 0}, 0.3, {ease: FlxEase.expoIn, onComplete: (_) -> {
                remove(oldBorder, true); oldBorder.destroy();
            }});
        }

        FlxTween.tween(_imgSprite,  {x: cx,          alpha: 1}, 0.3, {ease: FlxEase.expoOut, onComplete: (_) -> canMove = true});
        FlxTween.tween(_imgBorder,  {x: cx - 6.0,    alpha: 1}, 0.3, {ease: FlxEase.expoOut});

        if (oldCounter != null) { remove(oldCounter, true); oldCounter.destroy(); }

        _imgCounter = new FlxText(0, cy + fh + 22, FlxG.width, '${index + 1} / ${_images.length}', 28);
        _imgCounter.setFormat(Paths.font("bigass.otf"), 28, FlxColor.WHITE, CENTER);
        _imgCounter.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 3);
        _imgCounter.antialiasing = ClientPrefs.data.antialiasing;
        add(_imgCounter);
    }

    function _clearImageSprites():Void
    {
        if (_imgSprite  != null) { remove(_imgSprite,  true); _imgSprite.destroy();  _imgSprite  = null; }
        if (_imgBorder  != null) { remove(_imgBorder,  true); _imgBorder.destroy();  _imgBorder  = null; }
        if (_imgCounter != null) { remove(_imgCounter, true); _imgCounter.destroy(); _imgCounter = null; }
    }

    #if VIDEOS_ALLOWED
    function _openVideoItem(path:String, index:Int, direction:Int):Void
    {
        _vidOpen = true;
        canMove  = false;

        _vidBorder = new FlxSprite(0, 0);
        _vidBorder.makeGraphic(1, 1, 0xFFf48000);
        _vidBorder.alpha = 0;
        add(_vidBorder);

        _vidSprite = new VideoSprite(0, 0, false);
        _vidSprite.onFormat(() -> {
            final maxW = FlxG.width  * 0.72;
            final maxH = FlxG.height * 0.68;
            
            final s    = Math.min(maxW / _vidSprite.video.width, maxH / _vidSprite.video.height);
            final fw   = Math.floor(_vidSprite.video.width  * s);
            final fh   = Math.floor(_vidSprite.video.height * s);
            
            _vidSprite.setGraphicSize(fw, fh);

            final cx = (FlxG.width  - fw) * 0.5;
            final cy = (FlxG.height - fh) * 0.5 - 20;
            _vidSprite.setPosition(cx, cy);

            final slideOffset:Float = FlxG.width * 0.18;
            final startX = cx + (direction >= 0 ? slideOffset : -slideOffset);
            _vidSprite.x  = startX;
            _vidBorder.x  = startX - 6.0;
            _vidSprite.alpha = 0;

            final vidShader = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000);
            vidShader.setSize(fw, fh);
            
            _vidSprite.video.shader = vidShader;

            final bw = fw + Std.int(6.0 * 2);
            final bh = fh + Std.int(6.0 * 2);
            _vidBorder.makeGraphic(bw, bh, 0xFFf48000);
            _vidBorder.setPosition(startX - 6.0, cy - 6.0);
            final borderShader = new shaders.RoundedBorderShader(16.0 + 6.0, 0.0, 0xFF000000);
            borderShader.setSize(bw, bh);
            _vidBorder.shader = borderShader;

            if (_imgCounter != null) { remove(_imgCounter, true); _imgCounter.destroy(); _imgCounter = null; }
            _imgCounter = new FlxText(0, cy + fh + 22, FlxG.width, '${index + 1} / ${_images.length}', 28);
            _imgCounter.setFormat(Paths.font("bigass.otf"), 28, FlxColor.WHITE, CENTER);
            _imgCounter.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 3);
            _imgCounter.antialiasing = ClientPrefs.data.antialiasing;
            add(_imgCounter);

            FlxTween.tween(_vidSprite,  {x: cx,         alpha: 1}, 0.3, {ease: FlxEase.expoOut, onComplete: (_) -> canMove = true});
            FlxTween.tween(_vidBorder,  {x: cx - 6.0,   alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        });
        
        _vidSprite.onEnd(() -> { _vidSprite.play(); });
        add(_vidSprite);
        
        if (_vidSprite.loadVideo(path, [VideoSprite.ARG_LOOPING]))
            _vidSprite.playDelayed();
    }

    function _closeVideo():Void
    {
        if (!_vidOpen) return;
        _vidOpen = false;
        _imgOpen = false;
        canMove  = false;

        final vidRef    = _vidSprite;
        final borderRef = _vidBorder;
        _vidSprite = null;
        _vidBorder = null;

        if (_imgCounter != null) { remove(_imgCounter, true); _imgCounter.destroy(); _imgCounter = null; }

        if (vidRef != null)
        {
            vidRef.stop();
            final exitX = -vidRef.width - 50;
            FlxTween.tween(vidRef,    {x: exitX, alpha: 0}, 0.3, {ease: FlxEase.expoIn, onComplete: (_) -> { remove(vidRef,    true); vidRef.destroy(); }});
            FlxTween.tween(borderRef, {x: exitX - 6.0, alpha: 0}, 0.3, {ease: FlxEase.expoIn, onComplete: (_) -> {
                remove(borderRef, true); borderRef.destroy();
                _slideInLeft();
                canMove = true;
            }});
        }
        else
        {
            if (borderRef != null) { remove(borderRef, true); borderRef.destroy(); }
            _slideInLeft();
            canMove = true;
        }
    }

    function _closeVideoSilent():Void
    {
        if (!_vidOpen) return;
        _vidOpen = false;
        final vidRef    = _vidSprite;
        final borderRef = _vidBorder;
        _vidSprite = null;
        _vidBorder = null;
        if (_imgCounter != null) { remove(_imgCounter, true); _imgCounter.destroy(); _imgCounter = null; }
        if (vidRef != null)
        {
            vidRef.stop();
            remove(vidRef,    true); vidRef.destroy();
        }
        if (borderRef != null) { remove(borderRef, true); borderRef.destroy(); }
    }
    #end

    function _closeViewer():Void
    {
        #if VIDEOS_ALLOWED
        if (_vidOpen) { _closeVideo(); return; }
        #end

        _imgOpen = false;
        canMove  = false;

        final toSlide:Array<flixel.FlxBasic> = [];
        if (_imgSprite  != null) toSlide.push(_imgSprite);
        if (_imgBorder  != null) toSlide.push(_imgBorder);
        if (_imgCounter != null) toSlide.push(_imgCounter);

        var done = false;
        if (toSlide.length > 0)
        {
            for (obj in toSlide)
            {
                FlxTween.cancelTweensOf(obj);
                FlxTween.tween(obj, {y: -FlxG.height}, 0.3, {
                    ease: FlxEase.expoIn,
                    onComplete: (_) -> {
                        if (!done)
                        {
                            done = true;
                            _clearImageSprites();
                            _slideInLeft();
                            canMove = true;
                        }
                    }
                });
            }
        }
        else
        {
            _slideInLeft();
            canMove = true;
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (nowPlayingSong != null)
        {
            final daName  = states.extras.dagarden.DAGarden.currentSong;
            final display = daName != '' ? daName.toUpperCase() : 'EXTRAS MENU';
            if (nowPlayingSong.text != display) nowPlayingSong.text = display;
        }

        if (disco != null && discoShadows != null)
            for (s in discoShadows) s.angle = disco.angle;

        #if VIDEOS_ALLOWED
        if (_vidOpen)
        {
            if (!canMove) return;
            if (controls.UI_LEFT_P || FlxG.keys.justPressed.A)
            {
                if (_curImage > 0)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    canMove = false;
                    _closeVideoSilent();
                    _showImage(_curImage - 1, -1);
                }
            }
            else if (controls.UI_RIGHT_P || FlxG.keys.justPressed.D)
            {
                if (_curImage < _images.length - 1)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    canMove = false;
                    _closeVideoSilent();
                    _showImage(_curImage + 1, 1);
                }
            }
            else if (controls.BACK)
            {
                _closeVideo();
            }
            return;
        }
        #end

        if (_imgOpen)
        {
            if (!canMove) return;
            if (controls.UI_LEFT_P || FlxG.keys.justPressed.A)
            {
                if (_curImage > 0)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    canMove = false;
                    _showImage(_curImage - 1, -1);
                }
            }
            else if (controls.UI_RIGHT_P || FlxG.keys.justPressed.D)
            {
                if (_curImage < _images.length - 1)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    canMove = false;
                    _showImage(_curImage + 1, 1);
                }
            }
            else if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                _closeViewer();
            }
            return;
        }

        scrollY = FlxMath.lerp(scrollY, scrollYTarget, 0.12);
        _applyScroll();

        if (!canMove) return;

        if (controls.UI_UP_P)   changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        if (controls.ACCEPT)
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            canMove = false;
            FlxTween.cancelTweensOf(menuItems[curSelected].scale);
            FlxTween.tween(menuItems[curSelected].scale, {x: 0.575, y: 0.575}, 0.1, {
                ease: FlxEase.backOut,
                onComplete: (_) -> FlxTween.tween(menuItems[curSelected].scale, {x: 0.525, y: 0.525}, 0.15, {
                    ease: FlxEase.smootherStepInOut,
                    onComplete: (_) -> _onAccept()
                })
            });
        }

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            if (_mode == 0)
            {
                close();
            }
            else
            {
                _mode = _mode - 1;
                _buildMenu();
                changeSelection(0);
                canMove = true;
            }
        }
    }

    function _onAccept():Void
    {
        if (_mode == 0)
        {
            _curCategory = curSelected;
            final catPath = 'assets/exe/extras/gallery/${CATEGORIES[_curCategory].name}';
            _scanSubfolders(catPath);
            _mode = 1;
            _buildMenu();
            changeSelection(0);
            canMove = true;
        }
        else if (_mode == 1)
        {
            if (_subfolders.length == 0) { canMove = true; return; }
            _curSubfolder = curSelected;
            _scanSubSubfolders(_subfolders[_curSubfolder].path);
            if (_subSubfolders.length == 0)
            {
                _imgOpen = true;
                canMove  = false;
                _scanImages(_subfolders[_curSubfolder].path);
                if (_images.length == 0) { _imgOpen = false; canMove = true; return; }
                _curImage = 0;
                _slideOutLeft(() -> _showImage(0, 0));
                return;
            }
            _mode = 2;
            _buildMenu();
            changeSelection(0);
            canMove = true;
        }
        else if (_mode == 2)
        {
            if (_subSubfolders.length == 0) { canMove = true; return; }
            _curSubSubfolder = curSelected;
            _openViewer();
        }
    }

    override function destroy() 
    {
        if (box != null) 
        { 
            FlxTween.cancelTweensOf(box); 
            FlxTween.cancelTweensOf(box.scale); 
        }
            
        if (disco != null)
            FlxTween.cancelTweensOf(disco);

        for (s in [_selLeft, _selMid, _selRight]) 
        {
            if (s != null) 
            { 
                FlxTween.cancelTweensOf(s); 
                FlxTween.cancelTweensOf(s.scale); 
            }
        }

        for (item in menuItems) 
        {
            if (item != null) 
            { 
                FlxTween.cancelTweensOf(item); 
                FlxTween.cancelTweensOf(item.scale); 
            }
        }

        super.destroy();
    }
}