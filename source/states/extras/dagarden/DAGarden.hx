package states.extras.dagarden;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import sys.FileSystem;
import sys.io.File;

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
        if (targetY - scrollTarget < 0)
            scrollTarget = targetY;
        else if (targetY - scrollTarget > visibleH - 120.0)
            scrollTarget = targetY - visibleH + 120.0;
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
                    if (!seen.exists(song) && !song.contains('.'))
                    {
                        seen.set(song, true);
                        songList.push(song);
                        songMods.push(mod);
                    }
            }
            catch (_:Dynamic) {}
        }

        final globalDir = Paths.mods('songs');
        try
        {
            for (song in Paths.readDirectory(globalDir))
                if (!seen.exists(song) && !song.contains('.'))
                {
                    seen.set(song, true);
                    songList.push(song);
                    songMods.push('');
                }
        }
        catch (_:Dynamic) {}

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
        catch (_:Dynamic) { sortAlpha(); }
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
                return arr.filter(s -> s != null && s.length > 0);
            }
            final s = Std.string(json.composer);
            return s != null && s.length > 0 ? [s] : [];
        }
        catch (_:Dynamic) {}
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
    var barClipRect:flixel.math.FlxRect;
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

    var inst:FlxSound         = null;
    var vocals:Array<FlxSound> = [];
    var oppVocals:Array<FlxSound> = [];
    // Kept so destroyAudio() can explicitly .close() the streamed Sounds - FlxSound.destroy()
    // only drops its reference, which would leave the vorbis file open until GC.
    var instSound:openfl.media.Sound = null;
    var vocalSounds:Array<openfl.media.Sound> = [];
    
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

    public function detach():{inst:FlxSound, vocals:Array<FlxSound>, instSound:openfl.media.Sound, vocalSounds:Array<openfl.media.Sound>, song:String, mod:String, wasPlaying:Bool}
    {
        final result = {inst: inst, vocals: vocals, instSound: instSound, vocalSounds: vocalSounds, song: loadedSong, mod: loadedMod, wasPlaying: isPlaying};
        inst        = null;
        vocals      = [];
        oppVocals   = [];
        instSound   = null;
        vocalSounds = [];
        isPlaying  = false;
        loadedSong = '';
        loadedMod  = '';
        return result;
    }

    public function reclaim(snd:FlxSound, vocs:Array<FlxSound>, sndSound:openfl.media.Sound, vocSounds:Array<openfl.media.Sound>, mod:String, wasPlaying:Bool):Void
    {
        inst        = snd;
        vocals      = vocs != null ? vocs : [];
        instSound   = sndSound;
        vocalSounds = vocSounds != null ? vocSounds : [];
        loadedMod  = mod;
        isPlaying  = wasPlaying;
        fadeTarget = 1.0;
        fadeSpeed  = 0;
        if (inst != null) inst.volume = 1.0;
        applyVocalVol(1.0);
        pitchCurrent = 1.0;
        applyPitch(1.0);
    }

    public function setSongInfo(song:String, creds:Array<String>):Void
    {
        loadedSong = song;
        songNameTxt.text = song.replace('-', ' ').toUpperCase();
        var sz = 120;
        songNameTxt.size = sz;
        while (songNameTxt.textField.textWidth > 1080 && sz > 20) songNameTxt.size = --sz;

        credits    = creds != null ? creds : [];
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
    public function toggleLoop():Void   { loopEnabled = !loopEnabled; if (inst != null) inst.looped = loopEnabled; }

    public inline function hasAudio():Bool      return inst != null;
    public inline function currentTime():Float  return inst != null ? inst.time : -1.0;
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
        barClipRect = new flixel.math.FlxRect(0, 0, 0, barInnerH);
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

        timeTxt = new FlxText(765, 662, Std.int(bW), '0:00', 44);
        timeTxt.setFormat(Paths.font('NiseSegaSonic.TTF'), 44, FlxColor.BLACK, CENTER);
        timeTxt.scale.set(0.5, 0.5);
        timeTxt.updateHitbox();
        timeTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(timeTxt);

        songNameTxt = new FlxText(625, 132, 1120, '???????', 120);
        songNameTxt.setFormat(Paths.font('NiseSegaSonic.TTF'), 120, FlxColor.BLACK, CENTER);
        songNameTxt.letterSpacing = 2;
        songNameTxt.wordWrap      = false;
        songNameTxt.scale.set(0.5, 0.5);
        songNameTxt.updateHitbox();
        songNameTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(songNameTxt);

        final byLabel = Language.getArray('extras.dagarden', ['BY'])[0];
        composerTxt = new FlxText(625, 196, 1120, '$byLabel ?????', 36);
        composerTxt.setFormat(Paths.font('NiseSegaSonic.TTF'), 36, FlxColor.BLACK, CENTER);
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
        }

        final was = diskDragging;
        if (!FlxG.mouse.pressed) diskDragging = false;
        if (was && !diskDragging && elapsed > 0) diskSpeed = (diskDragVel / elapsed) * (180 / Math.PI);
        if (!diskDragging) { diskDragVel = 0.0; return; }
        if (inst == null || inst.length <= 0) return;
        var angle = Math.atan2(my - cy, mx - cx);
        var da    = angle - diskDragAngle;
        if (da >  Math.PI) da -= Math.PI * 2;
        if (da < -Math.PI) da += Math.PI * 2;
        diskDragAngle = angle;
        diskDragVel   = da;
        if (da == 0) return;
        disk.angle += da * (180 / Math.PI);
        cleanSeek(FlxMath.bound(inst.time + da * 120.0, 0, inst.length - 100));
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
            cleanSeek(barLastRatio * inst.length);
        }

        if (!FlxG.mouse.pressed) { barDragging = false; barDragVel = 0.0; return; }
        if (!barDragging) return;
        final ratio = FlxMath.bound((mx - barInnerX) / barInnerW, 0, 1);
        barDragVel   = ratio - barLastRatio;
        barLastRatio = ratio;
        if (Math.abs(barDragVel) < 0.0005) return;
        cleanSeek(ratio * inst.length);
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
        final cur   = inst?.time   ?? 0.0;
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
        try { inst.time = seekTargetMs; } catch (_:Dynamic) {}
        for (v in vocals) try { v.time = seekTargetMs; } catch (_:Dynamic) {}
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
        final vs:Array<{snd:openfl.media.Sound, isOpp:Bool}> = [];
        for (pf in [null, 'opponent', 'player'])
        {
            final s = Paths.voices(song, pf);
            if (s != null) vs.push({snd: s, isOpp: pf == 'opponent'});
        }
        Mods.currentModDirectory = prevMod;
        _finishLoad({inst: i, vocs: vs, gen: gen, lyricsMod: lMod, lyricsSong: lSong});
    }

    function _finishLoad(data:{inst:openfl.media.Sound, vocs:Array<{snd:openfl.media.Sound, isOpp:Bool}>, gen:Int, lyricsMod:String, lyricsSong:String}):Void
    {
        if (data == null) return;
        if (data.gen != loadGen)
        {
            data.inst?.close();
            for (v in data.vocs) if (v != null && v.snd != null) v.snd.close();
            return;
        }
        loadPending = false;
        isLoading   = false;
        if (data.inst == null) return;

        inst = FlxG.sound.load(data.inst);
        inst.looped = loopEnabled;
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
        #if DISCORD_ALLOWED DiscordClient.changePresence("In the DA Garden", 'Listening to ${songNameTxt.text}', null, true, FlxMath.bound(inst.time, 0, Math.max(1, inst.length))); #end
    }

    function checkEnd():Void
    {
        if (!isPlaying || inst == null || inst.length <= 0 || inst.time < inst.length - 100 || !inst.playing) return;
        if (loopEnabled)
        {
            cleanSeek(0);
            inst.play();
            for (v in vocals) v.play();
        }
        else
        {
            isPlaying  = false;
            inst.pause();
            inst.time  = 0;
            for (v in vocals) if (v != null) { v.play(); v.pause(); v.time = 0; }
        }
    }

	// Streamed (vorbis) tracks only advance in ~270ms chunks between refills, and FlxSound's
	// time setter fully rebuilds the audio source - a tight threshold here causes constant
	// rebuild churn (audible stuttering), so this needs to be looser than that chunk size.
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

    static var persistedInst:FlxSound          = null;
    static var persistedVocals:Array<FlxSound> = [];
    static var persistedInstSound:openfl.media.Sound          = null;
    static var persistedVocalSounds:Array<openfl.media.Sound> = [];
    static var persistedMod:String             = '';
    static var persistedWasPlaying:Bool        = false;

    public static function stopPersisted():Void
    {
        if (persistedInst != null)
        {
            persistedInst.stop();
            FlxG.sound.list.remove(persistedInst, true);
            persistedInst.destroy();
        }
        for (v in persistedVocals) if (v != null)
        {
            v.stop();
            FlxG.sound.list.remove(v, true);
            v.destroy();
        }
        persistedInstSound?.close();
        for (s in persistedVocalSounds) s?.close();
        persistedInst        = null;
        persistedVocals      = [];
        persistedInstSound   = null;
        persistedVocalSounds = [];
        persistedMod        = '';
        persistedWasPlaying = false;
        currentSong    = '';
        currentSongMod = '';
    }

    var checkers:FlxBackdrop;
    var decors:Array<FlxSprite> = [];
    var arrow:FlxSprite;
    var spikes:FlxBackdrop;
    var dagarden:FlxSprite;
    var rotTime:Float = 0.0;
    var songs:DAGSongs;
    var player:DAGPlayer;

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
            if(_allFound) { backend.EXEAchievements.unlock('dagarden'); backend.EXEAchievements.checkFinale(); backend.EXEAchievements.save(); }
        }

        player = new DAGPlayer();
        add(player);

        if (persistedInst != null)
        {
            final idx = songs.songList.indexOf(currentSong);
            if (idx >= 0) songs.selectIndex(idx);
            player.setSongInfo(currentSong, songs.selectedCredits());
            player.reclaim(persistedInst, persistedVocals, persistedInstSound, persistedVocalSounds, persistedMod, persistedWasPlaying);
            persistedInst        = null;
            persistedVocals      = [];
            persistedInstSound   = null;
            persistedVocalSounds = [];
        }
        else
        {
            FlxG.sound.music?.pause();
            if (songs.songList.length > 0)
                songs.selectSong(0);
        }

        #if DISCORD_ALLOWED DiscordClient.changePresence("In the DA Garden", null); #end
        super.create();
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

        handleInput();
    }

    override public function destroy():Void
    {
        FlxG.autoPause = true;
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
        return keys != null && keys.length > 0 && FlxG.keys.anyJustPressed(keys);
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
        if (controls.BACK)
        {
            player.restoreWindowTitle();
            if (player.isPlaying)
            {
                final d = player.detach();
                persistedInst        = d.inst;
                persistedVocals      = d.vocals;
                persistedInstSound   = d.instSound;
                persistedVocalSounds = d.vocalSounds;
                persistedMod        = d.mod;
                persistedWasPlaying = d.wasPlaying;
                currentSong    = d.song;
                currentSongMod = d.mod;
            }
            else
            {
                player.stop();
                FlxG.sound.music?.resume();
                currentSong    = '';
                currentSongMod = '';
            }
            close();
        }
    }
}