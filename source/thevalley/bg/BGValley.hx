package thevalley.bg;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import thevalley.player.Player;
import shaders.WiggleEffect;
import shaders.WiggleEffect.WiggleEffectType;

class BGValley
{
    public static final EXTRASUN_X:Float = 80.0;
    public static final EXTRASUN_Y:Float = 230.0;
    public static final ECLIPSE_X:Float  = 80.0;
    public static final ECLIPSE_Y:Float  = 230.0;

    // mountains n fog scrollin at diff speeds so it looks 3D-ish you alredy kno
    static final LAYERS = [
        { path: "minigame/thevalley/bg/mountain/1-mountain", scrollX: 0.05, scrollY: 0.01, offsetX: 260.0, offsetY: -70.0 },
        { path: "minigame/thevalley/bg/mountain/2-mountain", scrollX: 0.1,  scrollY: 0.02, offsetX: 0.0,   offsetY: -80.0 },
        { path: "minigame/thevalley/bg/mountain/3-fog",      scrollX: 0.15, scrollY: 0.03, offsetX: 0.0,   offsetY: -70.0 },
        { path: "minigame/thevalley/bg/mountain/4-fog",      scrollX: 0.2,  scrollY: 0.04, offsetX: 0.0,   offsetY: -100.0 },
        { path: "minigame/thevalley/bg/mountain/5-mountain", scrollX: 0.3,  scrollY: 0.06, offsetX: 0.0,   offsetY: -110.0 },
        { path: "minigame/thevalley/bg/mountain/6-fog",      scrollX: 0.45, scrollY: 0.09, offsetX: 0.0,   offsetY: -100.0 },
    ];

    public var eclipse:FlxSprite;

    var _fogWiggles:Array<WiggleEffect> = [];
    var _state:FlxState;
    var _parts:Array<{ part:Int, x:Float, y:Float, width:Float, height:Float }>;
    public var mapSprites:Array<FlxSprite>          = [];
    public var mapSpriteByPart:Map<Int, FlxSprite>  = [];

    public var frontSprites:Array<FlxSprite> = [];
    var _blackFadeSprites:Array<{ spr:FlxSprite, bmd:openfl.display.BitmapData }> = [];
    var _frontLayers:Array<{ partIdx:Int, l:Dynamic }> = [];

    public function new(state:FlxState, parts:Array<{ part:Int, x:Float, y:Float, width:Float, height:Float }>)
    {
        _state = state;
        _parts = parts;
    }

    public function addSprites():Void
    {
        eclipse = new FlxSprite(ECLIPSE_X, ECLIPSE_Y);
        eclipse.frames = Paths.getSparrowAtlas("minigame/thevalley/bg/mountain/eclipse");

        var eclipseFrames:Array<Int> = [];
        for (fi in 0...eclipse.frames.frames.length)
            if (eclipse.frames.frames[fi].name.indexOf("eclipse idle") == 0)
                eclipseFrames.push(fi);

        eclipse.animation.add("idle", eclipseFrames, 3, true);
        eclipse.animation.play("idle");
        eclipse.scrollFactor.set(0.0, 0.0);
        eclipse.scale.set(1.1, 1.1);
        eclipse.updateHitbox();
        _state.add(eclipse);

        var extraSun = new FlxSprite(EXTRASUN_X, EXTRASUN_Y);
        extraSun.loadGraphic(Paths.image("minigame/thevalley/bg/mountain/extra-sun"));
        extraSun.scrollFactor.set(0.0, 0.0);
        extraSun.scale.set(1.1, 1.1);
        extraSun.updateHitbox();
        _state.add(extraSun);

        for (layer in LAYERS)
        {
            var bd = new FlxBackdrop(Paths.image(layer.path), FlxAxes.X);
            bd.scrollFactor.set(layer.scrollX, layer.scrollY);
            bd.x = layer.offsetX;
            bd.y = 350 + layer.offsetY;
            bd.scale.set(1.1, 1.1);

            if (layer.path.indexOf("fog") >= 0)
            {
                var fw = new WiggleEffect();
                fw.effectType    = WiggleEffectType.WAVY;
                fw.waveSpeed     = 0.5;
                fw.waveFrequency = 2.5;
                fw.waveAmplitude = 0.008;
                bd.shader = fw.shader;
                _fogWiggles.push(fw);
            }
            _state.add(bd);
        }

        var graywalls = new FlxSprite(0, 0);
        graywalls.loadGraphic(Paths.image("minigame/thevalley/bg/graywalls"));
        graywalls.scrollFactor.set(1.0, 1.0);
        _state.add(graywalls);

        var sorted = _parts.copy();
        sorted.sort(function(a, b) {
            var za:Int = Reflect.hasField(a, "zOrder") ? Std.int(Reflect.field(a, "zOrder")) : 0;
            var zb:Int = Reflect.hasField(b, "zOrder") ? Std.int(Reflect.field(b, "zOrder")) : 0;
            return za - zb;
        });

        for (p in sorted)
        {
            var spr = new FlxSprite(p.x, p.y);
            spr.loadGraphic(Paths.image('minigame/thevalley/map/${p.part}/map'));
            spr.scrollFactor.set(1.0, 1.0);
            _state.add(spr);
            mapSprites.push(spr);
            mapSpriteByPart[p.part] = spr;

            if (Reflect.hasField(p, "layers"))
            {
                var layers:Array<Dynamic> = Reflect.field(p, "layers");
                for (l in layers)
                {
                    var inFront:Bool = Reflect.hasField(l, "inFront") && (l.inFront : Bool);
                    if (inFront)
                        _frontLayers.push({ partIdx: _parts.indexOf(p), l: l });
                    else
                        _spawnLayer(p, l);
                }
            }
        }
    }

    public function addFrontLayers():Void
    {
        for (entry in _frontLayers)
        {
            final spr = _spawnLayer(_parts[entry.partIdx], entry.l);
            frontSprites.push(spr);

            final isBlackFade = Reflect.hasField(entry.l, "blackFade") && (entry.l.blackFade : Bool);
            if (isBlackFade)
            {
                var p = _parts[entry.partIdx];
                var graphic = Paths.image('minigame/thevalley/map/${p.part}/${entry.l.file}', false);

                _blackFadeSprites.push({ spr: spr, bmd: graphic.bitmap });
            }
        }
        _frontLayers = [];
    }

    function _spawnLayer(p:Dynamic, l:Dynamic):FlxSprite
    {
        var lx:Float = (p.x : Float) + (l.x : Float);
        var ly:Float = (p.y : Float) + (l.y : Float);
        var ls = new FlxSprite(lx, ly);

        if (Reflect.hasField(l, "xml"))
        {
            ls.frames = Paths.getSparrowAtlas('minigame/thevalley/map/${p.part}/${l.file}', false);

            if (Reflect.hasField(l, "animations"))
            {
                var anims:Array<Dynamic> = l.animations;
                for (a in anims)
                {
                    var fps:Int   = Reflect.hasField(a, "fps")  ? Std.int(a.fps)   : 12;
                    var loop:Bool = Reflect.hasField(a, "loop") ? (a.loop : Bool)  : true;
                    ls.animation.addByPrefix(a.name, a.prefix, fps, loop);
                }
                if (anims.length > 0) ls.animation.play(anims[0].name);
            }
        }
        else
        {
            ls.loadGraphic(Paths.image('minigame/thevalley/map/${p.part}/${l.file}', false));
        }

        ls.scrollFactor.set(1.0, 1.0);
        _state.add(ls);
        return ls;
    }

    public function update(elapsed:Float, ?player:Player):Void
    {
        for (fw in _fogWiggles) fw.update(elapsed);

        if (player != null && _blackFadeSprites.length > 0)
        {
            var sampleXs = [0.2, 0.5, 0.8];
            var sampleYs = [0.2, 0.5, 0.8];

            for (entry in _blackFadeSprites)
            {
                var hit = false;

                if (entry.bmd != null && entry.bmd.readable)
                {
                    for (fx in sampleXs)
                    {
                        if (hit) break;
                        for (fy in sampleYs)
                        {
                            var wx = Std.int(player.x + player.width  * fx);
                            var wy = Std.int(player.y + player.height * fy);
                            var lx = wx - Std.int(entry.spr.x);
                            var ly = wy - Std.int(entry.spr.y);

                            if (lx < 0 || ly < 0 || lx >= entry.bmd.width || ly >= entry.bmd.height) continue;

                            var alpha = (entry.bmd.getPixel32(lx, ly) >> 24) & 0xFF;
                            if (alpha > 30) { hit = true; break; }
                        }
                    }
                }

                var target = hit ? 0.20 : 1.0;
                entry.spr.alpha += (target - entry.spr.alpha) * (1.0 - Math.pow(0.01, elapsed * 2.0));
            }
        }
    }

    static inline var OCCLUSION_GRID:Int = 12;

    public function getOcclusionAmount(player:Player, ?extraSprites:Array<FlxSprite>):Float
    {
        var samples = [for (i in 0...OCCLUSION_GRID) (i + 0.5) / OCCLUSION_GRID];
        var hits  = 0;
        var total = samples.length * samples.length;

        for (fx in samples)
        {
            for (fy in samples)
            {
                var wx = Std.int(player.x + player.width  * fx);
                var wy = Std.int(player.y + player.height * fy);
                var hit = _isOpaqueAt(frontSprites, wx, wy) || _isOpaqueAt(mapSprites, wx, wy);
                if (!hit && extraSprites != null) hit = _isOpaqueAt(extraSprites, wx, wy);
                if (hit) hits++;
            }
        }
        return hits / total;
    }

    function _isOpaqueAt(sprites:Array<FlxSprite>, wx:Int, wy:Int):Bool
    {
        for (spr in sprites)
        {
            if (!spr.visible || spr.alpha <= 0) continue;
            var px = spr.pixels;
            if (px == null || !px.readable) continue;

            var lx = wx - Std.int(spr.x);
            var ly = wy - Std.int(spr.y);
            if (lx < 0 || ly < 0 || lx >= px.width || ly >= px.height) continue;

            var alpha = (px.getPixel32(lx, ly) >> 24) & 0xFF;
            if (alpha > 30) return true;
        }
        return false;
    }
}