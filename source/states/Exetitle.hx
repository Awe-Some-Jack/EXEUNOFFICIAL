package states;

import objects.GifSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;

import openfl.Assets;

import states.StoryMenuState;
import states.Exemenu;

class Exetitle extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public static var closedState:Bool = false;

	var titleText:FlxSprite;
	var blackScreen:FlxSprite;

	var ring:FlxSprite;
	var bandana:FlxSprite;
	var logotxt:FlxSprite;
	var eyes:FlxSprite;

	var canStart:Bool = false;
	
	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		if(initialized) canStart = true;

		if(!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();
		}

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		FlxG.mouse.visible = false;
		if(FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(() -> new FlashingState());
		}
		else
		{
			if (!initialized && FlxG.sound.music == null)
			{
				Main.fpsVar.visible = false;
				persistentUpdate = true;
				initialized = true;

				FlxG.camera.visible = false;
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('exelaugh'));
					new FlxTimer().start(1.6, function(tmr:FlxTimer)
					{
						canStart = true;
						Main.fpsVar.visible = ClientPrefs.data.showFPS;
						FlxG.camera.visible = true;
						FlxG.camera.flash(FlxColor.RED, 1);
						FlxG.sound.playMusic(Assets.getSound('assets/exe/music/soundtest.ogg'), 1);
						FlxG.sound.play(Paths.sound('showMoment'));
					});
				});
			}
		}

		var screenBg:GifSprite = new GifSprite(0, 0);
		screenBg.loadGif('assets/exe/title/statictitlemenu.gif');
		screenBg.antialiasing = ClientPrefs.data.antialiasing;
		screenBg.setGraphicSize(FlxG.width, FlxG.height);
		screenBg.updateHitbox();
		screenBg.screenCenter();
		add(screenBg);

		makeLogo();

		var spikes:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/title/spikesdown.png'), X);
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

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackScreen.alpha = 0;
		add(blackScreen);

		eyes = new FlxSprite(ring.x + (1074 * 0.4)).loadGraphic(Assets.getBitmapData('assets/exe/title/logo/eyes.png'));
		eyes.scale.set(0.4, 0.4);
		eyes.updateHitbox();
		add(eyes);
	}

	function makeLogo():Void
	{
		var path:String = 'assets/exe/title/logo/';
	
		ring = new FlxSprite().loadGraphic(Assets.getBitmapData(path + 'ring.png'));
		ring.scale.set(0.4, 0.4);
		ring.updateHitbox();
		ring.screenCenter(X);
		add(ring);

		bandana = new FlxSprite(ring.x + (329 * 0.4)).loadGraphic(Assets.getBitmapData(path + 'bandana.png'));
		bandana.scale.set(0.4, 0.4);
		bandana.updateHitbox();
		add(bandana);

		logotxt = new FlxSprite(ring.x + (711 * 0.4)).loadGraphic(Assets.getBitmapData(path + 'sonic.png'));
		logotxt.scale.set(0.4, 0.4);
		logotxt.updateHitbox();
		add(logotxt);
	}

	var transitioning:Bool = false;
	var logoSin:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (initialized && !transitioning && canStart)
		{
			if(pressedEnter)
			{
				titleText.animation.play('press', true);
				transitioning = true;

				FlxG.sound.play(Paths.sound('menulaugh'));
				FlxG.sound.play(Paths.sound('menumomentclick'));
				FlxG.camera.flash(FlxColor.RED, 0.5);

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxTween.tween(blackScreen, {alpha: 1}, 1);
					new FlxTimer().start(1.3, function(tmr:FlxTimer){FlxG.switchState(() -> new Exemenu());});
					closedState = true;
				});
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
	}
}
