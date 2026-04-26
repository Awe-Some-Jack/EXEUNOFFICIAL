package minigame.thevalley;

import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxDirectionFlags;

import backend.Controls;

import nape.callbacks.CbType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;

enum PlayerMode
{
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

	static inline final HB_W:Int = 18;
	static inline final HB_H:Int = 38;

	static inline final COYOTE_FRAMES:Int = 5;
	static inline final JUMP_BUFFER_FRAMES:Int = 8;

	public static final PLAYER_CB:CbType = new CbType();

	public var mode:PlayerMode = Air;
	public var inertia:Float = 0;
	public var jumpHeld:Bool = false;
	public var wingOpenTimer:Int = 0;
	public var glideCooldown:Int = 0;
	public var coyoteTimer:Int = 0;
	public var jumpBufTimer:Int = 0;

	public var isGrounded:Bool = false;
	public var touchingFloor:Bool = false;

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

		origin.set(HB_W * 0.5, HB_H * 0.5);

		createRectangularBody(HB_W, HB_H, BodyType.DYNAMIC);

		body.shapes.clear();

		var r = HB_W * 0.5;
		var midH = HB_H - r;

		var mat = new Material(0, 0.0, 0.0, 1, 0);

		var rect = new Polygon(Polygon.box(HB_W, midH));
		rect.translate(Vec2.weak(0, -r * 0.5));
		rect.material = mat;
		body.shapes.add(rect);

		var bottom = new Circle(r, Vec2.weak(0, midH * 0.5 - r * 0.5));
		bottom.material = mat;
		body.shapes.add(bottom);

		body.setShapeMaterials(mat);

		body.allowRotation = false;
		body.velocity.setxy(0, 0);
		body.position.setxy(x + width * 0.5, y + height * 0.5);
		body.cbTypes.add(PLAYER_CB);

		setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
	}

	inline function vx():Float
		return body.velocity.x;

	inline function vy():Float
		return body.velocity.y;

	inline function setVX(v:Float):Void
	{
		var delta = v - body.velocity.x;

		if (Math.abs(delta) > 0.001)
			body.applyImpulse(Vec2.weak(delta * body.mass, 0));

		body.velocity.x = v;
	}

	inline function setVY(v:Float):Void
	{
		var delta = v - body.velocity.y;

		if (Math.abs(delta) > 0.001)
			body.applyImpulse(Vec2.weak(0, delta * body.mass));

		body.velocity.y = v;
	}

	public function setBodyXY(px:Float, py:Float):Void
	{
		body.position.setxy(px + width * 0.5, py + height * 0.5);
		body.velocity.setxy(0, 0);
		updatePosition();

		velocity.x = body.velocity.x;
		velocity.y = body.velocity.y;
	}

	function checkGrounded():Bool
	{
		if (body == null)
			return false;

		for (arb in body.arbiters)
		{
			if (!arb.isCollisionArbiter())
				continue;

			var col = arb.collisionArbiter;
			var ny = (arb.body1 == body) ? -col.normal.y : col.normal.y;

			if (ny < -0.35)
				return true;
		}

		return false;
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
			angle = 0;

			return true;
		}

		var left = controls.UI_LEFT || FlxG.keys.pressed.A;
		var right = controls.UI_RIGHT || FlxG.keys.pressed.D;

		var jumpJust = FlxG.keys.justPressed.Z || FlxG.keys.justPressed.SPACE;
		var jumpRel = FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE;
		var jumpHeldNow = FlxG.keys.pressed.Z || FlxG.keys.pressed.SPACE;

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
			setVY(JUMP_VY);

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

	public function updateNapePlayer(elapsed:Float):Void
	{
		touchingFloor = checkGrounded();

		if (touchingFloor && vy() >= -80)
		{
			coyoteTimer = COYOTE_FRAMES;
			isGrounded = true;

			if (mode == Air || mode == WingOpen || mode == Glide || mode == WingClose)
				mode = Ground;
		}
		else
		{
			if (coyoteTimer > 0)
				coyoteTimer--;

			isGrounded = coyoteTimer > 0 && vy() >= -120;
		}

		if (jumpBufTimer > 0)
			jumpBufTimer--;

		if (glideCooldown > 0)
			glideCooldown--;

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

		if (Math.abs(vx()) > 5 && isGrounded)
			mode = Ground;
	}

	public function updateAnim(elapsed:Float, controls:Controls):Void
	{
		var absV = Math.abs(vx());
		var down = controls.UI_DOWN || FlxG.keys.pressed.S;
		var up = controls.UI_UP || FlxG.keys.pressed.W;

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

			if (animation.curAnim != null
				&& animation.curAnim.name == "wingclose"
				&& animation.curAnim.finished)
			{
				mode = Air;
			}
		}
		else if (!isGrounded && coyoteTimer <= 0)
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

		angle += (0 - angle) * 0.25;

		if (Math.abs(angle) < 0.5)
			angle = 0;
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