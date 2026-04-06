package states;

import openfl.Assets;
import objects.GifSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Exemenu extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';

	static inline final TOTAL_OPTIONS:Int   = 5;
	static inline final CENTER_POSITION:Int = 2;

	static final OPTION_TEXTS:Array<String> = ["SOUND TEST", "FREEPLAY", "STORY MODE", "EXTRAS", "OPTIONS"];

	static final OPTION_POSITIONS:Array<{x:Float, y:Float}> = [
		{x: 175.0, y: -60.0},
		{x: 110.0, y:  65.0},
		{x:  20.0, y: 220.0},
		{x: 110.0, y: 360.0},
		{x: 175.0, y: 480.0}
	];
	static final OPTION_SCALES:Array<Float>  = [0.25, 0.30, 0.37, 0.30, 0.25];
	static final OPTION_ALPHAS:Array<Float>  = [0.55, 0.80, 1.00, 0.80, 0.55];

	static final TEXT_POSITIONS:Array<{x:Float, y:Float}> = [
		{x:  32.0, y: -136.0},
		{x: -75.0, y:   94.0},
		{x: -310.0, y:  251.0},
		{x: -75.0, y:  389.0},
		{x:  32.0, y:  507.0}
	];

	static final TEXT_SCALES:Array<Float> = [0.245, 0.3, 0.330, 0.3, 0.245];


	var menuOptions:Array<FlxSprite> = [];
	var menuTexts:Array<FlxText>     = [];
	var shadowSprite:FlxSprite;

	public static var selectedOptionIndex:Int = 2;
	var previousSelectedIndex:Int = 2;
	var isMovingUpward:Bool       = false;

	var canInteract:Bool        = true;
	var cooldownTimer:Float     = 0.0;
	var isBlinking:Bool         = false;
	var blinkTimer:Float        = 0.0;
	var blinkCount:Int          = 0;
	var shadowTimer:Float       = 0.0;
	var shadowMoved:Bool        = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		super.create();
		persistentUpdate = true;
		persistentDraw   = true;

		var loopingMenu:GifSprite = new GifSprite();
		loopingMenu.loadGif('assets/exe/mainmenu/mainmenuexefinal.gif');
		loopingMenu.antialiasing = ClientPrefs.data.antialiasing;
		loopingMenu.setGraphicSize(FlxG.width, FlxG.height);
		loopingMenu.updateHitbox();
		loopingMenu.screenCenter();
		add(loopingMenu);

		shadowSprite = new FlxSprite();
		shadowSprite.loadGraphic(Assets.getBitmapData("assets/exe/mainmenu/options/shadow.png"));
		shadowSprite.updateHitbox();
		shadowSprite.alpha = 0;
		add(shadowSprite);

		for (i in 0...TOTAL_OPTIONS)
		{
			var option = new FlxSprite();
			option.loadGraphic(Assets.getBitmapData("assets/exe/mainmenu/options/box.png"));
			option.antialiasing = ClientPrefs.data.antialiasing;
			option.updateHitbox();
			option.ID = i;
			add(option);
			menuOptions.push(option);

			var optionText = new FlxText(0, 0, option.width * 2, OPTION_TEXTS[i]);
			optionText.setFormat("assets/fonts/sonicfree.otf", 280, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
			optionText.borderSize = 2;
			optionText.antialiasing = ClientPrefs.data.antialiasing;
			optionText.ID = i;
			add(optionText);
			menuTexts.push(optionText);
		}

		refreshSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateBlink(elapsed);

		if (cooldownTimer > 0) cooldownTimer -= elapsed;

		updateShadow(elapsed);

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
				FlxG.switchState(() -> new Exetitle());
			}
			else if (controls.ACCEPT)
				startBlink();
		}
	}

	function changeSelection(dir:Int, up:Bool):Void
	{
		isMovingUpward      = up;
		selectedOptionIndex = (selectedOptionIndex + dir + TOTAL_OPTIONS) % TOTAL_OPTIONS;
		cooldownTimer       = 0.1;
		FlxG.sound.play(Paths.sound('scrollMenu'));
		refreshSelection();
		resetShadow();
	}

	function startBlink():Void
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		isBlinking = true;
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

		var opt  = menuOptions[selectedOptionIndex];
		var txt  = menuTexts[selectedOptionIndex];
		opt.visible  = !opt.visible;
		txt.visible  = !txt.visible;
		if (shadowSprite != null) shadowSprite.visible = !shadowSprite.visible;

		if (blinkCount >= 16)
		{
			opt.visible  = true;
			txt.visible  = true;
			if (shadowSprite != null) shadowSprite.visible = true;
			isBlinking = false;
			blinkCount = 0;
			executeOption();
		}
	}

	function executeOption():Void
	{
		switch (selectedOptionIndex)
		{
			case 0: FlxG.switchState(() -> new states.SoundTest());
			case 1: FlxG.switchState(() -> new states.EXEFreeplay());
			case 2: FlxG.switchState(() -> new states.StoryModeState());
			case 3: isBlinking = false;
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
		shadowMoved        = true;
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
			var visualPos:Int     = (i - selectedOptionIndex + CENTER_POSITION + TOTAL_OPTIONS) % TOTAL_OPTIONS;
			var prevVisualPos:Int = (i - previousSelectedIndex + CENTER_POSITION + TOTAL_OPTIONS) % TOTAL_OPTIONS;

			var option = menuOptions[i];
			var text   = menuTexts[i];

			FlxTween.cancelTweensOf(option);
			FlxTween.cancelTweensOf(option.scale);
			FlxTween.cancelTweensOf(text);
			FlxTween.cancelTweensOf(text.scale);

			var scale     = OPTION_SCALES[visualPos];
			var pos       = OPTION_POSITIONS[visualPos];
			var alpha     = OPTION_ALPHAS[visualPos];
			var textScale = TEXT_SCALES[visualPos];
			var textPos   = TEXT_POSITIONS[visualPos];

			if (visualPos == CENTER_POSITION && shadowSprite != null)
			{
				shadowSprite.scale.set(scale * 0.9, scale * 0.9);
				shadowSprite.updateHitbox();
				shadowSprite.x = pos.x + 535;
				shadowSprite.y = pos.y + 120;
			}

			var wrapping = (visualPos == 0 && prevVisualPos == 4)
			            || (visualPos == 4 && prevVisualPos == 0)
			            || (prevVisualPos == 0 && visualPos == 4)
			            || (prevVisualPos == 4 && visualPos == 0);

			text.fieldWidth = 2000;

			if (wrapping)
			{
				var entering = (visualPos == 0 && isMovingUpward) || (visualPos == 4 && !isMovingUpward);
				var yOff:Float = (visualPos == 0) ? -80.0 : 80.0;

				if (entering)
				{
					option.alpha = 0;
					option.x = pos.x; option.y = pos.y + yOff;
					option.scale.set(scale, scale);
					text.alpha = 0;
					text.x = textPos.x; text.y = textPos.y + yOff;
					text.scale.set(textScale, textScale);
					FlxTween.tween(option, {y: pos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(text,   {y: textPos.y, alpha: alpha}, 0.45, {ease: FlxEase.quintOut});
				}
				else
				{
					option.x = pos.x; option.y = pos.y;
					option.scale.set(scale, scale);
					text.x = textPos.x; text.y = textPos.y;
					text.scale.set(textScale, textScale);
					FlxTween.tween(option, {y: pos.y + yOff, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
					FlxTween.tween(text,   {y: textPos.y + yOff, alpha: 0}, 0.45, {ease: FlxEase.quintOut});
				}
			}
			else
			{
				FlxTween.tween(option,       {x: pos.x, y: pos.y, alpha: alpha},             0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(option.scale, {x: scale, y: scale},                           0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(text,         {x: textPos.x, y: textPos.y, alpha: alpha},     0.45, {ease: FlxEase.quintOut});
				FlxTween.tween(text.scale,   {x: textScale, y: textScale},                   0.45, {ease: FlxEase.quintOut});
			}
		}

		previousSelectedIndex = selectedOptionIndex;
	}

	override function destroy():Void
	{
		if (menuOptions != null)
			for (o in menuOptions) { FlxTween.cancelTweensOf(o); FlxTween.cancelTweensOf(o.scale); }
		if (menuTexts != null)
			for (t in menuTexts)   { FlxTween.cancelTweensOf(t); FlxTween.cancelTweensOf(t.scale); }
		if (shadowSprite != null)
			FlxTween.cancelTweensOf(shadowSprite);
		super.destroy();
	}
}
