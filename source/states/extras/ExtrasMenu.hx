package states.extras;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import flixel.addons.display.FlxBackdrop;

import states.EXEMenu;

class ExtrasMenu extends MusicBeatState
{
    static inline final MENU_START_Y:Int = 180;
    static inline final MENU_SPACING:Int = 58;
    static inline final MENU_START_X:Int = 50;
    static inline final MENU_FONT_SIZE:Int = 88;

    static inline final DESCRIPTION_Y:Int = 675;
    static inline final DESCRIPTION_SCROLL_SPEED:Int = -30;
    static inline final DESCRIPTION_FONT_SIZE:Int = 56;

    static inline final FADE_IN_DELAY:Float = 2.0;
    static inline final FADE_IN_DURATION:Float = 1.0;
    static inline final SELECTION_TWEEN_DURATION:Float = 0.2;
    static inline final MENU_SCALE_DURATION:Float = 0.2;

    static inline final DISCO_ROTATION_SPEED:Float = 3.0;
    static inline final BOX_ANIMATION_DURATION:Float = 0.5;

    static var extraMenuSong:Bool = false;

    var menuOptions:Array<String> = [
        "GALLERY",
        "CHARACTER BIOS",
        "D.A GARDEN",
        "CUTSCENES",
        "ACHIEVEMENTS",
        "CREDITS"
    ];

    var menuDescriptions:Array<String> = [
        'In the gallery you can see photos and screenshots of the development of the mod or jokes, please check it out!',
        'Here you can see the description of each character! A lot of them have a very extensive lore and its pretty interesting!',
        'Listen to the great music we have in store, composed by awesome composers. It took them a lot of time to give you something of good quality!',
        'Here you can rewatch the amazing cutscenes! Pretty simple right?',
        'Check out the achievements you can unlock, or the ones you already have!',
        'Credits to all the people who made this mod possible!'
    ];

    var menuItems:Array<FlxText> = [];
    var extrasTextBackdrops:Array<FlxBackdrop> = [];

    var curSelected:Int = 0;
    var canMove:Bool = true;

    var selectBox:FlxSprite;
    var disco:FlxSprite;
    var _discoSpinTween:FlxTween = null;
    var _discoSpinning:Bool = true;
    var box:FlxSprite;
    var extrasLogo:FlxSprite;
    var sumky:FlxSprite;
    var nowPlaying:FlxText;
    var nowPlayingSong:FlxText;

    var stopMusicPlay:Bool = false;
    public var _orphanPlayer:states.extras.dagarden.DAPlayer = null;

    var _debugMode:Bool = false;
    var _debugSelected:FlxSprite = null;
    var _debugDragging:Bool = false;
    var _debugDragOffX:Float = 0;
    var _debugDragOffY:Float = 0;
    var _debugRotating:Bool = false;
    var _debugOpacity:Bool = false;
    var _debugLabel:flixel.text.FlxText;

    override function create():Void
    {
        Paths.clearStoredMemory();

        super.create();

        if (!extraMenuSong) initializeMusic();
        createBackground();
        createDecorations();
        createMenu();
        createDescriptionBar();
        changeSelection(0);

        nowPlaying = new FlxText(169, 558, 0, "NOW PLAYING:", 60);
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

        _debugLabel = new flixel.text.FlxText(4, 4, 0, "", 14);
        _debugLabel.setFormat(null, 14, FlxColor.WHITE, LEFT);
        _debugLabel.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        _debugLabel.scrollFactor.set(0, 0);
        _debugLabel.visible = false;
        add(_debugLabel);

        Paths.clearUnusedMemory();

        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Extras", null);
		#end
    }

    function initializeMusic():Void
    {
        FlxG.sound.playMusic(openfl.utils.Assets.getSound('assets/exe/extras/music/ExtrasMenu.ogg'));
        extraMenuSong = true;
    }

    function createBackground():Void
    {
        final w:Int = FlxG.width;
        final h:Int = FlxG.height;
        final bmd = new openfl.display.BitmapData(w, h, false, 0xFFbd0033);
        final left:openfl.utils.Object = {r: 0xbd, g: 0x00, b: 0x33};
        final right:openfl.utils.Object = {r: 0x57, g: 0x00, b: 0x0b};
        for (x in 0...w)
        {
            final t:Float = x / (w - 1);
            final r:Int = Math.round(left.r + (right.r - left.r) * t);
            final g:Int = Math.round(left.g + (right.g - left.g) * t);
            final b:Int = Math.round(left.b + (right.b - left.b) * t);
            final col:Int = 0xFF000000 | (r << 16) | (g << 8) | b;
            bmd.fillRect(new openfl.geom.Rectangle(x, 0, 1, h), col);
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
        final checkers = new FlxBackdrop(cbmd, XY, 0, 0);
        checkers.alpha = 0.10;
        checkers.velocity.x = -60;
        add(checkers);

        final fadeBmd = new openfl.display.BitmapData(w, h, true, 0x00000000);
        for (fx in 0...w)
        {
            final t:Float = fx / (w - 1);
            final tLeft:Float = 0.0;
            final tRight:Float = t;
            final lr:Int = Math.round(0xbd + (0x57 - 0xbd) * t);
            final lg:Int = 0;
            final lb:Int = Math.round(0x33 + (0x0b - 0x33) * t);
            final a:Int = Math.round((1.0 - t) * 255);
            final col:Int = (a << 24) | (lr << 16) | (lg << 8) | lb;
            fadeBmd.fillRect(new openfl.geom.Rectangle(fx, 0, 1, h), col);
        }
        final fadeMask = new FlxSprite(0, 0);
        fadeMask.loadGraphic(fadeBmd);
        add(fadeMask);
    }

    function createDecorations():Void
    {
        createBox();
        createDiscoWithShadow();
        createExtrasLogo();
    }

    function createBox():Void
    {
        box = new FlxSprite(750, 120);
        box.loadGraphic(Assets.getBitmapData("assets/exe/extras/box.png"));
        box.scale.set(0.3, 0.3);
        box.updateHitbox();
        add(box);

        final sumkyScale:Float = 0.64;
        final sumkyVisW:Float = 953 * sumkyScale;
        final sumkyVisH:Float = 661 * sumkyScale;
        sumky = new FlxSprite(0, 0);
        sumky.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(
            Assets.getBitmapData('assets/exe/extras/sumky.png'),
            openfl.utils.Assets.getText('assets/exe/extras/sumky.xml')
        );
        sumky.animation.addByPrefix('idle', 'sunki instancia', 12, true);
        sumky.animation.play('idle');
        sumky.scale.set(sumkyScale, sumkyScale);
        sumky.updateHitbox();
        sumky.x = 675;
        sumky.y = 122;
        add(sumky);
    }

    function createDiscoWithShadow():Void
    {
        final shadowOffsets = [
            {x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2},
            {x: -2, y: 0}, {x: 2, y: 0},
            {x: -2, y: 2}, {x: 0, y: 2}, {x: 2, y: 2}
        ];

        final discoBmp = Assets.getBitmapData("assets/exe/extras/disco.png");
        for (offset in shadowOffsets)
        {
            final discoShadow = new FlxSprite(61 + offset.x, 541 + offset.y);
            discoShadow.loadGraphic(discoBmp);
            discoShadow.scale.set(0.29, 0.29);
            discoShadow.updateHitbox();
            discoShadow.color = FlxColor.BLACK;
            discoShadow.alpha = 0.3;
            add(discoShadow);
        }

        disco = new FlxSprite(61, 541);
        disco.loadGraphic(discoBmp);
        disco.scale.set(0.29, 0.29);
        disco.updateHitbox();
        add(disco);

        _discoSpinTween = FlxTween.angle(disco, 0, 360, DISCO_ROTATION_SPEED, {type: LOOPING});
    }

    function createExtrasLogo():Void
    {
        extrasLogo = new FlxSprite(49, 54);
        extrasLogo.loadGraphic("assets/exe/extras/extrasss.png");
        extrasLogo.scale.set(0.32, 0.32);
        extrasLogo.updateHitbox();
        add(extrasLogo);
    }

    function createMenu():Void
    {
        for (i in 0...menuOptions.length)
        {
            final menuText = new FlxText(MENU_START_X, MENU_START_Y + (i * MENU_SPACING), 0, menuOptions[i], MENU_FONT_SIZE);
            menuText.setFormat("assets/fonts/bigass.otf", MENU_FONT_SIZE, FlxColor.WHITE, LEFT);
            menuText.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 8);
            menuText.antialiasing = ClientPrefs.data.antialiasing;
            menuText.pixelPerfectRender = false;
            menuText.scale.set(0.5, 0.5);
            menuText.updateHitbox();
            menuText.ID = i;
            add(menuText);
            
            menuItems.push(menuText);
        }

        selectBox = new FlxSprite(0, 0);
        selectBox.loadGraphic("assets/exe/extras/select.png");
        selectBox.scale.set(0.31, 0.28);
        selectBox.updateHitbox();
        add(selectBox);
    }

    function createDescriptionBar():Void
    {
        final gradientHeight:Int = 30;

        final descriptionBar = new FlxSprite(0, 670 - gradientHeight);
        descriptionBar.makeGraphic(FlxG.width, 100 + gradientHeight, FlxColor.TRANSPARENT, true);

        for (i in 0...gradientHeight)
        {
            var alpha:Float = (i / gradientHeight) * 0.3;
            descriptionBar.pixels.fillRect(new openfl.geom.Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGBFloat(0, 0, 0, alpha));
        }

        descriptionBar.pixels.fillRect(new openfl.geom.Rectangle(0, gradientHeight, FlxG.width, 100), FlxColor.fromRGBFloat(0, 0, 0, 0.3));
        add(descriptionBar);

        for (i in 0...menuDescriptions.length)
        {
            final tempText = new FlxText(0, 0, 0, menuDescriptions[i], DESCRIPTION_FONT_SIZE);
            tempText.setFormat("assets/fonts/smallass.ttf", DESCRIPTION_FONT_SIZE, FlxColor.WHITE, LEFT);
            tempText.antialiasing = ClientPrefs.data.antialiasing;
            tempText.updateHitbox();
            tempText.drawFrame(true);

            final backdrop = new FlxBackdrop(tempText.graphic, X, 0, 0);
            backdrop.scale.set(0.5, 0.5);
            backdrop.updateHitbox();
            backdrop.y = DESCRIPTION_Y;
            backdrop.velocity.x = DESCRIPTION_SCROLL_SPEED;
            backdrop.visible = (i == curSelected);
            add(backdrop);

            extrasTextBackdrops.push(backdrop);

            tempText.destroy();
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (_orphanPlayer != null)
        {
            _orphanPlayer.update(elapsed);
            if (!_orphanPlayer.isPlaying && !_orphanPlayer.isLoading)
            {
                _orphanPlayer.stop();
                _orphanPlayer = null;
                states.extras.dagarden.DAGarden.currentSong = '';
                states.extras.dagarden.DAGarden.currentSongMod = '';
                if (FlxG.sound.music != null && !FlxG.sound.music.playing) FlxG.sound.music.resume();
                _discoStart();
            }
        }

        if (nowPlayingSong != null)
        {
            final daName = states.extras.dagarden.DAGarden.currentSong;
            final displayName = daName != '' ? daName.toUpperCase() : 'EXTRAS MENU';
            if (nowPlayingSong.text != displayName)
                nowPlayingSong.text = displayName;
        }

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

        if (!canMove)
            return;

        handleInput();
    }

    function _updateDebug():Void
    {
        final mx:Float = FlxG.mouse.x;
        final my:Float = FlxG.mouse.y;

        if (FlxG.keys.justPressed.T)
        {
            if (_debugSelected != null)
            {
                final _np:FlxSprite = cast nowPlaying;
                final _nps:FlxSprite = cast nowPlayingSong;
                var selName = _debugSelected == extrasLogo ? "extrasLogo" : (_debugSelected == disco ? "disco" : (_debugSelected == _np ? "nowPlaying" : (_debugSelected == _nps ? "nowPlayingSong" : "unknown")));
                trace('$selName | x:${_debugSelected.x} y:${_debugSelected.y} scale:${_debugSelected.scale.x} angle:${_debugSelected.angle} alpha:${_debugSelected.alpha}');
            }
            else
                trace('DEBUG | nothing selected');
        }

        if (FlxG.mouse.justPressed)
        {
            _debugSelected = null;
            _debugDragging = false;
            _debugRotating = false;
            _debugOpacity  = false;
            final debugSprites:Array<FlxSprite> = [extrasLogo, disco, cast nowPlaying, cast nowPlayingSong];
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

        if (FlxG.mouse.justReleased)
            _debugDragging = false;

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

        final _npLabel:FlxSprite = cast nowPlaying;
        final _npsLabel:FlxSprite = cast nowPlayingSong;
        var selName:String = "none";
        if (_debugSelected == extrasLogo) selName = "extrasLogo";
        else if (_debugSelected == disco) selName = "disco";
        else if (_debugSelected == sumky) selName = "sumky";
        else if (_debugSelected == _npLabel) selName = "nowPlaying";
        else if (_debugSelected == _npsLabel) selName = "nowPlayingSong";

        final modeStr = _debugRotating ? " [R=rotate]" : (_debugOpacity ? " [O=opacity]" : " [scroll=scale]");
        if (_debugSelected != null)
            _debugLabel.text = '[F3] DEBUG$modeStr  |  $selName\nx: ${Math.round(_debugSelected.x)}  y: ${Math.round(_debugSelected.y)}  scale: ${Math.round(_debugSelected.scale.x * 1000) / 1000}  angle: ${Math.round(_debugSelected.angle)}  alpha: ${Math.round(_debugSelected.alpha * 100)}%';
        else
            _debugLabel.text = '[F3] DEBUG  |  click sprite | hold R+scroll=rotate | hold O+scroll=opacity';
    }

    function handleInput():Void
    {
        if (controls.UI_UP_P)
            changeSelection(-1);

        if (controls.UI_DOWN_P)
            changeSelection(1);

        if (controls.ACCEPT)
            selectOption();

        if (controls.BACK)
            exitToMainMenu();

        if (FlxG.mouse.justPressed && disco != null
            && disco.overlapsPoint(new flixel.math.FlxPoint(FlxG.mouse.x, FlxG.mouse.y)))
        {
            if (_orphanPlayer != null)
            {
                if (_orphanPlayer.isPlaying) { _orphanPlayer.pause(); _discoStop(); }
                else { _orphanPlayer.playAudio(states.extras.dagarden.DAGarden.currentSong, states.extras.dagarden.DAGarden.currentSongMod); _discoStart(); }
            }
            else if (FlxG.sound.music != null)
            {
                if (FlxG.sound.music.playing) { FlxG.sound.music.pause(); _discoStop(); }
                else { FlxG.sound.music.resume(); _discoStart(); }
            }
        }
    }

    override function openSubState(subState:flixel.FlxSubState):Void
    {
        canMove = false;
        super.openSubState(subState);
    }

    override function closeSubState():Void
    {
        super.closeSubState();
        final op = states.extras.dagarden.DAGarden.orphanPlayer;
        if (op != null)
        {
            _orphanPlayer = op;
            states.extras.dagarden.DAGarden.orphanPlayer = null;
        }
        canMove = true;
        for (cam in FlxG.cameras.list)
            if (cam?.filters != null)
                Main.resetSpriteCache(cam.flashSprite);
        if (FlxG.game != null) Main.resetSpriteCache(FlxG.game);
    }

    function exitToMainMenu():Void
    {
        canMove = false;
        extraMenuSong = true;
        FlxG.sound.music?.fadeOut(0.3);
        if (_orphanPlayer != null) { _orphanPlayer.stop(); _orphanPlayer = null; }
        states.extras.dagarden.DAGarden.currentSong = '';
        states.extras.dagarden.DAGarden.currentSongMod = '';
        FlxG.switchState(() -> new EXEMenu());
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected += change;

        final maxIdx = menuOptions.length - 1;
        if (curSelected < 0)
            curSelected = maxIdx;
        if (curSelected > maxIdx)
            curSelected = 0;

        if (change != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));

        updateMenuItemStyles();
        animateSelectBox();

        if (change != 0)
            animateBox();

        updateDescriptionVisibility();
    }

    function updateMenuItemStyles():Void
    {
        for (i in 0...menuItems.length)
        {
            FlxTween.cancelTweensOf(menuItems[i].scale);

            if (i == curSelected)
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, 0xFF9c3829, 10);
                FlxTween.tween(menuItems[i].scale, {x: 0.525, y: 0.525}, MENU_SCALE_DURATION, {
                    ease: FlxEase.smootherStepInOut
                });
            }
            else
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 8);
                FlxTween.tween(menuItems[i].scale, {x: 0.5, y: 0.5}, MENU_SCALE_DURATION, {
                    ease: FlxEase.smootherStepInOut
                });
            }
        }
    }

    function animateSelectBox():Void
    {
        var targetItem = menuItems[curSelected];

        FlxTween.cancelTweensOf(selectBox);
        FlxTween.cancelTweensOf(selectBox.scale);

        FlxTween.tween(selectBox, {x: targetItem.x - 10, y: targetItem.y - 10}, SELECTION_TWEEN_DURATION, {
            ease: FlxEase.smootherStepInOut
        });

        FlxTween.tween(selectBox.scale, {x: 0.33, y: 0.30}, MENU_SCALE_DURATION, {
            ease: FlxEase.smootherStepInOut
        });
    }

    function updateDescriptionVisibility():Void
    {
        for (i in 0...extrasTextBackdrops.length)
        {
            FlxTween.cancelTweensOf(extrasTextBackdrops[i]);

            if (i == curSelected)
            {
                extrasTextBackdrops[i].visible = true;
                extrasTextBackdrops[i].alpha = 0;
                FlxTween.tween(extrasTextBackdrops[i], {alpha: 1}, 0.25, {
                    ease: FlxEase.smootherStepInOut
                });
            }
            else
            {
                FlxTween.tween(extrasTextBackdrops[i], {alpha: 0}, 0.15, {
                    ease: FlxEase.smootherStepInOut,
                    onComplete: function(tween:FlxTween) {
                        extrasTextBackdrops[i].visible = false;
                    }
                });
            }
        }
    }

    function _discoStop():Void
    {
        if (!_discoSpinning || disco == null) return;
        _discoSpinning = false;
        if (_discoSpinTween != null) { _discoSpinTween.cancel(); _discoSpinTween = null; }
        final startSpeed:Float = 360.0 / DISCO_ROTATION_SPEED;
        final timer = new flixel.util.FlxTimer();
        var speed = startSpeed;
        timer.start(1.0 / 60.0, (_) -> {
            speed = flixel.math.FlxMath.lerp(speed, 0, 0.12);
            if (disco != null) disco.angle += speed * (1.0 / 60.0);
            if (Math.abs(speed) < 0.05) timer.cancel();
        }, 0);
    }

    function _discoStart():Void
    {
        if (_discoSpinning || disco == null) return;
        _discoSpinning = true;
        _discoSpinTween = FlxTween.angle(disco, disco.angle, disco.angle + 360, DISCO_ROTATION_SPEED, {type: LOOPING});
    }

    function startFloatingAnimation(sprite:FlxSprite, centerX:Float, centerY:Float):Void
    {
        final radius:Float = 20;
        final duration:Float = FlxG.random.float(1.5, 2.5);

        final randomAngle:Float = FlxG.random.float(0, Math.PI * 2);
        final randomRadius:Float = FlxG.random.float(0, radius);

        final targetX:Float = centerX + Math.cos(randomAngle) * randomRadius;
        final targetY:Float = centerY + Math.sin(randomAngle) * randomRadius;

        FlxTween.tween(sprite, {x: targetX, y: targetY}, duration, {
            ease: FlxEase.sineInOut,
            onComplete: (tween:FlxTween) -> startFloatingAnimation(sprite, centerX, centerY)
        });
    }

    function animateBox():Void
    {
        final finalX:Float = 750;
        final finalY:Float = 120;
        final finalScale:Float = 0.3;
        final finalSumkyScale:Float = 0.64;
        final finalBoxW:Float = 1479 * finalScale;
        final finalBoxH:Float = 1451 * finalScale;
        final sumkyVisW:Float = 953 * finalSumkyScale;
        final sumkyVisH:Float = 661 * finalSumkyScale;
        final finalSumkyX:Float = finalX;
        final finalSumkyY:Float = finalY + finalBoxH - sumkyVisH;

        final initialScale:Float = 0.6;
        final initialX:Float = 200;

        FlxTween.cancelTweensOf(box);
        FlxTween.cancelTweensOf(box.scale);
        if (sumky != null) { FlxTween.cancelTweensOf(sumky); FlxTween.cancelTweensOf(sumky.scale); }

        box.scale.set(initialScale, initialScale);
        box.updateHitbox();
        box.x = initialX;
        box.y = finalY;
        box.alpha = 0;

        if (sumky != null)
        {
            sumky.alpha = 0;
        }

        FlxTween.tween(box, {x: finalX}, BOX_ANIMATION_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(box, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
        if (sumky != null)
            FlxTween.tween(sumky, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

        FlxTween.tween(box.scale, {x: finalScale, y: finalScale}, BOX_ANIMATION_DURATION, {
            ease: FlxEase.expoOut,
            onUpdate: (tween:FlxTween) -> {
                final currentX = box.x;
                final currentY = box.y;
                box.updateHitbox();
                box.x = currentX;
                box.y = currentY;

                if (sumky != null)
                {
                    sumky.x = 675;
                    sumky.y = 122;
                }
            }
        });
    }

    function selectOption():Void
    {
        canMove = false;

        FlxG.sound.play(Paths.sound('confirmMenu'));

        FlxTween.cancelTweensOf(menuItems[curSelected].scale);
        FlxTween.cancelTweensOf(selectBox.scale);

        FlxTween.tween(menuItems[curSelected].scale, {x: 0.575, y: 0.575}, 0.1, {
            ease: FlxEase.backOut,
            onComplete: function(tween:FlxTween) {
                FlxTween.tween(menuItems[curSelected].scale, {x: 0.525, y: 0.525}, 0.15, {
                    ease: FlxEase.smootherStepInOut,
                    onComplete: function(tween:FlxTween) {
                        navigateToOption();
                    }
                });
            }
        });

        FlxTween.tween(selectBox.scale, {x: 0.36, y: 0.33}, 0.1, {
            ease: FlxEase.backOut,
            onComplete: function(tween:FlxTween) {
                FlxTween.tween(selectBox.scale, {x: 0.33, y: 0.30}, 0.15, {
                    ease: FlxEase.smootherStepInOut
                });
            }
        });
    }

    function navigateToOption():Void
    {
        switch (menuOptions[curSelected])
        {
            case "GALLERY":
                canMove = false;
                openSubState(new states.extras.gallery.Gallery());

            case "CHARACTER BIOS":
                canMove = false;
                openSubState(new states.extras.bios.BIOS());

            case "D.A GARDEN":
                openSubState(new states.extras.dagarden.DAGarden());

            case "CUTSCENES":
                canMove = false;
                openSubState(new states.extras.cutscenes.Cutscene());

            case "ACHIEVEMENTS":
                canMove = false;
                openSubState(new states.extras.achievements.AchievementsMenuState());

            case "CREDITS":
                canMove = false;
                openSubState(new states.extras.credits.CreditsState());
        }
    }

    override public function destroy():Void
    {
        if (_orphanPlayer != null) { _orphanPlayer.stop(); _orphanPlayer = null; }
        if (disco != null) FlxTween.cancelTweensOf(disco);
        nowPlaying = null;
        nowPlayingSong = null;
        if (box != null) { FlxTween.cancelTweensOf(box); FlxTween.cancelTweensOf(box.scale); }
        sumky = null;
        if (selectBox != null) { FlxTween.cancelTweensOf(selectBox); FlxTween.cancelTweensOf(selectBox.scale); }

        if (menuItems != null)
        {
            for (item in menuItems)
            {
                if (item != null)
                    FlxTween.cancelTweensOf(item.scale);
            }
        }

        if (extrasTextBackdrops != null)
        {
            for (backdrop in extrasTextBackdrops)
            {
                if (backdrop != null)
                    FlxTween.cancelTweensOf(backdrop);
            }
        }

        menuItems = null;
        extrasTextBackdrops = null;
        selectBox = null;
        disco = null;
        box = null;

        if (!stopMusicPlay)
        {
            extraMenuSong = false;
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
        }

        super.destroy();
    }
}
