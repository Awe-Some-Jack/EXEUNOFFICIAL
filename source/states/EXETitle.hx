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

import openfl.Assets;
import backend.Song;
import backend.Difficulty;
import backend.WeekData;
import backend.Highscore;

import objects.VideoSprite;
import states.StoryModeState;
import states.EXEMenu;
import states.LoadingState;
import states.StoryModeState;
import states.parallax.ParallaxState;

class EXETitle extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
	public static var initialized:Bool = false;
	public static var closedState:Bool = false;
	
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

	var canStart:Bool = false;

	override function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();

			if (FlxG.save.data?.fullscreen ?? false)
				FlxG.fullscreen = FlxG.save.data.fullscreen;
		}

		if (FlxG.save.data?.weekCompleted != null)
			StoryModeState.weekCompleted = FlxG.save.data.weekCompleted;

		if (!initialized)
		{
			FlxG.mouse.visible = false;
			Main.fpsVar.visible = false;
			
			video = new VideoSprite();
			video.loadVideo(Paths.video('HaxeFlixelIntro'));
			video.onFormat(() -> {
				video.setGraphicSize(FlxG.width, FlxG.height);
				video.video.screenCenter();
				precache();
			});
			video.onEnd(() -> onVideoEnd());
			video.playDelayed();
			add(video);
			
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

	function precache():Void
	{
		final logoPath:String = 'assets/exe/title/logo/';
		
		Assets.getBitmapData(logoPath + 'ring.png');
		Assets.getBitmapData(logoPath + 'bandana.png');
		Assets.getBitmapData(logoPath + 'sonic.png');
		Assets.getBitmapData(logoPath + 'eyes.png');
		Assets.getBitmapData('assets/exe/title/spikesdown.png');
		Assets.getBitmapData('assets/exe/parallax/parallaxarrow.png');
		Assets.getSound('assets/exe/music/menu.ogg');
	}

	function onVideoEnd():Void
	{
		videoPlaying = false;
		initialized = true;

		buildTitle();

		FlxG.camera.visible = false;

		new FlxTimer().start(0.1, (_) -> {
			FlxG.sound.play(Paths.sound('exelaugh'));
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
		final screenBg = new hxvlc.flixel.FlxVideoSprite(0, 0);
		screenBg.bitmap.onFormatSetup.add(() -> {
			screenBg.setGraphicSize(FlxG.width, FlxG.height);
			screenBg.updateHitbox();
			screenBg.screenCenter();
		});
		screenBg.bitmap.onEndReached.add(() -> playTitleVideo(screenBg));
		add(screenBg);
		playTitleVideo(screenBg);
		FlxG.autoPause = false;
		#end

		makeLogo();

		spikes = new FlxBackdrop(Assets.getBitmapData('assets/exe/title/spikesdown.png'), X);
		spikes.scale.set(0.4, 0.4);
		spikes.updateHitbox();
		spikes.y = FlxG.height - spikes.height;
		spikes.velocity.x = -50;
		add(spikes);
		
		titleText = new FlxSprite();
		titleText.frames = FlxAtlasFrames.fromSparrow('assets/exe/title/titleEnterNEW.png', 'assets/exe/title/titleEnterNEW.xml');
		titleText.animation.addByPrefix('idle', 'Press Enter to Begin instance 1', 24, true);
		titleText.animation.addByPrefix('press', 'ENTER PRESSED instance 1', 24, false);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		titleText.y += 80;
		add(titleText);

		parallaxArrow = new FlxSprite(FlxG.width).loadGraphic(Assets.getBitmapData('assets/exe/parallax/parallaxarrow.png'));
		parallaxArrow.screenCenter(Y);
		add(parallaxArrow);
		
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0.0000001;
		add(blackScreen);

		eyes = new FlxSprite(ring.x + (1074 * 0.4)).loadGraphic(Assets.getBitmapData('assets/exe/title/logo/eyes.png'));
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
		
		ring = new FlxSprite().loadGraphic(Assets.getBitmapData(path + 'ring.png'));
		ring.scale.set(0.4, 0.4);
		ring.updateHitbox();
		ring.screenCenter(X);
		add(ring);

		savedRingX = ring.x;
		
		bandana = new FlxSprite(ring.x + (329 * 0.4)).loadGraphic(Assets.getBitmapData(path + 'bandana.png'));
		bandana.scale.set(0.4, 0.4);
		bandana.updateHitbox();
		add(bandana);
		
		logotxt = new FlxSprite(ring.x + (711 * 0.4)).loadGraphic(Assets.getBitmapData(path + 'sonic.png'));
		logotxt.scale.set(0.4, 0.4);
		logotxt.updateHitbox();
		add(logotxt);
	}

	#if VIDEOS_ALLOWED
	function playTitleVideo(v:hxvlc.flixel.FlxVideoSprite):Void
	{
		if (v?.load('assets/exe/title/statictitlemenu.mp4') ?? false)
			new FlxTimer().start(0.001, (_) -> v?.play());
	}
	#end

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

	var _mouseScreenX:Float = 0;
	override function update(elapsed:Float):Void
	{
		if (videoPlaying || subState != null)
		{
			super.update(elapsed);
			return;
		}
		
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		
		#if mobile
		for (touch in FlxG.touches.list)
			if (touch.justPressed) pressedEnter = true;
		#end
		
		final gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.START) pressedEnter = true;
			#if switch
			if (gamepad.justPressed.B) pressedEnter = true;
			#end
		}


		if (initialized && !transitioning && canStart && mousePosition == 'left')
		{
			if (pressedEnter)
			{
				titleText.animation.play('press', true);
				transitioning = true;
				spikes.acceleration.x = -100;
				
				FlxG.sound.play(Paths.sound('menulaugh'));
				FlxG.sound.play(Paths.sound('menumomentclick'));
				FlxG.camera.flash(FlxColor.RED, 0.5);
				
				new FlxTimer().start(1, (_) -> {
					FlxTween.tween(blackScreen, {alpha: 1}, 1);
					FlxTween.tween(eyes, {alpha: 0}, 1.5, {ease: FlxEase.expoIn});

					new FlxTimer().start(1.5, (_) -> { 
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
						} else FlxG.switchState(() -> new EXEMenu()); 
					});
					closedState = true;
				});
			}
		}

		if (!transitioning && canStart)
		{
			_mouseScreenX = FlxG.mouse.viewX;

			final threshold:Float = FlxG.width * PARALLAX_THRESHOLD;
			final arrowW:Float = parallaxArrow.width;
			
			if (mousePosition == 'left' && _mouseScreenX >= threshold)
			{
				cancelLogoTweens();
				mousePosition = 'right';
				
				FlxTween.tween(ring,          {x: savedRingX - arrowW},                 0.50, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana,       {x: savedRingX + BANDANA_OFF - arrowW},   0.51, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt,       {x: savedRingX + LOGOTXT_OFF - arrowW},   0.52, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes,          {x: savedRingX + EYES_OFF - arrowW},      0.55, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width - arrowW},                 0.50, {ease: FlxEase.cubeOut});
			}
			else if (mousePosition == 'right' && _mouseScreenX < threshold)
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

		final anyDir:Bool = controls.UI_UP_P || controls.UI_DOWN_P || controls.UI_LEFT_P || controls.UI_RIGHT_P;
		
		if (fridgeStatus < 4)
		{
			final hit:Bool = switch (fridgeStatus)
			{
				case 0: controls.UI_UP_P;
				case 1: controls.UI_DOWN_P;
				case 2: controls.UI_LEFT_P;
				case 3: controls.UI_RIGHT_P;
				default: false;
			};
			
			if (hit)
			{
				fridgeStatus++;
				if (fridgeStatus == 4)
				{
					FlxG.sound.play(Paths.sound('ringSound'));
					transitioning = true;
				}
			}
			else if (anyDir) 
			{
				fridgeStatus = 0;
			}
		}

		if (controls.ACCEPT && fridgeStatus == 4)
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

	function cancelLogoTweens():Void
	{
		FlxTween.cancelTweensOf(ring);
		FlxTween.cancelTweensOf(bandana);
		FlxTween.cancelTweensOf(logotxt);
		FlxTween.cancelTweensOf(eyes);
		FlxTween.cancelTweensOf(parallaxArrow);
	}
}