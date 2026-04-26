package states.stages;

import states.stages.objects.*;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.WindowAttributes;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Fatality extends BaseStage
{
	// -------------------------------------------------------------------------
	// CONSTANTS
	// -------------------------------------------------------------------------

	static inline var WINDOW_WIDTH         = 960;
	static inline var WINDOW_HEIGHT        = 720;
	static inline var WIDESCREEN_OFFSET    = 160; // (26 * 6) + 4

	static inline var STRUM_OPP_Y_OFFSET   = 50;
	static inline var STRUM_PLAY_Y_OFFSET  = 50;

	static inline var HBAR_MAX_SQUARES     = 25;
	static inline var HBAR_SQUARE_W        = 16;
	static inline var HBAR_SQUARE_H        = 15;
	static inline var HBAR_SPACING         = 2;
	static inline var HBAR_SCALE           = 1.32;
	static inline var HBAR_WIN_W           = 472;
	static inline var HBAR_WIN_H           = 70;
	static inline var HBAR_WIN_X_OFFSET    = 155;
	static inline var HBAR_WIN_Y_FROM_TOP  = 150;
	static inline var HBAR_WIN_Y_SLIDE_START = -500;
	static inline var HBAR_LIFE_X          = 13;
	static inline var HBAR_LIFE_Y          = 64;

	static inline var STEP_SLIDE_HEALTHBAR = 255;
	static inline var STEP_START_SHAKE     = 2230;
	static inline var STEP_START_INFINITY  = 2240;
	static inline var STEP_RETURN_NORMAL   = 2432;
	static inline var STEP_SHAKE_AGAIN     = 2528;
	static inline var STEP_FINAL_SCREEN    = 2560;

	static var STRUM_OPP_X  = [25, 137, 249, 361];
	static var STRUM_PLAY_X = [510, 622, 734, 846];

	// -------------------------------------------------------------------------
	// STAGE SPRITES
	// -------------------------------------------------------------------------

	var launchbase:FlxSprite;
	var truefatalstage:FlxSprite;

	var redbg:FlxSprite;
	var smallassbox:FlxBackdrop;
	var glitchythingy:FlxSprite;
	var smallbox:FlxBackdrop;
	var bigbox:FlxSprite;
	var barbg:FlxBackdrop;
	var floorbg:FlxSprite;
	var bansheeBG:FlxSprite;
	var dismantlerBG:FlxSprite;
	var machineBG:FlxSprite;
	var trapperBG:FlxSprite;

	var newBGSprites:Array<FlxSprite> = [];
	var newBGBoppers:Array<FlxSprite> = [];

	// -------------------------------------------------------------------------
	// HUD
	// -------------------------------------------------------------------------

	var missesTxt:FlxText;
	var scoreTxt2:FlxText;
	var hudSprite:FlxSprite;

	// -------------------------------------------------------------------------
	// WINDOW STATE
	// -------------------------------------------------------------------------

	var healthWindow:Window = null;
	var healthContainer:Sprite = null;
	var healthBarBitmap:Bitmap = null;
	var healthLifeBitmap:Bitmap = null;

	var savedFullscreen:Bool = false;

	// window animation state
	var healthWindowTargetY:Float = 0;
	var healthWindowBaseX:Float = 0;
	var healthWindowBaseY:Float = 0;
	var mainWindowBaseX:Float = 0;
	var mainWindowBaseY:Float = 0;
	var mainWindowCenterX:Float = 0;
	var mainWindowCenterY:Float = 0;
	var healthWindowCenterX:Float = 0;
	var healthWindowCenterY:Float = 0;

	var floatTime:Float = 0;
	var infinityTime:Float = 0;
	var returnTime:Float = 0;
	var slideTime:Float = 0;
	var slideStartY:Float = 0;

	var windowShaking:Bool = false;
	var windowInfinity:Bool = false;
	var windowReturning:Bool = false;
	var returnStartX:Float = 0;
	var returnStartY:Float = 0;
	var healthReturnStartX:Float = 0;
	var healthReturnStartY:Float = 0;

	var healthWindowShaking:Bool = false;
	var healthWindowInfinity:Bool = false;
	var healthWindowReturning:Bool = false;
	var healthWindowSliding:Bool = false;
	var healthWindowFloating:Bool = false;

	var windowCreated:Bool = false;

	// -------------------------------------------------------------------------
	// HELPERS
	// -------------------------------------------------------------------------

	function makeAnimSprite(path:String, x:Float, y:Float, animPrefix:String, fps:Int, scale:Float):FlxSprite
	{
		var spr = new FlxSprite(x, y);
		spr.frames = Paths.getSparrowAtlas(path);
		spr.animation.addByPrefix('idle', animPrefix, fps, true);
		spr.animation.play('idle');
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		spr.antialiasing = false;
		spr.visible = false;
		return spr;
	}

	function makeStaticSprite(path:String, x:Float, y:Float, scale:Float):FlxSprite
	{
		var spr = new FlxSprite(x, y);
		spr.loadGraphic(Paths.image(path));
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		spr.antialiasing = false;
		spr.visible = false;
		return spr;
	}

	// -------------------------------------------------------------------------
	// CREATE
	// -------------------------------------------------------------------------

	override function create()
	{
		savedFullscreen = FlxG.fullscreen;

		setupWindow();
		createHud();

		var domain = 'fatality/new/domain/';

		// Phase 1
		launchbase = new FlxSprite(-1050, -1110);
		launchbase.frames = Paths.getSparrowAtlas('fatality/launchbase');
		launchbase.animation.addByPrefix('idle', 'idle', 15, true);
		launchbase.animation.play('idle');
		launchbase.scale.set(6, 6);
		launchbase.updateHitbox();
		launchbase.antialiasing = false;
		add(launchbase);

		truefatalstage = new FlxSprite(-1050, -850);
		truefatalstage.frames = Paths.getSparrowAtlas('fatality/truefatalstage');
		truefatalstage.animation.addByPrefix('idle', 'idle', 15, true);
		truefatalstage.animation.play('idle');
		truefatalstage.scale.set(5, 5);
		truefatalstage.updateHitbox();
		truefatalstage.antialiasing = false;
		truefatalstage.visible = false;
		add(truefatalstage);

		// Phase 2
		redbg = makeStaticSprite(domain + 'redbg', -1350, -900, 5);
		add(redbg);
		newBGSprites.push(redbg);

		smallassbox = new FlxBackdrop(Paths.image(domain + 'smallassbox'), 0x01);
		smallassbox.setPosition(-1350, -900);
		smallassbox.velocity.x = -700;
		smallassbox.scale.set(5, 5);
		smallassbox.updateHitbox();
		smallassbox.antialiasing = false;
		smallassbox.visible = false;
		add(smallassbox);
		newBGSprites.push(smallassbox);

		glitchythingy = makeAnimSprite(domain + 'glitchythingy', -1350, -900, 'glitchythingy idle', 12, 5);
		add(glitchythingy);
		newBGSprites.push(glitchythingy);
		newBGBoppers.push(glitchythingy);

		smallbox = new FlxBackdrop(Paths.image(domain + 'smallbox'), 0x01);
		smallbox.setPosition(-1350, -900);
		smallbox.velocity.x = -500;
		smallbox.scale.set(5, 5);
		smallbox.updateHitbox();
		smallbox.antialiasing = false;
		smallbox.visible = false;
		add(smallbox);
		newBGSprites.push(smallbox);

		bigbox = makeAnimSprite(domain + 'bigbox', -1350, -900, 'bigbox idle', 12, 5);
		add(bigbox);
		newBGSprites.push(bigbox);
		newBGBoppers.push(bigbox);

		barbg = new FlxBackdrop(Paths.image(domain + 'barbg'), 0x01);
		barbg.setPosition(-1350, -900);
		barbg.velocity.x = -100;
		barbg.scale.set(5, 5);
		barbg.updateHitbox();
		barbg.antialiasing = false;
		barbg.visible = false;
		add(barbg);
		newBGSprites.push(barbg);

		floorbg = makeStaticSprite(domain + 'floorbg', -1350, -900, 5);
		add(floorbg);
		newBGSprites.push(floorbg);

		dismantlerBG = makeAnimSprite(domain + 'Dismantler and Meatsheild BG sheet', 750, -200, 'Dismantler and Meatsheild BG', 24, 4);
		dismantlerBG.flipX = true;
		add(dismantlerBG);
		newBGSprites.push(dismantlerBG);
		newBGBoppers.push(dismantlerBG);

		machineBG = makeAnimSprite(domain + 'Machine BG sheet', -1200, -500, 'Machine BG', 24, 4);
		add(machineBG);
		newBGSprites.push(machineBG);
		newBGBoppers.push(machineBG);

		trapperBG = makeAnimSprite(domain + 'Trapper BG sheet', 0, -270, 'Trapper BG', 24, 4);
		add(trapperBG);
		newBGSprites.push(trapperBG);
		newBGBoppers.push(trapperBG);
	}

	override function createPost()
	{
		bansheeBG = makeAnimSprite('fatality/new/domain/Banshee BG sheet', 1300, 100, 'Banshee BG', 24, 4);
		bansheeBG.flipX = true;
		add(bansheeBG);
		newBGSprites.push(bansheeBG);
		newBGBoppers.push(bansheeBG);

		hideDefaultHud();
		setupStrums();
		setupNoteSkins();

		var g:Dynamic = game;
		g.health = 2;
	}

	// -------------------------------------------------------------------------
	// WINDOW SETUP
	// -------------------------------------------------------------------------

	function setupWindow()
	{
		var mainWin = Application.current.window;
		if (mainWin.width == WINDOW_WIDTH) return;

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode(true);
		FlxG.camera.width = WINDOW_WIDTH;
		states.substates.PauseSubState.cameraWidth = WINDOW_WIDTH;

		mainWin.width     = WINDOW_WIDTH;
		mainWin.height    = WINDOW_HEIGHT;
		mainWin.x        += WIDESCREEN_OFFSET;
		mainWin.resizable = false;

		var offset = (1280 - WINDOW_WIDTH) / 2;
		for (cam in FlxG.cameras.list)
			cam.x = offset;
	}

	function restoreWindow()
	{
		if (Application.current.window.width == 1280) return;

		var mainWin = Application.current.window;
		mainWin.x        -= WIDESCREEN_OFFSET;
		mainWin.width     = 1280;
		mainWin.height    = 720;
		mainWin.resizable = true;

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		FlxG.camera.width = 1280;
		states.substates.PauseSubState.cameraWidth = 1280;

		for (cam in FlxG.cameras.list)
			cam.x = 0;
	}

	function closeHealthWindow()
	{
		if (healthWindow != null)
		{
			try { healthWindow.close(); } catch(e:Dynamic) {}
			healthWindow = null;
		}
		healthContainer   = null;
		healthBarBitmap   = null;
		healthLifeBitmap  = null;
		windowCreated     = false;
		healthWindowSliding  = false;
		healthWindowFloating = false;
	}

	function createHealthWindow()
	{
		if (windowCreated) return;
		windowCreated = true;

		var winW = Math.ceil(HBAR_WIN_W * HBAR_SCALE);
		var winH = Math.ceil(HBAR_WIN_H * HBAR_SCALE);

		try
		{
			var attrs:WindowAttributes = {};
			attrs.width       = winW;
			attrs.height      = winH;
			attrs.title       = "";
			attrs.borderless  = true;
			attrs.alwaysOnTop = false;
			attrs.resizable   = false;
			attrs.hidden      = false;

			var mainWin = Application.current.window;
			healthWindow = Application.current.createWindow(attrs);
			healthWindow.x = mainWin.x + HBAR_WIN_X_OFFSET;
			healthWindow.y = mainWin.y + HBAR_WIN_Y_SLIDE_START;

			healthWindowTargetY = mainWin.y - HBAR_WIN_Y_FROM_TOP;

			var container = new Sprite();
			healthWindow.stage.addChild(container);
			healthContainer = container;

			// bar background
			var barBD = BitmapData.fromFile('mods/FATAL/images/fatality/bar/bar.png');
			if (barBD != null)
			{
				var barBmp = new Bitmap(barBD);
				barBmp.scaleX = HBAR_SCALE;
				barBmp.scaleY = HBAR_SCALE;
				container.addChild(barBmp);
				healthBarBitmap = barBmp;
			}

			// life bar
			var lifeBD = BitmapData.fromFile('mods/FATAL/images/fatality/bar/life.png');
			if (lifeBD != null)
			{
				var lifeBmp = new Bitmap(lifeBD);
				lifeBmp.x      = HBAR_LIFE_X;
				lifeBmp.y      = HBAR_LIFE_Y;
				lifeBmp.scaleX = HBAR_SCALE;
				lifeBmp.scaleY = HBAR_SCALE;
				container.addChild(lifeBmp);
				healthLifeBitmap = lifeBmp;
			}

			mainWin.focus();
		}
		catch (e:Dynamic) {}
	}

	// -------------------------------------------------------------------------
	// HUD
	// -------------------------------------------------------------------------

	function createHud()
	{
		var hudY = ClientPrefs.data.downScroll ? 0.0 : 615.0;
		hudSprite = new FlxSprite(0, hudY);
		hudSprite.loadGraphic(Paths.image('fatality/bar/hud'));
		hudSprite.antialiasing = false;
		hudSprite.cameras = [camOther];
		hudSprite.scale.set(1.3, 1.3);
		hudSprite.updateHitbox();
		add(hudSprite);

		var missY = ClientPrefs.data.downScroll ? 39.0 : 654.0;
		missesTxt = new FlxText(15, missY, 400, 'Misses: 0');
		missesTxt.setFormat(Paths.font('ari-w9500-bold.ttf'), 17, 0xFF000000, LEFT);
		missesTxt.antialiasing = false;
		missesTxt.borderSize = 0;
		missesTxt.cameras = [camOther];
		add(missesTxt);

		var scoreY = ClientPrefs.data.downScroll ? 77.0 : 692.0;
		scoreTxt2 = new FlxText(15, scoreY, 400, 'Score: 0');
		scoreTxt2.setFormat(Paths.font('ari-w9500-bold.ttf'), 17, 0xFF000000, LEFT);
		scoreTxt2.antialiasing = false;
		scoreTxt2.borderSize = 0;
		scoreTxt2.cameras = [camOther];
		add(scoreTxt2);
	}

	function hideDefaultHud()
	{
		var g:Dynamic = game;
		g.timeTxt.visible  = false;
		g.timeBar.visible  = false;
		g.scoreTxt.visible = false;
		g.scoreTxt.alpha   = 0;
		g.scoreTxt.text    = '';
		g.scoreTxt.x       = -9999;
		g.scoreTxt.y       = -9999;
		g.healthBar.visible = false;
		g.iconP1.visible    = false;
		g.iconP2.visible    = false;

		for (i in 0...4)
		{
			g.opponentStrums.members[i].visible = false;
			g.opponentStrums.members[i].alpha   = 0;
		}

		g.showCombo    = false;
		g.showComboNum = false;
		g.showRating   = false;
	}

	function setupStrums()
	{
		var g:Dynamic = game;
		for (i in 0...4)
		{
			var oppY  = ClientPrefs.data.downScroll
				? FlxG.height - g.opponentStrums.members[i].height - STRUM_OPP_Y_OFFSET
				: STRUM_OPP_Y_OFFSET;
			var playY = ClientPrefs.data.downScroll
				? FlxG.height - g.playerStrums.members[i].height - STRUM_PLAY_Y_OFFSET
				: STRUM_PLAY_Y_OFFSET;

			g.opponentStrums.members[i].x = STRUM_OPP_X[i];
			g.opponentStrums.members[i].y = oppY;
			g.playerStrums.members[i].x   = STRUM_PLAY_X[i];
			g.playerStrums.members[i].y   = playY;
		}
	}

	function setupNoteSkins()
	{
		var g:Dynamic = game;
		if (!g.isPixelStage) return;
		for (i in 0...g.strumLineNotes.length)
			g.strumLineNotes.members[i].texture = 'fatal';
	}

	// -------------------------------------------------------------------------
	// UPDATE
	// -------------------------------------------------------------------------

	override function update(elapsed:Float)
	{
		updateNoteSkins();
		hideOpponentNotes();
		updateHealthBar();
		updateScoreDisplay();
		updateWindowAnimations(elapsed);
		maintainStrums();
	}

	function updateNoteSkins()
	{
		var g:Dynamic = game;
		if (!g.isPixelStage) return;
		for (i in 0...g.notes.length)
			if (!g.notes.members[i].mustPress && g.notes.members[i].noteType == '')
				g.notes.members[i].texture = 'fatal';
	}

	function hideOpponentNotes()
	{
		var g:Dynamic = game;
		for (i in 0...g.notes.length)
			if (!g.notes.members[i].mustPress)
			{
				g.notes.members[i].visible = false;
				g.notes.members[i].alpha   = 0;
			}
	}

	function updateHealthBar()
	{
		if (healthLifeBitmap == null) return;

		var hp      = boyfriend.health;
		var pct     = (hp / 2.0) * 100;
		var squares = Std.int((pct / 100) * HBAR_MAX_SQUARES);
		squares = Std.int(Math.max(0, Math.min(squares, HBAR_MAX_SQUARES)));
		var pixels  = squares * (HBAR_SQUARE_W + HBAR_SPACING);

		healthLifeBitmap.scrollRect = new Rectangle(0, 0, pixels, HBAR_SQUARE_H);
	}

	function updateScoreDisplay()
	{
		var g:Dynamic = game;
		missesTxt.text = 'Misses: ' + g.songMisses;
		scoreTxt2.text = 'Score: '  + g.songScore;
	}

	function maintainStrums()
	{
		var g:Dynamic = game;
		for (i in 0...4)
		{
			g.opponentStrums.members[i].x = STRUM_OPP_X[i];
			g.playerStrums.members[i].x   = STRUM_PLAY_X[i];
		}
	}

	function updateWindowAnimations(elapsed:Float)
	{
		if (healthWindow == null) return;

		var mainWin = Application.current.window;

		if (windowShaking)
		{
			mainWin.x = Std.int(mainWindowBaseX + FlxG.random.int(-10, 10));
			mainWin.y = Std.int(mainWindowBaseY + FlxG.random.int(-10, 10));
		}

		if (healthWindowShaking)
		{
			healthWindow.x = Std.int(healthWindowBaseX + FlxG.random.int(-10, 10));
			healthWindow.y = Std.int(healthWindowBaseY + FlxG.random.int(-10, 10));
		}

		if (windowInfinity)
		{
			infinityTime += elapsed;
			var t = infinityTime * 0.5;
			mainWin.x = Std.int(mainWindowCenterX   + Math.sin(t) * 100);
			mainWin.y = Std.int(mainWindowCenterY   + Math.sin(t * 2) * 50);
		}

		if (healthWindowInfinity)
		{
			var t = infinityTime * 0.5;
			healthWindow.x = Std.int(healthWindowCenterX + Math.sin(t) * 100);
			healthWindow.y = Std.int(healthWindowCenterY + Math.sin(t * 2) * 50);
		}

		if (windowReturning)
		{
			returnTime += elapsed;
			var duration = 1.5;
			if (returnTime >= duration)
			{
				mainWin.x = Std.int(mainWindowBaseX);
				mainWin.y = Std.int(mainWindowBaseY);
				windowReturning = false;
			}
			else
			{
				var eased = 1 - Math.pow(1 - returnTime / duration, 3);
				mainWin.x = Std.int(returnStartX + (mainWindowBaseX - returnStartX) * eased);
				mainWin.y = Std.int(returnStartY + (mainWindowBaseY - returnStartY) * eased);
			}
		}

		if (healthWindowReturning)
		{
			var duration = 1.5;
			if (returnTime >= duration)
			{
				healthWindow.x = Std.int(healthWindowBaseX);
				healthWindow.y = Std.int(healthWindowBaseY);
				healthWindowReturning = false;
			}
			else
			{
				var eased = 1 - Math.pow(1 - returnTime / duration, 3);
				healthWindow.x = Std.int(healthReturnStartX + (healthWindowBaseX - healthReturnStartX) * eased);
				healthWindow.y = Std.int(healthWindowBaseY + (healthWindowBaseY - healthReturnStartY) * eased);
			}
		}

		if (healthWindowSliding)
		{
			slideTime += elapsed;
			var duration = 1.0;
			if (slideTime >= duration)
			{
				healthWindow.y   = Std.int(healthWindowTargetY);
				healthWindowSliding  = false;
				healthWindowFloating = true;
			}
			else
			{
				var eased   = 1 - Math.pow(2, -10 * (slideTime / duration));
				healthWindow.y = Std.int(slideStartY + (healthWindowTargetY - slideStartY) * eased);
			}
		}

		if (healthWindowFloating && !windowInfinity && !windowShaking && !windowReturning)
		{
			floatTime += elapsed;
			healthWindow.x = Std.int(healthWindowBaseX + Math.sin(floatTime * 0.8) * 8);
		}
	}

	// -------------------------------------------------------------------------
	// SONG EVENTS
	// -------------------------------------------------------------------------

	override function startSong()
	{
		setupStrums();
		closeHealthWindow();
		new FlxTimer().start(0.5, function(_) createHealthWindow());
	}

	override function countdownTick(count:Countdown, num:Int)
	{
		var sounds = ['intro3-fatal', 'intro2-fatal', 'intro1-fatal', 'introGo-fatal'];
		if (num < sounds.length)
			FlxG.sound.play(Paths.sound(sounds[num]));
	}

	override function beatHit()
	{
		if (curBeat % 4 == 0)
			for (spr in newBGBoppers)
				if (spr.visible) spr.animation.play('idle', true);
	}

	override function stepHit()
	{
		switch (curStep)
		{
			case STEP_SLIDE_HEALTHBAR:
				launchbase.visible = false;
				for (spr in newBGSprites) spr.visible = true;
				startHealthWindowSlide();

			case STEP_START_SHAKE:
				startWindowShake();

			case STEP_START_INFINITY:
				startInfinityMovement();

			case STEP_RETURN_NORMAL:
				startReturnToNormal();

			case STEP_SHAKE_AGAIN:
				resumeShaking();

			case STEP_FINAL_SCREEN:
				showFinalScreen();

			case 1983:
				for (spr in newBGSprites) spr.visible = false;
				truefatalstage.visible = true;
				var g:Dynamic = game;
				g.triggerEvent('Change Character', 'dad', 'true-fatal', 0);
				g.triggerEvent('Change Character', 'bf', 'bf-fatal-small', 0);
				dad.danceEveryNumBeats = 4;
		}
	}

	// -------------------------------------------------------------------------
	// WINDOW ANIMATION TRIGGERS
	// -------------------------------------------------------------------------

	function startHealthWindowSlide()
	{
		if (healthWindow == null) return;
		slideStartY          = healthWindow.y;
		slideTime            = 0;
		healthWindowSliding  = true;
		healthWindowBaseX    = Application.current.window.x + HBAR_WIN_X_OFFSET;
	}

	function startWindowShake()
	{
		var mainWin = Application.current.window;
		windowShaking    = true;
		mainWindowBaseX  = mainWin.x;
		mainWindowBaseY  = mainWin.y;

		if (healthWindow != null)
		{
			healthWindowShaking = true;
			healthWindowBaseX   = healthWindow.x;
			healthWindowBaseY   = healthWindow.y;
		}
	}

	function startInfinityMovement()
	{
		var mainWin = Application.current.window;
		windowShaking       = false;
		healthWindowShaking = false;
		windowInfinity      = true;
		infinityTime        = 0;
		mainWindowCenterX   = mainWin.x;
		mainWindowCenterY   = mainWin.y;

		if (healthWindow != null)
		{
			healthWindowInfinity  = true;
			healthWindowCenterX   = healthWindow.x;
			healthWindowCenterY   = healthWindow.y;
		}
	}

	function startReturnToNormal()
	{
		var mainWin = Application.current.window;
		windowInfinity        = false;
		healthWindowInfinity  = false;
		windowReturning       = true;
		healthWindowReturning = true;
		returnTime            = 0;
		returnStartX          = mainWin.x;
		returnStartY          = mainWin.y;

		if (healthWindow != null)
		{
			healthReturnStartX = healthWindow.x;
			healthReturnStartY = healthWindow.y;
		}
	}

	function resumeShaking()
	{
		var mainWin = Application.current.window;
		windowReturning       = false;
		healthWindowReturning = false;
		windowShaking         = true;
		healthWindowShaking   = true;
		mainWindowBaseX       = mainWin.x;
		mainWindowBaseY       = mainWin.y;

		if (healthWindow != null)
		{
			healthWindowBaseX = healthWindow.x;
			healthWindowBaseY = healthWindow.y;
		}
	}

	function showFinalScreen()
	{
		windowShaking       = false;
		healthWindowShaking = false;

		if (healthWindow != null) healthWindow.visible = false;

		FlxG.fullscreen = true;

		var fatalScreen = new FlxSprite(0, 0);
		fatalScreen.loadGraphic(Paths.image('fatality/fatal'));
		fatalScreen.cameras = [camOther];
		add(fatalScreen);
	}

	// -------------------------------------------------------------------------
	// CLEANUP
	// -------------------------------------------------------------------------

	override function destroy()
	{
		closeHealthWindow();
		restoreWindow();
		FlxG.fullscreen = savedFullscreen;
	}

	override function closeSubState()
	{
		if (paused && healthWindow != null)
			Application.current.window.focus();
	}
}
