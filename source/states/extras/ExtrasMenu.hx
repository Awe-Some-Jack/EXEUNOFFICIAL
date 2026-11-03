package states.extras;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;

import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import openfl.geom.Rectangle;

import states.EXEMenu;
import states.extras.menuProps.*;

import shaders.ColorShiftShader;
import shaders.ErrorHandledShader.ErrorHandledRuntimeShader;
import flixel.sound.FlxSound;

typedef ExtrasMenuThemeEntry = {
    var name:String;
    var src:String;
    var author:String;
    @:optional
    var volume:Float;
    @:optional
    var timeStamps:{
        var start:Float;
        var end:Float;
    }
}

class ExtrasMenu extends MusicBeatState
{
    static final MENU_KEYS = [
        "extras.menu.gallery",
        "extras.menu.character",
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
    var menuRenders:ExtrasMenuRenders;
    var np:FlxText;
    var nowPlayingSong:FlxText;
    var extrasLogo:FlxSprite;

    var baseScale:Float = 1.;
    var ssGrp:FlxTypedGroup<CardSprite>;
    var videoTargetScale:Array<Float> = [];
    var videoBaseAngle:Array<Float> = [];

    var globalTime:Float = 0.0;

    var checkerSprite:FlxSprite;
    var checkShader:ErrorHandledRuntimeShader;
    var checkerSpriteRight:FlxSprite;
    var checkShaderRight:ErrorHandledRuntimeShader;

    static final extrasMenuThemes:Array<ExtrasMenuThemeEntry> = [
        {
            name: "Welcome to the Extras",
            src: "extras",
            author: "MeDicenKay",
            volume: 1
        },
        {
            name: "Data Select (Reimagined)",
            src: "extras2",
            author: "MeDicenKay",
            volume: 1
        },
        {
            name: "Door Into Summer (Reimagined)",
            src: "extras4",
            author: "MeDicenKay",
            volume: 1
        },
        {
            name: "Flying Battery (Reimagined)",
            src: "extras5",
            author: "MeDicenKay",
            volume: 1
        },
        {
            name: "Chaos Garden",
            src: "chaogarden",
            author: "Kiv.FLP",
            volume: 1
        },
        {
            name: "Principle of Monotony",
            src: "extras6",
            author: "Kiv.FLP",
            volume: 1
        },
        {
            name: "Palmtree Panic \"P\" Mix (ReImagined)",
            src: "extras7",
            author: "MeDicenKay",
            volume: 1
        },
        {
            name: "Parallel Zone",
            src: "extras3",
            author: "Alex Hamud",
            volume: 1
        },
        {
            name: "Hall of Fame",
            src: "credits",
            author: "MeDicenKay ft. Suonima",
            volume: 1
        }
    ];

    public static var currentExtrasTheme:Int = 0;

    public static function getCurrentMenuTheme():ExtrasMenuThemeEntry
    {
        return extrasMenuThemes[currentExtrasTheme];
    }

    public static function playCurrentMenuTheme():Void 
    {
        FlxG.sound.playMusic(OpenFlAssets.getSound('assets/exe/music/${getCurrentMenuTheme().src}.ogg'));
        FlxG.sound.music.volume = getCurrentMenuTheme().volume;
    }

    /**
        * Returns the Current Name Theme + Theme Author
    **/
    public function getThemeLabel():String
    {
        return getCurrentMenuTheme().name + '\n${Language.getArray('extras.dagarden', ['BY'])[0].toLowerCase()} ${getCurrentMenuTheme().author}';
    }

    public static function preloadExtrasThemes(?exception:Int = -1):Void
    {
        for (i in 0...extrasMenuThemes.length)
        {
            if (i != exception)
            {
                final soundPath:String = 'assets/exe/music/${extrasMenuThemes[i].src}.ogg';
                if (openfl.utils.Assets.exists(soundPath)){
                    openfl.utils.Assets.getSound(soundPath, true);
                }
            }
        }
    }

    public function updateArrowPositions()
    {
        arrowLeft.x = nowPlayingSong.x + nowPlayingSong.width;
        arrowLeft.x += 20;
        arrowRight.x = (arrowLeft.x + arrowLeft.width) + 8;
        arrowLeft.y = nowPlayingSong.y + ((nowPlayingSong.height-arrowLeft.height)/2);
        arrowLeft.y += 4;
        arrowLeft.y -= arrowLeft.height / 2;
        arrowLeft.y += 5;
        arrowRight.y = arrowLeft.y;
    }

    public static var instance:ExtrasMenu = null;
    public static var openCutscenes:Bool = false;

    public function new()
    {
        super();

        instance ??= this;
    }

    override function create():Void
    {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        buildBG();
        buildVideos();
        buildRenders();
        buildDisco();
        buildLogo();
        buildMenu();
        buildDescBar();
        changeSelection(0);

        preloadExtrasThemes(currentExtrasTheme);
        playCurrentMenuTheme();

        @:privateAccess
        final font = switch (Language.currentKey) {
            case 'ko-KR': 'korean.ttf';
            default: 'bigass.otf';
        }

        np = new FlxText(149, 558, -1, Language.get('extras.menu.nowplaying', 'NOW PLAYING:'), 60);
        np.setFormat(Paths.font(font), 60, FlxColor.BLACK, LEFT);
        np.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        np.scale.set(0.22, 0.22);
        np.updateHitbox();
        np.antialiasing = ClientPrefs.data.antialiasing;
        add(np);

        final daName = states.extras.dagarden.DAGarden.currentSong;
        nowPlayingSong = new FlxText(149, np.y + np.height + 6, -1, daName != '' ? daName.toUpperCase() : getThemeLabel(), 60);
        nowPlayingSong.setFormat(Paths.font(font), 70, FlxColor.BLACK, LEFT);
        nowPlayingSong.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        nowPlayingSong.scale.set(0.22, 0.22);
        nowPlayingSong.updateHitbox();
        nowPlayingSong.x = np.x;
        nowPlayingSong.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlayingSong);
    
        arrowsGrp = new FlxTypedGroup<Arrow>();
        add(arrowsGrp);
        
        arrowLeft = new Arrow(nowPlayingSong.x+8, nowPlayingSong.y, FlxKey.LEFT, 180);
        arrowLeft.x = nowPlayingSong.x + nowPlayingSong.width;
        arrowLeft.x += 10;
        arrowLeft.onDown.add(event->{
            if (!canMove) {
                event.cancel();
                return;
            }
        });
        arrowLeft.onUp.add(event->{
            if (!canMove) {
                event.cancel();
                return;
            }
            navigateExtrasMenuTheme(-1);
        });
        arrowsGrp.add(arrowLeft);

        arrowRight = new Arrow(arrowLeft.x + 20, arrowLeft.y, FlxKey.RIGHT, 0);
        arrowRight.x = (arrowLeft.x + arrowLeft.width) + 8;
        arrowRight.onDown.add(event->{
            if (!canMove) {
                event.cancel();
                return;
            }
        });
        arrowRight.onUp.add(event->{
            if (!canMove) {
                event.cancel();
                return;
            }
            navigateExtrasMenuTheme(1);
        });
        arrowsGrp.add(arrowRight); 

        updateArrowPositions();

        if (openCutscenes)
        {
            openCutscenes = false;
            curSelected = 3;
            changeSelection(0);
            canMove = false;
            new FlxTimer().start(0.05, (_) -> openOption());
        }

        #if DISCORD_ALLOWED DiscordClient.changePresence("In the Extras", null); #end

        super.create();

        SonicRetroTransition.init();
        SonicRetroTransition.play(false, 0.5);

        #if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        globalTime += elapsed;

        if (checkShader != null)
            checkShader.setFloat('uTime', checkShader.getFloat('uTime') + elapsed);

        if (checkShaderRight != null)
            checkShaderRight.setFloat('uTime', checkShaderRight.getFloat('uTime') + elapsed);

        if (ssGrp != null)
        {
            for (i in 0...ssGrp.members.length)
                objBehavior(i, elapsed);
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

        if (controls.BACK #if mobile || backPressed #end)
        {
            canMove = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.sound.music?.fadeOut(0.3);

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

    static final VIDEO_LAYOUT:Array<{x:Float, y:Float, scale:Float, angle:Float, alpha:Float}> = [
        {x: 733,  y: 43,  scale: 0.81, angle: 17.7,  alpha: 0.69},
        {x: 1016, y: 55,  scale: 0.83, angle: -12.5, alpha: 0.61},
        {x: 647,  y: 256, scale: 0.77, angle: 0,     alpha: 0.54},
        {x: 759,  y: 466, scale: 0.85, angle: -21.1, alpha: 0.60},
        {x: 977,  y: 329, scale: 0.91, angle: 17.7,  alpha: 0.69},
        {x: 794,  y: 218, scale: 0.85, angle: -8.2,  alpha: 0.83},
    ];

    function buildVideos():Void
    {
        ssGrp = new FlxTypedGroup<CardSprite>();
        add(ssGrp);

        videoTargetScale = [];
        videoBaseAngle = [];

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

            final layout = VIDEO_LAYOUT[i];
            spr.finalX = layout.x;
            spr.finalY = layout.y;
            spr.angle = layout.angle;
            spr.targetAlpha = layout.alpha;
            videoTargetScale.push(layout.scale);
            videoBaseAngle.push(layout.angle);

            baseScale = layout.scale;

            spr.blend = ALPHA;
            spr.ID = i;

            spr.x = spr.finalX;
            spr.y = spr.finalY;
            spr.scale.set(layout.scale, layout.scale);
            spr.alpha = spr.targetAlpha;
            spr.introDone = true;

            ssGrp.add(spr);
        }
    }

    public function objBehavior(idx:Int = 0, elapsed:Float = 0)
    {
        final spr = ssGrp.members[idx];
        if (spr == null || !spr.introDone) return;
        final driftX = Math.sin(globalTime * 0.9 + idx * 1.3) * 22;
        final driftY = Math.cos(globalTime * 0.75 + idx * 0.9) * 18;
        spr.x = spr.finalX + driftX;
        spr.y = spr.finalY + driftY;

        if (idx < videoBaseAngle.length)
            spr.angle = videoBaseAngle[idx] + Math.sin(globalTime * 0.8 + idx * 1.1) * 5;

        spr.alpha = spr.targetAlpha;
        if (idx < videoTargetScale.length)
            spr.scale.set(videoTargetScale[idx], videoTargetScale[idx]);
    }

    override function openSubState(subState:flixel.FlxSubState):Void
    {
        canMove = false;
        super.openSubState(subState);
    }

    function releaseSubStateMemory():Void
    {
        if (_requestSubStateReset)
        {
            FlxG.signals.postUpdate.addOnce(releaseSubStateMemory);
            return;
        }
        FlxG.bitmap.clearUnused();
        backend.MemoryUtil.clearMinor();
    }

    override function closeSubState():Void
    {
        canMove = true;
        super.closeSubState();
        FlxG.signals.postUpdate.addOnce(releaseSubStateMemory);
        if (nowPlayingSong != null)
        {
            final daName  = states.extras.dagarden.DAGarden.currentSong;
            final display = daName != '' ? daName.toUpperCase() : getThemeLabel();
            if (nowPlayingSong.text != display) nowPlayingSong.text = display;
            nowPlayingSong.x = np.x;
            updateArrowPositions();
        }
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
        final bmd = new BitmapData(w, h, false, 0xFFbd0033);
        for (x in 0...w)
        {
            final t = x / (w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final g = Math.round(0x00 + (0x00 - 0x00) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            bmd.fillRect(new Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | (g << 8) | b);
        }
        add(new FlxSprite().loadGraphic(bmd));

        final fadeBmd = new BitmapData(w, h, true, 0x00000000);
        for (x in 0...w)
        {
            final t = x / (w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            final a = Math.round((1.0 - t) * 255);
            fadeBmd.fillRect(new Rectangle(x, 0, 1, h), (a << 24) | (r << 16) | b);
        }
        add(new FlxSprite().loadGraphic(fadeBmd));

        checkerSprite = new FlxSprite(0, 0);
        checkerSprite.makeGraphic(w, h, FlxColor.TRANSPARENT);
        checkerSprite.scrollFactor.set();
        checkShader = new ErrorHandledRuntimeShader('extrasMenuChecker', '
            #pragma header
            uniform float uTime;
            void main()
            {
                vec2 uv = openfl_TextureCoordv;
                float tileSize = 40.0;
                float tx = floor((uv.x * ${w}.0 - uTime * 60.0) / tileSize);
                float ty = floor((uv.y * ${h}.0) / tileSize);
                float check = mod(tx + ty, 2.0);
                vec3 colorA = vec3(0.45, 0.08, 0.10);
                float tileAlpha = mix(0.25, 0.0, check);
                float fadeX = 1.0 - smoothstep(0.0, 0.45, uv.x);
                float finalAlpha = tileAlpha * fadeX;
                gl_FragColor = vec4(colorA * finalAlpha, finalAlpha);
            }
        ');
        checkShader.setFloat('uTime', 0.0);
        checkerSprite.shader = checkShader;
        add(checkerSprite);
        checkerSpriteRight = new FlxSprite(0, 0);
        checkerSpriteRight.makeGraphic(w, h, FlxColor.TRANSPARENT);
        checkerSpriteRight.scrollFactor.set();
        checkShaderRight = new ErrorHandledRuntimeShader('extrasMenuCheckerRight', '
            #pragma header
            uniform float uTime;
            void main()
            {
                vec2 uv = openfl_TextureCoordv;
                float tileSize = 40.0;
                float tx = floor((uv.x * ${w}.0 + uTime * 60.0) / tileSize);
                float ty = floor((uv.y * ${h}.0) / tileSize);
                float check = mod(tx + ty, 2.0);
                vec3 colorA = vec3(0.45, 0.08, 0.10);
                float tileAlpha = mix(0.5, 0.0, check);
                float fadeX = 1.0 - smoothstep(0.0, 0.45, 1.0 - uv.x);
                float finalAlpha = tileAlpha * fadeX;
                gl_FragColor = vec4(colorA * finalAlpha, finalAlpha);
            }
        ');
        checkShaderRight.setFloat('uTime', 0.0);
        checkerSpriteRight.shader = checkShaderRight;
        add(checkerSpriteRight);
    }

    function buildRenders():Void
    {
        menuRenders = new ExtrasMenuRenders(750, 120);
        add(menuRenders);
        menuRenders.swapRender(curSelected);
    }

    var discoTween:FlxTween;
    function buildDisco():Void
    {
        final bmp = Paths.getBitmapData("assets/exe/extras/disco.webp", true, true);
        for (off in [{x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2}, {x: -2, y: 0}, {x: 2, y: 0}, {x: -2, y: 2}, {x: 0, y: 2}, {x: 2, y: 2}])
        {
            final s = new FlxSprite(41 + off.x, 541 + off.y).loadGraphic(bmp);
            s.scale.set(0.29, 0.29);
            s.updateHitbox();
            s.color = FlxColor.BLACK;
            s.alpha  = 0.3;
            add(s);
        }
        disco = new FlxSprite(41, 541).loadGraphic(bmp);
        disco.scale.set(0.29, 0.29);
        disco.updateHitbox();
        add(disco);
        discoTween = FlxTween.angle(disco, 0, 360, 3.0, {type: LOOPING});
    }

    function buildLogo():Void
    {
        extrasLogo = new FlxSprite(44.62, 58.31).loadGraphic(Paths.getBitmapData("assets/exe/extras/extras.webp", true, true));
        extrasLogo.scale.set(0.18, 0.18);
        extrasLogo.updateHitbox();
        add(extrasLogo);
    }

    function buildMenu():Void
    {
        for (i in 0...MENU_KEYS.length)
        {
            @:privateAccess
            final font = switch (Language.currentKey) {
                case 'ko-KR': 'noto-serif/korean.ttf';
                default: 'bigass.otf';
            }
            final fallback = switch (i) {
                case 0: ['GALLERY', 'View the community gallery'];
                case 1: ['CHARACTER BIOS', 'Learn more about the cast'];
                default: ['?', ''];
            }
            final label = Language.getArray(MENU_KEYS[i], fallback)[0];
            final t = new FlxText(50, 180 + i * 58, 0, label, Language.cjkSize(88));
            t.setFormat(Paths.font(font), Language.cjkSize(88), FlxColor.WHITE, LEFT);
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
        leftBmp.copyPixels(selBmp, new Rectangle(0, 0, capW, selH), new openfl.geom.Point(0, 0));
        _selLeft = new FlxSprite(0, 0);
        _selLeft.loadGraphic(leftBmp);
        _selLeft.antialiasing = ClientPrefs.data.antialiasing;
        _selLeft.origin.set(0, 0);

        final midBmp = new BitmapData(midW, selH, true, 0);
        midBmp.copyPixels(selBmp, new Rectangle(capW, 0, midW, selH), new openfl.geom.Point(0, 0));
        _selMid = new FlxSprite(0, 0);
        _selMid.loadGraphic(midBmp);
        _selMid.origin.set(0, 0);

        final rightBmp = new BitmapData(capW, selH, true, 0);
        rightBmp.copyPixels(selBmp, new Rectangle(selBmp.width - capW, 0, capW, selH), new openfl.geom.Point(0, 0));
        _selRight = new FlxSprite(0, 0);
        _selRight.loadGraphic(rightBmp);

        _selRight.origin.set(0, 0);

        add(_selLeft);
        add(_selMid);
        add(_selRight);

        _snapSelectBox();
    }

    function buildDescBar():Void
    {
        final gradH = 15;
        final bar   = new FlxSprite(0, 680 - gradH);
        bar.makeGraphic(FlxG.width, 100 + gradH, FlxColor.TRANSPARENT, true);
        for (i in 0...gradH)
            bar.pixels.fillRect(new Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGBFloat(0, 0, 0, (i / gradH) * 0.3));
        bar.pixels.fillRect(new Rectangle(0, gradH, FlxG.width, 100), FlxColor.fromRGBFloat(0, 0, 0, 0.3));
        add(bar);

        for (i in 0...MENU_KEYS.length)
        {
            @:privateAccess
            final font = switch (Language.currentKey) {
                case 'ja-JP': 'noto-serif/japanese.ttf';
                case 'ko-KR': 'noto-serif/korean.ttf';
                case 'zh-CN': 'noto-serif/simplified-chinese.ttf';
                default: 'smallass.ttf';
            }
            final fallback = switch (i) {
                case 0: ['GALLERY', 'View the community gallery'];
                case 1: ['CHARACTER BIOS', 'Learn more about the cast'];
                default: ['?', ''];
            }

            final desc = Language.getArray(MENU_KEYS[i], fallback)[1];
            final tmp  = new FlxText(0, 0, 0, desc, Language.cjkSize(56));
            tmp.setFormat(Paths.font(font), Language.cjkSize(56), FlxColor.WHITE, LEFT);
            tmp.antialiasing = ClientPrefs.data.antialiasing;
            tmp.drawFrame(true);

            final bd = new FlxBackdrop(tmp.graphic, X, 0, 0);
            bd.scale.set(0.4, 0.4);
            bd.updateHitbox();
            bd.y          = 685;
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
        final itemW     = item.frameWidth * 0.525 + 56;
        final scaleY    = 0.28;
        final capPx     = _selLeft.frameWidth * scaleY;
        final minMidPx  = _selMid.frameWidth * scaleY;
        final midPx     = Math.max(minMidPx, itemW - capPx * 2);
        final midScaleX = midPx / _selMid.frameWidth;
        final targetY   = menuItems[curSelected].y - 16;
        return {targetX: 50.0 - 28, targetY: targetY, capPx: capPx, midPx: midPx, midScaleX: midScaleX, scaleY: scaleY};
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
        if (change != 0) { FlxG.sound.play(Paths.sound('scrollMenu')); swapRender(); }

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

    public function navigateExtrasMenuTheme(add:Int = 0){
        currentExtrasTheme = FlxMath.wrap(currentExtrasTheme+add, 0, extrasMenuThemes.length-1);

        FlxTween.cancelTweensOf(nowPlayingSong);
        FlxTween.cancelTweensOf(FlxG.sound.music);
        FlxTween.tween(nowPlayingSong, {alpha: 0}, 0.2, {ease: FlxEase.quadIn});
        FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.2, {ease: FlxEase.quadIn, 
            onComplete: twn->{
                nowPlayingSong.text = getThemeLabel();
                nowPlayingSong.updateHitbox(); // aaahhh
                nowPlayingSong.x = np.x;
                updateArrowPositions();
                FlxTween.tween(nowPlayingSong, {alpha: 1}, 0.2, {ease: FlxEase.quadIn});
                FlxG.sound.playMusic(OpenFlAssets.getSound('assets/exe/music/${getCurrentMenuTheme().src}.ogg'));
                FlxG.sound.music.volume = 0;
                FlxTween.tween(FlxG.sound.music, {volume: getCurrentMenuTheme().volume}, 0.2, {ease: FlxEase.quadOut}); 
            }
        });
    }

    function swapRender():Void
    {
        menuRenders.swapRender(curSelected);
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
            case 0:
                lime.system.System.openURL('https://vsexeunofficial.com/gallery');
                canMove = true;
            case 1: nextSubState = new states.extras.bios.BIOSLoadingState();
            case 2: nextSubState = new states.extras.dagarden.DAGarden();
            case 3: nextSubState = new states.extras.cutscenes.Cutscene();
            case 4: nextSubState = new states.extras.achievements.AchievementsState();
            case 5: nextSubState = new states.extras.credits.CreditsState();
        }

        if (nextSubState != null)
        {
            if (Std.isOfType(nextSubState, SonicSubState)) {
                cast(nextSubState, SonicSubState).onBeforeClose = function() {
                    canMove = true;
                };
            }

            final started = SonicRetroTransition.openSubState(nextSubState, 0.5, function() {
                canMove = false;
            });

            if (!started) canMove = true;
        }
    }
}