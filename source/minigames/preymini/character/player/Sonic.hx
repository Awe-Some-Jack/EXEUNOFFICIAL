package minigames.preymini.character.player;

import minigames.CameraTarget;
import minigames.preymini.map.Terrain;

class Sonic extends FlxSprite implements CameraTarget
{
	static final OUTTA_FRAMES:Array<Int> = [0, 1, 1, 2, 2, 3, 3, 4, 4, 1, 1, 2, 2, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 11];

	static final DX:Array<Int> = [0, 1, 0, -1];
	static final DY:Array<Int> = [1, 0, -1, 0];

	static final ANIMS:Array<{ name:String, fps:Int, loop:Bool }> = [
		{ name: "idle",            fps: 1,  loop: true },
		{ name: "bored-loop",      fps: 2,  loop: true },
		{ name: "up",              fps: 1,  loop: true },
		{ name: "down",            fps: 1,  loop: true },
		{ name: "walkNon",         fps: 10, loop: true },
		{ name: "walkAngled",      fps: 10, loop: true },
		{ name: "baserunNon",      fps: 14, loop: true },
		{ name: "baserunAngled",   fps: 14, loop: true },
		{ name: "peelout",         fps: 20, loop: true },
		{ name: "peeloutAngled",   fps: 20, loop: true },
		{ name: "jump",            fps: 16, loop: true },
		{ name: "spindash",        fps: 22, loop: true },
		{ name: "skid",            fps: 8,  loop: false },
		{ name: "push",            fps: 6,  loop: true },
		{ name: "balance-forward", fps: 8,  loop: true },
		{ name: "balance-back",    fps: 8,  loop: true },
		{ name: "hit",             fps: 1,  loop: false },
		{ name: "death",           fps: 1,  loop: false },
		{ name: "timetravel",      fps: 12, loop: true },
	];

	public var controllable:Bool = true;

	public var autoDir:Int = 0;

	public var anchored:Bool = false;
	public var anchorX:Float = 0;

	public final terrain:Terrain;

	public var posX(default, null):Float = 0;
	public var posY(default, null):Float = 0;

	public var grounded(default, null):Bool = true;
	public var rolling(default, null):Bool = false;
	public var crouching(default, null):Bool = false;

	public var jumping(get, never):Bool;
	inline function get_jumping() return !grounded && _jumped;

	public var spinDashing(default, null):Bool = false;

	public var rev(default, null):Float = 0;

	public var peelingOut(default, null):Bool = false;

	public var edge(default, null):Int = 0;

	public var dead(default, null):Bool = false;

	public var leaving(default, null):Bool = false;

	public var grabbed(default, null):Bool = false;

	public var hurting(default, null):Bool = false;

	public var attacking(get, never):Bool;
	inline function get_attacking() return _curled && !dead && !leaving && !grabbed && !hurting;

	public var invulnerable(get, never):Bool;
	inline function get_invulnerable() return _invulnerable > 0;

	public var groundAngle(default, null):Float = 0;

	public var mode(default, null):Int = 0;

	public var layer(default, null):Int = 0;

	public var speed(get, never):Float;
	inline function get_speed() return (grounded ? _gsp : _xsp) * 6 * 60;

	public var speedX(get, never):Float;
	inline function get_speedX() return _xsp * 6 * 60;

	var _gsp:Float = 0;
	var _xsp:Float = 0;
	var _revSound:FlxSound = null;
	var _chargeSound:FlxSound = null;
	var _ysp:Float = 0;
	var _curled:Bool = false;
	var _jumped:Bool = false;
	var _skidding:Bool = false;
	var _pushing:Bool = false;
	var _lock:Int = 0;
	var _coyote:Int = 0;
	var _buffer:Int = 0;
	var _still:Float = 0;
	var _jumpQueued:Bool = false;
	var _squash:Float = 0;
	var _acc:Float = 0;
	var _leaveTime:Float = 0;
	var _presses:Int = 0;
	var _invulnerable:Float = 0;
	var _peel:Float = 0;
	var _peelTime:Int = 0;
	var _hitX:Float = 0;
	var _hitY:Float = 0;

	public function new(terrain:Terrain, artX:Float)
	{
		super();
		this.terrain = terrain;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/sonic/sonic");
		for (a in ANIMS) animation.addByPrefix(a.name, a.name + "0", a.fps, a.loop);
		animation.addByNames("bored", ["bored0001", "bored0000", "bored0000", "bored0000", "bored-loop0000", "bored-loop0001"], 2.5, false);
		animation.addByNames("outtahere", [for (i in OUTTA_FRAMES) 'outtahere${StringTools.lpad(Std.string(i), "0", 4)}'], 12, false);
		animation.addByNames("outtahere-loop", ["outtahere0010", "outtahere0011"], 12, true);
		animation.play("idle");

		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		updateHitbox();
		origin.set(29.5, 32);
		offset.set(0, 0);

		placeAt(artX);
	}

	public function placeAt(artX:Float, fromY:Int = 0):Void
	{
		posX = artX;
		posY = Math.max(0, terrain.topAt(Math.floor(artX), fromY)) - 19;
		_gsp = _xsp = _ysp = 0;
		grounded = true;
		groundAngle = 0;
		mode = layer = 0;
		rolling = crouching = spinDashing = peelingOut = dead = leaving = grabbed = hurting = _curled = _jumped = _skidding = _pushing = false;
		_invulnerable = 0;
		visible = true;
		edge = 0;
		_still = _leaveTime = 0;
		_lock = _coyote = _buffer = _peelTime = 0;
		_peel = 0;
		_place();
	}

	public var hitRadiusX(get, never):Float;
	inline function get_hitRadiusX() return 8;
	public var hitRadiusY(get, never):Float;
	inline function get_hitRadiusY() return _heightR() - 3;

	public function cameraX():Float return anchored ? anchorX : terrain.worldX(posX);

	public function cameraY():Float
	{
		final dip = grounded && _curled && mode == 0 ? 5 : 0;
		return terrain.worldY(posY - dip);
	}

	public function cameraGrounded():Bool return grounded && mode == 0 && Math.abs(groundAngle) < 0.2;

	public function cameraSpeed():Float return (grounded ? _gsp : _xsp) / 6;

	public function cameraCanLook():Bool return grounded && _gsp == 0 && mode == 0 && controllable && !peelingOut && edge == 0;

	override public function update(elapsed:Float):Void
	{
		final c = Controls.instance;
		final on = controllable && !dead && !leaving;
		final dir = !on ? (dead || leaving ? 0 : autoDir) : (c.UI_RIGHT ? 1 : 0) - (c.UI_LEFT ? 1 : 0);
		final down = on && c.UI_DOWN;
		final up = on && c.UI_UP;
		final held = on && c.JUMP;
		final tap = on && c.JUMP_P;

		if (grabbed)
		{
			_jumpQueued = false;
			if (on) _presses += (tap ? 1 : 0) + (c.UI_LEFT_P ? 1 : 0) + (c.UI_RIGHT_P ? 1 : 0);
			_place();
			_animate(elapsed, 0, false);
			super.update(elapsed);
			return;
		}

		_jumpQueued = on && (_jumpQueued || tap);
		_acc = Math.min(_acc + elapsed, (1 / 60) * 4);
		while (_acc > (1 / 60) * 0.5)
		{
			_acc -= 1 / 60;
			_step(dir, down, up, held, _jumpQueued);
			if (!dead && !leaving) _keepInside();
			_jumpQueued = false;
			if (_invulnerable > 0) _invulnerable--;
		}
		visible = dead || leaving || _invulnerable <= 0 || Std.int(_invulnerable / 4) % 2 == 0;

		_place();
		_animate(elapsed, dir, up);
		super.update(elapsed);
	}

	function _step(dir:Int, down:Bool, up:Bool, held:Bool, pressed:Bool):Void
	{
		if (dead || leaving)
		{
			_fallOut();
			return;
		}
		if (hurting)
		{
			_air(0, false);
			return;
		}
		_buffer = pressed ? 7 : Std.int(Math.max(0, _buffer - 1));
		if (grounded)
		{
			if (_spinDash(down, pressed) || _peelOut(up, pressed)) return;
			if (_buffer <= 0)
			{
				_ground(dir, down);
				return;
			}
			_jump();
		}
		else if (_buffer > 0 && _coyote > 0) _jump();
		_air(dir, held);
	}

	function _keepInside():Void
	{
		if (terrain.repeat) return;
		final lo = 16, hi = terrain.width - 16;
		if (posX >= lo && posX <= hi) return;
		posX = posX < lo ? lo : hi;
		_gsp = _xsp = 0;
	}

	function _jump():Void
	{
		if (grounded)
		{
			final sin = Math.sin(groundAngle), cos = Math.cos(groundAngle);
			_xsp = _gsp * cos + 6.5 * sin;
			_ysp = _gsp * sin - 6.5 * cos;
		}
		else _ysp = -6.5;
		_leaveGround();
		_curled = true;
		rolling = crouching = _skidding = false;
		_jumped = true;
		_buffer = _coyote = 0;
		_sfx("jump");
	}

	function _ground(dir:Int, down:Bool):Void
	{
		if (_lock > 0)
		{
			_lock--;
			dir = 0;
		}

		edge = _gsp == 0 && mode == 0 && !rolling && !crouching && !_curled ? _edgeSide() : 0;

		if (down && !rolling && !crouching)
		{
			if (Math.abs(_gsp) >= 1.03125)
			{
				rolling = true;
				_curl(true);
			}
			else if (mode == 0 && edge == 0) crouching = true;
		}
		if (!down) crouching = false;

		final sin = Math.sin(groundAngle);
		if (rolling) _gsp += (_gsp * sin >= 0 ? 0.3125 : 0.078125) * sin;
		else if (!crouching && (_gsp != 0 || Math.abs(0.125 * sin) >= 0.05078125)) _gsp += 0.125 * sin;

		if (rolling)
		{
			if (dir != 0 && dir * _gsp < 0) _gsp = _toward(_gsp, 0, 0.125);
			_gsp = _toward(_gsp, 0, 0.0234375);
			if (Math.abs(_gsp) < 0.5 && mode == 0)
			{
				rolling = false;
				_curl(false);
			}
			_skidding = false;
		}
		else if (crouching) _gsp = _toward(_gsp, 0, 0.046875);
		else if (dir != 0 && dir * _gsp < 0)
		{
			if (!_skidding && Math.abs(_gsp) >= 4 && mode == 0)
			{
				_skidding = true;
				_sfx("skid");
			}
			_gsp = _toward(_gsp, 0, 0.5);
			if (_gsp == 0) _skidding = false;
		}
		else if (dir != 0)
		{
			_skidding = false;
			if (dir * _gsp < 6) _gsp = _toward(_gsp, dir * 6, 0.046875);
		}
		else
		{
			_gsp = _toward(_gsp, 0, 0.046875);
			if (Math.abs(_gsp) < 4) _skidding = false;
		}
		_gsp = Math.max(-16, Math.min(16, _gsp));
		_pushing = false;
		_moveOnGround();
	}

	function _moveOnGround():Void
	{
		final steps = Std.int(Math.max(1, Math.ceil(Math.abs(_gsp) / 8)));
		for (_ in 0...steps)
		{
			final cos = Math.cos(groundAngle), sin = Math.sin(groundAngle);
			var mx = _gsp * cos / steps, my = _gsp * sin / steps;

			if (_gsp != 0)
			{
				final d = _gsp > 0 ? (mode + 1) % 4 : (mode + 3) % 4;
				final low = mode == 0 && groundAngle == 0 ? 8 : 0;
				final dist = _probe(posX + mx + DX[d] * 10 + DX[mode] * low, posY + my + DY[d] * 10 + DY[mode] * low, d, false);
				if (!Math.isNaN(dist) && dist < 0)
				{
					mx += DX[d] * dist;
					my += DY[d] * dist;
					_gsp = 0;
					_pushing = true;
				}
			}
			posX += mx;
			posY += my;
			_xsp = _gsp * cos;
			_ysp = _gsp * sin;

			if (!_stickToFloor(Math.min(Math.abs(_gsp) / steps + 4, 14)))
			{
				_leaveGround();
				_coyote = 5;
				return;
			}
			if (_gsp == 0) break;
		}

		if (mode != 0 && Math.abs(_gsp) < 2.5)
		{
			_xsp = _gsp * Math.cos(groundAngle);
			_ysp = _gsp * Math.sin(groundAngle);
			_leaveGround();
			_lock = 30;
			return;
		}
		_switchPath();
	}

	function _stickToFloor(tolerance:Float):Bool
	{
		final d = mode, s = (mode + 1) % 4;
		final w = _widthR(), h = _heightR();
		final platforms = mode == 0;
		final da = _probe(posX - DX[s] * w + DX[d] * h, posY - DY[s] * w + DY[d] * h, d, platforms);
		final ax = _hitX, ay = _hitY;
		final db = _probe(posX + DX[s] * w + DX[d] * h, posY + DY[s] * w + DY[d] * h, d, platforms);
		final bx = _hitX, by = _hitY;

		final okA = !Math.isNaN(da) && da >= -14 && da <= tolerance;
		final okB = !Math.isNaN(db) && db >= -14 && db <= tolerance;
		if (!okA && !okB)
		{
			return (!Math.isNaN(da) && da < -14) || (!Math.isNaN(db) && db < -14);
		}
		final useA = okA && (!okB || da <= db);
		final dist = useA ? da : db;
		posX += DX[d] * dist;
		posY += DY[d] * dist;
		groundAngle = _surfaceAngle(useA ? ax : bx, useA ? ay : by, d, platforms, -mode * Math.PI / 2);
		mode = _modeOf(groundAngle);
		return true;
	}

	function _surfaceAngle(hx:Float, hy:Float, d:Int, platforms:Bool, fallback:Float):Float
	{
		final s = (d + 1) % 4;
		final dm = _probe(hx - DX[s] * 6, hy - DY[s] * 6, d, platforms);
		final mx = _hitX, my = _hitY;
		final dp = _probe(hx + DX[s] * 6, hy + DY[s] * 6, d, platforms);
		final px = _hitX, py = _hitY;
		final okM = !Math.isNaN(dm) && Math.abs(dm) <= 6 * 4;
		final okP = !Math.isNaN(dp) && Math.abs(dp) <= 6 * 4;
		if (okM && okP) return Math.atan2(py - my, px - mx);
		if (okP) return Math.atan2(py - hy, px - hx);
		if (okM) return Math.atan2(hy - my, hx - mx);
		return _wrap(fallback);
	}

	function _air(dir:Int, held:Bool):Void
	{
		if (_coyote > 0) _coyote--;

		if (_jumped && _ysp < -4 && !held) _ysp = -4;
		if (dir != 0 && dir * _xsp < 6) _xsp = _toward(_xsp, dir * 6, 0.09375);
		if (_ysp < 0 && _ysp > -4 && Math.abs(_xsp) >= 0.125) _xsp -= _xsp * (1 / 32);

		final steps = Std.int(Math.max(1, Math.ceil(Math.max(Math.abs(_xsp), Math.abs(_ysp)) / 8)));
		for (_ in 0...steps)
		{
			posX += _xsp / steps;
			posY += _ysp / steps;
			if (_airCollide()) return;
		}
		_ysp = Math.min(_ysp + (hurting ? 0.1875 : 0.21875), 16);
		_switchPath();
	}

	public function knockBack(fromX:Float):Void
	{
		if (dead || leaving || grabbed || hurting || invulnerable) return;
		final keepAnchor = anchored;
		_stopEverything();
		anchored = keepAnchor;
		hurting = true;
		_xsp = fromX <= posX ? 2 : -2;
		_ysp = -4;
		_invulnerable = 120;
		animation.play("hit", true);
	}

	public function rebound(fromX:Float):Void
	{
		if (dead || leaving || grabbed || hurting) return;
		_leaveGround();
		_xsp = fromX <= posX ? 3 : -3;
		_ysp = -4;
		_curled = true;
		rolling = false;
		_jumped = true;
	}

	public function bounceOff(enemyY:Float):Void
	{
		if (grounded) return;
		if (_ysp >= 0)
		{
			if (posY < enemyY) _ysp = -_ysp;
			else _ysp -= 1;
		}
		else _ysp += 1;
	}

	function _airCollide():Bool
	{
		for (d in 0...2)
		{
			final side = d == 0 ? 1 : 3;
			final dist = _probe(posX + DX[side] * 10, posY, side, false);
			if (!Math.isNaN(dist) && dist < 0)
			{
				posX += DX[side] * dist;
				if (_xsp * DX[side] > 0) _xsp = 0;
			}
		}

		final w = _widthR(), h = _heightR();
		if (_ysp < 0)
		{
			final da = _probe(posX - w, posY - h, 2, false), db = _probe(posX + w, posY - h, 2, false);
			final dist = Math.min(Math.isNaN(da) ? 0 : da, Math.isNaN(db) ? 0 : db);
			if (dist < 0)
			{
				posY -= dist;
				_ysp = 0;
			}
			return false;
		}

		final da = _probe(posX - w, posY + h, 0, true);
		final ax = _hitX, ay = _hitY;
		final db = _probe(posX + w, posY + h, 0, true);
		final bx = _hitX, by = _hitY;
		final deepest = -(_ysp + 8);
		final okA = !Math.isNaN(da) && da <= 0 && da >= deepest;
		final okB = !Math.isNaN(db) && db <= 0 && db >= deepest;
		if (!okA && !okB) return false;

		final useA = okA && (!okB || da <= db);
		posY += useA ? da : db;
		groundAngle = _surfaceAngle(useA ? ax : bx, useA ? ay : by, 0, true, 0);
		mode = _modeOf(groundAngle);
		_gsp = _xsp * Math.cos(groundAngle) + _ysp * Math.sin(groundAngle);
		grounded = true;
		_jumped = rolling = false;
		_curl(false);
		if (hurting)
		{
			hurting = false;
			_gsp = _xsp = 0;
		}
		return true;
	}

	function _spinDash(down:Bool, tap:Bool):Bool
	{
		if (!spinDashing)
		{
			if (!crouching || !tap) return false;
			spinDashing = true;
			rev = 0;
			_buffer = 0;
			_squash = 0.1;
			_curl(true);
			_rev();
			return true;
		}

		if (!down)
		{
			spinDashing = crouching = false;
			rolling = true;
			_gsp = (flipX ? -1 : 1) * (8 + Std.int(rev) / 2);
			rev = 0;
			_stopCharge();
			_sfx("spindashgo");
			return true;
		}

		if (tap)
		{
			rev = Math.min(8, rev + 2);
			_squash = 0.1;
			_buffer = 0;
			_rev();
		}
		rev -= rev * (1 / 32);
		_gsp = 0;
		return true;
	}

	function _peelOut(up:Bool, tap:Bool):Bool
	{
		if (!peelingOut)
		{
			if (!up || !tap || _gsp != 0 || mode != 0 || crouching || rolling || _curled || edge != 0) return false;
			peelingOut = true;
			_peel = 0;
			_peelTime = 1;
			_buffer = 0;
			_chargeSound ??= FlxG.sound.load(Paths.sound("minigame/preymini/peeloutcharge"));
			_chargeSound.play(true);
			return true;
		}

		_peelTime = Std.int(Math.min(30, _peelTime + 1));
		_buffer = 0;
		if (up)
		{
			_peel = Math.min(12, _peel + (100 / 256));
			return true;
		}

		peelingOut = false;
		_stopCharge();
		if (_peelTime >= 30) _sfx("peeloutgo");
		_gsp = _peelTime >= 30 ? (flipX ? -_peel : _peel) : 0;
		_peel = 0;
		return false;
	}

	function _leaveGround():Void
	{
		grounded = false;
		groundAngle = 0;
		mode = 0;
		crouching = _skidding = _pushing = spinDashing = peelingOut = false;
		edge = 0;
		_peel = 0;
		_stopCharge();
	}

	function _rev():Void
	{
		_revSound ??= FlxG.sound.load(Paths.sound("minigame/preymini/spindash"));
		#if FLX_PITCH
		_revSound.pitch = 1 + rev / 8 * 0.4;
		#end
		_revSound.play(true);
	}

	function _stopCharge():Void
	{
		if (_revSound != null) _revSound.stop();
		if (_chargeSound != null) _chargeSound.stop();
	}

	function _sfx(name:String):Void
	{
		FlxG.sound.play(Paths.sound('minigame/preymini/$name'));
	}

	public function die():Void
	{
		if (dead) return;
		_stopEverything();
		dead = true;
		_ysp = -7;
		animation.play("death", true);
	}

	function _goAway():Void
	{
		_stopEverything();
		leaving = true;
		_leaveTime = 0;
		animation.play("outtahere", true);
		_sfx("outtahere");
	}

	public function grab():Void
	{
		if (dead || leaving) return;
		final keepAnchor = anchored;
		_stopEverything();
		anchored = keepAnchor;
		grabbed = true;
		_presses = 0;
		animation.play("hit", true);
	}

	public function hangAt(x:Float, y:Float):Void
	{
		if (!grabbed) return;
		posX = x;
		posY = y;
	}

	public function release(ysp:Float):Void
	{
		if (!grabbed) return;
		grabbed = false;
		_ysp = ysp;
		_xsp = 0;
		_coyote = 0;
		_invulnerable = 120;
	}

	public function struggles():Int
	{
		final n = _presses;
		_presses = 0;
		return n;
	}

	function _stopEverything():Void
	{
		_stopCharge();
		grounded = rolling = crouching = spinDashing = peelingOut = grabbed = hurting = _skidding = _pushing = _jumped = false;
		_curled = false;
		edge = 0;
		groundAngle = 0;
		mode = 0;
		_gsp = _xsp = _ysp = 0;
		_peel = 0;
		anchored = false;
	}

	function _fallOut():Void
	{
		if (leaving && _ysp == 0 && _xsp == 0)
		{
			if (_leaveTime < 29 / 12) return;
			_xsp = flipX ? -1 : 1;
			_ysp = -5;
		}
		posX += _xsp;
		posY += _ysp;
		_ysp = Math.min(_ysp + 0.21875, 16);
	}

	function _edgeSide():Int
	{
		final floorY = posY + 19;
		if (_hasFloor(posX, floorY)) return 0;
		final left = _hasFloor(posX - 9, floorY), right = _hasFloor(posX + 9, floorY);
		return left && !right ? 1 : right && !left ? -1 : 0;
	}

	inline function _hasFloor(x:Float, y:Float):Bool
	{
		final dist = _probe(x, y, 0, true);
		return !Math.isNaN(dist) && dist < 12;
	}

	function _curl(on:Bool):Void
	{
		if (_curled == on) return;
		_curled = on;
		if (!grounded) return;
		final d = (5) * (on ? 1 : -1);
		posX += DX[mode] * d;
		posY += DY[mode] * d;
	}

	function _switchPath():Void
	{
		switch (terrain.kind(Math.floor(posX), Math.floor(posY)))
		{
			case Switch: if (_xsp != 0) layer = _xsp > 0 ? 0 : 1;
			case LaneA: layer = 0;
			case LaneB: layer = 1;
			default:
		}
	}

	function _probe(sx:Float, sy:Float, d:Int, platforms:Bool):Float
	{
		final dx = DX[d], dy = DY[d];
		var cx = Math.floor(sx), cy = Math.floor(sy);
		var n = 0;
		if (_solid(cx, cy, platforms))
		{
			while (_solid(cx - dx, cy - dy, platforms))
			{
				cx -= dx;
				cy -= dy;
				if (++n >= 32) return Math.NaN;
			}
		}
		else
		{
			do
			{
				cx += dx;
				cy += dy;
				if (++n > 32) return Math.NaN;
			}
			while (!_solid(cx, cy, platforms));
		}
		if (dx != 0)
		{
			_hitX = dx > 0 ? cx : cx + 1;
			_hitY = sy;
			return (_hitX - sx) * dx;
		}
		_hitX = sx;
		_hitY = dy > 0 ? cy : cy + 1;
		return (_hitY - sy) * dy;
	}

	inline function _solid(cx:Int, cy:Int, platforms:Bool):Bool
	{
		return switch (terrain.kind(cx, cy))
		{
			case Solid: true;
			case Platform: platforms;
			case PathA: layer == 0;
			case PathB: layer == 1;
			default: false;
		}
	}

	inline function _widthR():Float return _curled ? 7 : 9;
	inline function _heightR():Float return _curled ? 14 : 19;

	static inline function _modeOf(angle:Float):Int
	{
		final m = Math.round(-angle / (Math.PI / 2)) % 4;
		return m < 0 ? m + 4 : m;
	}

	static function _wrap(angle:Float):Float
	{
		while (angle <= -Math.PI) angle += Math.PI * 2;
		while (angle > Math.PI) angle -= Math.PI * 2;
		return angle;
	}

	public inline function place():Void _place();

	function _place():Void
	{
		x = terrain.worldX(posX) - 29.5;
		y = terrain.worldY(posY) - 32;
	}

	function _animate(elapsed:Float, dir:Int, up:Bool):Void
	{
		final moving = grounded ? _gsp : _xsp;

		if (moving != 0 && !_skidding) flipX = moving < 0;
		else if (moving == 0 && dir != 0 && !spinDashing && !peelingOut) flipX = dir < 0;

		_squash = Math.max(0, _squash - elapsed);
		scale.x = 6 * (1 + 0.12 * _squash / 0.1);

		final s = Math.abs(moving);
		final still = grounded && s == 0 && !crouching && !rolling && !up && edge == 0 && !peelingOut && !spinDashing;
		_still = still ? _still + elapsed : 0;
		if (_still >= 180 && !leaving && !dead) _goAway();

		final tilt = grounded && !_curled ? Math.round(groundAngle * 180 / Math.PI / 45) : 0;
		angle = tilt * 45;

		if (dead) _play("death", 1);
		else if (grabbed || hurting) _play("hit", 1);
		else if (leaving)
		{
			_leaveTime += elapsed;
			if (animation.name == "outtahere" && animation.finished) _play("outtahere-loop", 12);
		}
		else if (spinDashing) _play("spindash", 22 + Std.int(rev / 8 * 18));
		else if (peelingOut) _runAt(_peel, tilt);
		else if (!grounded && _jumped || _curled) _play("jump", 16 + Std.int(Math.min(1, s / 6) * 10));
		else if (!grounded) {}
		else if (_pushing && dir != 0) _play("push", 6);
		else if (_skidding) _play("skid", 8);
		else if (crouching) _play("down", 1);
		else if (edge != 0) _play(edge == (flipX ? -1 : 1) ? "balance-forward" : "balance-back", 3.75);
		else if (s == 0 && up) _play("up", 1);
		else if (s == 0) _bored();
		else _runAt(s, tilt);

		if (!grounded || dead || leaving || grabbed || hurting) angle = 0;
	}

	function _runAt(speed:Float, tilt:Int):Void
	{
		final fps = Std.int(60 / (Math.max(0, Math.floor(8 - speed)) + 1));
		if (speed >= 10) _run("peelout", "peeloutAngled", tilt, fps);
		else if (speed >= 6) _run("baserunNon", "baserunAngled", tilt, fps);
		else _run("walkNon", "walkAngled", tilt, fps);
	}

	function _run(straight:String, angled:String, tilt:Int, fps:Int):Void
	{
		final diagonal = tilt % 2 != 0;
		final name = diagonal ? angled : straight;
		if (diagonal) angle = tilt * 45 + (flipX ? -45 : 45);
		final other = diagonal ? straight : angled;
		if (animation.name == other && animation.curAnim != null)
		{
			final frame = animation.curAnim.curFrame;
			animation.play(name, true, false, frame % animation.getByName(name).numFrames);
		}
		_play(name, fps);
	}

	function _bored():Void
	{
		if (_still < 4.8) _play("idle", 1);
		else if (animation.name != "bored" && animation.name != "bored-loop") _play("bored", 2.5);
		else if (animation.name == "bored" && animation.finished) _play("bored-loop", 2.5);
	}

	function _play(name:String, fps:Float):Void
	{
		if (animation.name != name) animation.play(name, true);
		if (animation.curAnim != null) animation.curAnim.frameRate = fps;
	}

	static inline function _toward(value:Float, target:Float, step:Float):Float
	{
		return value < target ? Math.min(value + step, target) : Math.max(value - step, target);
	}
}
