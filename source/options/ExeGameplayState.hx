package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import backend.Paths;
import backend.ClientPrefs;
import backend.Language;

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
		menuTitle = Language.get('options.gameplay', 'GAMEPLAY');
		var lbl = Language.getArray('options.gameplay.labels', ["DOWNSCROLL", "GHOST TAPPING", "SICK WINDOW", "GOOD WINDOW", "BAD WINDOW", "SAFE FRAMES"]);
		allOptions = [
			{label: lbl[0], getValue: () -> ClientPrefs.data.downScroll,   setValue: (v) -> ClientPrefs.data.downScroll   = v},
			{label: lbl[1], getValue: () -> ClientPrefs.data.ghostTapping, setValue: (v) -> ClientPrefs.data.ghostTapping = v},
			{label: lbl[2], getValue: () -> ClientPrefs.data.sickWindow,   setValue: (v) -> ClientPrefs.data.sickWindow   = v, isFloat: true},
			{label: lbl[3], getValue: () -> ClientPrefs.data.goodWindow,   setValue: (v) -> ClientPrefs.data.goodWindow   = v, isFloat: true},
			{label: lbl[4], getValue: () -> ClientPrefs.data.badWindow,    setValue: (v) -> ClientPrefs.data.badWindow    = v, isFloat: true},
			{label: lbl[5], getValue: () -> ClientPrefs.data.safeFrames,   setValue: (v) -> ClientPrefs.data.safeFrames   = v, isFloat: true},
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

			var lblSize = Language.scaledFontSize(ExeBaseOptionsState.FONT_SIZE);
			var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), opt.label, lblSize);
			nameTxt.setFormat(Paths.font(ExeBaseOptionsState.getLangFont()), lblSize, FlxColor.WHITE, LEFT);
			nameTxt.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X + 120;
			nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2; nameTxt.scrollFactor.set(0, 0);
			add(nameTxt); rightGroup.push(cast nameTxt);

			var val = opt.getValue();
			var optIdx = allOptions.indexOf(opt);
			var valStr = "";
			var on = Language.get('options.on', 'ON'); var off = Language.get('options.off', 'OFF');

			if (Std.isOfType(val, Bool))
				valStr = (optIdx == 1) ? (cast(val, Bool) ? Language.get('options.ghosttapping.on', 'PUSSY') : Language.get('options.ghosttapping.off', 'OFF')) : (cast(val, Bool) ? on : off);
			else if (Std.isOfType(val, Float))
			{
				var suffix = (optIdx >= 2 && optIdx <= 5) ? "MS" : "";
				valStr = Std.string(Math.round(cast(val, Float) * 10) / 10) + suffix;
			}
			else valStr = Std.string(val);

			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), valStr, lblSize);
			valueTxt.setFormat(Paths.font(ExeBaseOptionsState.getLangFont()), lblSize, FlxColor.WHITE, CENTER);
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
				var optIdx = allOptions.indexOf(opt);

				if (Std.isOfType(val, Bool))
				{
					var b = !cast(val, Bool); opt.setValue(b);
					txt.text = (optIdx == 1) ? (b ? Language.get('options.ghosttapping.on', 'PUSSY') : Language.get('options.ghosttapping.off', 'OFF')) : (b ? Language.get('options.on', 'ON') : Language.get('options.off', 'OFF'));
				}
				else if (opt.isFloat == true)
				{
					var n = cast(val, Float);
					var step = 0.1; var mn = 0.0; var mx = 1.0;

					if (optIdx == 2)      { step = 0.5; mn = 15.0; mx = 45.0; }
					else if (optIdx == 3) { step = 1.0; mn = 15.0; mx = 90.0; }
					else if (optIdx == 4) { step = 1.5; mn = 15.0; mx = 135.0; }
					else if (optIdx == 5) { step = 0.1; mn = 2.0;  mx = 10.0; }

					n = Math.round((n + (isRight ? step : -step)) * 10) / 10;
					n = Math.max(mn, Math.min(mx, n));
					opt.setValue(n);

					var suffix = (optIdx >= 2 && optIdx <= 5) ? "MS" : "";
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
			editingValue = true; backLock = true; nudgeSelectedText(true);
			var g = optionGroups[curSelected];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}
		if (controls.BACK) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}