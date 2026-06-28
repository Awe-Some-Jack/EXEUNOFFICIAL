package states;

import openfl.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

import backend.Song;
import backend.Highscore;
import backend.WeekData;
import backend.Difficulty;
import backend.Language;

import states.EXEFreeplay;
import states.LoadingState;
import states.PlayState;

class EXEMenu extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';
	public static var selectedOptionIndex:Int = 2;

	static inline final TOTAL_OPTIONS:Int = 5;
	static inline final CENTER_POSITION:Int = 2;

	static final OPTION_TEXTS:Array<String> = ["SOUND TEST", "FREEPLAY", "STORY MODE", "EXTRAS", "OPTIONS"];

	static function getOptionTexts():Array<String> {
		return [
			Language.get('mainmenu.soundtest', 'SOUND TEST'),
			Language.get('mainmenu.freeplay',  'FREEPLAY'),
			Language.get('mainmenu.storymode', 'STORY MODE'),
			Language.get('mainmenu.extras',    'EXTRAS'),
			Language.get('mainmenu.options',   'OPTIONS')
		];
	}

	static final OPTION_POSITIONS:Array<{x:Float, y:Float}> = [
		{x: 175.0, y: -60.0},
		{x: 110.0, y:  65.0},
		{x:  20.0, y: 220.0},
		{x: 110.0, y: 360.0},
		{x: 175.0, y: 480.0}
	];

	static final OPTION_SCALES:Array<Float> = [0.25, 0.30, 0.37, 0.30, 0.25];
	static final OPTION_ALPHAS:Array<Float> = [0.55, 0.80, 1.00, 0.80, 0.55];

	static final TEXT_POSITIONS:Array<{x:Float, y:Float}> = [
		{x:   20, y: -32},
		{x:  -50, y:  94},
		{x: -140, y: 251},
		{x:  -50, y: 389},
		{x:   20, y: 507}
	];

	static final TEXT_SCALES:Array<Float> = [0.245, 0.3, 0.330, 0.3, 0.245];

	var menuOptions:Array<FlxSprite> = [];
	var menuTexts:Array<FlxText> = [];
	var shadowSprite:FlxSprite;

	var previousSelectedIndex:Int = 2;
	var isMovingUpward:Bool = false;
	var canInteract:Bool = true;
	var canManiaInteract:Bool = false;
	var cooldownTimer:Float = 0.0;
	var isBlinking:Bool = false;
	var blinkTimer:Float = 0.0;
	var blinkCount:Int = 0;
	var shadowTimer:Float = 0.0;
	var shadowMoved:Bool = false;

	final secretCodes:Array<String> = ['personel', '2005'];
	var curKey:Array<Int>;

	var heylookanemail:FlxSprite;

	#if VIDEOS_ALLOWED
	var menuVideo:hxvlc.flixel.FlxVideoSprite;
	#end

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menu", null);
		#end

		#if VIDEOS_ALLOWED
		menuVideo = new hxvlc.flixel.FlxVideoSprite(0, 0);
		menuVideo.bitmap.onFormatSetup.add(() -> {
			menuVideo.setGraphicSize(FlxG.width, FlxG.height);
			menuVideo.updateHitbox();
			menuVideo.screenCenter();
		});
		menuVideo.bitmap.onEndReached.add(() -> playMenuVideo());
		add(menuVideo);
		playMenuVideo();
		#end

		FlxG.autoPause = false;

		shadowSprite = new FlxSprite();
		shadowSprite.loadGraphic(Assets.getBitmapData("assets/exe/mainmenu/options/shadow.png"));
		shadowSprite.updateHitbox();
		shadowSprite.alpha = 0;
		add(shadowSprite);

		final translatedTexts = getOptionTexts();
		for (i in 0...TOTAL_OPTIONS)
		{
			final option = new FlxSprite();
			option.loadGraphic(Assets.getBitmapData("assets/exe/mainmenu/options/box.png"));
			option.updateHitbox();
			option.ID = i;
			add(option);
			menuOptions.push(option);

			final menuFont = Language.needsCustomFont() ? Paths.font(Language.getFontForLanguage()) : "assets/fonts/sonicfree.otf";
			final menuFontSize = Language.needsCustomFont() ? 180 : 280;
			final optionText = new FlxText(0, 0, option.width * 2, translatedTexts[i]);
			optionText.setFormat(menuFont, menuFontSize, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
			optionText.borderSize = 2;
			optionText.antialiasing = ClientPrefs.data.antialiasing;
			optionText.ID = i;
			add(optionText);
			menuTexts.push(optionText);
		}

		if (EXEFreeplay.maniaUnlock) 
		{
			new FlxTimer().start(0.4, (_) -> maniaEmail());
			heylookanemail = new FlxSprite();
			heylookanemail.frames = FlxAtlasFrames.fromSparrow('assets/exe/mainmenu/unlock/Mail Box.png', 'assets/exe/mainmenu/unlock/Mail Box.xml');
			heylookanemail.animation.addByPrefix('email', 'Mail', 24, false);
			heylookanemail.scale.set(0.5, 0.5);
			heylookanemail.alpha = 0;
			heylookanemail.setPosition(-480, -270);
			add(heylookanemail);
		}

		refreshSelection();
		changeSelection(0, false, false);

		curKey = [for (_ in secretCodes) 0];

		super.create();
	}

	#if VIDEOS_ALLOWED
	function playMenuVideo():Void
	{
		if (menuVideo?.load('assets/exe/mainmenu/menu.mp4') ?? false)
		{
			new FlxTimer().start(0.001, (_) -> {
				menuVideo?.play();
				if (menuVideo?.bitmap != null) menuVideo.bitmap.rate = 1.0;
			});
		}
	}
	#end

	function maniaEmail():Void 
	{
		canInteract = false;
		heylookanemail.animation.play('email', true);
		heylookanemail.alpha = 1;
		new FlxTimer().start(2, (_) -> canManiaInteract = true);
	}

	static final TAILS_DIR:String = 'CRAZY TAILS';

	function goToMania():Void 
	{
		FlxG.camera.fade(FlxColor.BLACK, 1);
		new FlxTimer().start(1, (_) -> {
			canManiaInteract = false;
			final song = 'mania';

			Mods.currentModDirectory = TAILS_DIR;
			WeekData.reloadWeekFiles(false);
			PlayState.storyWeek = 1;
			Difficulty.loadFromWeek();

			final normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
			final launchDiff = (normalIdx > -1) ? normalIdx : 0;

			try
			{
				Song.loadFromJson(song, Highscore.formatSong(song, launchDiff));
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
			}
			catch (e:haxe.Exception)
			{
				trace('Error loading song: ' + e.message);
				return;
			}

			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			
			#if !SHOW_LOADING_SCREEN 
			FlxG.sound.music?.stop(); 
			#end
			
			EXEFreeplay.maniaUnlock = false;
		});
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (subState != null) return;

		updateBlink(elapsed);

		if (cooldownTimer > 0) cooldownTimer -= elapsed;

		updateShadow(elapsed);

		if (canManiaInteract && controls.ACCEPT)
		{
			goToMania();
		}

		if (canInteract && !isBlinking)
		{
			if (controls.UI_UP_P && cooldownTimer <= 0)
				changeSelection(-1, true);
			else if (controls.UI_DOWN_P && cooldownTimer <= 0)
				changeSelection(1, false);
			else if (controls.BACK)
			{
				canInteract = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new EXETitle());
			}
			else if (controls.ACCEPT)
				startBlink();
		}

		for (i in 0...secretCodes.length)
		{
			final code = secretCodes[i];
			if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				final keyName = charToKeyName(code.substr(curKey[i], 1));

				if (Reflect.getProperty(FlxG.keys.justPressed, keyName))
					curKey[i]++;
				else
					curKey[i] = 0;
			}

			if (curKey[i] >= code.length)
				correctCode(i);
		}
	}

	function changeSelection(dir:Int, up:Bool, sound:Bool = true):Void
	{
		isMovingUpward = up;
		selectedOptionIndex = (selectedOptionIndex + dir + TOTAL_OPTIONS) % TOTAL_OPTIONS;
		cooldownTimer = 0.1;
		
		if (sound) FlxG.sound.play(Paths.sound('scrollMenu'));
		
		refreshSelection();
		resetShadow();
	}

	function startBlink():Void
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		isBlinking = true;
		canInteract = false;
		blinkTimer = 0;
		blinkCount = 0;
	}

	function updateBlink(elapsed:Float):Void
	{
		if (!isBlinking) return;
		
		blinkTimer += elapsed;
		if (blinkTimer < 0.05) return;
		
		blinkTimer = 0;
		blinkCount++;
		
		final opt = menuOptions[selectedOptionIndex];
		final txt = menuTexts[selectedOptionIndex];
		
		opt.visible = !opt.visible;
		txt.visible = !txt.visible;
		
		if (shadowSprite != null) shadowSprite.visible = !shadowSprite.visible;

		if (blinkCount >= 16)
		{
			opt.visible = true;
			txt.visible = true;
			
			if (shadowSprite != null) shadowSprite.visible = true;
			
			isBlinking = false;
			blinkCount = 0;
			executeOption();
		}
	}

	function executeOption():Void
	{
		if (selectedOptionIndex != 4) FlxG.sound.music?.fadeOut(0.3);
		
		switch (selectedOptionIndex)
		{
			case 0: FlxG.switchState(() -> new states.SoundTest());
			case 1: FlxG.switchState(() -> new states.EXEFreeplay());
			case 2: FlxG.switchState(() -> new states.StoryModeState());
			case 3: FlxG.switchState(() -> new states.extras.ExtrasMenu());
			case 4: FlxG.switchState(() -> new options.OptionsState());
		}
	}

	function resetShadow():Void
	{
		shadowTimer = 0;
		shadowMoved = false;
		if (shadowSprite != null)
		{
			FlxTween.cancelTweensOf(shadowSprite);
			shadowSprite.alpha = 0;
		}
	}

	function updateShadow(elapsed:Float):Void
	{
		if (shadowMoved || shadowSprite == null) return;
		
		shadowTimer += elapsed;
		if (shadowTimer < 0.15) return;
		
		shadowMoved = true;
		shadowSprite.alpha = 1.0;
		
		FlxTween.tween(shadowSprite, {
			x: shadowSprite.x + 25,
			y: shadowSprite.y + 8
		}, 0.1, {ease: FlxEase.quintOut});
	}

	function refreshSelection():Void
	{
		final langFont = Language.getFontForLanguage();
		final cjkYOffset:Float = switch (langFont) {
			case 'chinese.ttf': 28;
			case 'japanese.ttf' | 'korean.ttf': 36;
			default: 0;
		};
		for (i in 0...TOTAL_OPTIONS)
		{
			final visualPos:Int = (i - selectedOptionIndex + CENTER_POSITION + TOTAL_OPTIONS) % TOTAL_OPTIONS;
			final prevVisualPos:Int = (i - previousSelectedIndex + CENTER_POSITION + TOTAL_OPTIONS) % TOTAL_OPTIONS;

			final option = menuOptions[i];
			final text = menuTexts[i];

			FlxTween.cancelTweensOf(option);
			FlxTween.cancelTweensOf(option.scale);
			FlxTween.cancelTweensOf(text);
			FlxTween.cancelTweensOf(text.scale);

			final scale = OPTION_SCALES[visualPos];
			final pos = OPTION_POSITIONS[visualPos];
			final alpha = OPTION_ALPHAS[visualPos];

			final textScale = TEXT_SCALES[visualPos];
			final rawPos = TEXT_POSITIONS[visualPos];
			final textPos = {x: rawPos.x, y: rawPos.y + cjkYOffset};
			
			if (visualPos == CENTER_POSITION && shadowSprite != null)
			{
				shadowSprite.scale.set(scale * 0.9, scale * 0.9);
				shadowSprite.updateHitbox();
				shadowSprite.x = pos.x + 535;
				shadowSprite.y = pos.y + 120;
			}

			final wrapping = (visualPos == 0 && prevVisualPos == 4) ||
			               (visualPos == 4 && prevVisualPos == 0) ||
			               (prevVisualPos == 0 && visualPos == 4) ||
			               (prevVisualPos == 4 && visualPos == 0);

			text.fieldWidth = 2000;

			if (wrapping)
			{
				final entering = (visualPos == 0 && isMovingUpward) || (visualPos == 4 && !isMovingUpward);
				final yOff:Float = (visualPos == 0) ? -80.0 : 80.0;

				if (entering)
				{
					option.alpha = 0;
					option.x = pos.x; 
					option.y = pos.y + yOff;
					option.scale.set(scale, scale);
					
					text.alpha = 0;
					text.x = textPos.x;
					text.y = textPos.y + yOff;
					text.scale.set(textScale, textScale);
					
					FlxTween.tween(option, {y: pos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(text, {y: textPos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				}
				else
				{
					option.x = pos.x; 
					option.y = pos.y;
					option.scale.set(scale, scale);
					
					text.x = textPos.x; 
					text.y = textPos.y;
					text.scale.set(textScale, textScale);
					
					FlxTween.tween(option, {y: pos.y + yOff, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(text, {y: textPos.y + yOff, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
				}
			}
			else
			{
				FlxTween.tween(option, {x: pos.x, y: pos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(option.scale, {x: scale, y: scale}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(text, {x: textPos.x, y: textPos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(text.scale, {x: textScale, y: textScale}, 0.45, {ease: FlxEase.quintOut});
			}
		}

		previousSelectedIndex = selectedOptionIndex;
	}

	function charToKeyName(char:String):String
	{
		return switch(char)
		{
			case "0": "ZERO";
			case "1": "ONE";
			case "2": "TWO";
			case "3": "THREE";
			case "4": "FOUR";
			case "5": "FIVE";
			case "6": "SIX";
			case "7": "SEVEN";
			case "8": "EIGHT";
			case "9": "NINE";
			default: char.toUpperCase();
		}
	}

	function correctCode(codeIndex:Int):Void
	{
		final code = secretCodes[codeIndex];

		switch(code) {
			case "personel":
				loadSong('personel', 'COLDSTEEL');
			case "2005":
				loadSong('b4cksl4sh', 'SL4SH');
		}

		FlxG.sound.play(Paths.sound('ringSound'));
		curKey[codeIndex] = 0;
	}

	function loadSong(song:String, mod:String):Bool
	{
		try
		{
			Mods.currentModDirectory = mod;

			Song.loadFromJson(Paths.formatToSongPath(song), Paths.formatToSongPath(song));

			PlayState.storyPlaylist = [song];
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 0;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;

			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.sound.music?.fadeOut(0.3);
		}
		catch (e:Dynamic)
		{
			trace("Error cargando cancion: " + e);
			return false;
		}
		return true;
	}

	override function destroy():Void
	{
		for (o in menuOptions ?? []) 
		{ 
			FlxTween.cancelTweensOf(o); 
			FlxTween.cancelTweensOf(o?.scale);
		}
		
		for (t in menuTexts ?? []) 
		{ 
			FlxTween.cancelTweensOf(t); 
			FlxTween.cancelTweensOf(t?.scale); 
		}
		
		if (shadowSprite != null)
			FlxTween.cancelTweensOf(shadowSprite);
			
		#if VIDEOS_ALLOWED
		menuVideo?.destroy();
		menuVideo = null;
		#end
		
		FlxG.autoPause = true;
		super.destroy();
	}
}