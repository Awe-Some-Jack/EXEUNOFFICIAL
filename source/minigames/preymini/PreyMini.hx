package minigames.preymini;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.FlxSubState;
import options.OptionsState;
import states.substates.PauseSubState;
import minigames.Camera;
import minigames.ShakeCamera;
import minigames.preymini.character.monster.EnemySpawner;
import minigames.preymini.character.player.EscapePrompt;
import minigames.preymini.character.player.HUD;
import minigames.preymini.character.player.Sonic;
import minigames.preymini.cutscenes.LevelArrival;
import minigames.preymini.cutscenes.LevelEnding;
import minigames.preymini.cutscenes.LevelIntro;
import minigames.preymini.map.BGPrey;
import minigames.preymini.map.MapLights;
import minigames.preymini.map.Terrain;
import minigames.preymini.tiles.Rings;
import minigames.preymini.tiles.Spikes;

class PreyMini extends MusicBeatState
{
	public static var fromSoundTest:Bool = false;

	public static var songLives:Int = 0;
	public static var songRings:Int = -1;

	static final CHAIN_SCORE:Array<Int> = [100, 200, 500, 1000];

	var _prevWindowTitle:String;
	var _paused:Bool = false;
	var _bg:BGPrey;
	var _terrain:Terrain;
	var _lights:MapLights;
	var _enemies:EnemySpawner;
	var _rings:Rings;
	var _spikes:Spikes;
	var _destroyed:FlxSprite;
	var _cut:LevelEnding = null;
	var _arrival:LevelArrival = null;
	var _withIntro:Bool;
	var _rallied:Bool = false;
	var _chain:Int = 0;
	var _lastView:Float = 0;
	var _sonic:Sonic;
	var _camera:Camera;
	var _hud:HUD;
	var _escape:EscapePrompt;
	var _lightningTimer:Float = FlxG.random.int(5, 10) * 4 * (60 / 176);
	var _overlay:FlxCamera;
	var _inFront:Bool = false;
	var _ending:Bool = false;
	var _lives:Int;
	var _score:Int;
	var _oneUps:Int = 0;
	var _prevUpdateFps:Int = 60;
	var _prevDrawFps:Int = 60;
	
	var _exitTimer:FlxTimer = null;

	public function new(lives:Int = 3, score:Int = 0, withIntro:Bool = true)
	{
		super();
		_lives = lives;
		_score = score;
		_withIntro = withIntro;
	}

	override public function create():Void
	{
		_prevWindowTitle = FlxG.stage.window.title;
		super.create();
		FlxG.sound.music?.stop();
		songLives = 0;
		songRings = -1;
		_prevUpdateFps = FlxG.updateFramerate;
		_prevDrawFps = FlxG.drawFramerate;
		_setFps(60, 60);
		_setTitle(false);

		FlxG.cameras.reset(new ShakeCamera());
		FlxG.camera.bgColor = 0xFF000000;
		FlxG.camera.pixelPerfectRender = true;

		final overlay = _overlay = new FlxCamera();
		overlay.bgColor = 0x00000000;
		overlay.pixelPerfectRender = true;
		FlxG.cameras.add(overlay, false);

		#if mobile
		add(new minigames.MiniTouchPad(overlay));
		#end

		_bg = new BGPrey(this, overlay);
		_bg.setLit(true);
		_terrain = Terrain.load("minigame/preymini/bg/map/hitbox", false);
		_terrain.y = 820 - Math.max(0, _terrain.topAt(220)) * 6;
		add(_terrain.loadArt("minigame/preymini/bg/map/back"));
		_destroyed = new FlxSprite();
		_destroyed.frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Destroyed_Badniks");
		_destroyed.animation.addByPrefix("idle", "idle", 1, false);
		_destroyed.animation.addByPrefix("strike", "strike", 1000 / 60, false);
		_destroyed.animation.play("idle");
		add(_terrain.attach(_destroyed, 0, 652));
		_lights = new MapLights();
		add(_lit(_terrain.loadArt("minigame/preymini/bg/map/map")));
		_spikes = new Spikes(_terrain, "minigame/preymini/bg/map/spikes");
		_spikes.onHurt = _hurt;
		add(_spikes.art);
		add(_terrain.addSprite("minigame/preymini/objects/easter", 52, 700 - 50));
		add(_terrain.addSprite("minigame/preymini/objects/carteles/cartel1", 4357, 348 - 61));
		add(_terrain.addSprite("minigame/preymini/objects/carteles/goal", 10138, 1022 - 28));
		add(_terrain.addSprite("minigame/preymini/objects/carteles/cartel2", 14401, 1213 - 59));
		add(_terrain.addSprite("minigame/preymini/objects/carteles/signpost", 16433, 1213 - 59));
		_sonic = new Sonic(_terrain, 220);
		_sonic.anchored = true;
		_sonic.anchorX = 177;
		add(_sonic);
		_rings = new Rings(_terrain, _sonic);
		_rings.onCollect = _collectRing;
		insert(members.indexOf(_sonic), _rings);
		if (_withIntro) _arrival = new LevelArrival(this, _sonic, _terrain, _rings);
		_enemies = new EnemySpawner(this, _overlay, _terrain, _sonic, _hurt, _grabbed, _broke, _ovenHit, _bossDown, 220, Math.max(0, _terrain.topAt(220)));
		add(_lit(_terrain.loadArt("minigame/preymini/bg/map/front")));
		_lastView = _sonic.posX;
		_moveWorld(0);

		_camera = new Camera(FlxG.camera, _sonic, 0.45);
		_camera.lookAhead = 0;
		_camera.jumpRoom = 120;
		_camera.followRateY = 2.0;
		_camera.lookDelay = 2.0;
		_camera.lookDistance = 200;
		_camera.maxLagDown = 200;
		_camera.bottom = _terrain.worldY(_terrain.height);
		_camera.followTarget();
		_camera.cut();
		_bg.addFront();

		_hud = new HUD(overlay);
		_hud.timing = false;
		_hud.lives = _lives;
		_hud.score = _score;
		add(_hud);
		_escape = new EscapePrompt(overlay);
		add(_escape);

		_sonic.controllable = false;
		final intro = new LevelIntro(overlay);
		intro.onFade = () ->
		{
			if (_arrival != null) _arrival.start();
			else _startLevel();
		};
		intro.onDone = () -> if (_arrival == null) _startPlaying();
		if (_arrival != null) _arrival.onDone = () ->
		{
			_arrival = null;
			_startLevel();
			_startPlaying();
		};
		add(intro);
	}

	function _startLevel():Void
	{
		_hud.showCard();
		if (!_sonic.dead) FlxG.sound.playMusic(Paths.music("minigame/preymini/stardustspeedway"), 1, true);
	}

	function _startPlaying():Void
	{
		if (_sonic.dead || _sonic.leaving) return;
		_sonic.controllable = true;
		_hud.timing = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!_sonic.dead && !_sonic.leaving && (_sonic.posY > _terrain.height || _hud.time >= 599.99)) _kill();

		if (_sonic.dead || _sonic.leaving) _fallingOut();
		else
		{
			if (!_rallied && _sonic.posX >= 15400)
			{
				_rallied = true;
				_enemies.quiet = true;
				_bg.rally(true, _farBoom);
			}
			if (_cut == null && _sonic.controllable && _sonic.posX >= 16480 && _sonic.grounded && !_sonic.grabbed && !_sonic.hurting) _startEnding();
			_cut?.update(elapsed);
			_arrival?.update(elapsed);
			if (_arrival != null && controls.JUMP_P) _arrival.skip();
			_moveWorld(elapsed);
			_spikes.update(_sonic);
			final onFloor = _sonic.grounded && _sonic.mode == 0;
			_camera.jumpRoom = onFloor || _sonic.jumping ? 120 : 400;
			_camera.followRateY = _sonic.jumping || _sonic.cameraGrounded() ? 2.0 : 10;
			_camera.update(elapsed);
		}
		if (_sonic.grounded) _chain = 0;
		_enemies.update(_lastView, _viewHalf());
		_enemies.place();
		_trackEscape(elapsed);
		_rings.place();
		_bg.update(elapsed);
		_lights.update(elapsed);
		_bg.followCamera(FlxG.camera);

		if (_cut == null) _lightningTimer -= elapsed;
		if (_lightningTimer <= 0)
		{
			_lightningTimer = FlxG.random.int(5, 10) * 4 * (60 / 176);
			_bg.strike();
			if (ClientPrefs.data.flashing) _destroyed.animation.play("strike", true);
		}

		if (controls.PAUSE && _cut == null && !_ending && !_sonic.dead && !_sonic.leaving) _pause();
	}

	function _lit<T:FlxSprite>(layer:FlxTypedGroup<T>):FlxTypedGroup<T>
	{
		for (sprite in layer.members) sprite.shader = _lights.shader;
		return layer;
	}

	function _startEnding():Void
	{
		_hud.timing = false;
		_enemies.quiet = true;
		_enemies.clear();
		FlxG.sound.music?.fadeOut(1.5, 0);
		_cut = new LevelEnding(this, _sonic, _terrain, _camera, _bg, _hud, _overlay);
		_cut.furnaceLimit = 16369;
		_cut.onDone = _playPreySong;
	}

	function _pause():Void
	{
		persistentUpdate = false;
		persistentDraw = true;
		PauseSubState.miniSonicImage = "sonic";
		PauseSubState.miniSonicOffsets = [0, 0];
		PauseSubState.cameraWidth = FlxG.width;
		PauseSubState.standaloneExit = _exitMinigame;
		final lives = _lives, score = _hud.score;
		OptionsState.standaloneReturnState = () -> new PreyMini(lives, score, false);
		openSubState(new PauseSubState());
	}

	override function openSubState(sub:FlxSubState):Void
	{
		if (Std.isOfType(sub, PauseSubState))
		{
			_paused = true;
			if (FlxG.sound.music != null) FlxG.sound.music.pause();
			FlxTimer.globalManager.forEach(t -> if (!t.finished) t.active = false);
			FlxTween.globalManager.forEach(t -> if (!t.finished) t.active = false);
			_setTitle(true);
		}
		super.openSubState(sub);
	}

	override function closeSubState():Void
	{
		super.closeSubState();
		if (!_paused) return;
		_paused = false;
		PauseSubState.standaloneExit = null;
		OptionsState.standaloneReturnState = null;
		FlxTimer.globalManager.forEach(t -> if (!t.finished) t.active = true);
		FlxTween.globalManager.forEach(t -> if (!t.finished) t.active = true);
		if (FlxG.sound.music != null) FlxG.sound.music.resume();
		persistentUpdate = true;
		_setTitle(false);
	}

	function _setTitle(paused:Bool):Void
	{
		FlxG.stage.window.title = "Friday Night Funkin': Vs Sonic.EXE | Playing: Stardust Speedway" + (paused ? " (Paused)" : "");
	}

	function _exitMinigame():Void
	{
		if (fromSoundTest) FlxG.switchState(() -> new states.SoundTest());
		else FlxG.switchState(() -> new states.EXEFreeplay());
	}

	function _playPreySong():Void
	{
		WeekData.reloadWeekFiles(false);
		final week = WeekData.weeksList.indexOf("starv");
		final data = WeekData.weeksLoaded.get("starv");
		if (week < 0 || data == null)
		{
			_exitMinigame();
			return;
		}
		WeekData.setDirectoryFromWeek(data);
		PlayState.storyWeek = week;
		songLives = Std.int(Math.max(1, _lives));
		songRings = _hud.rings;
		Difficulty.loadFromWeek();
		final normal = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == "normal");
		final diff = normal > -1 ? normal : 0;
		try
		{
			if (fromSoundTest)
			{
				PlayState.storyPlaylist = [for (song in data.songs) if (Paths.formatToSongPath(song[0]) != "stardust-speedway") Paths.formatToSongPath(song[0])];
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 1;
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
				Song.loadFromJson(PlayState.storyPlaylist[0], PlayState.storyPlaylist[0]);
				states.SoundTest.fromSoundTest = true;
			}
			else
			{
				Song.loadFromJson(Highscore.formatSong("prey", diff), "prey");
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = diff;
			}
		}
		catch (e:haxe.Exception)
		{
			trace("Could not load prey: " + e.message);
			_exitMinigame();
			return;
		}
		@:privateAccess
		if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory) Paths.freeGraphicsFromMemory();
		if (data.transitionShape != null && data.transitionShape.length > 0)
			CustomShapeTransition.shape = CustomShapeTransition.getShapeByString(data.transitionShape);
		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function _farBoom(pan:Float, size:Float):Void
	{
		final sound = FlxG.sound.play(Paths.sound("minigame/preymini/explosion"), 0.14 + 0.1 * size);
		sound.pan = pan * 0.7;
		#if FLX_PITCH
		sound.pitch = FlxG.random.float(0.55, 0.8);
		#end
		_cut?.boom(pan, size);
	}

	function _hurt(fromX:Float):Void
	{
		if (_cut != null || _sonic.dead || _sonic.leaving || _sonic.grabbed || _sonic.hurting || _sonic.invulnerable) return;
		if (_hud.rings > 0)
		{
			_loseRings();
			_sonic.knockBack(fromX);
		}
		else _kill();
	}

	function _trackEscape(elapsed:Float):Void
	{
		final hook = _enemies.grabber();
		final cam = FlxG.camera;
		final screenX = (_sonic.cameraX() - cam.viewLeft) * cam.zoom;
		final screenY = (_terrain.worldY(_sonic.posY + 19) - cam.viewTop) * cam.zoom;
		_escape.track(elapsed, screenX, screenY, hook != null ? hook.escape : 0, hook != null && _sonic.grabbed);
	}

	function _ovenHit(x:Float, damaged:Bool):Void
	{
		_sonic.rebound(x);
		if (damaged) FlxG.sound.play(Paths.sound("minigame/preymini/hit"));
	}

	function _bossDown(x:Float, y:Float):Void
	{
		_hud.score += 1000;
		FlxG.sound.play(Paths.sound("minigame/preymini/breakbadnik"));
		FlxG.sound.play(Paths.sound("minigame/preymini/explosion"));
		_rings.scatter(x, y, 10);
	}

	function _grabbed():Void
	{
		FlxG.sound.play(Paths.sound("minigame/preymini/hit"));
	}

	function _broke(x:Float, y:Float):Void
	{
		_hud.score += _chain >= 16 ? 1000 : CHAIN_SCORE[Std.int(Math.min(_chain, CHAIN_SCORE.length - 1))];
		_chain++;
		FlxG.sound.play(Paths.sound("minigame/preymini/breakbadnik"));
		_sonic.bounceOff(y);
	}

	function _loseRings():Void
	{
		if (_hud.rings <= 0) return;
		_rings.scatter(_sonic.posX, _sonic.posY, _hud.rings);
		_hud.rings = 0;
		FlxG.sound.play(Paths.sound("minigame/preymini/loseRings"));
	}

	function _collectRing():Void
	{
		_hud.rings = Std.int(Math.min(_hud.rings + 1, 999));
		for (step in 0...2)
			if (_oneUps & (1 << step) == 0 && _hud.rings >= (step + 1) * 100)
			{
				_oneUps |= 1 << step;
				_lives++;
				_hud.lives = _lives;
				FlxG.sound.play(Paths.sound("minigame/preymini/extralife"));
			}
	}

	function _kill():Void
	{
		_sonic.die();
		FlxG.sound.play(Paths.sound("minigame/preymini/death"));
		_lives--;
		_hud.lives = _lives;
		_hud.time = Math.min(_hud.time, 599.99);
		_hud.timing = false;
		FlxG.sound.music?.stop();
	}

	function _fallingOut():Void
	{
		_bg.setSpeed(0);
		if (!_inFront)
		{
			_inFront = true;
			remove(_sonic, true);
			add(_sonic);
		}
		if (_ending || _sonic.cameraY() < FlxG.camera.viewBottom + 192) return;

		_ending = true;
		_hud.timing = false;
		final quit = _sonic.leaving;
		if (!quit && _lives <= 0)
		{
			_hud.showGameOver();
			FlxG.sound.play(Paths.sound("minigame/preymini/gameover"), 1, false, null, true,
				() -> _overlay.fade(FlxColor.BLACK, 1, false, _exitMinigame));
			return;
		}
		final lives = _lives, score = _hud.score;
		
		_exitTimer?.cancel();
		_exitTimer = new FlxTimer().start(1, _ -> _overlay.fade(FlxColor.BLACK, 0.5, false, () ->
		{
			if (quit) _exitMinigame();
			else FlxG.switchState(() -> new PreyMini(lives, score, false));
		}));
	}

	function _moveWorld(elapsed:Float):Void
	{
		final half = _viewHalf();
		final view = Math.max(half, Math.min(_terrain.width - half, _sonic.posX));
		_terrain.x = _sonic.anchorX - view * 6;
		_bg.setSpeed(elapsed > 0 ? (view - _lastView) * 6 / elapsed / 2000 : 0);
		_lastView = view;
		_sonic.place();
	}

	inline function _viewHalf():Float return FlxG.width / 0.45 * 0.5 / 6;

	override public function destroy():Void
	{
		_exitTimer?.cancel();
		PauseSubState.standaloneExit = null;
		if (!OptionsState.onPlayState) OptionsState.standaloneReturnState = null;
		FlxG.stage.window.title = _prevWindowTitle;
		_setFps(_prevUpdateFps, _prevDrawFps);
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
}