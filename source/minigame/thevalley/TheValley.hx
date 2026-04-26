package minigame.thevalley;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxColor;
import minigame.thevalley.TVPlayer;
import minigame.thevalley.TVSlopeMap;
import minigame.thevalley.TVHitboxMap;

class TheValley extends MusicBeatState
{
	var player:TVPlayer;
	var hitboxMap:TVHitboxMap;
	var slopeMap:TVSlopeMap;
	var hitboxOverlay:FlxSprite;

	var hudCamera:flixel.FlxCamera;

	var debugText:FlxText;
	var playerHitboxSprite:FlxSprite;
	var showDebug:Bool        = false;
	var showPlayerHitbox:Bool = false;
	var showMapHitbox:Bool    = true;

	static inline var SPAWN_X:Float = 150;
	static inline var SPAWN_Y:Float = 800;

	static inline var SENSOR_MISS:Int     = TVSlopeMap.MISS_DIST;
	static inline var FLOOR_SCAN_GND:Int  = 20;
	static inline var FLOOR_SCAN_AIR:Int  = TVSlopeMap.SCAN_UP + 1;
	static inline var SNAP_MAX:Int        = 14;
	static inline var SENSOR_DIFF_MAX:Int  = 20;
	static inline var LAUNCH_COOLDOWN:Int  = 20;
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

		var mapSprite = new FlxSprite(0, 0);
		mapSprite.loadGraphic(backend.Paths.image('minigame/thevalley/map'));
		add(mapSprite);

		var hitboxBmd = openfl.Assets.getBitmapData('assets/shared/images/minigame/thevalley/hitbox.png');

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

		if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.music.stop();
			FlxG.switchState(() -> new states.EXEMenu());
			return;
		}

		if (launchCooldown       > 0) launchCooldown--;
		if (player.glideCooldown > 0) player.glideCooldown--;
		if (player.jumpBufTimer  > 0) player.jumpBufTimer--;

		wantLaunch = false;
		FlxG.overlap(player, hitboxMap.launchpads, _checkLaunchpad);
		if (wantLaunch) _fireLaunch();

		player.updateSensors(slopeMap, launchCooldown, FLOOR_SCAN_GND, FLOOR_SCAN_AIR, SENSOR_DIFF_MAX);

		player.applyPhysics(elapsed, launchCooldown);

		if (launchCooldown > 0 && player.velocity.y < 0)
			player.allowCollisions = FlxDirectionFlags.LEFT | FlxDirectionFlags.RIGHT;
		else if (player.isGrounded && player.onSlope)
			player.allowCollisions = FlxDirectionFlags.UP | FlxDirectionFlags.DOWN;
		else
			player.allowCollisions = FlxDirectionFlags.ANY;

		FlxG.collide(player, hitboxMap.solidTiles);
		FlxG.collide(player, hitboxMap.platformTiles);
		player.allowCollisions = FlxDirectionFlags.ANY;

		player.slopeSnap(launchCooldown, SNAP_MAX);
		player.wallPush(slopeMap);
		player.updateCoyote();

		var respawned = player.handleInput(elapsed, controls, SPAWN_X, SPAWN_Y);
		if (respawned)
		{
			launchCooldown = 0;
			wantLaunch     = false;
		}

		player.updateAnim(elapsed, controls);

		_updateDebug();
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
		player.y           = launchPadY - player.height;
		player.doLaunch();
		launchCooldown     = LAUNCH_COOLDOWN;
		player.isGrounded  = false;
		player.touchingFloor = false;
		player.onSlope     = false;
		player.coyoteTimer = 0;
		player.jumpBufTimer = 0;
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

		var vx      = Math.round(player.velocity.x);
		var vy      = Math.round(player.velocity.y);
		var modeStr = switch (player.mode)
		{
			case Ground:    "GROUND";
			case Air:       "AIR";
			case Launch:    "LAUNCH";
			case WingOpen:  "WINGOPEN";
			case Glide:     "GLIDE";
			case WingClose: "WINGCLOSE";
		};
		var curAnim  = (player.animation.curAnim != null) ? player.animation.curAnim.name : "none";
		var angleS1  = Std.int(player.groundAngle);
		var angleDeg = Math.round(TVSlopeMap.s1ToDeg(angleS1));

		debugText.text = [
			"── DEBUG (TAB off) ──",
			"vX: " + vx + "  vY: " + vy,
			"inertia: " + Math.round(player.inertia),
			"mode: " + modeStr + "  anim: " + curAnim,
			"grounded: " + player.isGrounded + "  coyote: " + player.coyoteTimer,
			"onSlope: " + player.onSlope + "  slopeDeg: " + Math.round(player.slopeDeg),
			"angle S1: $" + StringTools.hex(angleS1, 2) + " (" + angleDeg + "°)",
			"dL: " + (player.sensorDistL == SENSOR_MISS ? "MISS" : "" + player.sensorDistL),
			"dC: " + (player.sensorDistC == SENSOR_MISS ? "MISS" : "" + player.sensorDistC),
			"dR: " + (player.sensorDistR == SENSOR_MISS ? "MISS" : "" + player.sensorDistR),
			"launch cd: " + launchCooldown + "  glide cd: " + player.glideCooldown,
			"pos: (" + Std.int(player.x) + ", " + Std.int(player.y) + ")",
			"zoom: " + Math.round(FlxG.camera.zoom * 100) / 100,
			"──────────────────",
			"F1: hitbox player  [" + (showPlayerHitbox ? "ON" : "off") + "]",
			"F2: hitbox map     [" + (showMapHitbox    ? "ON" : "off") + "]",
			"wheel: zoom in/out",
			"R: respawn",
			"ESC/BACK: volver al menu",
		].join("\n");
	}
}
