package minigames.preymini.map;

import minigames.preymini.map.Shader;
import flixel.graphics.FlxGraphic;
import minigames.preymini.character.monster.FireBee;
import minigames.preymini.character.monster.FireBox;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

typedef ParadeLane = {
	var layer:Int;
	var top:Float;
	var bottom:Float;
	var scale:Float;
	var haze:Array<Float>;
	var rim:Array<Float>;
	var rimAlpha:Float;
}

enum abstract RaiderKind(Int) from Int to Int
{
	var Bird = 0;
	var Bee = 1;
	var Lantern = 2;
	var Rush = 3;
}

class SkyParade
{
	public static final LANES:Array<ParadeLane> = [
		{ layer: 13, top: 362, bottom: 384, scale: 2, haze: [34, 0, 14], rim: [190, 40, 110], rimAlpha: 0.6 },
		{ layer: 9,  top: 396, bottom: 428, scale: 2, haze: [16, 0, 8],  rim: [255, 70, 160], rimAlpha: 0.85 },
		{ layer: 5,  top: 442, bottom: 470, scale: 4, haze: [6, 0, 3],   rim: [255, 90, 170], rimAlpha: 0.85 },
	];

	static final KIND_WEIGHTS:Array<Float> = [38, 32, 18, 12];
	static final FLYER_LANES:Array<Float> = [45, 40, 15];

	public final groups:Array<FlxTypedGroup<FlxSprite>> = [];
	public final shaders:Array<ParadeShader> = [];

	public var onBoom:Float->Float->Void = null;

	public var burning:Bool = false;

	public var crowd:Float = 1;

	public final unit:Float;

	final _velocity:Int->Float;
	final _layerY:Void->Float;
	final _raiders:Array<Raider> = [];
	final _booms:Array<Boom> = [];
	var _calm:Float = 4.5;
	var _wave:Float = 0;
	var _dir:Int = -1;
	var _spawnTimer:Float = 0;
	var _cityTimer:Float = 0;
	var _reveal:Float = 0;
	var _left:Float = 0;
	var _right:Float = 0;
	var _rally:Bool = false;

	public function new(velocity:Int->Float, layerY:Void->Float, unit:Float)
	{
		_velocity = velocity;
		_layerY = layerY;
		this.unit = unit;
		for (lane in LANES)
		{
			groups.push(new FlxTypedGroup<FlxSprite>());
			shaders.push(new ParadeShader(lane.haze, lane.rim, lane.rimAlpha));
		}
	}

	public function groupAfter(layer:Int):Null<FlxTypedGroup<FlxSprite>>
	{
		for (i in 0...LANES.length)
			if (LANES[i].layer == layer) return groups[i];
		return null;
	}

	public function update(elapsed:Float):Void
	{
		_reveal = Math.max(0, _reveal - elapsed / 1.4);
		for (s in shaders) s.setFlash(_reveal * _reveal);

		final cam = FlxG.camera;
		final shift = cam.scroll.x * (0.8);
		_left = cam.viewLeft - shift;
		_right = cam.viewRight - shift;

		if (_wave > 0)
		{
			if (!_rally) _wave -= elapsed;
			_spawnTimer -= elapsed;
			if (_spawnTimer <= 0)
			{
				_spawnTimer = _rally ? FlxG.random.float(0.25, 0.5) : FlxG.random.float(0.8, 1.6) / crowd;
				_spawn(FlxG.random.weightedPick(KIND_WEIGHTS));
			}
			_cityTimer -= elapsed;
			if (_cityTimer <= 0 && (!_rally || burning))
			{
				_cityTimer = _rally ? FlxG.random.float(0.45, 1.1) : FlxG.random.float(3, 6);
				final x = FlxG.random.float(_rally ? _left + (_right - _left) * 0.6 : _left, _right);
				final size = _rally ? FlxG.random.float(1, 1.8) : 1;
				_boom(0, x, FlxG.random.float(392, 410), size * unit / 4);
				if (_rally && onBoom != null) onBoom((x - _left) / (_right - _left) * 2 - 1, size);
			}
			if (_wave <= 0) _calm = FlxG.random.float(5, 9) / crowd;
		}
		else if ((_calm -= elapsed) <= 0)
		{
			_wave = FlxG.random.float(12, 18);
			_dir = FlxG.random.sign();
			_spawnTimer = 0;
			_cityTimer = FlxG.random.float(3, 6);
		}

		var i = _raiders.length;
		while (i-- > 0)
		{
			final r = _raiders[i];
			if (r.age > 45) r.fade = Math.max(0, r.fade - elapsed);
			r.onScreen = r.x > _left && r.x < _right;
			r.update(elapsed, _velocity(LANES[r.lane].layer), _layerY());
			if (r.hasImpact)
			{
				r.hasImpact = false;
				_boom(r.lane, r.impactX, r.impactRow, r.scale);
			}
			if (r.crashed || r.fade <= 0 || r.row > 720 || r.x + r.extent < _left - 240 || r.x - r.extent > _right + 240)
			{
				r.destroy();
				_raiders.splice(i, 1);
			}
		}

		var j = _booms.length;
		while (j-- > 0)
		{
			final b = _booms[j];
			b.update(elapsed, _velocity(LANES[b.lane].layer), _layerY());
			if (b.done)
			{
				b.destroy();
				_booms.splice(j, 1);
			}
		}
	}

	public function strike():Void
	{
		_reveal = ClientPrefs.data.flashing ? 1 : 0.45;
		var attacks = 2;
		for (r in _raiders)
		{
			r.startle = 1;
			if (attacks > 0 && r.onScreen && r.canAttack())
			{
				r.attack();
				attacks--;
			}
		}
		if (_wave > 0 && FlxG.random.bool(50)) _spawn(Rush);
	}

	public function rally(on:Bool):Void
	{
		_rally = on;
		burning = false;
		if (on)
		{
			_dir = 1;
			_wave = Math.max(_wave, 1);
			_spawnTimer = 0;
			_cityTimer = 0.3;
		}
		else
		{
			_wave = 0;
			_calm = 600;
		}
	}

	function _spawn(kind:RaiderKind):Void
	{
		if (_raiders.length >= (_rally ? 14 : Std.int(9 * crowd))) return;

		for (_ in 0...6)
		{
			final lane = _laneFor(kind);
			final l = LANES[lane];
			final row = FlxG.random.float(l.top, l.bottom);
			final v = _velocity(l.layer) + _dir * Raider.cruise(kind) * unit / 4;
			final fromRight = v < 0 || (v == 0 && _dir < 0);
			if (_crowded(lane, row, fromRight ? _right : _left)) continue;

			final r = new Raider(this, kind, lane, row, _dir);
			final jitter = 40 + FlxG.random.float(0, 200);
			r.x = fromRight ? _right + r.extent + jitter : _left - r.extent - jitter;
			r.update(0, 0, _layerY());
			_raiders.push(r);
			return;
		}
	}

	function _laneFor(kind:RaiderKind):Int
	{
		return switch (kind)
		{
			case Lantern: FlxG.random.bool(65) ? 1 : 2;
			case Rush: FlxG.random.bool(60) ? 0 : 1;
			default: FlxG.random.weightedPick(FLYER_LANES);
		}
	}

	function _crowded(lane:Int, row:Float, edge:Float):Bool
	{
		for (r in _raiders)
			if (r.lane == lane && Math.abs(r.row - row) < 14 && Math.abs(r.x - edge) < 260 + r.extent) return true;
		return false;
	}

	function _boom(lane:Int, x:Float, row:Float, scale:Float):Void
	{
		final b = new Boom(this, lane, x, row, scale);
		b.update(0, 0, _layerY());
		_booms.push(b);
	}

	public static function halo():FlxGraphic
	{
		final cached = FlxG.bitmap.get("preymini-skyparade-halo");
		if (cached != null) return cached;

		final c = 16;
		final bmd = new BitmapData(32, 32, true, 0);
		for (py in 0...32)
			for (px in 0...32)
			{
				final d = Math.sqrt(Math.pow(px + 0.5 - c, 2) + Math.pow(py + 0.5 - c, 2)) / c;
				final a = d < 0.38 ? 0.75 : d < 0.68 ? 0.42 : d < 1 ? 0.18 : 0;
				if (a > 0) bmd.setPixel32(px, py, FlxColor.fromRGBFloat(1, 1, 1, a));
			}
		return FlxG.bitmap.add(bmd, false, "preymini-skyparade-halo");
	}
}

private class SkyBits
{
	public final scale:Float;
	final _unit:Float;
	final _group:FlxTypedGroup<FlxSprite>;
	final _shader:ParadeShader;
	final _sprites:Array<FlxSprite> = [];

	public function new(parade:SkyParade, lane:Int, scale:Float)
	{
		this.scale = scale;
		_unit = parade.unit;
		_group = parade.groups[lane];
		_shader = parade.shaders[lane];
	}

	public function destroy():Void
	{
		for (s in _sprites)
		{
			_group.remove(s, true);
			s.destroy();
		}
	}

	function _sprite():FlxSprite
	{
		final s = new FlxSprite();
		s.antialiasing = false;
		s.moves = false;
		s.scrollFactor.set(0.2, 0.6);
		_sprites.push(s);
		return s;
	}

	function _anim(atlas:String, prefix:String, fps:Float, loop:Bool = true):FlxSprite
	{
		final s = _sprite();
		s.frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/" + atlas, null, false);
		s.animation.addByPrefix("play", prefix, fps, loop);
		s.animation.play("play", true, false, loop ? FlxG.random.int(0, s.animation.getByName("play").numFrames - 1) : 0);
		s.scale.set(scale, scale);
		s.shader = _shader;
		_group.add(s);
		return s;
	}

	function _glow(color:FlxColor, size:Float):FlxSprite
	{
		final s = _sprite();
		s.loadGraphic(SkyParade.halo());
		s.origin.set(0, 0);
		s.color = color;
		s.blend = BlendMode.ADD;
		s.scale.set(scale * size, scale * size);
		_group.add(s);
		return s;
	}

	inline function _centerGlow(glow:FlxSprite, cx:Float, cy:Float):Void
	{
		glow.x = cx - 32 / 2 * glow.scale.x;
		glow.y = cy - 32 / 2 * glow.scale.y;
	}
}

private class Raider extends SkyBits
{
	public final kind:RaiderKind;
	public final lane:Int;
	public var x:Float = 0;
	public var row:Float;
	public var extent:Float;
	public var age:Float = 0;
	public var startle:Float = 0;
	public var fade:Float = 1;
	public var onScreen:Bool = false;
	public var crashed:Bool = false;
	public var hasImpact:Bool = false;
	public var impactX:Float = 0;
	public var impactRow:Float = 0;

	final _body:FlxSprite;
	final _fps:Float;
	final _phase:Float;
	var _box:FlxSprite = null;
	var _light:FlxSprite = null;
	var _vx:Float;
	var _vy:Float;
	var _t:Float = 0;
	var _attackAt:Float = -1;
	var _attacked:Bool = false;
	var _diving:Bool = false;
	var _diveRows:Float = 0;
	var _boxFalling:Bool = false;
	var _boxX:Float = 0;
	var _boxRow:Float = 0;
	var _boxVy:Float = 0;
	var _bombRows:Float = 0;
	final _ghosts:Array<FlxSprite> = [];
	final _ghostAge:Array<Float> = [];
	var _ghostTimer:Float = 0;

	public static function cruise(kind:RaiderKind):Float
	{
		return switch (kind)
		{
			case Bird: 190;
			case Bee: 135;
			case Lantern: 95;
			case Rush: 1300;
		}
	}

	public function new(parade:SkyParade, kind:RaiderKind, lane:Int, row:Float, dir:Int)
	{
		super(parade, lane, SkyParade.LANES[lane].scale * parade.unit / 4);
		this.kind = kind;
		this.lane = lane;
		this.row = row;
		_phase = FlxG.random.float(0, Math.PI * 2);

		switch (kind)
		{
			case Bird:
				_fps = 10;
				_body = _anim("Badnik_1", "Badnik_1", _fps);
				_vx = FlxG.random.float(160, 220);
				_vy = FlxG.random.float(0, 10);
				if (FlxG.random.bool(35)) _attackAt = FlxG.random.float(2, 6);
			case Bee:
				_fps = 12;
				_body = _anim("Badnik_2", "Badnik_2", _fps);
				_vx = FlxG.random.float(110, 160);
				_vy = FlxG.random.float(0, 10);
			case Lantern:
				_fps = 12;
				_light = _glow(0xFFFF6E14, 2.6);
				_body = _anim("Badnik_2", "Badnik_2", _fps);
				_box = _anim("Fire_Box", "box", 10);
				_box.origin.set(0, 0);
				_vx = FlxG.random.float(80, 110);
				_vy = FlxG.random.float(0, 6);
				if (FlxG.random.bool(60)) _attackAt = FlxG.random.float(2, 6);
			case Rush:
				_fps = 20;
				_light = _glow(0xFFFF7820, 1.3);
				_body = _anim("Badnik_3", "Badnik_3", _fps);
				_vx = FlxG.random.float(1100, 1500);
				_vy = FlxG.random.float(60, 140);
		}
		_vx *= dir * _unit / 4;
		_body.flipX = dir > 0;
		extent = (_body.frameWidth / 2 + (kind == Lantern ? 20 : 0)) * scale;
	}

	public inline function canAttack():Bool
	{
		return !_attacked && (kind == Bird || (kind == Lantern && _box != null));
	}

	public function attack():Void
	{
		_attacked = true;
		_attackAt = -1;
		if (kind == Bird) _diving = true;
		else if (kind == Lantern) _boxFalling = true;
	}

	public function update(elapsed:Float, scrollVx:Float, layerY:Float):Void
	{
		age += elapsed;
		startle = Math.max(0, startle - elapsed / 1.6);
		_t += elapsed * (1 + startle);
		if (_attackAt >= 0 && age >= _attackAt && onScreen) attack();

		if (_diving)
		{
			_vy = Math.min(320, _vy + 500 * elapsed);
			_diveRows += _vy * elapsed / 4;
		}
		final rush = kind == Rush ? 0 : (kind == Lantern ? 0.3 : 0.7);
		x += (scrollVx + _vx * (_diving ? 0.6 : 1) * (1 + rush * startle)) * elapsed;
		row += _vy * elapsed / 4;

		final bob = _diving || kind == Rush ? 0 : Math.sin(_t * 2.4 + _phase) * 3;
		final cy = layerY + row * _unit + bob * scale;
		_body.x = x - _body.frameWidth / 2;
		_body.y = cy - _body.frameHeight / 2;
		_body.angle = _diving ? (_body.flipX ? 1 : -1) * 40 * _vy / 320 : 0;
		_body.alpha = fade;
		if (_body.animation.curAnim != null) _body.animation.curAnim.frameRate = _fps * (1 + startle);

		switch (kind)
		{
			case Lantern: _placeLantern(elapsed, scrollVx, layerY, cy);
			case Rush: _placeRush(elapsed);
			default:
		}

		if (_diving && _diveRows >= 36) _impact(x, row + _body.frameHeight / 2 * scale / _unit, true);
	}

	function _placeLantern(elapsed:Float, scrollVx:Float, layerY:Float, cy:Float):Void
	{
		if (_box == null) return;

		if (_boxFalling)
		{
			_boxVy += 600 * elapsed;
			_boxX += (scrollVx + _vx * 0.5) * elapsed;
			final fall = _boxVy * elapsed / 4;
			_boxRow += fall;
			_bombRows += fall;
			_box.x = _boxX - (99.5) * scale;
			_box.y = layerY + _boxRow * _unit - (61.5) * scale;
			_centerGlow(_light, _boxX, layerY + _boxRow * _unit);
		}
		else
		{
			final left = x - _body.frameWidth / 2 * scale;
			final top = cy - _body.frameHeight / 2 * scale;
			final boxAt = _body.flipX ? _body.frameWidth - 26 - 33 : 26;
			final hold = FireBee.BOX_AT_Y[_body.animation.curAnim.curFrame % FireBee.BOX_AT_Y.length];
			_box.x = left + (boxAt - 83) * scale;
			_box.y = top + (hold - 46) * scale;
			_boxX = left + (boxAt + 16.5) * scale;
			_boxRow = (top + (hold + 15.5) * scale - layerY) / _unit;
			_centerGlow(_light, _boxX, top + (hold + 15.5) * scale);
		}

		final flicker = 0.42 + 0.1 * Math.sin(age * 13 + _phase) + 0.06 * Math.sin(age * 29 + _phase * 2);
		_light.alpha = Math.min(1, flicker * (1 + 0.9 * startle)) * fade;
		_box.alpha = fade;

		if (_boxFalling && _bombRows >= 30)
		{
			_impact(_boxX, _boxRow + 15.5 * scale / _unit, false);
			_box.visible = _light.visible = false;
			_box = null;
			_boxFalling = false;
		}
	}

	function _placeRush(elapsed:Float):Void
	{
		_centerGlow(_light, _body.x + _body.frameWidth / 2, _body.y + _body.frameHeight / 2);
		_light.alpha = 0.5 * fade;

		for (i in 0..._ghosts.length)
		{
			if (!_ghosts[i].visible) continue;
			_ghostAge[i] += elapsed;
			_ghosts[i].alpha = 0.55 * Math.max(0, 1 - _ghostAge[i] / 0.3) * fade;
			if (_ghostAge[i] >= 0.3) _ghosts[i].visible = false;
		}

		_ghostTimer += elapsed;
		if (elapsed <= 0 || _ghostTimer < 0.03) return;
		_ghostTimer = 0;

		var i = _ghosts.length;
		for (j in 0..._ghosts.length)
			if (!_ghosts[j].visible)
			{
				i = j;
				break;
			}
		if (i == _ghosts.length)
		{
			final g = _sprite();
			g.frames = _body.frames;
			g.scale.set(scale, scale);
			g.color = 0xFFFF5A14;
			g.blend = BlendMode.ADD;
			_group.insert(0, g);
			_ghosts.push(g);
			_ghostAge.push(0);
		}
		final g = _ghosts[i];
		g.visible = true;
		g.animation.frameIndex = _body.animation.frameIndex;
		g.setPosition(_body.x, _body.y);
		g.alpha = 0.55 * fade;
		_ghostAge[i] = 0;
	}

	function _impact(atX:Float, atRow:Float, crash:Bool):Void
	{
		hasImpact = true;
		impactX = atX;
		impactRow = atRow;
		if (crash) crashed = true;
	}
}

private class Boom extends SkyBits
{
	public final lane:Int;
	public var done(default, null):Bool = false;

	final _fire:FlxSprite;
	final _flash:FlxSprite;
	final _row:Float;
	var _x:Float;
	var _t:Float = 0;

	public function new(parade:SkyParade, lane:Int, x:Float, row:Float, scale:Float)
	{
		super(parade, lane, scale);
		this.lane = lane;
		_x = x;
		_row = row;
		_flash = _glow(0xFFFFA040, 3);
		_fire = _anim("Fire_Box", "explosion", 14, false);
		_fire.origin.set(0, 0);
	}

	public function update(elapsed:Float, scrollVx:Float, layerY:Float):Void
	{
		_t += elapsed;
		_x += scrollVx * elapsed;
		final ground = layerY + _row * _unit;
		_fire.x = _x - 100 * scale;
		_fire.y = ground - 79 * scale;

		final k = Math.max(0, 1 - _t / 0.6);
		final size = scale * (3 + 2 * _t);
		_flash.scale.set(size, size);
		_flash.alpha = 0.9 * k;
		_centerGlow(_flash, _x, ground - 20 * scale);

		if (_fire.animation.finished) _fire.visible = false;
		done = !_fire.visible && k <= 0;
	}
}
