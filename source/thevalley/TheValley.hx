package thevalley;

import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
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

	public var bgCam:FlxCamera;
	public var uiCam:FlxCamera;

	public var bg:BGValley;
	var _vignette:FlxSprite;
	var _vigTimer:Float = 0;
	var napeWorld:TVNapeWorld;

	var hud:HUD;
	public var tileMap:TileMap;

	var _gameplayStarted:Bool = false;

	var _ambientSound:flixel.sound.FlxSound;
	var _ambientCloseness:Float = 0;

	var _lookDownTimer:Float = 0;

	var _deathFade:FlxSprite;
	var _spineDeathPhase:Int   = 0;
	var _spineDeathTimer:Float = 0;
	var _musicFadeFrom:Float   = 1.0;

	var _occlusionAmount:Float = 0;

	var _isRestarting:Bool          = false;
	var _pauseWatcher:Void->Void    = null;

	public var cutscene:TVCutscene;
	public var player:Player;

	public var launchpads:Array<Launchpad>     = [];
	public var skullPrompts:Array<SkullPrompt> = [];
	public var totems:Array<Totem>             = [];

	public var objectGroup:FlxTypedGroup<FlxSprite>;
	public var treeGroup:FlxTypedGroup<FlxSprite>;
	public var trees:Array<FlxSprite> = [];
	public var tileCheckers:Array<FlxSprite> = [];

	static var _prevAntialiasing:Bool = false;
	var _prevWindowTitle:String;

	override public function create():Void
	{
		_prevAntialiasing = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		super.create();

		_prevWindowTitle = FlxG.stage.window.title;
		FlxG.stage.window.title = "Friday Night Funkin': In The Valley";

		PlayState.isLetterboxedAspectRatio = true;

		bgCam = new FlxCamera();
		bgCam.bgColor = 0xFF000000;
		bgCam.zoom = 2.8;
		FlxG.cameras.reset(bgCam);

		uiCam = new FlxCamera();
		uiCam.bgColor = 0x00000000;
		FlxG.cameras.add(uiCam, false);

		for (i in 1...MAP_PARTS + 1)
		{
			var path = 'assets/shared/data/minigame/thevalley/map/$i.json';
			if (!openfl.Assets.exists(path)) continue;
			var raw = openfl.Assets.getText(path);
			if (raw != null) _mapParts.push(haxe.Json.parse(raw));
		}

		var mapW:Float = 0;
		var mapMinX:Float = Math.POSITIVE_INFINITY;
		var mapMinY:Float = 0;
		var mapMaxY:Float = 0;

		for (p in _mapParts)
		{
			if (p.x + p.width  > mapW)    mapW    = p.x + p.width;
			if (p.x            < mapMinX) mapMinX = p.x;
			if (p.y            < mapMinY) mapMinY = p.y;
			if (p.y + p.height > mapMaxY) mapMaxY = p.y + p.height;
		}

		if (mapMinX == Math.POSITIVE_INFINITY) mapMinX = 0;

		napeWorld = new TVNapeWorld();
		napeWorld.init();
		napeWorld.partOffsets = [for (p in _mapParts) { x: p.x, y: p.y }];
		napeWorld.loadParts("assets/shared/images/minigame/thevalley/map/", MAP_PARTS);

		var wallMat = new nape.phys.Material(0.0, 0.0, 0.0, 1.0, 0.0);

		var leftWall = new nape.phys.Body(nape.phys.BodyType.STATIC, nape.geom.Vec2.weak(mapMinX - 500, -5000));
		leftWall.shapes.add(new nape.shape.Polygon(nape.shape.Polygon.rect(0, 0, 500, 20000)));
		leftWall.setShapeMaterials(wallMat);
		leftWall.space = flixel.addons.nape.FlxNapeSpace.space;

		var rightWall = new nape.phys.Body(nape.phys.BodyType.STATIC, nape.geom.Vec2.weak(mapW, -5000));
		rightWall.shapes.add(new nape.shape.Polygon(nape.shape.Polygon.rect(0, 0, 500, 20000)));
		rightWall.setShapeMaterials(wallMat);
		rightWall.space = flixel.addons.nape.FlxNapeSpace.space;

		var floorWall = new nape.phys.Body(nape.phys.BodyType.STATIC, nape.geom.Vec2.weak(-5000, mapMaxY + 200));
		floorWall.shapes.add(new nape.shape.Polygon(nape.shape.Polygon.rect(0, 0, 30000, 500)));
		floorWall.setShapeMaterials(wallMat);
		floorWall.space = flixel.addons.nape.FlxNapeSpace.space;

		bg = new BGValley(this, _mapParts);
		bg.addSprites();

		treeGroup = new FlxTypedGroup<FlxSprite>();
		add(treeGroup);

		var map1Spr = bg.mapSprites.length > 0 ? bg.mapSprites[0] : null;
		if (map1Spr != null)
		{
			members.remove(treeGroup);
			members.insert(members.indexOf(map1Spr), treeGroup);
		}

		objectGroup = new FlxTypedGroup<FlxSprite>();
		add(objectGroup);

		player = new Player(146.0, 134.0, "assets/shared/images/minigame/thevalley/characters/fakergf/fakergf.json");
		player.cinematic = true;
		add(player);

		bgCam.setScrollBounds(0, 11749, null, null);

		_vignette = _buildVignette();
		add(_vignette);

		hud = new HUD(this, uiCam);
		hud.timerRunning = false;

		cutscene = new TVCutscene(this, player, bgCam, uiCam, hud);
		cutscene.addSprites(this, uiCam);

		cutscene.onGameplayStart = function()
		{
			_gameplayStarted  = true;
			player.cinematic  = false;
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
		cutscene.playIntro();

		_ambientSound = FlxG.sound.load(Paths.music("minigame/thevalley/ambient"), 0, true, null, false, true);

		bg.addFrontLayers();

		tileMap = new TileMap();
		tileMap.onPlayerKilled = _startSpineDeathSequence;
		tileMap.loadFromJson(this);

		var map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr != null)
			tileMap.insertSpineSprites(this, map7Spr);

		_loadObjects();

		var holdingAnchors = tileCheckers.length > 0
			? tileCheckers
			: [for (sp in tileMap.spines) sp.sprite];
		tileMap.insertHoldingSprites(this, holdingAnchors);

		_deathFade = new FlxSprite(0, 0);
		_deathFade.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		_deathFade.scrollFactor.set(0, 0);
		_deathFade.cameras = [uiCam];
		_deathFade.alpha = 0;
		add(_deathFade);

		if (PlayState.instance == null)
		{
			var dummyPlayState = new PlayState();
			dummyPlayState.vocals = new FlxSound();
			PlayState.instance = dummyPlayState;
		}

		flixel.addons.nape.FlxNapeSpace.drawDebug = true;
		FlxG.debugger.drawDebug = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (bgCam.target != null) bgCam.followLerp = 0.08;

		var nape = FlxG.plugins.get(flixel.addons.nape.FlxNapeSpace);
		if (nape != null) nape.active = true;

		if (FlxG.sound.music != null) FlxG.sound.music.play();

		if (controls.PAUSE)
		{
			persistentUpdate = false;
			persistentDraw   = true;
			bgCam.followLerp = 0;
			if (nape != null) nape.active = false;
			if (FlxG.sound.music != null) FlxG.sound.music.pause();

			options.OptionsState.standaloneReturnState = () -> new thevalley.TheValley();

			states.substates.PauseSubState.cameraWidth = FlxG.width;
			openSubState(new states.substates.PauseSubState());

			var canCheckRestart = true;
			_pauseWatcher = () -> {
				var pauseSub = Std.downcast(subState, states.substates.PauseSubState);
				if (pauseSub == null) { _removePauseWatcher(); return; }
				if (canCheckRestart)
				{
					@:privateAccess _isRestarting = (pauseSub.curSelected == 1);
					if (controls.ACCEPT) canCheckRestart = false;
				}
			};
			FlxG.signals.postUpdate.add(_pauseWatcher);
			return;
		}

		bg.update(elapsed, player);
		_updateVignette(elapsed);

		_updatePlayerOcclusion(elapsed);

		hud.setVisible(!player.cinematic && !player.isHiding && !player.isHidden);
		hud.update(elapsed);
		tileMap.update(elapsed, player);

		_updateSpineDeath(elapsed);

		cutscene.update(elapsed);
		for (sk in skullPrompts) sk.update(elapsed);
		player.updateAnim(elapsed);

		if (_gameplayStarted)
		{
			player.handleInput(elapsed, 146.0, 134.0);
			hud.setStamina(player.stamina / player.cfg.physics.staminaMax);
			_updateLookDown(elapsed);

			for (g in tileMap.garys) g.npcUpdate(elapsed);
			_updateAmbience(elapsed);

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

			_updateTotemHide(elapsed);
		}
	}

	function _removePauseWatcher():Void
	{
		if (_pauseWatcher != null)
		{
			FlxG.signals.postUpdate.remove(_pauseWatcher);
			_pauseWatcher = null;
		}
	}

	function _updateLookDown(elapsed:Float):Void
	{
		var holding = FlxG.keys.pressed.S && !player.cinematic;
		_lookDownTimer = holding ? _lookDownTimer + elapsed : 0;

		var active = _lookDownTimer >= 3.0;
		bgCam.targetOffset.y = active ? 80.0 : 0;
	}

	function _updatePlayerOcclusion(elapsed:Float):Void
	{

		var target = bg.getOcclusionAmount(player, trees);
		_occlusionAmount += (target - _occlusionAmount) * (1.0 - Math.pow(0.01, elapsed * 6.0));
		player.color = FlxColor.interpolate(FlxColor.WHITE, 0xFF63636E, _occlusionAmount);
	}

	function _updateAmbience(elapsed:Float):Void
	{
		var closeness = 0.0;
		var forceFull = false;
		for (g in tileMap.garys)
		{
			var d = g.getDist();
			var c = 1.0 - Math.min(Math.max((d - 60.0) / (220.0 - 60.0), 0.0), 1.0);
			if (c > closeness) closeness = c;
			if (g.isTalking) forceFull = true;
		}
		for (tm in totems)
		{
			var dt = tm.getDist();
			var ct = 1.0 - Math.min(Math.max((dt - 70.0) / (220.0 - 70.0), 0.0), 1.0);
			if (ct > closeness) closeness = ct;
			if (tm.isBusy()) forceFull = true;
		}
		if (forceFull) closeness = 1.0;

		_ambientCloseness += (closeness - _ambientCloseness) * (1.0 - Math.pow(0.01, elapsed * 2.0));

		if (_spineDeathPhase == 0 && FlxG.sound.music != null) FlxG.sound.music.volume = 1.0 - _ambientCloseness;
		if (_ambientSound != null) _ambientSound.volume = _ambientCloseness * 0.5;
	}

	static inline var TOTEM_ZOOM_RATE:Float = 1.0;

	function _updateTotemHide(elapsed:Float):Void
	{
		var hiding = player.isHiding || player.isHidden;
		if (!hiding && Math.abs(bgCam.zoom - 2.8) < 0.01) return;

		var targetZoom = hiding ? 4.80 : 2.8;
		bgCam.zoom += (targetZoom - bgCam.zoom) * (1.0 - Math.pow(0.01, elapsed * TOTEM_ZOOM_RATE));
	}

	function _buildVignette():FlxSprite
	{
		var w  = FlxG.width;
		var h  = FlxG.height;
		var bmd = new openfl.display.BitmapData(w, h, true, 0x00000000);
		var cx = w * 0.5;
		var cy = h * 0.5;

		for (y in 0...h)
		{
			var dy = (y - cy) / cy;
			for (x in 0...w)
			{
				var dx = (x - cx) / cx;
				var dist = Math.sqrt(dx * dx + dy * dy);

				var a = (dist - 0.35) / (1.15 - 0.35);
				if (a < 0) a = 0;
				if (a > 1) a = 1;
				a *= a;

				var alpha = Std.int(a * 235);
				bmd.setPixel32(x, y, (alpha << 24) | 0x000000);
			}
		}

		var spr = new FlxSprite(0, 0);
		spr.loadGraphic(bmd, false, 0, 0, true);
		spr.origin.set(0, 0);

		spr.scrollFactor.set(0, 0);
		spr.cameras = [uiCam];
		return spr;
	}

	function _updateVignette(elapsed:Float):Void
	{
		_vigTimer += elapsed;
		var wave = 0.5 + 0.5 * Math.sin(_vigTimer * 0.5 * Math.PI * 2);
		_vignette.alpha = 1.0 - 0.12 * wave;
	}

	override public function destroy():Void
	{
		_removePauseWatcher();
		FlxSprite.defaultAntialiasing = _prevAntialiasing;
		FlxG.stage.window.title = _prevWindowTitle;
		if (!_isRestarting)
			PlayState.isLetterboxedAspectRatio = false;
		super.destroy();
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

	public function spawnTileChecker(wx:Float, wy:Float):FlxSprite
	{
		var tc = new FlxSprite(wx, wy);
		tc.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/tilecheckers/tilecheckers"));
		tc.scrollFactor.set(1, 1);
		tileCheckers.push(tc);

		var map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr != null)
		{
			add(tc);
			var idx = members.indexOf(map7Spr);
			members.remove(tc);
			members.insert(idx + 1, tc);
		}
		else
		{
			objectGroup.add(tc);
		}
		return tc;
	}

	public function spawnLaunchpad(wx:Float, wy:Float):Launchpad
	{
		var lp = new Launchpad(wx, wy);
		launchpads.push(lp);

		objectGroup.add(lp);
		return lp;
	}

	public function spawnSkull(wx:Float, wy:Float):SkullPrompt
	{
		var sk = new SkullPrompt(wx, wy, player, cutscene, objectGroup, bgCam);
		sk.skullId = skullPrompts.length;
		skullPrompts.push(sk);
		return sk;
	}

	public function spawnTotem(wx:Float, wy:Float, type:TotemType):Totem
	{
		var tm = new Totem(wx, wy, type, player, cutscene, objectGroup, this, bgCam);
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
		var tcs = [for (tc in tileCheckers) { x: tc.x, y: tc.y }];
		var json = haxe.Json.stringify({ launchpads: lps, skulls: sks, totems: tms, trees: trs, tileCheckers: tcs }, null, "  ");
		sys.io.File.saveContent("assets/shared/data/minigame/thevalley/objects.json", json);
		#end
	}

	function _loadObjects():Void
	{
		var path = "assets/shared/data/minigame/thevalley/objects.json";
		if (!openfl.Assets.exists(path)) return;
		var raw = openfl.Assets.getText(path);
		if (raw == null || raw == "") return;
		var data:{ launchpads:Array<{x:Float,y:Float}>, skulls:Array<{x:Float,y:Float}>,
		           totems:Array<{x:Float,y:Float,type:String}>, trees:Array<{x:Float,y:Float}>,
		           tileCheckers:Array<{x:Float,y:Float}> } = haxe.Json.parse(raw);
		if (data.launchpads   != null) for (d in data.launchpads)   spawnLaunchpad(d.x, d.y);
		if (data.skulls       != null) for (d in data.skulls)       spawnSkull(d.x, d.y);
		if (data.trees        != null) for (d in data.trees)        spawnTree(d.x, d.y);
		if (data.tileCheckers != null) for (d in data.tileCheckers) spawnTileChecker(d.x, d.y);
		if (data.totems       != null)
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
			player.body.position.setxy(146.0 + player.width * 0.5, 134.0 + player.height * 0.5);
			player.body.velocity.setxy(0, 0);
		}
	}

	function _startSpineDeathSequence():Void
	{
		_spineDeathPhase = 1;
		_spineDeathTimer = 0;
		_musicFadeFrom   = (FlxG.sound.music != null) ? FlxG.sound.music.volume : 1.0;
	}

	function _updateSpineDeath(elapsed:Float):Void
	{
		if (_spineDeathPhase == 0) return;
		_spineDeathTimer += elapsed;

		switch (_spineDeathPhase)
		{
			case 1:

				if (FlxG.sound.music != null)
					FlxG.sound.music.volume = _musicFadeFrom * (1.0 - Math.min(_spineDeathTimer / 0.9, 1.0));
				if (_spineDeathTimer >= 0.9)
				{
					if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
					_spineDeathPhase = 2;
					_spineDeathTimer = 0;
				}
			case 2:
				_deathFade.alpha = Math.min(_spineDeathTimer / 0.4, 1.0);
				if (_spineDeathTimer >= 0.4)
				{
					_deathFade.alpha = 1.0;

					_onPlayerKilled();
					tileMap.clearDying(player);
					_spineDeathPhase = 3;
					_spineDeathTimer = 0;
				}
			case 3:
				_deathFade.alpha = 1.0 - Math.min(_spineDeathTimer / 0.4, 1.0);
				if (FlxG.sound.music != null)
					FlxG.sound.music.volume = Math.min(_spineDeathTimer / 0.4, 1.0);
				if (_spineDeathTimer >= 0.4)
				{
					_deathFade.alpha  = 0;
					if (FlxG.sound.music != null) FlxG.sound.music.volume = 1.0;
					_spineDeathPhase = 0;
				}
		}
	}
}