package minigame.thevalley;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import minigame.thevalley.TVPlayer;
import minigame.thevalley.TVSlopeMap;
import minigame.thevalley.TVHitboxMap;

class TheValley extends MusicBeatState
{
	var player:TVPlayer;
	var hitboxMap:TVHitboxMap;
	var slopeMap:TVSlopeMap;
	var hitboxBmd:BitmapData;
	var mapSprite:FlxSprite;
	var hitboxOverlay:FlxSprite;

	var hudCamera:flixel.FlxCamera;

	var debugText:FlxText;
	var playerHitboxSprite:FlxSprite;
	var showDebug:Bool        = false;
	var showPlayerHitbox:Bool = false;
	var showMapHitbox:Bool    = true;

	static inline var SPAWN_X:Float = 150;
	static inline var SPAWN_Y:Float = 800;

	static inline var SENSOR_MISS:Int    = TVSlopeMap.MISS_DIST;
	static inline var FLOOR_SCAN_GND:Int = 20;
	static inline var FLOOR_SCAN_AIR:Int = TVSlopeMap.SCAN_UP + 1;
	static inline var SNAP_MAX:Int       = 14;

	var sensorDistL:Int  = SENSOR_MISS;
	var sensorDistC:Int  = SENSOR_MISS;
	var sensorDistR:Int  = SENSOR_MISS;
	var sensorAngleL:Array<Float> = [0.0];
	var sensorAngleR:Array<Float> = [0.0];

	var touchingFloor:Bool = false;
	var onSlope:Bool       = false;
	var isGrounded:Bool    = false;

	var rawAngle:Float     = 0;
	var displayAngle:Float = 0;
	static inline var ANGLE_VIS_THRESH:Float = 8.0;

	var slopeDeg:Float    = 0;
	var prevRawAngle:Float = 0;

	static inline var COYOTE_FRAMES:Int      = 5;
	static inline var JUMP_BUFFER_FRAMES:Int = 8;
	var coyoteTimer:Int  = 0;
	var jumpBufTimer:Int = 0;

	static inline var LAUNCH_COOLDOWN:Int = 20;
	var launchCooldown:Int = 0;
	var wantLaunch:Bool    = false;
	var launchPadY:Float   = 0;

	override public function create():Void
	{
		super.create();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("The Valley", null);
		#end

		FlxG.camera.zoom = 3.0;

		hudCamera = new flixel.FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

		mapSprite = new FlxSprite(0, 0);
		mapSprite.loadGraphic(backend.Paths.image('minigame/thevalley/map'));
		add(mapSprite);

		hitboxBmd = openfl.Assets.getBitmapData('assets/shared/images/minigame/thevalley/hitbox.png');

		hitboxOverlay = new FlxSprite(0, 0);
		hitboxOverlay.loadGraphic(backend.Paths.image('minigame/thevalley/hitbox', null, false));
		hitboxOverlay.alpha = 0.35;
		add(hitboxOverlay);

		hitboxMap = new TVHitboxMap();
		hitboxMap.loadFromBitmap(hitboxBmd);
		add(hitboxMap.solidTiles);
		add(hitboxMap.platformTiles);
		add(hitboxMap.launchpads);

		slopeMap = new TVSlopeMap();
		slopeMap.loadFromBitmap(hitboxBmd);

		player = new TVPlayer(SPAWN_X, SPAWN_Y);
		add(player);

		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.10);
		FlxG.camera.setScrollBoundsRect(0, 0, mapSprite.width, mapSprite.height, true);
		FlxG.worldBounds.set(0, 0, mapSprite.width, mapSprite.height);

		var exitHint = new FlxText(0, 4, 0, "ESC / BACK — volver al menu", 10);
		exitHint.setFormat(null, 10, FlxColor.WHITE, RIGHT);
		exitHint.setBorderStyle(flixel.text.FlxText.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		exitHint.x = FlxG.width - exitHint.width - 4;
		exitHint.scrollFactor.set(0, 0);
		exitHint.cameras = [hudCamera];
		add(exitHint);

		debugText = new FlxText(0, 18, FlxG.width - 10, "", 10);
		debugText.setFormat(null, 10, FlxColor.WHITE, RIGHT);
		debugText.setBorderStyle(flixel.text.FlxText.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		debugText.scrollFactor.set(0, 0);
		debugText.cameras = [hudCamera];
		debugText.visible = false;
		add(debugText);

		playerHitboxSprite = new FlxSprite();
		playerHitboxSprite.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		playerHitboxSprite.visible = false;
		add(playerHitboxSprite);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Salir al EXEMenu con ESC o el botón BACK del juego
		if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.music.stop();
			FlxG.switchState(() -> new states.EXEMenu());
			return;
		}

		if (jumpBufTimer       > 0) jumpBufTimer--;
		if (launchCooldown     > 0) launchCooldown--;
		if (player.glideCooldown > 0) player.glideCooldown--;

		wantLaunch = false;
		FlxG.overlap(player, hitboxMap.launchpads, _checkLaunchpad);
		if (wantLaunch) _fireLaunch();

		_updateSensors();

		_applyPhysics(elapsed);

		if (launchCooldown > 0 && player.velocity.y < 0)
		{
			player.allowCollisions = FlxDirectionFlags.LEFT | FlxDirectionFlags.RIGHT;
		}
		else if (isGrounded && onSlope)
		{
			player.allowCollisions = FlxDirectionFlags.UP | FlxDirectionFlags.DOWN;
		}
		else
		{
			player.allowCollisions = FlxDirectionFlags.ANY;
		}
		FlxG.collide(player, hitboxMap.solidTiles);
		FlxG.collide(player, hitboxMap.platformTiles);
		player.allowCollisions = FlxDirectionFlags.ANY;

		_slopeSnap();

		_wallPush();

		_updateCoyote();

		_handleInput(elapsed);

		_updateAnimation(elapsed);

		_updateDebug();
	}

	function _updateSensors():Void
	{
		if (launchCooldown > 0)
		{
			sensorDistL = sensorDistC = sensorDistR = SENSOR_MISS;
			touchingFloor = onSlope = isGrounded = false;
			slopeDeg = 0;
			return;
		}

		var lx    = Std.int(player.x + player.width * 0.25);
		var cx    = Std.int(player.x + player.width * 0.50);
		var rx    = Std.int(player.x + player.width * 0.75);
		var footY = Std.int(player.y + player.height);

		var scanDown = (player.velocity.y >= 0) ? FLOOR_SCAN_GND : FLOOR_SCAN_AIR;

		sensorDistL = slopeMap.findFloor(lx, footY, scanDown, sensorAngleL);
		sensorDistR = slopeMap.findFloor(rx, footY, scanDown, sensorAngleR);
		sensorDistC = slopeMap.findFloor(cx, footY, scanDown, sensorAngleL);

		if (sensorDistL != SENSOR_MISS && sensorDistR != SENSOR_MISS)
		{
			var diff = sensorDistL - sensorDistR;
			if      (diff < -20) sensorDistL = SENSOR_MISS;
			else if (diff >  20) sensorDistR = SENSOR_MISS;
		}
		if (sensorDistC != SENSOR_MISS)
		{
			if (sensorDistL != SENSOR_MISS && (sensorDistC - sensorDistL) > 20) sensorDistC = SENSOR_MISS;
			if (sensorDistR != SENSOR_MISS && (sensorDistC - sensorDistR) > 20) sensorDistC = SENSOR_MISS;
		}

		if (sensorDistL == SENSOR_MISS && sensorDistR == SENSOR_MISS && sensorDistC != SENSOR_MISS)
		{ sensorDistL = sensorDistC; sensorDistR = sensorDistC; }
		if (sensorDistL == SENSOR_MISS && sensorDistC != SENSOR_MISS) sensorDistL = sensorDistC;
		if (sensorDistR == SENSOR_MISS && sensorDistC != SENSOR_MISS) sensorDistR = sensorDistC;
		if (sensorDistL == SENSOR_MISS && sensorDistR != SENSOR_MISS) sensorDistL = sensorDistR;
		if (sensorDistR == SENSOR_MISS && sensorDistL != SENSOR_MISS) sensorDistR = sensorDistL;

		touchingFloor = (sensorDistL != SENSOR_MISS && sensorDistL <= 0)
					 || (sensorDistC != SENSOR_MISS && sensorDistC <= 0)
					 || (sensorDistR != SENSOR_MISS && sensorDistR <= 0)
					 || player.isTouching(FlxDirectionFlags.FLOOR);

		onSlope = sensorDistL != SENSOR_MISS
			   && sensorDistR != SENSOR_MISS
			   && sensorDistL != sensorDistR
			   && (sensorDistL <= 0 || sensorDistR <= 0);

		var actuallyTouching = (sensorDistL != SENSOR_MISS && sensorDistL <= 0)
		                    || (sensorDistC != SENSOR_MISS && sensorDistC <= 0)
		                    || (sensorDistR != SENSOR_MISS && sensorDistR <= 0)
		                    || player.isTouching(FlxDirectionFlags.FLOOR);

		var canLand = (player.mode == Ground)
		           || (player.mode == Air       && player.velocity.y >= 0)
		           || ((player.mode == WingOpen || player.mode == Glide || player.mode == WingClose) && actuallyTouching);
		isGrounded = (touchingFloor || onSlope) && canLand;

		if (isGrounded && sensorDistL != SENSOR_MISS && sensorDistR != SENSOR_MISS
		    && sensorDistL != sensorDistR)
		{
			var dy  = sensorDistR - sensorDistL;
			var dx  = player.width * 0.5;
			var deg = Math.atan2(dy, dx) * (180.0 / Math.PI);
			rawAngle    = (deg / 360.0) * 256.0;
			slopeDeg    = Math.abs(deg);
			prevRawAngle = rawAngle;
		}
		else if (isGrounded)
		{
			rawAngle = prevRawAngle * 0.5;
			slopeDeg = Math.abs((rawAngle / 256.0) * 360.0);
			prevRawAngle = rawAngle;
		}
		else
		{
			rawAngle     = 0;
			slopeDeg     = 0;
			prevRawAngle = 0;
		}
	}

	function _slopeSnap():Void
	{
		if (launchCooldown > 0 || player.velocity.y < 0) return;

		var best = SENSOR_MISS;
		inline function consider(d:Int):Void
		{
			if (d != SENSOR_MISS && (best == SENSOR_MISS || d < best)) best = d;
		}
		consider(sensorDistL);
		consider(sensorDistC);
		consider(sensorDistR);

		if (best == SENSOR_MISS) return;

		if (best < -(SNAP_MAX + 1))
			return;

		if (best > SNAP_MAX)
		{
			if (isGrounded && player.mode == Ground)
			{
				player.mode       = Air;
				isGrounded        = false;
				player.groundAngle = 0;
			}
			return;
		}

		if (best != 0) player.y += best;
		player.velocity.y = 0;

		player.groundAngle = rawAngle;

		if (player.mode == Air || player.mode == WingOpen || player.mode == Glide || player.mode == WingClose)
		{
			player.mode          = Ground;
			isGrounded           = true;
			player.inertia       = player.velocity.x;
			player.wingOpenTimer = 0;
		}
	}

	function _wallPush():Void
	{
		var midY = Std.int(player.y + player.height * 0.4);

		var rightEdge = Std.int(player.x + player.width);
		if (slopeMap.isNarrowSlopeAt(rightEdge, midY))
		{
			var rightDist = slopeMap.findWallRight(rightEdge, midY);
			if (rightDist != SENSOR_MISS && rightDist > 0)
			{
				player.x -= rightDist;
				if (player.velocity.x > 0) player.velocity.x = 0;
				if (isGrounded && player.inertia > 0) player.inertia = 0;
			}
		}

		var leftEdge = Std.int(player.x);
		if (slopeMap.isNarrowSlopeAt(leftEdge - 1, midY))
		{
			var leftDist = slopeMap.findWallLeft(leftEdge, midY);
			if (leftDist != SENSOR_MISS && leftDist > 0)
			{
				player.x += leftDist;
				if (player.velocity.x < 0) player.velocity.x = 0;
				if (isGrounded && player.inertia < 0) player.inertia = 0;
			}
		}
	}

	function _applyPhysics(elapsed:Float):Void
	{
		if (isGrounded && launchCooldown == 0)
		{
			if (player.velocity.y >= 0) player.velocity.y = 0;

			var slopeDx   = player.width * 0.5;
			var slopeDy   = (sensorDistL != SENSOR_MISS && sensorDistR != SENSOR_MISS)
			                ? (sensorDistR - sensorDistL) : 0.0;
			var realAngle = Math.atan2(slopeDy, slopeDx);
			var sinA      = Math.sin(realAngle);

			player.inertia -= sinA * TVPlayer.SLOPE_RESIST * elapsed;

			if (slopeDeg > TVPlayer.SLOPE_SLIDE_ANGLE && Math.abs(player.inertia) < TVPlayer.SLOPE_SLIDE_SPEED)
			{
				player.inertia -= sinA * TVPlayer.SLOPE_RESIST * 1.5 * elapsed;
			}

			player.velocity.x = player.inertia;
			player.velocity.y = 0;
		}
		else if (player.mode == Launch)
		{
			player.velocity.y += TVPlayer.GRAVITY * elapsed;
			if (player.velocity.y > TVPlayer.MAX_FALL) player.velocity.y = TVPlayer.MAX_FALL;
			if (player.velocity.y >= 0) player.mode = Air;
		}
		else if (player.mode == WingOpen)
		{
			player.velocity.y += TVPlayer.GRAVITY * 0.4 * elapsed;
			if (player.velocity.y > TVPlayer.GLIDE_MAX_FALL) player.velocity.y = TVPlayer.GLIDE_MAX_FALL;
			player.inertia = player.velocity.x;
			if (player.wingOpenTimer > 0)
			{
				player.wingOpenTimer--;
				if (player.wingOpenTimer == 0) player.mode = Glide;
			}
		}
		else if (player.mode == Glide)
		{
			player.velocity.y += TVPlayer.GLIDE_GRAVITY * elapsed;
			if (player.velocity.y > TVPlayer.GLIDE_MAX_FALL) player.velocity.y = TVPlayer.GLIDE_MAX_FALL;
			player.inertia = player.velocity.x;
		}
		else if (player.mode == WingClose)
		{
			player.velocity.y += TVPlayer.GLIDE_GRAVITY * 2.0 * elapsed;
			if (player.velocity.y > TVPlayer.MAX_FALL) player.velocity.y = TVPlayer.MAX_FALL;
			player.inertia = player.velocity.x;
		}
		else
		{
			player.velocity.y += TVPlayer.GRAVITY * elapsed;
			if (player.velocity.y > TVPlayer.MAX_FALL)
				player.velocity.y = TVPlayer.MAX_FALL;

			if (!player.jumpHeld && player.velocity.y < TVPlayer.JUMP_CUT)
				player.velocity.y = TVPlayer.JUMP_CUT;

			player.inertia = player.velocity.x;
		}
	}

	function _handleInput(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.R)
		{
			player.x = SPAWN_X; player.y = SPAWN_Y;
			player.velocity.set(0, 0);
			player.inertia     = 0;
			player.groundAngle = 0;
			player.mode          = Air;
			isGrounded           = false;
			coyoteTimer          = 0;
			jumpBufTimer         = 0;
			player.glideCooldown = 0;
			player.wingOpenTimer = 0;
			displayAngle         = 0;
			player.angle         = 0;
			return;
		}

		var left     = FlxG.keys.pressed.LEFT  || FlxG.keys.pressed.A;
		var right    = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;
		var down     = FlxG.keys.pressed.DOWN  || FlxG.keys.pressed.S;
		var up       = FlxG.keys.pressed.UP    || FlxG.keys.pressed.W;
		var jumpJust = FlxG.keys.justPressed.Z || FlxG.keys.justPressed.SPACE;
		var jumpRel  = FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE;
		var jumpHeld = FlxG.keys.pressed.Z    || FlxG.keys.pressed.SPACE;

		if (jumpRel)  player.jumpHeld = false;
		if (jumpJust) jumpBufTimer    = JUMP_BUFFER_FRAMES;

		var gnd = _grounded();

		if (gnd && (player.mode == Glide || player.mode == WingOpen || player.mode == WingClose))
		{
			player.mode          = Ground;
			player.wingOpenTimer = 0;
			player.glideCooldown = 0;
		}

		if (gnd)
			_groundMove(elapsed, left, right, down, up);
		else
			_airMove(elapsed, left, right);

		if (jumpBufTimer > 0 && gnd)
		{
			var ar = _s1AngleToRad(player.groundAngle);
			player.velocity.x  = player.inertia;
			player.velocity.y  = TVPlayer.JUMP_VY;
			player.velocity.x -= TVPlayer.JUMP_VY * Math.sin(ar);
			player.inertia     = player.velocity.x;
			player.jumpHeld    = true;
			isGrounded         = false;
			coyoteTimer        = 0;
			jumpBufTimer       = 0;
			player.mode        = Air;
		}

		if (jumpJust && !gnd && player.mode == Air
		    && player.velocity.y > -50 && player.glideCooldown == 0)
		{
			player.velocity.y    = TVPlayer.WINGOPEN_IMPULSE;
			player.wingOpenTimer = TVPlayer.WINGOPEN_FRAMES;
			player.glideCooldown = TVPlayer.GLIDE_COOLDOWN;
			player.mode          = WingOpen;
		}
		else if (!jumpHeld && player.mode == Glide)
		{
			player.mode = WingClose;
		}
	}

	function _groundMove(elapsed:Float, left:Bool, right:Bool, down:Bool, up:Bool):Void
	{
		var v = player.inertia;

		if (right)
		{
			player.facing = FlxDirectionFlags.RIGHT;
			if (v < 0)
			{
				v += TVPlayer.WALK_BRAKE * elapsed;
				if (v > 0) v = 0;
			}
			else
			{
				v += TVPlayer.WALK_ACCEL * elapsed;
				if (v > TVPlayer.WALK_MAX) v = TVPlayer.WALK_MAX;
			}
		}
		else if (left)
		{
			player.facing = FlxDirectionFlags.LEFT;
			if (v > 0)
			{
				v -= TVPlayer.WALK_BRAKE * elapsed;
				if (v < 0) v = 0;
			}
			else
			{
				v -= TVPlayer.WALK_ACCEL * elapsed;
				if (v < -TVPlayer.WALK_MAX) v = -TVPlayer.WALK_MAX;
			}
		}
		else
		{
			if      (v > 0) { v -= TVPlayer.WALK_DECEL * elapsed; if (v < 0) v = 0; }
			else if (v < 0) { v += TVPlayer.WALK_DECEL * elapsed; if (v > 0) v = 0; }
		}

		player.inertia = v;
	}

	function _airMove(elapsed:Float, left:Bool, right:Bool):Void
	{
		var vx = player.velocity.x;
		if (right)
		{
			player.facing = FlxDirectionFlags.RIGHT;
			vx += TVPlayer.AIR_ACCEL * elapsed;
			if (vx > TVPlayer.AIR_MAX) vx = TVPlayer.AIR_MAX;
		}
		else if (left)
		{
			player.facing = FlxDirectionFlags.LEFT;
			vx -= TVPlayer.AIR_ACCEL * elapsed;
			if (vx < -TVPlayer.AIR_MAX) vx = -TVPlayer.AIR_MAX;
		}
		player.velocity.x = vx;
	}

	function _updateCoyote():Void
	{
		if (isGrounded) coyoteTimer = COYOTE_FRAMES;
		else if (coyoteTimer > 0) coyoteTimer--;
	}

	inline function _grounded():Bool return coyoteTimer > 0;

	function _updateAnimation(elapsed:Float):Void
	{
		var gnd   = _grounded();
		var absV  = Math.abs(player.inertia);
		var down  = FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S;
		var up    = FlxG.keys.pressed.UP   || FlxG.keys.pressed.W;

		var animName:String;

		if (player.mode == Launch)
		{
			animName = "launch";
		}
		else if (player.mode == WingOpen)
		{
			animName = "wingopen";
		}
		else if (player.mode == Glide)
		{
			animName = "glide";
		}
		else if (player.mode == WingClose)
		{
			animName = "wingclose";
			if (player.animation.curAnim != null
			    && player.animation.curAnim.name == "wingclose"
			    && player.animation.curAnim.finished)
				player.mode = Air;
		}
		else if (!gnd)
		{
			animName = "jump";
		}
		else
		{
			if (player.mode == Air) player.mode = Ground;

			if (down && absV < 5)
				animName = "crouch";
			else if (up && absV < 5)
				animName = "up";
			else if (absV > 5)
				animName = "walk";
			else
				animName = "idle";
		}

		if (player.animation.curAnim == null || player.animation.curAnim.name != animName)
			player.animation.play(animName, true);

		if (animName == "walk")
		{
			var t = absV / TVPlayer.WALK_MAX;
			var fps = 6 + Std.int(t * 12);
			player.animation.curAnim.frameRate = fps;
		}

		var targetDeg = 0.0;
		if (gnd && slopeDeg > ANGLE_VIS_THRESH)
		{
			targetDeg = (rawAngle / 256.0) * 360.0;
			if (targetDeg > 180) targetDeg -= 360;
		}
		displayAngle += (targetDeg - displayAngle) * 0.25;
		if (Math.abs(displayAngle) < 0.5) displayAngle = 0.0;
		player.angle = displayAngle;
	}

	function _checkLaunchpad(obj1:FlxObject, obj2:FlxObject):Void
	{
		if (launchCooldown > 0 || obj1.velocity.y < 0) return;
		var pBot = obj1.y + obj1.height;
		var pTop = obj2.y;
		if (pBot < pTop - 4) return;
		if (!wantLaunch || pTop < launchPadY) launchPadY = pTop;
		wantLaunch = true;
	}

	function _fireLaunch():Void
	{
		player.y        = launchPadY - player.height;
		player.doLaunch();
		launchCooldown  = LAUNCH_COOLDOWN;
		isGrounded      = false;
		touchingFloor   = false;
		onSlope         = false;
		coyoteTimer     = 0;
		jumpBufTimer    = 0;
	}

	function _updateDebug():Void
	{
		if (FlxG.keys.justPressed.TAB)
		{ showDebug = !showDebug; debugText.visible = showDebug; }
		if (FlxG.keys.justPressed.F1)
			showPlayerHitbox = !showPlayerHitbox;
		if (FlxG.keys.justPressed.F2)
		{ showMapHitbox = !showMapHitbox; hitboxOverlay.visible = showMapHitbox; }
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom = Math.max(0.5, Math.min(8.0, FlxG.camera.zoom + FlxG.mouse.wheel * 0.1));

		playerHitboxSprite.visible = showPlayerHitbox;
		if (showPlayerHitbox)
		{
			var pw = Std.int(player.width);
			var ph = Std.int(player.height);
			if (Std.int(playerHitboxSprite.width) != pw || Std.int(playerHitboxSprite.height) != ph)
			{
				playerHitboxSprite.makeGraphic(pw, ph, FlxColor.TRANSPARENT);
				for (x in 0...pw)
				{
					playerHitboxSprite.pixels.setPixel32(x, 0,    0xFF00FF00);
					playerHitboxSprite.pixels.setPixel32(x, ph-1, 0xFF00FF00);
				}
				for (y in 0...ph)
				{
					playerHitboxSprite.pixels.setPixel32(0,    y, 0xFF00FF00);
					playerHitboxSprite.pixels.setPixel32(pw-1, y, 0xFF00FF00);
				}
				playerHitboxSprite.dirty = true;
			}
			playerHitboxSprite.x = player.x;
			playerHitboxSprite.y = player.y;
		}

		if (!showDebug) return;

		var vx  = Math.round(player.velocity.x);
		var vy  = Math.round(player.velocity.y);
		var modeStr = switch (player.mode)
		{
			case Ground:   "GROUND";
			case Air:      "AIR";
			case Launch:   "LAUNCH";
			case WingOpen:  "WINGOPEN";
			case Glide:     "GLIDE";
			case WingClose: "WINGCLOSE";
		};
		var curAnim = (player.animation.curAnim != null) ? player.animation.curAnim.name : "none";
		var angleS1  = Std.int(player.groundAngle);
		var angleDeg = Math.round((angleS1 / 256.0) * 360.0);

		debugText.text = [
			"── DEBUG (TAB off) ──",
			"vX: " + vx + "  vY: " + vy,
			"inertia: " + Math.round(player.inertia),
			"mode: " + modeStr + "  anim: " + curAnim,
			"grounded: " + isGrounded + "  coyote: " + coyoteTimer,
			"onSlope: " + onSlope + "  slopeDeg: " + Math.round(slopeDeg),
			"angle S1: $" + StringTools.hex(angleS1,2) + " (" + angleDeg + "°)",
			"dL: " + (sensorDistL == SENSOR_MISS ? "MISS" : "" + sensorDistL),
			"dC: " + (sensorDistC == SENSOR_MISS ? "MISS" : "" + sensorDistC),
			"dR: " + (sensorDistR == SENSOR_MISS ? "MISS" : "" + sensorDistR),
			"launch cd: " + launchCooldown + "  glide cd: " + player.glideCooldown,
			"pos: (" + Std.int(player.x) + ", " + Std.int(player.y) + ")",
			"zoom: " + Math.round(FlxG.camera.zoom * 100) / 100,
			"──────────────────",
			"F1: hitbox player  [" + (showPlayerHitbox?"ON":"off") + "]",
			"F2: hitbox map     [" + (showMapHitbox?"ON":"off") + "]",
			"wheel: zoom in/out",
			"R: respawn",
			"ESC/BACK: volver al menu",
		].join("\n");
	}

	inline function _s1AngleToRad(a:Float):Float
		return (a / 256.0) * Math.PI * 2.0;
}
