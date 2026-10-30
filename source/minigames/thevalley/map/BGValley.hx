package minigames.thevalley.map;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxAxes;

import openfl.Assets;

import haxe.ds.ArraySort;

import shaders.WiggleEffect;
import minigames.thevalley.character.player.Player;

typedef LayerAnim = { name:String, prefix:String, ?fps:Int, ?loop:Bool };

typedef MapLayer =
{
	file:String,
	?x:Float,
	?y:Float,
	?inFront:Bool,
	?blackFade:Bool,
	?animations:Array<LayerAnim>,
	?xml:Dynamic
};

typedef MapPart =
{
	part:Int,
	x:Float,
	y:Float,
	width:Float,
	height:Float,
	?zOrder:Int,
	?layers:Array<MapLayer>
};

private typedef Parallax = { file:String, scroll:Float, scrollY:Float, x:Float, y:Float, ?wave:Float, ?drift:Float };

private typedef Occluder = { spr:FlxSprite, mask:AlphaMask };

class BGValley
{
	public static final ECLIPSE_X:Float  = 80.0;
	public static final ECLIPSE_Y:Float  = 230.0;
	public static final EXTRASUN_X:Float = 80.0;
	public static final EXTRASUN_Y:Float = 230.0;

	static final PARALLAX:Array<Parallax> = [
		{ file: "1-mountain", scroll: 0.05, scrollY: 0.01, x: 260, y: -70 },
		{ file: "2-mountain", scroll: 0.10, scrollY: 0.02, x: 0,   y: -80 },
		{ file: "3-fog",      scroll: 0.15, scrollY: 0.03, x: 0,   y: -70,  wave: 0.4, drift: -3 },
		{ file: "4-fog",      scroll: 0.20, scrollY: 0.04, x: 0,   y: -100, wave: 0.5, drift: -5 },
		{ file: "5-mountain", scroll: 0.30, scrollY: 0.06, x: 0,   y: -110 },
		{ file: "6-fog",      scroll: 0.45, scrollY: 0.09, x: 0,   y: -100, wave: 0.6, drift: -8 },
	];

	static final FADE_POINTS = [0.2, 0.5, 0.8];

	public var eclipse(default, null):FlxSprite;
	public var sun(default, null):FlxSprite;

	public static final ECLIPSE_DISK_X:Float = EXTRASUN_X + 370.0 * 1.1;
	public static final ECLIPSE_DISK_Y:Float = EXTRASUN_Y + 48.5 * 1.1;
	public static final SKY_TOP:Float = ECLIPSE_Y;

	final _sky:Array<{ spr:FlxSprite, x:Float, y:Float, moveX:Bool }> = [];

	public final mapSprites:Array<FlxSprite> = [];
	public final mapSpriteByPart:Map<Int, FlxSprite> = [];
	public final frontSprites:Array<FlxSprite> = [];

	public var darkZone(default, null):Int = -1;

	public final left:Float;
	public final right:Float;
	public final top:Float;
	public final bottom:Float;

	final _state:FlxState;
	final _parts:Array<MapPart>;
	final _fog:Array<WiggleEffect> = [];
	final _pendingFront:Array<{ part:MapPart, layer:MapLayer }> = [];
	final _occluders:Array<Occluder> = [];
	final _fades:Array<Occluder> = [];
	final _near:Array<Occluder> = [];
	final _fx:SkyFX;

	var _occlusionTimer:Float = 0;
	var _cachedOcclusion:Float = 0.0;

	public static function loadParts(count:Int):Array<MapPart>
	{
		final parts:Array<MapPart> = [];
		for (i in 1...count + 1)
		{
			final path = 'assets/shared/data/minigame/thevalley/map/$i.json';
			final raw = Assets.exists(path) ? Assets.getText(path) : null;
			if (raw == null || raw == "") continue;

			final p:MapPart = haxe.Json.parse(raw);
			final art = Paths.image('minigame/thevalley/map/${p.part}/map', false);
			if (art != null)
			{
				p.width = art.width;
				p.height = art.height;
			}
			parts.push(p);
		}
		return parts;
	}

	public function new(state:FlxState, parts:Array<MapPart>)
	{
		_state = state;
		_parts = parts;
		_fx = new SkyFX(state);

		var l = Math.POSITIVE_INFINITY, r = Math.NEGATIVE_INFINITY;
		var t = Math.POSITIVE_INFINITY, b = Math.NEGATIVE_INFINITY;
		for (p in parts)
		{
			l = Math.min(l, p.x);
			r = Math.max(r, p.x + p.width);
			t = Math.min(t, p.y);
			b = Math.max(b, p.y + p.height);
		}
		if (parts.length == 0) l = r = t = b = 0;
		left = l;
		right = r;
		top = t;
		bottom = b;
	}

	public function addSprites():Void
	{
		_addSky();
		_addParallax();

		final sorted = _parts.copy();
		ArraySort.sort(sorted, (a, b) -> (a.zOrder ?? 0) - (b.zOrder ?? 0));
		for (p in sorted)
		{
			final spr = _still(p.x, p.y, Paths.image('minigame/thevalley/map/${p.part}/map', false));
			mapSprites.push(spr);
			mapSpriteByPart.set(p.part, spr);
			_addOccluder(spr);

			if (p.layers != null)
				for (l in p.layers)
				{
					if (l.inFront == true) _pendingFront.push({ part: p, layer: l });
					else _spawnLayer(p, l);
				}
		}
	}

	public function addFrontLayers():Void
	{
		for (entry in _pendingFront)
		{
			final spr = _spawnLayer(entry.part, entry.layer);
			frontSprites.push(spr);
			final o = _addOccluder(spr);
			if (o != null && entry.layer.blackFade == true) _fades.push(o);
		}
		_pendingFront.resize(0);
	}

	public function showFades(on:Bool):Void
	{
		for (f in _fades) f.spr.visible = on;
	}

	public function update(elapsed:Float, ?player:Player):Void
	{
		_fx.update(elapsed);
		for (fx in _fog) fx.update(elapsed);
		if (player == null || _fades.length == 0) return;

		final ease = 1.0 - Math.pow(0.01, elapsed * 2.0);
		for (f in _fades)
		{
			final target = _overlaps(f.spr, player) && _covers(f, player) ? 0.2 : 1.0;
			f.spr.alpha += (target - f.spr.alpha) * ease;
		}
	}

	public function darkness(player:Player):Float
	{
		var best = 0.0;
		darkZone = -1;
		for (i in 0..._fades.length)
		{
			final f = _fades[i];
			if (!_overlaps(f.spr, player)) continue;
			var hits = 0;
			for (gx in 0...5)
				for (gy in 0...5)
					if (f.mask.opaqueAt(f.spr, player.x + player.width * (gx + 0.5) / 5, player.y + player.height * (gy + 0.5) / 5))
						hits++;
			final cover = hits / (5 * 5);
			if (cover > best)
			{
				best = cover;
				darkZone = i;
			}
		}
		return best;
	}

	public function darkZoneAt(x:Float, y:Float):Int
	{
		for (i in 0..._fades.length)
			if (_fades[i].mask.opaqueAt(_fades[i].spr, x, y)) return i;
		return -1;
	}

	public function cutY(x:Float):Float
	{
		var cut = Math.NEGATIVE_INFINITY;
		var before:MapPart = null;
		var after:MapPart = null;
		for (p in _parts)
		{
			if (x >= p.x && x < p.x + p.width) cut = Math.max(cut, p.y + p.height);
			else if (p.x + p.width <= x) { if (before == null || p.x + p.width > before.x + before.width) before = p; }
			else if (after == null || p.x < after.x) after = p;
		}
		if (cut > Math.NEGATIVE_INFINITY) return cut;
		if (before == null) return after == null ? bottom : after.y + after.height;
		if (after == null) return before.y + before.height;
		return Math.min(before.y + before.height, after.y + after.height);
	}

	public function getOcclusionAmount(target:FlxSprite, ?extraSprites:Array<FlxSprite>):Float
	{
		_near.resize(0);
		for (o in _occluders)
			if (_shown(o.spr) && _overlaps(o.spr, target)) _near.push(o);
		if (extraSprites != null)
			for (spr in extraSprites)
				if (_shown(spr) && _overlaps(spr, target))
				{
					final mask = AlphaMask.of(spr);
					if (mask != null) _near.push({ spr: spr, mask: mask });
				}
		if (_near.length == 0) return 0;

		var hits = 0;
		for (i in 0...12)
		{
			final wx = target.x + target.width * (i + 0.5) / 12;
			for (j in 0...12)
			{
				final wy = target.y + target.height * (j + 0.5) / 12;
				for (o in _near)
					if (o.mask.opaqueAt(o.spr, wx, wy)) { hits++; break; }
			}
		}
		return hits / (12 * 12);
	}

	public function getOcclusionAmountThrottled(player:Player, elapsed:Float, ?extraSprites:Array<FlxSprite>):Float
	{
		_occlusionTimer -= elapsed;
		if (_occlusionTimer <= 0)
		{
			_occlusionTimer = 0.05;
			_cachedOcclusion = getOcclusionAmount(player, extraSprites);
		}
		return _cachedOcclusion;
	}

	function _addSky():Void
	{
		eclipse = new FlxSprite(ECLIPSE_X, ECLIPSE_Y);
		eclipse.frames = Paths.getSparrowAtlas('minigame/thevalley/bg/mountain/eclipse');
		eclipse.animation.addByPrefix("idle", "eclipse idle", 3, true);
		eclipse.animation.play("idle");
		_addSkySprite(eclipse);
		_fx.addSky(eclipse, spr ->
		{
			spr.scrollFactor.set(0, 0);
			_sky.push({ spr: spr, x: spr.x, y: spr.y, moveX: true });
			_state.add(spr);
		});

		sun = new FlxSprite(EXTRASUN_X, EXTRASUN_Y, Paths.image('minigame/thevalley/bg/mountain/extra-sun'));
		sun.active = false;
		_addSkySprite(sun);
	}

	function _addSkySprite(spr:FlxSprite):Void
	{
		spr.scrollFactor.set(0, 0);
		spr.scale.set(1.1, 1.1);
		spr.updateHitbox();
		spr.x += FlxG.width * 0.5 - ECLIPSE_DISK_X;
		_sky.push({ spr: spr, x: spr.x, y: spr.y, moveX: true });
		_state.add(spr);
	}

	function _addParallax():Void
	{
		for (l in PARALLAX)
		{
			final bd = new FlxBackdrop(Paths.image('minigame/thevalley/bg/mountain/${l.file}'), FlxAxes.X);
			bd.scrollFactor.set(l.scroll, l.scrollY);
			bd.setPosition(l.x, 290.0 + l.y);
			_sky.push({ spr: bd, x: bd.x, y: bd.y, moveX: false });
			bd.scale.set(1.1, 1.1);

			if (l.wave != null)
			{
				final fx = new WiggleEffect();
				fx.effectType = WiggleEffectType.WAVY;
				fx.waveSpeed = l.wave;
				fx.waveFrequency = 2.5;
				fx.waveAmplitude = 0.008;
				bd.shader = fx.shader;
				_fog.push(fx);
			}

			if (l.drift != null) bd.velocity.x = l.drift;
			else bd.active = false;
			_state.add(bd);
			if (l.file == "5-mountain") _fx.addEmbers();
		}
	}

	public function skyOffset(dx:Float, dy:Float):Void
	{
		for (s in _sky)
		{
			if (s.moveX) s.spr.x = s.x + dx;
			s.spr.y = s.y + dy;
		}
	}

	public function showParallax(on:Bool):Void
	{
		for (s in _sky)
			if (!s.moveX) s.spr.visible = on;
		_fx.showParallax(on);
	}

	public function eclipseOffset(dx:Float, dy:Float):Void
	{
		for (s in _sky)
			if (s.moveX)
			{
				s.spr.x = s.x + dx;
				s.spr.y = s.y + dy;
			}
	}

	function _spawnLayer(p:MapPart, l:MapLayer):FlxSprite
	{
		final x = p.x + (l.x ?? 0.0);
		final y = p.y + (l.y ?? 0.0);
		final key = 'minigame/thevalley/map/${p.part}/${l.file}';
		if (l.animations == null && l.xml == null) return _still(x, y, Paths.image(key, false));

		final spr = new FlxSprite(x, y);
		spr.frames = Paths.getSparrowAtlas(key, false);
		if (l.animations != null)
		{
			for (a in l.animations) spr.animation.addByPrefix(a.name, a.prefix, a.fps ?? 12, a.loop ?? true);
			if (l.animations.length > 0) spr.animation.play(l.animations[0].name);
		}
		_state.add(spr);
		return spr;
	}

	function _still(x:Float, y:Float, graphic:FlxGraphic):FlxSprite
	{
		final spr = new FlxSprite(x, y, graphic);
		spr.active = false;
		_state.add(spr);
		return spr;
	}

	function _addOccluder(spr:FlxSprite):Null<Occluder>
	{
		final mask = AlphaMask.of(spr);
		if (mask == null) return null;
		final o = { spr: spr, mask: mask };
		_occluders.push(o);
		return o;
	}

	function _covers(o:Occluder, player:Player):Bool
	{
		for (fx in FADE_POINTS)
			for (fy in FADE_POINTS)
				if (o.mask.opaqueAt(o.spr, player.x + player.width * fx, player.y + player.height * fy)) return true;
		return false;
	}

	static inline function _shown(spr:FlxSprite):Bool
	{
		return spr != null && spr.visible && spr.alpha > 0;
	}

	static inline function _overlaps(spr:FlxSprite, target:FlxSprite):Bool
	{
		return target.x < spr.x + spr.width && target.x + target.width > spr.x
			&& target.y < spr.y + spr.height && target.y + target.height > spr.y;
	}
}
