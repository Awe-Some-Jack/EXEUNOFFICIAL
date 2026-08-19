package thevalley.tiles;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxDirectionFlags;
import nape.callbacks.CbType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import thevalley.map.TVNapeWorld;
import thevalley.player.Player;
import thevalley.TVCutscene;

enum abstract CrumbleState(Int)
{
	var Idle    = 0;
	var Shaking = 1;
	var Sinking = 2;
	var Gone    = 3;
}

enum abstract LaunchState(Int)
{
	var LpIdle      = 0;
	var LpGoingUp   = 1;
	var LpUp        = 2;
	var LpGoingDown = 3;
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
	var ToHiding    = 1;
	var ToHidden    = 2;
	var ToRevealing = 3;
}

enum abstract TotemType(Int)
{
	var Fake  = 0;
	var Short = 1;
	var Tall  = 2;
}

// stand on it too long n it dips down then it shakes that booty and falls 
class CrumblingTile extends FlxSprite
{
	public static inline var TILE_W:Int = 84;
	public static inline var TILE_H:Int = 28;

	public static var CB_CRUMBLE:CbType = new CbType();

	public var body:Body;
	public var tileState:CrumbleState = Idle;

	var _standTimer:Float = 0;
	var _shakeTimer:Float = 0;
	var _sinkTimer:Float  = 0;
	var _offTimer:Float   = 0;
	var _originX:Float;
	var _originY:Float;
	var _playerOn:Bool = false;

	public function new(tx:Float, ty:Float)
	{
		super(tx, ty);
		loadGraphic(Paths.image("minigame/thevalley/bg/tiles/tile/tile"));
		setGraphicSize(TILE_W, TILE_H);
		updateHitbox();
		scrollFactor.set(1, 1);
		_originX = tx;
		_originY = ty;

		_buildBody(tx, ty);
	}

	function _buildBody(tx:Float, ty:Float):Void
	{
		if (body != null) { body.space = null; body = null; }

		body = new Body(BodyType.KINEMATIC, Vec2.weak(tx + TILE_W * 0.5, ty + TILE_H * 0.5));
		var shape = new Polygon(Polygon.box(TILE_W, TILE_H));
		body.shapes.add(shape);
		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.1, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(CB_CRUMBLE);
		body.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		body.space = FlxNapeSpace.space;
	}

	public function notifyStanding(on:Bool):Void
		_playerOn = on;

	public function tileUpdate(elapsed:Float):Void
	{
		if (tileState == Gone) return;

		switch (tileState)
		{
			case Idle:

				if (_playerOn)
					_offTimer = 0;
				else
					_offTimer += elapsed;

				if (_playerOn || _offTimer < 0.15)
				{
					_standTimer += elapsed;
					var pressY = 14.0 * (_standTimer / 5.0); // tile sinks a lil the longer u chill on it
					_setBodyY(_originY + pressY);
					if (_standTimer >= 5.0) // btw 5 whole ass seconds so if you fall out of tha shi your bad aijfaijfajfiajfaj
					{
						tileState   = Shaking;
						_shakeTimer = 0;
					}
				}
				else
				{
					_standTimer = 0;
					var ty = y + ((_originY - y) * 20.0 * elapsed);
					if (Math.abs(ty - _originY) < 0.5) ty = _originY;
					_setBodyY(ty);
				}

			case Shaking:
				_shakeTimer += elapsed;
				var progress = _shakeTimer / 0.6;
				var amp  = 2.5 * (1.0 + progress * 2.0);
				var newX = _originX + Math.sin(_shakeTimer * 30.0) * amp;
				var newY = _originY + 14.0 + progress * 4.0;
				_setBodyPos(newX, newY);
				if (_shakeTimer >= 0.6)
				{
					tileState = Sinking;
					_sinkTimer = 0;
					_setBodyPos(_originX, body.position.y - TILE_H * 0.5);
					body.space = null;
				}

			case Sinking:
				_sinkTimer += elapsed;
				var t     = _sinkTimer / 3.0;
				var accel = t * t;
				y     += 1400.0 * accel * elapsed;
				angle += 15.0 * elapsed * (1.0 + t * 4.0);
				if (_sinkTimer >= 3.0)
				{
					tileState = Gone;
					visible   = false;
				}

			case Gone:
		}

		if (body != null && body.space != null)
		{
			x = body.position.x - TILE_W * 0.5;
			y = body.position.y - TILE_H * 0.5;
		}
	}

	function _setBodyY(newY:Float):Void
	{
		if (body == null) return;
		body.position.y = newY + TILE_H * 0.5;
	}

	function _setBodyPos(newX:Float, newY:Float):Void
	{
		if (body == null) return;
		body.position.setxy(newX + TILE_W * 0.5, newY + TILE_H * 0.5);
	}

	override public function destroy():Void
	{
		if (body != null) { body.space = null; body = null; }
		super.destroy();
	}
}

class GrabbedTile
{
	public var x:Float;
	public var y:Float;

	var _ropes:FlxSprite;
	var _tile:FlxSprite;

	public var body:Body;

	var _ropeH:Float;
	var _tileH:Float;
	var _tileW:Float;

	var _scaleY:Float = 1.0;
	var _onTile:Bool  = false;

	var _floorX:Float = 0;
	var _floorW:Float = 0;

	public function new(wx:Float, wy:Float, state:FlxState)
	{
		x = wx;
		y = wy;

		_ropes = new FlxSprite(wx, wy);
		_ropes.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/grabbedtile/grabbedtile"));
		_ropes.scrollFactor.set(1, 1);
		_ropes.moves = false;
		_ropeH = _ropes.height;

		_tile = new FlxSprite(wx + 130.0, wy - _ropes.height + 8.0);
		_tile.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/grabbedtile/tile"));
		_tile.scrollFactor.set(1, 1);
		_tile.moves = false;
		_tileH = _tile.height;
		_tileW = _tile.width;
		state.add(_tile);

		state.add(_ropes);

		_parseFloor();
		_buildBody(wx, wy);
	}

	function _parseFloor():Void
	{
		var graphic = Paths.image("minigame/thevalley/bg/tiles/grabbedtile/hitbox", false);
		var hb = graphic != null ? graphic.bitmap : null;
		if (hb == null) { _floorX = 0; _floorW = _tileW; return; }

		var bw   = hb.width;
		var pxs  = hb.getVector(hb.rect);
		var minX = bw; var maxX = 0;

		for (i in 0...pxs.length)
		{
			var argb = pxs[i];
			var a    = (argb >> 24) & 0xFF; if (a < 30) continue;
			var g    = (argb >>  8) & 0xFF;
			var r    = (argb >> 16) & 0xFF;
			var b    =  argb        & 0xFF;
			if (r < 40 && g > 180 && b < 40)
			{
				var px = i % bw;
				if (px < minX) minX = px;
				if (px > maxX) maxX = px;
			}
		}

		_floorX = (minX < bw) ? minX : 0;
		_floorW = (maxX > 0)  ? maxX - minX + 1 : _tileW;
	}

	function _buildBody(wx:Float, wy:Float):Void
	{
		var cx = wx + 130.0 + _floorX + _floorW * 0.5;
		var cy = wy - _ropeH + 8.0 - 6.0 * 0.5;
		body = new Body(BodyType.KINEMATIC, Vec2.weak(cx, cy));
		body.shapes.add(new Polygon(Polygon.box(_floorW, 6.0)));
		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.1, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		body.space = FlxNapeSpace.space;
	}

	public function tileUpdate(elapsed:Float, player:Player):Void
	{
		var tileTop = _tile.y;
		_onTile = player.y + player.height >= tileTop - 4
		       && player.y + player.height <= tileTop + 10
		       && player.x + player.width  >  _tile.x + _floorX
		       && player.x <  _tile.x + _floorX + _floorW;

		if (_onTile)
			_scaleY = Math.max(0.85, _scaleY - 0.4 * elapsed);
		else
			_scaleY = Math.min(1.0,  _scaleY + 0.6 * elapsed);

		_ropes.scale.y  = _scaleY;
		_ropes.origin.y = _ropeH;
		_ropes.y        = y;

		_tile.y = y + _ropeH * (1.0 - _scaleY) - _tileH + 8.0;

		if (body != null)
		{
			var targetY = _tile.y + 6.0 * 0.5;
			var delta   = targetY - body.position.y;
			body.velocity.setxy(0, delta / Math.max(elapsed, 0.0001));
		}
	}

	public function destroy():Void
	{
		if (body != null) { body.space = null; body = null; }
		if (_ropes != null) _ropes.destroy();
		if (_tile  != null) _tile.destroy();
	}
}

class SpineTile
{
	public var x:Float;
	public var y:Float;

	public var sprite(get, never):FlxSprite;
	inline function get_sprite() return _spr;

	var _spr:FlxSprite;
	var _sprW:Float;
	var _sprH:Float;

	var _hitX:Float;
	var _hitW:Float;
	var _hitH:Float;

	public function new(wx:Float, wy:Float)
	{
		x = wx;
		y = wy;

		_spr = new FlxSprite(wx, wy);
		_spr.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/spines/spines"));
		_spr.scrollFactor.set(1, 1);
		_spr.moves = false;
		_sprW = _spr.width;
		_sprH = _spr.height;

		_parseHitbox();
	}

	function _parseHitbox():Void
	{
		var graphic = Paths.image("minigame/thevalley/bg/tiles/spines/hitbox", false);
		var hb = graphic != null ? graphic.bitmap : null;
		if (hb == null) { _hitX = 0; _hitW = _sprW; _hitH = _sprH; return; }

		var bw   = hb.width;
		var bh   = hb.height;
		var pxs  = hb.getVector(hb.rect);
		var minX = bw; var maxX = 0;
		var minY = bh; var maxY = 0;

		for (i in 0...pxs.length)
		{
			var argb = pxs[i];
			var a    = (argb >> 24) & 0xFF; if (a < 30) continue;
			var g    = (argb >>  8) & 0xFF;
			var r    = (argb >> 16) & 0xFF;
			var b    =  argb        & 0xFF;
			if (r < 40 && g > 180 && b < 40)
			{
				var px = i % bw;
				var py = Std.int(i / bw);
				if (px < minX) minX = px;
				if (px > maxX) maxX = px;
				if (py < minY) minY = py;
				if (py > maxY) maxY = py;
			}
		}

		_hitX = (minX < bw) ? minX : 0;
		_hitW = (maxX > 0)  ? maxX - minX + 1 : _sprW;
		_hitH = (maxY > 0)  ? maxY - minY + 1 : _sprH;
	}

	static inline var KILL_SINK_OFFSET:Float = 24.0;

	public function checkKill(player:Player):Bool
	{
		return player.x + player.width  > x + _hitX
		    && player.x                 < x + _hitX + _hitW
		    && player.y + player.height > y + KILL_SINK_OFFSET
		    && player.y                 < y + _hitH;
	}

	static inline var WARNING_HEIGHT:Float = 20.0;

	public function checkFallingWarning(player:Player):Bool
	{
		if (player.body == null || player.body.velocity.y <= 0) return false;
		var footY = player.y + player.height;
		if (footY > y + KILL_SINK_OFFSET) return false;
		return player.x + player.width > x
		    && player.x               < x + _sprW
		    && (y - footY) <= WARNING_HEIGHT;
	}

	public function destroy():Void
	{
		if (_spr != null) _spr.destroy();
	}
}

// shi is also i thanks gonzod for the F I S I C A S
class SonicBridge
{
	public var x:Float;
	public var y:Float;
	public var totalWidth(get, never):Float;
	inline function get_totalWidth() return _estribW * 2 + 14 * _plankW;

	var _planks:Array<FlxSprite>  = [];
	var _bodies:Array<Body>       = [];
	var _baseY:Array<Float>       = [];
	var _sag:Float                = 0.0;
	var _onBridge:Bool            = false;
	var _playerPlank:Int          = -1;
	var _lastPlank:Int            = 7;

	var _plankW:Float;
	var _plankH:Float;
	var _estribW:Float;

	public function new(wx:Float, wy:Float, state:FlxState)
	{
		x = wx;
		y = wy;

		var estSample = new FlxSprite(0, 0);
		estSample.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/bridge/estribo"));
		_estribW = estSample.width;
		estSample.destroy();

		_spawnEstribo(wx, wy, state, false);

		var sample = new FlxSprite(0, 0);
		sample.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/bridge/bridge"));
		_plankW = sample.width;
		_plankH = sample.height;
		sample.destroy();

		for (i in 0...14)
		{
			var px = wx + _estribW + i * _plankW;
			var py = wy + 7.0;
			var spr = new FlxSprite(px, py);
			spr.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/bridge/bridge"));
			spr.scrollFactor.set(1, 1);
			spr.moves = false;
			state.add(spr);
			_planks.push(spr);
			_baseY.push(py);

			var bx = px + _plankW * 0.5;
			var by = py;
			var body = new Body(BodyType.KINEMATIC, Vec2.weak(bx, by + 4.0 * 0.5));
			body.shapes.add(new Polygon(Polygon.box(_plankW, 4.0)));
			body.allowRotation = false;
			body.setShapeMaterials(new Material(0.05, 0.0, 0.0, 1.0, 0.0));
			body.cbTypes.add(TVNapeWorld.CB_PLATFORM);
			body.space = FlxNapeSpace.space;
			_bodies.push(body);
		}

		_spawnEstribo(wx + _estribW + 14 * _plankW, wy, state, true);
	}

	function _spawnEstribo(ex:Float, ey:Float, state:FlxState, flipX:Bool):Void
	{
		var spr = new FlxSprite(ex, ey);
		spr.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/bridge/estribo"));
		spr.flipX = flipX;
		spr.scrollFactor.set(1, 1);
		spr.moves = false;
		state.add(spr);

		var graphic = Paths.image("minigame/thevalley/bg/tiles/bridge/estribohitbox", false);
		var hb = graphic != null ? graphic.bitmap : null;
		if (hb != null)
		{
			var bw  = hb.width;
			var bh  = hb.height;
			var pxs = hb.getVector(hb.rect);
			var minX = bw; var maxX = 0; var minY = bh; var maxY = 0;
			for (i in 0...pxs.length)
			{
				var argb = pxs[i];
				var a = (argb >> 24) & 0xFF; if (a < 30) continue;
				var g = (argb >>  8) & 0xFF;
				var r = (argb >> 16) & 0xFF;
				var b =  argb        & 0xFF;
				if (r < 40 && g > 180 && b < 40)
				{
					var px = i % bw; var py = Std.int(i / bw);
					if (px < minX) minX = px; if (px > maxX) maxX = px;
					if (py < minY) minY = py; if (py > maxY) maxY = py;
				}
			}
			if (maxX > 0)
			{
				var fw = maxX - minX + 1;
				var fh = maxY - minY + 1;
				var cx = ex + (flipX ? (spr.width - maxX - 1) : minX) + fw * 0.5;
				var cy = ey + minY + fh * 0.5;
				var body = new Body(BodyType.STATIC, Vec2.weak(cx, cy));
				body.shapes.add(new Polygon(Polygon.box(fw, fh)));
				body.allowRotation = false;
				body.setShapeMaterials(new Material(0.3, 0.0, 0.0, 1.0, 0.0));
				body.space = FlxNapeSpace.space;
			}
		}
	}

	public function bridgeUpdate(elapsed:Float, player:Player):Void
	{
		_onBridge    = false;
		_playerPlank = -1;

		var footY = player.y + player.height;
		for (i in 0...14)
		{
			var spr = _planks[i];
			var top = spr.y;
			if (footY >= top - 4 && footY <= top + 10
			&&  player.x + player.width > spr.x
			&&  player.x < spr.x + _plankW)
			{
				_onBridge    = true;
				_playerPlank = i;
				_lastPlank   = i;
				break;
			}
		}

		if (_onBridge)
			_sag = Math.min(1.0, _sag + 6.0 * elapsed);
		else
			_sag = Math.max(0.0, _sag - 4.0 * elapsed);

		for (i in 0...14)
		{
			var offset:Float = 0;
			if (_sag > 0)
			{
				var center = (_playerPlank >= 0) ? _playerPlank : _lastPlank;
				var t    = (i + 0.5) / 14;
				var arch = Math.sin(t * Math.PI); // thats literally just how a bridge sags who knew
				var dist   = Math.abs(i - center) / 14;
				var weight = Math.max(0.0, 1.0 - dist * 2.5);
				offset = arch * weight * _sag * 12.0;
			}

			var newY = _baseY[i] + offset;
			_planks[i].y = newY;

			if (_bodies[i] != null)
			{
				var targetY = newY + 4.0 * 0.5;
				var delta   = targetY - _bodies[i].position.y;
				_bodies[i].velocity.setxy(0, delta / Math.max(elapsed, 0.0001));
			}
		}
	}

	public function destroy():Void
	{
		for (b in _bodies) if (b != null) { b.space = null; }
		for (s in _planks) if (s != null) s.destroy();
		_bodies = [];
		_planks = [];
	}
}

class Launchpad extends FlxSprite
{
	public static inline var LAUNCH_VY:Float = -950.0;

	public static var CB_LAUNCHPAD:CbType = new CbType();

	public var body:Body;

	var _lState:LaunchState = LpIdle;
	var _holdTimer:Float    = 0;
	var _cooldown:Float     = 0;

	public function new(tx:Float, ty:Float)
	{
		super(tx, ty);
		frames = Paths.getSparrowAtlas("minigame/thevalley/objects/interactable/launchpad");

		animation.addByPrefix("idle",    "launchpad idle",    12, true);
		animation.addByPrefix("goingup", "launchpad goingup", 24, false);
		animation.addByPrefix("up",      "launchpad up",      12, true);
		animation.play("idle");
		scrollFactor.set(1, 1);
		moves = false;

		_buildBody(tx, ty);
	}

	function _buildBody(tx:Float, ty:Float):Void
	{
		var bw = 35.0;
		var bh = 6.0;
		var cx = tx + width * 0.5;
		var cy = ty + height - bh * 0.5;
		body = new Body(BodyType.STATIC, Vec2.weak(cx, cy));
		var shape = new Polygon(Polygon.box(bw, bh));
		body.shapes.add(shape);
		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		body.space = FlxNapeSpace.space;
	}

	public function tryLaunch(player:Player):Bool
	{
		if (_cooldown > 0 || _lState != LpIdle) return false;

		var footY  = player.y + player.height;
		var padTop = y + height - 10;
		if (footY < padTop - 8 || footY > padTop + 18) return false;
		if (player.x + player.width <= x || player.x >= x + width) return false;
		if (player.body == null || player.body.velocity.y < 0) return false;

		player.doLaunch(LAUNCH_VY);
		FlxG.sound.play(Paths.sound("minigame/thevalley/launchpad"), 0.3);

		_lState    = LpGoingUp;
		_holdTimer = 0;
		animation.play("goingup", true);
		return true;
	}

	public function padUpdate(elapsed:Float):Void
	{
		if (_cooldown > 0) { _cooldown -= elapsed; if (_cooldown < 0) _cooldown = 0; }

		switch (_lState)
		{
			case LpGoingUp:
				if (animation.curAnim != null && animation.curAnim.finished)
				{
					_lState    = LpUp;
					_holdTimer = 0;
					animation.play("up");
				}

			case LpUp:
				_holdTimer += elapsed;
				if (_holdTimer >= 0.12)
				{
					_lState = LpGoingDown;
					_playReverse();
				}

			case LpGoingDown:
				if (animation.curAnim != null && animation.curAnim.finished)
				{
					_lState   = LpIdle;
					_cooldown = 0.4;
					animation.play("idle");
				}

			case LpIdle:
		}
	}

	function _playReverse():Void
	{
		var guAnim = animation.getByName("goingup");
		if (guAnim == null) { animation.play("idle"); _lState = LpIdle; return; }
		var fwd = guAnim.frames;
		var rev:Array<Int> = [];
		var i = fwd.length - 1;
		while (i >= 0) { rev.push(fwd[i]); i--; }
		animation.add("_godown", rev, 12, false);
		animation.play("_godown");
	}

	override public function destroy():Void
	{
		if (body != null) { body.space = null; body = null; }
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

	var _skull:FlxSprite;
	var _hitzone:FlxSprite;
	var _eButton:FlxSprite;
	var _player:Player;
	var _cutscene:TVCutscene;
	var _cam:FlxCamera;
	var _state:SkullState        = SkIdle;
	var _searchTimer:Float       = 0;
	var _resultTimer:Float       = 0;
	var _win:Bool                = false;
	var _done:Bool               = false;
	var _searchSound:flixel.sound.FlxSound = null;
	var _zoomFrom:Float          = 0;

	inline function get_skullX() return _skull.x;
	inline function get_skullY() return _skull.y;

	public function new(wx:Float, wy:Float, player:Player, cutscene:TVCutscene, group:FlxTypedGroup<FlxSprite>, cam:FlxCamera)
	{
		_player   = player;
		_eButton  = cutscene.eButton;
		_cutscene = cutscene;
		_cam      = cam;

		_skull = new FlxSprite(wx, wy);
		_skull.frames = Paths.getSparrowAtlas("minigame/thevalley/bg/tiles/skulls/skulls");

		_skull.animation.addByIndices("idle",       "skulls destroying", [0], "", 1, true);
		_skull.animation.addByPrefix("destroying", "skulls destroying", 8, false);
		_skull.animation.addByPrefix("destroy",    "skulls destroy",    1, false);
		_skull.animation.play("idle");
		_skull.scrollFactor.set(1, 1);
		group.add(_skull);

		_hitzone = new FlxSprite(wx, wy);
		_hitzone.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/skulls/hitbox"));
		_hitzone.scrollFactor.set(1, 1);
		_hitzone.visible = false;
		group.add(_hitzone);
	}

	public function setPos(nx:Float, ny:Float):Void
	{
		var dx = nx - _skull.x;
		var dy = ny - _skull.y;
		_skull.x   += dx; _skull.y   += dy;
		_hitzone.x += dx; _hitzone.y += dy;
	}

	public function isBusy():Bool
		return _state == SkSearching || _state == SkResult;

	public function isDone():Bool
		return false;

	public function getDist():Float
	{
		var cx = _hitzone.x + _hitzone.width  * 0.5;
		var cy = _hitzone.y + _hitzone.height * 0.5;
		var dx = _player.x + _player.width  * 0.5 - cx;
		var dy = _player.y + _player.height * 0.5 - cy;

		if (Math.abs(dy) > 30.0) return 9999.0;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function update(elapsed:Float):Void
	{
		if (!_done) return;
		var anim = _skull.animation.curAnim;
		if (anim != null && anim.name == "destroying" && anim.finished)
			_skull.animation.play("destroy");
	}

	public function updateActive(elapsed:Float, dist:Float = 0):Void
	{
		if (_done) return;

		switch (_state)
		{
			case SkIdle:
				var t = 1.0 - Math.min(Math.max((dist - 60.0) / (INTERACT_DIST - 60.0), 0.0), 1.0);
				_eButton.alpha = t * 0.55;
				_eButton.x = _skull.x + (_skull.width  - _eButton.width)  * 0.5;
				_eButton.y = _skull.y - _eButton.height - 6;

				if (FlxG.keys.justPressed.E && dist <= 55.0)
				{
					_eButton.alpha = 0;
					_state         = SkSearching;
					_searchTimer   = 0;
					_zoomFrom      = _cam.zoom;
					_player.cinematic     = true;
					_player.mode          = thevalley.player.Player.PlayerMode.Ground;
					_player.wingOpenTimer = 0;
					_player.glideCooldown = 0;
					_player.body.velocity.setxy(0, 0);
					_player.lockedAnim    = "searching";
					_player.animation.play("searching", true);
					_searchSound = FlxG.sound.play(Paths.sound("minigame/thevalley/skullsearch"), 0.3);
				}

			case SkSearching:
				_eButton.alpha = 0;
				_searchTimer += elapsed;

				var zt = Math.min(_searchTimer / 1.5, 1.0);
				zt = 1.0 - (1.0 - zt) * (1.0 - zt);
				_cam.zoom = _zoomFrom + SEARCH_ZOOM_BUMP * zt;
				if (_searchTimer >= 1.5)
				{
					if (_searchSound != null) { _searchSound.stop(); _searchSound = null; }
					_win         = !_cutscene.skullUsedOnce ? true : Math.random() < 0.15;
					_state       = SkResult;
					_resultTimer = 0;

					_player.lockedAnim = _win ? "searchingwin" : "searchinglose";
					_player.animation.play(_win ? "searchingwin" : "searchinglose", true);
				}

			case SkResult:
				_eButton.alpha = 0;
				_resultTimer += elapsed;

				var zt2 = Math.min(_resultTimer / 0.9, 1.0);
				zt2 = 1.0 - (1.0 - zt2) * (1.0 - zt2);
				_cam.zoom = (_zoomFrom + SEARCH_ZOOM_BUMP) + (_zoomFrom - (_zoomFrom + SEARCH_ZOOM_BUMP)) * zt2;
				if (!_win)
				{
					var anim2 = _player.animation.curAnim;
					if (anim2 != null && anim2.name == "searchinglose" && anim2.finished)
						_player.animation.pause();
				}
				if (_resultTimer >= 2.0)
				{
					if (_win && _cutscene.skullUsedOnce && _cutscene.onSkullWin != null)
						_cutscene.onSkullWin();
					if (!_cutscene.skullUsedOnce)
					{
						_cutscene.skullUsedOnce = true;
						_cutscene.triggerSkullCS2();
					}
					_done  = true;
					_state = SkIdle;
					_eButton.alpha = 0;
					_skull.animation.play("destroying");
					_player.lockedAnim = null;
					_player.cinematic  = false;
					_player.animation.play("idle");
				}
		}
        
		// searching skull then you make noise. wip because still need to add more things to the skull 
		// like the cutscene DO NOT TOUCH
		if (_state == SkSearching || _state == SkResult) _player.isMakingNoise = true;
	}
}

class HoldingTile
{
	public var x:Float;
	public var y:Float;

	public var ropeSprite(get, never):FlxSprite;
	public var tileSprite(get, never):FlxSprite;
	inline function get_ropeSprite() return _ropes;
	inline function get_tileSprite() return _tile;

	var _ropes:FlxSprite;
	var _tile:FlxSprite;

	public var body:Body;

	var _ropeH:Float;
	var _tileH:Float;
	var _tileW:Float;

	var _scaleY:Float = 1.0;
	var _onTile:Bool  = false;

	public function new(wx:Float, wy:Float, state:FlxState)
	{
		x = wx;
		y = wy;

		_ropes = new FlxSprite(wx, wy);
		_ropes.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/holdingtile/cuerdas"));
		_ropes.scrollFactor.set(1, 1);
		_ropes.moves = false;
		_ropeH = _ropes.height;

		_tile = new FlxSprite(wx + 8.0, wy - _ropes.height + 8.0);
		_tile.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/holdingtile/tile"));
		_tile.scrollFactor.set(1, 1);
		_tile.moves = false;
		_tileH = _tile.height;
		_tileW = _tile.width;
		state.add(_tile);

		state.add(_ropes);

		_buildBody(wx, wy);
	}

	function _buildBody(wx:Float, wy:Float):Void
	{
		var cx = wx + _tileW * 0.5;
		var cy = wy - _ropeH + 8.0 - 6.0 * 0.5;
		body = new Body(BodyType.KINEMATIC, Vec2.weak(cx, cy));
		body.shapes.add(new Polygon(Polygon.box(_tileW, 6.0)));
		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.1, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(TVNapeWorld.CB_PLATFORM);
		body.space = FlxNapeSpace.space;
	}

	public function tileUpdate(elapsed:Float, player:Player):Void
	{
		var tileTop = _tile.y;
		_onTile = player.y + player.height >= tileTop - 4
		       && player.y + player.height <= tileTop + 10
		       && player.x + player.width  >  _tile.x
		       && player.x                 <  _tile.x + _tileW;

		if (_onTile)
			_scaleY = Math.max(0.85, _scaleY - 0.4 * elapsed);
		else
			_scaleY = Math.min(1.0,  _scaleY + 0.6 * elapsed);

		_ropes.scale.y  = _scaleY;
		_ropes.origin.y = _ropeH;
		_ropes.y        = y;

		_tile.y = y + _ropeH * (1.0 - _scaleY) - _tileH + 8.0;

		if (body != null)
		{
			var targetY = _tile.y + 6.0 * 0.5;
			var delta   = targetY - body.position.y;
			body.velocity.setxy(0, delta / Math.max(elapsed, 0.0001));
		}
	}

	public function destroy():Void
	{
		if (body != null) { body.space = null; body = null; }
		if (_ropes != null) _ropes.destroy();
		if (_tile  != null) _tile.destroy();
	}
}

class Totem
{
	static inline var HIDE_ZOOM_BUMP:Float = 0.4;
	static inline var HIDE_ZOOM_RATE:Float = 2.0;

	public var totemX(get, never):Float;
	public var totemY(get, never):Float;
	public var totemType(get, never):TotemType;
	public var isDone:Bool = false;

	var _sprite:FlxSprite;
	var _hitzone:FlxSprite;
	var _eButton:FlxSprite;
	var _player:Player;
	var _type:TotemType;
	var _state:TotemState = ToIdle;
	var _hidden:Bool = false;
	var _hideTimer:Float = 0.0;
	var _group:FlxTypedGroup<FlxSprite>;
	var _flxState:flixel.FlxState;
	var _savedFacing:FlxDirectionFlags;

	var _cam:FlxCamera;
	var _zoomFrom:Float = 0;

	var _hasHidden:Bool = false;

	inline function get_totemX()    return _sprite.x;
	inline function get_totemY()    return _sprite.y;
	inline function get_totemType() return _type;

	public function new(wx:Float, wy:Float, type:TotemType, player:Player, cutscene:TVCutscene, group:FlxTypedGroup<FlxSprite>, ?state:flixel.FlxState, ?cam:FlxCamera)
	{
		_player   = player;
		_eButton  = cutscene.eButton;
		_type     = type;
		_group    = group;
		_flxState = state;
		_cam      = cam;

		_sprite = new FlxSprite(wx, wy);
		switch (type)
		{
			case Fake:
				_sprite.frames = Paths.getSparrowAtlas("minigame/thevalley/objects/interactable/faketotem");
				_addAnim("idle",  "faketotem idle",  1,  true);
				_addAnim("press", "faketotem press", 12, false);
				_addAnim("fake",  "faketotem fake",  1,  true);
				_sprite.animation.play("idle");
			case Short:
				_sprite.loadGraphic(Paths.image("minigame/thevalley/objects/interactable/totemshort"));
			case Tall:
				_sprite.loadGraphic(Paths.image("minigame/thevalley/objects/interactable/totemtall"));
		}
		_sprite.scrollFactor.set(1, 1);
		group.add(_sprite);

		_hitzone = new FlxSprite(wx - 10, wy - 10);
		_hitzone.makeGraphic(Std.int(_sprite.width) + 20, Std.int(_sprite.height) + 20, 0x00000000);
		_hitzone.scrollFactor.set(1, 1);
		_hitzone.visible = false;
		group.add(_hitzone);
	}

	function _addAnim(name:String, prefix:String, fps:Int, loop:Bool):Void
	{
		var idxs:Array<Int> = [];
		for (fi in 0..._sprite.frames.frames.length)
			if (_sprite.frames.frames[fi].name.indexOf(prefix) == 0)
				idxs.push(fi);
		_sprite.animation.add(name, idxs, fps, loop);
	}

	public function setPos(nx:Float, ny:Float):Void
	{
		var dx = nx - _sprite.x;
		var dy = ny - _sprite.y;
		_sprite.x  += dx; _sprite.y  += dy;
		_hitzone.x += dx; _hitzone.y += dy;
	}

	public function isBusy():Bool
		return _state == ToHiding || _state == ToHidden || _state == ToRevealing;

	public function getDist():Float
	{
		var cx = _hitzone.x + _hitzone.width  * 0.5;
		var cy = _hitzone.y + _hitzone.height * 0.5;
		var dx = _player.x + _player.width  * 0.5 - cx;
		var dy = _player.y + _player.height * 0.5 - cy;

		if (Math.abs(dy) > 40.0) return 9999.0;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function updateActive(elapsed:Float, dist:Float = 0):Void
	{
		switch (_state)
		{
			case ToIdle:
				var t = 1.0 - Math.min(Math.max((dist - 60.0) / (120.0 - 60.0), 0.0), 1.0);
				if (t > 0)
				{
					_eButton.alpha = t;
					_eButton.x = _sprite.x + (_sprite.width - _eButton.width) * 0.5;
					_eButton.y = _sprite.y - _eButton.height - 6;
				}
				else
				{
					_eButton.alpha = 0;
				}

				if (FlxG.keys.justPressed.E && dist <= 70.0)
				{
					_eButton.alpha = 0;
					if (!_hidden)
					{
						_state = ToHiding;
						_hideTimer = 1.0;
						_savedFacing = _player.facing;
						_player.isHiding = true;
						_player.animation.play("hide1", true);
						if (_type == Fake) _sprite.animation.play("press", true);
						_hasHidden = true;
						if (_cam != null) _zoomFrom = _cam.zoom;
					}
					else
					{
						_state = ToRevealing;
						_player.animation.play("unhide", true);
						if (_type == Fake) _sprite.animation.play("idle", true);
					}
				}

			case ToHiding:
				_eButton.alpha = 0;
				_hideTimer -= elapsed;
				if (_hideTimer <= 0)
				{
					_hidden = true;
					_state  = ToHidden;
					_player.isHiding = false;
					_player.isHidden = true;
					_eButton.alpha = 0;
					_player.facing = FlxDirectionFlags.RIGHT;
					_player.body.velocity.setxy(0, 0);
					var h = _player.cfg.hitbox;
					var tx = _sprite.x + (_sprite.width - h.width) * 0.5 - 11;
					var ty = _sprite.y + _sprite.height - h.height;
					_player.body.position.setxy(tx + h.width * 0.5, ty + h.height * 0.5);
					_player.animation.play("hide2");
					if (_flxState != null)
					{
						_group.remove(_sprite, true);
						_flxState.add(_sprite);
					}
					if (_type == Fake)
					{
						var fa = _sprite.animation.curAnim;
						if (fa == null || fa.finished) _sprite.animation.play("fake");
					}
				}

			case ToHidden:
				_eButton.alpha = 0;
				var h2 = _player.cfg.hitbox;
				var tx2 = _sprite.x + (_sprite.width - h2.width) * 0.5 - 11;
				var ty2 = _sprite.y + _sprite.height - h2.height;
				_player.body.position.setxy(tx2 + h2.width * 0.5, ty2 + h2.height * 0.5);
				_player.body.velocity.setxy(0, 0);
				_player.facing = FlxDirectionFlags.RIGHT;

				if (FlxG.keys.justPressed.E && dist <= 70.0)
				{
					_eButton.alpha = 0;
					_state = ToRevealing;
					_player.animation.play("unhide", true);
					if (_type == Fake) _sprite.animation.play("idle", true);
				}

			case ToRevealing:
				_eButton.alpha = 0;
				var anim2 = _player.animation.curAnim;
				if (anim2 != null && anim2.name == "unhide" && anim2.finished)
				{
					_hidden = false;
					_state  = ToIdle;
					_player.isHidden = false;
					_player.body.gravMass = 1.0;

					_player.body.velocity.setxy(0, 0);
					_player.jumpHeld     = false;
					_player.jumpBufTimer = 0;
					_player.coyoteTimer = _player.cfg.tuning.coyoteFrames / 60.0;
					_player.isGrounded  = true;
					_player.mode        = thevalley.player.Player.PlayerMode.Ground;
					_player.animation.play("idle");
					if (_flxState != null)
					{
						_flxState.remove(_sprite, true);
						_group.add(_sprite);
					}
					if (_type == Fake) _sprite.animation.play("idle");
				}
		}
        
		// if player makes noise then monster detects it
		// like i mean if you hide in a totem without no reason
		if (_state == ToHiding || _state == ToRevealing) _player.isMakingNoise = true;

		_updateHideZoom(elapsed);
	}

	function _updateHideZoom(elapsed:Float):Void
	{
		if (_cam == null || !_hasHidden) return;
		var hiding = _state == ToHiding || _state == ToHidden;
		var target = hiding ? (_zoomFrom + HIDE_ZOOM_BUMP) : _zoomFrom;
		if (!hiding && Math.abs(_cam.zoom - target) < 0.01) return;
		_cam.zoom += (target - _cam.zoom) * (1.0 - Math.pow(0.01, elapsed * HIDE_ZOOM_RATE));
	}
}