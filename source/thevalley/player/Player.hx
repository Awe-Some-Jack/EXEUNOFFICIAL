package thevalley.player;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.geom.Ray;
import thevalley.map.TVNapeWorld;

enum PlayerMode { Ground; Air; Launch; WingOpen; Glide; WingClose; }

typedef PlayerConfig = {
	sprite:String,
	hitbox:{ width:Int, height:Int, offsetX:Float, offsetY:Float, frameWidth:Float, ?footRadius:Float },
	physics:{
		walkAccel:Float, walkDecel:Float, walkBrake:Float, walkMax:Float,
		runMax:Float, runAccel:Float,
		staminaMax:Int, staminaDrain:Int, staminaRegen:Int,
		airAccel:Float,  airMax:Float,
		jumpVy:Float,    jumpCut:Float,
		maxFall:Float,
		launchVy:Float,
		glideGravity:Float, glideMaxFall:Float,
		wingOpenImpulse:Float, wingOpenFrames:Int, glideCooldown:Int,
		slopeResist:Float, slopeSlideAngle:Float, slopeSlideSpeed:Float
	},
	tuning:{ coyoteFrames:Int, jumpBufferFrames:Int, angleVisThresh:Float },
	animations:Array<Dynamic>
}

class Player extends FlxSprite
{
	public var cfg:PlayerConfig;
	public var body:Body;

	public var cinematic:Bool     = false;
	public var breakFalling:Bool  = false;
	public var mode:PlayerMode    = Air;
	public var inertia:Float      = 0.0;
	public var groundAngle:Float  = 0.0;
	public var jumpHeld:Bool      = false;
	public var wingOpenTimer:Int  = 0;
	public var glideCooldown:Int  = 0;
	public var isGrounded:Bool    = false;
	public var touchingFloor:Bool = false;
	public var onSlope:Bool       = false;
	public var coyoteTimer:Int    = 0;
	public var jumpBufTimer:Int   = 0;
	public var slopeDeg:Float     = 0.0;
	public var rawAngle:Float     = 0.0;
	public var isRunning:Bool     = false;
	public var isHidden:Bool      = false;
	public var isHiding:Bool      = false;
	public var lockedAnim:String  = null;
	public var stamina:Int        = 180;

	public var sensorDistL:Int    = 0x7FFF;
	public var sensorDistC:Int    = 0x7FFF;
	public var sensorDistR:Int    = 0x7FFF;

	var _wasGrounded:Bool       = false;
	var _launchCooldown:Int     = 0;
	var _glideTimer:Float       = 0.0;
	var _glideCooldownSec:Float = 0.0;
	var _staminaDepleted:Bool   = false;
	var _jumpCooldown:Float     = 0.0;

	public function new(spawnX:Float, spawnY:Float, configPath:String = "assets/shared/images/minigame/thevalley/characters/fakergf/fakergf.json")
	{
		super(spawnX, spawnY);

		var raw = openfl.Assets.getText(configPath);
		cfg = haxe.Json.parse(raw);
		stamina = cfg.physics.staminaMax;

		var h = cfg.hitbox;
		frames = Paths.getSparrowAtlas(cfg.sprite);

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
	}

	override public function update(elapsed:Float):Void
	{
		if (body == null) { super.update(elapsed); return; }

		if (isHidden)
		{
			body.velocity.setxy(0, 0);
			body.angularVel = 0;
			body.gravMass = 0;
			super.update(elapsed);
			var h = cfg.hitbox;
			x = body.position.x - h.width  * 0.5;
			y = body.position.y - h.height * 0.5;
			return;
		}

		_detectGround(elapsed);
		_applyModeGravity(elapsed);

		if (body.velocity.y > 900.0) body.velocity.y = 900.0;

		if (_launchCooldown > 0) _launchCooldown--;
		if (glideCooldown  > 0) glideCooldown--;
		if (_jumpCooldown  > 0) _jumpCooldown -= elapsed;
		if (_glideCooldownSec > 0) _glideCooldownSec -= elapsed;
		if (mode == Glide && !cinematic)
		{
			_glideTimer -= elapsed;
			if (_glideTimer <= 0) { _glideTimer = 0; mode = WingClose; _glideCooldownSec = 1.0; }
		}

		if (isGrounded)
		{
			_glideTimer = 0; 
			_glideCooldownSec = 0;

			// coyote shi
			coyoteTimer = cfg.tuning.coyoteFrames;
			if (!_wasGrounded)
				FlxG.sound.play("assets/shared/sounds/minigame/thevalley/jumplanding.ogg", 0.3); // THUD (guy fell from waaay up and it shows)

			if (cinematic) body.velocity.x = 0;
		}
		else if (coyoteTimer > 0) coyoteTimer--;
		_wasGrounded = isGrounded;

		var h = cfg.hitbox;
		x = body.position.x - h.width  * 0.5;
		y = body.position.y - h.height * 0.5;

		velocity.x = body.velocity.x;
		velocity.y = body.velocity.y;

		super.update(elapsed);
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
			var res = FlxNapeSpace.space.rayCast(ray, false);
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

		if (isGrounded) mode = Ground;
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

	// ese culo gravitando sobre mi velga
	function _applyModeGravity(elapsed:Float):Void
	{
		var p = cfg.physics;
		var defaultGravity = TVNapeWorld.GRAVITY; 
		
		switch (mode)
		{
			case WingOpen:
				body.velocity.y -= TVNapeWorld.GRAVITY * 0.6 * elapsed;
				if (body.velocity.y > p.glideMaxFall) body.velocity.y = p.glideMaxFall;
				if (wingOpenTimer > 0) { wingOpenTimer--; if (wingOpenTimer == 0) mode = Glide; }
			case Glide:
				body.velocity.y += (p.glideGravity - TVNapeWorld.GRAVITY) * elapsed;
				if (body.velocity.y > p.glideMaxFall) body.velocity.y = p.glideMaxFall;
			case WingClose:
				if (body.velocity.y > p.maxFall) body.velocity.y = p.maxFall;
			case Launch:
				if (body.velocity.y >= 0) mode = Air;
			default:
				if (!isGrounded)
				{
					if (body.velocity.y < 0 && !jumpHeld)
						body.velocity.y += defaultGravity * 1.5 * elapsed; 

					if (Math.abs(body.velocity.y) < 120.0)
						body.velocity.y -= defaultGravity * 0.4 * elapsed;

					if (body.velocity.y > 0)
						body.velocity.y += defaultGravity * 0.6 * elapsed;

					if (body.velocity.y > p.maxFall) 
						body.velocity.y = p.maxFall;
				}
		}
	}

	public function handleInput(elapsed:Float, spawnX:Float, spawnY:Float):Bool
	{
		var p = cfg.physics;
		var t = cfg.tuning;
		if (cinematic) return false;
		if (isHidden) return false;

		if (FlxG.keys.justPressed.R)
		{
			var h = cfg.hitbox;
			body.position.setxy(spawnX + h.width * 0.5, spawnY + h.height * 0.5);
			body.velocity.setxy(0, 0);
			inertia = groundAngle = 0;
			mode = Air; isGrounded = false;
			coyoteTimer = jumpBufTimer = 0;
			glideCooldown = wingOpenTimer = 0;
			isRunning = false;
			stamina = p.staminaMax;
			angle = 0;
			return true;
		}

		final left        = FlxG.keys.pressed.LEFT  || FlxG.keys.pressed.A;
		final right       = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;
		final shift       = FlxG.keys.pressed.SHIFT;
		final jumpJust    = FlxG.keys.justPressed.SPACE;
		final jumpRel     = FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE;
		final jumpHeldNow = FlxG.keys.pressed.Z     || FlxG.keys.pressed.SPACE;

		if (jumpRel)  jumpHeld = false;
		if (jumpJust) jumpBufTimer = t.jumpBufferFrames; // jump buffer: u mashed space 2 frames b4 landin, we got u, calm down

		final gnd = coyoteTimer > 0;
		if (gnd && (mode == Glide || mode == WingOpen || mode == WingClose))
			mode = Ground; wingOpenTimer = glideCooldown = 0; _glideTimer = 0; _glideCooldownSec = 0;

		if (stamina <= 0) _staminaDepleted = true;
		if (_staminaDepleted && stamina >= p.staminaMax) _staminaDepleted = false;

		//gf cardio simulator. she out here doin more exercise than me fr fatass chair 
		var wantsRun = gnd && shift && (left || right) && stamina > 0 && !_staminaDepleted;
		if (wantsRun)
		{
			isRunning = true;
			stamina -= p.staminaDrain;
			if (stamina < 0) stamina = 0;
		}
		else
		{
			isRunning = false;
			stamina += p.staminaRegen;
			if (stamina > p.staminaMax) stamina = p.staminaMax;
		}

		var maxSpd = isRunning ? p.runMax  : p.walkMax;
		var accel  = isRunning ? p.runAccel : p.walkAccel;

		var vx = body.velocity.x;
		if (gnd)
		{
			if (right)
			{
				facing = FlxDirectionFlags.RIGHT;
				if (vx < 0) { vx += p.walkBrake * elapsed; if (vx > 0) vx = 0; }
				else        { vx += accel * elapsed; if (vx > maxSpd) vx = maxSpd; }
			}
			else if (left)
			{
				facing = FlxDirectionFlags.LEFT;
				if (vx > 0) { vx -= p.walkBrake * elapsed; if (vx < 0) vx = 0; }
				else        { vx -= accel * elapsed; if (vx < -maxSpd) vx = -maxSpd; }
			}
			else
			{
				if      (vx > 0) { vx -= p.walkDecel * elapsed; if (vx < 0) vx = 0; }
				else if (vx < 0) { vx += p.walkDecel * elapsed; if (vx > 0) vx = 0; }
			}
		}
		else
		{
			if (right)     { facing = FlxDirectionFlags.RIGHT; vx += p.airAccel * elapsed; if (vx > p.airMax)  vx = p.airMax;  }
			else if (left) { facing = FlxDirectionFlags.LEFT;  vx -= p.airAccel * elapsed; if (vx < -p.airMax) vx = -p.airMax; }
		}
		body.velocity.x = vx;
		inertia = vx;

		_projectOnSlope();

		if (jumpBufTimer > 0 && gnd && _jumpCooldown <= 0)
		{
			body.velocity.y = p.jumpVy;
			body.velocity.x = vx;
			jumpHeld    = true;
			isGrounded  = false;
			coyoteTimer = jumpBufTimer = 0;
			_jumpCooldown = 0.5;
			mode = Air;
			stamina -= 20;
			if (stamina < 0) stamina = 0;
			FlxG.sound.play("assets/shared/sounds/minigame/thevalley/jump.ogg", 0.3);
		}

		if (jumpJust && !gnd && mode == Air && body.velocity.y > -50 && glideCooldown == 0 && _glideCooldownSec <= 0)
		{
			body.velocity.y = p.wingOpenImpulse;
			wingOpenTimer   = p.wingOpenFrames;
			glideCooldown   = p.glideCooldown;
			_glideTimer     = 1.5;
			mode            = WingOpen;
		}
		else if (!jumpHeldNow && mode == Glide)
			mode = WingClose;

		if (jumpBufTimer > 0) jumpBufTimer--;

		return false;
	}

	public function updateAnim(elapsed:Float):Void
	{
		var p = cfg.physics;
		if (isHidden || isHiding) return;
		if (lockedAnim != null)
		{
			var cur0 = animation.curAnim;
			if (cur0 == null || cur0.name != lockedAnim)
				animation.play(lockedAnim, true);
			return;
		}
		if (cinematic)
		{
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
			if      (down && absV < 5)        animName = "crouch";
			else if (up   && absV < 5)        animName = "lookup";
			else if (absV > 5 && isRunning)   animName = "run";
			else if (absV > 5)                animName = "walk";
			else                              animName = "idle";
		}

		if (animation.curAnim == null || animation.curAnim.name != animName)
			animation.play(animName, true);

		if (animName == "walk")
			animation.curAnim.frameRate = 6 + Std.int((absV / p.walkMax) * 12);
		else if (animName == "run")
			animation.curAnim.frameRate = 10 + Std.int((absV / p.runMax) * 10);

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
		_launchCooldown = 20;
	}
}
