package states.extras.dagarden;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.media.Sound;

import sys.FileSystem;
import sys.io.File;

import backend.InputFormatter;

class DAGSongs extends MusicBeatSubstate
{
    public var songList:Array<String>          = [];
    public var songMods:Array<String>          = [];
    public var songCredits:Array<Array<String>> = [];
    public var selectedIndex:Int               = -1;
    public var onSelect:Int->Void              = null;
    public var onChangeSelection:Void->Int     = null;

    var boxes:Array<FlxSprite> = [];
    var covers:Array<FlxSprite> = [];
    var labels:Array<FlxText>  = [];
    var hasCover:Array<Bool>   = [];
    var scrollY:Float      = 0.0;
    var scrollTarget:Float = 0.0;

    public function new()
    {
        super();
        loadAll();
        buildBoxes();
    }

    override public function destroy():Void
    {
        for (bx in boxes) bx?.destroy();
        for (cv in covers) cv?.destroy();
        for (lbl in labels) lbl?.destroy();
        
        boxes = [];
        covers = [];
        labels = [];
        hasCover = [];
        songList = [];
        songMods = [];
        songCredits = [];
        
        super.destroy();
    }

    public function selectIndex(i:Int):Void
    {
        if (i < 0 || i >= boxes.length) return;

        if (selectedIndex >= 0 && selectedIndex < boxes.length)
        {
            final p = hasCover[selectedIndex] ? covers[selectedIndex] : boxes[selectedIndex];
            FlxTween.cancelTweensOf(p);
            FlxTween.cancelTweensOf(labels[selectedIndex]);
            FlxTween.tween(p, {x: 86.0}, 0.15, {ease: FlxEase.quadOut});
            FlxTween.tween(labels[selectedIndex], {x: 96.0}, 0.15, {ease: FlxEase.quadOut});
        }

        selectedIndex = i;
        final c = hasCover[i] ? covers[i] : boxes[i];
        FlxTween.cancelTweensOf(c);
        FlxTween.cancelTweensOf(labels[i]);
        FlxTween.tween(c, {x: 104.0}, 0.2, {ease: FlxEase.quadOut});
        FlxTween.tween(labels[i], {x: 114.0}, 0.2, {ease: FlxEase.quadOut});
    }

    public function selectSong(i:Int):Void
    {
        if (songList.length == 0 || i < 0 || i >= songList.length) return;
        selectIndex(i);
        if (onSelect != null) onSelect(i);
        scrollToSelected();
    }

    public inline function selectedSong():String           return selectedIndex >= 0 ? songList[selectedIndex] : '';
    public inline function selectedMod():String            return selectedIndex >= 0 ? songMods[selectedIndex] : '';
    public inline function selectedCredits():Array<String> return selectedIndex >= 0 && selectedIndex < songCredits.length ? songCredits[selectedIndex] : [];

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        final wheel = #if !mobile FlxG.mouse.deltaWheel.y #else deltaMouseY #end;
        if (wheel != 0 #if mobile && pressHolding #end) scrollTarget -= wheel #if !mobile * 80.0 #end;

        if (onChangeSelection != null)
        {
            final dir = onChangeSelection();
            if (dir != 0 && songList.length > 0) changeSelection(dir);
        }

        final maxScroll = Math.max(0.0, (songList.length - 1) * 120.0 - (FlxG.height - 116.0 - 120.0));
        scrollTarget = FlxMath.bound(scrollTarget, 0, maxScroll);
        scrollY += (scrollTarget - scrollY) * FlxMath.bound(18.0 * elapsed, 0, 1);

        for (i in 0...boxes.length)
        {
            final yPos = 116.0 + i * 120.0 - scrollY;
            boxes[i].y  = yPos;
            covers[i].y = yPos;
            labels[i].y = yPos + 8;
            final vis = yPos > -4.0 && yPos < FlxG.height;
            boxes[i].visible  = vis && !hasCover[i];
            covers[i].visible = vis;
            labels[i].visible = vis && !hasCover[i];
        }

        if (FlxG.mouse.justPressed)
        {
            final mx = FlxG.mouse.x;
            final my = FlxG.mouse.y;
            for (i in 0...boxes.length)
            {
                final hit = hasCover[i] ? covers[i] : boxes[i];
                if (!hit.visible || mx < hit.x || mx > hit.x + hit.width || my < hit.y || my > hit.y + hit.height) continue;
                selectSong(i);
                break;
            }
        }
    }

    function changeSelection(delta:Int):Void
    {
        if (songList.length == 0) return;
        final next = Std.int(FlxMath.bound(selectedIndex + delta, 0, songList.length - 1));
        if (next == selectedIndex) return;
        selectSong(next);
    }

    function scrollToSelected():Void
    {
        final targetY  = 116.0 + selectedIndex * 120.0;
        final visibleH = FlxG.height - 116.0 - 120.0;
        final desiredCenterY = FlxG.height / 2.0 - 60.0;
        scrollTarget = targetY - desiredCenterY;
        scrollTarget = FlxMath.bound(scrollTarget, 0, Math.max(0.0, (songList.length - 1) * 120.0 - visibleH));
    }

    function loadAll():Void
    {
        final seen = new haxe.ds.StringMap<Bool>();

        for (mod in Mods.parseList().enabled)
        {
            final dir = Paths.mods('$mod/songs');
            try
            {
                for (song in Paths.readDirectory(dir))
                {
                    final lowerSong = song.toLowerCase();
                    if (!seen.exists(lowerSong) && !song.contains('.'))
                    {
                        seen.set(lowerSong, true);
                        songList.push(song);
                        songMods.push(mod);
                    }
                }
            }
            catch (e:Dynamic) { trace('Error loading mod songs $mod: $e'); }
        }

        final globalDir = Paths.mods('songs');
        try
        {
            for (song in Paths.readDirectory(globalDir))
            {
                final lowerSong = song.toLowerCase();
                if (!seen.exists(lowerSong) && !song.contains('.'))
                {
                    seen.set(lowerSong, true);
                    songList.push(song);
                    songMods.push('');
                }
            }
        }
        catch (e:Dynamic) { trace('Error loading global songs: $e'); }

        applyOrder();
        for (i in 0...songList.length) songCredits.push(readCredits(songList[i], songMods[i]));
    }

    function applyOrder():Void
    {
        final orderPath = 'assets/exe/extras/dagarden/dagarden_order.json';
        
        try
        {
            final content = Paths.getContent(orderPath);
            final order:Array<String> = cast haxe.Json.parse(content).order;
            if (order == null || order.length == 0) { sortAlpha(); return; }
            
            final pos = new haxe.ds.StringMap<Int>();
            for (i in 0...order.length) pos.set(order[i].toLowerCase(), i);
            
            final pairs = [for (i in 0...songList.length) {
                s: songList[i],
                m: songMods[i],
                p: pos.exists(songList[i].toLowerCase()) ? pos.get(songList[i].toLowerCase()) : order.length + i
            }];
            pairs.sort((a, b) -> a.p - b.p);
            songList = [for (p in pairs) p.s];
            songMods = [for (p in pairs) p.m];
        }
        catch (e:Dynamic) { trace('Error applying song order: $e'); sortAlpha(); }
    }

    function sortAlpha():Void
    {
        final pairs = [for (i in 0...songList.length) {s: songList[i], m: songMods[i]}];
        pairs.sort((a, b) -> a.s.toLowerCase() < b.s.toLowerCase() ? -1 : 1);
        songList = [for (p in pairs) p.s];
        songMods = [for (p in pairs) p.m];
    }

    function readCredits(song:String, mod:String):Array<String>
    {
        final path = mod != '' ? Paths.mods('$mod/data/$song/credits.json') : Paths.mods('data/$song/credits.json');

        try
        {
            final content = Paths.getContent(path);
            final json:Dynamic = haxe.Json.parse(content);
            if (json == null || json.composer == null) return [];
            
            if (Std.isOfType(json.composer, Array))
            {
                final arr:Array<String> = cast json.composer;
                return arr.filter(s -> s?.length > 0);
            }
            final s = Std.string(json.composer);
            return s?.length > 0 ? [s] : [];
        }
        catch (e:Dynamic) { trace('Error parsing credits for $song: $e'); }
        return [];
    }

    function buildBoxes():Void
    {
        final bmp = Paths.getBitmapData("assets/exe/extras/dagarden/sprites/gardenbox.webp");
        for (i in 0...songList.length)
        {
            final y     = 116.0 + i * 120.0;
            final cover = loadCover(songList[i].toLowerCase(), 86.0, y);
            covers.push(cover);

            final bx = new FlxSprite(86.0, y).loadGraphic(bmp);
            bx.scale.set(0.308, 0.308);
            bx.updateHitbox();
            bx.visible = !hasCover[i];
            add(bx);
            boxes.push(bx);
            add(cover);

            final lbl = new FlxText(96.0, y + 8, 600, songList[i].toUpperCase(), 28);
            lbl.setFormat(null, 28, FlxColor.WHITE, LEFT);
            lbl.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 4);
            lbl.scale.set(0.5, 0.5);
            lbl.updateHitbox();
            lbl.antialiasing = ClientPrefs.data.antialiasing;
            lbl.visible = !hasCover[i];
            add(lbl);
            labels.push(lbl);
        }
    }

    function loadCover(song:String, bx:Float, by:Float):FlxSprite
    {
        final cv = new FlxSprite(bx, by);
        final basePath = 'assets/exe/extras/dagarden/cover/$song';
        
        final bitmap = Paths.getBitmapData(basePath);

        if (bitmap != null)
        {
            cv.loadGraphic(bitmap);
            cv.scale.set(0.308, 0.308);
            cv.updateHitbox();
            hasCover.push(true);
        }
        else
        {
            cv.makeGraphic(1, 1, 0x00000000);
            hasCover.push(false);
        }
        return cv;
    }
}

class DAGPlayer extends FlxGroup
{
    public static inline final SEEK_SECONDS:Float = 5.0;
    public var isPlaying:Bool    = false;
    public var isLoading:Bool    = false;
    public var loopEnabled:Bool  = false;
    public var vocalsEnabled:Bool = true;

    var disk:FlxSprite;
    var barProgress:FlxSprite;
    var barKnob:FlxSprite;
    var barInnerX:Float;
    var barInnerY:Float;
    var barInnerW:Float;
    var barInnerH:Float;
    var barClipRect:FlxRect;
    var timeTxt:FlxText;
    var songNameTxt:FlxText;
    var composerTxt:FlxText;
    var diskSpeed:Float    = 0.0;
    var diskDragging:Bool  = false;
    var diskDragAngle:Float = 0.0;
    var diskDragVel:Float  = 0.0;
    var barDragging:Bool   = false;
    var barLastRatio:Float = 0.0;
    var barDragVel:Float   = 0.0;
    var scrubTime:Float    = 0.0;

    var inst:FlxSound         = null;
    var vocals:Array<FlxSound> = [];
    var oppVocals:Array<FlxSound> = [];
    var instSound:Sound = null;
    var vocalSounds:Array<Sound> = [];
    
    public var loadedSong:String = '';
    public var loadedMod:String  = '';
    var fadeTarget:Float  = 1.0;
    var fadeSpeed:Float   = 0.0;
    var pitchingDown:Bool = false;
    var pitchingUp:Bool   = false;
    var pitchCurrent:Float = 1.0;
    var pitchSpeed:Float  = 0.0;
    var onPitchDone:Void->Void = null;
    var scratchPitch:Float  = 1.0;
    var scratchActive:Bool  = false;
    var seekPending:Bool    = false;
    var seekTargetMs:Float  = 0.0;
    var seekWasPlaying:Bool = false;
    var loadPending:Bool    = false;
    var loadGen:Int         = 0;

    var credits:Array<String> = [];
    var credIdx:Int   = 0;
    var credTimer:Float = 0.0;

    var _panelW:Int = 596;
    var _panelH:Int = 592;
    var _panelBorder:FlxSprite = null;
    var _debugPanel:FlxSprite  = null;
    var origTitle:String  = '';
    var lastTitleSec:Int  = -1;

    public function new()
    {
        super();
        #if !mobile origTitle = lime.app.Application.current.window.title; #end
        buildUI();
    }

    override public function destroy():Void
    {
        destroyAudio();
        onPitchDone = null;
        if (composerTxt != null) FlxTween.cancelTweensOf(composerTxt);
        super.destroy();
    }

    public function restoreWindowTitle():Void
    {
        #if !mobile lime.app.Application.current.window.title = origTitle; #end
    }

    public function setSongInfo(song:String, creds:Array<String>):Void
    {
        loadedSong = song;
        songNameTxt.text = song.replace('-', ' ').toUpperCase();
        var sz = 120;
        songNameTxt.size = sz;
        while (songNameTxt.textField.textWidth > 1080 && sz > 20) songNameTxt.size = --sz;

        credits    = creds ?? [];
        credIdx    = 0;
        credTimer  = 0.0;
        final byLabel = Language.getArray('extras.dagarden', ['BY'])[0];
        composerTxt.alpha = 1;
        composerTxt.text  = credits.length > 0 ? '$byLabel ' + credits[0].toUpperCase() : '';

        updateTitle();
    }

    public function playAudio(song:String, mod:String):Void
    {
        if (isLoading && loadedSong == song && loadedMod == mod) return;
        if (inst != null && loadedSong == song && loadedMod == mod)
        {
            inst.resume();
            for (v in vocals) v.resume();
            pitchUp();
            fadeTarget = 1.0;
            fadeSpeed  = 12.0;
            isPlaying  = true;
            #if DISCORD_ALLOWED DiscordClient.changePresence("In the DA Garden", 'Listening to ${songNameTxt.text}', null, true, FlxMath.bound(inst.time, 0, Math.max(1, inst.length))); #end
            return;
        }
        stop();
        loadAsync(song, mod);
    }

    public function pause():Void
    {
        isPlaying = false;
        pitchDown(() -> { inst?.pause(); for (v in vocals) v.pause(); });
        #if DISCORD_ALLOWED DiscordClient.changePresence("In the DA Garden", 'Listening to ${songNameTxt.text} (Paused)', null, true, FlxMath.bound(inst?.time ?? 0, 0, Math.max(1, inst?.length ?? 1))); #end
    }

    public function stop():Void
    {
        fadeSpeed    = 0;
        seekPending  = false;
        scratchPitch = 1.0;
        scratchActive = false;
        ++loadGen;
        loadPending = false;
        isLoading   = false;
        destroyAudio();
    }

    public function fadeOutAndStop():Void
    {
        if (inst == null) return;
        isPlaying = false;
        pitchDown(() -> { fadeTarget = 0.0; fadeSpeed = 12.0; });
    }

    public function setVolume(vol:Float):Void
    {
        fadeTarget = vol;
        fadeSpeed  = 8.0;
    }

    public function seek(deltaSec:Float):Void
    {
        if (inst == null || inst.length <= 0) return;
        cleanSeek(FlxMath.bound(inst.time + deltaSec * 1000, 0, inst.length - 100));
    }

    public function toggleVocals():Void { vocalsEnabled = !vocalsEnabled; applyVocalVol(inst?.volume ?? 1.0); }
    public function toggleLoop():Void   { loopEnabled = !loopEnabled; }

    public inline function hasAudio():Bool      return inst != null;
    public inline function currentTime():Float  return inst?.time ?? -1.0;
    public function updateTitle():Void
    {
        #if !mobile
        if (inst == null)
        {
            if (lastTitleSec != -1)
            {
                lastTitleSec = -1;
                lime.app.Application.current.window.title = origTitle;
            }
            return;
        }
        final sec = Std.int(inst.time / 1000);
        if (sec == lastTitleSec) return;
        lastTitleSec = sec;
        final song = loadedSong.replace('-', ' ').toUpperCase();
        final m    = Std.int(sec / 60);
        final s    = sec % 60;
        lime.app.Application.current.window.title = '[${isPlaying ? "PLAY" : "PAUSE"}] $song | ${vocalsEnabled ? "NORMAL" : "INST"} | $m:${s < 10 ? "0" : ""}$s';
        #end
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        updateComposer(elapsed);
        updateDiskSpin(elapsed);
        updateFade(elapsed);
        updatePitch(elapsed);
        updateScratch(elapsed);
        applySeek();
        checkEnd();
        updateBar();
        handleDisk(elapsed);
        handleBarMouse(elapsed);
        updateTitle();
        resyncVocals();
    }

    function buildUI():Void
    {
        final SC:Float = 0.34;
        final BX:Float = 620;
        final BY:Float = 620;

        _buildPanel();

        disk = spr(732, 245, "sprites/disk.webp", 0.34);

        final barBmp  = Paths.getBitmapData("assets/exe/extras/dagarden/sprites/bar.webp");
        final bW      = barBmp.width  * SC;
        final bH      = barBmp.height * SC;
        barInnerX = BX + (15 / 1642) * bW;
        barInnerY = BY + (15 / 96)   * bH;
        barInnerW = ((1642 - 32) / 1642) * bW;
        barInnerH = ((96 - 29)   / 96)   * bH;

        barProgress = new FlxSprite(barInnerX, barInnerY);
        barProgress.makeGraphic(Std.int(Math.ceil(barInnerW)), Std.int(Math.ceil(barInnerH)), 0xFFCC0000);
        barProgress.antialiasing = false;
        barClipRect = new FlxRect(0, 0, 0, barInnerH);
        barProgress.clipRect = barClipRect;
        add(barProgress);
        spr(BX, BY, "sprites/bar.webp", SC);

        final kr   = Std.int(barInnerH * 0.9);
        barKnob    = new FlxSprite(0, 0).makeGraphic(kr * 2, kr * 2, 0x00000000);
        final kbmp = new BitmapData(kr * 2, kr * 2, true, 0x00000000);
        final sh   = new openfl.display.Shape();
        sh.graphics.beginFill(0xFFCC0000, 1);
        sh.graphics.drawCircle(kr, kr, kr - 1);
        sh.graphics.endFill();
        kbmp.draw(sh, new openfl.geom.Matrix(), null, null, null, true);
        barKnob.pixels = kbmp;
        barKnob.alpha  = 0;
        add(barKnob);

        timeTxt = new FlxText(765, 652, Std.int(bW), '0:00', 44);
        timeTxt.setFormat(Paths.font('NiseSegaSonic.ttf'), 44, FlxColor.BLACK, CENTER);
        timeTxt.scale.set(0.5, 0.5);
        timeTxt.updateHitbox();
        timeTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(timeTxt);

        songNameTxt = new FlxText(625, 132, 1120, '???????', 120);
        songNameTxt.setFormat(Paths.font('NiseSegaSonic.ttf'), 120, FlxColor.BLACK, CENTER);
        songNameTxt.letterSpacing = 2;
        songNameTxt.wordWrap      = false;
        songNameTxt.scale.set(0.5, 0.5);
        songNameTxt.updateHitbox();
        songNameTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(songNameTxt);

        final byLabel = Language.getArray('extras.dagarden', ['BY'])[0];
        composerTxt = new FlxText(625, 196, 1120, '$byLabel ?????', 36);
        composerTxt.setFormat(Paths.font('NiseSegaSonic.ttf'), 36, FlxColor.BLACK, CENTER);
        composerTxt.letterSpacing = 6;
        composerTxt.wordWrap      = false;
        composerTxt.scale.set(0.5, 0.5);
        composerTxt.updateHitbox();
        composerTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(composerTxt);
    }

    inline function spr(x:Float, y:Float, file:String, sc:Float):FlxSprite
    {
        final s = new FlxSprite(x, y);
        s.loadGraphic(Paths.getBitmapData("assets/exe/extras/dagarden/" + file));
        s.scale.set(sc, sc);
        s.updateHitbox();
        s.antialiasing = ClientPrefs.data.antialiasing;
        add(s);
        return s;
    }

    function _buildPanel():Void
    {
        final b = 4;
        _panelBorder = new FlxSprite(602 - b, 97 - b);
        _panelBorder.scrollFactor.set(0, 0);
        add(_panelBorder);

        _debugPanel = new FlxSprite(602, 97);
        _redrawPanel();
        _debugPanel.scrollFactor.set(0, 0);
        add(_debugPanel);
    }

    function _redrawPanel():Void
    {
        final b  = 4;
        final bw = _panelW + b * 2;
        final bh = _panelH + b * 2;
        
        final bbmd = new BitmapData(bw, bh, false, 0xFF000000);
        _panelBorder.loadGraphic(bbmd);
        _panelBorder.x = _debugPanel.x - b;
        _panelBorder.y = _debugPanel.y - b;
        final bsh = new shaders.RoundedBorderShader(18.0, 0.0, 0xFF000000);
        bsh.setSize(bw, bh);
        _panelBorder.shader = bsh;
        
        final bmd    = new BitmapData(_panelW, _panelH, false, 0xFFFFFFFF);
        final gshape = new openfl.display.Shape();
        final mat    = new openfl.geom.Matrix();
        mat.createGradientBox(_panelW, _panelH, Math.PI * 0.5);
        gshape.graphics.beginGradientFill(openfl.display.GradientType.LINEAR, [0xFFFFFF, 0xB2B1B1], [1, 1], [0, 255], mat);
        gshape.graphics.drawRect(0, 0, _panelW, _panelH);
        gshape.graphics.endFill();
        bmd.draw(gshape);
        _debugPanel.loadGraphic(bmd);
        final sh = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000);
        sh.setSize(_panelW, _panelH);
        _debugPanel.shader = sh;
    }

    function updateComposer(elapsed:Float):Void
    {
        if (credits.length <= 1) return;
        credTimer += elapsed;
        if (credTimer < 10.0) return;
        credTimer = 0;
        credIdx   = (credIdx + 1) % credits.length;
        final byLabel = Language.getArray('extras.dagarden', ['BY'])[0];
        final next    = '$byLabel ' + credits[credIdx].toUpperCase();
        FlxTween.cancelTweensOf(composerTxt);
        FlxTween.tween(composerTxt, {alpha: 0.0}, 0.3, {ease: FlxEase.quadOut, onComplete: (_) -> {
            composerTxt.text = next;
            FlxTween.tween(composerTxt, {alpha: 1.0}, 0.4, {ease: FlxEase.quadIn});
        }});
    }

    function updateDiskSpin(elapsed:Float):Void
    {
        if (diskDragging) return;
        diskSpeed   += ((isPlaying ? 45.0 : 0.0) - diskSpeed) * (isPlaying ? 6.0 : 22.0) * elapsed;
        disk.angle  += elapsed * diskSpeed;
    }

    function handleDisk(elapsed:Float):Void
    {
        final mx = FlxG.mouse.x;
        final my = FlxG.mouse.y;
        final cx = disk.x + disk.width  * 0.5;
        final cy = disk.y + disk.height * 0.5;

        if (FlxG.mouse.justPressed && Math.sqrt((mx - cx) * (mx - cx) + (my - cy) * (my - cy)) <= disk.width * 0.5)
        {
            diskDragging  = true;
            diskDragAngle = Math.atan2(my - cy, mx - cx);
            diskDragVel   = 0.0;
            scrubTime     = inst?.time ?? 0.0;
        }

        final was = diskDragging;
        if (!FlxG.mouse.pressed) diskDragging = false;
        
        if (was && !diskDragging) {
            if (elapsed > 0) diskSpeed = (diskDragVel / elapsed) * (180 / Math.PI);
            cleanSeek(scrubTime);
        }
        
        if (!diskDragging) { diskDragVel = 0.0; return; }
        if (inst == null || inst.length <= 0) return;
        
        var angle = Math.atan2(my - cy, mx - cx);
        var da    = angle - diskDragAngle;
        if (da >  Math.PI) da -= Math.PI * 2;
        if (da < -Math.PI) da += Math.PI * 2;
        diskDragAngle = angle;
        diskDragVel   = da;
        
        if (da != 0) {
            disk.angle += da * (180 / Math.PI);
            scrubTime = FlxMath.bound(scrubTime + da * 120.0, 0, inst.length - 100);
        }
    }

    function handleBarMouse(elapsed:Float):Void
    {
        if (inst == null || diskDragging) return;
        final mx = FlxG.mouse.x;
        final my = FlxG.mouse.y;

        if (FlxG.mouse.justPressed && mx >= barInnerX && mx <= barInnerX + barInnerW && my >= barInnerY && my <= barInnerY + barInnerH)
        {
            barDragging  = true;
            barLastRatio = FlxMath.bound((mx - barInnerX) / barInnerW, 0, 1);
            barDragVel   = 0.0;
            scrubTime    = barLastRatio * inst.length;
        }

        final was = barDragging;
        if (!FlxG.mouse.pressed) { 
            barDragging = false; 
            barDragVel = 0.0; 
            if (was) cleanSeek(scrubTime);
            return; 
        }
        
        if (!barDragging) return;
        
        final ratio = FlxMath.bound((mx - barInnerX) / barInnerW, 0, 1);
        barDragVel   = ratio - barLastRatio;
        barLastRatio = ratio;
        
        scrubTime = ratio * inst.length;
    }

    function updateScratch(elapsed:Float):Void
    {
        if (inst == null) return;
        final dragging = diskDragging || barDragging;
        if (dragging)
        {
            scratchActive = true;
            final v = diskDragging
                ? FlxMath.bound(Math.abs(diskDragVel) / (elapsed > 0 ? elapsed : 0.001) / 0.25, 0, 1)
                : FlxMath.bound(Math.abs(barDragVel)  / (elapsed > 0 ? elapsed : 0.001) / 0.5,  0, 1);
            scratchPitch += (FlxMath.lerp(1.0, 0.30, v) - scratchPitch) * 18.0 * elapsed;
        }
        else if (scratchActive)
        {
            scratchPitch += (1.0 - scratchPitch) * 6.0 * elapsed;
            if (Math.abs(scratchPitch - 1.0) < 0.01) { scratchPitch = 1.0; scratchActive = false; }
        }
        if (scratchActive || scratchPitch != 1.0) applyPitch(pitchCurrent * scratchPitch);
    }

    function updateBar():Void
    {
        final total = inst?.length ?? 0.0;
        final cur   = (diskDragging || barDragging) ? scrubTime : (inst?.time ?? 0.0);
        final pct   = total > 0 ? FlxMath.bound(cur / total, 0, 1) : 0.0;
        
        barClipRect.width = barInnerW * pct;
        barProgress.clipRect = barClipRect;
        barKnob.setPosition(barInnerX + barInnerW * pct - barKnob.width * 0.5, barInnerY + barInnerH * 0.5 - barKnob.height * 0.5);
        barKnob.alpha += ((barDragging ? 1.0 : 0.0) - barKnob.alpha) * 0.25;
        
        final rem:Int = Std.int(Math.max(0, (total - cur) / 1000));
        timeTxt.text = '${Std.int(rem / 60)}:${rem % 60 < 10 ? "0" : ""}${rem % 60}';
    }

    function updateFade(elapsed:Float):Void
    {
        if (fadeSpeed == 0) return;

        final cur  = inst?.volume ?? 0.0;
        final next = cur + (fadeTarget - cur) * fadeSpeed * elapsed;
        if (inst != null) inst.volume = next;

        applyVocalVol(next);

        if (Math.abs(next - fadeTarget) < 0.01)
        {
            if (inst != null) inst.volume = fadeTarget;
            applyVocalVol(fadeTarget);
            if (fadeTarget <= 0) destroyAudio();
            fadeSpeed = 0;
        }
    }

    function updatePitch(elapsed:Float):Void
    {
        if (pitchingDown && pitchSpeed != 0)
        {
            pitchCurrent += -pitchCurrent * pitchSpeed * elapsed;
            applyPitch(pitchCurrent * scratchPitch);
            if (pitchCurrent < 0.05)
            {
                pitchingDown = false;
                pitchSpeed   = 0;
                if (onPitchDone != null) { onPitchDone(); onPitchDone = null; }
            }
        }
        else if (pitchingUp && pitchSpeed != 0)
        {
            pitchCurrent += (1.0 - pitchCurrent) * pitchSpeed * elapsed;
            applyPitch(pitchCurrent * scratchPitch);
            if (pitchCurrent > 0.97) { pitchCurrent = 1.0; pitchingUp = false; pitchSpeed = 0; applyPitch(scratchPitch); }
        }
    }

    function cleanSeek(ms:Float):Void
    {
        if (inst == null) return;
        seekWasPlaying = inst.playing;
        seekTargetMs   = ms;
        seekPending    = true;
        if (seekWasPlaying) inst.pause();
        for (v in vocals) if (v.playing) v.pause();
    }

    function applySeek():Void
    {
        if (!seekPending || inst == null) return;
        seekPending = false;
        try {
            FlxTween.cancelTweensOf(inst);
            FlxTween.tween(inst, {volume: 0}, 0.2, {
                ease: FlxEase.quadIn,
                onComplete: twn->{
                    inst.time = seekTargetMs;
                    FlxTween.tween(inst, {volume: 1}, 0.2, {ease: FlxEase.quadIn});
                }
            }); 
        } catch (_:Dynamic) {}
        for (v in vocals) try {
            FlxTween.cancelTweensOf(v);

            if (!vocalsEnabled){ v.time = inst.time; v.volume = 0; }
            else{
                FlxTween.tween(v, {volume: 0}, 0.2, {
                    ease: FlxEase.quadIn,
                    onComplete: twn->{
                        v.time = inst.time;
                        FlxTween.tween(v, {volume: 1}, 0.2, {ease: FlxEase.quadIn});
                    }
                }); 
            }
        } catch (_:Dynamic) {}
        if (seekWasPlaying) { inst.resume(); for (v in vocals) v.resume(); }
    }

    inline function applyPitch(p:Float):Void { if (inst != null) inst.pitch = p; for (v in vocals) v.pitch = p; }
    inline function applyVocalVol(base:Float):Void { for (v in vocals) v.volume = vocalsEnabled ? base : 0.0; }

    function pitchDown(cb:Void->Void):Void
    {
        pitchingUp   = false;
        pitchCurrent = 1.0;
        applyPitch(1.0);
        pitchingDown = true;
        pitchSpeed   = 4.5;
        onPitchDone  = cb;
    }

    function pitchUp():Void
    {
        pitchingDown = false;
        onPitchDone  = null;
        pitchCurrent = 0.2;
        applyPitch(0.2);
        pitchingUp  = true;
        pitchSpeed  = 8.0;
    }

    function loadAsync(song:String, mod:String):Void
    {
        loadedSong = song;
        loadedMod  = mod;
        final prevMod = Mods.currentModDirectory;
        Mods.currentModDirectory = mod;

        isLoading   = true;
        loadPending = true;
        final gen  = ++loadGen;
        final lMod = mod;
        final lSong = song;

        final i = Paths.inst(song);
        final vs:Array<{snd:Sound, isOpp:Bool}> = [];
        for (pf in [null, 'Opponent', 'Player'])
        {
            final s = Paths.voices(song, pf);
            if (s != null) vs.push({snd: s, isOpp: pf == 'Opponent'});
        }
        Mods.currentModDirectory = prevMod;
        _finishLoad({inst: i, vocs: vs, gen: gen, lyricsMod: lMod, lyricsSong: lSong});
    }

    function _finishLoad(data:{inst:Sound, vocs:Array<{snd:Sound, isOpp:Bool}>, gen:Int, lyricsMod:String, lyricsSong:String}):Void
    {
        if (data == null) return;
        if (data.gen != loadGen)
        {
            data.inst?.close();
            for (v in data.vocs) v?.snd?.close();
            return;
        }
        loadPending = false;
        isLoading   = false;
        if (data.inst == null) return;

        inst = FlxG.sound.load(data.inst);
        inst.looped = false;
        inst.volume = 0.0;
        instSound = data.inst;
        for (v in data.vocs)
        {
            if (v == null || v.snd == null) continue;
            final snd = FlxG.sound.load(v.snd);
            if (snd == null) continue;
            snd.looped = false;
            vocals.push(snd);
            vocalSounds.push(v.snd);
            if (v.isOpp) oppVocals.push(snd);
        }

        inst.play();
        for (v in vocals) v.play();
        pitchUp();
        fadeTarget = 1.0;
        fadeSpeed  = 12.0;
        isPlaying  = true;
        #if DISCORD_ALLOWED DiscordClient.changePresence("In the D.A Garden", 'Listening to ${songNameTxt.text}', null, true, FlxMath.bound(inst.time, 0, Math.max(1, inst.length))); #end
    }

    function checkEnd():Void
    {
        if (!isPlaying || seekPending || diskDragging || barDragging || inst == null || inst.length <= 0) return;

        if (!inst.playing || inst.time >= inst.length - 50)
        {
            if (loopEnabled)
            {
                cleanSeek(0);
                inst.play();
                for (v in vocals) v?.play();
            }
            else
            {
                isPlaying = false;
                inst.pause();
                inst.time = 0;
                for (v in vocals) if (v != null) { v.pause(); v.time = 0; }
            }
        }
    }

	static inline final threshold:Float = 300.0;

    function resyncVocals():Void
    {
        if(inst == null || !isPlaying) return;

        for(voc in vocals) {
            if(voc == null) continue;

            final drift = Math.abs(voc.time - inst.time);
            if(drift > threshold) {
                voc.time = inst.time;
                if(!voc.playing) voc.resume();
            } else if(!voc.playing) {
                voc.resume();
            }
        }
    }

    function destroyAudio():Void
    {
        if (inst != null)
        {
            inst.stop();
            FlxG.sound.list.remove(inst, true);
            inst.destroy();
            inst = null;
        }

        for (v in vocals) if (v != null)
        {
            v.stop();
            FlxG.sound.list.remove(v, true);
            v.destroy();
        }

        instSound?.close();
        instSound = null;

        for (s in vocalSounds) s?.close();

        vocalSounds = [];
        vocals     = [];
        oppVocals  = [];
        isPlaying  = false;
        loadedSong = '';
        loadedMod  = '';
        #if DISCORD_ALLOWED DiscordClient.changePresence("In the DA Garden", null); #end
    }
}

class DAGarden extends SonicSubState
{
    public static var currentSong:String    = '';
    public static var currentSongMod:String = '';

    var checkers:FlxBackdrop;
    var decors:Array<FlxSprite> = [];
    var arrow:FlxSprite;
    var spikes:FlxBackdrop;
    var dagarden:FlxSprite;
    var rotTime:Float = 0.0;
    var songs:DAGSongs;
    var player:DAGPlayer;
    var ambientMusic:FlxSound;

    var drawerOpen:Bool = false;
    var drawerGroup:flixel.group.FlxSpriteGroup;
    var drawerBtnTxt:Array<FlxText> = [];
    var drawerBtnAction:Array<Void->Void> = [];
    var drawerBtnKey:Array<String> = [];
    var drawerKeycapBg:Array<FlxSprite> = [];
    var drawerKeycapTxt:Array<FlxText> = [];
    var _keycapInkOffsetX:Array<Float> = [];
    var _keycapInkOffsetY:Array<Float> = [];
    var drawerRowsAlpha:Float = 0.0;
    var drawerBorder:FlxSprite;
    var drawerBg:FlxSprite;
    var drawerTabBorder:FlxSprite;
    var drawerTabBg:FlxSprite;
    var drawerTabTxt:FlxText;
    var drawerW:Float = 118.0;
    var drawerH:Float = 184.0;
    
    var sharedCapShader:shaders.RoundedBorderShader;

    override public function create():Void
    {
        FlxG.autoPause = false;
        FlxG.mouse.visible = true;

        buildBG();
        songs = new DAGSongs();
        songs.onSelect          = onSongSelected;
        songs.onChangeSelection = () -> controls.UI_DOWN_P ? 1 : controls.UI_UP_P ? -1 : 0;
        add(songs);
        buildFG();

        if(!backend.EXEAchievements.isUnlocked('dagarden') && songs.songList.length > 0) {
            var _save = new flixel.util.FlxSave();
            _save.bind('savedSongs', backend.CoolUtil.getSavePath());
            var _saved:Array<String> = cast(_save.data.songs ?? []);
            var _allFound = true;
            for(s in songs.songList) if(!_saved.contains(s)) { _allFound = false; break; }
            if(_allFound) { backend.EXEAchievements.unlock('dagarden'); backend.EXEAchievements.save(); }
        }

        player = new DAGPlayer();
        add(player);

        FlxG.sound.music?.pause();
        if (songs.songList.length > 0)
            songs.selectSong(0);

        ambientMusic = FlxG.sound.load(OpenFlAssets.getSound('assets/exe/extras/music/ChaoGarden.ogg'), 1.0, true);

        buildDrawer();

        final panelRingW = 596.0 + 4 * 2;
        final panelRingH = 592.0 + 4 * 2;
        final panelRing = new FlxSprite(602.0 - 4, 97.0 - 4);
        panelRing.makeGraphic(Std.int(panelRingW), Std.int(panelRingH), FlxColor.TRANSPARENT, true);
        final ringShader = new shaders.RoundedBorderShader(18.0, 4.0, 0xFF000000, 15);
        ringShader.setSize(panelRingW, panelRingH);
        panelRing.shader = ringShader;
        add(panelRing);

        #if DISCORD_ALLOWED DiscordClient.changePresence("In the DA Garden", null); #end
        super.create();

        #if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
    }

    function buildDrawer():Void
    {
        drawerGroup = new flixel.group.FlxSpriteGroup(485.0, 402.0);
        add(drawerGroup);

        sharedCapShader = new shaders.RoundedBorderShader(5.0, 0.0, 0xFF000000);

        final b = 4;
        drawerBorder = new FlxSprite(-b, -b);
        drawerGroup.add(drawerBorder);

        drawerBg = new FlxSprite(0, 0);
        drawerGroup.add(drawerBg);

        drawerTabBorder = new FlxSprite(0, 0);
        drawerGroup.add(drawerTabBorder);

        drawerTabBg = new FlxSprite(0, 0);
        drawerGroup.add(drawerTabBg);

        drawerTabTxt = new FlxText(0, 0, 0, 'MENU', 32);
        drawerTabTxt.setFormat(Paths.font('NiseSegaSonic.ttf'), 32, FlxColor.BLACK, CENTER);
        drawerTabTxt.scale.set(0.6, 0.6);
        drawerTabTxt.updateHitbox();
        drawerTabTxt.antialiasing = ClientPrefs.data.antialiasing;
        drawerGroup.add(drawerTabTxt);

        _redrawDrawerBg();

        final rows = [
            {key: 'dagarden_play',    action: () -> { if (player.isPlaying) player.pause(); else player.playAudio(songs.selectedSong(), songs.selectedMod()); }},
            {key: 'dagarden_loop',    action: () -> player.toggleLoop()},
            {key: 'dagarden_vocals',  action: () -> player.toggleVocals()},
            {key: 'dagarden_rewind',  action: () -> player.seek(-DAGPlayer.SEEK_SECONDS)},
            {key: 'dagarden_forward', action: () -> player.seek(DAGPlayer.SEEK_SECONDS)},
            {key: 'dagarden_stop',    action: () -> player.fadeOutAndStop()}
        ];

        for (i in 0...rows.length)
        {
            drawerBtnKey.push(rows[i].key);
            drawerBtnAction.push(rows[i].action);

            final rowY = 5 + i * 29.0;

            final cap = new FlxSprite(8.0, rowY);
            cap.makeGraphic(Std.int(22.0), Std.int(22.0), FlxColor.BLACK);
            
            final instShader = new shaders.RoundedBorderShader(5.0, 0.0, 0xFF000000);
            instShader.setSize(22.0, 22.0);
            cap.shader = instShader;
            
            drawerGroup.add(cap);
            drawerKeycapBg.push(cap);

            final capTxt = new FlxText(0, 0, 0, '', 20);
            capTxt.setFormat(Paths.font('NiseSegaSonic.ttf'), 20, FlxColor.WHITE, CENTER);
            capTxt.scale.set(0.5, 0.5);
            capTxt.updateHitbox();
            capTxt.antialiasing = ClientPrefs.data.antialiasing;
            drawerGroup.add(capTxt);
            drawerKeycapTxt.push(capTxt);
            _keycapInkOffsetX.push(0.0);
            _keycapInkOffsetY.push(0.0);

            final lbl = new FlxText(8.0 + 22.0 + 8.0, rowY, 0, '', 20);
            lbl.setFormat(Paths.font('NiseSegaSonic.ttf'), 20, FlxColor.BLACK, LEFT);
            lbl.wordWrap = false;
            lbl.scale.set(0.5, 0.5);
            lbl.updateHitbox();
            lbl.antialiasing = ClientPrefs.data.antialiasing;
            drawerGroup.add(lbl);
            drawerBtnTxt.push(lbl);
        }
    }

    function _redrawDrawerBg():Void
    {
        final b  = 4;
        final bw = drawerW + b; 
        final bh = drawerH + b * 2;

        drawerBorder.makeGraphic(Std.int(bw), Std.int(bh), FlxColor.BLACK);
        final borderShader = new shaders.RoundedBorderShader(10.0, 0.0, 0xFF000000, 9);
        borderShader.setSize(bw, bh);
        drawerBorder.shader = borderShader;

        final gshape = new openfl.display.Shape();
        final mat = new openfl.geom.Matrix();
        mat.createGradientBox(drawerW, drawerH, Math.PI * 0.5);
        gshape.graphics.beginGradientFill(openfl.display.GradientType.LINEAR, [0xFFFFFF, 0xB2B1B1], [1, 1], [0, 255], mat);
        gshape.graphics.drawRect(0, 0, drawerW, drawerH);
        gshape.graphics.endFill();
        final bmd = new BitmapData(Std.int(drawerW), Std.int(drawerH), false, 0xFFFFFFFF);
        bmd.draw(gshape);
        drawerBg.loadGraphic(bmd);
        final bgShader = new shaders.RoundedBorderShader(8.0, 0.0, 0xFF000000, 9);
        bgShader.setSize(drawerW, drawerH);
        drawerBg.shader = bgShader;
        
        _redrawDrawerTab();
    }

    function _redrawDrawerTab():Void
    {
        final b    = 4;
        final tabW = 44.0 + 2.0;
        final tw   = tabW + b; 
        final th   = drawerH + b * 2;
        final tabLocalX = drawerW - 2.0;

        drawerTabBorder.makeGraphic(Std.int(tw), Std.int(th), FlxColor.BLACK);
        drawerTabBorder.x = drawerGroup.x + tabLocalX;
        drawerTabBorder.y = drawerGroup.y - b;

        final tabBorderShader = new shaders.RoundedBorderShader(10.0, 0.0, 0xFF000000, 6);
        tabBorderShader.setSize(tw, th);
        drawerTabBorder.shader = tabBorderShader;

        final gshape = new openfl.display.Shape();
        final mat = new openfl.geom.Matrix();
        mat.createGradientBox(tabW, drawerH, Math.PI * 0.5);
        gshape.graphics.beginGradientFill(openfl.display.GradientType.LINEAR, [0xFFFFFF, 0xB2B1B1], [1, 1], [0, 255], mat);
        gshape.graphics.drawRect(0, 0, tabW, drawerH);
        gshape.graphics.endFill();

        final bmd = new BitmapData(Std.int(tabW), Std.int(drawerH), false, 0xFFFFFFFF);
        bmd.draw(gshape);

        drawerTabBg.loadGraphic(bmd);
        drawerTabBg.x = drawerGroup.x + tabLocalX;
        drawerTabBg.y = drawerGroup.y;

        final tabBgShader = new shaders.RoundedBorderShader(8.0, 0.0, 0xFF000000, 6);
        tabBgShader.setSize(tabW, drawerH);
        drawerTabBg.shader = tabBgShader;

        drawerTabTxt.angle = 90;

        final tabCenterX = drawerGroup.x + tabLocalX + 2.0 + 44.0 / 2;
        final tabCenterY = drawerGroup.y + drawerH / 2;
        drawerTabTxt.x = tabCenterX - drawerTabTxt.width  / 2;
        drawerTabTxt.y = tabCenterY - drawerTabTxt.height / 2;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (subState != null) return;

        rotTime += elapsed;

        decors[0].angle = Math.sin(rotTime * 0.5) * 3;
        decors[2].angle = Math.cos(rotTime * 0.7) * 4;
        decors[5].angle = Math.sin(rotTime * 0.6) * 2;
        decors[6].angle = Math.cos(rotTime * 0.8) * 3.5;

        currentSong    = player.isPlaying ? player.loadedSong : '';
        currentSongMod = player.isPlaying ? player.loadedMod  : '';

        if (ambientMusic != null)
        {
            if (player.isPlaying) { if (ambientMusic.playing) ambientMusic.pause(); }
            else                  { if (!ambientMusic.playing) ambientMusic.play();  }
        }

        updateDrawer();
        handleInput();
    }

    function updateDrawer():Void
    {
        _applyDrawerClip();

        if (FlxG.keys.justPressed.TAB) toggleDrawer();

        final mp = FlxG.mouse.getWorldPosition();
        if (FlxG.mouse.justPressed && drawerTabBg.overlapsPoint(mp)) toggleDrawer();

        if (drawerOpen)
        {
            final labels = [
                player.isPlaying ? Language.getArray('extras.dagarden', ['PAUSE'])[2] : Language.getArray('extras.dagarden', ['PLAY'])[1],
                Language.getArray('extras.dagarden', ['LOOP: '])[3]   + (player.loopEnabled   ? Language.get('options.on', "ON") : Language.get('options.off', "OFF")),
                Language.getArray('extras.dagarden', ['VOCALS: '])[4] + (player.vocalsEnabled ? Language.get('options.on', "ON") : Language.get('options.off', "OFF")),
                Language.getArray('extras.dagarden', ['REWIND'])[5],
                Language.getArray('extras.dagarden', ['FORWARD'])[6],
                Language.getArray('extras.dagarden', ['STOP'])[7]
            ];
            for (i in 0...drawerBtnTxt.length)
            {
                if (drawerBtnTxt[i].text != labels[i])
                {
                    drawerBtnTxt[i].text = labels[i];
                    drawerBtnTxt[i].updateHitbox();
                }

                final keys = ClientPrefs.keyBinds.get(drawerBtnKey[i]);
                final keyName = keys?.length > 0 ? InputFormatter.getKeyName(keys[0]) : '?';
                final cap = drawerKeycapBg[i];
                if (drawerKeycapTxt[i].text != keyName)
                {
                    drawerKeycapTxt[i].text = keyName;
                    drawerKeycapTxt[i].scale.set(0.5, 0.5);
                    drawerKeycapTxt[i].updateHitbox();
                    drawerKeycapTxt[i].offset.set(0, 0);
                    drawerKeycapTxt[i].origin.set(0, 0);

                    final capW = Math.max(22.0, drawerKeycapTxt[i].width + 8);
                    cap.makeGraphic(Std.int(capW), Std.int(22.0), FlxColor.BLACK);
                    
                    if (cap.shader != null && Std.isOfType(cap.shader, shaders.RoundedBorderShader)) {
                         cast(cap.shader, shaders.RoundedBorderShader).setSize(capW, 22.0);
                    }

                    drawerBtnTxt[i].x = cap.x + capW + 8.0;

                    final ink = drawerKeycapTxt[i].pixels.getColorBoundsRect(0xFF000000, 0x00000000, false);
                    final sx = drawerKeycapTxt[i].scale.x;
                    final sy = drawerKeycapTxt[i].scale.y;
                    _keycapInkOffsetX[i] = (ink.width  <= 0) ? 0.0 : (ink.x + ink.width  / 2) * sx;
                    _keycapInkOffsetY[i] = (ink.width  <= 0) ? 0.0 : (ink.y + ink.height / 2) * sy;
                }
                drawerKeycapTxt[i].x = cap.x + cap.frameWidth / 2 - _keycapInkOffsetX[i];
                drawerKeycapTxt[i].y = cap.y + 22.0 / 2     - _keycapInkOffsetY[i];

                final clickable = (drawerBtnTxt[i].overlapsPoint(mp) || cap.overlapsPoint(mp)) && cap.x >= 602.0;
                if (FlxG.mouse.justPressed && clickable) drawerBtnAction[i]();
            }
        }
        mp.put();
    }

    function _applyDrawerClip():Void
    {
        _clipToBoundary(drawerBorder);
        _clipToBoundary(drawerBg);

        final fadeRange = 24.0;
        drawerRowsAlpha = FlxMath.bound((drawerBg.x - 602.0 + fadeRange) / fadeRange, 0, 1);

        for (t in drawerBtnTxt)    t.alpha = drawerRowsAlpha;
        for (k in drawerKeycapBg)  k.alpha = drawerRowsAlpha;
        for (k in drawerKeycapTxt) k.alpha = drawerRowsAlpha;
    }

    function _clipToBoundary(spr:FlxSprite):Void
    {
        final localX = 602.0 - spr.x;
        if (localX <= 0)
            spr.clipRect = null; // show all of it
        else if (localX >= spr.frameWidth)
            spr.clipRect = new FlxRect(0, 0, 0, spr.frameHeight); // then hide all of it
        else
            spr.clipRect = new FlxRect(localX, 0, spr.frameWidth - localX, spr.frameHeight);
    }

    function toggleDrawer():Void
    {
        drawerOpen = !drawerOpen;
        FlxTween.cancelTweensOf(drawerGroup);
        final targetX = drawerOpen ? 604.0 : 485.0;
        FlxTween.tween(drawerGroup, {x: targetX}, 0.3, {ease: drawerOpen ? FlxEase.expoOut : FlxEase.expoIn});
    }

    override public function destroy():Void
    {
        FlxG.autoPause = true;
        if (ambientMusic != null)
        {
            ambientMusic.stop();
            FlxG.sound.list.remove(ambientMusic, true);
            ambientMusic.destroy();
            ambientMusic = null;
        }
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
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            bmd.fillRect(new Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | b);
        }
        add(new FlxSprite(0, 0).loadGraphic(bmd));

        final ts   = 40;
        final cbmd = new BitmapData(ts * 2, ts * 2, true, 0x00000000);
        cbmd.fillRect(new Rectangle(0,  0,  ts, ts), 0xFF3d0008);
        cbmd.fillRect(new Rectangle(ts, 0,  ts, ts), 0xFF831826);
        cbmd.fillRect(new Rectangle(0,  ts, ts, ts), 0xFF831826);
        cbmd.fillRect(new Rectangle(ts, ts, ts, ts), 0xFF3d0008);
        checkers = new FlxBackdrop(cbmd, XY, 0, 0);
        checkers.alpha      = 0.10;
        checkers.velocity.x = -60;
        add(checkers);

        for (d in [
            {x: 560, y: 560, f: "objects/1.webp", s: 0.25},
            {x: 950, y: 580, f: "objects/2.webp", s: 0.15},
            {x:1100, y:  50, f: "objects/3.webp", s: 0.25},
            {x: 540, y: 300, f: "objects/4.webp", s: 0.25},
            {x: 700, y: 800, f: "objects/6.webp", s: 0.25},
  
            {x: 550, y:  50, f: "objects/7.webp", s: 0.25},
            {x: 800, y:  50, f: "objects/8.webp", s: 0.25}
        ])
        {
            decors.push(spr(d.x, d.y, d.f, d.s));
        }

        arrow  = spr(490, 90, "objects/arrow.webp", 0.34);
        spikes = new FlxBackdrop(Paths.getBitmapData("assets/exe/extras/dagarden/sprites/spikes.webp"), Y, 0, 0);
        spikes.setPosition(70, 87);
        spikes.scale.set(0.34, 0.34);
        spikes.updateHitbox();
        spikes.velocity.y = 50;
        add(spikes);

        final ox = [20.0, -10.0,  25.0, -18.0,  12.0, -16.0, 28.0];
        final oy = [ 8.0,  18.0, -15.0,  22.0, -20.0,  14.0, 10.0];
        final dx = [ 3.2,   1.8,   2.9,   2.4,   3.6,   1.9,  3.3];
        final dy = [ 2.1,   3.5,   1.7,   3.1,   2.2,   2.8,  2.5];
        for (i in 0...decors.length)
        {
            final s = decors[i];
            FlxTween.tween(s, {x: s.x + ox[i]}, dx[i], {ease: FlxEase.sineInOut, type: PINGPONG});
            FlxTween.tween(s, {y: s.y + oy[i]}, dy[i], {ease: FlxEase.sineInOut, type: PINGPONG});
            FlxTween.tween(s, {alpha: 0.85}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG, startDelay: Math.random() * 2});
        }
        FlxTween.tween(arrow, {y: arrow.y - 10}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
    }

    function buildFG():Void
    {
        spr(0, 0, "sprites/marcogris.webp", 0.34);
        dagarden = spr(70, 35, "sprites/dagarden.webp", 0.34);
        FlxTween.tween(dagarden, {y: dagarden.y + 5}, 3.0, {ease: FlxEase.sineInOut, type: PINGPONG});
    }

    inline function spr(x:Float, y:Float, file:String, sc:Float):FlxSprite
    {
        final s = new FlxSprite(x, y);
        s.loadGraphic(Paths.getBitmapData("assets/exe/extras/dagarden/" + file));
        s.scale.set(sc, sc);
        s.updateHitbox();
        add(s);
        return s;
    }

    function onSongSelected(index:Int):Void
    {
        player.setSongInfo(songs.selectedSong(), songs.selectedCredits());
        player.stop();
        player.updateTitle();
    }

    inline function dagKey(saveKey:String):Bool
    {
        final keys = ClientPrefs.keyBinds.get(saveKey);
        return keys?.length > 0 && FlxG.keys.anyJustPressed(keys);
    }

    function handleInput():Void
    {
        if (dagKey('dagarden_play'))    { if (player.isPlaying) player.pause();
        else player.playAudio(songs.selectedSong(), songs.selectedMod()); }

        if (dagKey('dagarden_loop'))    player.toggleLoop();
        if (dagKey('dagarden_vocals'))  player.toggleVocals();
        if (dagKey('dagarden_stop'))    player.fadeOutAndStop();
        if (dagKey('dagarden_rewind'))  player.seek(-DAGPlayer.SEEK_SECONDS);
        if (dagKey('dagarden_forward')) player.seek(DAGPlayer.SEEK_SECONDS);
        if (controls.BACK #if mobile || backPressed #end)
        {
            player.restoreWindowTitle();
            player.stop();
            FlxG.sound.music?.resume();
            currentSong    = '';
            currentSongMod = '';
            close();
        }
    }
}