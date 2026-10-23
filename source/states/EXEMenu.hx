package states;

import backend.EXEAchievements;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.math.FlxMath;

import backend.Song;
import backend.Highscore;
import backend.WeekData;
import backend.Difficulty;
import backend.Language;

import states.EXEFreeplay;
import states.LoadingState;
import states.PlayState;

import shaders.ColorSwap;
import states.access.FatalAccess;
import states.access.FatalAccess.FatalScene;

@:allow(backend.BurningBot)
class EXEMenu extends MusicBeatState
{
	public static var selectedOptionIndex:Int = 2;
	static inline final TOTAL_OPTIONS:Int = 5;
	static inline final CENTER_POSITION:Int = 2;
	static inline final HB_NATIVE_W:Float = 1478.0;
	static inline final HB_NATIVE_H:Float = 231.0;

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

	var menuOptions:Array<FlxSprite> = [];
	var menuTexts:Array<FlxText> = [];
	var menuHitboxes:Array<FlxSprite> = [];
	var _cjkYOffset:Float = 0;
	var shadowSprite:FlxSprite;
	var previousSelectedIndex:Int = 2;
	var isMovingUpward:Bool = false;
	var canInteract:Bool = true;
	var _fatalScene:Null<FatalScene> = null;
	var _fatalTimer:Float = -1;
	var canManiaInteract:Bool = false;
	var cooldownTimer:Float = 0.0;
	var isBlinking:Bool = false;
	var blinkTimer:Float = 0.0;
	var blinkCount:Int = 0;
	var shadowTimer:Float = 0.0;
	var shadowMoved:Bool = false;

	public static var secretSong:Bool = false;
	final secretCodes:Array<String> = ['personel', '2005'];
	var curKey:Array<Int>;

	var heylookanemail:FlxSprite;

	#if VIDEOS_ALLOWED
	var menuVideo:VideoSprite;
	#end

	var unlocked:Array<String> = [];
	public static var inDevMode:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menu", null);
		#end

		#if VIDEOS_ALLOWED
		menuVideo = new VideoSprite();
		menuVideo.onFormat(() -> {
			menuVideo.setGraphicSize(FlxG.width, FlxG.height);
			menuVideo.screenCenter();
		});
		if (menuVideo.loadVideo('assets/exe/mainmenu/menu.mp4', [VideoSprite.ARG_LOOPING])) menuVideo.playDelayed();
		menuVideo.isStateAffected = false;
		add(menuVideo);
		#end

		shadowSprite = new FlxSprite();
		shadowSprite.loadGraphic(Paths.getBitmapData("assets/exe/mainmenu/options/shadow.webp"));
		shadowSprite.updateHitbox();
		shadowSprite.alpha = 0;
		add(shadowSprite);

		final translatedTexts = getOptionTexts();
		final boxBitmap = Paths.getBitmapData("assets/exe/mainmenu/options/box.webp");
		final menuFont = Language.needsCustomFont() ? Paths.font(Language.getFontForLanguage()) : Paths.font("SonicFont.ttf");
		final maxFontSize:Int = Language.needsCustomFont() ? 180 : 280;
		final minFontSize:Int = 40;

		for (i in 0...TOTAL_OPTIONS)
		{
			final option = new FlxSprite();
			option.loadGraphic(boxBitmap);
			option.updateHitbox();
			option.ID = i;
			add(option);
			menuOptions.push(option);

			var fontSize:Int = maxFontSize;
			final optionText = new FlxText(0, 0, 0, translatedTexts[i]);
			optionText.setFormat(menuFont, fontSize, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
			optionText.borderSize = 2;
			optionText.antialiasing = ClientPrefs.data.antialiasing;

			while (fontSize > minFontSize && optionText.textField.textWidth > HB_NATIVE_W - 80)
			{
				fontSize -= 2;
				optionText.size = fontSize;
			}

			optionText.fieldWidth = optionText.textField.textWidth + 4;
			optionText.ID = i;
			add(optionText);
			menuTexts.push(optionText);
		}

		final hitboxBitmap = Paths.getBitmapData("assets/exe/mainmenu/options/hitbox.webp");
		for (i in 0...TOTAL_OPTIONS)
		{
			final hitbox = new FlxSprite();
			hitbox.loadGraphic(hitboxBitmap);
			hitbox.updateHitbox();
			hitbox.visible = false;
			hitbox.ID = i;
			add(hitbox);
			menuHitboxes.push(hitbox);
		}

		if (!inDevMode)
		{
			var save:FlxSave = new FlxSave();
			save.bind('savedSongs', CoolUtil.getSavePath());
			unlocked = cast (save.data.songs ?? []);

			var colorSwap = new ColorSwap();
			colorSwap.saturation = -1;
			if (unlocked.length < 5)
			{
				menuOptions[0].shader = colorSwap.shader;
				menuTexts[0].color = 0xFFACACAC;
				menuOptions[3].shader = colorSwap.shader;
				menuTexts[3].color = 0xFFACACAC;
			}
			if (unlocked.length < 6) { menuOptions[1].shader = colorSwap.shader; menuTexts[1].color = 0xFFACACAC; }
		}
		else unlocked = ['f', 'u', 'c', 'k', 'y', 'o', 'u']; //fuck :)

		if (EXEFreeplay.maniaUnlock)
		{
			new FlxTimer().start(0.4, (_) -> maniaEmail());
			heylookanemail = new FlxSprite();
			heylookanemail.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/access/mania/Mail Box.webp'), 'assets/exe/access/mania/Mail Box.xml');
			heylookanemail.animation.addByPrefix('email', 'Mail', 24, false);
			heylookanemail.scale.set(0.5, 0.5);
			heylookanemail.alpha = 0;
			heylookanemail.setPosition(-480, -270);
			add(heylookanemail);
		}

		_cjkYOffset = switch (Language.getFontForLanguage()) {
			case 'chinese.ttf': -17;
			case 'japanese.ttf' | 'korean.ttf': -20;
			default: 0;
		};

		refreshSelection();
		changeSelection(0, false, false);

		curKey = [for (_ in secretCodes) 0];

		FlxG.mouse.visible = true;

		super.create();

		FatalAccess.startWatching();
		final fatalScene = FatalAccess.menuScene();
		if (fatalScene != null && FlxG.random.bool(fatalScene == TRANSMISSION ? 15 : 8))
		{
			_fatalScene = fatalScene;
			_fatalTimer = FlxG.random.float(4, 10);
		}

		#if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
	}

	function maniaEmail():Void
	{
		canInteract = false;
		heylookanemail.animation.play('email', true);
		heylookanemail.alpha = 1;
		new FlxTimer().start(2, (_) -> canManiaInteract = true);

		EXEAchievements.unlock('sega');
		EXEAchievements.save();
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
			FlxG.save.data.unlockManiaOnce = true;
			states.SoundTest.fromSoundTest = true;
			EXEFreeplay.maniaUnlock = false;
		});
	}

	// holding scroll feature
	var _holdRepeatTimer:Float = 0.0;
	var holdDelay:Float = 0.35;     
	var repeatInterval:Float = 0.08; 

	function updateScrollInput(elapsed:Float){
			var upJustPressed = controls.UI_UP_P;
			var downJustPressed = controls.UI_DOWN_P;
			var upPressed = controls.UI_UP;
			var downPressed = controls.UI_DOWN;

			if ((upJustPressed || downJustPressed) && cooldownTimer <= 0)
			{
				_holdRepeatTimer = 0.0;
				if (upJustPressed) changeSelection(-1, true);
				if (downJustPressed) changeSelection(1, false);
			}
			else if (upPressed || downPressed)
			{
				_holdRepeatTimer += elapsed;
				if (_holdRepeatTimer >= holdDelay)
				{
					_holdRepeatTimer -= repeatInterval;
					if (upPressed) changeSelection(-1, true);
					if (downPressed) changeSelection(1, false);
				}
			}
			else
			{
				_holdRepeatTimer = 0.0;
			}
	}

	var soundHold:Float = 0;
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (subState != null) return;

		if (_fatalTimer > 0 && canInteract)
		{
			_fatalTimer -= elapsed;
			if (_fatalTimer <= 0) _startFatalGlitch();
		}

		if (Main.DEVELOPMENT_BUILD){
			if (#if mobile shortPress && !inDevMode || #end FlxG.keys.justPressed.TAB && !inDevMode) { inDevMode = true; FlxG.resetState(); }

			if (FlxG.keys.justPressed.T) FlxG.switchState(() -> new states.CreditsRollState());
			if (FlxG.keys.justPressed.F && canInteract)
			{
				FatalAccess.resetForTesting();
				if (!FlxG.keys.pressed.SHIFT)
				{
					_fatalScene = TRANSMISSION;
					_startFatalGlitch();
				}
			}

		}

		soundHold += elapsed;

		updateBlink(elapsed);

		if (cooldownTimer > 0) cooldownTimer -= elapsed;

		updateShadow(elapsed);

		if (canManiaInteract && (controls.ACCEPT #if mobile || shortPress #end))
		{
			goToMania();
		}

		if (canInteract && !isBlinking)
		{
			if (backend.BurningBot.active)
			{
				backend.BurningBot.updateMenu(this, elapsed);
				return;
			}

			updateScrollInput(elapsed);

			if (controls.BACK #if mobile || backPressed #end)
			{
				canInteract = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new EXETitle());
			}
			else if (controls.ACCEPT)
				startBlink();
			final wheel = FlxG.mouse.deltaWheel.y;
			if (wheel != 0 && cooldownTimer <= 0)
				changeSelection(wheel > 0 ? -1 : 1, wheel > 0);
			#if mobile
			if(pressHolding && deltaMouseY != 0 && cooldownTimer <= 0)
				if(deltaMouseY > 5)
					changeSelection(-1, false);
				else if(deltaMouseY < -5)
					changeSelection(1, true);
			#end

			final centerHitbox = menuHitboxes[selectedOptionIndex];
			centerHitbox.updateHitbox();
			if (#if mobile !pressHolding && #end FlxG.mouse.justPressed && FlxG.mouse.overlaps(centerHitbox))
				startBlink();
		}

		if (unlocked.length < 5) return;
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
		cooldownTimer = #if !mobile 0.1 #else 0.15 #end;

		if (sound) FlxG.sound.play(Paths.sound('scrollMenu'));

		refreshSelection();
		resetShadow();
	}

	function startBlink():Void
	{
		if (unlocked.length < 5 && (selectedOptionIndex == 0 || selectedOptionIndex == 3))
		{
			if (soundHold > 0.5)
			{
				final optX = menuOptions[selectedOptionIndex].x;
				final txtX = menuTexts[selectedOptionIndex].x;
				FlxTween.num(0, 1, 0.25, {
					onComplete: _ -> {
						menuOptions[selectedOptionIndex].x = optX;
						menuTexts[selectedOptionIndex].x = txtX;
					}
				}, v -> {
					final offset = Math.sin(v * Math.PI * 8) * 8 * (1 - v);
					menuOptions[selectedOptionIndex].x = optX + offset;
					menuTexts[selectedOptionIndex].x = txtX + offset;
				});
				FlxG.sound.play(Paths.sound('denied'));
				FlxG.sound.play(Paths.sound('deniedMOMENT'), 0.7);
				soundHold = 0;
			}
			return;
		}

		if (unlocked.length < 6 && selectedOptionIndex == 1)
		{
			if (soundHold > 0.5)
			{
				final optX = menuOptions[selectedOptionIndex].x;
				final txtX = menuTexts[selectedOptionIndex].x;
				FlxTween.num(0, 1, 0.25, {
					onComplete: _ -> {
						menuOptions[selectedOptionIndex].x = optX;
						menuTexts[selectedOptionIndex].x = txtX;
					}
				}, v -> {
					final offset = Math.sin(v * Math.PI * 8) * 8 * (1 - v);
					menuOptions[selectedOptionIndex].x = optX + offset;
					menuTexts[selectedOptionIndex].x = txtX + offset;
				});
				FlxG.sound.play(Paths.sound('denied'));
				FlxG.sound.play(Paths.sound('deniedMOMENT'), 0.7);
				soundHold = 0;
			}
			return;
		}

		var soundKey:String = 'confirmMenu';
		if (selectedOptionIndex == 2){
			soundKey = 'confirmMenuCREEPY';
			FlxTween.color(menuTexts[selectedOptionIndex], 0.5, menuTexts[selectedOptionIndex].color, FlxColor.RED);
		}
		FlxG.sound.play(Paths.sound(soundKey));
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
			case 3:	FlxG.switchState(() -> new states.extras.ExtrasMenu());
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
		for (i in 0...TOTAL_OPTIONS)
		{
			final visualPos:Int = (i - selectedOptionIndex + CENTER_POSITION + TOTAL_OPTIONS) % TOTAL_OPTIONS;
			final prevVisualPos:Int = (i - previousSelectedIndex + CENTER_POSITION + TOTAL_OPTIONS) % TOTAL_OPTIONS;

			final option = menuOptions[i];
			final text = menuTexts[i];
			final hitbox = menuHitboxes[i];
			FlxTween.cancelTweensOf(option);
			FlxTween.cancelTweensOf(option.scale);
			FlxTween.cancelTweensOf(text);
			FlxTween.cancelTweensOf(text.scale);
			FlxTween.cancelTweensOf(hitbox);
			FlxTween.cancelTweensOf(hitbox.scale);

			final scale = OPTION_SCALES[visualPos];
			final pos = OPTION_POSITIONS[visualPos];
			final alpha = OPTION_ALPHAS[visualPos];

			final txtNW:Float = text.fieldWidth;
			final txtNH:Float = text.textField.textHeight;
			final textPos = {
				x: pos.x + 97.5 + (HB_NATIVE_W - txtNW) / 2,
				y: pos.y + 45.5 + (HB_NATIVE_H - txtNH) / 2 + 10 + _cjkYOffset
			};

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
					text.scale.set(scale, scale);

					hitbox.alpha = 0;
					hitbox.x = pos.x + 557.5;
					hitbox.y = pos.y + yOff + 119.5;
					hitbox.scale.set(scale, scale);

					FlxTween.tween(option, {y: pos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(text, {y: textPos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(hitbox, {y: pos.y + 119.5, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				}
				else
				{
					option.x = pos.x;
					option.y = pos.y;
					option.scale.set(scale, scale);

					text.x = textPos.x;
					text.y = textPos.y;
					text.scale.set(scale, scale);

					hitbox.x = pos.x + 557.5;
					hitbox.y = pos.y + 119.5;
					hitbox.scale.set(scale, scale);

					FlxTween.tween(option, {y: pos.y + yOff, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(text, {y: textPos.y + yOff, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(hitbox, {y: pos.y + yOff + 119.5, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
				}
			}
			else
			{
				FlxTween.tween(option, {x: pos.x, y: pos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(option.scale, {x: scale, y: scale}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(text, {x: textPos.x, y: textPos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(text.scale, {x: scale, y: scale}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(hitbox, {x: pos.x + 557.5, y: pos.y + 119.5, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(hitbox.scale, {x: scale, y: scale}, 0.45, {ease: FlxEase.quintOut});
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

	function _startFatalGlitch():Void
	{
		canInteract = false;
		FlxG.sound.play(Paths.sound('static'), 0.8);
		#if FLX_PITCH
		if (FlxG.sound.music != null) FlxTween.tween(FlxG.sound.music, {pitch: 0.6}, 1.2);
		#end
		final w = 640;
		final h = 190;
		final x = (FlxG.width - w) * 0.5;
		final y = (FlxG.height - h) * 0.5;
		final box = FatalAccess.glitchBox(w, h, x, y, 0);
		final label = FatalAccess.textSprite('A FATAL ERROR HAS OCCURRED', 15, Std.int((w - 40) / 2), false);
		final bar = FatalAccess.barHeight(0);
		label.setPosition(x + (w - label.width) * 0.5, y + bar + (h - bar - label.height) * 0.5);
		label.visible = false;
		for (spr in [box, label])
		{
			spr.scrollFactor.set();
			add(spr);
		}
		final scene = _fatalScene;
		new FlxTimer().start(0.35, _ -> label.visible = true);
		new FlxTimer().start(2.6, _ -> {
			FlxG.sound.music?.stop();
			flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
			flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(() -> new FatalAccess(scene));
		});
	}

	function loadSong(song:String, mod:String):Bool
	{
		try
		{
			Mods.currentModDirectory = mod;

			Song.loadFromJson(Paths.formatToSongPath(song), Paths.formatToSongPath(song));

			secretSong = true;
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

	override function onFocus():Void
	{
		super.onFocus();
		menuVideo?.resume();
	}

	override function destroy():Void
	{
		FlxG.mouse.visible = false;
		FlxG.autoPause = true;
		super.destroy();
	}
}
