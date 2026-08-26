package states.extras;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;

import openfl.display.BitmapData;

import states.EXEMenu;

import hxvlc.flixel.FlxVideoSprite;

import states.extras.menuProps.CardSprite;
import states.extras.menuProps.Arrow;
import shaders.ColorShiftShader;
#if !flash
import openfl.filters.ShaderFilter;
#end

class OrbitSprite extends FlxSprite
{
    public var centerX:Float = 0;
    public var centerY:Float = 0;
    public var radius:Float = 40.0;
    public var speed:Float = 2.5;
    public var angleOffset:Float = 0.0;

    private var timer:Float = 0.0;

    public function new(x:Float = 0, y:Float = 0, ?imagePath:String)
    {
        super(x, y);

        if (imagePath != null)
            loadGraphic(Paths.getBitmapData(imagePath));
    }

    public function setCenterFromCurrentPos():Void
    {
        centerX = x;
        centerY = y;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        timer += speed * elapsed;

        x = centerX + Math.cos(timer + angleOffset) * radius;
        y = centerY + Math.sin(timer + angleOffset) * radius;
    }
}

class ExtrasMenu extends MusicBeatState
{
    static final MENU_KEYS = [
        "extras.menu.dagarden",
        "extras.menu.cutscenes",
        "extras.menu.achievements",
        "extras.menu.credits"
    ];

    var menuItems:Array<FlxText>      = [];
    var descBackdrops:Array<FlxBackdrop> = [];
    var curSelected:Int  = 0;
    var canMove:Bool     = true;
    var cooldownTimer:Float = #if mobile 0.15; #else 0.1; #end

    // select box for the selection shit 
    var _selLeft:FlxSprite;
    var _selMid:FlxSprite;
    var _selRight:FlxSprite;
    var disco:FlxSprite;
    var arrowsGrp:FlxTypedGroup<Arrow>;
    var arrowLeft:Arrow;
    var arrowRight:Arrow;
    var box:FlxSprite;
    var sumky:FlxSprite;
    var np:FlxText;
    var nowPlayingSong:FlxText;
    var extrasLogo:FlxSprite;

    var luis:OrbitSprite;
    var lordX:OrbitSprite;

    var baseScale:Float = 1.;
    var ssGrp:FlxTypedGroup<CardSprite>;
    var ssBoxGrp:FlxTypedGroup<FlxSprite>;
    
    var globalTime:Float = 0.0;

    override function create():Void
    {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        buildBG();
        buildVideos();
        buildBox();
        buildDisco();
        buildLogo();
        buildMenu();
        buildDescBar();
        changeSelection(0);

        FlxG.sound.playMusic(OpenFlAssets.getSound('assets/exe/extras/music/ExtrasMenu.ogg'));

        np = new FlxText(169, 558, 0, Language.get('extras.menu.nowplaying', 'NOW PLAYING:'), 60);
        np.setFormat(Paths.font("bigass.otf"), 60, FlxColor.BLACK, LEFT);
        np.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        np.scale.set(0.22, 0.22);
        np.updateHitbox();
        np.antialiasing = ClientPrefs.data.antialiasing;
        add(np);

        final daName = states.extras.dagarden.DAGarden.currentSong;
        nowPlayingSong = new FlxText(169, np.y + np.height + 6, -1, daName != '' ? daName.toUpperCase() : 'EXTRAS MENU', 60);
        nowPlayingSong.setFormat(Paths.font("bigass.otf"), 70, FlxColor.BLACK, LEFT);
        nowPlayingSong.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        nowPlayingSong.scale.set(0.22, 0.22);
        nowPlayingSong.updateHitbox();
        nowPlayingSong.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlayingSong);
    
        arrowsGrp = new FlxTypedGroup<Arrow>();
        add(arrowsGrp);
        
        arrowLeft = new Arrow(nowPlayingSong.x+8, nowPlayingSong.y, flixel.input.keyboard.FlxKey.LEFT, 180);
        arrowLeft.x = (nowPlayingSong.x + nowPlayingSong.width)+15;
        arrowLeft.y = (nowPlayingSong.y + nowPlayingSong.height)-arrowLeft.height;
        arrowLeft.onDown.add(event->{
            trace("aqui va la logica de cuando presionas la tecla flecha bro, es un justPressed btw\npodemos acceder a su evento: "+event.toString()+"\ncomo tmb cancelarlo! con 'event.cancel();'");
        });
        arrowLeft.onUp.add(event->{
            trace("aqui va la logica de cuando sueltas la tecla flecha bro, es un justReleased btw\npodemos acceder a su evento: "+event.toString()+"\ncomo tmb cancelarlo! con 'event.cancel();'");
        });
        arrowsGrp.add(arrowLeft);

        arrowRight = new Arrow(arrowLeft.x + 20, arrowLeft.y, flixel.input.keyboard.FlxKey.RIGHT, 0);
        arrowRight.x = (arrowLeft.x + arrowLeft.width) + 8;
        arrowRight.onDown.add(event->{
            trace("aqui va la logica de cuando presionas la tecla flecha bro, es un justPressed btw\npodemos acceder a su evento: "+event.toString()+"\ncomo tmb cancelarlo! con 'event.cancel();'");
        });
        arrowRight.onUp.add(event->{
            trace("aqui va la logica de cuando sueltas la tecla flecha bro, es un justReleased btw\npodemos acceder a su evento: "+event.toString()+"\ncomo tmb cancelarlo! con 'event.cancel();'");
        });
        arrowsGrp.add(arrowRight); 

        #if DISCORD_ALLOWED DiscordClient.changePresence("In the Extras", null); #end

        super.create();

        SonicRetroTransition.init();
        SonicRetroTransition.play(false, 0.5);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        globalTime += elapsed;

        if (ssGrp != null)
        {
            for (i in 0...ssGrp.members.length)
                objBehavior(i, elapsed);
        }

        if (nowPlayingSong != null)
        {
            final daName  = states.extras.dagarden.DAGarden.currentSong;
            final display = daName != '' ? daName.toUpperCase() : 'EXTRAS MENU';
            if (nowPlayingSong.text != display) nowPlayingSong.text = display;
        }

        if (!canMove) return;

        if (controls.UI_UP_P)   changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        #if mobile
        if(pressHolding && deltaMouseY != 0 && cooldownTimer <= 0)
            if(deltaMouseY > 5)
                changeSelection(1);
            else if(deltaMouseY < -5)
                changeSelection(-1);
        #else
        var mouseWheel = FlxG.mouse.wheel;
        if (mouseWheel != 0 && cooldownTimer <= 0){
            changeSelection(mouseWheel > 0 ? -1 :1);
        }
        #end
        
        if (cooldownTimer > 0) cooldownTimer -= elapsed;

        if (controls.ACCEPT #if mobile || (shortPress && FlxG.mouse.overlaps(menuItems[curSelected])) #end)    selectOption();

        if (controls.BACK)
        {
            canMove = false;
            FlxG.sound.music?.fadeOut(0.3);

            states.extras.dagarden.DAGarden.stopPersisted();
            FlxG.switchState(() -> new EXEMenu());
        }

        #if !mobile
        if (FlxG.mouse.justMoved){
            FlxG.mouse.visible = true;
        }
        #end

        if (FlxG.sound.music.playing){
            discoTween.active = true;
        }else{
            discoTween.active = false;
        }

        if (FlxG.mouse.justPressed && disco != null && disco.overlapsPoint(new flixel.math.FlxPoint(FlxG.mouse.x, FlxG.mouse.y)))
        {
            if (FlxG.sound.music != null)
            {
                if (FlxG.sound.music.playing) FlxG.sound.music.pause();
                else FlxG.sound.music.resume();
            }
        }
    }

    // finally
    function buildVideos():Void
    {
        ssGrp = new FlxTypedGroup<CardSprite>();
        add(ssGrp);

        ssBoxGrp = new FlxTypedGroup<FlxSprite>();
        add(ssBoxGrp);

        final baseImages:Array<Int> = [1, 2, 3, 4, 5];
        FlxG.random.shuffle(baseImages);

        final extraImage:Int = FlxG.random.getObject(baseImages);
        final imageList:Array<Int> = baseImages.copy();
        imageList.push(extraImage);

        FlxG.random.shuffle(imageList);

        for (i in 0...6)
        {
            final spr = new CardSprite();
            
            final videoName:String = Std.string(imageList[i]);
            spr.loadVideoCard(Paths.video('extrasMenu/$videoName')); 

            var rightEdge = FlxG.width - 300;
            switch (i) {
                case 0:
                    spr.finalX = rightEdge - 200;
                    spr.finalY = 20;
                case 1:
                    spr.finalX = rightEdge - 20;
                    spr.finalY = 120;
                case 2:
                    spr.finalX = rightEdge - 250;
                    spr.finalY = 220;
                case 3:
                    spr.finalX = rightEdge - 60;
                    spr.finalY = 320;
                case 4:
                    spr.finalX = rightEdge - 180;
                    spr.finalY = 420;
                case 5:
                    spr.finalX = rightEdge;
                    spr.finalY = 510;
            }

            baseScale = spr.scale.x;

            spr.blend = ALPHA;
            spr.ID = i;
            // spr.color = 0xFFBB102F;

            spr.x = spr.finalX;
            spr.y = spr.finalY;
            spr.alpha = spr.targetAlpha;
            spr.introDone = true;

            ssGrp.add(spr);
        }
    }

    public function objBehavior(idx:Int = 0, elapsed:Float = 0)
    {
        final spr = ssGrp.members[idx];
        if (spr == null || !spr.introDone) return;

        final linearDrift = Math.sin(globalTime * 0.8 + idx * 0.5) * 50;
        spr.x = spr.finalX + linearDrift;
        spr.y = spr.finalY + linearDrift * 0.5;

        final rotDirection = (idx % 2 == 0) ? 1 : -1;
        spr.angle += rotDirection * (8 + idx * 2.0) * elapsed;

        spr.alpha = spr.targetAlpha + Math.sin(globalTime * 1.5 + idx) * 0.1;
    }

    override function openSubState(subState:flixel.FlxSubState):Void
    {
        canMove = false;
        if (np != null) np.visible = false;
        if (nowPlayingSong != null) nowPlayingSong.visible = false;
        super.openSubState(subState);
    }

    override function closeSubState():Void
    {
        canMove = true;
        if (np != null) np.visible = true;
        if (nowPlayingSong != null) nowPlayingSong.visible = true;

        super.closeSubState();
    }

    override public function destroy():Void
    {
        FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
        super.destroy();
    }

    function buildBG():Void
    {
        final w   = FlxG.width;
        final h   = FlxG.height;
        final bmd = new openfl.display.BitmapData(w, h, false, 0xFFbd0033);
        for (x in 0...w)
        {
            final t = x / (w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final g = Math.round(0x00 + (0x00 - 0x00) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            bmd.fillRect(new openfl.geom.Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | (g << 8) | b);
        }
        add(new FlxSprite().loadGraphic(bmd));

        final ts   = 40;
        final cbmd = new openfl.display.BitmapData(ts * 2, ts * 2, true, 0x00000000);
        cbmd.fillRect(new openfl.geom.Rectangle(0,  0,  ts, ts), 0xFF3d0008);
        cbmd.fillRect(new openfl.geom.Rectangle(ts, 0,  ts, ts), 0xFF831826);
        cbmd.fillRect(new openfl.geom.Rectangle(0,  ts, ts, ts), 0xFF831826);
        cbmd.fillRect(new openfl.geom.Rectangle(ts, ts, ts, ts), 0xFF3d0008);
        final ch = new FlxBackdrop(cbmd, XY, 0, 0);
        ch.alpha      = 0.10;
        ch.velocity.x = -60;
        add(ch);

        final fadeBmd = new openfl.display.BitmapData(w, h, true, 0x00000000);
        for (x in 0...w)
        {
            final t = x / (w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            final a = Math.round((1.0 - t) * 255);
            fadeBmd.fillRect(new openfl.geom.Rectangle(x, 0, 1, h), (a << 24) | (r << 16) | b);
        }
        add(new FlxSprite().loadGraphic(fadeBmd));
    }

    function buildBox():Void
    {
        luis = new OrbitSprite(0, 0, "assets/exe/extras/luis.webp");
        luis.scale.set(0.07, 0.07);
        luis.updateHitbox();
        luis.screenCenter();
        luis.x += 475;
        luis.y -= 50;
        luis.angle += 15;
        luis.radius = 20;
        luis.speed = 0.75;
        luis.setCenterFromCurrentPos();
        add(luis);

        lordX = new OrbitSprite(0, 0, "assets/exe/extras/lordx.webp");
        lordX.scale.set(0.07, 0.07);
        lordX.updateHitbox();
        lordX.screenCenter();
        lordX.x += 200;
        lordX.y -= 50;
        lordX.radius = 20;
        lordX.speed = 0.75;
        lordX.angleOffset = Math.PI;
        lordX.setCenterFromCurrentPos();
        add(lordX);
        
        box = new FlxSprite(750, 120).loadGraphic(Paths.getBitmapData("assets/exe/extras/box.webp"));
        box.scale.set(0.3, 0.3);
        box.updateHitbox();
        add(box);

        sumky = new FlxSprite(box.x - 75, box.y + 2);
        sumky.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(
            Paths.getBitmapData('assets/exe/extras/sumky.webp'),
            openfl.utils.Assets.getText('assets/exe/extras/sumky.xml')
        );
        sumky.animation.addByPrefix('idle', 'sunki instancia', 12, true);
        sumky.animation.play('idle');
        sumky.scale.set(0.64, 0.64);
        sumky.updateHitbox();
        add(sumky);
    }

    var discoTween:FlxTween;
    function buildDisco():Void
    {
        final bmp = Paths.getBitmapData("assets/exe/extras/disco.webp");
        for (off in [{x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2}, {x: -2, y: 0}, {x: 2, y: 0}, {x: -2, y: 2}, {x: 0, y: 2}, {x: 2, y: 2}])
        {
            final s = new FlxSprite(61 + off.x, 541 + off.y).loadGraphic(bmp);
            s.scale.set(0.29, 0.29);
            s.updateHitbox();
            s.color = FlxColor.BLACK;
            s.alpha  = 0.3;
            add(s);
        }
        disco = new FlxSprite(61, 541).loadGraphic(bmp);
        disco.scale.set(0.29, 0.29);
        disco.updateHitbox();
        add(disco);
        discoTween = FlxTween.angle(disco, 0, 360, 3.0, {type: LOOPING});
    }

    function buildLogo():Void
    {
        extrasLogo = new FlxSprite(49, 54).loadGraphic(Paths.getBitmapData("assets/exe/extras/extrasss.webp"));
        extrasLogo.scale.set(0.32, 0.32);
        extrasLogo.updateHitbox();
        add(extrasLogo);
    }

    function buildMenu():Void
    {
        for (i in 0...MENU_KEYS.length)
        {
            final label = Language.getArray(MENU_KEYS[i], ['?', ''])[0];
            final t = new FlxText(50, 180 + i * 58, 0, label, Language.cjkSize(88));
            t.setFormat(Paths.font("bigass.otf"), Language.cjkSize(88), FlxColor.WHITE, LEFT);
            t.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, Language.cjkBorder(8));
            t.antialiasing = ClientPrefs.data.antialiasing;
            t.scale.set(0.5, 0.5);
            t.updateHitbox();
            t.ID = i;
            add(t);
            menuItems.push(t);
        }
        final selBmp = Paths.getBitmapData("assets/exe/extras/select.webp");
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

        _snapSelectBox();
    }

    function buildDescBar():Void
    {
        final gradH = 30;
        final bar   = new FlxSprite(0, 670 - gradH);
        bar.makeGraphic(FlxG.width, 100 + gradH, FlxColor.TRANSPARENT, true);
        for (i in 0...gradH)
            bar.pixels.fillRect(new openfl.geom.Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGBFloat(0, 0, 0, (i / gradH) * 0.3));
        bar.pixels.fillRect(new openfl.geom.Rectangle(0, gradH, FlxG.width, 100), FlxColor.fromRGBFloat(0, 0, 0, 0.3));
        add(bar);

        for (i in 0...MENU_KEYS.length)
        {
            final desc = Language.getArray(MENU_KEYS[i], ['', ''])[1];
            final tmp  = new FlxText(0, 0, 0, desc, Language.cjkSize(56));
            tmp.setFormat(Paths.font(Language.fontOrCJK("smallass.ttf")), Language.cjkSize(56), FlxColor.WHITE, LEFT);
            tmp.antialiasing = ClientPrefs.data.antialiasing;
            tmp.drawFrame(true);
            final bd = new FlxBackdrop(tmp.graphic, X, 0, 0);
            bd.scale.set(0.5, 0.5);
            bd.updateHitbox();
            bd.y          = 675;
            bd.velocity.x = -30;
            bd.visible    = (i == 0);
            add(bd);
            descBackdrops.push(bd);
            tmp.destroy();
        }
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
        final targetY   = menuItems[curSelected].y - 16;
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
        FlxTween.tween(_selLeft,        {x: l.targetX,                     y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selLeft.scale,  {x: l.scaleY,     y: l.scaleY},                  0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selMid,         {x: l.targetX + l.capPx,           y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selMid.scale,   {x: l.midScaleX,  y: l.scaleY},                  0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selRight,       {x: l.targetX + l.capPx + l.midPx, y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selRight.scale, {x: l.scaleY,     y: l.scaleY},                  0.35, {ease: FlxEase.expoOut});
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = (curSelected + change + MENU_KEYS.length) % MENU_KEYS.length;
        #if mobile cooldownTimer = 0.15; #else cooldownTimer = 0.1; #end
        if (change != 0) { FlxG.sound.play(Paths.sound('scrollMenu')); animateBox(); }

        for (i in 0...menuItems.length)
        {
            FlxTween.cancelTweensOf(menuItems[i].scale);
            if (i == curSelected)
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, 0xFF9c3829, Language.cjkBorder(10));
                FlxTween.tween(menuItems[i].scale, {x: 0.525, y: 0.525}, 0.2, {ease: FlxEase.smootherStepInOut});
            }
            else
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, Language.cjkBorder(8));
                FlxTween.tween(menuItems[i].scale, {x: 0.5, y: 0.5}, 0.2, {ease: FlxEase.smootherStepInOut});
            }
        }

        _updateSelectBox();
        for (i in 0...descBackdrops.length)
        {
            FlxTween.cancelTweensOf(descBackdrops[i]);
            if (i == curSelected)
            {
                descBackdrops[i].visible = true;
                descBackdrops[i].alpha   = 0;
                FlxTween.tween(descBackdrops[i], {alpha: 1}, 0.25, {ease: FlxEase.smootherStepInOut});
            }
            else
            {
                FlxTween.tween(descBackdrops[i], {alpha: 0}, 0.15, {ease: FlxEase.smootherStepInOut, onComplete: (_) -> descBackdrops[i].visible = false});
            }
        }
    }

    function animateBox():Void
    {
        FlxTween.cancelTweensOf(box);
        FlxTween.cancelTweensOf(box.scale);
        if (sumky != null) FlxTween.cancelTweensOf(sumky);
        if (luis != null) FlxTween.cancelTweensOf(luis);
        if (lordX != null) FlxTween.cancelTweensOf(lordX);

        box.scale.set(0.6, 0.6);
        box.updateHitbox();
        box.x     = 200;
        box.y     = 120;
        box.alpha = 0;

        if (sumky != null) sumky.alpha = 0;
        if (luis != null) luis.alpha = 0;
        if (lordX != null) lordX.alpha = 0;

        FlxTween.tween(box, {x: 750}, 0.5, {ease: FlxEase.expoOut});
        FlxTween.tween(box, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

        if (sumky != null) FlxTween.tween(sumky, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
        if (luis != null) FlxTween.tween(luis, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
        if (lordX != null) FlxTween.tween(lordX, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

        FlxTween.tween(box.scale, {x: 0.3, y: 0.3}, 0.5, {ease: FlxEase.expoOut, onUpdate: (_) -> {
            final cx = box.x;
            final cy = box.y;
            box.updateHitbox();
            box.x = cx;
            box.y = cy;
        }});
    }

    function selectOption():Void
    {
        canMove = false;
        FlxG.sound.play(Paths.sound('confirmMenu'));
        FlxTween.cancelTweensOf(menuItems[curSelected].scale);
        FlxTween.tween(menuItems[curSelected].scale, {x: 0.575, y: 0.575}, 0.1, {ease: FlxEase.backOut, onComplete: (_) ->
            FlxTween.tween(menuItems[curSelected].scale, {x: 0.525, y: 0.525}, 0.15, {ease: FlxEase.smootherStepInOut, onComplete: (_) -> openOption()})
        });
    }

    function openOption():Void
    {
        var nextSubState:flixel.FlxSubState = null;

        switch (curSelected)
        {
            case 0: nextSubState = new states.extras.dagarden.DAGarden();
            case 1: nextSubState = new states.extras.cutscenes.Cutscene();
            case 2: nextSubState = new states.extras.achievements.AchievementsState();
            case 3: nextSubState = new states.extras.credits.CreditsState();
        }

        if (nextSubState != null)
        {
            if (Std.isOfType(nextSubState, SonicSubState)) {
                cast(nextSubState, SonicSubState).onBeforeClose = function() {
                    canMove = true;
                    if (np != null) np.visible = true;
                    if (nowPlayingSong != null) nowPlayingSong.visible = true;
                };
            }

            SonicRetroTransition.openSubState(nextSubState, 0.5, function() {
                canMove = false;
                if (np != null) np.visible = false;
                if (nowPlayingSong != null) nowPlayingSong.visible = false;
            });
        }
    }
}