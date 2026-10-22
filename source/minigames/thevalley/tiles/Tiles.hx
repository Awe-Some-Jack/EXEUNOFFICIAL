package minigames.thevalley.tiles;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxDirectionFlags;

import nape.geom.AABB;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;

import minigames.Camera;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.character.player.ValleyInput;
import minigames.thevalley.character.player.Player.PlayerMode;
import minigames.thevalley.map.TVNapeWorld;
import minigames.thevalley.tiles.HitboxMask.HitKind;
import minigames.thevalley.tiles.HitboxMask.HitRect;

enum abstract CrumbleState(Int)
{
	var Idle       = 0;
	var Shaking    = 1;
	var Sinking    = 2;
	var Gone       = 3;
	var Respawning = 4;
}

enum abstract LaunchState(Int)
{
	var LpIdle      = 0;
	var LpGoingUp   = 1;
}

enum abstract SkullState(Int)
{
	var SkIdle      = 0;
	var SkSearching = 1;
	var SkResult    = 2;
}

enum abstract TotemState(Int)
{
	var ToIdle      = 0;
	var ToApproach  = 1;
	var ToHiding    = 2;
	var ToHidden    = 3;
	var ToRevealing = 4;
}

enum abstract TotemType(Int)
{
	var Fake  = 0;
	var Short = 1;
	var Tall  = 2;
}

class TileKit
{
	public static function body(type:BodyType, cx:Float, cy:Float, w:Float, h:Float, oneWay:Bool):Body
	{
		final b = new Body(type, Vec2.weak(cx, cy));
		b.shapes.add(new Polygon(Polygon.box(w, h)));
		b.allowRotation = false;
		b.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		if (oneWay) b.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		b.space = FlxNapeSpace.space;
		return b;
	}

	public static inline function moveKinematic(b:Body, x:Float, y:Float, elapsed:Float):Void
	{
		final dt = Math.max(elapsed, 0.0001);
		b.velocity.setxy((x - b.position.x) / dt, (y - b.position.y) / dt);
	}

	public static function standing(player:Player, left:Float, width:Float, top:Float):Bool
	{
		final foot = player.y + player.height;
		return player.isGrounded && foot >= top - 4 && foot <= top + 10
			&& player.x + player.width > left && player.x < left + width;
	}

	public static function removeBody(b:Body):Void
	{
		if (b != null) b.space = null;
	}
}

class CrumblingTile extends FlxSprite
{
	public static inline var TILE_W:Int = 84;
	public static inline var TILE_H:Int = 28;

	public static inline var HOLD_TIME:Float    = 5.0;
	public static inline var PRESS_DEPTH:Float  = 14.0;
	public static inline var SHAKE_TIME:Float   = 0.6;
	public static inline var FALL_TIME:Float    = 3.0;
	public static inline var RESPAWN_TIME:Float = 6.0;
	public static inline var FADE_IN:Float      = 0.4;
	static inline var THICKNESS:Float = 8.0;

	public var body(default, null):Body;
	public var tileState(default, null):CrumbleState = Idle;

	public final surface:HitRect;

	final _originX:Float;
	final _originY:Float;
	var _timer:Float = 0;
	var _offTimer:Float = 0;
	var _standTimer:Float = 0;

	public function new(tx:Float, ty:Float)
	{
		super(tx, ty);
		loadGraphic(Paths.image("minigame/thevalley/bg/tiles/" + "tile/tile"));
		setGraphicSize(TILE_W, TILE_H);
		updateHitbox();
		scrollFactor.set(1, 1);
		moves = false;
		_originX = tx;
		_originY = ty;

		final mask = HitboxMask.get("minigame/thevalley/bg/tiles/" + "tile/hitbox");
		surface = mask.bounds(Platform, { x: 0, y: 0, w: TILE_W, h: 4 });
		body = TileKit.body(BodyType.KINEMATIC, tx + surface.x + surface.w * 0.5, ty + surface.y + THICKNESS * 0.5, surface.w, THICKNESS, true);
	}

	public inline function surfaceTop():Float return y + surface.y;

	public inline function atRest():Bool return tileState == Idle && _standTimer == 0 && y == _originY;

	public function tileUpdate(elapsed:Float, playerOn:Bool):Void
	{
		var tx = _originX;
		var ty = _originY;

		switch (tileState)
		{
			case Idle:
				_offTimer = playerOn ? 0 : _offTimer + elapsed;
				if (playerOn || _offTimer < 0.15)
				{
					_standTimer += elapsed;
					ty += PRESS_DEPTH * Math.min(_standTimer / HOLD_TIME, 1);
					if (_standTimer >= HOLD_TIME) _setState(Shaking);
				}
				else
				{
					_standTimer = 0;
					ty = y + (_originY - y) * Math.min(20.0 * elapsed, 1);
					if (Math.abs(ty - _originY) < 0.5) ty = _originY;
				}

			case Shaking:
				_timer += elapsed;
				final progress = _timer / SHAKE_TIME;
				tx += Math.sin(_timer * 30.0) * 2.5 * (1.0 + progress * 2.0);
				ty += PRESS_DEPTH + progress * 4.0;
				if (_timer >= SHAKE_TIME)
				{
					_setState(Sinking);
					TileKit.removeBody(body);
					x = _originX;
				}

			case Sinking:
				_timer += elapsed;
				final t = _timer / FALL_TIME;
				y += 1400.0 * t * t * elapsed;
				angle += 15.0 * elapsed * (1.0 + t * 4.0);
				if (_timer >= FALL_TIME)
				{
					visible = false;
					_setState(Gone);
				}
				return;

			case Gone:
				_timer += elapsed;
				if (_timer >= RESPAWN_TIME && !playerOn) _respawn();
				return;

			case Respawning:
				_timer += elapsed;
				alpha = Math.min(_timer / FADE_IN, 1);
				if (_timer >= FADE_IN) _setState(Idle);
		}

		x = tx;
		y = ty;
		TileKit.moveKinematic(body, tx + surface.x + surface.w * 0.5, ty + surface.y + THICKNESS * 0.5, elapsed);
	}

	function _respawn():Void
	{
		x = _originX;
		y = _originY;
		angle = 0;
		alpha = 0;
		visible = true;
		_standTimer = 0;
		body.position.setxy(_originX + surface.x + surface.w * 0.5, _originY + surface.y + THICKNESS * 0.5);
		body.velocity.setxy(0, 0);
		body.space = FlxNapeSpace.space;
		_setState(Respawning);
	}

	inline function _setState(s:CrumbleState):Void
	{
		tileState = s;
		_timer = 0;
	}

	override public function destroy():Void
	{
		TileKit.removeBody(body);
		body = null;
		super.destroy();
	}
}

class HangingTile
{
	static inline var THICKNESS:Float = 8.0;
	static inline var MIN_SAG:Float   = 0.85;

	public var x(default, null):Float;
	public var y(default, null):Float;

	public final ropeSprite:FlxSprite;
	public final tileSprite:FlxSprite;
	public var body(default, null):Body;
	public final surface:HitRect;

	final _ropeH:Float;
	final _tileH:Float;
	var _stretch:Float = 1.0;

	function new(wx:Float, wy:Float, state:FlxState, ropes:String, tile:String, tileOffsetX:Float, hitbox:String)
	{
		x = wx;
		y = wy;

		ropeSprite = _sprite(wx, wy, ropes);
		_ropeH = ropeSprite.height;
		ropeSprite.origin.y = _ropeH;

		tileSprite = _sprite(wx + tileOffsetX, 0, tile);
		_tileH = tileSprite.height;
		tileSprite.y = _tileY();
		state.add(tileSprite);
		state.add(ropeSprite);

		surface = HitboxMask.get("minigame/thevalley/bg/tiles/" + hitbox).bounds(Platform, { x: 0, y: 0, w: Std.int(tileSprite.width), h: 4 });
		body = TileKit.body(BodyType.KINEMATIC, _bodyX(), _bodyY(), surface.w, THICKNESS, true);
	}

	static function _sprite(sx:Float, sy:Float, image:String):FlxSprite
	{
		final s = new FlxSprite(sx, sy);
		s.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/" + image));
		s.scrollFactor.set(1, 1);
		s.moves = false;
		return s;
	}

	inline function _tileY():Float return y + _ropeH * (1.0 - _stretch) - _tileH + 8.0;

	inline function _bodyX():Float return tileSprite.x + surface.x + surface.w * 0.5;

	inline function _bodyY():Float return tileSprite.y + surface.y + THICKNESS * 0.5;

	public inline function surfaceTop():Float return tileSprite.y + surface.y;

	public inline function atRest():Bool return _stretch >= 1.0;

	public function update(elapsed:Float, player:Player):Void
	{
		final on = TileKit.standing(player, tileSprite.x + surface.x, surface.w, surfaceTop());
		_stretch = on ? Math.max(MIN_SAG, _stretch - 0.4 * elapsed) : Math.min(1.0, _stretch + 0.6 * elapsed);

		ropeSprite.scale.y = _stretch;
		tileSprite.y = _tileY();
		TileKit.moveKinematic(body, _bodyX(), _bodyY(), elapsed);
	}

	public function destroy():Void
	{
		TileKit.removeBody(body);
		body = null;
		ropeSprite.destroy();
		tileSprite.destroy();
	}
}

class GrabbedTile extends HangingTile
{
	public function new(wx:Float, wy:Float, state:FlxState)
	{
		super(wx, wy, state, "grabbedtile/grabbedtile", "grabbedtile/tile", 130.0, "grabbedtile/hitbox");
	}
}

class HoldingTile extends HangingTile
{
	public function new(wx:Float, wy:Float, state:FlxState)
	{
		super(wx, wy, state, "holdingtile/cuerdas", "holdingtile/tile", 8.0, "tile/hitbox");
	}
}

class SpineTile
{
	public static inline var SINK:Float = 10.0;

	public static inline var WARNING_HEIGHT:Float = 20.0;

	static inline var FEET_INSET:Float = 3.0;

	static var _profile:Array<Int> = null;

	public var x(default, null):Float;
	public var y(default, null):Float;
	public final sprite:FlxSprite;

	public function new(wx:Float, wy:Float)
	{
		x = wx;
		y = wy;
		sprite = new FlxSprite(wx, wy);
		sprite.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/" + "spines/spines"));
		sprite.scrollFactor.set(1, 1);
		sprite.moves = false;
		sprite.active = false;

		if (_profile == null) _profile = _buildProfile();
	}

	static function _buildProfile():Array<Int>
	{
		final art = HitboxMask.get("minigame/thevalley/bg/tiles/" + "spines/spines");
		final zone = HitboxMask.get("minigame/thevalley/bg/tiles/" + "spines/hitbox");
		final zoneTop = zone.bounds(Solid).y;
		return [for (c in 0...art.width) {
			final t = art.top(Art, c);
			t < 0 ? art.height : Std.int(Math.max(t, zoneTop));
		}];
	}

	public inline function width():Float return sprite.width;

	public function surfaceY(worldX:Float):Float
	{
		final c = Std.int(worldX - x);
		return c < 0 || c >= _profile.length ? y + sprite.height : y + _profile[c];
	}

	function _highestUnderFeet(player:Player):Null<Float>
	{
		final left = player.x + FEET_INSET;
		final right = player.x + player.width - FEET_INSET;
		if (right <= x || left >= x + sprite.width) return null;

		var top = Math.POSITIVE_INFINITY;
		for (c in Std.int(Math.max(0, left - x))...Std.int(Math.min(_profile.length, right - x + 1)))
			if (_profile[c] < top) top = _profile[c];
		return y + top;
	}

	public function checkKill(player:Player):Bool
	{
		if (player.y >= y + sprite.height) return false;
		final top = _highestUnderFeet(player);
		return top != null && player.y + player.height > top + SINK;
	}

	public function checkFallingWarning(player:Player):Bool
	{
		if (player.body == null || player.body.velocity.y <= 0) return false;
		final top = _highestUnderFeet(player);
		if (top == null) return false;
		final foot = player.y + player.height;
		return foot <= top + SINK && top - foot <= WARNING_HEIGHT;
	}

	public function destroy():Void
	{
		sprite.destroy();
	}
}

class SonicBridge
{
	static inline var PLANKS:Int = 14;
	static inline var PLANK_THICKNESS:Float = 8.0;
	static inline var MAX_SAG:Float = 12.0;

	public var x(default, null):Float;
	public var y(default, null):Float;
	public var totalWidth(get, never):Float;

	final _planks:Array<FlxSprite> = [];
	final _supports:Array<Body> = [];
	final _plankW:Float;
	final _plankH:Float;
	final _supportW:Float;
	final _line:Body;
	final _leftSeg:Polygon;
	final _rightSeg:Polygon;
	var _sag:Float = 0.0;
	var _sagVel:Float = 0.0;
	var _dip:Float = 0.5;
	var _wasOn:Bool = false;
	var _lastFall:Float = 0.0;

	inline function get_totalWidth() return _supportW * 2 + PLANKS * _plankW;
	inline function _left():Float return x + _supportW;
	inline function _right():Float return x + _supportW + PLANKS * _plankW;
	inline function _top():Float return y + 7.0;
	inline function _dipX():Float return _left() + (_right() - _left()) * _dip;

	function _depth():Float
	{
		final d = _dipX();
		final cap = 0.3 * Math.min(d - _left(), _right() - d);
		return Math.max(-cap, Math.min(cap, _sag * MAX_SAG));
	}

	public function new(wx:Float, wy:Float, state:FlxState)
	{
		x = wx;
		y = wy;

		final plankMask = HitboxMask.get("minigame/thevalley/bg/tiles/" + "bridge/bridgehitbox");
		_supportW = Paths.image("minigame/thevalley/bg/tiles/" + "bridge/estribo").width;
		_plankW = plankMask.width;
		_plankH = plankMask.height;

		_addSupport(wx, wy, state, false);
		for (i in 0...PLANKS)
		{
			final spr = new FlxSprite(wx + _supportW + i * _plankW, wy + 7.0);
			spr.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/" + "bridge/bridge"));
			spr.scrollFactor.set(1, 1);
			spr.moves = false;
			spr.active = false;
			state.add(spr);
			_planks.push(spr);
		}
		_addSupport(wx + _supportW + PLANKS * _plankW, wy, state, true);

		_line = new Body(BodyType.KINEMATIC, Vec2.weak(0, 0));
		_leftSeg = new Polygon(Polygon.box(1, 1));
		_rightSeg = new Polygon(Polygon.box(1, 1));
		_line.shapes.add(_leftSeg);
		_line.shapes.add(_rightSeg);
		_line.allowRotation = false;
		_line.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		_line.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		_line.space = FlxNapeSpace.space;
		_applyLine(0.0);
	}

	public function lineY(px:Float):Float
	{
		final l = _left();
		final r = _right();
		final d = _dipX();
		final depth = _depth();
		if (px <= d) return _top() + depth * Math.max(0.0, px - l) / Math.max(1.0, d - l);
		return _top() + depth * Math.max(0.0, r - px) / Math.max(1.0, r - d);
	}

	function _applyLine(elapsed:Float):Void
	{
		final top = _top();
		final d = _dipX();
		final depth = _depth();
		_setSegment(_leftSeg, _left(), top - depth, d, top);
		_setSegment(_rightSeg, d, top, _right(), top - depth);

		if (atRest() || elapsed <= 0)
		{
			_line.position.setxy(0, depth);
			_line.velocity.setxy(0, 0);
		}
		else
			_line.velocity.setxy(0, (depth - _line.position.y) / elapsed);

		for (p in _planks)
		{
			final yl = lineY(p.x);
			final yr = lineY(p.x + _plankW);
			p.y = (yl + yr) * 0.5;
			p.angle = Math.atan2(yr - yl, _plankW) * 180.0 / Math.PI;
		}
	}

	function _setSegment(seg:Polygon, x0:Float, y0:Float, x1:Float, y1:Float):Void
	{
		if (x1 - x0 < 1.0) x1 = x0 + 1.0;
		final verts = seg.localVerts;
		verts.at(0).setxy(x0, y0);
		verts.at(1).setxy(x1, y1);
		verts.at(2).setxy(x1, y1 + PLANK_THICKNESS);
		verts.at(3).setxy(x0, y0 + PLANK_THICKNESS);
	}

	function _addSupport(sx:Float, sy:Float, state:FlxState, flip:Bool):Void
	{
		final spr = new FlxSprite(sx, sy);
		spr.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/" + "bridge/estribo"));
		spr.flipX = flip;
		spr.scrollFactor.set(1, 1);
		spr.moves = false;
		spr.active = false;
		state.add(spr);

		final rx = flip ? sx : sx + _supportW - _plankW;
		final ry = _top();
		_supports.push(TileKit.body(BodyType.STATIC, rx + _plankW * 0.5, ry + _plankH * 0.5, _plankW, _plankH, true));
	}

	public inline function atRest():Bool return _sag == 0 && _sagVel == 0;

	public function update(elapsed:Float, player:Player):Void
	{
		final l = _left();
		final r = _right();
		final px = player.x + player.width * 0.5;
		final on = px > l && px < r && TileKit.standing(player, l, r - l, lineY(px));

		if (on)
		{
			_dip = Math.max(0.02, Math.min(0.98, (px - l) / (r - l)));
			if (!_wasOn) _sagVel += Math.min(_lastFall, 900.0) / 120.0 * 4.0 * _dip * (1.0 - _dip);
		}
		else if (_wasOn && player.body != null && player.body.velocity.y < -150)
			_sagVel += 2.0 * 4.0 * _dip * (1.0 - _dip);
		_wasOn = on;
		_lastFall = player.body != null ? Math.max(0.0, player.body.velocity.y) : 0.0;

		final target = on ? 4.0 * _dip * (1.0 - _dip) : 0.0;
		var left = elapsed;
		while (left > 0)
		{
			final dt = Math.min(left, 1.0 / 60.0);
			_sagVel += ((target - _sag) * 160.0 - _sagVel * 12.0) * dt;
			_sag = Math.max(-0.35, _sag + _sagVel * dt);
			left -= dt;
		}
		if (!on && Math.abs(_sag) < 0.002 && Math.abs(_sagVel) < 0.01)
		{
			_sag = 0;
			_sagVel = 0;
		}

		_applyLine(elapsed);
	}

	public function destroy():Void
	{
		for (b in _supports.concat([_line])) TileKit.removeBody(b);
		for (s in _planks) s.destroy();
	}
}

class Launchpad extends FlxSprite
{
	public static inline var LAUNCH_VY:Float = -950.0;
	static inline var PAD_W:Float = 35.0;
	static inline var PAD_H:Float = 6.0;

	public var body(default, null):Body;

	var _lState:LaunchState = LpIdle;
	var _holdTimer:Float = 0;
	var _cooldown:Float = 0;
	var _ext:Float = 0;
	var _extVel:Float = 0;

	public function new(tx:Float, ty:Float)
	{
		super(tx, ty);
		frames = Paths.getSparrowAtlas("minigame/thevalley/objects/interactable/launchpad");
		_showSpring();
		scrollFactor.set(1, 1);
		moves = false;

		body = TileKit.body(BodyType.STATIC, tx + width * 0.5, ty + height - PAD_H * 0.5, PAD_W, PAD_H, true);
	}

	public inline function triggerTop():Float return y + height - 18;

	public inline function triggerHeight():Float return 26;

	public function tryLaunch(player:Player):Bool
	{
		if (_cooldown > 0 || _lState != LpIdle) return false;

		final foot = player.y + player.height;
		if (foot < triggerTop() || foot > triggerTop() + triggerHeight()) return false;
		if (player.x + player.width <= x || player.x >= x + width) return false;
		if (player.body == null || player.body.velocity.y < 0) return false;

		player.doLaunch(LAUNCH_VY);
		FlxG.sound.play(Paths.sound("minigame/thevalley/launchpad"), 0.3);
		_lState = LpGoingUp;
		_holdTimer = 0.16;
		_extVel = 1100;
		return true;
	}

	public function padUpdate(elapsed:Float):Void
	{
		if (_cooldown > 0) _cooldown = Math.max(0, _cooldown - elapsed);

		if (_lState == LpIdle) return;

		_holdTimer -= elapsed;
		final target = _holdTimer > 0 ? 24.0 : 0.0;
		_extVel += ((target - _ext) * 520.0 - _extVel * 9.0) * elapsed;
		_ext += _extVel * elapsed;
		if (_ext > 28)
		{
			_ext = 28;
			if (_extVel > 0) _extVel *= -0.2;
		}
		if (_ext < 0)
		{
			_ext = 0;
			if (_extVel < 0) _extVel *= -0.25;
		}
		if (_holdTimer <= 0 && _ext < 0.4 && Math.abs(_extVel) < 12)
		{
			_ext = 0;
			_extVel = 0;
			_lState = LpIdle;
			_cooldown = 0.4;
		}
		_showSpring();
	}

	function _showSpring():Void
	{
		final i = Std.int(Math.max(0, Math.min(14, Math.round(_ext / 2))));
		animation.frameName = "launchpad spring" + StringTools.lpad(Std.string(i), "0", 4);
	}

	override public function destroy():Void
	{
		TileKit.removeBody(body);
		body = null;
		super.destroy();
	}
}

class SkullPrompt
{
	public static inline var INTERACT_DIST:Float = 120.0;
	static inline var SEARCH_ZOOM_BUMP:Float = 0.35;

	public var skullX(get, never):Float;
	public var skullY(get, never):Float;
	public var skullId:Int = 0;

	public final zone:HitRect;

	final _skull:FlxSprite;
	final _eButton:FlxSprite;
	final _player:Player;
	final _onWin:(first:Bool, playerReleased:Bool) -> Void;
	final _camera:Camera;
	final _hunt:ShardHunt;
	final _isDanger:Null<() -> Bool>;
	
	var _state:SkullState = SkIdle;
	var _timer:Float = 0;
	var _win:Bool = false;
	var _first:Bool = false;
	var _done:Bool = false;
	var _searchSound:flixel.sound.FlxSound = null;

	inline function get_skullX() return _skull.x;

	inline function get_skullY() return _skull.y;

	public function new(wx:Float, wy:Float, player:Player, eButton:FlxSprite, group:FlxTypedGroup<FlxSprite>, camera:Camera, hunt:ShardHunt, ?onWin:(first:Bool, playerReleased:Bool) -> Void, ?isDanger:() -> Bool)
	{
		_player = player;
		_eButton = eButton;
		_onWin = onWin;
		_camera = camera;
		_hunt = hunt;
		_isDanger = isDanger;
		_hunt.addSkull();

		_skull = new FlxSprite(wx, wy);
		_skull.frames = Paths.getSparrowAtlas("minigame/thevalley/bg/tiles/" + "skulls/skulls");
		_skull.animation.addByIndices("idle",       "skulls destroying", [0], "", 1, true);
		_skull.animation.addByPrefix("destroying", "skulls destroying", 8, false);
		_skull.animation.addByPrefix("destroy",    "skulls destroy",    1, false);
		_skull.animation.play("idle");
		_skull.scrollFactor.set(1, 1);
		group.add(_skull);

		zone = HitboxMask.get("minigame/thevalley/bg/tiles/" + "skulls/hitbox").bounds(Zone);
	}

	public inline function isBusy():Bool return _state == SkSearching || _state == SkResult;

	public function getDist():Float
	{
		final dx = _player.x + _player.width * 0.5 - (_skull.x + zone.x + zone.w * 0.5);
		final dy = _player.y + _player.height * 0.5 - (_skull.y + zone.y + zone.h * 0.5);
		return Math.abs(dy) > 30.0 ? 9999.0 : Math.sqrt(dx * dx + dy * dy);
	}

	inline function _inZone():Bool
		return Math.abs(_player.x + _player.width * 0.5 - (_skull.x + zone.x + zone.w * 0.5)) <= zone.w * 0.5
			&& Math.abs(_player.y + _player.height * 0.5 - (_skull.y + zone.y + zone.h * 0.5)) <= 30.0;

	public function update(elapsed:Float):Void
	{
		if (!_done) return;
		final anim = _skull.animation.curAnim;
		if (anim != null && anim.name == "destroying" && anim.finished) _skull.animation.play("destroy");
	}

	public function updateActive(elapsed:Float, dist:Float = 0):Void
	{
		if (_done) return;

		switch (_state)
		{
			case SkIdle:
				final inZone = _inZone();
				_eButton.alpha = (1.0 - Math.min(Math.max((dist - 60.0) / (INTERACT_DIST - 60.0), 0.0), 1.0)) * (inZone ? 0.55 : 0.25);
				_eButton.x = _skull.x + (_skull.width - _eButton.width) * 0.5;
				_eButton.y = _skull.y - _eButton.height - 6;

				if (ValleyInput.interact() && inZone)
				{
					_eButton.alpha = 0;
					_state = SkSearching;
					_timer = 0;
					_player.cinematic = true;
					_player.mode = PlayerMode.Ground;
					_player.wingOpenTimer = 0;
					_player.glideCooldown = 0;
					_player.body.velocity.setxy(0, 0);
					_lockAnim("searching");
					_searchSound = FlxG.sound.play(Paths.sound("minigame/thevalley/skullsearch"), 0.3);
				}

			case SkSearching:
				_eButton.alpha = 0;
				_timer += elapsed;

				final wantsToMove = ValleyInput.movedJust();
				if (wantsToMove && (_isDanger != null && _isDanger()))
				{
					interrupt();
					_player.lockedAnim = null;
					_player.cinematic = false;
					_player.animation.play("idle");
					return;
				}

				_camera.zoomIn(SEARCH_ZOOM_BUMP * _easeOut(_timer / 1.0), 0);
				final dig = _player.animation.curAnim;
				if ((dig?.name == "searching" && dig.finished) || _timer >= 1.5)
				{
					_searchSound?.stop();
					_searchSound = null;
					_first = _hunt.searched == 0;
					_win = _hunt.search();
					_state = SkResult;
					_timer = 0;
					_lockAnim(_win ? "searchreward" : "searchinglose");
				}

			case SkResult:
				_eButton.alpha = 0;
				_timer += elapsed;

				final wantsToMove = ValleyInput.movedJust(false);
				if (wantsToMove && (_isDanger != null && _isDanger()))
				{
					_finish(true);
					return;
				}

				_camera.zoomIn(SEARCH_ZOOM_BUMP * (1 - _easeOut(_timer / 0.9)), 0);
				final anim = _player.animation.curAnim;
				if (!_win && anim?.name == "searchinglose" && anim.finished) _player.animation.pause();
				if (_win && anim?.name == "searchreward" && anim.finished) _lockAnim("searchingwin");

				if (_timer >= (_win ? 2.0 + 0.8 : 2.0)) _finish(true);
		}

		if (isBusy()) _player.isMakingNoise = true;
	}

	public function interrupt():Void
	{
		switch (_state)
		{
			case SkSearching:
				_searchSound?.stop();
				_searchSound = null;
				_state = SkIdle;
				_timer = 0;
			case SkResult:
				_finish(false);
			case SkIdle:
		}
	}

	function _finish(releasePlayer:Bool):Void
	{
		_done = true;
		_state = SkIdle;
		_skull.animation.play("destroying");
		if (releasePlayer)
		{
			_player.lockedAnim = null;
			_player.cinematic = false;
			_player.animation.play("idle");
		}
		if (_win && _onWin != null) _onWin(_first, releasePlayer);
	}

	inline function _lockAnim(name:String):Void
	{
		_player.lockedAnim = name;
		_player.animation.play(name, true);
	}

	static inline function _easeOut(t:Float):Float
	{
		final c = Math.min(t, 1.0);
		return 1.0 - (1.0 - c) * (1.0 - c);
	}
}

class Totem
{
	public static inline var BURN_TIME:Float = 15.0;
	public static inline var BURN_ZOOM:Float = 2.55;
	public static inline var BURN_SHOT_ZOOM:Float = 1.5;
	static inline var DREAD_DELAY:Float = 3.75;
	static inline var HIDE_ZOOM_BUMP:Float = 0.95;
	static inline var HIDE_ZOOM_RATE:Float = 3.0;
	static inline var USE_DIST:Float = 70.0;
	static inline var HIDE_OFFSET:Float = 20.0;
	static inline var EXIT_SLIDE:Float = 12.0;
	static inline var BURN_GUIDE:Int = 34;
	static inline var BURN_NUDGE:Float = 3.0;
	static inline var BURN_LINGER:Float = 2.0;
	static inline var DECOY_CALM:Float = 0.8;
	static inline var DECOY_BREAK:Float = 1.0;
	static inline var FLICKER_STEP:Float = 0.05;
	static inline var APPROACH_SPEED:Float = 140.0;
	static inline var SLIDE_DIST:Float = 8.0;
	static inline var SLIDE_TIME:Float = 0.1;
	static inline var PRESS_BUFFER:Float = 0.2;
	static inline var COVER_FRAME:Int = 1;

	public var totemX(get, never):Float;
	public var totemY(get, never):Float;
	public var totemType(get, never):TotemType;
	public var isDone:Bool = false;
	public var onBurn:Totem->Void;
	public var hiddenTime(default, null):Float = 0;
	public var dread(get, never):Float;
	public var sprite(get, never):FlxSprite;
	public var isDecoy(get, never):Bool;

	final _sprite:FlxSprite;
	var _disguise:FlxSprite = null;
	var _flickerTimer:Float = 0;
	final _eButton:FlxSprite;
	final _player:Player;
	final _type:TotemType;
	final _group:FlxTypedGroup<FlxSprite>;
	final _flxState:FlxState;
	final _camera:Camera;
	final _poleX:Float;
	final _poleHalf:Float;
	var _state:TotemState = ToIdle;
	var _side:Int = -1;
	var _approachSpeed:Float = APPROACH_SPEED;
	var _pressedAt:Float = Math.NEGATIVE_INFINITY;
	var _inFront:Bool = false;
	var _spent:Bool = false;
	var _slideX:Float = 0.0;
	var _slideY:Float = 0.0;
	var _slideT:Float = 1.0;
	var _exitT:Float = 0.0;
	var _exitTime:Float = 0.3;

	inline function get_totemX() return _sprite.x;

	inline function get_totemY() return _sprite.y;

	inline function get_totemType() return _type;

	inline function get_sprite() return _sprite;

	inline function get_isDecoy() return _type == Fake;

	public static function burnDuration(player:Player):Float
	{
		final anim = player.animation.getByName("totemdeath");
		return (anim != null ? anim.numFrames / anim.frameRate : 0) + BURN_LINGER;
	}

	function get_dread():Float
	{
		if (_state != ToHidden || isDecoy) return 0;
		return Math.max(0, Math.min(1, (hiddenTime - DREAD_DELAY) / (BURN_TIME - DREAD_DELAY)));
	}

	public function new(wx:Float, wy:Float, type:TotemType, player:Player, eButton:FlxSprite, group:FlxTypedGroup<FlxSprite>, ?state:FlxState, ?camera:Camera)
	{
		_player = player;
		_eButton = eButton;
		_type = type;
		_group = group;
		_flxState = state;
		_camera = camera;

		_sprite = new FlxSprite(wx, wy);
		final dir = "minigame/thevalley/objects/interactable/";
		switch (type)
		{
			case Fake:
				_sprite.frames = Paths.getSparrowAtlas(dir + "faketotem");
				_addAnim("idle",  "faketotem idle",  1,  true);
				_addAnim("press", "faketotem press", 12, false);
				_addAnim("fake",  "faketotem fake",  1,  true);
				_sprite.animation.play("idle");
			case Short:
				_sprite.loadGraphic(Paths.image(dir + "totemshort"));
				_sprite.active = false;
			case Tall:
				_sprite.loadGraphic(Paths.image(dir + "totemtall"));
				_sprite.active = false;
		}
		_sprite.scrollFactor.set(1, 1);
		group.add(_sprite);

		final pole = _sprite.frame;
		_poleX = pole.offset.x + pole.frame.width * 0.5;
		_poleHalf = pole.frame.width * 0.5;

		if (type == Fake)
		{
			_disguise = new FlxSprite(0, 0, Paths.image(dir + "totemshort"));
			_disguise.scrollFactor.set(1, 1);
			_disguise.active = false;
			_poleHalf = _disguise.width * 0.5;
			_sprite.visible = false;
			_placeDisguise();
			group.add(_disguise);
		}
	}

	public function setBottom(y:Float):Void
	{
		_sprite.y = y - _sprite.height;
		if (_disguise != null) _placeDisguise();
	}

	public function anchor():{ x:Float, y:Float }
		return { x: _sprite.x + _poleX, y: _sprite.y + _sprite.height };

	public function placeAt(x:Float, bottom:Float):Void
	{
		_sprite.x = x - _poleX;
		setBottom(bottom);
	}

	function _placeDisguise():Void
	{
		_disguise.setPosition(_sprite.x + _poleX - _disguise.width * 0.5, _sprite.y + _sprite.height - _disguise.height);
	}

	function _addAnim(name:String, prefix:String, fps:Int, loop:Bool):Void
	{
		final frames = _sprite.frames.frames;
		_sprite.animation.add(name, [for (i in 0...frames.length) if (frames[i].name.indexOf(prefix) == 0) i], fps, loop);
	}

	public inline function isBusy():Bool return _state != ToIdle;

	public function getDist():Float
	{
		if (_spent) return 9999.0;
		final dx = _player.x + _player.width * 0.5 - (_sprite.x + _sprite.width * 0.5);
		final dy = _player.y + _player.height * 0.5 - (_sprite.y + _sprite.height * 0.5);
		return Math.abs(dy) > 40.0 ? 9999.0 : Math.sqrt(dx * dx + dy * dy);
	}

	public function updateActive(elapsed:Float, dist:Float = 0):Void
	{
		if (_state != ToIdle) _eButton.alpha = 0;
		else _uncoverWhenClear();

		switch (_state)
		{
			case ToIdle if (_player.cinematic || _spent):
				_eButton.alpha = 0;

			case ToIdle:
				final t = 1.0 - Math.min(Math.max((dist - 60.0) / 60.0, 0.0), 1.0);
				_eButton.alpha = t;
				if (t > 0)
				{
					_eButton.x = _sprite.x + _poleX - _eButton.width * 0.5;
					_eButton.y = (_disguise != null ? Math.min(_disguise.y, _sprite.y) : _sprite.y) - _eButton.height - 6;
				}

				final now = haxe.Timer.stamp();
				if (ValleyInput.interact() && dist <= USE_DIST) _pressedAt = now;
				if (now - _pressedAt <= PRESS_BUFFER && dist <= USE_DIST && (_player.isGrounded || _player.coyoteTimer > 0)) _startApproach();

			case ToApproach:
				_approach(elapsed);

			case ToHiding:
				_slideT = Math.min(1, _slideT + elapsed / SLIDE_TIME);
				_snapPlayerInside();
				if (_frameOf("hide1") >= COVER_FRAME) _setCover(true);
				final anim = _player.animation.curAnim;
				if (anim == null || anim.name != "hide1" || anim.finished)
				{
					_state = ToHidden;
					hiddenTime = 0;
					_player.isHiding = false;
					_player.isHidden = true;
					_setCover(true);
					_player.animation.play("hide2", true);
				}

			case ToHidden:
				_snapPlayerInside();
				hiddenTime += elapsed;
				if (isDecoy)
				{
					if (hiddenTime >= DECOY_CALM + DECOY_BREAK) _collapse();
					else if (hiddenTime >= DECOY_CALM) _crack(elapsed, (hiddenTime - DECOY_CALM) / DECOY_BREAK);
				}
				else if (hiddenTime >= BURN_TIME) _burn();
				if (_state == ToHidden && ValleyInput.interact() && dist <= USE_DIST)
				{
					_mend();
					_startExit();
				}

			case ToRevealing:
				_exitT += elapsed;
				_snapPlayerInside();
				_uncoverWhenClear();
				final anim = _player.animation.curAnim;
				if (anim == null || anim.name != "unhide" || anim.finished)
				{
					_exitT = _exitTime;
					_snapPlayerInside();
					_finishReveal();
				}
		}

		if (_type == Fake)
		{
			final anim = _sprite.animation.curAnim;
			if (anim != null && anim.name == "press" && anim.finished) _sprite.animation.play("fake");
		}

		if (_state != ToIdle && _state != ToHidden) _player.isMakingNoise = true;

		_updateHideZoom();
	}

	function _startApproach():Void
	{
		_pressedAt = Math.NEGATIVE_INFINITY;
		hiddenTime = 0;
		_eButton.alpha = 0;
		_side = _player.body.position.x < _sprite.x + _poleX ? -1 : 1;
		_approachSpeed = Math.max(APPROACH_SPEED, Math.abs(_player.body.velocity.x));
		_player.isHiding = true;
		_player.inDecoy = isDecoy;
		_state = ToApproach;
		_approach(0);
	}

	function _approach(elapsed:Float):Void
	{
		final body = _player.body;
		final dx = _hideX() - body.position.x;
		final step = _approachSpeed * elapsed;
		_player.facing = _side < 0 ? FlxDirectionFlags.RIGHT : FlxDirectionFlags.LEFT;

		if (dx * _side > 0 || Math.abs(dx) <= Math.max(step, SLIDE_DIST))
		{
			_beginHide();
			return;
		}

		final frac = step / Math.abs(dx);
		final ty = _hideY();
		body.position.setxy(body.position.x + dx * frac, body.position.y + (ty - body.position.y) * frac);
		body.velocity.setxy(0, 0);

		final p = _player.cfg.physics;
		final running = _approachSpeed > p.walkMax;
		final name = running ? "run" : "walk";
		if (_player.animation.curAnim == null || _player.animation.curAnim.name != name) _player.animation.play(name, true);
		_player.animation.curAnim.frameRate = running ? 4 + Std.int(_approachSpeed / p.runMax * 16) : 6 + Std.int(_approachSpeed / p.walkMax * 12);
	}

	function _beginHide():Void
	{
		final body = _player.body;
		_slideX = body.position.x - _hideX();
		_slideY = body.position.y - _hideY();
		_slideT = 0;
		_state = ToHiding;
		_player.animation.play("hide1", true);
		_snapPlayerInside();
	}

	function _crack(elapsed:Float, t:Float):Void
	{
		_flickerTimer -= elapsed;
		if (_flickerTimer > 0) return;
		_flickerTimer = FLICKER_STEP;
		final showFake = FlxG.random.float() < 0.15 + 0.85 * t;
		_disguise.visible = !showFake;
		_sprite.visible = showFake;
		_disguise.offset.x = _sprite.offset.x = FlxG.random.int(-1, 1);
	}

	function _mend():Void
	{
		if (_disguise == null || _spent) return;
		_disguise.visible = true;
		_sprite.visible = false;
		_disguise.offset.x = _sprite.offset.x = 0;
		_flickerTimer = 0;
	}

	function _collapse():Void
	{
		_spent = true;
		_disguise.visible = false;
		_disguise.offset.x = _sprite.offset.x = 0;
		_sprite.visible = true;
		_sprite.animation.play("press", true);
		_eject();
	}

	function _eject():Void
	{
		_state = ToIdle;
		_player.isHidden = false;
		_player.isHiding = false;
		_player.inDecoy = false;
		_player.setGravity(true);
		_player.knockDown(_side * 240.0, -210.0);
		_camera?.shake(0.004, 0.2);
	}

	function _startExit():Void
	{
		_state = ToRevealing;
		_player.animation.play("unhide", true);
		final unhide = _player.animation.curAnim;
		_exitTime = unhide.numFrames / unhide.frameRate;
		_exitT = 0;
	}

	public function interrupt():Void
	{
		if (_state == ToIdle) return;
		_state = ToIdle;
		_player.isHiding = false;
		_player.isHidden = false;
		_player.inDecoy = false;
		_mend();
		_uncoverWhenClear();
	}

	function _finishReveal():Void
	{
		_state = ToIdle;
		_uncoverWhenClear();
		_player.isHidden = false;
		_player.isHiding = false;
		_player.inDecoy = false;
		_player.setGravity(true);
		_player.body.velocity.setxy(0, 0);
		_player.jumpHeld = false;
		_player.jumpBufTimer = 0;
		_player.coyoteTimer = _player.cfg.tuning.coyoteFrames / 60.0;
		_player.isGrounded = true;
		_player.mode = PlayerMode.Ground;
		_player.animation.play("idle");
	}

	function _burn():Void
	{
		_state = ToIdle;
		_player.isHidden = false;
		_player.cinematic = true;
		_player.lockedAnim = "totemdeath";
		_player.animation.play("totemdeath", true);

		final center = _player.offset.x + _player.width * 0.5;
		final guide = _player.flipX ? _player.frameWidth - 1 - BURN_GUIDE : BURN_GUIDE;
		final edge = _sprite.x + _poleX + (_side < 0 ? -_poleHalf : _poleHalf - 1);
		final x = edge - (guide - center) - _side * BURN_NUDGE;
		_player.x += x - _player.body.position.x;
		_player.body.position.x = x;
		if (onBurn != null) onBurn(this);
	}

	inline function _frameOf(name:String):Int
	{
		final anim = _player.animation.curAnim;
		return anim != null && anim.name == name ? anim.curFrame : -1;
	}

	function _uncoverWhenClear():Void
	{
		if (_inFront && !_overlapsPlayer()) _setCover(false);
	}

	function _overlapsPlayer():Bool
	{
		final f = _player.frame;
		final t = _sprite.frame;
		if (f == null || t == null) return false;
		final from = _player.x - _player.offset.x + (_player.flipX ? f.sourceSize.x - f.offset.x - f.frame.width : f.offset.x);
		final totem = _sprite.x + _poleX - _poleHalf;
		return from < totem + _poleHalf * 2 && from + f.frame.width > totem;
	}

	function _setCover(on:Bool):Void
	{
		if (_inFront == on) return;
		_inFront = on;
		if (_flxState == null) return;
		final pieces = _disguise != null ? [_sprite, _disguise] : [_sprite];
		if (on)
		{
			for (piece in pieces) _group.remove(piece, true);
			final i = _flxState.members.indexOf(_player);
			for (k in 0...pieces.length)
			{
				if (i >= 0) _flxState.insert(i + 1 + k, pieces[k]);
				else _flxState.add(pieces[k]);
			}
		}
		else
		{
			for (piece in pieces)
			{
				_flxState.remove(piece, true);
				_group.add(piece);
			}
		}
	}

	inline function _hideX():Float return _sprite.x + _poleX + _side * HIDE_OFFSET;

	inline function _hideY():Float return _sprite.y + _sprite.height - _player.cfg.hitbox.height * 0.5;

	function _snapPlayerInside():Void
	{
		final rest = 1 - _slideT;
		var out = 0.0;
		if (_state == ToRevealing)
		{
			final t = Math.min(1, _exitT / _exitTime);
			out = 1 - (1 - t) * (1 - t);
		}
		_player.body.position.setxy(_hideX() + _slideX * rest + _side * EXIT_SLIDE * out, _hideY() + _slideY * rest);
		_player.body.velocity.setxy(0, 0);
		_player.facing = _side < 0 ? FlxDirectionFlags.RIGHT : FlxDirectionFlags.LEFT;
	}

	function _updateHideZoom():Void
	{
		if (_camera == null || _state == ToIdle || _state == ToRevealing) return;
		final d = dread;
		_camera.zoomIn(HIDE_ZOOM_BUMP + (BURN_ZOOM - HIDE_ZOOM_BUMP) * d * d, HIDE_ZOOM_RATE);
	}
}

class LoopTile extends FlxSprite
{
	final _bodies:Array<Body> = [];

	public function new(wx:Float, wy:Float)
	{
		super(wx, wy);
		frames = Paths.getSparrowAtlas("minigame/thevalley/bg/tiles/loop/loop");
		animation.addByPrefix("collapse", "loop0", 10, false);
		animation.frameIndex = 0;
		_buildBodies();
	}

	public function collapse():Void
	{
		animation.play("collapse");
		_removeBodies();
	}

	override public function destroy():Void
	{
		_removeBodies();
		super.destroy();
	}

	function _removeBodies():Void
	{
		for (b in _bodies) TileKit.removeBody(b);
		_bodies.resize(0);
	}

	function _buildBodies():Void
	{
		final hitbox = Paths.getBitmapData("assets/shared/images/minigame/thevalley/bg/tiles/loop/hitbox.webp");
		if (hitbox == null) return;
		final w = hitbox.width;
		final h = hitbox.height;
		final solid = new haxe.ds.Vector<Bool>(w * h);
		final platform = new haxe.ds.Vector<Bool>(w * h);
		final pixels = hitbox.getVector(hitbox.rect);
		hitbox.dispose();
		for (i in 0...w * h)
		{
			final argb = pixels[i];
			if (((argb >> 24) & 0xFF) < 30) continue;
			final r = (argb >> 16) & 0xFF;
			final g = (argb >> 8) & 0xFF;
			final b = argb & 0xFF;
			if (r >= 160 && g < 100 && b < 100) solid[i] = true;
			else if (r < 100 && g >= 160 && b < 100) platform[i] = true;
		}
		_addBody(solid, w, h, false);
		_addBody(platform, w, h, true);
	}

	function _addBody(mask:haxe.ds.Vector<Bool>, w:Int, h:Int, oneWay:Bool):Void
	{
		final iso = (fx:Float, fy:Float) -> {
			final ix = Std.int(fx);
			final iy = Std.int(fy);
			return ix < 0 || iy < 0 || ix >= w || iy >= h || !mask[iy * w + ix] ? 1.0 : -1.0;
		};
		final body = new Body(BodyType.STATIC, Vec2.weak(x, y));
		if (oneWay) body.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		for (gp in MarchingSquares.run(iso, new AABB(0, 0, w, h), Vec2.weak(2, 2), 2, null, true, null))
		{
			gp.simplify(2.0);
			for (cp in gp.convexDecomposition()) new Polygon(cp).body = body;
			gp.dispose();
		}
		if (body.shapes.length == 0) return;
		body.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		body.space = FlxNapeSpace.space;
		_bodies.push(body);
	}
}
