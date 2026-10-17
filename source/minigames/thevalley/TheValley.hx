package minigames.thevalley;

import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.nape.FlxNapeSpace;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;

import minigames.Camera;
import minigames.thevalley.map.BGValley;
import minigames.thevalley.map.BGValley.MapPart;
import minigames.thevalley.map.TVNapeWorld;
import minigames.thevalley.map.WaypointGraph;
import minigames.thevalley.map.WaypointGraph.WNode;
import minigames.thevalley.cutscenes.TVCutscene;
import minigames.thevalley.cutscenes.GameOver;
import minigames.thevalley.cutscenes.IntroCutscene;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.character.player.Player.PlayerMode;
import minigames.thevalley.character.player.HUD;
import minigames.thevalley.tiles.TileMap;
import minigames.thevalley.tiles.ShardHunt;
import minigames.thevalley.tiles.Tiles.Launchpad;
import minigames.thevalley.tiles.Tiles.SkullPrompt;
import minigames.thevalley.tiles.Tiles.Totem;
import minigames.thevalley.tiles.Tiles.TotemType;
import minigames.thevalley.tiles.Tiles.SpineTile;
import minigames.thevalley.tiles.TotemDread;
import minigames.thevalley.tiles.BurnFlash;
import minigames.thevalley.character.monster.Monster;
import minigames.thevalley.character.monster.Monster.MonsterAnim;
import minigames.thevalley.character.monster.Monster.ExeWorld;

import backend.Song;
import backend.WeekData;
import backend.Highscore;
import backend.Difficulty;
import backend.ClientPrefs;
import backend.Mods;
import states.PlayState;
import states.LoadingState;

class TheValley extends MusicBeatState implements ExeWorld
{
	public static inline final MAP_PARTS:Int = 11;

	var _mapParts:Array<MapPart> = [];

	public var bgCam:FlxCamera;
	public var uiCam:FlxCamera;

	public var gameCamera:Camera;

	public final shardHunt:ShardHunt = new ShardHunt();

	public var dying(get, never):Bool;
	inline function get_dying() return _deathPhase != 0;

	public var bg:BGValley;
	var _vignette:FlxSprite;
	var _vigTimer:Float = 0;
	var napeWorld:TVNapeWorld;

	var hud:HUD;
	public var tileMap:TileMap;
	public var waypointGraph:WaypointGraph;

	var _gameplayStarted:Bool = false;

	var _ambientSound:FlxSound;
	var _windSound:FlxSound;
	var _chase:minigames.thevalley.character.monster.Monster.ChaseMusic;
	var _reveal:minigames.thevalley.character.monster.FakerReveal;

	var _ambientCloseness:Float = 0;

	var _breath:minigames.thevalley.character.monster.Monster.ExeBreath;
	var _monsterCloseness:Float = 0;

	var _deathFade:FlxSprite;
	public var gameOver:GameOver;
	var _lastDeathByExe:Bool = false;
	var _deathPhase:Int = 0;
	var _deathHop:Bool = false;
	var _burning:Bool = false;
	var _burnSound:FlxSound;
	var _dread:TotemDread;
	var _burnFlash:BurnFlash;
	var _burnDuck:Float = 1.0;
	var _deathTimer:Float = 0;
	var _deathHold:Float = 0;
	var _musicFadeFrom:Float = 1.0;

	var _finalTriggered:Bool = false;

	var _gateNotified:Bool = false;
	var _gateMsgBar:FlxSprite;
	var _gateMsgTxt:FlxText;
	var _gateMsgTimer:Float = 0;

	static final GATE_LINES:Array<String> = [
		"I can't leave yet... I haven't found all of him.",
		"Not yet. There's still more of him out there.",
		"I won't go without him. Not all of him.",
	];

	var _occlusionAmount:Float = 0;

	var _isRestarting:Bool = false;
	var _pauseWatcher:()->Void = null;

	public var cutscene:TVCutscene;
	public var player:Player;

	public final launchpads:Array<Launchpad> = [];
	public final skullPrompts:Array<SkullPrompt> = [];
	public final totems:Array<Totem> = [];

	public var objectGroup:FlxTypedGroup<FlxSprite>;
	public var treeGroup:FlxTypedGroup<FlxSprite>;
	public final trees:Array<FlxSprite> = [];
	public final tileCheckers:Array<FlxSprite> = [];
	public final monsters:Array<Monster> = [];

	static var _prevAntialiasing:Bool = false;
	var _prevWindowTitle:String;
	var _prevUpdateFps:Int = 60;
	var _prevDrawFps:Int = 60;

	override public function create():Void
	{
		_prevAntialiasing = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		super.create();

		_prevWindowTitle = FlxG.stage.window.title;
		_prevUpdateFps = FlxG.updateFramerate;
		_prevDrawFps = FlxG.drawFramerate;
		_setFps(60, 60);
		_setTitle(false);

		PlayState.isLetterboxedAspectRatio = true;

		final shakeCam = new minigames.ShakeCamera();
		shakeCam.shakeView = true;
		bgCam = shakeCam;
		bgCam.bgColor = 0xFF000000;
		bgCam.zoom = 2.8;
		FlxG.cameras.reset(bgCam);

		uiCam = new FlxCamera();
		uiCam.bgColor = 0x00000000;
		FlxG.cameras.add(uiCam, false);

		_mapParts = BGValley.loadParts(MAP_PARTS);
		bg = new BGValley(this, _mapParts);

		napeWorld = new TVNapeWorld();
		napeWorld.init();
		napeWorld.partOffsets = [for (p in _mapParts) { x: p.x, y: p.y }];
		napeWorld.loadParts("assets/shared/images/minigame/thevalley/map/", MAP_PARTS);

		final wallMat = new Material(0.0, 0.0, 0.0, 1.0, 0.0);

		final leftWall = new Body(BodyType.STATIC, Vec2.weak(bg.left - 500, -5000));
		leftWall.shapes.add(new Polygon(Polygon.rect(0, 0, 500, 20000)));
		leftWall.setShapeMaterials(wallMat);
		leftWall.space = FlxNapeSpace.space;

		final rightWall = new Body(BodyType.STATIC, Vec2.weak(bg.right, -5000));
		rightWall.shapes.add(new Polygon(Polygon.rect(0, 0, 500, 20000)));
		rightWall.setShapeMaterials(wallMat);
		rightWall.space = FlxNapeSpace.space;

		final floorWall = new Body(BodyType.STATIC, Vec2.weak(-5000, bg.bottom + 200));
		floorWall.shapes.add(new Polygon(Polygon.rect(0, 0, 30000, 500)));
		floorWall.setShapeMaterials(wallMat);
		floorWall.space = FlxNapeSpace.space;

		bg.addSprites();

		treeGroup = new FlxTypedGroup<FlxSprite>();
		add(treeGroup);

		final map1Spr = bg.mapSprites.length > 0 ? bg.mapSprites[0] : null;
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

		gameCamera = new Camera(bgCam, player, 2.8);
		gameCamera.setBounds(bg.left, bg.right);

		_vignette = _buildVignette();
		add(_vignette);
		_dread = new TotemDread(this, uiCam);
		_reveal = new minigames.thevalley.character.monster.FakerReveal(this, uiCam, gameCamera, player);
		_burnFlash = new BurnFlash(this, bgCam, uiCam);

		hud = new HUD(this, uiCam);
		hud.onDeath = _timeUp;
		hud.timerRunning = false;

		cutscene = new TVCutscene(this, player, bgCam, uiCam, hud);
		cutscene.addSprites(this, uiCam);

		cutscene.onGameplayStart = () -> {
			_gameplayStarted  = true;
			player.cinematic  = false;
			hud.timerRunning  = true;
			gameCamera.followTarget();
		};

		cutscene.onSkullWin = _onShardFound;
		cutscene.onSkullCS2Done = _onShardFound;
		cutscene.playIntro();

		_ambientSound = FlxG.sound.load(Paths.music("minigame/thevalley/ambient"), 0, true, null, false, true);
		_breath = new minigames.thevalley.character.monster.Monster.ExeBreath();
		_chase = new minigames.thevalley.character.monster.Monster.ChaseMusic();
		_windSound = FlxG.sound.load(Paths.music("minigame/thevalley/wind"), 0, true, null, false, true);
		_windSound.fadeIn(3.0, 0, 0.35);

		bg.addFrontLayers();

		tileMap = new TileMap();
		tileMap.onPlayerKilled = _startSpikesDeath;
		tileMap.loadFromJson(this);

		final map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr != null) tileMap.insertSpineSprites(this, map7Spr);

		waypointGraph = new WaypointGraph(this);
		waypointGraph.generate(bg.left, bg.right);

		_loadObjects();
		Monster.fakerSpent = false;
		for (m in monsters) m.lurkAhead();

		final holdingAnchors = tileCheckers.length > 0 ? tileCheckers : [for (sp in tileMap.spines) sp.sprite];
		tileMap.insertHoldingSprites(this, holdingAnchors);

		add(player.sparkle);
		add(player.sparkleGlow);

		_deathFade = new FlxSprite(0, 0);
		_deathFade.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		_deathFade.scrollFactor.set(0, 0);
		_deathFade.cameras = [uiCam];
		_deathFade.alpha = 0;
		add(_deathFade);

		gameOver = new GameOver(this, uiCam);
		gameOver.onContinue = () -> {
			IntroCutscene.quickStart = true;
			FlxG.resetState();
		};
		gameOver.onQuit = () -> FlxG.resetState();

		final gateBarH = 54;
		_gateMsgBar = new FlxSprite(0, FlxG.height - gateBarH);
		_gateMsgBar.makeGraphic(FlxG.width, gateBarH, 0xFF000000);
		_gateMsgBar.scrollFactor.set(0, 0);
		_gateMsgBar.cameras = [uiCam];
		_gateMsgBar.alpha = 0;
		add(_gateMsgBar);

		_gateMsgTxt = new FlxText(0, 0, FlxG.width, "", 18);
		_gateMsgTxt.color = FlxColor.WHITE;
		_gateMsgTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_gateMsgTxt.alignment = FlxTextAlign.CENTER;
		_gateMsgTxt.scrollFactor.set(0, 0);
		_gateMsgTxt.cameras = [uiCam];
		_gateMsgTxt.alpha = 0;
		_gateMsgTxt.y = _gateMsgBar.y + (gateBarH - _gateMsgTxt.height) * 0.5;
		add(_gateMsgTxt);

		if (PlayState.instance == null)
		{
			final dummyPlayState = new PlayState();
			dummyPlayState.vocals = new FlxSound();
			PlayState.instance = dummyPlayState;
		}

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		_clock += elapsed;


		if (gameOver.active)
		{
			gameOver.update(elapsed);
			return;
		}

		final nape = FlxG.plugins.get(FlxNapeSpace);
		if (nape != null) nape.active = true;

		FlxG.sound.music?.play();

		if (controls.PAUSE)
		{
			states.substates.PauseSubState.miniSonicImage = 'the-valley';
			persistentUpdate = false;
			persistentDraw   = true;
			if (nape != null) nape.active = false;
			FlxG.sound.music?.pause();
			_pauseSounds();

			options.OptionsState.standaloneReturnState = () -> new minigames.thevalley.TheValley();
			states.substates.PauseSubState.cameraWidth = FlxG.width;
			_setTitle(true);
			openSubState(new states.substates.PauseSubState());

			var canCheckRestart = true;
			_pauseWatcher = () -> {
				final pauseSub = Std.downcast(subState, states.substates.PauseSubState);
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
		_updateDarkness();
		_updateVignette(elapsed);
		_updatePlayerOcclusion(elapsed);

		hud.setVisible(!player.cinematic && !player.isHiding && !player.isHidden && !cutscene.skullCSPlaying);
		hud.forceShardsVisible = cutscene.skullCSPlaying;

		var nearestActiveMonster:Monster = null;
		var nearestActiveDist = Math.POSITIVE_INFINITY;
		for (m in monsters)
		{
			if (m.isDormant || m.disguised) continue;
			final dx = m.sprite.x - player.x;
			final dy = m.sprite.y - player.y;
			final d = Math.sqrt(dx * dx + dy * dy);
			if (d < nearestActiveDist) { nearestActiveDist = d; nearestActiveMonster = m; }
		}
		
		if (nearestActiveMonster != null)
			hud.setMonsterDirection(nearestActiveMonster.sprite.x - player.x, nearestActiveMonster.sprite.y - player.y, true);
		else
			hud.setMonsterDirection(0, 0, false);

		hud.update(elapsed);
		tileMap.update(elapsed, player);
		tileMap.drawDebug(this, player, launchpads, skullPrompts, totems);

		_updateDeath(elapsed);
		if (gameOver.active) return;

		cutscene.update(elapsed);
		for (sk in skullPrompts) sk.update(elapsed);
		player.updateAnim(elapsed);

		if (_gameplayStarted)
		{
			if (FlxG.keys.justPressed.F7) tileMap.debugHitboxes = !tileMap.debugHitboxes;

			if (_deathPhase == 0) player.handleInput(elapsed, 146.0, 134.0);

			for (g in tileMap.garys) g.npcUpdate(elapsed);
			_updateAmbience(elapsed);

			for (lp in launchpads)
			{
				lp.tryLaunch(player);
				lp.padUpdate(elapsed);
			}

			player.isMakingNoise = false;

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
					final d = sk.getDist();
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
					final d = tm.getDist();
					if (d < nearTotemDist) { nearTotemDist = d; nearestTotem = tm; }
				}
				nearestTotem?.updateActive(elapsed, nearTotemDist);
			}

			var dread = 0.0;
			for (tm in totems) dread = Math.max(dread, tm.dread);
			if (_burning) gameCamera.zoomIn(Totem.BURN_SHOT_ZOOM, 2.0);
			_dread.update(elapsed, _burning ? 1.0 : Math.max(dread, _reveal.dread), !_burning);

			_updateFinalTrigger(elapsed);
			_updateGateMessage(elapsed);
			if (_finalTriggered) gameCamera.zoomIn(0.6, 0.6);
			if (player.inDark && _deathPhase == 0) gameCamera.zoomIn(0.6, 1.0);
			final fall = player.isGrounded ? 0.0 : Math.max(0, Math.min(1, (player.body.velocity.y - 150.0) / (550.0 - 150.0)));
			gameCamera.followRateY = 1.4 + (9.0 - 1.4) * fall * fall * (3 - 2 * fall);
			_reveal.update(elapsed, monsters);

			for (m in monsters)
			{
				m.paused = cutscene.skullCSPlaying;
				m.update(elapsed);
			}
		}

		gameCamera.update(elapsed);
		_burnFlash.update(elapsed, player);
	}

	function _removePauseWatcher():Void
	{
		if (_pauseWatcher != null)
		{
			FlxG.signals.postUpdate.remove(_pauseWatcher);
			_pauseWatcher = null;
		}
	}

	function _updateDarkness():Void
	{
		final cover = bg.darkness(player);
		player.inDark = cover >= (player.inDark ? 0.35 : 0.6);
		player.darkZone = player.inDark ? bg.darkZone : -1;
		hud.radarHidden = player.inDark;
	}

	function _updatePlayerOcclusion(elapsed:Float):Void
	{
		final target = bg.getOcclusionAmount(player, trees);
		_occlusionAmount += (target - _occlusionAmount) * (1.0 - Math.pow(0.01, elapsed * 6.0));
		player.color = FlxColor.interpolate(FlxColor.WHITE, 0xFF63636E, _occlusionAmount);
	}

	function _updateAmbience(elapsed:Float):Void
	{
		var closeness = 0.0;
		var forceFull = false;
		for (g in tileMap.garys)
		{
			final d = g.getDist();
			final c = 1.0 - Math.min(Math.max((d - 60.0) / (220.0 - 60.0), 0.0), 1.0);
			if (c > closeness) closeness = c;
			if (g.isTalking) forceFull = true;
		}
		for (tm in totems)
		{
			final dt = tm.getDist();
			final ct = 1.0 - Math.min(Math.max((dt - 70.0) / (220.0 - 70.0), 0.0), 1.0);
			if (ct > closeness) closeness = ct;
			if (tm.isBusy()) forceFull = true;
		}
		if (forceFull || player.inDark) closeness = 1.0;

		_ambientCloseness += (closeness - _ambientCloseness) * (1.0 - Math.pow(0.01, elapsed * 2.0));

		var monsterCloseness = 0.0;
		var nearestMonster:Monster = null;
		var nearestMonsterDist = 500.0;
		for (m in monsters)
		{
			final breathesNow = m.anim == MonsterAnim.Idle || m.anim == MonsterAnim.Walk || m.anim == MonsterAnim.Searching;
			if (!breathesNow) continue;

			final dx = m.sprite.x - player.x;
			final dy = m.sprite.y - player.y;
			final d = Math.sqrt(dx * dx + dy * dy);
			if (d < nearestMonsterDist) { nearestMonsterDist = d; nearestMonster = m; }
		}
		
		if (nearestMonster != null)
			monsterCloseness = 1.0 - Math.min(Math.max((nearestMonsterDist - 100.0) / (500.0 - 100.0), 0.0), 1.0);

		_monsterCloseness += (monsterCloseness - _monsterCloseness) * (1.0 - Math.pow(0.01, elapsed * 2.0));

		final totalCloseness = Math.max(_ambientCloseness, _monsterCloseness);
		_burnDuck += ((_burning ? 0.0 : 1.0) - _burnDuck) * (1.0 - Math.pow(0.01, elapsed * 4.0));

		if (!_finalTriggered) _chase.update(elapsed, monsters);
		final calm = (1.0 - _chase.mix) * (1.0 - _reveal.quiet);

		if (_deathPhase == 0 && !_finalTriggered && FlxG.sound.music != null)
			FlxG.sound.music.volume = 0.7 * (1.0 - totalCloseness) * calm * cutscene.musicMix;

		if (!_finalTriggered && _ambientSound != null)
			_ambientSound.volume = _ambientCloseness * 0.55 * _burnDuck * (1.0 - 0.7 * _chase.mix) * (1.0 - _reveal.quiet);

		if (!_finalTriggered && _windSound != null && !_windSound.fadeTween?.active)
			_windSound.volume = 0.35 * (1.0 - 0.5 * _chase.mix) * (1.0 - 0.8 * _reveal.quiet);

		if (!_finalTriggered) _breath.update(elapsed, monsters, player, bgCam, _burnDuck * (1.0 - _chase.mix));
	}

	function _buildVignette():FlxSprite
	{
		final w  = FlxG.width;
		final h  = FlxG.height;
		final bmd = new openfl.display.BitmapData(w, h, true, 0x00000000);
		final cx = w * 0.5;
		final cy = h * 0.5;

		for (y in 0...h)
		{
			final dy = (y - cy) / cy;
			for (x in 0...w)
			{
				final dx = (x - cx) / cx;
				final dist = Math.sqrt(dx * dx + dy * dy);

				var a = (dist - 0.35) / (1.15 - 0.35);
				if (a < 0) a = 0;
				if (a > 1) a = 1;
				a *= a;

				final alpha = Std.int(a * 235);
				bmd.setPixel32(x, y, (alpha << 24) | 0x000000);
			}
		}

		final spr = new FlxSprite(0, 0);
		spr.loadGraphic(bmd, false, 0, 0, true);
		spr.origin.set(0, 0);
		spr.scrollFactor.set(0, 0);
		spr.cameras = [uiCam];
		return spr;
	}

	function _updateVignette(elapsed:Float):Void
	{
		_vigTimer += elapsed;
		final wave = 0.5 + 0.5 * Math.sin(_vigTimer * 0.5 * Math.PI * 2);
		_vignette.alpha = 1.0 - 0.12 * wave;
	}

	final _pausedSounds:Array<FlxSound> = [];

	function _pauseSounds():Void
	{
		for (snd in FlxG.sound.list)
			if (snd != null && snd.playing)
			{
				snd.pause();
				_pausedSounds.push(snd);
			}
	}

	function _setTitle(paused:Bool):Void
	{
		FlxG.stage.window.title = "Friday Night Funkin': Vs Sonic.EXE | Playing: In The Valley" + (paused ? " (Paused)" : "");
	}

	override public function closeSubState():Void
	{
		super.closeSubState();
		_setTitle(false);
		for (snd in _pausedSounds) snd.resume();
		_pausedSounds.resize(0);
	}

	override public function destroy():Void
	{
		_removePauseWatcher();
		FlxSprite.defaultAntialiasing = _prevAntialiasing;
		FlxG.stage.window.title = _prevWindowTitle;
		_setFps(_prevUpdateFps, _prevDrawFps);
		if (!_isRestarting) PlayState.isLetterboxedAspectRatio = false;
		super.destroy();
	}

	static function _setFps(update:Int, draw:Int):Void
	{
		if (FlxG.drawFramerate != 0 && draw > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = update;
			FlxG.drawFramerate = draw;
		}
		else
		{
			FlxG.drawFramerate = draw;
			FlxG.updateFramerate = update;
		}
	}

	public function reorderSpine(sp:minigames.thevalley.tiles.SpineTile):Void
	{
		final map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr == null) return;
		final idx = members.indexOf(map7Spr);
		if (idx < 0) return;
		members.remove(sp.sprite);
		members.insert(idx + 1, sp.sprite);
	}

	public function spawnTree(wx:Float, wy:Float):FlxSprite
	{
		final t = new FlxSprite(wx, wy);
		t.loadGraphic(Paths.image("minigame/thevalley/map/1/tree", false));
		t.scrollFactor.set(1, 1);
		trees.push(t);
		treeGroup.add(t);
		return t;
	}

	public function spawnMonster(wx:Float, wy:Float):Monster
	{
		final m = new Monster(wx, wy, this, player);
		m.onLostYou = _onExeLostYou;
		monsters.push(m);
		return m;
	}

	public function spawnTileChecker(wx:Float, wy:Float):FlxSprite
	{
		final tc = new FlxSprite(wx, wy);
		tc.loadGraphic(Paths.image("minigame/thevalley/bg/tiles/tilecheckers/tilecheckers"));
		tc.scrollFactor.set(1, 1);
		tileCheckers.push(tc);

		final map7Spr = bg.mapSpriteByPart.get(7);
		if (map7Spr != null)
		{
			add(tc);
			final idx = members.indexOf(map7Spr);
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
		final lp = new Launchpad(wx, wy);
		launchpads.push(lp);
		objectGroup.add(lp);
		return lp;
	}

	public function spawnSkull(wx:Float, wy:Float):SkullPrompt
	{
		final sk = new SkullPrompt(wx, wy, player, cutscene.eButton, objectGroup, gameCamera, shardHunt, (first, released) -> {
			if (first) cutscene.triggerSkullCS2(!released);
			else if (cutscene.onSkullWin != null) cutscene.onSkullWin();
		});
		sk.skullId = skullPrompts.length;
		skullPrompts.push(sk);
		return sk;
	}

	public function spawnTotem(wx:Float, wy:Float, type:TotemType):Totem
	{
		final tm = new Totem(wx, wy, type, player, cutscene.eButton, objectGroup, this, gameCamera);
		tm.onBurn = _totemBurned;
		totems.push(tm);
		return tm;
	}

	public function saveObjects():Void
	{
		#if sys
		final lps = [for (lp in launchpads) { x: lp.x, y: lp.y }];
		final sks = [for (sk in skullPrompts) { x: sk.skullX, y: sk.skullY }];
		final tms = [for (tm in totems) {
			x: tm.totemX, y: tm.totemY,
			type: switch (tm.totemType) {
				case Short: "short";
				case Tall:  "tall";
				default:    "fake";
			}
		}];
		final trs = [for (t in trees) { x: t.x, y: t.y }];
		final tcs = [for (tc in tileCheckers) { x: tc.x, y: tc.y }];
		final mns = [for (m in monsters) { x: m.sprite.x, y: m.sprite.y }];
		final json = haxe.Json.stringify({ launchpads: lps, skulls: sks, totems: tms, trees: trs, tileCheckers: tcs, monsters: mns }, null, "  ");
		sys.io.File.saveContent("assets/shared/data/minigame/thevalley/objects.json", json);
		#end
	}

	function _loadObjects():Void
	{
		final path = "assets/shared/data/minigame/thevalley/objects.json";
		if (!openfl.Assets.exists(path)) return;

		final raw = #if sys sys.FileSystem.exists(path) ? sys.io.File.getContent(path) : #end openfl.Assets.getText(path);
		if (raw == null || raw == "") return;
		
		final data:{ launchpads:Array<{x:Float,y:Float}>, skulls:Array<{x:Float,y:Float}>,
		           totems:Array<{x:Float,y:Float,type:String}>, trees:Array<{x:Float,y:Float}>,
		           tileCheckers:Array<{x:Float,y:Float}>, ?monsters:Array<{x:Float,y:Float}> } = haxe.Json.parse(raw);
		           
		if (data.launchpads != null) for (d in data.launchpads) spawnLaunchpad(d.x, d.y);
		if (data.skulls != null) for (d in data.skulls) spawnSkull(d.x, d.y);
		if (data.trees != null) for (d in data.trees) spawnTree(d.x, d.y);
		if (data.tileCheckers != null) for (d in data.tileCheckers) spawnTileChecker(d.x, d.y);
		if (data.monsters != null) for (d in data.monsters) spawnMonster(d.x, d.y);
		if (data.totems != null)
			for (d in data.totems)
			{
				final t = switch (d.type) {
					case "short": TotemType.Short;
					case "tall":  TotemType.Tall;
					default:      TotemType.Fake;
				};
				spawnTotem(d.x, d.y, t);
			}
	}

	var _lastGetaway:Float = -999;
	var _clock:Float = 0;

	function _onShardFound():Void
	{
		hud.addShard();
		hud.addPoints(1000, "PIECE FOUND");
	}

	function _onExeLostYou(hidden:Bool, closest:Float):Void
	{
		if (_deathPhase != 0 || _clock - _lastGetaway < 10.0) return;
		_lastGetaway = _clock;
		final close = closest <= 110.0;
		final points = (hidden ? 500 : 300) + (close ? 200 : 0);
		hud.addPoints(points, (hidden ? "HIDDEN" : "ESCAPED") + (close ? " - CLOSE CALL" : ""));
	}

	public function onPlayerKilled():Bool
	{
		hud.addPoints(-500, "DEATH");
		hud.lives--;
		if (hud.lives <= 0)
		{
			_startGameOver();
			return true;
		}
		else
		{
			player.body.type = BodyType.DYNAMIC;
			player.body.position.setxy(146.0 + player.width * 0.5, 134.0 + player.height * 0.5);
			player.body.velocity.setxy(0, 0);
			player.jumpHeld = false;
			player.jumpBufTimer = 0;
			player.coyoteTimer = player.cfg.tuning.coyoteFrames / 60.0;
			player.isGrounded = true;
			player.mode = Ground;
			gameCamera.cut();
			if (_timeOver)
			{
				_timeOver = false;
				hud.timeElapsed = 0;
			}
		}
		return false;
	}

	function _startGameOver():Void
	{
		hud.timerRunning = false;
		_chase.stop();
		_breath.fadeOut(0.3);
		_ambientSound?.stop();
		_windSound?.stop();
		_stopBurnSound(0.2);
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
		for (snd in FlxG.sound.list) if (snd != null && snd.looped && snd.playing) snd.stop();
		bgCam.visible = false;
		gameOver.start(_lastDeathByExe);
	}

	function _startSpikesDeath():Void
	{
		if (!_startDeath(0.9)) return;
		gameCamera.shake(0.0025, 0.3);
		player.body.type = BodyType.KINEMATIC;
		player.body.velocity.setxy(0, 0);
		player.body.position.y += 18;
	}

	function _stopBurnSound(fade:Float):Void
	{
		final sound = _burnSound;
		_burnSound = null;
		sound?.fadeOut(fade, 0, _ -> sound.stop());
	}

	function _totemBurned(totem:Totem):Void
	{
		if (!_startDeath(Totem.burnDuration(player))) return;
		_burning = true;
		_burnFlash.arm(player, totem.sprite);
		_burnSound = FlxG.sound.play(Paths.sound("minigame/thevalley/gfire"), 1.0);
		player.body.type = BodyType.KINEMATIC;
		player.body.velocity.setxy(0, 0);
		player.setGravity(false);
	}

	public function exeLayer():FlxState return this;

	public function exeGraph():WaypointGraph return waypointGraph;

	public function exeCamera():FlxCamera return bgCam;

	public function exeTotems():Array<Totem> return totems;

	public function exeSpines():Array<SpineTile> return tileMap.spines;

	public function exeMapBottom():Float return bg.mapSprites.length > 0 ? bg.bottom : Math.POSITIVE_INFINITY;

	public function exeCanKill():Bool return !_finalTriggered && _deathPhase == 0 && !cutscene.skullCSPlaying;

	public function exeCaught():Void playerCaught();

	public function playerCaught():Void
	{
		_sonicDeath(true);
	}

	var _timeOver:Bool = false;

	function _timeUp():Void
	{
		if (_deathPhase != 0 || _finalTriggered || !_gameplayStarted) return;
		_timeOver = true;
		_sonicDeath(false);
	}

	function _sonicDeath(byExe:Bool):Void
	{
		if (!_startDeath(2.3, byExe)) return;
		gameCamera.lookAt(gameCamera.x, gameCamera.y, gameCamera.zoom, 0, null, true);
		gameCamera.shake(0.003, 0.3);
		player.cinematic = true;
		player.lockedAnim = "gameover";
		player.animation.play("gameover", true);
		player.body.type = BodyType.KINEMATIC;
		player.body.velocity.setxy(0, -260.0);
		player.setGravity(false);
		player.mode = PlayerMode.Air;
		_deathHop = true;
	}

	function _startDeath(hold:Float, byExe:Bool = false):Bool
	{
		if (_deathPhase != 0) return false;
		_lastDeathByExe = byExe;
		for (sk in skullPrompts) sk.interrupt();
		for (tm in totems) tm.interrupt();
		for (m in monsters) m.forgetHunt();
		_chase.release();
		_deathPhase = 1;
		_deathTimer = 0;
		_deathHold = hold;
		_musicFadeFrom = (FlxG.sound.music != null) ? FlxG.sound.music.volume : 1.0;
		return true;
	}

	function _updateDeath(elapsed:Float):Void
	{
		if (_deathPhase == 0) return;
		_deathTimer += elapsed;
		if (_deathHop) player.body.velocity.y += 450.0 * elapsed;

		switch (_deathPhase)
		{
			case 1:
				if (FlxG.sound.music != null)
					FlxG.sound.music.volume = _musicFadeFrom * (1.0 - Math.min(_deathTimer / _deathHold, 1.0));
				if (_deathTimer >= _deathHold)
				{
					if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
					_stopBurnSound(0.4);
					_deathPhase = 2;
					_deathTimer = 0;
				}
			case 2:
				_deathFade.alpha = Math.min(_deathTimer / 0.4, 1.0);
				if (_deathTimer >= 0.4)
				{
					_deathFade.alpha = 1.0;
					_deathHop = false;
					_burning = false;
					_burnFlash.cancel();
					gameCamera.followTarget();
					if (onPlayerKilled())
					{
						_deathPhase = 4;
						return;
					}
					tileMap.clearDying(player);
					_deathPhase = 3;
					_deathTimer = 0;
				}
			case 3:
				_deathFade.alpha = 1.0 - Math.min(_deathTimer / 0.4, 1.0);
				if (FlxG.sound.music != null)
					FlxG.sound.music.volume = 0.7 * Math.min(_deathTimer / 0.4, 1.0);
				if (_deathTimer >= 0.4)
				{
					_deathFade.alpha = 0;
					if (FlxG.sound.music != null) FlxG.sound.music.volume = 0.7;
					_deathPhase = 0;
				}
		}
	}

	function _updateFinalTrigger(elapsed:Float):Void
	{
		if (_finalTriggered || player.cinematic) return;

		final pastGate = player.x + player.width * 0.5 >= 10368.0;

		if (!shardHunt.complete)
		{
			if (pastGate) _blockFinalGate();
			else if (player.x + player.width * 0.5 < 10368.0 - 150.0) _gateNotified = false;
			return;
		}

		if (!pastGate) return;

		if (player.mode == Glide || player.mode == WingOpen || player.mode == WingClose)
		{
			player.mode = Air;
			return;
		}

		if (player.isGrounded)
		{
			_finalTriggered = true;
			_startFinalCutscene();
		}
	}

	function _blockFinalGate():Void
	{
		if (player.mode == Glide || player.mode == WingOpen || player.mode == WingClose)
			player.mode = Air;

		final maxX = 10368.0 - player.width * 0.5;
		if (player.body.position.x > maxX) player.body.position.x = maxX;
		if (player.body.velocity.x > 0) player.body.velocity.x = 0;

		if (!_gateNotified)
		{
			_gateNotified = true;
			_gateMsgTimer = 2.6;
			_gateMsgTxt.text = GATE_LINES[Std.random(GATE_LINES.length)];
			_gateMsgTxt.y = _gateMsgBar.y + (_gateMsgBar.height - _gateMsgTxt.height) * 0.5;
			hud.flashShards();
		}
	}

	function _updateGateMessage(elapsed:Float):Void
	{
		final target = _gateMsgTimer > 0 ? 1.0 : 0.0;
		if (_gateMsgTimer > 0) _gateMsgTimer -= elapsed;

		final spd = 1.0 - Math.pow(0.01, elapsed * 6.0);
		_gateMsgBar.alpha += (target - _gateMsgBar.alpha) * spd;
		_gateMsgTxt.alpha  = _gateMsgBar.alpha;
	}

	function _startFinalCutscene():Void
	{
		player.cinematic = true;
		player.body.velocity.setxy(0, 0);

		FlxG.sound.music?.fadeOut(1.0, 0.0);
		_ambientSound?.fadeIn(1.0, _ambientSound.volume, 0.5);
		_breath.fadeOut(1.0);
		_chase.stop();
		_windSound?.fadeOut(1.0, 0.0);

		FlxTween.tween(_deathFade, { alpha: 1.0 }, 1.0, { ease: FlxEase.quadInOut, onComplete: (_) -> _playFinalVideo() });
	}

	function _playFinalVideo():Void
	{
		#if VIDEOS_ALLOWED
		final vid = new VideoSprite(0, 0, true);
		vid.antialiasing = vid.video.antialiasing = ClientPrefs.data.antialiasing;
		vid.camera = uiCam;
		add(vid);

		vid.onFormat(() -> {
			#if switch
			final hasFrame = vid.video != null;
			#else
			final hasFrame = vid.video.bitmap?.bitmapData != null;
			#end
			if (hasFrame)
			{
				#if switch
				final bw:Float = vid.video.frameWidth;
				final bh:Float = vid.video.frameHeight;
				#else
				final bw:Float = vid.video.bitmap.bitmapData.width;
				final bh:Float = vid.video.bitmap.bitmapData.height;
				#end
				final cw:Float = uiCam.width;
				final ch:Float = uiCam.height;
				final scale:Float = Math.max(cw / bw, ch / bh);
				
				vid.video.setGraphicSize(Std.int(bw * scale), Std.int(bh * scale));
				vid.video.updateHitbox();
				vid.video.x = (cw - vid.video.width)  * 0.5;
				vid.video.y = (ch - vid.video.height) * 0.5;
			}
		});

		vid.onEnd(() -> _finishFinalCutscene());

		if (vid.loadVideo("assets/shared/images/minigame/thevalley/bg/cutscene/final.mp4"))
			vid.playDelayed();
		else
			_finishFinalCutscene(); 
		#else
		_finishFinalCutscene();
		#end
	}

	function _finishFinalCutscene():Void
	{
		Mods.currentModDirectory = "EXE";
		WeekData.reloadWeekFiles(false);
		PlayState.storyWeek = Std.int(Math.max(0, WeekData.weeksList.indexOf('exe')));
		Difficulty.loadFromWeek();

		final normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		final launchDiff = (normalIdx > -1) ? normalIdx : 0;

		try
		{
			Song.loadFromJson('godspeed', Highscore.formatSong('godspeed', launchDiff));
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = launchDiff;
		}
		catch (e:haxe.Exception)
		{
			trace('Error loading godspeed: ' + e.message);
			return;
		}

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());

		#if !SHOW_LOADING_SCREEN
		FlxG.sound.music?.stop();
		#end
	}
}