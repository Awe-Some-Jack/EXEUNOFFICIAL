package minigame.thevalley;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxDirectionFlags;

import backend.Controls;

import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.phys.Material;

enum PlayerMode { 
	Ground; 
	Air; 
	Launch; 
	WingOpen; 
	Glide; 
	WingClose; 
}

class TVPlayer extends FlxNapeSprite
{
	public static inline final WALK_ACCEL:Float = 420;
	public static inline final WALK_DECEL:Float = 540;
	public static inline final WALK_BRAKE:Float = 900;
	public static inline final WALK_MAX:Float = 180;

	public static inline final AIR_ACCEL:Float = 300;
	public static inline final AIR_MAX:Float = 180;

	public static inline final JUMP_VY:Float = -460;
	public static inline final JUMP_CUT:Float = -180;
	public static inline final MAX_FALL:Float = 700;

	public static inline final LAUNCH_VY:Float = -580;

	public static inline final GLIDE_GRAVITY_SCALE:Float = 0.15;
	public static inline final GLIDE_MAX_FALL:Float = 60;
	public static inline final WINGOPEN_IMPULSE:Float = -120;
	public static inline final WINGOPEN_FRAMES:Int = 18;
	public static inline final GLIDE_COOLDOWN:Int = 90;

	public static inline final SLOPE_RESIST:Float = 300;
	public static inline final SLOPE_VIS_THRESH:Float = 8;

	static inline final HB_W:Int = 18;
	static inline final HB_H:Int = 38;

	static inline final COYOTE_FRAMES:Int = 5;
	static inline final JUMP_BUFFER_FRAMES:Int = 8;

	public var mode:PlayerMode = Air;
	public var inertia:Float = 0;
	public var jumpHeld:Bool = false;
	public var wingOpenTimer:Int = 0;
	public var glideCooldown:Int = 0;
	public var coyoteTimer:Int = 0;
	public var jumpBufTimer:Int = 0;

	public var isGrounded:Bool = false;
	public var touchingFloor:Bool = false;
	public var onSlope:Bool = false;

	public var slopeDeg:Float = 0;
	public var rawAngle:Float = 0;
	public var groundAngle:Float = 0;

	public var sensorDistL:Int = TVSlopeMap.MISS_DIST;
	public var sensorDistC:Int = TVSlopeMap.MISS_DIST;
	public var sensorDistR:Int = TVSlopeMap.MISS_DIST;

	var _prevRawAngle:Float = 0;
	var _displayAngle:Float = 0;

	final _sensorAngle:Array<Float> = [0.0];

	public function new(x:Float, y:Float)
	{
		super(x, y, null, false, true);

		frames = backend.Paths.getSparrowAtlas('minigame/thevalley/fakergf');

		animation.addByPrefix("idle", "fakergf idle", 12, true);
		animation.addByPrefix("walk", "fakergf walk", 12, true);
		animation.addByPrefix("jump", "fakergf jump", 1, true);
		animation.addByPrefix("crouch", "fakergf crouch", 1, false);
		animation.addByPrefix("up", "fakergf up", 1, false);
		animation.addByPrefix("launch", "fakergf up", 1, false);
		animation.addByPrefix("wingopen", "fakergf wingopen", 8, false);
		animation.addByIndices("wingclose", "fakergf wingopen", [3, 2, 1, 0], "", 18, false);
		animation.addByPrefix("glide", "fakergf glide", 8, true);
		animation.play("idle");

		setSize(HB_W, HB_H);
		offset.x = (60 - HB_W) / 2;
		offset.y = 9;

		createRectangularBody(HB_W, HB_H, BodyType.DYNAMIC);

		body.allowRotation = false;
		body.velocity.setxy(0, 0);
		body.position.setxy(x + origin.x, y + origin.y);
		body.setShapeMaterials(new Material(0, 0.05, 0.05, 1, 0));

		setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
	}

	inline function vx():Float return body.velocity.x;
	inline function vy():Float return body.velocity.y;

	inline function setVX(v:Float):Void
	{
		var delta = v - body.velocity.x;
		body.applyImpulse(Vec2.weak(delta * body.mass, 0));
		body.velocity.x = v;
	}

	inline function setVY(v:Float):Void
	{
		var delta = v - body.velocity.y;
		body.applyImpulse(Vec2.weak(0, delta * body.mass));
		body.velocity.y = v;
	}

	public function setBodyXY(px:Float, py:Float):Void
	{
		body.position.setxy(px + origin.x, py + origin.y);
		body.velocity.setxy(0, 0);

		updatePosition();

		velocity.x = body.velocity.x;
		velocity.y = body.velocity.y;
	}

	public function updateSlopeMap(
		slopeMap:TVSlopeMap,
		launchCooldown:Int,
		floorScanGnd:Int,
		floorScanAir:Int,
		sensorDiffMax:Int
	):Void
	{
		if (launchCooldown > 0)
		{
			touchingFloor = false;
			onSlope = false;
			isGrounded = false;
			slopeDeg = 0;
			rawAngle = 0;
			groundAngle = 0;
			return;
		}

		final lx:Int = Std.int(x + width * 0.25);
		final cx:Int = Std.int(x + width * 0.50);
		final rx:Int = Std.int(x + width * 0.75);
		final footY:Int = Std.int(y + height);

		final scanDown:Int = vy() >= 0 ? floorScanGnd : floorScanAir;

		var dL = slopeMap.findFloor(lx, footY, scanDown, _sensorAngle);
		var dR = slopeMap.findFloor(rx, footY, scanDown, _sensorAngle);
		var dC = slopeMap.findFloor(cx, footY, scanDown, _sensorAngle);

		if (dL != TVSlopeMap.MISS_DIST && dR != TVSlopeMap.MISS_DIST)
		{
			final diff = dL - dR;

			if (diff < -sensorDiffMax)
				dL = TVSlopeMap.MISS_DIST;
			else if (diff > sensorDiffMax)
				dR = TVSlopeMap.MISS_DIST;
		}

		if (dC != TVSlopeMap.MISS_DIST)
		{
			if (dL != TVSlopeMap.MISS_DIST && (dC - dL) > sensorDiffMax)
				dC = TVSlopeMap.MISS_DIST;

			if (dR != TVSlopeMap.MISS_DIST && (dC - dR) > sensorDiffMax)
				dC = TVSlopeMap.MISS_DIST;
		}

		if (dL == TVSlopeMap.MISS_DIST && dC != TVSlopeMap.MISS_DIST) dL = dC;
		if (dR == TVSlopeMap.MISS_DIST && dC != TVSlopeMap.MISS_DIST) dR = dC;
		if (dL == TVSlopeMap.MISS_DIST && dR != TVSlopeMap.MISS_DIST) dL = dR;
		if (dR == TVSlopeMap.MISS_DIST && dL != TVSlopeMap.MISS_DIST) dR = dL;

		sensorDistL = dL;
		sensorDistC = dC;
		sensorDistR = dR;

		final floorEps = 10;

		touchingFloor = (dL != TVSlopeMap.MISS_DIST && dL <= floorEps)
			|| (dC != TVSlopeMap.MISS_DIST && dC <= floorEps)
			|| (dR != TVSlopeMap.MISS_DIST && dR <= floorEps);

		onSlope = dL != TVSlopeMap.MISS_DIST
			&& dR != TVSlopeMap.MISS_DIST
			&& dL != dR
			&& touchingFloor;

		isGrounded = touchingFloor && vy() >= -20;

		if (isGrounded)
		{
			var best:Int = TVSlopeMap.MISS_DIST;

			inline function consider(d:Int):Void
			{
				if (d != TVSlopeMap.MISS_DIST && (best == TVSlopeMap.MISS_DIST || d < best))
					best = d;
			}

			consider(dL);
			consider(dC);
			consider(dR);

			if (best != TVSlopeMap.MISS_DIST && best >= -6 && best <= 12)
			{
				body.position.y += best;
				body.velocity.y = 0;
				updatePosition();

				velocity.x = body.velocity.x;
				velocity.y = body.velocity.y;
			}
		}

		if (isGrounded && dL != TVSlopeMap.MISS_DIST && dR != TVSlopeMap.MISS_DIST && dL != dR)
		{
			final deg = Math.atan2(dR - dL, width * 0.5) * (180 / Math.PI);

			rawAngle = TVSlopeMap.degToS1(deg);
			slopeDeg = Math.abs(deg);
			_prevRawAngle = rawAngle;
			groundAngle = rawAngle;
		}
		else if (isGrounded)
		{
			rawAngle = _prevRawAngle * 0.5;
			slopeDeg = Math.abs(TVSlopeMap.s1ToDeg(rawAngle));
			_prevRawAngle = rawAngle;
			groundAngle = rawAngle;
		}
		else
		{
			rawAngle = 0;
			slopeDeg = 0;
			_prevRawAngle = 0;
			groundAngle = 0;
		}
	}

	public function handleInput(elapsed:Float, controls:Controls, spawnX:Float, spawnY:Float):Bool
	{
		if (FlxG.keys.justPressed.R)
		{
			setBodyXY(spawnX, spawnY);

			mode = Air;
			inertia = 0;
			jumpHeld = false;
			wingOpenTimer = 0;
			glideCooldown = 0;
			coyoteTimer = 0;
			jumpBufTimer = 0;
			isGrounded = false;
			touchingFloor = false;
			onSlope = false;
			rawAngle = 0;
			slopeDeg = 0;
			groundAngle = 0;
			_displayAngle = 0;
			angle = 0;

			return true;
		}

		final left:Bool = controls.UI_LEFT || FlxG.keys.pressed.A;
		final right:Bool = controls.UI_RIGHT || FlxG.keys.pressed.D;

		final jumpJust:Bool = controls.ACCEPT || FlxG.keys.justPressed.SPACE;
		final jumpRel:Bool = FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE;
		final jumpHeldNow:Bool = FlxG.keys.pressed.Z || FlxG.keys.pressed.SPACE;

		if (jumpJust)
			jumpBufTimer = JUMP_BUFFER_FRAMES;

		if (jumpRel)
			jumpHeld = false;

		if (isGrounded || coyoteTimer > 0)
			_groundMove(elapsed, left, right);
		else
			_airMove(elapsed, left, right);

		if (jumpBufTimer > 0 && coyoteTimer > 0)
		{
			var ar = TVSlopeMap.s1ToRad(groundAngle);

			setVY(JUMP_VY);
			setVX(vx() - JUMP_VY * Math.sin(ar));

			jumpHeld = true;
			isGrounded = false;
			touchingFloor = false;
			coyoteTimer = 0;
			jumpBufTimer = 0;
			mode = Air;
		}

		if (jumpJust && !isGrounded && mode == Air && vy() > -50 && glideCooldown == 0)
		{
			setVY(WINGOPEN_IMPULSE);
			wingOpenTimer = WINGOPEN_FRAMES;
			glideCooldown = GLIDE_COOLDOWN;
			mode = WingOpen;
		}
		else if (!jumpHeldNow && mode == Glide)
		{
			mode = WingClose;
		}

		return false;
	}

	function setNapeSensorMode(v:Bool):Void
	{
		if (body?.shapes.length > 0)
			body.shapes.at(0).sensorEnabled = v;
	}

	public function updateNapePlayer(elapsed:Float):Void
	{
		setNapeSensorMode(touchingFloor || onSlope || coyoteTimer > 0);

		if (touchingFloor && vy() >= -20)
		{
			isGrounded = true;
			coyoteTimer = COYOTE_FRAMES;

			if (mode == Air || mode == WingOpen || mode == Glide || mode == WingClose)
				mode = Ground;
		}
		else
		{
			isGrounded = false;

			if (coyoteTimer > 0)
				coyoteTimer--;
		}

		if (jumpBufTimer > 0)
			jumpBufTimer--;

		if (glideCooldown > 0)
			glideCooldown--;

		if (isGrounded && onSlope)
		{
			final angleRad = TVSlopeMap.s1ToRad(rawAngle);
			body.velocity.x -= Math.sin(angleRad) * SLOPE_RESIST * elapsed;
		}

		if (!jumpHeld && vy() < JUMP_CUT)
			setVY(JUMP_CUT);

		if (mode == Launch)
		{
			body.gravMass = 1;

			if (vy() >= 0)
				mode = Air;
		}
		else if (mode == WingOpen)
		{
			body.gravMass = GLIDE_GRAVITY_SCALE;

			if (vy() > GLIDE_MAX_FALL)
				setVY(GLIDE_MAX_FALL);

			if (wingOpenTimer > 0)
			{
				wingOpenTimer--;

				if (wingOpenTimer == 0)
					mode = Glide;
			}
		}
		else if (mode == Glide)
		{
			body.gravMass = GLIDE_GRAVITY_SCALE;

			if (vy() > GLIDE_MAX_FALL)
				setVY(GLIDE_MAX_FALL);
		}
		else
		{
			body.gravMass = 1;

			if (vy() > MAX_FALL)
				setVY(MAX_FALL);
		}

		inertia = vx();

		velocity.x = body.velocity.x;
		velocity.y = body.velocity.y;

		if (Math.abs(body.velocity.x) > 5 && isGrounded)
			mode = Ground;
	}

	public function updateAnim(elapsed:Float, controls:Controls):Void
	{
		final absV = Math.abs(vx());
		final down = controls.UI_DOWN || FlxG.keys.pressed.S;
		final up = controls.UI_UP || FlxG.keys.pressed.W;

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

			if (animation.curAnim != null && animation.curAnim.name == "wingclose"
				&& animation.curAnim.finished)
			{
				mode = Air;
			}
		}
		else if (!isGrounded)
			animName = "jump";
		else
		{
			if (down && absV < 5)
				animName = "crouch";
			else if (up && absV < 5)
				animName = "up";
			else if (absV > 5)
				animName = "walk";
			else
				animName = "idle";
		}

		if (animation.curAnim == null || animation.curAnim.name != animName)
			animation.play(animName, true);

		if (animName == "walk" && animation.curAnim != null)
			animation.curAnim.frameRate = 6 + Std.int((absV / WALK_MAX) * 12);

		var targetDeg = 0.0;

		if (isGrounded && slopeDeg > SLOPE_VIS_THRESH)
		{
			targetDeg = TVSlopeMap.s1ToDeg(rawAngle);

			if (targetDeg > 180)
				targetDeg -= 360;
		}

		_displayAngle += (targetDeg - _displayAngle) * 0.25;

		if (Math.abs(_displayAngle) < 0.5)
			_displayAngle = 0;

		angle = _displayAngle;
	}

	public function doLaunch():Void
	{
		setVY(LAUNCH_VY);
		jumpHeld = false;
		isGrounded = false;
		touchingFloor = false;
		coyoteTimer = 0;
		mode = Launch;
	}

	function _groundMove(elapsed:Float, left:Bool, right:Bool):Void
	{
		var v = vx();

		if (right)
		{
			facing = FlxDirectionFlags.RIGHT;

			if (v < 0)
			{
				v += WALK_BRAKE * elapsed;
				if (v > 0) v = 0;
			}
			else
			{
				v += WALK_ACCEL * elapsed;
				if (v > WALK_MAX) v = WALK_MAX;
			}
		}
		else if (left)
		{
			facing = FlxDirectionFlags.LEFT;

			if (v > 0)
			{
				v -= WALK_BRAKE * elapsed;
				if (v < 0) v = 0;
			}
			else
			{
				v -= WALK_ACCEL * elapsed;
				if (v < -WALK_MAX) v = -WALK_MAX;
			}
		}
		else
		{
			if (v > 0)
			{
				v -= WALK_DECEL * elapsed;
				if (v < 0) v = 0;
			}
			else if (v < 0)
			{
				v += WALK_DECEL * elapsed;
				if (v > 0) v = 0;
			}
		}

		if (!left && !right && Math.abs(v) < 5)
			v = 0;

		setVX(v);
		inertia = v;
	}

	function _airMove(elapsed:Float, left:Bool, right:Bool):Void
	{
		var v = vx();

		if (right)
		{
			facing = FlxDirectionFlags.RIGHT;
			v += AIR_ACCEL * elapsed;
			if (v > AIR_MAX) v = AIR_MAX;
		}
		else if (left)
		{
			facing = FlxDirectionFlags.LEFT;
			v -= AIR_ACCEL * elapsed;
			if (v < -AIR_MAX) v = -AIR_MAX;
		}
		else
		{
			var airDecel = 220.0;

			if (v > 0)
			{
				v -= airDecel * elapsed;
				if (v < 0) v = 0;
			}
			else if (v < 0)
			{
				v += airDecel * elapsed;
				if (v > 0) v = 0;
			}
		}

		setVX(v);
		inertia = v;
	}
}