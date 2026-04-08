package states.extras;

import backend.MusicBeatState;
import backend.Controls;
import backend.Paths;
import backend.Mods;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.extras.ExtrasMenu;
import sys.FileSystem;

class DAGarden extends MusicBeatState
{
    private var fondo:FlxSprite;
    private var sprite1:FlxSprite;
    private var sprite2:FlxSprite;
    private var sprite3:FlxSprite;
    private var sprite4:FlxSprite;
    private var sprite6:FlxSprite;
    private var sprite7:FlxSprite;
    private var sprite8:FlxSprite;
    private var arrow:FlxSprite;
    private var spikes:FlxBackdrop;
    private var marcogris:FlxSprite;
    private var dagarden:FlxSprite;
    private var box:FlxSprite;
    private var disk:FlxSprite;
    private var bar:FlxSprite;
    private var barProgress:FlxSprite;
    private var gardenbox:FlxSprite;
    private var play:FlxSprite;

    private var timeTxt:FlxText;
    private var songNameTxt:FlxText;

    private var barInnerX:Float = 0;
    private var barInnerY:Float = 0;
    private var barInnerW:Float = 0;
    private var barInnerH:Float = 0;

    private var rotationTime:Float = 0;

    private var songList:Array<String>     = [];
    private var songMods:Array<String>     = [];
    private var songBoxes:Array<FlxSprite> = [];
    private var songLabels:Array<FlxText>  = [];

    static inline var BOX_START_X:Float      = 86;
    static inline var BOX_START_Y:Float      = 116;
    static inline var BOX_SPACING:Float      = 120;
    static inline var BOX_SCALE:Float        = 0.308;
    static inline var SELECTED_OFFSET_X:Float = 18;

    private var scrollY:Float      = 0;
    private var scrollTarget:Float = 0;
    private var selectedIndex:Int  = -1;

    private var instSound:FlxSound   = null;
    private var vocalsSounds:Array<FlxSound> = [];
    private var vocalsEnabled:Bool   = true;
    private var isPlaying:Bool       = false;

    private var inputCooldown:Float = 0;
    static inline var SEEK_SECONDS:Float = 5.0;

    private var diskSpeed:Float     = 0;
    static inline var DISK_MAX_SPEED:Float  = 45;
    static inline var DISK_ACCEL:Float      = 6;
    static inline var DISK_DECEL:Float      = 10;

    private var audioFadeTarget:Float = 1.0;
    private var audioFadeSpeed:Float  = 0;


    override public function create():Void
    {
        Paths.clearStoredMemory();
        super.create();

        loadSongList();
        initializeSprites();
        setupAnimations();

        Paths.clearUnusedMemory();
    }

    private function initializeSprites():Void
    {
        fondo = createSprite(0, 0, "fondo.png", 0.34);

        sprite1 = createSprite(560, 560, "1.png", 0.25);
        sprite2 = createSprite(950, 580, "2.png", 0.15);
        sprite3 = createSprite(1100, 50, "3.png", 0.25);
        sprite4 = createSprite(540, 300, "4.png", 0.25);
        sprite6 = createSprite(700, 800, "6.png", 0.25);
        sprite7 = createSprite(550, 50, "7.png", 0.25);
        sprite8 = createSprite(800, 50, "8.png", 0.25);

        arrow = createSprite(490, 90, "arrow.png", 0.34);

        spikes = new FlxBackdrop("assets/exe/extras/dagarden/spikes.png", Y, 0, 0);
        spikes.setPosition(70, 87);
        spikes.scale.set(0.34, 0.34);
        spikes.updateHitbox();
        spikes.antialiasing = ClientPrefs.data.antialiasing;
        add(spikes);

        buildSongBoxes();

        marcogris = createSprite(0, 0, "marcogris.png", 0.34);
        dagarden  = createSprite(70, 35, "dagarden.png", 0.34);
        box       = createSprite(565, 100, "box.png", 0.34);
        disk      = createSprite(697, 206, "disk.png", 0.356);

        var barScale:Float = 0.34;
        var barBmp = openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/bar.png");
        var barFullW:Float = barBmp.width  * barScale;
        var barFullH:Float = barBmp.height * barScale;
        var barX:Float = 620;
        var barY:Float = 620;
        var marginX:Float = barFullW * 0.022;
        var marginY:Float = barFullH * 0.12;
        barInnerX = barX + marginX;
        barInnerY = barY + marginY;
        barInnerW = barFullW - marginX * 2;
        barInnerH = barFullH - marginY * 2;

        barProgress = new FlxSprite(barInnerX, barInnerY);
        barProgress.makeGraphic(Std.int(barInnerW), Std.int(barInnerH), 0xFFCC0000);
        barProgress.antialiasing = false;
        barProgress.clipRect = new flixel.math.FlxRect(0, 0, 0, barInnerH);
        add(barProgress);

        bar  = createSprite(barX, barY, "bar.png", barScale);
        play = createSprite(616, 478, "play.png", 0.34);

        timeTxt = new FlxText(barX, barY + barFullH + 4, Std.int(barFullW), '0:00', 18);
        timeTxt.setFormat('assets/fonts/NiseSegaSonic.TTF', 18, FlxColor.WHITE, CENTER);
        timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        add(timeTxt);

        songNameTxt = new FlxText(697, 170, 400, '', 20);
        songNameTxt.setFormat('assets/fonts/NiseSegaSonic.TTF', 20, FlxColor.WHITE, CENTER);
        songNameTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        add(songNameTxt);
    }

    private function createSprite(x:Float, y:Float, fileName:String, scale:Float):FlxSprite
    {
        var sprite = new FlxSprite(x, y);
        sprite.loadGraphic(openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/" + fileName));
        sprite.scale.set(scale, scale);
        sprite.updateHitbox();
        sprite.antialiasing = ClientPrefs.data.antialiasing;
        add(sprite);
        return sprite;
    }

    private function setupAnimations():Void
    {
        createFloatAnimation(sprite1, 20, 8, 3.2, 2.1);
        createFloatAnimation(sprite2, -10, 18, 1.8, 3.5);
        createFloatAnimation(sprite3, 25, -15, 2.9, 1.7);
        createFloatAnimation(sprite4, -18, 22, 2.4, 3.1);
        createFloatAnimation(sprite6, 12, -20, 3.6, 2.2);
        createFloatAnimation(sprite7, -16, 14, 1.9, 2.8);
        createFloatAnimation(sprite8, 28, 10, 3.3, 2.5);

        FlxTween.tween(arrow, {y: arrow.y - 10}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.tween(dagarden, {y: dagarden.y + 5}, 3.0, {ease: FlxEase.sineInOut, type: PINGPONG});
    }

    private function createFloatAnimation(sprite:FlxSprite, offsetX:Float, offsetY:Float, durationX:Float, durationY:Float):Void
    {
        FlxTween.tween(sprite, {x: sprite.x + offsetX}, durationX, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.tween(sprite, {y: sprite.y + offsetY}, durationY, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.tween(sprite, {alpha: 0.85}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG, startDelay: Math.random() * 2});
    }

    private function loadSongList():Void
    {
        songList = [];
        songMods = [];

        for (mod in Mods.parseList().enabled)
        {
            var songsDir = Paths.mods('$mod/songs');
            if (FileSystem.exists(songsDir) && FileSystem.isDirectory(songsDir))
            {
                for (song in FileSystem.readDirectory(songsDir))
                {
                    if (FileSystem.isDirectory('$songsDir/$song') && !songList.contains(song))
                    {
                        songList.push(song);
                        songMods.push(mod);
                    }
                }
            }
        }

        var globalSongs = Paths.mods('songs');
        if (FileSystem.exists(globalSongs))
        {
            for (song in FileSystem.readDirectory(globalSongs))
            {
                if (FileSystem.isDirectory('$globalSongs/$song') && !songList.contains(song))
                {
                    songList.push(song);
                    songMods.push('');
                }
            }
        }

        var pairs:Array<{song:String, mod:String}> = [];
        for (i in 0...songList.length)
            pairs.push({song: songList[i], mod: songMods[i]});
        pairs.sort((a, b) -> a.song < b.song ? -1 : 1);
        songList = [for (p in pairs) p.song];
        songMods = [for (p in pairs) p.mod];
    }

    private function buildSongBoxes():Void
    {
        for (i in 0...songList.length)
        {
            var bx = new FlxSprite(BOX_START_X, BOX_START_Y + i * BOX_SPACING);
            bx.loadGraphic(openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/gardenbox.png"));
            bx.scale.set(BOX_SCALE, BOX_SCALE);
            bx.updateHitbox();
            bx.antialiasing = ClientPrefs.data.antialiasing;
            add(bx);
            songBoxes.push(bx);

            var lbl = new FlxText(BOX_START_X + 10, BOX_START_Y + i * BOX_SPACING + 8, 300, songList[i].toUpperCase(), 14);
            lbl.setFormat(null, 14, FlxColor.WHITE, LEFT);
            lbl.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
            lbl.antialiasing = ClientPrefs.data.antialiasing;
            add(lbl);
            songLabels.push(lbl);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        spikes.velocity.y = 50;
        rotationTime += elapsed;

        sprite1.angle = Math.sin(rotationTime * 0.5) * 3;
        sprite3.angle = Math.cos(rotationTime * 0.7) * 4;
        sprite7.angle = Math.sin(rotationTime * 0.6) * 2;
        sprite8.angle = Math.cos(rotationTime * 0.8) * 3.5;

        var targetSpeed = isPlaying ? DISK_MAX_SPEED : 0;
        var rate = isPlaying ? DISK_ACCEL : DISK_DECEL;
        diskSpeed += (targetSpeed - diskSpeed) * rate * elapsed;
        disk.angle += elapsed * diskSpeed;

        if (audioFadeSpeed != 0)
        {
            var cur = instSound != null ? instSound.volume : 0;
            var next = cur + (audioFadeTarget - cur) * audioFadeSpeed * elapsed;
            if (instSound != null) instSound.volume = next;
            for (v in vocalsSounds) v.volume = vocalsEnabled ? next : 0;
            if (Math.abs(next - audioFadeTarget) < 0.01)
            {
                if (instSound != null) instSound.volume = audioFadeTarget;
                if (audioFadeTarget <= 0) stopAudio();
                audioFadeSpeed = 0;
            }
        }

        updateProgressBar();

        if (inputCooldown > 0) inputCooldown -= elapsed;

        handleScroll(elapsed);
        handleMouseClick();
        handlePlaybackInput(elapsed);

        if (Controls.instance.BACK)
        {
            stopAudio();
            if (FlxG.sound.music != null) FlxG.sound.music.resume();
            FlxG.switchState(new ExtrasMenu());
        }
    }

    private function updateProgressBar():Void
    {
        if (barProgress == null) return;
        var progress:Float = 0;
        var elapsed:Float  = 0;
        var total:Float    = 0;
        if (instSound != null && instSound.length > 0)
        {
            total    = instSound.length;
            elapsed  = instSound.time;
            progress = FlxMath.bound(elapsed / total, 0, 1);
        }
        barProgress.clipRect = new flixel.math.FlxRect(0, 0, barInnerW * progress, barInnerH);

        if (timeTxt != null)
        {
            var remaining = Std.int((total - elapsed) / 1000);
            if (remaining < 0) remaining = 0;
            var m = Std.int(remaining / 60);
            var s = remaining % 60;
            timeTxt.text = m + ':' + (s < 10 ? '0' : '') + s;
        }
    }

    private function handleScroll(elapsed:Float):Void
    {
        var wheel = FlxG.mouse.wheel;
        if (wheel != 0)
            scrollTarget -= wheel * BOX_SPACING;

        var minScroll:Float = 0;
        var maxScroll:Float = Math.max(0, (songList.length - 1) * BOX_SPACING - (FlxG.height - BOX_START_Y - BOX_SPACING));
        scrollTarget = FlxMath.bound(scrollTarget, minScroll, maxScroll);

        scrollY = FlxMath.lerp(scrollY, scrollTarget, 0.15);

        for (i in 0...songBoxes.length)
        {
            var yPos = BOX_START_Y + i * BOX_SPACING - scrollY;
            songBoxes[i].y  = yPos;
            songLabels[i].y = yPos + 8;

            var visible = yPos > BOX_START_Y - BOX_SPACING && yPos < FlxG.height;
            songBoxes[i].visible  = visible;
            songLabels[i].visible = visible;
        }
    }

    private function handleMouseClick():Void
    {
        if (!FlxG.mouse.justPressed) return;

        var mx = FlxG.mouse.x;
        var my = FlxG.mouse.y;

        for (i in 0...songBoxes.length)
        {
            var bx = songBoxes[i];
            if (!bx.visible) continue;

            if (mx >= bx.x && mx <= bx.x + bx.width &&
                my >= bx.y && my <= bx.y + bx.height)
            {
                selectSong(i);
                break;
            }
        }
    }

    private function selectSong(index:Int):Void
    {
        if (selectedIndex >= 0 && selectedIndex < songBoxes.length)
        {
            FlxTween.cancelTweensOf(songBoxes[selectedIndex]);
            FlxTween.tween(songBoxes[selectedIndex],  {x: BOX_START_X}, 0.15, {ease: FlxEase.quadOut});
            FlxTween.tween(songLabels[selectedIndex], {x: BOX_START_X + 10}, 0.15, {ease: FlxEase.quadOut});
        }

        selectedIndex = index;

        FlxTween.cancelTweensOf(songBoxes[index]);
        FlxTween.tween(songBoxes[index],  {x: BOX_START_X + SELECTED_OFFSET_X}, 0.2, {ease: FlxEase.quadOut});
        FlxTween.tween(songLabels[index], {x: BOX_START_X + SELECTED_OFFSET_X + 10}, 0.2, {ease: FlxEase.quadOut});

        if (songNameTxt != null)
            songNameTxt.text = songList[index].toUpperCase();

        if (isPlaying) fadeOutAndStop(); else stopAudio();
    }

    private function handlePlaybackInput(elapsed:Float):Void
    {
        if (selectedIndex < 0) return;

        if (FlxG.keys.justPressed.P)
        {
            if (isPlaying)
                pauseAudio();
            else
                playAudio();
        }

        if (FlxG.keys.justPressed.I)
        {
            vocalsEnabled = !vocalsEnabled;
            for (v in vocalsSounds) v.volume = vocalsEnabled ? 1 : 0;
        }

        if (FlxG.keys.justPressed.S)
            fadeOutAndStop();

        if (FlxG.keys.justPressed.A && instSound != null)
        {
            var t = Math.max(0, instSound.time - SEEK_SECONDS * 1000);
            instSound.time = t;
            for (v in vocalsSounds) v.time = t;
        }

        if (FlxG.keys.justPressed.D && instSound != null)
        {
            var t = Math.min(instSound.length - 100, instSound.time + SEEK_SECONDS * 1000);
            instSound.time = t;
            for (v in vocalsSounds) v.time = t;
        }
    }

    private function playAudio():Void
    {
        var song    = songList[selectedIndex];
        var modName = songMods[selectedIndex];

        if (instSound == null)
        {
            var prevMod = Mods.currentModDirectory;
            Mods.currentModDirectory = modName;

            var instPath = Paths.instPath(song);
            if (instPath == null || !FileSystem.exists(instPath))
            {
                Mods.currentModDirectory = prevMod;
                return;
            }

            instSound = FlxG.sound.load(openfl.media.Sound.fromFile(instPath));
            if (instSound == null) { Mods.currentModDirectory = prevMod; return; }
            instSound.looped = false;

            var vocPostfixes:Array<String> = [null, 'opponent', 'Opponent', 'player', 'Player'];
            var loadedPaths:Array<String> = [];
            for (postfix in vocPostfixes)
            {
                var vocPath = Paths.voicesPath(song, postfix);
                if (vocPath == null || !FileSystem.exists(vocPath)) continue;
                if (loadedPaths.contains(vocPath)) continue;
                loadedPaths.push(vocPath);
                var snd = FlxG.sound.load(openfl.media.Sound.fromFile(vocPath));
                if (snd == null) continue;
                snd.looped = false;
                snd.volume = vocalsEnabled ? 1 : 0;
                vocalsSounds.push(snd);
            }

            Mods.currentModDirectory = prevMod;

            instSound.volume = 0;
            for (v in vocalsSounds) v.volume = 0;
            instSound.play();
            for (v in vocalsSounds) v.play();
        }
        else
        {
            instSound.resume();
            for (v in vocalsSounds) v.resume();
        }

        audioFadeTarget = 1.0;
        audioFadeSpeed  = 8.0;

        isPlaying = true;
    }

    private function pauseAudio():Void
    {
        isPlaying = false;

        new flixel.util.FlxTimer().start(0.25, function(_) {
            if (instSound != null) instSound.pause();
            for (v in vocalsSounds) v.pause();
        });
    }

    private function stopAudio():Void
    {
        audioFadeSpeed = 0;

        if (instSound != null) { instSound.stop(); instSound.destroy(); instSound = null; }
        for (v in vocalsSounds) { v.stop(); v.destroy(); }
        vocalsSounds = [];
        isPlaying = false;

    }

    private function fadeOutAndStop():Void
    {
        if (instSound == null) return;
        isPlaying = false;
        audioFadeTarget = 0.0;
        audioFadeSpeed  = 12.0;
    }

    override public function destroy():Void
    {
        stopAudio();

        if (sprite1 != null)  FlxTween.cancelTweensOf(sprite1);
        if (sprite2 != null)  FlxTween.cancelTweensOf(sprite2);
        if (sprite3 != null)  FlxTween.cancelTweensOf(sprite3);
        if (sprite4 != null)  FlxTween.cancelTweensOf(sprite4);
        if (sprite6 != null)  FlxTween.cancelTweensOf(sprite6);
        if (sprite7 != null)  FlxTween.cancelTweensOf(sprite7);
        if (sprite8 != null)  FlxTween.cancelTweensOf(sprite8);
        if (arrow != null)    FlxTween.cancelTweensOf(arrow);
        if (dagarden != null) FlxTween.cancelTweensOf(dagarden);
        if (disk != null)     FlxTween.cancelTweensOf(disk);

        for (b in songBoxes) FlxTween.cancelTweensOf(b);
        songBoxes  = null;
        songLabels = null;
        songList   = null;
        songMods   = null;

        fondo = null; gardenbox = null; play = null;
        sprite1 = null; sprite2 = null; sprite3 = null;
        sprite4 = null; sprite6 = null; sprite7 = null;
        sprite8 = null; arrow = null; spikes = null;
        marcogris = null; dagarden = null; box = null;
        disk = null; bar = null; barProgress = null;
        timeTxt = null; songNameTxt = null;

        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        super.destroy();
    }
}
