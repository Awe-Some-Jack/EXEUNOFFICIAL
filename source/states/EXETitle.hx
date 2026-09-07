package states;

import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
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
	var titleText:FlxSprite;
	var blackScreen:FlxSprite;
	var spikes:FlxBackdrop;
	var ring:FlxSprite;
	var bandana:FlxSprite;
	var logotxt:FlxSprite;
	var eyes:FlxSprite;
	var whiteBG:FlxSprite;
	var parallaxArrow:FlxSprite;
	var playedIntro:Bool = false;

	var canStart:Bool = false;

	override function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (FlxG.save.data.burningBot == true)
		{
			FlxG.save.data.burningBot = false;
			FlxG.save.flush();
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

		if (!initialized)
		{
			FlxG.mouse.visible = false;
			Main.fpsVar.visible = false;

			playVideo('introexe');
			
			videoPlaying = true;
		}
		else
		{
			canStart = true;
			FlxG.mouse.visible = true;
			buildTitle();
		}

		super.create();
	}

	function playVideo(vid:String)
	{
		if(video != null) video.destroy();

		video = new VideoSprite();
		video.loadVideo(Paths.video(vid));
		video.onEnd(onVideoEnd);
		video.onFormat(() -> {
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.video.screenCenter();
		});
		video.playDelayed();
		add(video);
		
		videoPlaying = true;
	}

	function onVideoEnd():Void
	{

		if (FlxG.save.data.goToFinalEscape != null){
			FlxG.save.data.goToFinalEscape = null;
			FlxG.save.flush();

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

		videoPlaying = false;
		initialized = true;

		buildTitle();

		FlxG.camera.visible = false;

		new FlxTimer().start(0.1, (_) -> {
			FlxG.sound.play(Paths.sound(backend.BurningBot.active ? 'eggmanlaugh' : 'exelaugh'));
			new FlxTimer().start(1.6, (_) -> {
				canStart = true;
				FlxG.mouse.visible = true;
				FlxG.camera.visible = true;
				
				FlxG.camera.flash(FlxColor.RED, 1);
				
				FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
				FlxG.sound.play(Paths.sound('showMoment'));
				
				Main.fpsVar.visible = ClientPrefs.data.showFPS;
			});
		});
		
	}

	function buildTitle():Void
	{
		#if VIDEOS_ALLOWED
		final screenBg = new VideoSprite();
		screenBg.onFormat(() -> {
			screenBg.setGraphicSize(FlxG.width, FlxG.height);
			screenBg.screenCenter();
		});
		if (screenBg.loadVideo('assets/exe/title/statictitlemenu.mp4', [VideoSprite.ARG_LOOPING])) screenBg.playDelayed();
		add(screenBg);
		#end

		makeLogo();

		spikes = new FlxBackdrop(Paths.getBitmapData('assets/exe/title/spikesdown.webp'), X);
		spikes.scale.set(0.4, 0.4);
		spikes.updateHitbox();
		spikes.y = FlxG.height - spikes.height;
		spikes.velocity.x = -50;
		add(spikes);
		
		titleText = new FlxSprite();
		titleText.frames = FlxAtlasFrames.fromSparrow('assets/exe/title/titleEnterNEW.webp', 'assets/exe/title/titleEnterNEW.xml');
		titleText.animation.addByPrefix('idle', 'Press Enter to Begin instance 1', 24, true);
		titleText.animation.addByPrefix('press', 'ENTER PRESSED instance 1', 24, false);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		titleText.y += 80;
		add(titleText);

		parallaxArrow = new FlxSprite(FlxG.width).loadGraphic(Paths.getBitmapData('assets/exe/parallax/parallaxarrow.webp'));
		parallaxArrow.screenCenter(Y);
		add(parallaxArrow);
		
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0.0000001;
		add(blackScreen);

		eyes = new FlxSprite(ring.x + (1074 * 0.4)).loadGraphic(Paths.getBitmapData('assets/exe/title/logo/eyes.webp'));
		eyes.scale.set(0.4, 0.4);
		eyes.updateHitbox();
		add(eyes);

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteBG.alpha = 0.0000001;
		whiteBG.screenCenter();
		add(whiteBG);
	}

	var savedRingX:Float = 0;
	function makeLogo():Void
	{
		final path:String = 'assets/exe/title/logo/';
		
		ring = new FlxSprite().loadGraphic(Paths.getBitmapData(path + 'ring.webp'));
		ring.scale.set(0.4, 0.4);
		ring.updateHitbox();
		ring.screenCenter(X);
		add(ring);

		savedRingX = ring.x;
		bandana = new FlxSprite(ring.x + (329 * 0.4)).loadGraphic(Paths.getBitmapData(path + 'bandana.webp'));
		bandana.scale.set(0.4, 0.4);
		bandana.updateHitbox();
		add(bandana);
		
		logotxt = new FlxSprite(ring.x + (711 * 0.4)).loadGraphic(Paths.getBitmapData(path + 'sonic.webp'));
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
	var transitioning:Bool = false;
	var logoSin:Float = 0;
	var fridgeStatus:Int = 0;
	
	static inline final BANDANA_OFF:Float = 329 * 0.4;
	static inline final LOGOTXT_OFF:Float = 711 * 0.4;
	static inline final EYES_OFF:Float = 1074 * 0.4;
	static inline final BANDANA_Y:Float = 20 + (873 * 0.4);
	static inline final LOGOTXT_Y:Float = 20 + (777 * 0.4);
	static inline final EYES_Y:Float = 20 + (517 * 0.4);
	static inline final PARALLAX_THRESHOLD:Float = 0.85;

	override function update(elapsed:Float):Void
	{
		if (videoPlaying || subState != null)
		{
			super.update(elapsed);
			return;
		}
		
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = #if mobile shortPress || #end FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		final gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START) pressedEnter = true;
			#if switch
			if (gamepad.justPressed.B) pressedEnter = true;
			#end
		}

		if (initialized && !transitioning && canStart)
		{
			if (backend.BurningBot.active)
				backend.BurningBot.updateTitle(this, elapsed);
			else if (mousePosition == 'left' && pressedEnter)
				confirmStart();
		}

		if (!transitioning && canStart)
		{
			final threshold:Float = FlxG.width * PARALLAX_THRESHOLD;
			final arrowW:Float = parallaxArrow.width;
			
			if (mousePosition == 'left' && FlxG.mouse.viewX >= threshold)
			{
				cancelLogoTweens();
				mousePosition = 'right';
				FlxTween.tween(ring,          {x: savedRingX - arrowW},                 0.50, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF - arrowW},   0.51, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt,       {x: savedRingX + LOGOTXT_OFF - arrowW},   0.52, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF - arrowW},      0.55, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width - arrowW},                 0.50, {ease: FlxEase.cubeOut});
			}
			else if (mousePosition == 'right' && FlxG.mouse.viewX < threshold)
			{
				cancelLogoTweens();
				mousePosition = 'left';
				FlxTween.tween(ring,          {x: savedRingX},                          0.50, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF},            0.51, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt,       {x: savedRingX + LOGOTXT_OFF},            0.52, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF},               0.55, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width},                          0.50, {ease: FlxEase.cubeOut});
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
				FlxTween.tween(ring,          {x: savedRingX - arrowW25},                 0.90, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF - arrowW25},   0.91, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt,       {x: savedRingX + LOGOTXT_OFF - arrowW25},   0.92, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF - arrowW25},      0.95, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width - arrowW * 2},               0.90, {ease: FlxEase.cubeOut});
			}
		}

		super.update(elapsed);

		logoSin += elapsed;

		final sinBase:Float = Math.sin(logoSin);
		final sinHalf:Float = Math.sin(logoSin + (Math.PI / 2)) * 0.15;
		
		if (ring != null)
			ring.y = 20 + sinBase * 10;
			
		if (bandana != null) 
		{
			bandana.y = BANDANA_Y + Math.sin(logoSin - 0.05) * 10;
			bandana.angle = sinHalf;
		}

		if (logotxt != null) 
		{
			logotxt.y = LOGOTXT_Y + Math.sin(logoSin - 0.1) * 10;
			logotxt.angle = sinHalf;
		}

		if (eyes != null) 
		{
			eyes.y = EYES_Y + Math.sin(logoSin - 0.15) * 7;
			eyes.angle = Math.sin(logoSin + (Math.PI / 2.5) + 0.15) * 2;
		}

		if (!canStart) return;

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
				trace(hit + " " + fridgeStatus);
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