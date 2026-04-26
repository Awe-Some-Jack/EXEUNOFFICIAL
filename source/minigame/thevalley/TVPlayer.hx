package minigame.thevalley;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import backend.Controls;

enum PlayerMode { Ground; Air; Launch; WingOpen; Glide; WingClose; }

class TVPlayer extends FlxSprite
{
	public static inline var WALK_ACCEL:Float        = 420.0;
	public static inline var WALK_DECEL:Float        = 540.0;
	public static inline var WALK_BRAKE:Float        = 900.0;
	public static inline var WALK_MAX:Float          = 180.0;

	public static inline var AIR_ACCEL:Float         = 300.0;
	public static inline var AIR_MAX:Float           = 180.0;

	public static inline var JUMP_VY:Float           = -460.0;
	public static inline var JUMP_CUT:Float          = -180.0;

	public static inline var GRAVITY:Float           = 900.0;
	public static inline var MAX_FALL:Float          = 700.0;

	public static inline var LAUNCH_VY:Float         = -580.0;

	public static inline var GLIDE_GRAVITY:Float     = 120.0;
	public static inline var GLIDE_MAX_FALL:Float    = 60.0;
	public static inline var WINGOPEN_IMPULSE:Float  = -120.0;
	public static inline var WINGOPEN_FRAMES:Int     = 18;
	public static inline var GLIDE_COOLDOWN:Int      = 90;

	public static inline var SLOPE_RESIST:Float      = 300.0;
	public static inline var SLOPE_SLIDE_ANGLE:Float = 30.0;
	public static inline var SLOPE_SLIDE_SPEED:Float = 40.0;

	static inline var HB_W:Int = 18;
	static inline var HB_H:Int = 38;

	static inline var COYOTE_FRAMES:Int      = 5;
	static inline var JUMP_BUFFER_FRAMES:Int = 8;

	public var mode:PlayerMode   = Air;
	public var inertia:Float     = 0.0;
	public var groundAngle:Float = 0.0;
	public var jumpHeld:Bool     = false;
	public var wingOpenTimer:Int = 0;
	public var glideCooldown:Int = 0;

	public var isGrounded:Bool  = false;
	public var touchingFloor:Bool = false;
	public var onSlope:Bool     = false;
	public var coyoteTimer:Int  = 0;
	public var jumpBufTimer:Int = 0;
	public var slopeDeg:Float   = 0.0;
	public var rawAngle:Float   = 0.0;

	var _prevRawAngle:Float  = 0.0;
	var _displayAngle:Float  = 0.0;

	static inline var ANGLE_VIS_THRESH:Float = 8.0;

	final _sensorAngle:Array<Float> = [0.0];

	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = backend.Paths.getSparrowAtlas('minigame/thevalley/fakergf');

		animation.addByPrefix("idle",      "fakergf idle",      12, true);
		animation.addByPrefix("walk",      "fakergf walk",      12, true);
		animation.addByPrefix("jump",      "fakergf jump",       1, true);
		animation.addByPrefix("crouch",    "fakergf crouch",     1, false);
		animation.addByPrefix("up",        "fakergf up",         1, false);
		animation.addByPrefix("launch",    "fakergf up",         1, false);
		animation.addByPrefix("wingopen",  "fakergf wingopen",   8, false);
		animation.addByIndices("wingclose","fakergf wingopen", [3, 2, 1, 0], "", 18, false);
		animation.addByPrefix("glide",     "fakergf glide",      8, true);
		animation.play("idle");

		setSize(HB_W, HB_H);
		offset.x = (60 - HB_W) / 2.0;
		offset.y = 9;

		drag.set(0, 0);
		maxVelocity.set(AIR_MAX + 50, 2000);

		setFacingFlip(FlxDirectionFlags.LEFT,  true,  false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
	}

	public function updateSensors(slopeMap:TVSlopeMap, launchCooldown:Int,
	                               floorScanGnd:Int, floorScanAir:Int,
	                               sensorDiffMax:Int):Void
	{
		if (launchCooldown > 0)
		{
			touchingFloor = onSlope = isGrounded = false;
			slopeDeg = rawAngle = 0;
			return;
		}

		var lx    = Std.int(x + width * 0.25);
		var cx    = Std.int(x + width * 0.50);
		var rx    = Std.int(x + width * 0.75);
		var footY = Std.int(y + height);

		var scanDown = (velocity.y >= 0) ? floorScanGnd : floorScanAir;

		var dL = slopeMap.findFloor(lx, footY, scanDown, _sensorAngle);
		var dR = slopeMap.findFloor(rx, footY, scanDown, _sensorAngle);
		var dC = slopeMap.findFloor(cx, footY, scanDown, _sensorAngle);

		if (dL != TVSlopeMap.MISS_DIST && dR != TVSlopeMap.MISS_DIST)
		{
			var diff = dL - dR;
			if      (diff < -sensorDiffMax) dL = TVSlopeMap.MISS_DIST;
			else if (diff >  sensorDiffMax) dR = TVSlopeMap.MISS_DIST;
		}
		if (dC != TVSlopeMap.MISS_DIST)
		{
			if (dL != TVSlopeMap.MISS_DIST && (dC - dL) > sensorDiffMax) dC = TVSlopeMap.MISS_DIST;
			if (dR != TVSlopeMap.MISS_DIST && (dC - dR) > sensorDiffMax) dC = TVSlopeMap.MISS_DIST;
		}

		if (dL == TVSlopeMap.MISS_DIST && dC != TVSlopeMap.MISS_DIST) dL = dC;
		if (dR == TVSlopeMap.MISS_DIST && dC != TVSlopeMap.MISS_DIST) dR = dC;
		if (dL == TVSlopeMap.MISS_DIST && dR != TVSlopeMap.MISS_DIST) dL = dR;
		if (dR == TVSlopeMap.MISS_DIST && dL != TVSlopeMap.MISS_DIST) dR = dL;

		sensorDistL = dL;
		sensorDistC = dC;
		sensorDistR = dR;

		touchingFloor = (dL != TVSlopeMap.MISS_DIST && dL <= 0)
					 || (dC != TVSlopeMap.MISS_DIST && dC <= 0)
					 || (dR != TVSlopeMap.MISS_DIST && dR <= 0)
					 || isTouching(FlxDirectionFlags.FLOOR);

		onSlope = dL != TVSlopeMap.MISS_DIST
			   && dR != TVSlopeMap.MISS_DIST
			   && dL != dR
			   && (dL <= 0 || dR <= 0);

		var canLand = (mode == Ground)
		           || (mode == Air && velocity.y >= 0)
		           || ((mode == WingOpen || mode == Glide || mode == WingClose) && touchingFloor);
		isGrounded = (touchingFloor || onSlope) && canLand;

		if (isGrounded && dL != TVSlopeMap.MISS_DIST && dR != TVSlopeMap.MISS_DIST && dL != dR)
		{
			var deg = Math.atan2(dR - dL, width * 0.5) * (180.0 / Math.PI);
			rawAngle     = TVSlopeMap.degToS1(deg);
			slopeDeg     = Math.abs(deg);
			_prevRawAngle = rawAngle;
		}
		else if (isGrounded)
		{
			rawAngle     = _prevRawAngle * 0.5;
			slopeDeg     = Math.abs(TVSlopeMap.s1ToDeg(rawAngle));
			_prevRawAngle = rawAngle;
		}
		else
		{
			rawAngle = slopeDeg = _prevRawAngle = 0;
		}
	}

	public var sensorDistL:Int = TVSlopeMap.MISS_DIST;
	public var sensorDistC:Int = TVSlopeMap.MISS_DIST;
	public var sensorDistR:Int = TVSlopeMap.MISS_DIST;

	public function slopeSnap(launchCooldown:Int, snapMax:Int):Void
	{
		if (launchCooldown > 0 || velocity.y < 0) return;

		var best = TVSlopeMap.MISS_DIST;
		inline function consider(d:Int):Void
			if (d != TVSlopeMap.MISS_DIST && (best == TVSlopeMap.MISS_DIST || d < best)) best = d;
		consider(sensorDistL);
		consider(sensorDistC);
		consider(sensorDistR);

		if (best == TVSlopeMap.MISS_DIST) return;

		if (best < -(snapMax + 1)) return;

		if (best > snapMax)
		{
			if (isGrounded && mode == Ground)
			{
				mode        = Air;
				isGrounded  = false;
				groundAngle = 0;
			}
			return;
		}

		if (best != 0) y += best;
		velocity.y  = 0;
		groundAngle = rawAngle;

		if (mode == Air || mode == WingOpen || mode == Glide || mode == WingClose)
		{
			mode          = Ground;
			isGrounded    = true;
			inertia       = velocity.x;
			wingOpenTimer = 0;
		}
	}

	public function wallPush(slopeMap:TVSlopeMap):Void
	{
		var midY      = Std.int(y + height * 0.4);
		var rightEdge = Std.int(x + width);

		if (slopeMap.isNarrowSlopeAt(rightEdge, midY))
		{
			var d = slopeMap.findWallRight(rightEdge, midY);
			if (d != TVSlopeMap.MISS_DIST && d > 0)
			{
				x -= d;
				if (velocity.x > 0) velocity.x = 0;
				if (isGrounded && inertia > 0) inertia = 0;
			}
		}

		var leftEdge = Std.int(x);
		if (slopeMap.isNarrowSlopeAt(leftEdge - 1, midY))
		{
			var d = slopeMap.findWallLeft(leftEdge, midY);
			if (d != TVSlopeMap.MISS_DIST && d > 0)
			{
				x += d;
				if (velocity.x < 0) velocity.x = 0;
				if (isGrounded && inertia < 0) inertia = 0;
			}
		}
	}

	public function applyPhysics(elapsed:Float, launchCooldown:Int):Void
	{
		if (isGrounded && launchCooldown == 0)
		{
			if (velocity.y >= 0) velocity.y = 0;

			var slopeDy   = (sensorDistL != TVSlopeMap.MISS_DIST && sensorDistR != TVSlopeMap.MISS_DIST)
			                ? (sensorDistR - sensorDistL) : 0.0;
			var sinA      = Math.sin(Math.atan2(slopeDy, width * 0.5));

			inertia -= sinA * SLOPE_RESIST * elapsed;
			if (slopeDeg > SLOPE_SLIDE_ANGLE && Math.abs(inertia) < SLOPE_SLIDE_SPEED)
				inertia -= sinA * SLOPE_RESIST * 1.5 * elapsed;

			velocity.x = inertia;
			velocity.y = 0;
		}
		else if (mode == Launch)
		{
			velocity.y += GRAVITY * elapsed;
			if (velocity.y > MAX_FALL) velocity.y = MAX_FALL;
			if (velocity.y >= 0) mode = Air;
		}
		else if (mode == WingOpen)
		{
			velocity.y += GRAVITY * 0.4 * elapsed;
			if (velocity.y > GLIDE_MAX_FALL) velocity.y = GLIDE_MAX_FALL;
			inertia = velocity.x;
			if (wingOpenTimer > 0)
			{
				wingOpenTimer--;
				if (wingOpenTimer == 0) mode = Glide;
			}
		}
		else if (mode == Glide)
		{
			velocity.y += GLIDE_GRAVITY * elapsed;
			if (velocity.y > GLIDE_MAX_FALL) velocity.y = GLIDE_MAX_FALL;
			inertia = velocity.x;
		}
		else if (mode == WingClose)
		{
			velocity.y += GLIDE_GRAVITY * 2.0 * elapsed;
			if (velocity.y > MAX_FALL) velocity.y = MAX_FALL;
			inertia = velocity.x;
		}
		else
		{
			velocity.y += GRAVITY * elapsed;
			if (velocity.y > MAX_FALL) velocity.y = MAX_FALL;
			if (!jumpHeld && velocity.y < JUMP_CUT) velocity.y = JUMP_CUT;
			inertia = velocity.x;
		}
	}

	public function handleInput(elapsed:Float, controls:Controls, spawnX:Float, spawnY:Float):Bool
	{
		if (FlxG.keys.justPressed.R)
		{
			x = spawnX; y = spawnY;
			velocity.set(0, 0);
			inertia       = 0;
			groundAngle   = 0;
			mode          = Air;
			isGrounded    = false;
			coyoteTimer   = 0;
			jumpBufTimer  = 0;
			glideCooldown = 0;
			wingOpenTimer = 0;
			_displayAngle = 0;
			angle         = 0;
			return true;
		}

		var left     = controls.UI_LEFT  || FlxG.keys.pressed.A;
		var right    = controls.UI_RIGHT || FlxG.keys.pressed.D;
		var jumpJust = controls.ACCEPT   || FlxG.keys.justPressed.SPACE;
		var jumpRel  = FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE;
		var jumpHeldNow = FlxG.keys.pressed.Z   || FlxG.keys.pressed.SPACE;

		if (jumpRel)  jumpHeld    = false;
		if (jumpJust) jumpBufTimer = JUMP_BUFFER_FRAMES;

		var gnd = coyoteTimer > 0;

		if (gnd && (mode == Glide || mode == WingOpen || mode == WingClose))
		{
			mode          = Ground;
			wingOpenTimer = 0;
			glideCooldown = 0;
		}

		if (gnd) _groundMove(elapsed, left, right);
		else     _airMove(elapsed, left, right);

		if (jumpBufTimer > 0 && gnd)
		{
			var ar    = TVSlopeMap.s1ToRad(groundAngle);
			velocity.x  = inertia;
			velocity.y  = JUMP_VY;
			velocity.x -= JUMP_VY * Math.sin(ar);
			inertia     = velocity.x;
			jumpHeld    = true;
			isGrounded  = false;
			coyoteTimer = 0;
			jumpBufTimer = 0;
			mode        = Air;
		}

		if (jumpJust && !gnd && mode == Air
		    && velocity.y > -50 && glideCooldown == 0)
		{
			velocity.y    = WINGOPEN_IMPULSE;
			wingOpenTimer = WINGOPEN_FRAMES;
			glideCooldown = GLIDE_COOLDOWN;
			mode          = WingOpen;
		}
		else if (!jumpHeldNow && mode == Glide)
		{
			mode = WingClose;
		}

		return false;
	}

	public function updateCoyote():Void
	{
		if (isGrounded) coyoteTimer = COYOTE_FRAMES;
		else if (coyoteTimer > 0) coyoteTimer--;
	}

	public function updateAnim(elapsed:Float, controls:Controls):Void
	{
		var gnd  = coyoteTimer > 0;
		var absV = Math.abs(inertia);
		var down = controls.UI_DOWN || FlxG.keys.pressed.S;
		var up   = controls.UI_UP   || FlxG.keys.pressed.W;

		var animName:String;

		if (mode == Launch)         animName = "launch";
		else if (mode == WingOpen)  animName = "wingopen";
		else if (mode == Glide)     animName = "glide";
		else if (mode == WingClose)
		{
			animName = "wingclose";
			if (animation.curAnim != null
			    && animation.curAnim.name == "wingclose"
			    && animation.curAnim.finished)
				mode = Air;
		}
		else if (!gnd)              animName = "jump";
		else
		{
			if (mode == Air) mode = Ground;

			if      (down && absV < 5) animName = "crouch";
			else if (up   && absV < 5) animName = "up";
			else if (absV > 5)         animName = "walk";
			else                       animName = "idle";
		}

		if (animation.curAnim == null || animation.curAnim.name != animName)
			animation.play(animName, true);

		if (animName == "walk")
			animation.curAnim.frameRate = 6 + Std.int((absV / WALK_MAX) * 12);

		var targetDeg = 0.0;
		if (gnd && slopeDeg > ANGLE_VIS_THRESH)
		{
			targetDeg = TVSlopeMap.s1ToDeg(rawAngle);
			if (targetDeg > 180) targetDeg -= 360;
		}
		_displayAngle += (targetDeg - _displayAngle) * 0.25;
		if (Math.abs(_displayAngle) < 0.5) _displayAngle = 0.0;
		angle = _displayAngle;
	}

	public function doLaunch():Void
	{
		velocity.y    = LAUNCH_VY;
		jumpHeld      = false;
		mode          = Launch;
	}

	function _groundMove(elapsed:Float, left:Bool, right:Bool):Void
	{
		var v = inertia;
		if (right)
		{
			facing = FlxDirectionFlags.RIGHT;
			if (v < 0) { v += WALK_BRAKE * elapsed; if (v > 0) v = 0; }
			else       { v += WALK_ACCEL * elapsed; if (v > WALK_MAX) v = WALK_MAX; }
		}
		else if (left)
		{
			facing = FlxDirectionFlags.LEFT;
			if (v > 0) { v -= WALK_BRAKE * elapsed; if (v < 0) v = 0; }
			else       { v -= WALK_ACCEL * elapsed; if (v < -WALK_MAX) v = -WALK_MAX; }
		}
		else
		{
			if      (v > 0) { v -= WALK_DECEL * elapsed; if (v < 0) v = 0; }
			else if (v < 0) { v += WALK_DECEL * elapsed; if (v > 0) v = 0; }
		}
		inertia = v;
	}

	function _airMove(elapsed:Float, left:Bool, right:Bool):Void
	{
		var vx = velocity.x;
		if (right)
		{
			facing = FlxDirectionFlags.RIGHT;
			vx += AIR_ACCEL * elapsed;
			if (vx > AIR_MAX) vx = AIR_MAX;
		}
		else if (left)
		{
			facing = FlxDirectionFlags.LEFT;
			vx -= AIR_ACCEL * elapsed;
			if (vx < -AIR_MAX) vx = -AIR_MAX;
		}
		velocity.x = vx;
	}
}
