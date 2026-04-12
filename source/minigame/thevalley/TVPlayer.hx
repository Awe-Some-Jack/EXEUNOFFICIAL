package minigame.thevalley;

import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;

enum PlayerMode { Ground; Air; Launch; WingOpen; Glide; WingClose; }

class TVPlayer extends FlxSprite
{
	public static inline var WALK_ACCEL:Float   = 420.0;
	public static inline var WALK_DECEL:Float   = 540.0;
	public static inline var WALK_BRAKE:Float   = 900.0;
	public static inline var WALK_MAX:Float     = 180.0;

	public static inline var AIR_ACCEL:Float    = 300.0;
	public static inline var AIR_MAX:Float      = 180.0;

	public static inline var JUMP_VY:Float      = -460.0;
	public static inline var JUMP_CUT:Float     = -180.0;

	public static inline var GRAVITY:Float      = 900.0;
	public static inline var MAX_FALL:Float     = 700.0;

	public static inline var LAUNCH_VY:Float    = -580.0;

	public static inline var GLIDE_GRAVITY:Float   = 120.0;
	public static inline var GLIDE_MAX_FALL:Float  = 60.0;
	public static inline var WINGOPEN_IMPULSE:Float = -120.0;
	public static inline var WINGOPEN_FRAMES:Int   = 18;
	public static inline var GLIDE_COOLDOWN:Int    = 90;

	public static inline var SLOPE_RESIST:Float = 300.0;
	public static inline var SLOPE_SLIDE_ANGLE:Float = 30.0;
	public static inline var SLOPE_SLIDE_SPEED:Float = 40.0;

	public static inline var HB_W:Int = 18;
	public static inline var HB_H:Int = 38;

	public var mode:PlayerMode     = Air;
	public var inertia:Float       = 0.0;
	public var groundAngle:Float   = 0.0;
	public var jumpHeld:Bool       = false;
	public var wingOpenTimer:Int   = 0;
	public var glideCooldown:Int   = 0;

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

	public function doLaunch():Void
	{
		velocity.y = LAUNCH_VY;
		jumpHeld   = false;
		mode       = Launch;
	}
}
