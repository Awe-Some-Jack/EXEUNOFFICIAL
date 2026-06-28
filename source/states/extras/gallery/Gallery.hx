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
import openfl.Assets;

class Gallery extends MusicBeatSubstate
{
    static inline final BOX_FINAL_X:Float       = 750.0;
    static inline final BOX_FINAL_Y:Float       = 120.0;
    static inline final BOX_FINAL_SCALE:Float   = 0.3;
    static inline final BOX_ANIM_DURATION:Float = 0.5;

    static inline final MENU_START_Y:Float          = 180.0;
    static inline final MENU_SPACING:Float          = 58.0;
    static inline final MENU_START_X:Float          = 50.0;
    static inline final MENU_FONT_SIZE:Int          = 88;
    static inline final MENU_SCALE_DURATION:Float   = 0.2;
    static inline final SELECTION_TWEEN_DURATION:Float = 0.2;

    var checkers:FlxBackdrop;
    var box:FlxSprite;
    var disco:FlxSprite;
    var discoShadows:Array<FlxSprite> = [];
    var titleText:FlxText;
    var nowPlaying:FlxText;
    var nowPlayingSong:FlxText;

    var menuItems:Array<FlxText> = [];
    var selectBox:FlxSprite;
    var curSelected:Int = 0;
    var canMove:Bool = true;

    static final CATEGORIES:Array<{name:String, label:String}> = [
        {name: 'wips',    label: 'WIPS'},
        {name: 'devs',    label: 'DEVS'},
        {name: 'memes',   label: 'MEMES'},
        {name: 'sprites', label: 'SPRITES'},
    ];

    override public function create():Void
    {
        super.create();

        createBackground();
        createBox();
        createDisco();
        _buildMenu();
        changeSelection(0);

        titleText = new FlxText(49, 68, 0, Language.getArray('extras.menu.gallery', ['GALLERY', ''])[0], 88);
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

        final descTemp = new FlxText(0, 0, 0, Language.getArray('extras.menu.gallery', ['', 'Browse WIPs, dev stuff, memes and sprites from the team!'])[1], 56);
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

    }

    function createBackground():Void
    {
        final w:Int = FlxG.width;
        final h:Int = FlxG.height;
        final bmd = new openfl.display.BitmapData(w, h, false, 0xFFbd0033);
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
        final background = new FlxSprite(0, 0);
        background.loadGraphic(bmd);
        add(background);

        final tileSize:Int = 40;
        final cbmd = new openfl.display.BitmapData(tileSize * 2, tileSize * 2, true, 0x00000000);
        cbmd.fillRect(new openfl.geom.Rectangle(0,        0,        tileSize, tileSize), 0xFF3d0008);
        cbmd.fillRect(new openfl.geom.Rectangle(tileSize, 0,        tileSize, tileSize), 0xFF831826);
        cbmd.fillRect(new openfl.geom.Rectangle(0,        tileSize, tileSize, tileSize), 0xFF831826);
        cbmd.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF3d0008);
        checkers = new FlxBackdrop(cbmd, XY, 0, 0);
        checkers.alpha = 0.10;
        checkers.velocity.x = -60;
        add(checkers);
    }

    function createBox():Void
    {
        box = new FlxSprite(BOX_FINAL_X, BOX_FINAL_Y);
        box.loadGraphic(Assets.getBitmapData("assets/exe/extras/box.png"));
        box.scale.set(BOX_FINAL_SCALE, BOX_FINAL_SCALE);
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
            final s = new FlxSprite(61 + offset.x, 541 + offset.y);
            s.loadGraphic(discoBmp);
            s.scale.set(0.29, 0.29);
            s.updateHitbox();
            s.color = FlxColor.BLACK;
            s.alpha = 0.3;
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
        for (i in 0...CATEGORIES.length)
        {
            final lbl = new FlxText(MENU_START_X, MENU_START_Y + (i * MENU_SPACING), 0, CATEGORIES[i].label, MENU_FONT_SIZE);
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

        selectBox = new FlxSprite(0, 0);
        selectBox.loadGraphic("assets/exe/extras/select.png");
        selectBox.scale.set(0.31, 0.28);
        selectBox.updateHitbox();
        add(selectBox);
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected += change;
        if (curSelected < 0) curSelected = menuItems.length - 1;
        if (curSelected >= menuItems.length) curSelected = 0;

        if (change != 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            animateBox();
        }

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
        final targetY = MENU_START_Y + (curSelected * MENU_SPACING) - 10;
        FlxTween.cancelTweensOf(selectBox);
        FlxTween.cancelTweensOf(selectBox.scale);
        FlxTween.tween(selectBox, {x: MENU_START_X - 10, y: targetY}, SELECTION_TWEEN_DURATION, {ease: FlxEase.smootherStepInOut});
        FlxTween.tween(selectBox.scale, {x: 0.33, y: 0.30}, MENU_SCALE_DURATION, {ease: FlxEase.smootherStepInOut});
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

        if (!canMove) return;

        if (controls.UI_UP_P)   changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        if (controls.ACCEPT)
            _selectCurrent();

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
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
                    onComplete: (_) -> canMove = true
                });
            }
        });
    }

    override public function destroy():Void
    {
        if (box      != null) { FlxTween.cancelTweensOf(box);      FlxTween.cancelTweensOf(box.scale); }
        if (disco    != null) FlxTween.cancelTweensOf(disco);
        if (selectBox != null) { FlxTween.cancelTweensOf(selectBox); FlxTween.cancelTweensOf(selectBox.scale); }
        for (item in menuItems)
            if (item != null) { FlxTween.cancelTweensOf(item); FlxTween.cancelTweensOf(item.scale); }
        box            = null;
        disco          = null;
        titleText      = null;
        nowPlaying     = null;
        nowPlayingSong = null;
        selectBox      = null;
        menuItems      = null;
        super.destroy();
    }
}
