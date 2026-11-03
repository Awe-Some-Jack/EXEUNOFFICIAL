package states;

import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;


import backend.Song;
import backend.Difficulty;
import backend.WeekData;
import backend.Highscore;

import states.StoryModeState;
import states.EXEMenu;
import states.LoadingState;
import states.parallax.ParallaxState;

@:allow(backend.BurningBot)
class EXETitle extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
	public static var initialized:Bool = false;
	
	var video:VideoSprite;
	var videoPlaying:Bool = false;
	var videoKey:String = null;
	var titleText:FlxSprite;
	var blackScreen:FlxSprite;
	var screenBg:VideoSprite;
	var spikes:FlxBackdrop;
	var ring:FlxSprite;
	var bandana:FlxSprite;
	var logotxt:FlxSprite;
	var eyes:FlxSprite;
	var whiteBG:FlxSprite;
	var parallaxArrow:FlxSprite;
	var playedIntro:Bool = false;

	var canStart:Bool = false;

	var unlocked:Array<String> = [];
	var parallaxUnlocked:Bool = false;

	public static var AFK_TIMER_VALUE:Float = 60;
	var afkTimer:Float = AFK_TIMER_VALUE;
	public static var afkVideos:Array<String> = ["introcutscene"];

	override function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		if(FlxG.sound.music == null) FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'), 0);

		if (FlxG.save.data.burningBot == true)
		{
			backend.BurningBot.active = true;
		}

		if (!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reload();
			if (FlxG.save.data?.fullscreen ?? false)
				FlxG.fullscreen = FlxG.save.data.fullscreen;
		}

		if (FlxG.save.data?.weekCompleted != null)
			StoryModeState.weekCompleted = FlxG.save.data.weekCompleted;

		final fatalScene = initialized ? null : states.access.FatalAccess.bootScene();
		if (fatalScene != null)
		{
			initialized = true;
			transitioning = true;
			super.create();
			FlxG.switchState(() -> new states.access.FatalAccess(fatalScene));
			return;
		}

		if (FlxG.save.data.sonichuUnlockPending == true)
		{
			transitioning = true;
			super.create();
			FlxG.switchState(() -> new SonichuUnlockState());
			return;
		}

		if (FlxG.save.data.parallaxUnlockNoticePending == true)
		{
			transitioning = true;
			super.create();
			FlxG.switchState(() -> new ParallaxUnlockState());
			return;
		}

		if (!initialized)
		{
			Main.fpsVar.visible = false;
			if(FlxG.save.data.firstBoot == null) 
				playWarningScreen();
			else
			{
				playVideo('introexe');
				videoPlaying = true;
			}
		}
		else
		{
			canStart = true;
			buildTitle();
			showTitle();
		}

		var save:FlxSave = new FlxSave();
		save.bind('savedSongs', CoolUtil.getSavePath());
		try { unlocked = cast (save.data.songs ?? []); } catch(e:Dynamic) { trace("Error loading unlocked songs: " + e); }
		parallaxUnlocked = backend.SongProgress.soundTestComplete();

		super.create();

		backend.MasterAccess.init();
	}

	var warningText:FlxText;
	var warningText2:FlxText;
	var pressContinue:Bool;
	function playWarningScreen()
	{
		final mainText = Language.get('warning_text_main', "WELCOME.\n\nBefore you continue any further, you have to be aware this mod contains flashing lights and seizures.\n\nIf you feel uncomfortable or triggered by these events, DO NOT PLAY THIS AND CLOSE THE GAME.\n\nAlso, if you have a weaker device, some issues with loading may occur. Please consider lowering shader quality or playing on a device with more RAM.\n\nViewer discretion is advised.");
		warningText = new FlxText(0, 0, 620, mainText, 40);
		warningText.scale.set(0, 0);
		warningText.setFormat(Language.fontOrCJK("SonicFont.ttf"), 30, FlxColor.WHITE, CENTER);
		warningText.screenCenter();
		add(warningText);

		warningText2 = new FlxText(0, 0, 620, Language.get('warning_text_enter', "Press Enter To Continue."), 40);
		warningText2.scale.set(0, 0);
		warningText2.setFormat(Language.fontOrCJK("SonicFont.ttf"), 30, FlxColor.WHITE, CENTER);
		warningText2.screenCenter(X);
		warningText2.y = warningText.y + 520;
		add(warningText2);

		FlxTween.tween(warningText.scale, {x: 1, y: 1}, 2, {ease: FlxEase.cubeOut});

		new FlxTimer().start(2.5, (_) -> FlxTween.tween(warningText2.scale, {x: 1, y: 1}, 1, {ease: FlxEase.cubeOut}));
		new FlxTimer().start(4, (_) -> pressContinue = true); 
	}

	function playVideo(vid:String, ?byAfk:Bool = false)
	{
		video?.destroy();

		videoKey = vid;
		video = new VideoSprite();
		video.loadVideo(Paths.video(vid));
		video.onEnd(()->{
			onVideoEnd(byAfk);
		});
		video.onFormat(() -> {
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.video.screenCenter();
		});
		video.playDelayed();
		add(video);
		
		videoPlaying = true;
	}

	var transitioning:Bool = false;
	function onVideoEnd(byAfk:Bool):Void
	{
		videoPlaying = false;
		
		if (!byAfk)
		{
			if (FlxG.save.data.goToFinalEscape != null){
				initialized = true;
				Main.fpsVar.visible = ClientPrefs.data.showFPS;

				Mods.currentModDirectory = "STORY MODE";
				WeekData.reloadWeekFiles(false);
				Difficulty.loadFromWeek();
				
				final song:String = 'final-escape';
				final normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
				final launchDiff = (normalIdx > -1) ? normalIdx : 0;
				
				PlayState.SONG = Song.loadFromJson(song, Highscore.formatSong(song, launchDiff));
				PlayState.isStoryMode = true;
				PlayState.storyWeek = 0;
				PlayState.storyDifficulty = launchDiff;
				
				states.StoryModeState.fromStoryMode = true;
				StoryModeState.fromTooSlow = true;

				LoadingState.loadAndSwitchState(new PlayState(), true);
				return;
			} 

			if(FlxG.save.data.firstBoot == null) 
			{
				FlxG.save.data.firstBoot = true;
				FlxG.save.flush();

				playedIntro = true;
				playVideo('introcutscene');
				return;
			}
			else if(FlxG.save.data.firstBoot && !playedIntro && !backend.BurningBot.active)
			{
				playedIntro = true;
				playVideo('postIntro');
				return;
			}

			initialized = true;

			buildTitle();
		}

		if (byAfk){
			transitioning = false;
			afkTimer = AFK_TIMER_VALUE;
		}
		FlxG.camera.visible = false;

		new FlxTimer().start(0.5, (_) -> {
			FlxG.sound.play(Paths.sound(backend.BurningBot.active ? 'eggmanlaugh' : 'exelaugh'));
			new FlxTimer().start(1.6, (_) -> {
				canStart = true;
				showTitle();
				FlxG.camera.visible = true;
				
				FlxG.camera.flash(FlxColor.RED, 1);
				whiteBG.alpha = 0.00001;
				whiteBG.color = 0xFFFFFFFF;
				
				FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
				FlxG.sound.play(Paths.sound('showMoment'));
				
				Main.fpsVar.visible = ClientPrefs.data.showFPS;
			});
		});
		
	}

	function buildTitle():Void
	{
		#if VIDEOS_ALLOWED
		screenBg = new VideoSprite();
		screenBg.onFormat(() -> {
			screenBg.setGraphicSize(FlxG.width, FlxG.height);
			screenBg.screenCenter();
		});
		if (screenBg.loadVideo('assets/exe/title/statictitlemenu.mp4', [VideoSprite.ARG_LOOPING])) screenBg.playDelayed();
		add(screenBg);
		#end

		makeLogo();

		spikes = new FlxBackdrop(Paths.getBitmapData('assets/exe/title/spikesdown.webp', true, true), X);
		spikes.scale.set(0.4, 0.4);
		spikes.updateHitbox();
		spikes.y = FlxG.height - spikes.height;
		spikes.velocity.x = -50;
		add(spikes);
		
		titleText = new FlxSprite();
		titleText.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/title/titleEnterNEW.webp', true, true), 'assets/exe/title/titleEnterNEW.xml');
		titleText.animation.addByPrefix('idle', 'Press Enter to Begin instance 1', 24, true);
		titleText.animation.addByPrefix('press', 'ENTER PRESSED instance 1', 24, false);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		titleText.y += 80;
		add(titleText);

		parallaxArrow = new FlxSprite(FlxG.width).loadGraphic(Paths.getBitmapData('assets/exe/parallax/parallaxarrow.webp', true, true));
		parallaxArrow.screenCenter(Y);
		add(parallaxArrow);
		
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0.0000001;
		add(blackScreen);

		eyes = new FlxSprite(ring.x + (1074 * 0.4)).loadGraphic(Paths.getBitmapData('assets/exe/title/logo/eyes.webp', true, true));
		eyes.scale.set(0.4, 0.4);
		eyes.updateHitbox();
		add(eyes);

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteBG.alpha = 0.00001;
		whiteBG.screenCenter();
		add(whiteBG);

		hideTitle();
	}

	function hideTitle():Void
	{
		#if VIDEOS_ALLOWED
		if (screenBg != null) 
		{
			screenBg.pause();
			screenBg.active = screenBg.visible = false;
		}
		#end
		if (ring != null) ring.active = ring.visible = false;
		if (bandana != null) bandana.active = bandana.visible = false;
		if (logotxt != null)  logotxt.active = logotxt.visible = false;
		if (spikes != null)  spikes.active = spikes.visible = false;
		if (titleText != null) titleText.active = titleText.visible = false;
		if (parallaxArrow != null) parallaxArrow.active = parallaxArrow.visible = false;
		if (blackScreen != null) blackScreen.active = blackScreen.visible = false;
		if (eyes != null) eyes.active = eyes.visible = false;
		if (whiteBG != null) whiteBG.active = whiteBG.visible = false;
	}

	function showTitle():Void
	{
		#if VIDEOS_ALLOWED
		if (screenBg != null) 
		{
			screenBg.active = screenBg.visible = true;
			screenBg.resume();
		}
		#end
		if (ring != null) ring.active = ring.visible = true;
		if (bandana != null) bandana.active = bandana.visible = true;
		if (logotxt != null) logotxt.active = logotxt.visible = true;
		if (spikes != null) spikes.active = spikes.visible = true;
		if (titleText != null) titleText.active = titleText.visible = true;
		if (parallaxArrow != null) parallaxArrow.active = parallaxArrow.visible = true;
		if (blackScreen != null) blackScreen.active = blackScreen.visible = true;
		if (eyes != null) eyes.active = eyes.visible = true;
		if (whiteBG != null) whiteBG.active = whiteBG.visible = true;
	}

	var savedRingX:Float = 0;
	function makeLogo():Void
	{
		final path:String = 'assets/exe/title/logo/';
		
		ring = new FlxSprite().loadGraphic(Paths.getBitmapData(path + 'ring.webp', true, true));
		ring.scale.set(0.4, 0.4);
		ring.updateHitbox();
		ring.screenCenter(X);
		add(ring);

		savedRingX = ring.x;
		bandana = new FlxSprite(ring.x + (329 * 0.4)).loadGraphic(Paths.getBitmapData(path + 'bandana.webp', true, true));
		bandana.scale.set(0.4, 0.4);
		bandana.updateHitbox();
		add(bandana);
		
		logotxt = new FlxSprite(ring.x + (711 * 0.4)).loadGraphic(Paths.getBitmapData(path + 'sonic.webp', true, true));
		logotxt.scale.set(0.4, 0.4);
		logotxt.updateHitbox();
		add(logotxt);
	}

	override function destroy():Void
	{
		#if VIDEOS_ALLOWED
		FlxG.autoPause = true;
		#end
		super.destroy();
	}

	var mousePosition:String = 'left';
	var logoSine:Float = 0;
	var fridgeStatus:Int = 0;
	
	static inline final BANDANA_OFF:Float = 329 * 0.4;
	static inline final logotxt_OFF:Float = 711 * 0.4;
	static inline final EYES_OFF:Float = 1074 * 0.4;
	static inline final BANDANA_Y:Float = 20 + (873 * 0.4);
	static inline final logotxt_Y:Float = 20 + (777 * 0.4);
	static inline final EYES_Y:Float = 20 + (517 * 0.4);
	static inline final PARALLAX_THRESHOLD:Float = 0.85;

	override function update(elapsed:Float):Void
	{
		final gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		#if !final
		if (videoPlaying)
		{
			if (videoKey != 'introexe' && (controls.ACCEPT #if mobile || shortPress #end || (gamepad != null && gamepad.justPressed.START #if switch || gamepad.justPressed.B #end))) video?.setVideoPercent(1);
			super.update(elapsed);
			return;
		}
		#end

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!transitioning && canStart && (FlxG.keys.justPressed.ANY || FlxG.mouse.justMoved))
			afkTimer = AFK_TIMER_VALUE;

		if (!transitioning && afkTimer <= 0)
		{
			transitioning = true;
			canStart = false;
			afkTimer = AFK_TIMER_VALUE;

			whiteBG.color = 0xFF000000;
			FlxTween.tween(whiteBG, {alpha: 1}, 1, {ease: FlxEase.quadOut});
			FlxTween.tween(FlxG.sound.music, {volume: 0}, 1, {ease: FlxEase.quadOut,
				onComplete: twn ->
				{
					Main.fpsVar.visible = false;
					hideTitle();

					FlxG.sound.music.stop();
					playVideo(afkVideos[FlxG.random.int(0, afkVideos.length - 1)], true);
				}
			});
		}
		else if (afkTimer > 0 && canStart)
			afkTimer -= elapsed;

		var pressedEnter:Bool = #if mobile shortPress || #end FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START) pressedEnter = true;
			#if switch
			if (gamepad.justPressed.B) pressedEnter = true;
			#end
		}

		if (pressContinue && !canStart)
		{
			if (controls.ACCEPT #if mobile || shortPress #end)
			{
				pressContinue = false;
				FlxG.sound.play(Paths.sound('menumomentclick'));
				FlxG.camera.flash(FlxColor.RED, 1);
				new FlxTimer().start(2, (_) -> playVideo('introexe'));
				warningText.alpha = warningText2.alpha = 0;
			}
		}

		if (initialized && !transitioning && canStart)
		{
			if (backend.BurningBot.active)
				backend.BurningBot.updateTitle(this, elapsed);
			else if (mousePosition == 'left' && pressedEnter)
				confirmStart();
		}

		if (!transitioning && canStart && parallaxUnlocked)
		{
			final threshold:Float = FlxG.width * PARALLAX_THRESHOLD;
			final arrowW:Float = parallaxArrow.width;
			
			if (mousePosition == 'left' && FlxG.mouse.viewX >= threshold)
			{
				cancelLogoTweens();
				mousePosition = 'right';
				if (ring != null) FlxTween.tween(ring,          {x: savedRingX - arrowW},                 0.50, {ease: FlxEase.cubeOut});
				if (bandana != null) FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF - arrowW},   0.51, {ease: FlxEase.cubeOut});
				if (logotxt != null) FlxTween.tween(logotxt,       {x: savedRingX + logotxt_OFF - arrowW},   0.52, {ease: FlxEase.cubeOut});
				if (eyes != null) FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF - arrowW},      0.55, {ease: FlxEase.cubeOut});
				if (parallaxArrow != null) FlxTween.tween(parallaxArrow, {x: FlxG.width - arrowW},                 0.50, {ease: FlxEase.cubeOut});
			}
			else if (mousePosition == 'right' && FlxG.mouse.viewX < threshold)
			{
				cancelLogoTweens();
				mousePosition = 'left';
				if (ring != null) FlxTween.tween(ring,          {x: savedRingX},                          0.50, {ease: FlxEase.cubeOut});
				if (bandana != null) FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF},            0.51, {ease: FlxEase.cubeOut});
				if (logotxt != null) FlxTween.tween(logotxt,       {x: savedRingX + logotxt_OFF},            0.52, {ease: FlxEase.cubeOut});
				if (eyes != null) FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF},               0.55, {ease: FlxEase.cubeOut});
				if (parallaxArrow != null) FlxTween.tween(parallaxArrow, {x: FlxG.width},                          0.50, {ease: FlxEase.cubeOut});
			}

			if (mousePosition == 'right' && (pressedEnter || FlxG.mouse.justPressed))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				transitioning = true;

				new FlxTimer().start(0.8, (_) -> {
					FlxG.sound.music?.fadeOut(0.3);
					FlxG.switchState(() -> new ParallaxState());
				});
				FlxTween.tween(whiteBG, {alpha: 1}, 0.8);

				cancelLogoTweens();
				final arrowW25:Float = arrowW * 2.5;
				if (ring != null) FlxTween.tween(ring,          {x: savedRingX - arrowW25},                 0.90, {ease: FlxEase.cubeOut});
				if (bandana != null) FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF - arrowW25},   0.91, {ease: FlxEase.cubeOut});
				if (logotxt != null) FlxTween.tween(logotxt,       {x: savedRingX + logotxt_OFF - arrowW25},   0.92, {ease: FlxEase.cubeOut});
				if (eyes != null) FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF - arrowW25},      0.95, {ease: FlxEase.cubeOut});
				if (parallaxArrow != null) FlxTween.tween(parallaxArrow, {x: FlxG.width - arrowW * 2},               0.90, {ease: FlxEase.cubeOut});
			}
		}

		super.update(elapsed);

		logoSine += elapsed;

		final sinBase:Float = Math.sin(logoSine);
		final sinHalf:Float = Math.sin(logoSine + (Math.PI / 2)) * 0.15;
		
		if (ring != null)
			ring.y = 20 + sinBase * 10;
			
		if (bandana != null) 
		{
			bandana.y = BANDANA_Y + Math.sin(logoSine - 0.05) * 10;
			bandana.angle = sinHalf;
		}

		if (logotxt != null) 
		{
			logotxt.y = logotxt_Y + Math.sin(logoSine - 0.1) * 10;
			logotxt.angle = sinHalf;
		}

		if (eyes != null) 
		{
			eyes.y = EYES_Y + Math.sin(logoSine - 0.15) * 7;
			eyes.angle = Math.sin(logoSine + (Math.PI / 2.5) + 0.15) * 2;
		}

		if (!canStart || unlocked.length < 5) return;

		final anyDir:Bool = controls.UI_UP_P || controls.UI_DOWN_P || controls.UI_LEFT_P || controls.UI_RIGHT_P #if mobile || swipeUP || swipeDOWN || swipeLEFT || swipeRIGHT #end;
		
		if (fridgeStatus < 4)
		{
			final hit:Bool = switch (fridgeStatus)
			{
				case 0: controls.UI_UP_P #if mobile || swipeUP #end;
				case 1: controls.UI_DOWN_P #if mobile || swipeDOWN #end;
				case 2: controls.UI_LEFT_P #if mobile || swipeLEFT #end;
				case 3: controls.UI_RIGHT_P #if mobile || swipeRIGHT #end;
				default: false;
			};
			
			if (hit)
			{
				fridgeStatus++;
				var snd = FlxG.sound.play(Paths.sound('secretKeyPress'));
					snd.pitch = FlxG.random.float(0.7, 1.3);
				if (fridgeStatus == 4)
				{
					FlxG.sound.play(Paths.sound('ringSound'));
					transitioning = true;
				}
			}
			else if (anyDir) 
			{
				#if !mobile fridgeStatus = 0; #end
			}
		}

		if ((controls.ACCEPT #if mobile || shortPress #end) && fridgeStatus == 4)
		{
			fridgeStatus = 0;
			CustomShapeTransition.shape = CustomShapeTransition.getShapeByString('SUNKY');
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(whiteBG, {alpha: 1}, 0.8);
			FlxG.sound.music?.fadeOut(0.5);
			
			new FlxTimer().start(0.8, (_) -> { 
				FlxG.switchState(() -> new states.access.FridgeAccess()); 
			});
		}
	}

	function confirmStart():Void
	{
		titleText.animation.play('press', true);
		transitioning = true;
		spikes.acceleration.x = -100;

		FlxG.sound.play(Paths.sound(backend.BurningBot.active ? 'menueggmanlaugh' : 'menulaugh'));
		FlxG.sound.play(Paths.sound('menumomentclick'));
		FlxG.camera.flash(FlxColor.RED, 0.5);

		new FlxTimer().start(1, (_) -> {
			FlxTween.tween(blackScreen, {alpha: 1}, 1);
			FlxTween.tween(eyes, {alpha: 0}, 1.5, {ease: FlxEase.expoIn});

			new FlxTimer().start(1.5, (_) -> FlxG.switchState(() -> new EXEMenu()));
		});
	}

	function cancelLogoTweens():Void
	{
		FlxTween.cancelTweensOf(ring);
		FlxTween.cancelTweensOf(bandana);
		FlxTween.cancelTweensOf(logotxt);
		FlxTween.cancelTweensOf(eyes);
		FlxTween.cancelTweensOf(parallaxArrow);
	}
}