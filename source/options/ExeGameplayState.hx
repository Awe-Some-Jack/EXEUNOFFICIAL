package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import backend.Paths;
import backend.ClientPrefs;

class ExeGameplayState extends ExeBaseOptionsState
{
	var allOptions:Array<ExeBaseOptionsState.ExeGenericOption>;
	var pageOptions:Array<Array<ExeBaseOptionsState.ExeGenericOption>> = [];

	public static var curSelected:Int = 0;
	public static var curPage:Int = 0;

	var holdTimer:Float = 0;
	var holdRepeat:Float = 0;

	override public function create()
	{
		menuTitle = "GAMEPLAY";
		allOptions = [
			{label: "DOWNSCROLL",  getValue: () -> ClientPrefs.data.downScroll,  setValue: (v) -> ClientPrefs.data.downScroll  = v},
			{label: "SICK WINDOW", getValue: () -> ClientPrefs.data.sickWindow,  setValue: (v) -> ClientPrefs.data.sickWindow  = v, isFloat: true},
			{label: "GOOD WINDOW", getValue: () -> ClientPrefs.data.goodWindow,  setValue: (v) -> ClientPrefs.data.goodWindow  = v, isFloat: true},
			{label: "BAD WINDOW",  getValue: () -> ClientPrefs.data.badWindow,   setValue: (v) -> ClientPrefs.data.badWindow   = v, isFloat: true},
			{label: "SAFE FRAMES", getValue: () -> ClientPrefs.data.safeFrames,  setValue: (v) -> ClientPrefs.data.safeFrames  = v, isFloat: true},
		];
		var i = 0;
		while (i < allOptions.length) { pageOptions.push(allOptions.slice(i, i + ExeBaseOptionsState.PAGE_SIZE)); i += ExeBaseOptionsState.PAGE_SIZE; }

		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected; }

	override public function loadPage()
	{
		clearPage();
		var page = pageOptions[curPage];
		titlebarTxt.text = menuTitle;
		var offRight:Float = FlxG.width + 200;

		for (i in 0...page.length)
		{
			var opt = page[i];
			var rowY = ExeBaseOptionsState.NB_Y + i * ExeBaseOptionsState.ROW_GAP;

			var nameBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			nameBG.scale.set(ExeBaseOptionsState.NB_SCALE_X, ExeBaseOptionsState.NB_SCALE_Y); nameBG.updateHitbox();
			nameBG.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X; nameBG.y = rowY; nameBG.scrollFactor.set(0, 0);
			add(nameBG); rightGroup.push(nameBG);

			var valueBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			valueBG.scale.set(ExeBaseOptionsState.VB_SCALE_X, ExeBaseOptionsState.VB_SCALE_Y); valueBG.updateHitbox();
			valueBG.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X; valueBG.y = rowY; valueBG.scrollFactor.set(0, 0);
			add(valueBG); rightGroup.push(valueBG);

			var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), opt.label, ExeBaseOptionsState.FONT_SIZE);
			nameTxt.setFormat(Paths.font(ExeBaseOptionsState.FONT), ExeBaseOptionsState.FONT_SIZE, FlxColor.WHITE, LEFT);
			nameTxt.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X + 120;
			nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2; nameTxt.scrollFactor.set(0, 0);
			add(nameTxt); rightGroup.push(cast nameTxt);

			var val = opt.getValue();
			var label = opt.label;
			var valStr = "";
			
			if (Std.isOfType(val, Bool)) valStr = cast(val, Bool) ? "ON" : "OFF";
			else if (Std.isOfType(val, Float))
			{
				var suffix = (label.indexOf("WINDOW") != -1 || label == "SAFE FRAMES") ? "MS" : "";
				valStr = Std.string(Math.round(cast(val, Float) * 10) / 10) + suffix;
			}
			else valStr = Std.string(val);

			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), valStr.toUpperCase(), ExeBaseOptionsState.FONT_SIZE);
			valueTxt.setFormat(Paths.font(ExeBaseOptionsState.FONT), ExeBaseOptionsState.FONT_SIZE, FlxColor.WHITE, CENTER);
			valueTxt.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X + (valueBG.width - valueTxt.width) / 2;
			valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2; valueTxt.scrollFactor.set(0, 0);
			add(valueTxt); rightGroup.push(cast valueTxt);

			optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});
		}

		if (!introAnimating) changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (introAnimating || backLock) { backLock = false; return; }

		if (editingValue)
		{
			var isLeft  = controls.UI_LEFT_P  || (controls.UI_LEFT  && holdTimer > 0.4 && holdRepeat <= 0);
			var isRight = controls.UI_RIGHT_P || (controls.UI_RIGHT && holdTimer > 0.4 && holdRepeat <= 0);

			if (controls.UI_LEFT || controls.UI_RIGHT) holdTimer += elapsed; else holdTimer = 0;
			if (holdRepeat > 0) holdRepeat -= elapsed;

			if (isLeft || isRight)
			{
				if (controls.UI_LEFT_P || controls.UI_RIGHT_P) holdRepeat = 0; else holdRepeat = 0.07;
				var opt = pageOptions[curPage][curSelected];
				var val = opt.getValue();
				var txt = optionGroups[curSelected].valueText;
				var label = opt.label;

				if (Std.isOfType(val, Bool))
				{
					var b = !cast(val, Bool); opt.setValue(b); txt.text = b ? "ON" : "OFF";
				}
				else if (opt.isFloat == true)
				{
					var n = cast(val, Float);
					var step = 0.1; var mn = 0.0; var mx = 1.0;
					
					if (label == "SICK WINDOW")      { step = 0.5; mn = 15.0; mx = 45.0; }
					else if (label == "GOOD WINDOW") { step = 1.0; mn = 15.0; mx = 90.0; }
					else if (label == "BAD WINDOW")  { step = 1.5; mn = 15.0; mx = 135.0; }
					else if (label == "SAFE FRAMES") { step = 0.1; mn = 2.0;  mx = 10.0; }
					
					n = Math.round((n + (isRight ? step : -step)) * 10) / 10;
					n = Math.max(mn, Math.min(mx, n));
					opt.setValue(n);
					
					var suffix = (label.indexOf("WINDOW") != -1 || label == "SAFE FRAMES") ? "MS" : "";
					txt.text = Std.string(n) + suffix;
				}
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				editingValue = false; holdTimer = 0; holdRepeat = 0; backLock = true;
				hideArrows(); nudgeSelectedText(false);
			}
			return;
		}

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = FlxMath.wrap(curSelected + (controls.UI_UP_P ? -1 : 1), 0, optionGroups.length - 1);
			hideArrows(); changeSelection();
		}
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			var isRight = controls.UI_RIGHT_P;
			if (isRight && curPage < pageOptions.length - 1) { curPage++; curSelected = 0; loadPage(); }
			else if (!isRight && curPage > 0) { curPage--; curSelected = 0; loadPage(); }
		}
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			editingValue = true; nudgeSelectedText(true);
			var g = optionGroups[curSelected];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}
		if (controls.BACK) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}