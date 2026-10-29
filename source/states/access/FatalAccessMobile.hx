package states.access;

import flixel.text.FlxText;
#if mobile
import openfl.events.TextEvent;
import flixel.input.touch.FlxTouch;
#end
import flixel.addons.transition.FlxTransitionableState;
import states.access.FatalAccess.FatalScene;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;


import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.display.Shape;
import openfl.system.Capabilities;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.Lib;

import DateTools;
import Date;


import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxCollision;
import flixel.math.FlxRect;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.system.scaleModes.RatioScaleMode;

import lime.app.Application as Application;


import sys.io.File;
import sys.FileSystem;

import haxe.Json;

import Reflect;

using StringTools;

class FatalAccessMobile extends MusicBeatState 
{
    var mouseClickRight:Bool = false;
    var mouseClickLeft:Bool = false;
    var mouseDeltaX = 0;
    var mouseDeltaY = 0;
    var icons:Array<Array<Dynamic>> = [];
    var folderIcons:Array<Array<Dynamic>> = [];
    var taskbarIcons:Array<Dynamic> = [];

    var bar:FlxSprite;
    var explorerSprites:Array<FlxSprite> = [];
    var sidebarHits:Array<FlxSprite> = [];
    var sidebarItems:Array<FlxSprite> = [];
    var sidebarArrow:FlxSprite;
    var sidebarCollapsed:Bool = false;
    var editorSprites:Array<Dynamic> = [];
    var inFolder:Bool = false;
    var inEditor:Bool = false;
    var draggingEditor:Bool = false;
    var draggingExplorer:Bool = false;
    var pressedIcon:Int = -1;
    var iconDragDist:Float = 0;
    var fileText:FlxText;
    var fileHitbox:FlxSprite;
    var typedLabel:FlxText;
    var folderInd:Int = 0;
    var subfolderInd:Int = 0;
    var maxSubfolderInd:Int = 0;
    var windowBusy:Bool = false;
    var explorerBack:FlxSprite;
    var explorerForward:FlxSprite;
    var cooldown:Float = 0;
    var highlightSpr:FlxSprite;
    var highlightedThisFrame:Bool = false;
    var clockText:FlxText;
    var screenBg:VideoSprite;
    var errok:FlxSprite;
    var errokHit:FlxSprite;
    var errorOpen:Bool = true;
    var mintStartLogo:FlxSprite;
    var black:FlxSprite;

    final paths:Array<Array<String>> = [ // always starts with User/Desktop/
        ["Android Studio"],
        ["Memes"],
        ["Godot"],
        ["Funkin Lullaby Reboot"],
        ["videos"],
        ["flowery"],
        ["Mirror Modulation"],
        ["Unofficial", "$exe,fonts,shared,videos", "access,$OPEN ME PLAYER,freeplayassets,mainmenu,parallax,story", "ContainFatalError.cnt"]
    ];

    var unlockText:String = "
================================================================
                                                        ContainFatalError.cnt
================================================================

Y̸̺͐͊ O̸̱̟͑́͛ U̸͓̼̳͗ Ṛ̵̛̘  ̵̼̆̇̾Ȃ̸͙̂̕ N̸̨̎ S̷̩̯̩̏̏͗ W̴͒̈͜͝ E̸̛͎̓ R̶͒͐͜  ̵̨͎̱̌N̴̘̬̑̋ O̷̺͒̑̕ W̶̬̦͍͛.̶͚̿͑ ̴̬̆̚
̴̨̟͈́͘͠
̶̫͍̈́́Y̶̱̖̞͂ E̶̯͂̈́͑ S̷̫͛̅ ̷̺̐̿̔ Ö̷̧̤͕́ Ṟ̸͚̭͛  ̶̨̓ N̸ O̵̼͓͝?̷͚̰̾͝

>";
    var typedText:String = "";
    var savedText:String = "";
    var prefixTxt:String = "";
    var underline1:FlxSprite;
    var underline2:FlxSprite;

    /* 
    10 folders
        -Memes
        -Unofficial
        -Games
        -ill figure the rest out later




        whenever opening something unrelated, popup window saying "THIS IS NOT WHAT YOU CAME HERE FOR"
    */

    function img(key:String):BitmapData {
        return Paths.getBitmapData('assets/exe/access/fatal/mobile/' + key + '.webp');
    }

    var prevAntialiasing:Bool = false;

    #if mobile
    var pinching:Bool = false;
    var pinchStartDist:Float = 1;
    var pinchStartZoom:Float = 1;
    var lastMidX:Float = 0;
    var lastMidY:Float = 0;
    var viewCX:Float = 0;
    var viewCY:Float = 0;

    function updatePinch():Bool {
        var held:Array<FlxTouch> = [];
        for(t in FlxG.touches.list) {
            if(t.pressed) held.push(t);
        }

        if(held.length < 2) {
            pinching = false;
            return false;
        }

        var dx:Float = held[0].gameX - held[1].gameX;
        var dy:Float = held[0].gameY - held[1].gameY;
        var dist:Float = Math.sqrt(dx * dx + dy * dy);
        var midX:Float = (held[0].gameX + held[1].gameX) / 2;
        var midY:Float = (held[0].gameY + held[1].gameY) / 2;

        if(!pinching) {
            pinching = true;
            pinchStartDist = Math.max(dist, 1);
            pinchStartZoom = FlxG.camera.zoom;
            lastMidX = midX;
            lastMidY = midY;
            draggingEditor = false;
            draggingExplorer = false;
            pressedIcon = -1;
            return true;
        }

        var oldZoom:Float = FlxG.camera.zoom;
        var newZoom:Float = Math.max(1, Math.min(3, pinchStartZoom * dist / pinchStartDist));

        var worldX:Float = viewCX + (lastMidX - FlxG.width / 2) / oldZoom;
        var worldY:Float = viewCY + (lastMidY - FlxG.height / 2) / oldZoom;

        viewCX = worldX - (midX - FlxG.width / 2) / newZoom;
        viewCY = worldY - (midY - FlxG.height / 2) / newZoom;

        var halfW:Float = FlxG.width / (2 * newZoom);
        var halfH:Float = FlxG.height / (2 * newZoom);
        viewCX = Math.max(halfW, Math.min(FlxG.width - halfW, viewCX));
        viewCY = Math.max(halfH, Math.min(FlxG.height - halfH, viewCY));

        FlxG.camera.zoom = newZoom;
        FlxG.camera.scroll.set(viewCX - FlxG.width / 2, viewCY - FlxG.height / 2);

        lastMidX = midX;
        lastMidY = midY;
        return true;
    }

    var pendingChars:Array<String> = [];

    function onTextInput(e:TextEvent):Void {
        if(inEditor) pendingChars.push(e.text);
    }

    function setKeyboard(on:Bool):Void {
        FlxG.stage.window.textInputEnabled = on;
        if(!on) pendingChars = [];
    }
    #end

    override function destroy() {
        #if mobile
        FlxG.stage.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
        setKeyboard(false);
        #end
        FlxSprite.defaultAntialiasing = prevAntialiasing;
        super.destroy();
    }

    override function create() {
        super.create();

        prevAntialiasing = FlxSprite.defaultAntialiasing;
        FlxSprite.defaultAntialiasing = true;

        FlxG.sound.music?.stop();
        
        FlxG.mouse.visible = true;
        
        FlxG.camera.zoom = 1;

        #if mobile
        FlxG.stage.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
        viewCX = FlxG.width / 2;
        viewCY = FlxG.height / 2;
        #end

        #if VIDEOS_ALLOWED
		screenBg = new VideoSprite();
		screenBg.onFormat(() -> {
			screenBg.setGraphicSize(FlxG.width, FlxG.height);
			screenBg.screenCenter();
		});
		if (screenBg.loadVideo('assets/exe/access/fatal/mobile/bakamitai.mp4', [VideoSprite.ARG_LOOPING, VideoSprite.ARG_HW_ACCEL, VideoSprite.ARG_DROP_LATE, VideoSprite.ARG_SKIP_FRAMES])) screenBg.playDelayed();
		add(screenBg);
		#end

        savedText = unlockText;

        bar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, 0xFF1c1c20);
        bar.setPosition(0, FlxG.height - bar.height);
        add(bar);

        for(i in 0...paths.length) {
            var icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("desktopIcons/1"));
            icon.scale.set(0.325, 0.325);
            icon.updateHitbox();
            icon.setPosition(30, (icon.height*i) + (30*i));

            var hitbox:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(icon.width), Std.int(icon.height+10), 0xFFFFFFFF);
            hitbox.setPosition(icon.x, icon.y);
            hitbox.alpha = 0;

            var text:FlxText = new FlxText(0, 0, 1000, paths[i][0]);
            text.setPosition(icon.x - icon.width + 10, icon.y + (icon.height)+3);
            text.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, CENTER);
            text.scale.set(0.08, 0.08);
            text.updateHitbox();
            icons.push([icon, hitbox, text]);

            add(icon);
            add(hitbox);
            add(text);
        }

        var mint:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("desktopIcons/mint"));
        mint.scale.set(0.043, 0.043);
        mint.updateHitbox();
        mint.setPosition(bar.x+2, bar.y+2);
        taskbarIcons.push(mint);
        add(mint);

        for(i in 1...9) {
            var icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("desktopIcons/"+i));
            icon.scale.set(0.16, 0.16);
            icon.updateHitbox();
            icon.setPosition(10+(icon.width*i)+(6*i), bar.y+2);
            taskbarIcons.push(icon);
            add(icon);
        }

        clockText = new FlxText(0, 0, 1000, DateTools.format(Date.now(), "%H:%M"));
        clockText.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, CENTER);
        clockText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF, 2, 1);
        clockText.scale.set(0.08, 0.08);
        clockText.updateHitbox();
        clockText.setPosition(FlxG.width - clockText.width + 30, bar.y + 8);
        add(clockText);

        var soundIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("volume"));
        soundIcon.scale.set(0.14, 0.14);
        soundIcon.updateHitbox();
        soundIcon.setPosition(clockText.x + clockText.width / 2 - 17 - soundIcon.width, bar.y + 5);
        taskbarIcons.push(soundIcon);
        add(soundIcon);

        var internetIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("network"));
        internetIcon.scale.set(0.14, 0.14);
        internetIcon.updateHitbox();
        internetIcon.setPosition(soundIcon.x - internetIcon.width - 8, bar.y + 5);
        taskbarIcons.push(internetIcon);
        add(internetIcon);

        var printerIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("printer"));
        printerIcon.scale.set(0.14, 0.14);
        printerIcon.updateHitbox();
        printerIcon.setPosition(internetIcon.x - printerIcon.width - 8, bar.y + 5);
        taskbarIcons.push(printerIcon);
        add(printerIcon);

        var notifIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("notifications"));
        notifIcon.scale.set(0.14, 0.14);
        notifIcon.updateHitbox();
        notifIcon.setPosition(printerIcon.x - notifIcon.width - 8, bar.y + 5);
        taskbarIcons.push(notifIcon);
        add(notifIcon);

        underline1 = new FlxSprite(0, 0).makeGraphic(Std.int(taskbarIcons[1].width), 1, 0xFF1f9ede);
        underline1.setPosition(taskbarIcons[1].x, taskbarIcons[1].y+17);
        underline1.updateHitbox();
        underline1.visible = false;
        add(underline1);

        underline2 = new FlxSprite(0, 0).makeGraphic(Std.int(taskbarIcons[8].width), 1, 0xFF1f9ede);
        underline2.setPosition(taskbarIcons[8].x, taskbarIcons[8].y+17);
        underline2.updateHitbox();
        underline2.visible = false;
        add(underline2);

        var mintLine:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, Std.int(bar.height-2), 0xFF303036);
        mintLine.updateHitbox();
        mintLine.setPosition(mint.x+23, mint.y-1);
        add(mintLine);

        var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        black.updateHitbox();
        black.screenCenter();
        add(black);

        var mintStartLogo:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("mint"));
        mintStartLogo.scale.set(0.3, 0.3);
        mintStartLogo.updateHitbox();
        mintStartLogo.screenCenter();
        mintStartLogo.alpha = 0;
        add(mintStartLogo);

        new FlxTimer().start(1, _ -> {
            mintStartLogo.alpha = 1;
            FlxG.sound.play(Paths.sound('mint/login'));
        });

        new FlxTimer().start(4, _ -> {
            FlxTween.tween(mintStartLogo, {alpha: 0}, 0.3, {ease: FlxEase.linear});
        });
        new FlxTimer().start(5, _ -> {
            FlxTween.tween(black, {alpha: 0}, 0.5, {ease: FlxEase.linear, onComplete: _ -> {
                errorOpen = false;
            }});
        });
        //303036
    }

    function createFolder(filePaths:String) {
        if(editorSprites.length > 0) {
            windowBusy = true;
            closeTextEditor();
            new FlxTimer().start(0.11, _ -> {
                buildFolder(filePaths);
                windowBusy = false;
            });
        } else
            buildFolder(filePaths);
    }

    function buildFolder(filePaths:String) {
        underline1.visible = inFolder = true;

        FlxG.sound.play(Paths.sound('mint/openWindow'));

        var bgTop:FlxSprite = new FlxSprite(0,0).makeGraphic(553, 50, 0xFF222226);
        explorerSprites.push(bgTop);
        bgTop.screenCenter();
        bgTop.y -= 160;
        add(bgTop);

        var bgBottom:FlxSprite = new FlxSprite(bgTop.x, bgTop.y+bgTop.height).makeGraphic(553, 288, 0xFF2e2e33);
        explorerSprites.push(bgBottom);
        add(bgBottom);

        var bgSide:FlxSprite = new FlxSprite(bgBottom.x, bgBottom.y).makeGraphic(87, 288, 0xFF2c2c31);
        explorerSprites.push(bgSide);
        add(bgSide);

        var lineSide:FlxSprite = new FlxSprite(bgSide.x + bgSide.width, bgSide.y).makeGraphic(1, 273, 0xFF202023);
        explorerSprites.push(lineSide);
        add(lineSide);

        var bgVBottom:FlxSprite = new FlxSprite(bgBottom.x, bgBottom.y + bgBottom.height - 15).makeGraphic(553, 15, 0xFF2e2e33);
        explorerSprites.push(bgVBottom);
        add(bgVBottom);

        var lineBottom:FlxSprite = new FlxSprite(bgVBottom.x, bgVBottom.y).makeGraphic(553, 1, 0xFF29292e);
        explorerSprites.push(lineBottom);
        add(lineBottom);

        var lineTop:FlxSprite = new FlxSprite(bgTop.x, bgTop.y + bgTop.height).makeGraphic(553, 1, 0xFF000000);
        explorerSprites.push(lineTop);
        add(lineTop);

        var arrowDown:FlxSprite = new FlxSprite(0, 0).loadGraphic(img("pan-down")); //8
        arrowDown.updateHitbox();
        arrowDown.setPosition(bgSide.x, bgSide.y);
        explorerSprites.push(arrowDown);
        sidebarArrow = arrowDown;
        sidebarCollapsed = false;
        sidebarItems = [];
        add(arrowDown);

        var myComputer:FlxText = new FlxText(0, 0, 1000, 'My Computer');
        myComputer.setPosition(arrowDown.x+20, arrowDown.y+7);
        myComputer.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, LEFT);
        myComputer.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF, 2, 1);
        myComputer.scale.set(0.08, 0.08);
        myComputer.updateHitbox();
        explorerSprites.push(myComputer);
        add(myComputer);

        var fileNm:Array<String> = ['Home', 'Desktop', 'Documents', 'Music', 'Pictures', 'Videos', 'Downloads', 'Recent', 'Trash'];//18

        for(i in 0...fileNm.length) {
            var iconThing:FlxSprite = new FlxSprite(0, 0).loadGraphic(img(fileNm[i].toLowerCase()));
            iconThing.scale.set(0.16, 0.16);
            iconThing.updateHitbox();
            iconThing.setPosition(bgSide.x+17, myComputer.y+(16*i)+14);
            explorerSprites.push(iconThing);
            sidebarItems.push(iconThing);
            add(iconThing);

            var iconTxt:FlxText = new FlxText(0, 0, 1000, fileNm[i]);
            iconTxt.setPosition(iconThing.x+16, iconThing.y+4);
            iconTxt.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, LEFT);
            iconTxt.scale.set(0.08, 0.08);
            iconTxt.updateHitbox();
            explorerSprites.push(iconTxt);
            sidebarItems.push(iconTxt);
            add(iconTxt);
        }

        var hit1:FlxSprite = new FlxSprite(bgTop.x, bgTop.y + bgTop.height + 4).makeGraphic(Std.int(bgSide.width), Std.int(myComputer.height), 0xFFFFFFFF);
        explorerSprites.push(hit1);
        sidebarHits.push(hit1);
        hit1.alpha = 0;
        hit1.updateHitbox();
        add(hit1);

        for(i in 0...9) { //37
            var hit2:FlxSprite = new FlxSprite(bgTop.x, bgTop.y + bgTop.height + 21 + (16*i)).makeGraphic(Std.int(bgSide.width), Std.int(myComputer.height), 0xFFFFFFFF);
            explorerSprites.push(hit2);
            sidebarHits.push(hit2);
            sidebarItems.push(hit2);
            hit2.alpha = 0;
            hit2.updateHitbox();
            add(hit2);
        }

        var folderName:FlxText = new FlxText(0, 0, 500, 'Unofficial');
        folderName.setPosition(bgTop.x+269, bgTop.y+6);
        folderName.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, CENTER);
        folderName.scale.set(0.08, 0.08);
        folderName.updateHitbox();
        explorerSprites.push(folderName);
        add(folderName);

        var xIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('close'));
        xIcon.scale.set(0.14, 0.14);
        xIcon.updateHitbox();
        xIcon.setPosition(bgTop.x+bgTop.width-13, bgTop.y+3);
        explorerSprites.push(xIcon);
        add(xIcon);

        var _Icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('minimize'));
        _Icon.scale.set(0.14, 0.14);
        _Icon.updateHitbox();
        _Icon.setPosition(bgTop.x+bgTop.width-_Icon.width-16, bgTop.y+3);
        explorerSprites.push(_Icon);
        add(_Icon);

        var flText = new FlxText(0, 0, 202, 'File'); // 40
        flText.setPosition(bgTop.x+10, bgTop.y+10);
        flText.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, LEFT);
        flText.scale.set(0.08, 0.08);
        flText.updateHitbox();
        explorerSprites.push(flText);
        add(flText);

        var leftArr:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('back'));
        leftArr.scale.set(0.18, 0.18);
        leftArr.updateHitbox();
        leftArr.setPosition(bgTop.x+7, bgTop.y+28);
        explorerSprites.push(leftArr);
        explorerBack = leftArr;
        add(leftArr);

        var rightArr:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('forward'));
        rightArr.scale.set(0.18, 0.18);
        rightArr.updateHitbox();
        rightArr.setPosition(bgTop.x+33, bgTop.y+28);
        explorerSprites.push(rightArr);
        explorerForward = rightArr;
        maxSubfolderInd = subfolderInd;
        add(rightArr);

        var grid:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('grid'));
        grid.scale.set(0.18, 0.18);
        grid.updateHitbox();
        grid.setPosition(bgTop.x+bgTop.width-20, bgTop.y+28);
        explorerSprites.push(grid);
        add(grid);

        var fold:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('places'));
        fold.scale.set(0.12, 0.12);
        fold.updateHitbox();
        fold.setPosition(bgTop.x+7, bgBottom.y+bgBottom.height-12);
        explorerSprites.push(fold);
        add(fold);

        updateFolder(filePaths);

        popIn(explorerWindow());
    }

    function closeTextEditor() {
        underline2.visible = inEditor = false;
        typedLabel = null;
        #if mobile
        setKeyboard(false);
        #end

        var closing:Array<Dynamic> = editorSprites;

        if(highlightSpr != null) {
            remove(highlightSpr);
            highlightSpr = null;
        }

        editorSprites = [];
        editorSnap = null;

        if(closing.length == 0) return;

        for(sp in closing) {
            remove(sp, true);
            add(sp);
        }

        tweenWindow(closing, 0.8, 0, 0, 0, 0.05, () -> {
            for(sp in closing) {
                remove(sp, true);
                sp.destroy();
            }
        });

        FlxG.sound.play(Paths.sound('mint/closeWindow'));
    }

    function closeFolder() {
        underline1.visible = inFolder = false;

        if(highlightSpr != null) {
            remove(highlightSpr);
            highlightSpr = null;
        }

        var closing:Array<FlxSprite> = explorerWindow();

        folderIcons = [];
        explorerSprites = [];
        sidebarHits = [];
        sidebarItems = [];
        sidebarArrow = null;
        explorerBack = null;
        explorerForward = null;

        if(closing.length == 0) return;

        for(sp in closing) {
            remove(sp, true);
            add(sp);
        }

        tweenWindow(closing, 0.8, 0, 0, 0, 0.05, () -> {
            for(s in closing) {
                remove(s, true);
                s.destroy();
            }
        });
        FlxG.sound.play(Paths.sound('mint/closeWindow'));
    }

    function updateFolder(filePaths:String) {
        var names:Array<String> = filePaths.split(",");
        trace(names);

        for(i in 0...folderIcons.length) {
            for(g in 0...3) {
                remove(folderIcons[i][g], true);
                folderIcons[i][g].destroy();
            }
        }
        folderIcons = [];

        for(i in 0...names.length) {
            var canMoveForward = false;
            if(names[i].substr(0, 1) == "$") {
                canMoveForward = true;
                names[i] = names[i].substr(1, names[i].length-1);
            }

            var fileIcon:String = '';
            var iconScale:Float = 0.75;

            if(names[i].endsWith(".dat") || names[i].endsWith(".cnt") || names[i].endsWith(".json") || names[i].endsWith(".txt")) {
                fileIcon = 'text';
                iconScale = 0.57;
            } else if(names[i].endsWith(".webp")) {
                fileIcon = 'image';
            } else {
                fileIcon = 'desktopIcons/1';
                iconScale = 0.375;
            }

            var icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img(fileIcon));
            icon.scale.set(iconScale, iconScale);
            icon.updateHitbox();
            icon.setPosition(explorerSprites[0].x+80+(icon.width+70*i), explorerSprites[0].y+60);

            var hitbox:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(icon.width), Std.int(icon.height+10), 0xFFFFFFFF);
            hitbox.setPosition(icon.x, icon.y);
            hitbox.alpha = 0;

            var text:FlxText = new FlxText(0, 0, 850, names[i]);
            text.setPosition(icon.x - (icon.width/2)+2, icon.y + (icon.height)+1);
            text.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, CENTER);
            text.scale.set(0.09, 0.09);
            text.updateHitbox();
            folderIcons.push([icon, hitbox, text, canMoveForward, names[i]]);

            add(icon);
            add(hitbox);
            add(text);
        }
    }

    function createTextEditor() {
        subfolderInd = folderInd = 0;

        FlxG.sound.play(Paths.sound('mint/openWindow'));

        underline2.visible = true;

        var topBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(325, 52, 0xFF222226);
        topBar.updateHitbox();
        topBar.screenCenter();
        topBar.y -= 100;
        editorSprites.push(topBar);
        add(topBar);

        var middleBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(325, 17, 0xFF2e2e33);
        middleBar.setPosition(topBar.x, topBar.y+topBar.height-1);
        middleBar.updateHitbox();
        editorSprites.push(middleBar);
        add(middleBar);

        var tab:FlxSprite = new FlxSprite(0, 0).makeGraphic(94, 15, 0xFF2e2e33);
        tab.updateHitbox();
        editorSprites.push(tab);
        tab.setPosition(middleBar.x+2, middleBar.y+(middleBar.height-tab.height+1));
        add(tab);

        var bottom:FlxSprite = new FlxSprite(0, 0).makeGraphic(325, 197, 0xFF2e2e33);
        bottom.setPosition(middleBar.x, middleBar.y+middleBar.height);
        bottom.updateHitbox();
        editorSprites.push(bottom);
        add(bottom);

        var lineTop:FlxSprite = new FlxSprite(0, 0).makeGraphic(325, 1, 0xFF000000);
        lineTop.setPosition(topBar.x, topBar.y+topBar.height-1);
        lineTop.updateHitbox();
        editorSprites.push(lineTop);
        add(lineTop);

        var lineTab1:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, Std.int(tab.height), 0xFF202023);
        lineTab1.setPosition(tab.x, tab.y);
        lineTab1.updateHitbox();
        editorSprites.push(lineTab1);
        add(lineTab1);

        var lineTab2:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(tab.width), 1, 0xFF202023);
        lineTab2.setPosition(tab.x, tab.y);
        lineTab2.updateHitbox();
        editorSprites.push(lineTab2);
        add(lineTab2);
            
        var lineTab3:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, Std.int(tab.height), 0xFF202023);
        lineTab3.setPosition(tab.x+tab.width, tab.y);
        lineTab3.updateHitbox();
        editorSprites.push(lineTab3);
        add(lineTab3);

        var lineTab4:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(325-tab.width-2), 1, 0xFF202023);
        lineTab4.setPosition(tab.x+tab.width, tab.y+tab.height);
        lineTab4.updateHitbox();
        editorSprites.push(lineTab4);
        add(lineTab4);

        var lineTab5:FlxSprite = new FlxSprite(0, 0).makeGraphic(3, 1, 0xFF202023);
        lineTab5.setPosition(middleBar.x, tab.y+tab.height);
        lineTab5.updateHitbox();
        editorSprites.push(lineTab5);
        add(lineTab5);

        var lineB:FlxSprite = new FlxSprite(0, 0).makeGraphic(325, 1, 0xFF202023);
        lineB.setPosition(bottom.x, bottom.y+bottom.height-17);
        lineB.updateHitbox();
        editorSprites.push(lineB);
        add(lineB);

        var editorText:FlxText = new FlxText(0, 0, 2000, unlockText);
        editorText.setPosition(bottom.x+4,  bottom.y-5);
        editorText.setFormat(Paths.font("UbuntuSans.ttf"), 20, 0xFFFFFFFF, LEFT);
        editorText.scale.set(0.4, 0.4);
        editorText.updateHitbox();
        editorSprites.push(editorText);
        add(editorText);

        fileText = new FlxText(0, 0, 200, 'File');
        fileText.setPosition(bottom.x+10, bottom.y-50);
        fileText.setFormat(Paths.font("UbuntuSans.ttf"), 100, 0xFFFFFFFF, LEFT);
        fileText.scale.set(0.08, 0.08);
        fileText.updateHitbox();
        editorSprites.push(fileText);
        add(fileText);

        var iconS:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('text'));
        iconS.scale.set(0.12, 0.12);
        iconS.updateHitbox();
        iconS.setPosition(tab.x+6, tab.y+5);
        iconS.antialiasing = false;
        editorSprites.push(iconS);
        add(iconS);

        var fileText2:FlxText = new FlxText(0, 0, 2000, 'ContainFatalError.cnt');
        fileText2.setPosition(iconS.x+11, iconS.y+2);
        fileText2.setFormat(Paths.font("UbuntuSans.ttf"), 20, 0xFFFFFFFF, LEFT);
        fileText2.scale.set(0.3, 0.3);
        fileText2.updateHitbox();
        editorSprites.push(fileText2);
        add(fileText2);

        var fileText3:FlxText = new FlxText(0, 0, 2000, 'Ln 9, Col 2         INS');
        fileText3.setPosition(bottom.x+254, bottom.y+bottom.height-11);
        fileText3.setFormat(Paths.font("UbuntuSans.ttf"), 20, 0xFFFFFFFF, LEFT);
        fileText3.scale.set(0.4, 0.4);
        fileText3.updateHitbox();
        editorSprites.push(fileText3);
        add(fileText3);

        var fileText4:FlxText = new FlxText(0, 0, 2000, 'ContainFatalError.cnt (~/Desktop/Unofficial/assets/exe/OPEN ME PLAYER)');
        fileText4.setPosition(bottom.x-243, topBar.y+5);
        fileText4.setFormat(Paths.font("UbuntuSans.ttf"), 20, 0xFFFFFFFF, CENTER);
        fileText4.scale.set(0.4, 0.4);
        fileText4.updateHitbox();
        editorSprites.push(fileText4);
        add(fileText4);

        var xIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('close')); //17
        xIcon.scale.set(0.14, 0.14);
        xIcon.updateHitbox();
        xIcon.setPosition(tab.x+310, tab.y-50);
        editorSprites.push(xIcon);
        add(xIcon);

        var _Icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('minimize'));
        _Icon.scale.set(0.14, 0.14);
        _Icon.updateHitbox();
        _Icon.setPosition(tab.x+305-_Icon.width, tab.y-50);
        editorSprites.push(_Icon);
        add(_Icon);

        var saveIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('downloads'));
        saveIcon.scale.set(0.14, 0.14);
        saveIcon.updateHitbox();
        saveIcon.setPosition(tab.x+5, tab.y-20);
        editorSprites.push(saveIcon);
        add(saveIcon);

        var xIcon2:FlxSprite = new FlxSprite(0, 0).loadGraphic(img('close'));
        xIcon2.scale.set(0.12, 0.12);
        xIcon2.updateHitbox();
        xIcon2.setPosition(tab.x+6, tab.y+5);
        editorSprites.push(xIcon2);
        add(xIcon2);

        fileHitbox = new FlxSprite(0, 0).makeGraphic(Std.int(fileText.textField.textWidth * 0.08 + 6), Std.int(fileText.height + 2), 0xFFFFFFFF);
        fileHitbox.setPosition(fileText.x - 3, fileText.y - 1);
        fileHitbox.alpha = 0;
        editorSprites.push(fileHitbox);
        add(fileHitbox);

        var promptEnd = editorText.textField.getCharBoundaries(unlockText.length - 1);
        var labelX:Float = editorText.x + (promptEnd != null ? (promptEnd.x + promptEnd.width - 2) * 0.4 : 4);
        var labelY:Float = editorText.y + (promptEnd != null ? (promptEnd.y - 2) * 0.4 : 0);

        typedLabel = new FlxText(labelX, labelY, 0, '');
        typedLabel.setFormat(Paths.font("UbuntuSans.ttf"), 20, 0xFFFFFFFF, LEFT);
        typedLabel.scale.set(0.4, 0.4);
        typedLabel.updateHitbox();
        editorSprites.push(typedLabel);
        add(typedLabel);

        inEditor = true;
        popIn(editorSprites);
    }

    function error() {
        if(errorOpen) return;
        errorOpen = true;

        if(highlightSpr != null) {
            remove(highlightSpr);
            highlightSpr = null;
        }

        FlxG.sound.play(Paths.sound('mint/openWindow'));

        errok = new FlxSprite(0, 0).loadGraphic(Paths.getBitmapData('assets/exe/access/fatal/cutscene/errok.webp'));
        errok.scale.set(3, 3);
        errok.antialiasing = false;
        errok.updateHitbox();
        errok.screenCenter();
        add(errok);

        errokHit = new FlxSprite(errok.x+141, errok.y+123).makeGraphic(114, 45, 0xFFFFFFFF);
        errokHit.alpha = 0;
        add(errokHit);

        popIn([errok, errokHit]);
    }

    function closeError() {
        errorOpen = false;

        var closing:Array<Dynamic> = [errok, errokHit];
        errok = null;
        errokHit = null;

        tweenWindow(closing, 0.8, 0, 0, 0, 0.1, () -> {
            for(sp in closing) {
                remove(sp, true);
                sp.destroy();
            }
        });
        FlxG.sound.play(Paths.sound('mint/closeWindow'));
    }

    function clicked():Bool {
        #if mobile
        return shortPress && FlxG.mouse.justReleased;
        #else
        return FlxG.mouse.justReleased;
        #end
    }

    function dragging():Bool {
        #if mobile
        return pressHolding;
        #else
        return true;
        #end
    }

    function setBright(s:FlxSprite, on:Bool) {
        var state:Int = on ? 1 : 0;
        if(s.ID == state) return;
        s.ID = state;
        var o:Float = on ? 60 : 0;
        s.setColorTransform(1, 1, 1, 1, o, o, o, 0);
    }

    function setHighlight(sprite:FlxSprite, alpha:Float) {
        highlightedThisFrame = true;
        if(highlightSpr == null) {
            highlightSpr = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFFFFFFFF);
            add(highlightSpr);
        }
        highlightSpr.setGraphicSize(sprite.width, sprite.height);
        highlightSpr.updateHitbox();
        highlightSpr.setPosition(sprite.x, sprite.y);
        highlightSpr.alpha = alpha;
    }

    function flattenEntries(entries:Array<Array<Dynamic>>):Array<FlxSprite> {
        var all:Array<FlxSprite> = [];
        for(e in entries) for(g in 0...3) all.push(e[g]);
        return all;
    }

    function saveFile() {
        savedText = unlockText+typedText;

        var answer:Null<Bool> = FatalAccess.parseAnswer(typedText);
        if(answer == null || windowBusy) return;

        windowBusy = true;
        errorOpen = true;

        if(answer)
            FlxG.save.data.fatalGranted = true;
        else
            FlxG.save.data.fatalDenied = true;
        FlxG.save.flush();

        var scene:FatalScene = answer ? FatalScene.GRANTED : FatalScene.DENIED;
        FlxG.sound.music?.stop();

        new FlxTimer().start(0.5, _ -> {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            FlxG.switchState(() -> new FatalAccess(scene));
        });
    }

    var editorX:Float;
    var editorY:Float;
    var folderX:Float;
    var folderY:Float;
    var editorSnap:Array<Array<Float>> = [];
    var folderSnap:Array<Array<Float>> = [];

    function snapIconToGrid(index:Int) {
        var entry = icons[index];
        var icon = entry[0];
        var cell:Float = icons[0][0].height + 30;
        var originX:Float = 30;

        var left:Float = 999999;
        var top:Float = 999999;
        var right:Float = -999999;
        var bottom:Float = -999999;
        for(g in 0...3) {
            var s = entry[g];
            if(s.x < left) left = s.x;
            if(s.y < top) top = s.y;
            if(s.x + s.width > right) right = s.x + s.width;
            if(s.y + s.height > bottom) bottom = s.y + s.height;
        }
        var offL:Float = left - icon.x;
        var offT:Float = top - icon.y;
        var offR:Float = right - icon.x;
        var offB:Float = bottom - icon.y;

        var wantCol:Float = (icon.x - originX) / cell;
        var wantRow:Float = icon.y / cell;

        var bestCol:Int = -1;
        var bestRow:Int = -1;
        var bestDist:Float = 999999;

        var cols:Int = Math.floor(FlxG.width / cell) + 1;
        var rows:Int = Math.floor(bar.y / cell) + 1;
        for(c in 0...cols) {
            for(r in 0...rows) {
                var gx:Float = originX + c * cell;
                var gy:Float = r * cell;
                if(gx + offL < 0 || gx + offR > FlxG.width || gy + offT < 0 || gy + offB > bar.y) continue;

                var taken:Bool = false;
                for(j in 0...icons.length) {
                    if(j == index) continue;
                    var o = icons[j][0];
                    if(Math.round((o.x - originX) / cell) == c && Math.round(o.y / cell) == r) {
                        taken = true;
                        break;
                    }
                }
                if(taken) continue;

                var dist:Float = (c - wantCol) * (c - wantCol) + (r - wantRow) * (r - wantRow);
                if(dist < bestDist) {
                    bestDist = dist;
                    bestCol = c;
                    bestRow = r;
                }
            }
        }

        if(bestCol == -1) return;

        if(left < 0 || top < 0 || right > FlxG.width || bottom > bar.y)
            FlxG.sound.play(Paths.sound('mint/tile'));

        var dx:Float = originX + bestCol * cell - icon.x;
        var dy:Float = bestRow * cell - icon.y;
        for(g in 0...3) {
            entry[g].x += dx;
            entry[g].y += dy;
        }
    }

    function snapToDesktop(sprites:Array<Dynamic>, skipText:Bool) {
        var left:Float = 999999;
        var top:Float = 999999;
        var right:Float = -999999;
        var bottom:Float = -999999;
        for(s in sprites) {
            if(skipText && Std.isOfType(s, FlxText)) continue;
            if(s.x < left) left = s.x;
            if(s.y < top) top = s.y;
            if(s.x + s.width > right) right = s.x + s.width;
            if(s.y + s.height > bottom) bottom = s.y + s.height;
        }

        var dx:Float = 0;
        var dy:Float = 0;
        if(left < 0) dx = -left;
        else if(right > FlxG.width) dx = FlxG.width - right;
        if(top < 0) dy = -top;
        else if(bottom > bar.y) dy = bar.y - bottom;

        if(dx == 0 && dy == 0) return;

        FlxG.sound.play(Paths.sound('mint/tile'));

        for(s in sprites) {
            s.x += dx;
            s.y += dy;
        }
    }

    function minimizeWindow(window:Array<Dynamic>, windowName:String, icon:FlxSprite) {
        var left:Float = 999999;
        var top:Float = 999999;
        var right:Float = -999999;
        var bottom:Float = -999999;
        for(s in window) {
            if(Std.isOfType(s, FlxText)) continue;
            if(s.x < left) left = s.x;
            if(s.y < top) top = s.y;
            if(s.x + s.width > right) right = s.x + s.width;
            if(s.y + s.height > bottom) bottom = s.y + s.height;
        }

        if(windowName == 'editor') {
            inEditor = false;
            #if mobile
            setKeyboard(false);
            #end
        }
        else if(windowName == 'folder') inFolder = false;

        var centerX:Float = (left + right) / 2;
        var centerY:Float = (top + bottom) / 2;

        var snap:Array<Array<Float>> = [];
        for(s in window)
            snap.push([s.x + s.width / 2, s.y + s.height / 2, s.scale.x, s.scale.y, s.alpha]);

        if(windowName == 'editor')
            editorSnap = snap;
        else if(windowName == 'folder')
            folderSnap = snap;

        tweenWindow(window, 0, icon.x + icon.width / 2 - centerX, icon.y + icon.height / 2 - centerY, 1, 0.1);
        FlxG.sound.play(Paths.sound('mint/minimize'));
    }

    function unminimizeWindow(window:Array<Dynamic>, windowName:String) {
        var snap:Array<Array<Float>> = windowName == 'editor' ? editorSnap : folderSnap;
        if(snap == null || window.length == 0 || snap.length != window.length) return;

        if(windowName == 'editor') inEditor = true;
        else if(windowName == 'folder') inFolder = true;

        var startX:Array<Float> = [];
        var startY:Array<Float> = [];
        var startScaleX:Array<Float> = [];
        var startScaleY:Array<Float> = [];
        var startAlpha:Array<Float> = [];

        for(s in window) {
            startX.push(s.x + s.width / 2);
            startY.push(s.y + s.height / 2);
            startScaleX.push(s.scale.x);
            startScaleY.push(s.scale.y);
            startAlpha.push(s.alpha);
        }

        FlxTween.num(0, 1, 0.1, {ease: FlxEase.linear}, function(t:Float) {
            for(i in 0...window.length) {
                var s = window[i];
                if(s == null || s.scale == null) continue;
                var e = snap[i];
                s.scale.set(startScaleX[i] + (e[2] - startScaleX[i]) * t, startScaleY[i] + (e[3] - startScaleY[i]) * t);
                s.alpha = startAlpha[i] + (e[4] - startAlpha[i]) * t;
                s.updateHitbox();
                var cx = startX[i] + (e[0] - startX[i]) * t;
                var cy = startY[i] + (e[1] - startY[i]) * t;
                s.setPosition(cx - s.width / 2, cy - s.height / 2);
            }
        });
        FlxG.sound.play(Paths.sound('mint/minimize'));
    }

    function explorerWindow():Array<FlxSprite> {
        return explorerSprites.concat(flattenEntries(folderIcons));
    }

    function popStep(sprites:Array<Dynamic>, endX:Array<Float>, endY:Array<Float>, endScaleX:Array<Float>, endScaleY:Array<Float>, endAlpha:Array<Float>, pivotX:Float, pivotY:Float, t:Float) {
        var k:Float = 0.7 + 0.3 * t;
        for(i in 0...sprites.length) {
            var s = sprites[i];
            if(s == null || s.scale == null) continue;
            s.scale.set(endScaleX[i] * k, endScaleY[i] * k);
            s.alpha = endAlpha[i] * t;
            s.updateHitbox();
            var cx = pivotX + (endX[i] - pivotX) * k;
            var cy = pivotY + (endY[i] - pivotY) * k;
            s.setPosition(cx - s.width / 2, cy - s.height / 2);
        }
    }

    function popIn(sprites:Array<Dynamic>) {
        if(sprites.length == 0) return;

        var left:Float = 999999;
        var top:Float = 999999;
        var right:Float = -999999;
        var bottom:Float = -999999;
        var endX:Array<Float> = [];
        var endY:Array<Float> = [];
        var endScaleX:Array<Float> = [];
        var endScaleY:Array<Float> = [];
        var endAlpha:Array<Float> = [];

        for(s in sprites) {
            if(!Std.isOfType(s, FlxText)) {
                if(s.x < left) left = s.x;
                if(s.y < top) top = s.y;
                if(s.x + s.width > right) right = s.x + s.width;
                if(s.y + s.height > bottom) bottom = s.y + s.height;
            }
            endX.push(s.x + s.width / 2);
            endY.push(s.y + s.height / 2);
            endScaleX.push(s.scale.x);
            endScaleY.push(s.scale.y);
            endAlpha.push(s.alpha);
        }

        var pivotX:Float = (left + right) / 2;
        var pivotY:Float = (top + bottom) / 2;

        popStep(sprites, endX, endY, endScaleX, endScaleY, endAlpha, pivotX, pivotY, 0);

        FlxTween.num(0, 1, 0.1, {ease: FlxEase.linear}, function(t:Float) {
            popStep(sprites, endX, endY, endScaleX, endScaleY, endAlpha, pivotX, pivotY, t);
        });
    }

    function tweenSprites(sprites:Array<Dynamic>, targetScale:Float, pivotX:Float, pivotY:Float, moveX:Float, moveY:Float, alpha:Float, duration:Float, ?onComplete:Void->Void) {
        var startX:Array<Float> = [];
        var startY:Array<Float> = [];
        var startScaleX:Array<Float> = [];
        var startScaleY:Array<Float> = [];
        var startScaleA:Array<Float> = [];

        for(s in sprites) {
            startX.push(s.x + s.width / 2);
            startY.push(s.y + s.height / 2);
            startScaleX.push(s.scale.x);
            startScaleY.push(s.scale.y);
            startScaleA.push(s.alpha);
        }

        FlxTween.num(0, 1, duration, {ease: FlxEase.linear, onComplete: _ -> {
            if(onComplete != null) onComplete();
        }}, function(t:Float) {
            var k:Float = 1 + (targetScale - 1) * t;
            for(i in 0...sprites.length) {
                var s = sprites[i];
                if(s == null || s.scale == null) continue;
                s.scale.set(startScaleX[i] * k, startScaleY[i] * k);
                s.alpha = startScaleA[i] * (1 + (alpha - 1) * t);
                s.updateHitbox();
                var cx = pivotX + (startX[i] - pivotX) * k + moveX * t;
                var cy = pivotY + (startY[i] - pivotY) * k + moveY * t;
                s.setPosition(cx - s.width / 2, cy - s.height / 2);
            }
        });
    }

    function tweenWindow(sprites:Array<Dynamic>, targetScale:Float, moveX:Float, moveY:Float, alpha:Float, duration:Float, ?onComplete:Void->Void) {
        var left:Float = 999999;
        var top:Float = 999999;
        var right:Float = -999999;
        var bottom:Float = -999999;
        for(s in sprites) {
            if(Std.isOfType(s, FlxText)) continue;
            if(s.x < left) left = s.x;
            if(s.y < top) top = s.y;
            if(s.x + s.width > right) right = s.x + s.width;
            if(s.y + s.height > bottom) bottom = s.y + s.height;
        }
        tweenSprites(sprites, targetScale, (left + right) / 2, (top + bottom) / 2, moveX, moveY, alpha, duration, onComplete);
    }

    function pollTyping():Void {
        #if mobile
        if(FlxG.keys.justPressed.BACKSPACE && typedText.length > 0)
            typedText = typedText.substr(0, typedText.length-1);

        for(ch in pendingChars) {
            if(typedText.length < 8 && ch.length > 0 && ch.charCodeAt(0) >= 32)
                typedText += ch;
        }
        pendingChars = [];
        return;
        #end

        var shift:Bool = FlxG.keys.pressed.SHIFT;
        for(k in FlxG.keys.getIsDown()) {
            if(!k.justPressed) continue;
            var id:Int = k.ID;
            if(id == 8)
                if(typedText.length > 0) typedText = typedText.substr(0, typedText.length-1);
            
            if(typedText.length < 8) {
                if(id == 32) {
                    typedText += " ";
                } else if(id >= 65 && id <= 90) {
                    typedText += (shift ? "ABCDEFGHIJKLMNOPQRSTUVWXYZ" : "abcdefghijklmnopqrstuvwxyz").charAt(id - 65);
                } else if(id >= 48 && id <= 57) {
                    typedText += shift ? ")!@#$%^&*(".charAt(id - 48) : "0123456789".charAt(id - 48);
                } else if(id == 190) {
                    typedText += shift ? ">" : ".";
                } else if(id == 188) {
                    typedText += shift ? "<" : ",";
                } else if(id == 189) {
                    typedText += shift ? "_" : "-";
                } else if(id == 191) {
                    typedText += shift ? "?" : "/";
                } else if(id == 186) {
                    typedText += shift ? ":" : ";";
                } else if(id == 222) {
                    typedText += shift ? "\"" : "'";
                }
            }
        }
    }

    override function update(elapsed:Float) {
        mouseClickLeft = FlxG.mouse.pressed;
        mouseClickRight = FlxG.mouse.pressedRight;
        mouseDeltaX = FlxG.mouse.deltaScreenX;
        mouseDeltaY = FlxG.mouse.deltaScreenY;

        if(inEditor) {
            editorSprites[14].text = prefixTxt + 'ContainFatalError.cnt';
            editorSprites[15].text = 'Ln 9, Col ${1+typedText.length}         INS';
            editorSprites[16].text = prefixTxt + 'ContainFatalError.cnt (~/Desktop/Unofficial/assets/exe/OPEN ME PLAYER)';
        }

        super.update(elapsed);

        #if mobile
        if(updatePinch()) return;
        #end

        if(errorOpen) {
            if(errokHit != null && clicked() && FlxG.mouse.overlaps(errokHit))
                closeError();
            return;
        }

        highlightedThisFrame = false;

        var clockNow:String = DateTools.format(Date.now(), "%H:%M");
        if(clockText.text != clockNow) clockText.text = clockNow;

        if(inEditor) {
            pollTyping();
            if(typedLabel != null && typedLabel.text != typedText) {
                typedLabel.text = typedText;
                typedLabel.updateHitbox();
            }
            if(clicked() && FlxG.mouse.overlaps(taskbarIcons[8])) {
                minimizeWindow(editorSprites, 'editor', taskbarIcons[8]);
            } else if(FlxG.mouse.overlaps(editorSprites[17])) {
                setHighlight(editorSprites[17], 0.3);
                if(clicked()) {
                    closeTextEditor();
                }
            } else if(FlxG.mouse.overlaps(editorSprites[12])) {
                setHighlight(editorSprites[12], 0.3);
                if(clicked()) error();
            } else if(FlxG.mouse.overlaps(editorSprites[18])) {
                setHighlight(editorSprites[18], 0.3);
                if(clicked()) {
                    minimizeWindow(editorSprites, 'editor', taskbarIcons[8]);
                }
            } else if(FlxG.mouse.overlaps(editorSprites[19])) {
                setHighlight(editorSprites[19], 0.3);
                if(clicked()) saveFile();
            } else if(inEditor && FlxG.mouse.justPressed && FlxG.mouse.overlaps(editorSprites[0])) {
                draggingEditor = true;
            }

            #if mobile
            if(inEditor && !highlightedThisFrame && clicked() && FlxG.mouse.overlaps(editorSprites[3]))
                setKeyboard(true);
            #end
        } else {
            if(editorSprites != [] && clicked() && FlxG.mouse.overlaps(taskbarIcons[8])) unminimizeWindow(editorSprites, 'editor');
        }

        if(savedText != unlockText+typedText)
            prefixTxt = '*';
        else
            prefixTxt = '';
        
        for(i in 0...taskbarIcons.length) {
            if(FlxG.mouse.overlaps(taskbarIcons[i])) {
                setHighlight(taskbarIcons[i], 0.3);
                if(clicked() && i != 1 && i != 8) error();
                break;
            }
        }

        if(!highlightedThisFrame && highlightSpr != null) {
            remove(highlightSpr);
            highlightSpr = null;
        }

        var overWindow:Bool = (inFolder && (FlxG.mouse.overlaps(explorerSprites[0]) || FlxG.mouse.overlaps(explorerSprites[1])))
            || (inEditor && (FlxG.mouse.overlaps(editorSprites[0]) || FlxG.mouse.overlaps(editorSprites[3])));

        if(FlxG.mouse.justPressed && pressedIcon == -1 && !overWindow) {
            for(i in 0...icons.length) {
                if(FlxG.mouse.overlaps(icons[i][1])) {
                    pressedIcon = i;
                    iconDragDist = 0;
                    break;
                }
            }
        }

        if(pressedIcon != -1 && mouseClickLeft && dragging()) {
            iconDragDist += Math.abs(FlxG.mouse.deltaX) + Math.abs(FlxG.mouse.deltaY);
            if(iconDragDist > 4) {
                for(g in 0...3) {
                    icons[pressedIcon][g].x += FlxG.mouse.deltaX;
                    icons[pressedIcon][g].y += FlxG.mouse.deltaY;
                }
            }
        }

        if(pressedIcon != -1 && !mouseClickLeft) {
            if(iconDragDist <= 4) {
                if(paths[pressedIcon].length > 1 && !inFolder && !windowBusy) {
                    cooldown = 0.1;
                    subfolderInd = 1;
                    folderInd = pressedIcon;
                    createFolder(paths[folderInd][subfolderInd]);
                } else
                    error();
            } else {
                snapIconToGrid(pressedIcon);
            }
            pressedIcon = -1;
        }

        for(e in icons) {
            var hover:Bool = FlxG.mouse.overlaps(e[1]);
            setBright(e[0], hover);
            setBright(e[2], hover);
        }

        for(e in folderIcons) {
            var hover:Bool = FlxG.mouse.overlaps(e[1]);
            setBright(e[0], hover);
            setBright(e[2], hover);
        }
        if(inEditor) setBright(fileText, FlxG.mouse.overlaps(fileHitbox));

        if(!mouseClickLeft && draggingEditor) {
            draggingEditor = false;
            snapToDesktop(editorSprites, true);
        }

        if(inEditor && draggingEditor && dragging()) {
            for(sprite in editorSprites) {
                sprite.x += FlxG.mouse.deltaX;
                sprite.y += FlxG.mouse.deltaY;
            }
        }

        if(!mouseClickLeft && draggingExplorer) {
            draggingExplorer = false;
            snapToDesktop(explorerWindow(), true);
        }

        if(inFolder && draggingExplorer && dragging()) {
            for(sprite in explorerWindow()) {
                sprite.x += FlxG.mouse.deltaX;
                sprite.y += FlxG.mouse.deltaY;
            }
        }

        if(inFolder) {
            for(i in 0...folderIcons.length) {
                if(clicked() && cooldown <= 0 && FlxG.mouse.overlaps(folderIcons[i][1])) {
                    cooldown = 0.1;
                    if(!folderIcons[i][3]) {
                        trace(folderIcons[i][4]);
                        if(folderIcons[i][4] == 'ContainFatalError.cnt' && !windowBusy) {
                            windowBusy = true;
                            closeFolder();
                            new FlxTimer().start(0.11, _ -> {
                                createTextEditor();
                                windowBusy = false;
                            });
                            return;
                        } else
                            error();
                    } else if(subfolderInd + 1 < paths[folderInd].length) {
                        subfolderInd++;
                        if(subfolderInd > maxSubfolderInd) maxSubfolderInd = subfolderInd;
                        updateFolder(paths[folderInd][subfolderInd]);
                    } else
                        error();
                    break;
                }
            }

            if(subfolderInd > 1 && FlxG.mouse.overlaps(explorerBack)) {
                setHighlight(explorerBack, 0.3);
                if(clicked()) {
                    subfolderInd--;
                    updateFolder(paths[folderInd][subfolderInd]);
                }
            } else if(subfolderInd < maxSubfolderInd && FlxG.mouse.overlaps(explorerForward)) {
                setHighlight(explorerForward, 0.3);
                if(clicked()) {
                    subfolderInd++;
                    updateFolder(paths[folderInd][subfolderInd]);
                }
            }

            if(FlxG.mouse.overlaps(explorerSprites[39])) {
                setHighlight(explorerSprites[39], 0.3);
                if(clicked()) {
                    minimizeWindow(explorerWindow(), 'folder', taskbarIcons[1]);
                }
            } else if(FlxG.mouse.overlaps(explorerSprites[38])) {
                setHighlight(explorerSprites[38], 0.3);
                if(clicked()) {
                    closeFolder();
                    return;
                }
            } else if(FlxG.mouse.overlaps(taskbarIcons[1]) && clicked()) {
                minimizeWindow(explorerWindow(), 'folder', taskbarIcons[1]);
            } else if(FlxG.mouse.overlaps(explorerSprites[40])) {
                setHighlight(explorerSprites[40], 0.3);
                if(clicked()) error();
            }
            
            if(FlxG.mouse.overlaps(explorerSprites[44])) {
                setBright(explorerSprites[44], true);
                if(clicked()) error();
            } else
                setBright(explorerSprites[44], false);


            for(hit in sidebarHits) {
                if(hit.visible && FlxG.mouse.overlaps(hit)) {
                    setHighlight(hit, 0.3);
                    if(clicked() && hit != sidebarHits[0]) error();
                    break;
                }
            }

            if(clicked() && sidebarHits.length > 0 && FlxG.mouse.overlaps(sidebarHits[0])) {
                sidebarCollapsed = !sidebarCollapsed;
                for(item in sidebarItems) item.visible = !sidebarCollapsed;
                sidebarArrow.loadGraphic(img(sidebarCollapsed ? "pan-end" : "pan-down"));
            }

            if(!highlightedThisFrame && explorerSprites.length > 0 && FlxG.mouse.justPressed && !draggingEditor && FlxG.mouse.overlaps(explorerSprites[0]))
                draggingExplorer = true;
        } else {
            if(clicked() && FlxG.mouse.overlaps(taskbarIcons[1])) unminimizeWindow(explorerWindow(), 'folder');
        }

        if(cooldown > 0) cooldown -= elapsed;
    }
}