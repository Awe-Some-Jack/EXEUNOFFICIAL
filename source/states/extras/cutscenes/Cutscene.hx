package states.extras.cutscenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;

import openfl.display.BitmapData;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import objects.VideoSprite;
#end

class Cutscene extends SonicSubState
{
    
    var COOLDOWN_TIMER:Float = #if mobile 0.15; #else 0.1; #end

    var checkerSprite:FlxSprite;
    var checkShader:shaders.ErrorHandledShader.ErrorHandledRuntimeShader;
    var checkerSpriteRight:FlxSprite;
    var checkShaderRight:shaders.ErrorHandledShader.ErrorHandledRuntimeShader;
    var box:FlxSprite;
    var boxHitboxRect:{x:Float, y:Float, w:Float, h:Float} = null;
    #if VIDEOS_ALLOWED
    var boxThumb:VideoSprite;
    #end
    var _boxThumbPath:String = null;
    var _boxThumbPendingPath:String = null;
    var _boxThumbDebounce:Float = 0.0;
    var _boxThumbReady:Bool = false;
    var disco:FlxSprite;
    var discoTween:FlxTween;
    var discoShadows:Array<FlxSprite> = [];
    var titleText:FlxSprite;
    var nowPlaying:FlxText;
    var nowPlayingSong:FlxText;

    var videoEntries:Array<{name:String, displayName:String, path:String, ?launch:Void->Void}> = [];

    public static function returnToExtras():Void
    {
        ExtrasMenu.openCutscenes = true;
        Mods.loadTopMod();
        FlxG.sound.music?.stop();
        FlxG.switchState(() -> new ExtrasMenu());
    }
    var menuItems:Array<FlxText> = [];
    // select box for the selection shit 
    var _selLeft:FlxSprite;
    var _selMid:FlxSprite;
    var _selRight:FlxSprite;
    var curSelected:Int = 0;
    var canMove:Bool    = true;
    var scrollY:Float       = 0.0;
    var scrollYTarget:Float = 0.0;

    var _vidBorder:FlxSprite = null;
    var _vidDim:FlxSprite    = null;
    #if VIDEOS_ALLOWED
    var _vidSprite:VideoSprite = null;
    #end
    var _vidOpen:Bool   = false;
    var _vidPaused:Bool = false;

    var _hud:FlxSpriteGroup  = null;
    var _hudBar:FlxSprite    = null;
    var _hudFill:FlxSprite   = null;
    var _hudKnob:FlxSprite   = null;
    var _hudBtn:FlxSprite    = null;
    var _hudTimeTxt:FlxText  = null;

    var _hudVisible:Bool    = false;
    var _hudIdleTimer:Float = 0.0;
    var _seekDragging:Bool  = false;
    var _lastMouseX:Float   = -1;
    var _lastMouseY:Float   = -1;

    var _leftOrigX:Map<flixel.FlxBasic, Float> = new Map();

    public static var debugMode:Bool = false;
    override public function create():Void
    {
        super.create();
        
        createBackground();
        createBox();
        createDisco();
        _scanVideos();
        _buildMenu();
        changeSelection(0);

        titleText = new FlxSprite(44.62, 58.31).loadGraphic(Paths.getBitmapData("assets/exe/extras/cutscenes/cutscene.webp"));
        titleText.scale.set(0.18, 0.18);
        titleText.updateHitbox();
        titleText.antialiasing = ClientPrefs.data.antialiasing;
        add(titleText);

        final gradientHeight:Int = 15;
        final descBar = new FlxSprite(0, 680 - gradientHeight);
        descBar.makeGraphic(FlxG.width, 100 + gradientHeight, FlxColor.TRANSPARENT, true);
        for (i in 0...gradientHeight)
        {
            final a:Float = (i / gradientHeight) * 0.3;
            descBar.pixels.fillRect(new openfl.geom.Rectangle(0, i, FlxG.width, 1), FlxColor.fromRGBFloat(0, 0, 0, a));
        }
        descBar.pixels.fillRect(new openfl.geom.Rectangle(0, gradientHeight, FlxG.width, 100), FlxColor.fromRGBFloat(0, 0, 0, 0.3));
        add(descBar);

        final descTemp = new FlxText(0, 0, 0, Language.getArray('extras.menu.cutscenes', ['', 'In here you can rewatch cutscenes used in gameplay! Just that!'])[1], Language.cjkSize(56));
        descTemp.setFormat(Paths.font(Language.fontOrCJK("smallass.TTF")), Language.cjkSize(56), FlxColor.WHITE, LEFT);
        descTemp.antialiasing = ClientPrefs.data.antialiasing;
        descTemp.updateHitbox();
        descTemp.drawFrame(true);
        
        final descBackdrop = new FlxBackdrop(descTemp.graphic, X, 0, 0);
        descBackdrop.scale.set(0.4, 0.4);
        descBackdrop.updateHitbox();
        descBackdrop.y = 685;
        descBackdrop.velocity.x = -30;
        add(descBackdrop);
        descTemp.destroy();

        nowPlaying = new FlxText(149, 558, 0, Language.get('extras.menu.nowplaying', 'NOW PLAYING:'), 60);
        nowPlaying.setFormat(Paths.font("bigass.otf"), 60, FlxColor.BLACK, LEFT);
        nowPlaying.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        nowPlaying.scale.set(0.22, 0.22);
        nowPlaying.updateHitbox();
        nowPlaying.antialiasing = ClientPrefs.data.antialiasing;
        add(nowPlaying);

        // positioned relative to nowPlaying's real rendered height (not a hardcoded offset) so it
        // still lines up correctly when the label text is longer/taller in another language
        final daName = states.extras.dagarden.DAGarden.currentSong;
        final songName = daName != '' ? daName.toUpperCase() : ExtrasMenu.instance.getThemeLabel();
        nowPlayingSong = new FlxText(149, nowPlaying.y + nowPlaying.height + 6, -1, songName, 60);
        nowPlayingSong.setFormat(Paths.font("bigass.otf"), 60, FlxColor.BLACK, LEFT);
        nowPlayingSong.setBorderStyle(OUTLINE_FAST, FlxColor.WHITE, Language.cjkBorder(6));
        nowPlayingSong.scale.set(0.22, 0.22);
        nowPlayingSong.updateHitbox();
        nowPlayingSong.antialiasing = ClientPrefs.data.antialiasing;
        nowPlayingSong.x = nowPlaying.x;
        add(nowPlayingSong);

        #if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end

        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In the Сutscenes menu", "Browsing Cutscenes", null, true, 0, "icon", 0, 0);
        #end
    }

    function createBackground():Void
    {
        final w:Int = FlxG.width;
        final h:Int = FlxG.height;
        final bmd = new openfl.display.BitmapData(w, h, false, 0xFF003380);
        final left  = {r: 0x00, g: 0x33, b: 0x80};
        final right = {r: 0x00, g: 0x0b, b: 0x3a};
        for (x in 0...w)
        {
            final t:Float = x / (w - 1);
            final r:Int = Math.round(left.r + (right.r - left.r) * t);
            final g:Int = Math.round(left.g + (right.g - left.g) * t);
            final b:Int = Math.round(left.b + (right.b - left.b) * t);
            bmd.fillRect(new openfl.geom.Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | (g << 8) | b);
        }
        final background = new FlxSprite(0, 0).loadGraphic(bmd);
        add(background);

        checkerSprite = new FlxSprite(0, 0);
        checkerSprite.makeGraphic(w, h, FlxColor.TRANSPARENT);
        checkerSprite.scrollFactor.set();
        checkShader = new shaders.ErrorHandledShader.ErrorHandledRuntimeShader('cutsceneChecker', '
            #pragma header
            uniform float uTime;
            void main()
            {
                vec2 uv = openfl_TextureCoordv;
                float tileSize = 40.0;
                float tx = floor((uv.x * ${w}.0 - uTime * 60.0) / tileSize);
                float ty = floor((uv.y * ${h}.0) / tileSize);
                float check = mod(tx + ty, 2.0);
                vec3 colorA = vec3(0.0, 0.09, 0.4);
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
        checkShaderRight = new shaders.ErrorHandledShader.ErrorHandledRuntimeShader('cutsceneCheckerRight', '
            #pragma header
            uniform float uTime;
            void main()
            {
                vec2 uv = openfl_TextureCoordv;
                float tileSize = 40.0;
                float tx = floor((uv.x * ${w}.0 + uTime * 60.0) / tileSize);
                float ty = floor((uv.y * ${h}.0) / tileSize);
                float check = mod(tx + ty, 2.0);
                vec3 colorA = vec3(0.0, 0.09, 0.4);
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

    function createBox():Void
    {
        box = new FlxSprite(750.0, 120.0).loadGraphic(Paths.getBitmapData("assets/exe/extras/cutscenes/box.webp"));
        box.scale.set(0.3, 0.3);
        box.updateHitbox();
        add(box);

        boxHitboxRect = _findRedRect(Paths.getBitmapData("assets/exe/extras/boxhitbox.webp"));
    }

    function _findRedRect(bmp:BitmapData):{x:Float, y:Float, w:Float, h:Float}
    {
        var minX = bmp.width, minY = bmp.height, maxX = 0, maxY = 0, found = false;
        for (y in 0...bmp.height)
        {
            for (x in 0...bmp.width)
            {
                final c = bmp.getPixel32(x, y);
                final a = (c >>> 24) & 0xFF;
                final r = (c >>> 16) & 0xFF;
                final g = (c >>> 8)  & 0xFF;
                final b = c & 0xFF;
                if (a > 200 && r > 180 && g < 100 && b < 100)
                {
                    found = true;
                    if (x < minX) minX = x;
                    if (x > maxX) maxX = x;
                    if (y < minY) minY = y;
                    if (y > maxY) maxY = y;
                }
            }
        }
        if (!found) return {x: 0.0, y: 0.0, w: bmp.width * 1.0, h: bmp.height * 1.0};
        return {x: minX * 1.0, y: minY * 1.0, w: (maxX - minX + 1) * 1.0, h: (maxY - minY + 1) * 1.0};
    }

    function _loadBoxThumb(path:String):Void
    {
        #if VIDEOS_ALLOWED
        if (path == null || path == _boxThumbPath) return;
        _boxThumbPath  = path;
        _boxThumbReady = false;

        if (boxThumb != null) { remove(boxThumb, true); boxThumb.destroy(); boxThumb = null; FlxG.signals.postUpdate.addOnce(backend.MemoryUtil.clearMinor); }

        final thumb = new VideoSprite(0, 0, false);
        thumb.autoDestroyOnComplete = false;
        thumb.isStateAffected       = false;
        thumb.visible = false;
        thumb.onFormat(() -> { if (thumb == boxThumb) _boxThumbReady = true; });

        final boxIdx = (box != null) ? members.indexOf(box) : -1;
        if (boxIdx >= 0) insert(boxIdx, thumb); else add(thumb);
        boxThumb = thumb;

        if (thumb.loadVideo(path, [VideoSprite.ARG_LOOPING, VideoSprite.ARG_MUTED]))
            thumb.playDelayed();
        else if (boxThumb == thumb)
        {
            remove(thumb, true); thumb.destroy();
            boxThumb = null;
        }
        #end
    }

    function _syncBoxThumb(elapsed:Float):Void
    {
        #if VIDEOS_ALLOWED
        if (_boxThumbPendingPath != null)
        {
            _boxThumbDebounce -= elapsed;
            if (_boxThumbDebounce <= 0)
            {
                _loadBoxThumb(_boxThumbPendingPath);
                _boxThumbPendingPath = null;
            }
        }

        if (boxThumb != null && boxHitboxRect != null && box != null)
        {
            final thumbW = boxHitboxRect.w * box.scale.x;
            final thumbH = boxHitboxRect.h * box.scale.y;
            boxThumb.x = box.x + (box.width - thumbW) * 0.5;
            boxThumb.y = box.y + (box.height - thumbH) * 0.5;
            if (_boxThumbReady)
            {
                boxThumb.setGraphicSize(thumbW, thumbH);
                boxThumb.visible = !_vidOpen;
            }
        }
        #end
    }

    function createDisco():Void
    {
        final shadowOffsets = [
            {x: -2, y: -2}, {x: 0, y: -2}, {x: 2, y: -2},
            {x: -2, y: 0},                  {x: 2, y: 0},
            {x: -2, y: 2},  {x: 0, y: 2},  {x: 2, y: 2}
        ];
        final discoBmp = Paths.getBitmapData("assets/exe/extras/disco.webp");
        for (offset in shadowOffsets)
        {
            final s = new FlxSprite(41 + offset.x, 541 + offset.y).loadGraphic(discoBmp);
            s.scale.set(0.29, 0.29);
            s.updateHitbox();
            s.color = FlxColor.BLACK;
            s.alpha = 0.3;
            add(s);
            discoShadows.push(s);
        }
        disco = new FlxSprite(41, 541).loadGraphic(discoBmp);
        disco.scale.set(0.29, 0.29);
        disco.updateHitbox();
        add(disco);
        discoTween = FlxTween.angle(disco, 0, 360, 3.0, {type: LOOPING});
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
                if (box == null) return;
                final cx = box.x; final cy = box.y;
                box.updateHitbox();
       
                box.x = cx; box.y = cy;
            }
        });
    }


    function _scanVideos():Void
    {
        videoEntries = [];

        final save:flixel.util.FlxSave = new flixel.util.FlxSave();
        backend.CoolUtil.bindSave(save, 'savedSongs', CoolUtil.getSavePath());
        save.data.songs ??= [];
        var unlocked:Array<String> = save.data.songs;

        // bye bye read json for load videos!! HAahahah 
        final rawList:Array<{name:String, displayName:String, ?path:String, ?launch:Void->Void}> = [
            {name: "too-slow",           displayName: "Too Slow Cutscene",              path: "contents/STORY MODE/videos/tooslow.mp4"},
            {name: "you-cant-run",       displayName: "You Can't Run Cutscene",         path: "contents/STORY MODE/videos/YRC.mp4"},
            {name: "triple-trouble",     displayName: "Triple Trouble Cutscene",        path: "contents/STORY MODE/videos/tripletrouble.mp4"},
            {name: "final-escape",       displayName: "Intro (Final Escape Fakeout)",   path: "contents/STORY MODE/videos/fake intro.mp4"},
            {name: "final-escape",       displayName: "Final Escape Dialogue Scene",    path: "contents/STORY MODE/videos/you know.mp4"},
            {name: "final-escape",       displayName: "Final Escape Super BF Scene",    path: "contents/STORY MODE/videos/what.mp4"},
            {name: "yourself",           displayName: "Yourself Cutscene",              path: "contents/STORY MODE/videos/EYE_TO_EYE intro.mp4"},
            {name: "yourself",           displayName: "Yourself Mirror Scene",          path: "contents/STORY MODE/videos/EYE FOR EYE.mp4"},
            {name: "sunshine",           displayName: "Sunshine Ending Cutscene",       path: "contents/TAILS DOLL/videos/dollending.mp4"},
            {name: "soulless",           displayName: "Soulless Cutscene",              path: "contents/TAILS DOLL/videos/soulless.mp4"},
            {name: "black-sun",          displayName: "Black Sun Ending Cutscene",      path: "contents/EXE/videos/Black Sun Transition.mp4"},
            {name: "black-sun",          displayName: "The Valley Intro",               launch: () -> _launchValley('intro')},
            {name: "black-sun",          displayName: "The Valley Ending",              launch: () -> _launchValley('ending')},
            {name: "godspeed",           displayName: "Godspeed Cutscene",              path: "contents/EXE/videos/good speed.mp4"},
            {name: "universal-collapse", displayName: "Universal Collapse Cutscene",    path: "contents/OMW/videos/omwintro.mp4"},
            {name: "pre-design",         displayName: "Movie Ugly Sonic Cutscene",      path: "contents/MOVIE/videos/SONIC FEO.mp4"},
            {name: "sharpy-showdown",    displayName: "Sharpy Showdown Cutscene",       launch: _launchSharpy},
            {name: "prey",               displayName: "Stardust Speedway Ending",       launch: _launchPrey},
            {name: "fight-or-flight",    displayName: "Fight or Flight Cutscene",       path: "contents/STARVED/videos/intro.mp4"},
            {name: "mania",              displayName: "Mania Ending Cutscene",          path: "contents/CRAZY TAILS/videos/Who is he.mp4"},
            {name: "personel",           displayName: "Personel Cutscene",              path: "contents/COLDSTEEL/videos/intro.mp4"},
            {name: "deception",          displayName: "Deception Cutscene",             path: "contents/REQUITAL/videos/anim.mp4"},
            {name: "fakebaby",           displayName: "Fakebaby Cutscene",              path: "contents/NMI/videos/fakebaby.mp4"},
            {name: "fakebaby",           displayName: "Fakebaby Ending Cutscene",       path: "contents/NMI/videos/fakebabyfinal.mp4"}
        ];

        for (entry in rawList)
        {
            final songKey:String = Paths.formatToSongPath(entry.name);
            final isUnlocked:Bool = debugMode || unlocked.contains(songKey);

            if (isUnlocked && entry.launch != null)
            {
                videoEntries.push({name: entry.name, displayName: entry.displayName, path: null, launch: entry.launch});
            }
            else if (isUnlocked)
            {
                trace("unlocked "+entry.name);
                final fullPath = Paths.mods(entry.path);
                if (FileSystem.exists(fullPath))
                {
                    videoEntries.push({
                        name: entry.name,
                        displayName: entry.displayName,
                        path: fullPath
                    });
                }
                else if (FileSystem.exists(entry.path))
                {
                    videoEntries.push({
                        name: entry.name,
                        displayName: entry.displayName,
                        path: entry.path
                    });
                }
            }
        }
    }

    static function videoJsonPath():String
        return #if mac backend.CoolUtil.userDataDir() + 'video.json' #else 'assets/exe/extras/cutscenes/video.json' #end;

    function _loadJsonManifest():Void
    {
        videoEntries = [];
        if (!FileSystem.exists(videoJsonPath())) return;

        try
        {
            final json:Dynamic = haxe.Json.parse(File.getContent(videoJsonPath()));
            final arr:Array<Dynamic> = cast json.videos;
            if (arr != null)
                for (v in arr)
                    videoEntries.push({name: Std.string(v.name), displayName: Std.string(v.displayName), path: Std.string(v.path)});
        }
        catch (_:Dynamic) {}
    }

    function _scanDirIfExists(dir:String):Void
    {
        if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
            _scanDir(dir);

        trace(dir);
    }

    function _scanDir(dir:String):Void
	{
		var scanPath = dir.endsWith('/') ? dir : dir + '/';
        for (entry in FileSystem.readDirectory(scanPath))
		{
			final full = scanPath + entry;

			final lowerEntry = entry.toLowerCase();
			var matchedExt:String = null;
			for (ext in Paths.VIDEO_EXTS)
				if (lowerEntry.endsWith('.$ext')) { matchedExt = ext; break; }

			if (matchedExt != null)
			{
				final noExt = entry.substr(0, entry.length - matchedExt.length - 1);
                trace(full);
                videoEntries.push({name: noExt, displayName: _toDisplayName(noExt), path: full});
			}
			else if (!entry.contains('.'))
			{
				_scanDir(full);
			}
		}
	}

    function _toDisplayName(name:String):String
    {
        var s = name.split('-').join(' ').split('_').join(' ');
        final words = s.split(' ');
        final result = [];
        for (w in words)
            if (w.length > 0)
                result.push(w.charAt(0).toUpperCase() + w.substr(1).toLowerCase());
        return result.join(' ');
    }

    function _saveJson():Void
    {
        final arr = [];
        for (e in videoEntries)
            arr.push({name: e.name, displayName: e.displayName, path: e.path});
        final json = haxe.Json.stringify({videos: arr}, null, '  ');
        try { File.saveContent(videoJsonPath(), json); } catch (_:Dynamic) {}
    }

    function _buildMenu():Void
    {
        if (videoEntries.length == 0)
        {
            final lbl = new FlxText(50.0, 180.0, 0, Language.get('cutscenes.empty', 'NO VIDEOS FOUND'), Language.cjkSize(88));
            lbl.setFormat(Paths.font("bigass.otf"), Language.cjkSize(88), FlxColor.WHITE, LEFT);
            lbl.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, Language.cjkBorder(8));
            lbl.scale.set(0.5, 0.5);
            lbl.updateHitbox();
            add(lbl);
            menuItems.push(lbl);
        }
        else
        {
            for (i in 0...videoEntries.length)
            {
                final lbl = new FlxText(50.0, 180.0 + (i * 58.0), 0, Language.upper(videoEntries[i].displayName), Language.cjkSize(88));
                lbl.setFormat(Paths.font("bigass.otf"), Language.cjkSize(60), FlxColor.WHITE, LEFT);
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

    function _scrollTargetFor(index:Int):Float
    {
        final ideal = (index - Std.int(6 / 2)) * 58.0;
        final maxScroll = Math.max(0.0, (menuItems.length - 6) * 58.0);
        return FlxMath.bound(ideal, 0, maxScroll);
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected += change;
        #if mobile COOLDOWN_TIMER = 0.15; #else COOLDOWN_TIMER = 0.1; #end
        final maxIdx = menuItems.length - 1;
        if (curSelected < 0) curSelected = maxIdx;
        if (curSelected > maxIdx) curSelected = 0;
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
            menuItems[i].updateHitbox();
        }

        _updateSelectBox();

        #if VIDEOS_ALLOWED
        if (videoEntries.length > 0 && videoEntries[curSelected].launch != null)
        {
            _boxThumbPendingPath = null;
            _boxThumbPath = null;
            if (boxThumb != null) { remove(boxThumb, true); boxThumb.destroy(); boxThumb = null; }
        }
        else if (videoEntries.length > 0)
        {
            _boxThumbPendingPath = videoEntries[curSelected].path;
            _boxThumbDebounce = (change != 0) ? 0.18 : 0.0;
        }
        #end
    }

    function _calcSelectLayout():{targetX:Float, targetY:Float, capPx:Float, midPx:Float, midScaleX:Float, scaleY:Float}
    {
        final item      = menuItems[curSelected];
        final itemW     = item.frameWidth * 0.525 + 26;
        final scaleY    = 0.28;
        final capPx     = _selLeft.frameWidth * scaleY;
        final minMidPx  = _selMid.frameWidth * scaleY;
        final midPx     = Math.max(minMidPx, itemW - capPx * 2);
        final midScaleX = midPx / _selMid.frameWidth;
        final targetY   = 180.0 + (curSelected * 58.0) - scrollYTarget - 16;
        return {targetX: 50.0 - 28, targetY: targetY, capPx: capPx, midPx: midPx, midScaleX: midScaleX, scaleY: scaleY};
    }


    function _snapSelectBox():Void
    {
        if (_selLeft == null || _selMid == null || _selRight == null) return;
        final l = _calcSelectLayout();
        for (s in [_selLeft, _selMid, _selRight]) { FlxTween.cancelTweensOf(s); FlxTween.cancelTweensOf(s.scale); }
        _selLeft.setPosition(l.targetX, l.targetY);
        _selLeft.scale.set(l.scaleY, l.scaleY);
        _selMid.setPosition(l.targetX + l.capPx - 1.0, l.targetY);
        _selMid.scale.set((l.midPx + 1.0 * 2) / _selMid.frameWidth, l.scaleY);
        _selRight.setPosition(l.targetX + l.capPx + l.midPx, l.targetY);
        _selRight.scale.set(l.scaleY, l.scaleY);
    }

    function _updateSelectBox():Void
    {
        if (_selLeft == null || _selMid == null || _selRight == null) return;
        final l = _calcSelectLayout();
        for (s in [_selLeft, _selMid, _selRight]) { FlxTween.cancelTweensOf(s); FlxTween.cancelTweensOf(s.scale); }
        FlxTween.tween(_selLeft,        {x: l.targetX,                                    y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selLeft.scale,  {x: l.scaleY,     y: l.scaleY},                                 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selMid,         {x: l.targetX + l.capPx - 1.0,            y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selMid.scale,   {x: (l.midPx + 1.0 * 2) / _selMid.frameWidth, y: l.scaleY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selRight,       {x: l.targetX + l.capPx + l.midPx,                y: l.targetY}, 0.35, {ease: FlxEase.expoOut});
        FlxTween.tween(_selRight.scale, {x: l.scaleY,     y: l.scaleY},                                 0.35, {ease: FlxEase.expoOut});
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

    function _openVideo(path:String):Void
    {
        #if VIDEOS_ALLOWED
        if (_vidOpen) _closeVideo();
        _vidOpen   = true;
        _vidPaused = false;
        canMove    = false;

        if (boxThumb != null) { boxThumb.pause(); boxThumb.visible = false; }

        _vidBorder = new FlxSprite(0, 0);
        _vidBorder.makeGraphic(1, 1, 0xFF3a6bc9);
        _vidBorder.alpha = 0;
        add(_vidBorder);

        _vidSprite = new VideoSprite(0, 0, false);
        _vidSprite.onFormat(() -> {
            final maxW = FlxG.width  * 0.7;
            final maxH = FlxG.height * 0.65;
            final s    = Math.min(maxW / _vidSprite.video.width, maxH / _vidSprite.video.height);
            final fw   = Math.floor(_vidSprite.video.width  * s);
            final fh   = Math.floor(_vidSprite.video.height * s);
 
            _vidSprite.setGraphicSize(fw, fh);
            _vidSprite.screenCenter();

            final finalY = FlxG.height * 0.5 - fh * 0.5 - 25;

            _vidSprite.setPosition(FlxG.width * 0.5 - fw * 0.5, -fh);

            final vidShader = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000);
            vidShader.setSize(fw, fh);
  
            _vidSprite.video.shader = vidShader;

            final bw = fw + Std.int(6.0 * 2);
            final bh = fh + Std.int(6.0 * 2);
            _vidBorder.makeGraphic(bw, bh, 0xFF3a6bc9);
            _vidBorder.setPosition(_vidSprite.x - 6.0, _vidSprite.y - 6.0);

            final borderShader = new shaders.RoundedBorderShader(16.0 + 6.0, 0.0, 0xFF000000);
            borderShader.setSize(bw, bh);

            _vidBorder.shader = borderShader;

            FlxTween.tween(_vidSprite,  {y: finalY},                    0.35, {ease: FlxEase.expoOut});
            FlxTween.tween(_vidBorder,  {y: finalY - 6.0, alpha: 1}, 0.35, {ease: FlxEase.expoOut});

            _buildHud(fw, finalY + fh);

            #if DISCORD_ALLOWED
                DiscordClient.changePresence("In the Сutscenes menu", 'Watching ${videoEntries[curSelected].displayName}', null, true, haxe.Int64.toInt(#if switch _vidSprite.video.duration #else _vidSprite.video.bitmap.duration #end), "icon", 3, 0);
            #end
        });
        _vidSprite.onEnd(() -> { 
            _vidSprite.playDelayed(); 
            _vidPaused = false; 
            _hudUpdateBtn(); 
            #if DISCORD_ALLOWED
                DiscordClient.changePresence("In the Сutscenes menu", 'Watching ${videoEntries[curSelected].displayName}', null, true, haxe.Int64.toInt(#if switch _vidSprite.video.duration #else _vidSprite.video.bitmap.duration #end), "icon", 3, 0);
            #end
        });

        if (FlxG.sound.music != null)
        {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 0.1}, 0.5, {ease: FlxEase.quadOut});
        }

        add(_vidSprite);
        
        if (_vidSprite.loadVideo(path, [VideoSprite.ARG_LOOPING]))
            _vidSprite.playDelayed();
        #end
    }

    function _buildHud(vidW:Float, hudTopY:Float):Void
    {
        if (_hud != null) { remove(_hud, true); _hud.destroy(); _hud = null; }

        _hud = new FlxSpriteGroup();
        _hud.alpha = 0;
        final hudX = _vidSprite.x;
        final hudY = hudTopY + 8;
        final w    = vidW;
        final bg = new FlxSprite(hudX, hudY).makeGraphic(Std.int(w), Std.int(52.0), 0x00000000, true);
        bg.pixels.fillRect(new openfl.geom.Rectangle(0, 0, w, 52.0), 0xBB000000);
        final hudShader = new shaders.RoundedBorderShader(52.0 * 0.5, 0.0, 0xFF000000);
        hudShader.setSize(Std.int(w), Std.int(52.0));
        bg.shader = hudShader;
        _hud.add(bg);

        _hudBtn = new FlxSprite(0, 0).loadGraphic(Paths.getBitmapData('assets/exe/extras/credits/pause.webp'));
        final btnScale = 32.0 / Math.max(_hudBtn.width, _hudBtn.height);
        _hudBtn.scale.set(btnScale, btnScale);
        _hudBtn.updateHitbox();
        _hudBtn.x = hudX + 14.0;
        _hudBtn.y = hudY + (52.0 - _hudBtn.height) * 0.5;
        _hudBtn.color = 0xFFFFFFFF;
        _hud.add(_hudBtn);
        final barX = _hudBtn.x + _hudBtn.width + 14.0;
        final barY = hudY + 52.0 * 0.5 - 3;
        final barW = w - (barX - hudX) - 14.0 * 2 - 60;

        _hudBar = new FlxSprite(barX, barY);
        _hudBar.makeGraphic(Std.int(barW), 6, 0xFF555577);
        final barShader = new shaders.RoundedBorderShader(3.0, 0.0, 0xFF000000);
        barShader.setSize(Std.int(barW), 6);
        _hudBar.shader = barShader;
        _hud.add(_hudBar);
        _hudFill = new FlxSprite(barX, barY);
        _hudFill.makeGraphic(1, 6, 0xFF5a8fff);
        _hudFill.scale.x = 1;
        _hudFill.updateHitbox();
        _hud.add(_hudFill);

        final knobD = Std.int(7.0 * 2);
        _hudKnob = new FlxSprite(0, 0);
        _hudKnob.makeGraphic(knobD, knobD, 0x00000000, true);
        final cx = 7.0; final cy = 7.0;
        for (py in 0...knobD)
            for (px in 0...knobD)
                if (Math.sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy)) <= 7.0)
                    _hudKnob.pixels.setPixel32(px, py, 0xFFFFFFFF);
        _hudKnob.x = barX - 7.0;
        _hudKnob.y = barY + 3 - 7.0;
        _hud.add(_hudKnob);
        _hudTimeTxt = new FlxText(0, 0, 55, "0:00", 14);
        _hudTimeTxt.setFormat(Paths.font("bigass.otf"), 14, FlxColor.WHITE, RIGHT);
        _hudTimeTxt.antialiasing = ClientPrefs.data.antialiasing;
        _hudTimeTxt.x = hudX + w - 14.0 - 55;
        _hudTimeTxt.y = hudY + (52.0 - _hudTimeTxt.height) * 0.5;
        _hud.add(_hudTimeTxt);

        add(_hud);
        _hudVisible   = false;
        _hudIdleTimer = 0.0;
        _seekDragging = false;
    }

    function _hudUpdateBtn():Void
    {
        if (_hudBtn == null) return;
        _hudBtn.loadGraphic(Paths.getBitmapData(_vidPaused
            ? 'assets/exe/extras/credits/play.webp'
            : 'assets/exe/extras/credits/pause.webp'));
        final btnScale = 32.0 / Math.max(_hudBtn.frameWidth, _hudBtn.frameHeight);
        _hudBtn.scale.set(btnScale, btnScale);
        _hudBtn.updateHitbox();
        if (_hud != null && _hud.members.length > 0)
        {
            final bg = _hud.members[0];
            _hudBtn.y = bg.y + (52.0 - _hudBtn.height) * 0.5;
        }
    }

    function _hudSetVisible(v:Bool):Void
    {
        if (_hud == null) return;
        if (_hudVisible == v) return;
        _hudVisible = v;
        FlxTween.cancelTweensOf(_hud);
        FlxTween.tween(_hud, {alpha: v ? 1.0 : 0.0}, 0.22, {ease: FlxEase.quadInOut});
    }

    function _hudFmtTime(ms:Int):String
    {
        final s = Std.int(ms / 1000);
        final m = Std.int(s / 60);
        return '$m:${StringTools.lpad(Std.string(s % 60), "0", 2)}';
    }

    function _updateHud(elapsed:Float):Void
    {
        #if VIDEOS_ALLOWED
        if (_hud == null || _vidSprite == null) return;
        final mx = FlxG.mouse.x;
        final my = FlxG.mouse.y;
        final moved = (mx != _lastMouseX || my != _lastMouseY);
        _lastMouseX = mx; _lastMouseY = my;

        if (moved || _seekDragging) { _hudIdleTimer = 0.0; _hudSetVisible(true); }
        else if (_hudVisible && !_seekDragging)
        {
            _hudIdleTimer += elapsed;
            if (_hudIdleTimer >= 2.5) _hudSetVisible(false);
        }

        if (_hudBar != null && _hudFill != null && _hudKnob != null)
        {
            final pct   = FlxMath.bound(_vidSprite.getVideoPercent(), 0, 1);
            #if switch
            final dur   = haxe.Int64.ofInt(_vidSprite.video.duration);
            #else
            final dur   = _vidSprite.video.bitmap.duration;
            #end
            final barW  = _hudBar.width;
            final fillW = Math.max(1, barW * pct);
            _hudFill.scale.x = fillW;
            _hudFill.updateHitbox();
            _hudKnob.x = _hudBar.x + barW * pct - 7.0;
            if (_hudTimeTxt != null) _hudTimeTxt.text = _hudFmtTime(Std.int(pct * haxe.Int64.toInt(dur)));
        }

        if (_hudBar != null)
        {
            final barX = _hudBar.x;
            final barW = _hudBar.width;

            if (FlxG.mouse.justPressed && my >= _hudBar.y - 8 && my <= _hudBar.y + 14
                && mx >= barX - 4 && mx <= barX + barW + 4)
                _seekDragging = true;
            if (_seekDragging)
                _vidSprite.setVideoPercent(FlxMath.bound((mx - barX) / barW, 0, 1));

            if (FlxG.mouse.justReleased) {
                _seekDragging = false;
                #if DISCORD_ALLOWED
                if (_vidSprite?.video?.bitmap != null)
                    DiscordClient.changePresence("In the Сutscenes menu", 'Watching ${videoEntries[curSelected].displayName}' + (_vidPaused ? ' (Paused)' : ''), null, true, haxe.Int64.toInt(#if switch _vidSprite.video.duration #else _vidSprite.video.bitmap.duration #end), "icon", 3, _vidSprite.getTime());
                #end
            }
        }

        if (_hudBtn != null && FlxG.mouse.justPressed && _vidSprite != null && FlxG.mouse.overlaps(_hudBtn))
        {
            _vidPaused = !_vidPaused;
            if (_vidPaused) _vidSprite.pause(); else _vidSprite.resume();
            _hudUpdateBtn();
            
            #if DISCORD_ALLOWED
            if (_vidSprite.video?.bitmap != null) {
                final durMs = _vidPaused ? 0 : haxe.Int64.toInt(#if switch _vidSprite.video.duration #else _vidSprite.video.bitmap.duration #end);
                DiscordClient.changePresence("In the Сutscenes menu", 'Watching ${videoEntries[curSelected].displayName}' + (_vidPaused ? ' (Paused)' : ''), null, true, durMs, "icon", 3, _vidSprite.getTime());
            }
            #end
        }
        #end
    }

    function _closeVideo():Void
    {
        #if VIDEOS_ALLOWED
        if (!_vidOpen) return;
        _vidOpen   = false;
        _vidPaused = false;

        if (_hud != null) { FlxTween.cancelTweensOf(_hud); remove(_hud, true); _hud.destroy(); _hud = null; }
        _hudBar = null; _hudFill = null; _hudKnob = null; _hudBtn = null; _hudTimeTxt = null;

        if (FlxG.sound.music != null)
        {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 1.0}, 0.5, {ease: FlxEase.quadOut});
        }

        final vidRef    = _vidSprite;
        final borderRef = _vidBorder;
        final dimRef    = _vidDim;

        _vidSprite = null;
        _vidBorder = null;
        _vidDim    = null;

        if (vidRef != null)
        {
            vidRef.stop();
            final targetY = -vidRef.height - 50;
            FlxTween.tween(vidRef,    {y: targetY}, 0.35, {ease: FlxEase.expoIn});
            FlxTween.tween(borderRef, {y: targetY - 6.0, alpha: 0}, 0.35, {
                ease: FlxEase.expoIn,
                onComplete: (_) -> {
                    remove(vidRef,    true); vidRef.destroy();
                    FlxG.signals.postUpdate.addOnce(backend.MemoryUtil.clearMinor);
                    remove(borderRef, true); borderRef.destroy();
         
                    if (dimRef != null) { remove(dimRef, true); dimRef.destroy(); }
                    _slideBackIn();
                    canMove = true;
                    #if DISCORD_ALLOWED
                    DiscordClient.changePresence("In the Сutscenes menu", "Browsing Cutscenes", null, true, 0, "icon", 0, 0);
                    #end
                }
            });
        }
        else
        {
            if (borderRef != null) { remove(borderRef, true); borderRef.destroy(); }
            if (dimRef    != null) { remove(dimRef,    true); dimRef.destroy(); }
            _slideBackIn();
            canMove = true;
            #if DISCORD_ALLOWED
            DiscordClient.changePresence("In the Сutscenes menu", "Browsing Cutscenes", null, true, 0, "icon", 0, 0);
            #end
        }
        #end
    }

    var isBacking:Bool = false;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (isBacking) return;

        if (FlxG.keys.justPressed.TAB){
            debugMode = !debugMode;
            FlxG.resetState();
        }

        if (COOLDOWN_TIMER > 0) COOLDOWN_TIMER -= elapsed;

        if (checkShader != null)
            checkShader.setFloat('uTime', checkShader.getFloat('uTime') + elapsed);
        if (checkShaderRight != null)
            checkShaderRight.setFloat('uTime', checkShaderRight.getFloat('uTime') + elapsed);

        if (nowPlayingSong != null)
        {
            final daName = states.extras.dagarden.DAGarden.currentSong;
            final display = daName != '' ? daName.toUpperCase() : ExtrasMenu.instance.getThemeLabel();
            if (nowPlayingSong.text != display) nowPlayingSong.text = display;
            nowPlayingSong.x = nowPlaying.x;
        }

        if (disco != null && discoShadows != null)
            for (s in discoShadows) s.angle = disco.angle;

        if (discoTween != null && FlxG.sound.music != null)
            discoTween.active = FlxG.sound.music.playing;

        if (_vidOpen)
        {
            _updateHud(elapsed);
            if ((controls.BACK #if mobile || backPressed #end) && !_seekDragging) _closeVideo();
            return;
        }

        scrollY += (scrollYTarget - scrollY) * FlxMath.bound(15.0 * elapsed, 0, 1);
        _applyScroll();
        _syncBoxThumb(elapsed);
        if (!canMove) return;

        if (controls.UI_UP_P)   changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        #if mobile
        if(pressHolding && deltaMouseY != 0 && COOLDOWN_TIMER <= 0)
            if(deltaMouseY > 5)
                changeSelection(1);
            else if(deltaMouseY < -1)
                changeSelection(-1);
        #else
        final mouseWheel = FlxG.mouse.wheel;
        if (mouseWheel != 0 && COOLDOWN_TIMER <= 0)
            changeSelection(mouseWheel > 0 ? -1 : 1);
        #end

        if ((controls.ACCEPT #if mobile || (shortPress && FlxG.mouse.overlaps(menuItems[curSelected])) #end) && videoEntries.length > 0)
            _selectCurrent();
        if (FlxG.mouse.justPressed && disco?.overlapsPoint(new flixel.math.FlxPoint(FlxG.mouse.x, FlxG.mouse.y)))
        {
            if (FlxG.sound.music != null)
            {
                if (FlxG.sound.music.playing) FlxG.sound.music.pause();
                else FlxG.sound.music.resume();
            }
        }

        if (controls.BACK #if mobile || backPressed #end)
        {
            isBacking = true;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
        }
    }

    function _slideOutAndOpenVideo():Void
    {
        final path = videoEntries[curSelected].path;
        var completed = 0;
        final total = 2;
        final onDone = (_:FlxTween) -> {
            completed++;
            if (completed >= total) _openVideo(path);
        };

        FlxTween.cancelTweensOf(box);
        FlxTween.tween(box, {x: FlxG.width + 50}, 0.35, {ease: FlxEase.expoIn, onComplete: onDone});
        final leftItems:Array<flixel.FlxObject> = [];
        for (item in menuItems) if (item != null) leftItems.push(item);
        if (_selLeft  != null) leftItems.push(_selLeft);
        if (_selMid   != null) leftItems.push(_selMid);
        if (_selRight != null) leftItems.push(_selRight);
        if (titleText      != null) leftItems.push(titleText);
        if (disco          != null) leftItems.push(disco);
        for (s in discoShadows) if (s != null) leftItems.push(s);
        if (nowPlaying     != null) leftItems.push(nowPlaying);
        if (nowPlayingSong != null) leftItems.push(nowPlayingSong);

        _leftOrigX = new Map();
        for (item in leftItems)
            _leftOrigX.set(item, item.x);
        var leftDone = false;
        for (item in leftItems)
        {
            FlxTween.cancelTweensOf(item);
            final target = -item.width - 100;
            FlxTween.tween(item, {x: target}, 0.35, {
                ease: FlxEase.expoIn,
                onComplete: (_) -> {
                    if (!leftDone) { leftDone = true; onDone(null); }
                }
           
            });
        }
    }

    function _slideBackIn():Void
    {
        if (box != null)
        {
            FlxTween.cancelTweensOf(box);
            box.x = FlxG.width + 50;
            FlxTween.tween(box, {x: 750.0}, 0.35, {ease: FlxEase.expoOut});
        }

        #if VIDEOS_ALLOWED
        if (boxThumb != null) { boxThumb.resume(); boxThumb.visible = _boxThumbReady; }
        #end

        final leftItems:Array<flixel.FlxObject> = [];
        for (item in menuItems) if (item != null) leftItems.push(item);
        if (_selLeft  != null) leftItems.push(_selLeft);
        if (_selMid   != null) leftItems.push(_selMid);
        if (_selRight != null) leftItems.push(_selRight);
        if (titleText      != null) leftItems.push(titleText);
        if (disco          != null) leftItems.push(disco);
        for (s in discoShadows) if (s != null) leftItems.push(s);
        if (nowPlaying     != null) leftItems.push(nowPlaying);
        if (nowPlayingSong != null) leftItems.push(nowPlayingSong);

        for (item in leftItems)
        {
            final origX = _leftOrigX.exists(item) ? _leftOrigX.get(item) : item.x;
            item.x = -item.width - 100;
            FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {x: origX}, 0.35, {ease: FlxEase.expoOut});
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
                    onComplete: (_) -> {
                        final launch = videoEntries[curSelected].launch;
                        if (launch != null) launch();
                        else _slideOutAndOpenVideo();
                    }
                });
            }
        });
    }

    static function _launchSharpy():Void
    {
        FlxG.sound.music?.stop();
        states.access.cutscene.SharpyCutscene.replay = true;
        FlxG.switchState(() -> new states.access.cutscene.SharpyCutscene());
    }

    static function _launchValley(scene:String):Void
    {
        FlxG.sound.music?.stop();
        Mods.currentModDirectory = 'EXE';
        minigames.thevalley.TheValley.fromFreeplay = false;
        minigames.thevalley.TheValley.cutsceneReplay = scene;
        minigames.thevalley.cutscenes.IntroCutscene.quickStart = scene == 'ending';
        FlxG.switchState(() -> new minigames.thevalley.TheValley());
    }

    static function _launchPrey():Void
    {
        FlxG.sound.music?.stop();
        Mods.currentModDirectory = 'STARVED';
        minigames.preymini.PreyMini.fromSoundTest = false;
        minigames.preymini.PreyMini.cutsceneReplay = true;
        FlxG.switchState(() -> new minigames.preymini.PreyMini(3, 0, false));
    }

    override function destroy()
    {
        if (menuItems != null)
            for (item in menuItems)
                if (item != null) 
                { 
                    FlxTween.cancelTweensOf(item);
                    FlxTween.cancelTweensOf(item.scale); 
                }
        
        for (s in [_selLeft, _selMid, _selRight]) 
            if (s != null) 
            { 
                FlxTween.cancelTweensOf(s);
                FlxTween.cancelTweensOf(s.scale); 
            }
        
        if (box != null) 
        { 
            FlxTween.cancelTweensOf(box);
            FlxTween.cancelTweensOf(box.scale); 
        }

        if (disco != null) 
            FlxTween.cancelTweensOf(disco);
        if (_hud != null) 
        { 
            FlxTween.cancelTweensOf(_hud);
            _hud.destroy(); 
            _hud = null; 
        }

        #if VIDEOS_ALLOWED
        if (_vidSprite != null) { remove(_vidSprite, true); _vidSprite.destroy(); _vidSprite = null; }
        if (boxThumb != null) { remove(boxThumb, true); boxThumb.destroy(); boxThumb = null; }
        #end

        super.destroy();
        backend.MemoryUtil.clearMinor();
    }
}