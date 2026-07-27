package thevalley;

import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;
import flixel.addons.nape.FlxNapeSpace;
import thevalley.bg.BGValley;
import thevalley.map.TVNapeWorld;
import thevalley.player.Player;
import thevalley.player.HUD;
import thevalley.tiles.TileMap;
import thevalley.tiles.Tiles.Launchpad;
import thevalley.tiles.Tiles.SkullPrompt;
import thevalley.tiles.Tiles.Totem;
import thevalley.tiles.Tiles.TotemType;
import thevalley.tiles.Tiles.SpineTile;

class TheValley extends MusicBeatState
{
	static inline var MAP_PARTS:Int = 11;

	var _mapParts:Array<{ part:Int, x:Float, y:Float, width:Float, height:Float }> = [];

	var bgCam:FlxCamera;
	public var uiCam:FlxCamera;
	var bg:BGValley;
	var _vigLeft:FlxSprite;
	var _vigRight:FlxSprite;
	var napeWorld:TVNapeWorld;
	public var player:Player;
	var hud:HUD;
var tileMap:TileMap;
	public var cutscene:TVCutscene;
	var _gameplayStarted:Bool = false;

	public var launchpads:Array<Launchpad>     = [];
	public var skullPrompts:Array<SkullPrompt> = [];
	public var totems:Array<Totem>             = [];

	public var objectGroup:FlxTypedGroup<FlxSprite>;
	public var treeGroup:FlxTypedGroup<FlxSprite>;
	public var trees:Array<FlxSprite> = [];

	static inline var NATIVE_W:Int = 1280;
	static inline var NATIVE_H:Int = 896;

	static var _prevAntialiasing:Bool = false;
	static var _letterboxed:Bool      = false;
	static var _wasFullscreen:Bool    = false;

	override public function create():Void
	{
		_prevAntialiasing = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		super.create();

		bgCam = new FlxCamera(0, 0, 1280, 896);
		bgCam.bgColor = 0xFF000000;
		bgCam.zoom = 2.8;
		FlxG.cameras.reset(bgCam);

		uiCam = new FlxCamera(0, 0, 1280, 896);
		uiCam.bgColor = 0x00000000;
		FlxG.cameras.add(uiCam, false);

		_enableLetterbox();

		// map is chopped into 11 pieces (1.json thru 11.json) instead of one big map.
		for (i in 1...MAP_PARTS + 1)
		{
			var path = 'assets/shared/data/minigame/thevalley/map/$i.json';
			if (!openfl.Assets.exists(path)) continue;
			var raw = openfl.Assets.getText(path);
			if (raw != null) _mapParts.push(haxe.Json.parse(raw));
		}

		var mapW:Float = 0;
		var mapMinY:Float = 0;
		var mapMaxY:Float = 0;
		for (p in _mapParts)
		{
			if (p.x + p.width  > mapW)    mapW    = p.x + p.width;
			if (p.y            < mapMinY)  mapMinY = p.y;
			if (p.y + p.height > mapMaxY)  mapMaxY = p.y + p.height;
		}

		napeWorld = new TVNapeWorld();
		napeWorld.init();
		napeWorld.partOffsets = [for (p in _mapParts) { x: p.x, y: p.y }];
		napeWorld.loadParts("assets/shared/images/minigame/thevalley/map/", MAP_PARTS);

		bg = new BGValley(this, _mapParts);
		bg.addSprites();

		treeGroup = new FlxTypedGroup<FlxSprite>();
		add(treeGroup);
		var map1Spr = bg.mapSprites.length > 0 ? bg.mapSprites[0] : null;
		if (map1Spr != null)
		{
			members.remove(treeGroup);
			var map1Idx = members.indexOf(map1Spr);
			members.insert(map1Idx, treeGroup);
		}

		objectGroup = new FlxTypedGroup<FlxSprite>();
		add(objectGroup);

		player = new Player(80.0, 155.0, "assets/shared/images/minigame/thevalley/characters/fakergf/fakergf.json");
		player.cinematic = true;
		add(player);

		bgCam.follow(player, FlxCameraFollowStyle.LOCKON);
		bgCam.followLerp = 0.08;
		bgCam.setScrollBounds(0, 11749, null, null);

		hud = new HUD(this, uiCam);
		hud.setVisible(false);
		hud.timerRunning = false;

		_vigLeft = FlxGradient.createGradientFlxSprite(420, 896, [0xAA000000, 0x00000000], 1, 0);
		_vigLeft.scrollFactor.set(0, 0); _vigLeft.cameras = [uiCam]; add(_vigLeft);

		_vigRight = FlxGradient.createGradientFlxSprite(420, 896, [0x00000000, 0xAA000000], 1, 0);
		_vigRight.x = 1280 - 420; _vigRight.scrollFactor.set(0, 0); _vigRight.cameras = [uiCam]; add(_vigRight);

		var vigTop = FlxGradient.createGradientFlxSprite(1280, 200, [0x66000000, 0x00000000], 1, 90);
		vigTop.scrollFactor.set(0, 0); vigTop.cameras = [uiCam]; add(vigTop);

		var vigBottom = FlxGradient.createGradientFlxSprite(1280, 200, [0x00000000, 0xAA000000], 1, 90);
		vigBottom.x = 0; vigBottom.y = 896 - 200; vigBottom.scrollFactor.set(0, 0); vigBottom.cameras = [uiCam]; add(vigBottom);

		cutscene = new TVCutscene(this, player, bgCam, uiCam, hud);
		cutscene.addSprites(this, uiCam);

		cutscene.onGameplayStart = function()
		{
			_gameplayStarted  = true;
			player.cinematic  = false;
			hud.setVisible(true);
			hud.timerRunning  = true;
		};
		cutscene.onSkullWin = function()
		{
			hud.addShard();
		};
		cutscene.onSkullCS2Done = function()
		{
			hud.addShard();
		};
		cutscene.skipAll();

		bg.addFrontLayers();

		tileMap = new TileMap();
		tileMap.loadFromJson(this);

		var map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr != null)
			tileMap.insertSpineSprites(this, map7Spr);
		tileMap.insertHoldingSprites(this);

		_loadObjects();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (_letterboxed)
		{
			final fs = FlxG.fullscreen;
			if (_wasFullscreen && !fs) _snapWindow();
			_wasFullscreen = fs;
		}

		bg.update(elapsed, player);
		hud.update(elapsed);
		tileMap.update(elapsed, player);

		cutscene.update(elapsed);
		for (sk in skullPrompts) sk.update(elapsed);
		for (g in tileMap.garys) g.npcUpdate(elapsed);
		player.updateAnim(elapsed);

		if (_gameplayStarted)
		{
			player.handleInput(elapsed, 80.0, 155.0);
			hud.setStamina(player.stamina / player.cfg.physics.staminaMax);

			for (lp in launchpads)
			{
				lp.tryLaunch(player);
				lp.padUpdate(elapsed);
			}

			var busySkull:SkullPrompt = null;
			for (sk in skullPrompts) if (sk.isBusy()) { busySkull = sk; break; }
			if (busySkull != null)
			{
				busySkull.updateActive(elapsed, busySkull.getDist());
			}
			else
			{
				var nearest:SkullPrompt = null;
				var nearDist = SkullPrompt.INTERACT_DIST;
				for (sk in skullPrompts)
				{
					var d = sk.getDist();
					if (d < nearDist) { nearDist = d; nearest = sk; }
				}
				if (nearest != null) nearest.updateActive(elapsed, nearDist);
			}

			var busyTotem:Totem = null;
			for (tm in totems) if (tm.isBusy()) { busyTotem = tm; break; }
			if (busyTotem != null)
			{
				busyTotem.updateActive(elapsed, busyTotem.getDist());
			}
			else
			{
				var nearestTotem:Totem = null;
				var nearTotemDist = 120.0;
				for (tm in totems)
				{
					var d = tm.getDist();
					if (d < nearTotemDist) { nearTotemDist = d; nearestTotem = tm; }
				}
				if (nearestTotem != null)
					nearestTotem.updateActive(elapsed, nearTotemDist);
			}
		}
	}

	override public function destroy():Void
	{
		FlxSprite.defaultAntialiasing = _prevAntialiasing;
		_disableLetterbox();
		super.destroy();
	}

	static function _enableLetterbox():Void
	{
		if (_letterboxed) return;
		_letterboxed = true;

		for (cam in FlxG.cameras.list)
			cam.setSize(NATIVE_W, NATIVE_H);

		FlxG.scaleMode = new flixel.system.scaleModes.FixedRatioScaleMode(NATIVE_W, NATIVE_H);
		FlxG.stage.window.resizable = false;

		_wasFullscreen = FlxG.fullscreen;
		if (!FlxG.fullscreen) _snapWindow();
	}

	static function _disableLetterbox():Void
	{
		if (!_letterboxed) return;
		_letterboxed = false;

		for (cam in FlxG.cameras.list)
			cam.setSize(FlxG.initialWidth, FlxG.initialHeight);

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		FlxG.stage.window.resizable = true;

		if (!FlxG.fullscreen)
		{
			FlxG.resizeGame(FlxG.initialWidth, FlxG.initialHeight);
			FlxG.resizeWindow(FlxG.initialWidth, FlxG.initialHeight);

			final screen = FlxG.stage.window.display;
			final winX = Std.int((screen.bounds.width  - FlxG.initialWidth)  / 2);
			final winY = Std.int((screen.bounds.height - FlxG.initialHeight) / 2);
			FlxG.stage.window.move(winX, winY);
		}
	}

	static function _snapWindow():Void
	{
		FlxG.resizeWindow(NATIVE_W, NATIVE_H);

		final screen = FlxG.stage.window.display;
		final winX = Std.int((screen.bounds.width  - NATIVE_W) / 2);
		final winY = Std.int((screen.bounds.height - NATIVE_H) / 2);
		FlxG.stage.window.move(winX, winY);
	}

	public function reorderSpine(sp:thevalley.tiles.SpineTile):Void
	{
		var map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr == null) return;
		var idx = members.indexOf(map7Spr);
		if (idx < 0) return;
		members.remove(sp.sprite);
		members.insert(idx + 1, sp.sprite);
	}

	public function spawnTree(wx:Float, wy:Float):FlxSprite
	{
		var t = new FlxSprite(wx, wy);
		t.loadGraphic(Paths.image("minigame/thevalley/map/1/tree"));
		t.scrollFactor.set(1, 1);
		trees.push(t);
		treeGroup.add(t);
		return t;
	}

	public function spawnLaunchpad(wx:Float, wy:Float):Launchpad
	{
		var lp = new Launchpad(wx, wy);
		launchpads.push(lp);
		add(lp);
		return lp;
	}

	public function spawnSkull(wx:Float, wy:Float):SkullPrompt
	{
		var sk = new SkullPrompt(wx, wy, player, cutscene, objectGroup);
		sk.skullId = skullPrompts.length;
		skullPrompts.push(sk);
		return sk;
	}

	public function spawnTotem(wx:Float, wy:Float, type:TotemType):Totem
	{
		var tm = new Totem(wx, wy, type, player, cutscene, objectGroup, this);
		totems.push(tm);
		return tm;
	}

	public function saveObjects():Void
	{
		#if sys
		var lps = [for (lp in launchpads) { x: lp.x, y: lp.y }];
		var sks = [for (sk in skullPrompts) { x: sk.skullX, y: sk.skullY }];
		var tms = [for (tm in totems) {
			x: tm.totemX, y: tm.totemY,
			type: switch (tm.totemType) {
				case Short: "short";
				case Tall:  "tall";
				default:    "fake";
			}
		}];
		var trs = [for (t in trees) { x: t.x, y: t.y }];
		var json = haxe.Json.stringify({ launchpads: lps, skulls: sks, totems: tms, trees: trs }, null, "  ");
		sys.io.File.saveContent("assets/shared/data/minigame/thevalley/objects.json", json);
		#end
	}

	function _loadObjects():Void
	{
		var raw = openfl.Assets.getText("assets/shared/data/minigame/thevalley/objects.json");
		if (raw == null || raw == "") return;
		var data:{ launchpads:Array<{x:Float,y:Float}>, skulls:Array<{x:Float,y:Float}>,
		           totems:Array<{x:Float,y:Float,type:String}>, trees:Array<{x:Float,y:Float}> } = haxe.Json.parse(raw);
		if (data.launchpads != null) for (d in data.launchpads) spawnLaunchpad(d.x, d.y);
		if (data.skulls     != null) for (d in data.skulls)     spawnSkull(d.x, d.y);
		if (data.trees      != null) for (d in data.trees)      spawnTree(d.x, d.y);
		if (data.totems     != null)
			for (d in data.totems)
			{
				var t = switch (d.type) {
					case "short": TotemType.Short;
					case "tall":  TotemType.Tall;
					default:      TotemType.Fake;
				};
				spawnTotem(d.x, d.y, t);
			}
	}

	function _onPlayerKilled():Void
	{
		hud.lives--;
		if (hud.lives <= 0)
		{
			trace("Game Over");
		}
		else
		{
			player.body.position.setxy(80.0 + player.width * 0.5, 155.0 + player.height * 0.5);
			player.body.velocity.setxy(0, 0);
		}
	}
}
