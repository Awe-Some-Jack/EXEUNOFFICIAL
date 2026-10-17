package minigames.thevalley.character.player;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.GravMassMode;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.geom.Ray;
import minigames.CameraTarget;
import minigames.thevalley.map.TVNapeWorld;

enum PlayerMode { Ground; Air; Launch; WingOpen; Glide; WingClose; }

typedef PlayerConfig = {
	sprite:String,
	hitbox:{ width:Int, height:Int, offsetX:Float, offsetY:Float, frameWidth:Float, ?footRadius:Float },
	physics:{
		walkMax:Float, walkAccel:Float, walkDecel:Float, turnBrake:Float,
		runMax:Float, runAccel:Float, runDecel:Float, skidSpeed:Float, skidBrake:Float,
		tiredRunMax:Float, runEndurance:Float, runRecover:Float,
		uphillDrag:Float, downhillBoost:Float,
		airAccel:Float, airTurn:Float, airDrag:Float, airMinMax:Float,
		jumpHeight:Float, runJumpBonus:Float, jumpRiseTime:Float, fallGravityScale:Float, jumpCutVy:Float,
		apexHangVy:Float, apexHangScale:Float,
		jumpWindup:Float, runWindup:Float, tiredWindup:Float, windupDrag:Float, jumpEffort:Float,
		maxFall:Float,
		softLandDrop:Float, softLandTime:Float, hardLandDrop:Float, hardLandTime:Float, hardLandKeep:Float,
		launchVy:Float,
		glideGravity:Float, glideMaxFall:Float, glideSpeed:Float, glideAccel:Float, glideTime:Float, glideOpenVy:Float,
		wingOpenImpulse:Float, wingOpenFrames:Int, glideCooldown:Int, wingCloseMaxFall:Float
	},
	tuning:{ coyoteFrames:Int, jumpBufferFrames:Int, angleVisThresh:Float },
	animations:Array<Dynamic>
}

class Player extends FlxSprite implements CameraTarget
{
	public var cfg:PlayerConfig;
	public var body:Body;

	public var cinematic:Bool     = false;
	public var breakFalling:Bool  = false;
	public var mode:PlayerMode    = Air;
	public var inertia:Float      = 0.0;
	public var groundAngle:Float  = 0.0;
	public var jumpHeld:Bool      = false;
	public var wingOpenTimer:Float = 0;
	public var glideCooldown:Float = 0;
	public var isGrounded:Bool    = false;
	public var touchingFloor:Bool = false;
	public var onSlope:Bool       = false;
	public var coyoteTimer:Float  = 0;
	public var jumpBufTimer:Float = 0;
	public var slopeDeg:Float     = 0.0;
	public var rawAngle:Float     = 0.0;
	public var isRunning:Bool     = false;
	public var isHidden:Bool      = false;
	public var isHiding:Bool      = false;
	public var inDecoy:Bool       = false;
	public var isMakingNoise:Bool = false;

	public var inDark:Bool = false;
	public var darkZone:Int = -1;
	public var lockedAnim:String  = null;

	public var fatigue(default, null):Float = 0;

	public var sensorDistL:Int    = 0x7FFF;
	public var sensorDistC:Int    = 0x7FFF;
	public var sensorDistR:Int    = 0x7FFF;

	var _launchCooldown:Float   = 0;
	var _glideTimer:Float       = 0.0;
	var _glideCooldownSec:Float = 0.0;
	var _jumpLock:Float         = 0.0;
	var _airMax:Float           = 0.0;
	var _peakY:Float            = 0.0;
	var _lastX:Float            = 0.0;
	var _lastY:Float            = 0.0;
	var _wasGrounded:Bool       = false;
	var _landTimer:Float        = 0.0;
	var _squatTimer:Float       = 0.0;
	var _windup:Float           = 0.0;
	var _gravityOn:Bool         = true;

	public function new(spawnX:Float, spawnY:Float, configPath:String = "assets/shared/images/minigame/thevalley/characters/fakergf/fakergf.json")
	{
		super(spawnX, spawnY);

		var raw = openfl.Assets.getText(configPath);
		cfg = haxe.Json.parse(raw);

		var h = cfg.hitbox;
		frames = Paths.getSparrowAtlas(cfg.sprite);
		sparkle = new FlxSprite();
		sparkle.frames = Paths.getSparrowAtlas("minigame/thevalley/characters/fakergf/sparkle");
		sparkle.visible = false;
		sparkleGlow = new FlxSprite();
		sparkleGlow.frames = sparkle.frames;
		sparkleGlow.blend = openfl.display.BlendMode.ADD;
		sparkleGlow.visible = false;

		for (anim in cfg.animations)
		{
			if (anim.type == "prefix" || anim.type == "numindices")
			{
				var prefix:String = anim.prefix;
				var globalFrames:Array<Int> = [];
				for (fi in 0...frames.frames.length)
					if (frames.frames[fi].name.indexOf(prefix) == 0)
						globalFrames.push(fi);
				if (anim.type == "numindices")
				{
					var idxArr:Array<Int> = [for (i in (anim.indices : Array<Dynamic>)) Std.int(i)];
					var mapped:Array<Int> = [for (i in idxArr) if (i < globalFrames.length) globalFrames[i]];
					animation.add(anim.name, mapped, anim.fps, anim.loop);
				}
				else
					animation.add(anim.name, globalFrames, anim.fps, anim.loop);
			}
		}
		animation.play("idle");

		setSize(h.width, h.height);
		offset.x = h.offsetX;
		offset.y = h.offsetY;

		var rad  = h.footRadius ?? h.width * 0.5;
		var boxH = h.height - rad;
		var cx   = spawnX + h.width  * 0.5;
		var cy   = spawnY + h.height * 0.5;
		
		body = new Body(BodyType.DYNAMIC, Vec2.weak(cx, cy));

		// shii i honestly thanks gpt for this idea, i didnt know
		var footCircle = new Circle(rad, Vec2.weak(0, h.height * 0.5 - rad));
		body.shapes.add(footCircle);

		var torsoVerts = Polygon.box(h.width - 2.0, boxH);
		var torso      = new Polygon(torsoVerts);
		for (v in torso.localVerts) v.y -= rad * 0.5;
		body.shapes.add(torso);

		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(TVNapeWorld.CB_DYNAMIC);
		body.space = FlxNapeSpace.space;

		setFacingFlip(FlxDirectionFlags.LEFT,  true,  false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
		moves = false;

		_airMax = cfg.physics.airMinMax;
		_resetFall();
	}

	override public function update(elapsed:Float):Void
	{
		sparkle.visible = sparkleGlow.visible = false;
		_sparkleTime += elapsed;
		if (body == null) { super.update(elapsed); return; }

		if (cinematic || isHidden || isHiding)
		{
			_catchBreath(elapsed, 1.6);
			_windup = 0;
		}

		if (isHidden || isHiding)
		{
			body.velocity.setxy(0, 0);
			body.angularVel = 0;
			setGravity(false);
			super.update(elapsed);
			var h = cfg.hitbox;
			x = body.position.x - h.width  * 0.5;
			y = body.position.y - h.height * 0.5;
			_resetFall();
			return;
		}

		_detectGround(elapsed);
		_applyModeGravity(elapsed);

		if (body.velocity.y > cfg.physics.maxFall) body.velocity.y = cfg.physics.maxFall;

		if (_launchCooldown > 0) _launchCooldown -= elapsed;
		if (glideCooldown  > 0) glideCooldown -= elapsed;
		if (_jumpLock      > 0) _jumpLock -= elapsed;
		if (_landTimer     > 0) _landTimer -= elapsed;
		if (_squatTimer    > 0) _squatTimer -= elapsed;
		if (_glideCooldownSec > 0) _glideCooldownSec -= elapsed;
		if (mode == Glide && !cinematic)
		{
			_glideTimer -= elapsed;
			if (_glideTimer <= 0) { _glideTimer = 0; mode = WingClose; _glideCooldownSec = 1.0; }
		}

		_trackFall();

		if (isGrounded)
		{
			_glideTimer = 0;
			_glideCooldownSec = 0;

			coyoteTimer = cfg.tuning.coyoteFrames / 60.0;

			if (cinematic)
			{
				body.velocity.x = 0;
				if (_gravityOn && onSlope) body.velocity.y = Math.min(body.velocity.y, 0) - TVNapeWorld.GRAVITY * elapsed;
			}
		}
		else if (coyoteTimer > 0) coyoteTimer -= elapsed;

		var h = cfg.hitbox;
		x = body.position.x - h.width  * 0.5;
		y = body.position.y - h.height * 0.5;

		velocity.x = body.velocity.x;
		velocity.y = body.velocity.y;

		super.update(elapsed);
	}    

	public var sparkle(default, null):FlxSprite;
	public var sparkleGlow(default, null):FlxSprite;
	var _sparkleTime:Float = 0;

	override public function draw():Void
	{
		super.draw();
		final f = frame;
		if (f == null || f.name == null || !StringTools.startsWith(f.name, "fakergf win0")) return;
		final sf = sparkle.frames.getByName("sparkle" + f.name.substr(7));
		if (sf == null) return;
		for (s in [sparkle, sparkleGlow])
		{
			s.frame = sf;
			s.setPosition(x, y);
			s.offset.copyFrom(offset);
			s.origin.copyFrom(origin);
			s.scale.copyFrom(scale);
			s.angle = angle;
			s.flipX = flipX;
			s.antialiasing = antialiasing;
			s.scrollFactor.copyFrom(scrollFactor);
			s.cameras = cameras;
			s.visible = true;
		}
		sparkle.alpha = alpha;
		sparkleGlow.alpha = alpha * (0.35 + 0.25 * Math.sin(_sparkleTime * 6.0));
	}

	// shoots 3 little invisible lasers down outta the feet like kaboom type shi
	function _detectGround(elapsed:Float):Void
	{
		if (_launchCooldown > 0) { isGrounded = touchingFloor = onSlope = false; groundAngle = 0; return; }

		if (body.velocity.y < -150) { isGrounded = touchingFloor = onSlope = false; return; } // movin up too fast? bro is NOT touchin grass rn

		isGrounded    = false;
		onSlope       = false;
		groundAngle   = 0.0;
		touchingFloor = false;

		var h       = cfg.hitbox;
		var halfW   = h.width  * 0.5;
		var footY   = body.position.y + h.height * 0.5;
		var DIST:Float = 10.0;

		var rayDir = Vec2.get(0, 1);

		var offsets:Array<Float> = [ -halfW * 0.7, 0.0, halfW * 0.7 ];
		var shortestDist:Float = DIST + 1.0;

		for (ox in offsets)
		{
			var orig = Vec2.get(body.position.x + ox, footY - 2);
			var ray  = new Ray(orig, rayDir);
			ray.maxDistance = DIST;

			var res = body.space.rayCast(ray, false);
			orig.dispose();

			if (res != null)
			{
				isGrounded    = true;
				touchingFloor = true;

				if (res.distance < shortestDist)
				{
					shortestDist = res.distance;
					var nx = res.normal.x;
					var ny = res.normal.y;
					var ang = Math.atan2(nx, -ny) * (180.0 / Math.PI);

					if (Math.abs(ang) <= 85.0) 
					{
						groundAngle = ang;
						onSlope = (Math.abs(ang) > 5.0);
					}
				}
				res.dispose();
			}
		}
		rayDir.dispose();

		var inAerialMove = mode == WingOpen || mode == Glide || mode == WingClose || mode == Launch;
		if (isGrounded) { if (!inAerialMove) mode = Ground; }
		else { touchingFloor = false; if (mode == Ground) mode = Air; }
	}

	function _projectOnSlope():Void
	{
		if (!isGrounded || Math.abs(groundAngle) < 3.0) return;

		var rad = groundAngle * (Math.PI / 180.0);
		var tx  = Math.cos(rad);
		var ty  = Math.sin(rad);
		var dot = body.velocity.x * tx + body.velocity.y * ty;
		body.velocity.x = dot * tx;
		body.velocity.y = dot * ty;
	}

	function _glue(elapsed:Float):Void
	{
		if (!isGrounded || mode != Ground || !_gravityOn || _jumpLock > 0 || body.velocity.y < -60) return;
		body.velocity.y -= TVNapeWorld.GRAVITY * elapsed;

		final footY = body.position.y + cfg.hitbox.height * 0.5;
		final orig = Vec2.get(body.position.x, footY - 2);
		final down = Vec2.get(0, 1);
		final ray = new Ray(orig, down);
		ray.maxDistance = 12.0;
		final res = body.space.rayCast(ray, false);
		orig.dispose();
		down.dispose();
		if (res == null) return;
		final gap = res.distance - 2;
		res.dispose();
		if (gap > 1.0) body.position.y += gap - 0.5;
	}

	function _stepUp(dir:Int):Void
	{
		if (Math.abs(groundAngle) > 5.0) return;

		final h     = cfg.hitbox;
		final footY = body.position.y + h.height * 0.5;
		final step  = TVNapeWorld.ONE_WAY_STEP;
		final orig  = Vec2.get(body.position.x + dir * (h.width * 0.5 + 2.0), footY - step - 1.0);
		final down  = Vec2.get(0, 1);
		final ray   = new Ray(orig, down);
		ray.maxDistance = step + 1.0;
		final res = body.space.rayCast(ray, false);
		orig.dispose();
		down.dispose();
		if (res == null) return;

		final rise = step + 1.0 - res.distance;
		final ledge = !res.shape.body.isDynamic() && res.normal.y < -0.99 && rise > 0.5 && rise <= step;
		res.dispose();
		if (ledge) body.position.y -= rise;
	}

	public function cameraX():Float return x + width * 0.5;

	public function cameraY():Float return y + height * 0.5;

	public function cameraGrounded():Bool return isGrounded || isHidden || isHiding;

	public function cameraSpeed():Float return cinematic || isHidden || isHiding ? 0 : body.velocity.x / cfg.physics.runMax;

	public function cameraCanLook():Bool return isGrounded && !cinematic && Math.abs(body.velocity.x) < 5;

	function _updateFatigue(elapsed:Float, grounded:Bool, moving:Bool):Void
	{
		final p = cfg.physics;
		if (isRunning && Math.abs(body.velocity.x) > p.walkMax)
			fatigue = Math.min(1, fatigue + elapsed / p.runEndurance);
		else if (grounded)
			_catchBreath(elapsed, moving ? 1.0 : 1.6);
	}

	inline function _catchBreath(elapsed:Float, rate:Float):Void
	{
		fatigue = Math.max(0, fatigue - elapsed / cfg.physics.runRecover * rate);
	}

	function _runSpeed():Float
	{
		final p = cfg.physics;
		final t = Math.max(0, Math.min(1, (fatigue - 0.4) / (1 - 0.4)));
		return p.runMax - (p.runMax - p.tiredRunMax) * t * t * (3 - 2 * t);
	}

	public function setGravity(on:Bool):Void
	{
		_gravityOn = on;
		if (on) body.gravMassMode = GravMassMode.DEFAULT;
		else body.gravMass = 0;
	}

	inline function _riseGravity():Float
	{
		final p = cfg.physics;
		return 2 * p.jumpHeight / (p.jumpRiseTime * p.jumpRiseTime);
	}

	function _applyModeGravity(elapsed:Float):Void
	{
		var p = cfg.physics;
		switch (mode)
		{
			case WingOpen:
				body.velocity.y -= TVNapeWorld.GRAVITY * 0.6 * elapsed;
				if (body.velocity.y > p.glideMaxFall) body.velocity.y = p.glideMaxFall;
				if (wingOpenTimer > 0) { wingOpenTimer -= elapsed; if (wingOpenTimer <= 0) { wingOpenTimer = 0; mode = Glide; } }
			case Glide:
				body.velocity.y += (p.glideGravity - TVNapeWorld.GRAVITY) * elapsed;
				if (body.velocity.y > p.glideMaxFall) body.velocity.y = p.glideMaxFall;
			case WingClose:
				if (body.velocity.y > p.wingCloseMaxFall) body.velocity.y = p.wingCloseMaxFall;
			case Launch:
				if (body.velocity.y >= 0) mode = Air;
			default:
				if (isGrounded || !_gravityOn) return;
				var g = body.velocity.y < 0 ? _riseGravity() : _riseGravity() * p.fallGravityScale;
				if (jumpHeld && Math.abs(body.velocity.y) < p.apexHangVy) g *= p.apexHangScale;
				body.velocity.y += (g - TVNapeWorld.GRAVITY) * elapsed;
				if (!jumpHeld && body.velocity.y < -p.jumpCutVy)
					body.velocity.y = -p.jumpCutVy;
		}
	}

	function _resetFall():Void
	{
		_lastX = body.position.x;
		_lastY = _peakY = body.position.y;
		_wasGrounded = isGrounded;
	}

	function _trackFall():Void
	{
		final jumped = Math.abs(body.position.x - _lastX) > 48.0 || Math.abs(body.position.y - _lastY) > 48.0;
		if (jumped || cinematic || mode == WingOpen || mode == Glide || mode == Launch)
		{
			_resetFall();
			return;
		}
		_lastX = body.position.x;
		_lastY = body.position.y;
		if (isGrounded)
		{
			if (!_wasGrounded) _land(body.position.y - _peakY);
			_peakY = body.position.y;
		}
		else if (body.position.y < _peakY) _peakY = body.position.y;
		_wasGrounded = isGrounded;
	}

	function _land(drop:Float):Void
	{
		final p = cfg.physics;
		jumpHeld = false;
		if (drop >= p.hardLandDrop)
		{
			_landTimer = _squatTimer = p.hardLandTime;
			body.velocity.x *= p.hardLandKeep;
		}
		else if (drop >= p.softLandDrop && Math.abs(body.velocity.x) < p.walkMax)
			_squatTimer = p.softLandTime;
	}

	static inline function _approach(v:Float, target:Float, step:Float):Float
	{
		return v < target ? Math.min(target, v + step) : Math.max(target, v - step);
	}

	function _slopeFactor(dir:Int):Float
	{
		if (!onSlope) return 1.0;
		final p = cfg.physics;
		final s = Math.sin(Math.abs(groundAngle) * (Math.PI / 180.0));
		return dir * groundAngle < 0 ? 1 - p.uphillDrag * s : 1 + p.downhillBoost * s;
	}

	function _groundMove(vx:Float, dir:Int, elapsed:Float):Float
	{
		final p = cfg.physics;
		if (dir == 0)
			return _approach(vx, 0, (Math.abs(vx) > p.walkMax ? p.runDecel : p.walkDecel) * elapsed);
		if (vx * dir < 0)
			return _approach(vx, 0, (Math.abs(vx) > p.skidSpeed ? p.skidBrake : p.turnBrake) * elapsed);

		final target = (isRunning ? _runSpeed() : p.walkMax) * _slopeFactor(dir);
		final speed  = vx * dir;
		if (speed > target) return dir * Math.max(target, speed - 450.0 * elapsed);
		final accel = speed < p.walkMax ? p.walkAccel : p.runAccel;
		return dir * Math.min(target, speed + accel * elapsed);
	}

	function _airMove(vx:Float, dir:Int, elapsed:Float):Float
	{
		final p = cfg.physics;
		final gliding = mode == WingOpen || mode == Glide;
		if (gliding) _airMax = Math.max(_airMax, Math.abs(vx));
		final max = gliding ? Math.max(_airMax, p.glideSpeed) : _airMax;

		if (dir == 0) return _approach(vx, 0, p.airDrag * elapsed);
		if (vx * dir < 0) return vx + dir * p.airTurn * elapsed;

		final speed = vx * dir;
		if (speed >= max) return dir * Math.max(max, speed - p.airDrag * elapsed);
		return dir * Math.min(max, speed + (gliding ? p.glideAccel : p.airAccel) * elapsed);
	}

	inline function _runFrac(speed:Float):Float
	{
		final p = cfg.physics;
		return Math.max(0, Math.min(1, (speed - p.walkMax) / (p.runMax - p.walkMax)));
	}

	function _takeOff(held:Bool):Void
	{
		final p = cfg.physics;
		final speed = Math.abs(body.velocity.x);
		body.velocity.y = -Math.sqrt(2 * _riseGravity() * (p.jumpHeight + p.runJumpBonus * _runFrac(speed)));
		_airMax     = Math.max(p.airMinMax, speed);
		jumpHeld    = held;
		isGrounded  = false;
		coyoteTimer = jumpBufTimer = 0;
		_windup     = 0;
		_jumpLock   = 0.1;
		mode = Air;
	}

	public function handleInput(elapsed:Float, spawnX:Float, spawnY:Float):Bool
	{
		var p = cfg.physics;
		var t = cfg.tuning;
		if (cinematic) return false;

		if (isHidden || isHiding) return false;

		final left        = FlxG.keys.pressed.LEFT  || FlxG.keys.pressed.A;
		final right       = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;
		final shift       = FlxG.keys.pressed.SHIFT;
		final jumpJust    = FlxG.keys.justPressed.SPACE;
		final jumpRel     = FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE;
		final jumpHeldNow = FlxG.keys.pressed.Z     || FlxG.keys.pressed.SPACE;

		if (jumpRel)  jumpHeld = false;
		if (jumpJust) jumpBufTimer = t.jumpBufferFrames / 60.0;

		final gnd = coyoteTimer > 0;
		if (gnd && (mode == Glide || mode == WingOpen || mode == WingClose))
		{
			mode = Ground;
			wingOpenTimer = glideCooldown = 0;
			_glideTimer = 0;
			_glideCooldownSec = 0;
		}

		final recovering = gnd && _landTimer > 0;
		final winding    = _windup > 0;
		if (right)     facing = FlxDirectionFlags.RIGHT;
		else if (left) facing = FlxDirectionFlags.LEFT;
		final dir = recovering || winding ? 0 : (right ? 1 : (left ? -1 : 0));

		//gf cardio simulator. she out here doin more exercise than me fr fatass chair
		isRunning = gnd && shift && dir != 0;
		_updateFatigue(elapsed, gnd, dir != 0);

		var vx = winding ? _approach(body.velocity.x, 0, p.windupDrag * elapsed)
			: gnd ? _groundMove(body.velocity.x, dir, elapsed) : _airMove(body.velocity.x, dir, elapsed);
		body.velocity.x = vx;
		inertia = vx;
		if (gnd) _airMax = Math.max(p.airMinMax, Math.abs(vx));

		_projectOnSlope();
		if (gnd && isGrounded && dir != 0) _stepUp(dir);
		_glue(elapsed);

		if (winding)
		{
			_windup -= elapsed;
			if (_windup <= 0 || !isGrounded) _takeOff(jumpHeldNow);
		}
		else if (jumpBufTimer > 0 && gnd && !recovering && _jumpLock <= 0)
		{
			if (isGrounded)
			{
				final runFrac = _runFrac(Math.abs(vx));
				_windup = p.jumpWindup + (p.runWindup - p.jumpWindup) * runFrac + p.tiredWindup * fatigue;
				fatigue = Math.min(1, fatigue + p.jumpEffort);
				jumpBufTimer = 0;
			}
			else _takeOff(jumpHeldNow);
		}

		if (jumpJust && !gnd && mode == Air && body.velocity.y > p.glideOpenVy && glideCooldown <= 0 && _glideCooldownSec <= 0 && lockedAnim != "fallingtodeath")
		{
			body.velocity.y = Math.min(body.velocity.y, p.wingOpenImpulse);
			wingOpenTimer   = p.wingOpenFrames / 60.0;
			glideCooldown   = p.glideCooldown / 60.0;
			_glideTimer     = p.glideTime;
			mode            = WingOpen;
		}
		else if (!jumpHeldNow && mode == Glide)
			mode = WingClose;

		if (jumpBufTimer > 0 && !recovering) jumpBufTimer -= elapsed;

		return false;
	}

	var _idleTime:Float = 0;

	public function updateAnim(elapsed:Float):Void
	{
		var p = cfg.physics;
		if (isHidden || isHiding) { _idleTime = 0; return; }
		if (lockedAnim != null)
		{
			_idleTime = 0;
			var cur0 = animation.curAnim;
			if (cur0 == null || cur0.name != lockedAnim)
				animation.play(lockedAnim, true);
			return;
		}
		if (cinematic)
		{
			_idleTime = 0;
			var cur = animation.curAnim;
			var isBreakAnim = cur != null && (cur.name == "break_idle" || cur.name == "break_tap" || cur.name == "break_full");
			if (!isBreakAnim && isGrounded && (cur == null || cur.name != "idle"))
				animation.play("idle");
			return;
		}

		var gnd  = coyoteTimer > 0;
		var absV = Math.abs(body.velocity.x);
		var down = FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S;
		var up   = FlxG.keys.pressed.UP   || FlxG.keys.pressed.W;

		var animName:String;
		if (mode == Launch)
			animName = "launch";
		else if (mode == WingOpen)
			animName = "wingopen";
		else if (mode == Glide)
			animName = "glide";
		else if (mode == WingClose)
		{
			animName = "wingclose";
			if (animation.curAnim != null && animation.curAnim.name == "wingclose" && animation.curAnim.finished)
				mode = Air;
		}
		else if (!gnd)
			animName = "jump";
		else
		{
			if (mode == Air) mode = Ground;
			if      (_squatTimer > 0 || _windup > 0) animName = "crouch";
			else if (down && absV < 5)        animName = "crouch";
			else if (up   && absV < 5)        animName = "lookup";
			else if (absV > 5 && isRunning)   animName = "run";
			else if (absV > 5)                animName = "walk";
			else
			{
				_idleTime = FlxG.keys.pressed.ANY ? 0 : _idleTime + elapsed;
				final cur = animation.curAnim;
				final boredDone = cur != null && (cur.name == "boredloop" || (cur.name == "bored" && cur.finished));
				animName = _idleTime < 8.0 ? "idle" : (boredDone ? "boredloop" : "bored");
			}
		}
		if (animName != "idle" && animName != "bored" && animName != "boredloop") _idleTime = 0;

		if (animation.curAnim == null || animation.curAnim.name != animName)
			animation.play(animName, true);

		if (animName == "walk")
			animation.curAnim.frameRate = 6 + Std.int((absV / p.walkMax) * 12);
		else if (animName == "run")
			animation.curAnim.frameRate = 4 + Std.int((absV / p.runMax) * 16);

		angle = 0;
	}

	public function doLaunch(vy:Float = 0):Void
	{
		body.position.y -= 5; 

		body.velocity.y = 0; 
		body.velocity.y = (vy != 0) ? vy : cfg.physics.launchVy;

		isGrounded      = false;
		touchingFloor   = false;
		jumpHeld        = false;
		mode            = Launch;
		_airMax         = Math.max(_airMax, cfg.physics.glideSpeed);
		_windup         = 0;
		_launchCooldown = 20.0 / 60.0;
	}
}