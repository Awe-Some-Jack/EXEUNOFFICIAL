package states;

import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;

import openfl.Assets;

import objects.VideoSprite;
import states.StoryModeState;
import states.EXEMenu;
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

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();

			if (FlxG.save.data?.fullscreen)
				FlxG.fullscreen = FlxG.save.data.fullscreen;

			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
			StoryModeState.weekCompleted = FlxG.save.data.weekCompleted;

		if (!initialized)
		{
			FlxG.mouse.visible = false;
			Main.fpsVar.visible = false;

			video = new VideoSprite();
			video.loadVideo(Paths.video('HaxeFlixelIntro'));
			video.onFormat(() -> {
				video.setGraphicSize(FlxG.width, FlxG.height);
				video.screenCenter();
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

		Main.fpsVar.visible = false;
		persistentUpdate = true;

		FlxG.camera.visible = false;

		new FlxTimer().start(0.1, (_) -> {
			FlxG.sound.play(Paths.sound('exelaugh'));
			new FlxTimer().start(1.6, (_) -> {
				canStart = true;
				FlxG.mouse.visible = true;
				Main.fpsVar.visible = ClientPrefs.data.showFPS;
				FlxG.camera.visible = true;
				FlxG.camera.flash(FlxColor.RED, 1);
				FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
				FlxG.sound.play(Paths.sound('showMoment'));
			});
		});
	}
	function buildTitle():Void
	{
		final screenBg:FlxGifSprite = new FlxGifSprite().loadGif('assets/exe/title/statictitlemenu.gif');
		screenBg.antialiasing = ClientPrefs.data.antialiasing;
		screenBg.setGraphicSize(FlxG.width, FlxG.height);
		screenBg.updateHitbox();
		screenBg.screenCenter();
		add(screenBg);

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
		titleText.antialiasing = ClientPrefs.data.antialiasing;
		titleText.updateHitbox();
		titleText.screenCenter();
		titleText.y += 80;
		add(titleText);

		parallaxArrow = new FlxSprite(FlxG.width).loadGraphic(Assets.getBitmapData('assets/exe/parallax/parallaxarrow.png'));
		parallaxArrow.antialiasing = ClientPrefs.data.antialiasing;
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
		var path:String = 'assets/exe/title/logo/';
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

	var mousePosition:String = 'left';
	var transitioning:Bool = false;
	var logoSin:Float = 0;
	var fridgeStatus:Int = 0;
	override function update(elapsed:Float)
	{
		if (videoPlaying)
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
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
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
				new FlxTimer().start(1, function(_) {
					FlxTween.tween(blackScreen, {alpha: 1}, 1);
					FlxTween.tween(eyes, {alpha: 0}, 1.5, {ease: FlxEase.expoIn});
					new FlxTimer().start(1.5, function(_) { MusicBeatState.switchState(new EXEMenu()); });
					closedState = true;
				});
			}
		}
		if (!transitioning && canStart)
		{
			if (mousePosition == 'left' && FlxG.mouse.getScreenPosition().x >= (FlxG.width * 0.85))
			{
				FlxTween.cancelTweensOf(ring);
				FlxTween.cancelTweensOf(bandana);
				FlxTween.cancelTweensOf(logotxt);
				FlxTween.cancelTweensOf(eyes);
				FlxTween.cancelTweensOf(parallaxArrow);

				mousePosition = 'right';

				FlxTween.tween(ring, {x: savedRingX - parallaxArrow.width}, 0.5, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana, {x: savedRingX + (329 * 0.4) - parallaxArrow.width}, 0.51, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt, {x: savedRingX + (711 * 0.4) - parallaxArrow.width}, 0.52, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes, {x: savedRingX + (1074 * 0.4) - parallaxArrow.width}, 0.55, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width - parallaxArrow.width}, 0.5, {ease: FlxEase.cubeOut});
			}
			else if (mousePosition == 'right' && FlxG.mouse.getScreenPosition().x < (FlxG.width * 0.85))
			{
				FlxTween.cancelTweensOf(ring);
				FlxTween.cancelTweensOf(bandana);
				FlxTween.cancelTweensOf(logotxt);
				FlxTween.cancelTweensOf(eyes);
				FlxTween.cancelTweensOf(parallaxArrow);

				mousePosition = 'left';

				FlxTween.tween(ring, {x: savedRingX}, 0.5, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana, {x: savedRingX + (329 * 0.4)}, 0.51, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt, {x: savedRingX + (711 * 0.4)}, 0.52, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes, {x: savedRingX + (1074 * 0.4)}, 0.55, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width}, 0.5, {ease: FlxEase.cubeOut});
			}
			if (mousePosition == 'right' && (pressedEnter || FlxG.mouse.justPressed))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				transitioning = true;
				
				new FlxTimer().start(0.8, function(_) {
					FlxG.sound.music.fadeOut(0.3);
					MusicBeatState.switchState(new ParallaxState());
				});
				FlxTween.tween(whiteBG, {alpha: 1}, 0.8);

				FlxTween.cancelTweensOf(ring);
				FlxTween.cancelTweensOf(bandana);
				FlxTween.cancelTweensOf(logotxt);
				FlxTween.cancelTweensOf(eyes);
				FlxTween.cancelTweensOf(parallaxArrow);

				FlxTween.tween(ring, {x: savedRingX - (parallaxArrow.width * 2.5)}, 0.9, {ease: FlxEase.cubeOut});
				FlxTween.tween(bandana, {x: savedRingX + (329 * 0.4) - (parallaxArrow.width * 2.5)}, 0.91, {ease: FlxEase.cubeOut});
				FlxTween.tween(logotxt, {x: savedRingX + (711 * 0.4) - (parallaxArrow.width * 2.5)}, 0.92, {ease: FlxEase.cubeOut});
				FlxTween.tween(eyes, {x: savedRingX + (1074 * 0.4) - (parallaxArrow.width * 2.5)}, 0.95, {ease: FlxEase.cubeOut});
				FlxTween.tween(parallaxArrow, {x: FlxG.width - (parallaxArrow.width * 2)}, 0.9, {ease: FlxEase.cubeOut});
			}
		}
		super.update(elapsed);

		logoSin += elapsed;
		ring.y = 20 + (Math.sin(logoSin) * 10);
		bandana.y = 20 + (873 * 0.4) + (Math.sin(logoSin - 0.05) * 10);
		bandana.angle = Math.sin(logoSin + (Math.PI / 2)) * 0.15;
		logotxt.y = 20 + (777 * 0.4) + (Math.sin(logoSin - 0.1) * 10);
		logotxt.angle = Math.sin(logoSin + (Math.PI / 2)) * 0.15;
		eyes.y = 20 + (517 * 0.4) + (Math.sin(logoSin - 0.15) * 7);
		eyes.angle = Math.sin(logoSin + (Math.PI / 2.5) + 0.15) * 2;

		if (!canStart) return;

		var fridgeInputs = [
			controls.UI_UP_P,
			controls.UI_DOWN_P,
			controls.UI_LEFT_P,
			controls.UI_RIGHT_P
		];

		if (fridgeStatus < fridgeInputs.length)
		{
			if (fridgeInputs[fridgeStatus])
			{
				fridgeStatus++;
				if (fridgeStatus == fridgeInputs.length)
				{
					FlxG.sound.play(Paths.sound('ringSound'));
					transitioning = true;
				}
			}
			else if (controls.UI_UP_P || controls.UI_DOWN_P || controls.UI_LEFT_P || controls.UI_RIGHT_P) fridgeStatus = 0;
		}

		if (controls.ACCEPT && fridgeStatus == fridgeInputs.length)
		{
			fridgeStatus = 0;
			CustomShapeTransition.shape = CustomShapeTransition.getShapeByString('SUNKY');
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(whiteBG, {alpha: 1}, 0.8);
			FlxG.sound.music.fadeOut(0.5);
			new FlxTimer().start(0.8, function(_) { MusicBeatState.switchState(new states.access.FridgeAccess()); });
		}
	}
}
