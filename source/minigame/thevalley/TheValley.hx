package minigame.thevalley;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import flixel.addons.nape.FlxNapeSpace;

import minigame.thevalley.TVPlayer;
import minigame.thevalley.TVHitboxMap;
import minigame.thevalley.TVNapeWorldBuilder;

class TheValley extends MusicBeatState
{
	var player:TVPlayer;
	var hitboxMap:TVHitboxMap;
	var hitboxOverlay:FlxSprite;

	var napeDebug:TVNapeDebugDraw;
	var showNapeDebug:Bool = false;

	var hudCamera:flixel.FlxCamera;

	var debugText:FlxText;
	var playerHitboxSprite:FlxSprite;

	var showDebug:Bool = false;
	var showPlayerHitbox:Bool = false;
	var showMapHitbox:Bool = true;

	static inline final SPAWN_X:Float = 150;
	static inline final SPAWN_Y:Float = 800;

	static inline final LAUNCH_COOLDOWN:Int = 20;

	var launchCooldown:Int = 0;
	var wantLaunch:Bool = false;
	var launchPadY:Float = 0;

	override public function create():Void
	{
		super.create();

		FlxNapeSpace.init();
		FlxNapeSpace.space?.clear();
		FlxNapeSpace.space?.gravity.setxy(0, 900);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("The Valley", null);
		#end

		FlxG.camera.zoom = 3.0;

		hudCamera = new flixel.FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

		final mapSprite = new FlxSprite(0, 0);
		mapSprite.loadGraphic(backend.Paths.image('minigame/thevalley/map'));
		add(mapSprite);

		final hitboxBmd = openfl.Assets.getBitmapData('assets/shared/images/minigame/thevalley/hitbox.png');

		hitboxOverlay = new FlxSprite(0, 0);
		hitboxOverlay.loadGraphic(backend.Paths.image('minigame/thevalley/hitbox', null, false));
		hitboxOverlay.alpha = 0.35;
		hitboxOverlay.visible = showMapHitbox;
		add(hitboxOverlay);

		hitboxMap = new TVHitboxMap();
		hitboxMap.loadFromBitmap(hitboxBmd);

		add(hitboxMap.solidTiles);
		add(hitboxMap.platformTiles);
		add(hitboxMap.launchpads);

		TVNapeWorldBuilder.buildFromBitmap(hitboxBmd);

		napeDebug = new TVNapeDebugDraw(Std.int(mapSprite.width), Std.int(mapSprite.height));
		napeDebug.visible = false;
		add(napeDebug);

		player = new TVPlayer(SPAWN_X, SPAWN_Y);
		add(player);

		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.10);
		FlxG.camera.setScrollBoundsRect(0, 0, mapSprite.width, mapSprite.height, true);
		FlxG.worldBounds.set(0, 0, mapSprite.width, mapSprite.height);

		final exitHint = new FlxText(0, 4, 0, "ESC / BACK — volver al menu", 10);
		exitHint.setFormat(null, 10, FlxColor.WHITE, RIGHT);
		exitHint.setBorderStyle(flixel.text.FlxText.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		exitHint.x = FlxG.width - exitHint.width - 4;
		exitHint.scrollFactor.set(0, 0);
		exitHint.camera = hudCamera;
		add(exitHint);

		debugText = new FlxText(0, 18, FlxG.width - 10, "", 10);
		debugText.setFormat(null, 10, FlxColor.WHITE, RIGHT);
		debugText.setBorderStyle(flixel.text.FlxText.FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		debugText.scrollFactor.set(0, 0);
		debugText.camera = hudCamera;
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

		if (launchCooldown > 0)
			launchCooldown--;

		wantLaunch = false;
		//FlxG.overlap(player, hitboxMap.launchpads, _checkLaunchpad);

		if (wantLaunch)
			_fireLaunch();

		var respawned = player.handleInput(elapsed, controls, SPAWN_X, SPAWN_Y);
		player.updateNapePlayer(elapsed);

		if (respawned)
		{
			launchCooldown = 0;
			wantLaunch = false;
		}

		player.updateAnim(elapsed, controls);

		_updateDebug();
	}

	function _checkLaunchpad(obj1:FlxObject, obj2:FlxObject):Void
	{
		if (launchCooldown > 0 || obj1.velocity.y < 0)
			return;

		var pBot = obj1.y + obj1.height;
		var pTop = obj2.y;

		if (pBot < pTop - 4)
			return;

		if (!wantLaunch || pTop < launchPadY)
			launchPadY = pTop;

		wantLaunch = true;
	}

	function _fireLaunch():Void
	{
		player.setBodyXY(player.x, launchPadY - player.height);
		player.doLaunch();

		launchCooldown = LAUNCH_COOLDOWN;
		player.isGrounded = false;
		player.touchingFloor = false;
		player.coyoteTimer = 0;
		player.jumpBufTimer = 0;
	}

	function _updateDebug():Void
	{
		if (FlxG.keys.justPressed.TAB)
		{
			showDebug = !showDebug;
			debugText.visible = showDebug;
		}

		if (FlxG.keys.justPressed.F1)
			showPlayerHitbox = !showPlayerHitbox;

		if (FlxG.keys.justPressed.F2)
		{
			showMapHitbox = !showMapHitbox;
			hitboxOverlay.visible = showMapHitbox;
		}

		if (FlxG.keys.justPressed.F3)
		{
			showNapeDebug = !showNapeDebug;
			napeDebug.visible = showNapeDebug;

			if (showNapeDebug)
				napeDebug.redraw();
		}

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
					playerHitboxSprite.pixels.setPixel32(x, 0, 0xFF00FF00);
					playerHitboxSprite.pixels.setPixel32(x, ph - 1, 0xFF00FF00);
				}

				for (y in 0...ph)
				{
					playerHitboxSprite.pixels.setPixel32(0, y, 0xFF00FF00);
					playerHitboxSprite.pixels.setPixel32(pw - 1, y, 0xFF00FF00);
				}

				playerHitboxSprite.dirty = true;
			}

			playerHitboxSprite.x = player.x;
			playerHitboxSprite.y = player.y;
		}

		if (!showDebug)
			return;

		final modeStr = switch (player.mode)
		{
			case Ground: "GROUND";
			case Air: "AIR";
			case Launch: "LAUNCH";
			case WingOpen: "WINGOPEN";
			case Glide: "GLIDE";
			case WingClose: "WINGCLOSE";
		};

		final curAnim = player.animation.curAnim != null ? player.animation.curAnim.name : "none";

		debugText.text = [
			"── DEBUG (TAB off) ──",
			"vX: " + Math.round(player.velocity.x) + "  vY: " + Math.round(player.velocity.y),
			"inertia: " + Math.round(player.inertia),
			"mode: " + modeStr + "  anim: " + curAnim,
			"grounded: " + player.isGrounded + "  coyote: " + player.coyoteTimer,
			"launch cd: " + launchCooldown + "  glide cd: " + player.glideCooldown,
			"pos: (" + Std.int(player.x) + ", " + Std.int(player.y) + ")",
			"zoom: " + Math.round(FlxG.camera.zoom * 100) / 100,
			"──────────────────",
			"F1: hitbox player  [" + (showPlayerHitbox ? "ON" : "off") + "]",
			"F2: hitbox map     [" + (showMapHitbox ? "ON" : "off") + "]",
			"F3: nape hitboxes  [" + (showNapeDebug ? "ON" : "off") + "]",
			"wheel: zoom in/out",
			"R: respawn",
			"ESC/BACK: volver al menu",
		].join("\n");
	}
}