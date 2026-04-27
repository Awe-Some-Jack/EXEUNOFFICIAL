package states.extras;

import backend.MusicBeatState;
import backend.Controls;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import states.EXEMenu;
import backend.Paths;

class ExtrasMenu extends MusicBeatState
{
    private static inline var MENU_START_Y:Int = 180;
    private static inline var MENU_SPACING:Int = 58;
    private static inline var MENU_START_X:Int = 50;
    private static inline var MENU_FONT_SIZE:Int = 44;

    private static inline var DESCRIPTION_Y:Int = 675;
    private static inline var DESCRIPTION_SCROLL_SPEED:Int = -30;
    private static inline var DESCRIPTION_FONT_SIZE:Int = 28;

    private static inline var FADE_IN_DELAY:Float = 2.0;
    private static inline var FADE_IN_DURATION:Float = 1.0;
    private static inline var SELECTION_TWEEN_DURATION:Float = 0.2;
    private static inline var MENU_SCALE_DURATION:Float = 0.2;

    private static inline var DISCO_ROTATION_SPEED:Float = 3.0;
    private static inline var BOX_ANIMATION_DURATION:Float = 0.5;

    private var menuOptions:Array<String> = [
        "GALLERY",
        "CHARACTER BIOS",
        "D.A GARDEN",
        "CUTSCENES",
        "ACHIEVEMENTS",
        "CREDITS"
    ];

    private var menuDescriptions:Array<String> = [
        'In the gallery you can see photos and screenshots of the development of the mod or jokes, please check it out!',
        'Here you can see the description of each character! A lot of them have a very extensive lore and its pretty interesting!',
        'Listen to the great music we have in store, composed by awesome composers. It took them a lot of time to give you something of good quality!',
        'Here you can rewatch the amazing cutscenes! Pretty simple right?',
        'Check out the achievements you can unlock, or the ones you already have!',
        'Credits to all the people who made this mod possible!'
    ];

    private var menuItems:Array<FlxText> = [];
    private var extrasTextBackdrops:Array<FlxBackdrop> = [];

    private var curSelected:Int = 0;
    private var canMove:Bool = true;
    private var cooldownTimer:Float = 0;

    private var selectBox:FlxSprite;
    private var disco:FlxSprite;
    private var box:FlxSprite;
    private var sketch1:FlxSprite;
    private var sketch2:FlxSprite;

    static var extraMenuSong:Bool = false;
    var stopMusicPlay:Bool = false;

    override public function create():Void
    {
        Paths.clearStoredMemory();
        
        super.create();

        if(!extraMenuSong) initializeMusic();
        createBackground();
        createDecorations();
        createMenu();
        createDescriptionBar();
        changeSelection(0);

        Paths.clearUnusedMemory();

        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Extras", null);
		#end
    }

    private function initializeMusic():Void
    {
        FlxG.sound.playMusic(openfl.utils.Assets.getSound('assets/exe/extras/music/ExtrasMenu.ogg'));
        extraMenuSong = true;
    }

    private function createBackground():Void
    {
        var background = new FlxSprite(0, 0);
        var graphic = Assets.getBitmapData("assets/exe/extras/fondo.png");
        if (graphic != null)
            background.loadGraphic(graphic);
        else
            background.loadGraphic("assets/exe/extras/fondo.png");
        background.scale.set(0.4, 0.4);
        background.updateHitbox();
        add(background);
    }

    private function createDecorations():Void
    {
        createBox();
        createDiscoWithShadow();
        createExtrasLogo();
    }

    private function createBox():Void
    {
        sketch1 = new FlxSprite(600, 60);
        var g1 = Assets.getBitmapData("assets/exe/extras/sketch1.png");
        if (g1 != null) sketch1.loadGraphic(g1); else sketch1.loadGraphic("assets/exe/extras/sketch1.png");
        sketch1.scale.set(0.6, 0.6);
        sketch1.updateHitbox();
        sketch1.alpha = 0.3;
        add(sketch1);
        startFloatingAnimation(sketch1, 600, 60);

        sketch2 = new FlxSprite(900, 60);
        var g2 = Assets.getBitmapData("assets/exe/extras/sketch2.png");
        if (g2 != null) sketch2.loadGraphic(g2); else sketch2.loadGraphic("assets/exe/extras/sketch2.png");
        sketch2.scale.set(0.65, 0.65);
        sketch2.updateHitbox();
        sketch2.alpha = 0.3;
        add(sketch2);
        startFloatingAnimation(sketch2, 900, 60);

        box = new FlxSprite(750, 120);
        var g3 = Assets.getBitmapData("assets/exe/extras/box.png");
        if (g3 != null) box.loadGraphic(g3); else box.loadGraphic("assets/exe/extras/box.png");
        box.scale.set(0.3, 0.3);
        box.updateHitbox();
        add(box);
    }

    private function createDiscoWithShadow():Void
    {
        var shadowOffsets = [
            {x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2},
            {x: -2, y: 0}, {x: 2, y: 0},
            {x: -2, y: 2}, {x: 0, y: 2}, {x: 2, y: 2}
        ];

        var discoBmp = Assets.getBitmapData("assets/exe/extras/disco.png");

        for (offset in shadowOffsets)
        {
            var discoShadow = new FlxSprite(60 + offset.x, FlxG.height - 180 + offset.y);
            if (discoBmp != null) discoShadow.loadGraphic(discoBmp); else discoShadow.loadGraphic("assets/exe/extras/disco.png");
            discoShadow.scale.set(0.3, 0.3);
            discoShadow.updateHitbox();
            discoShadow.color = FlxColor.BLACK;
            discoShadow.alpha = 0.3;
            add(discoShadow);
        }

        disco = new FlxSprite(60, FlxG.height - 180);
        if (discoBmp != null) disco.loadGraphic(discoBmp); else disco.loadGraphic("assets/exe/extras/disco.png");
        disco.scale.set(0.3, 0.3);
        disco.updateHitbox();
        add(disco);

        FlxTween.angle(disco, 0, 360, DISCO_ROTATION_SPEED, {type: LOOPING});
    }

    private function createExtrasLogo():Void
    {
        var extrasLogo = new FlxSprite(90, 30);
        extrasLogo.loadGraphic("assets/exe/extras/extrasss.png");
        extrasLogo.scale.set(0.35, 0.35);
        extrasLogo.updateHitbox();
        add(extrasLogo);
    }

    private function createMenu():Void
    {
        for (i in 0...menuOptions.length)
        {
            var menuText = new FlxText(MENU_START_X, MENU_START_Y + (i * MENU_SPACING), 0, menuOptions[i], MENU_FONT_SIZE);
            menuText.setFormat("assets/fonts/bigass.otf", MENU_FONT_SIZE, FlxColor.WHITE, LEFT);
            menuText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
            menuText.antialiasing = ClientPrefs.data.antialiasing;
            menuText.pixelPerfectRender = false;
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

    private function createDescriptionBar():Void
    {
        var gradientHeight:Int = 30;
        var descriptionBar = new FlxSprite(0, 670 - gradientHeight);
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
            var tempText = new FlxText(0, 0, 0, menuDescriptions[i], DESCRIPTION_FONT_SIZE);
            tempText.setFormat("assets/fonts/smallass.ttf", DESCRIPTION_FONT_SIZE, FlxColor.WHITE, LEFT);
            tempText.updateHitbox();
            tempText.drawFrame(true);

            // Keep a ref to the graphic before destroying the temp FlxText
            var textGraphic = tempText.graphic;
            var backdrop = new FlxBackdrop(textGraphic, X, 0, 0);
            backdrop.y = DESCRIPTION_Y;
            backdrop.velocity.x = DESCRIPTION_SCROLL_SPEED;
            backdrop.visible = (i == curSelected);
            add(backdrop);
            extrasTextBackdrops.push(backdrop);

            // Destroy the temp FlxText (its graphic is now owned by the backdrop)
            tempText.destroy();
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!canMove)
            return;

        if (cooldownTimer > 0)
            cooldownTimer -= elapsed;

        handleInput();
    }

    private function handleInput():Void
    {
        if (cooldownTimer <= 0)
        {
            if (Controls.instance.UI_UP_P)
            {
                changeSelection(-1);
                cooldownTimer = 0.2;
            }

            if (Controls.instance.UI_DOWN_P)
            {
                changeSelection(1);
                cooldownTimer = 0.2;
            }
        }

        if (Controls.instance.ACCEPT)
            selectOption();

        if (Controls.instance.BACK)
            exitToMainMenu();
    }

    private function exitToMainMenu():Void
    {
        canMove = false;
        extraMenuSong = true;
        FlxG.sound.music.fadeOut(0.3);
        FlxG.switchState(new EXEMenu());
    }

    private function changeSelection(change:Int = 0):Void
    {
        curSelected += change;

        var maxIdx = menuOptions.length - 1;
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

    private function updateMenuItemStyles():Void
    {
        for (i in 0...menuItems.length)
        {
            FlxTween.cancelTweensOf(menuItems[i].scale);

            if (i == curSelected)
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, 0xFF9c3829, 5);
                FlxTween.tween(menuItems[i].scale, {x: 1.05, y: 1.05}, MENU_SCALE_DURATION, {
                    ease: FlxEase.smootherStepInOut
                });
            }
            else
            {
                menuItems[i].setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 4);
                FlxTween.tween(menuItems[i].scale, {x: 1.0, y: 1.0}, MENU_SCALE_DURATION, {
                    ease: FlxEase.smootherStepInOut
                });
            }
        }
    }

    private function animateSelectBox():Void
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

    private function updateDescriptionVisibility():Void
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

    private function startFloatingAnimation(sprite:FlxSprite, centerX:Float, centerY:Float):Void
    {
        var radius:Float = 20;
        var duration:Float = FlxG.random.float(1.5, 2.5);

        var randomAngle:Float = FlxG.random.float(0, Math.PI * 2);
        var randomRadius:Float = FlxG.random.float(0, radius);
        var targetX:Float = centerX + Math.cos(randomAngle) * randomRadius;
        var targetY:Float = centerY + Math.sin(randomAngle) * randomRadius;

        FlxTween.tween(sprite, {x: targetX, y: targetY}, duration, {
            ease: FlxEase.sineInOut,
            onComplete: function(tween:FlxTween) {
                startFloatingAnimation(sprite, centerX, centerY);
            }
        });
    }

    private function animateBox():Void
    {
        var finalX:Float = 750;
        var finalY:Float = 120;
        var finalScale:Float = 0.3;
        var initialScale:Float = 0.6;
        var initialX:Float = 200;

        FlxTween.cancelTweensOf(box);
        FlxTween.cancelTweensOf(box.scale);

        box.scale.set(initialScale, initialScale);
        box.updateHitbox();
        box.x = initialX;
        box.y = finalY;
        box.alpha = 0;

        FlxTween.tween(box, {x: finalX}, BOX_ANIMATION_DURATION, {ease: FlxEase.expoOut});
        FlxTween.tween(box, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

        FlxTween.tween(box.scale, {x: finalScale, y: finalScale}, BOX_ANIMATION_DURATION, {
            ease: FlxEase.expoOut,
            onUpdate: function(tween:FlxTween) {
                var currentX = box.x;
                var currentY = box.y;
                box.updateHitbox();
                box.x = currentX;
                box.y = currentY;
            }
        });
    }

    private function selectOption():Void
    {
        canMove = false;

        FlxG.sound.play(Paths.sound('confirmMenu'));

        FlxTween.cancelTweensOf(menuItems[curSelected].scale);
        FlxTween.cancelTweensOf(selectBox.scale);

        FlxTween.tween(menuItems[curSelected].scale, {x: 1.15, y: 1.15}, 0.1, {
            ease: FlxEase.backOut,
            onComplete: function(tween:FlxTween) {
                FlxTween.tween(menuItems[curSelected].scale, {x: 1.05, y: 1.05}, 0.15, {
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

    private function navigateToOption():Void
    {
        switch (menuOptions[curSelected])
        {
            case "GALLERY":
                trace("Gallery selected");

            case "CHARACTER BIOS":
                stopMusicPlay = true;
                FlxG.switchState(new BIOS());

            case "D.A GARDEN":
                extraMenuSong = false;
                stopMusicPlay = true;
                if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.3);
                FlxG.switchState(new DAGarden());

            case "CUTSCENES":
                trace("Cutscenes selected");

            case "ACHIEVEMENTS":
                trace("Achievements selected");

            case "CREDITS":
                trace("Credits selected");
        }

        canMove = true;
    }

    override public function destroy():Void
    {
        

        // Cancel all active tweens to prevent them running after state is gone
        if (disco != null) FlxTween.cancelTweensOf(disco);
        if (box != null) { FlxTween.cancelTweensOf(box); FlxTween.cancelTweensOf(box.scale); }
        if (sketch1 != null) FlxTween.cancelTweensOf(sketch1);
        if (sketch2 != null) FlxTween.cancelTweensOf(sketch2);
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
        sketch1 = null;
        sketch2 = null;

        if (!stopMusicPlay){
            extraMenuSong = false;
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
        }

        super.destroy();
    }
}
