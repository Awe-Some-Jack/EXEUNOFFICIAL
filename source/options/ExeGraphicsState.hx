package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import backend.Paths;
import backend.ClientPrefs;

class ExeGraphicsState extends ExeBaseOptionsState
{
	var allOptions:Array<ExeBaseOptionsState.ExeGenericOption>;
	var pageOptions:Array<Array<ExeBaseOptionsState.ExeGenericOption>> = [];

	public static var curSelected:Int = 0;
	public static var curPage:Int = 0;

	var holdTimer:Float = 0;
	var holdRepeat:Float = 0;

	override public function create()
	{
		menuTitle = "GRAPHICS";

		allOptions = [
			{label: "POTATO MODE",  getValue: () -> ClientPrefs.data.lowQuality,    setValue: (v) -> ClientPrefs.data.lowQuality   = v},
			{label: "ANTI ALIASING",getValue: () -> ClientPrefs.data.antialiasing,  setValue: (v) -> ClientPrefs.data.antialiasing = v},
			{label: "GPU CACHING",  getValue: () -> ClientPrefs.data.cacheOnGPU,    setValue: (v) -> ClientPrefs.data.cacheOnGPU   = v},
			{label: "SHADERS",      getValue: () -> ClientPrefs.data.shaders,       setValue: (v) -> ClientPrefs.data.shaders      = v},
			{label: "UNCAPPED FPS", getValue: () -> ClientPrefs.data.uncappedFPS,   setValue: (v) -> ClientPrefs.data.uncappedFPS  = v},
			{label: "FRAMERATE",    getValue: () -> ClientPrefs.data.framerate,     setValue: (v) -> ClientPrefs.data.framerate    = v, isInt: true}
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
			var valStr = Std.isOfType(val, Bool) ? (cast(val, Bool) ? "ON" : "OFF") : Std.string(val);
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

				if (Std.isOfType(val, Bool))
				{
					var b = !cast(val, Bool); opt.setValue(b); txt.text = b ? "ON" : "OFF";
				}
				else if (opt.isInt == true)
				{
					var n = cast(val, Int) + (isRight ? 1 : -1);
					n = isRight ? Std.int(Math.min(n, 240)) : Std.int(Math.max(n, 30));
					opt.setValue(n); txt.text = Std.string(n);
				}
				ClientPrefs.saveSettings();

				switch (opt.label)
				{
					case "FRAMERATE":
						if (!ClientPrefs.data.uncappedFPS)
						{
							if (ClientPrefs.data.framerate > FlxG.drawFramerate) { 
								FlxG.updateFramerate = ClientPrefs.data.framerate;
								FlxG.drawFramerate = ClientPrefs.data.framerate; 
							}
							else { 
								FlxG.drawFramerate = ClientPrefs.data.framerate; 
								FlxG.updateFramerate = ClientPrefs.data.framerate; 
							}
						}
					case "ANTI ALIASING": 
						FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
					case "UNCAPPED FPS":
						if (ClientPrefs.data.uncappedFPS)
						{
							FlxG.drawFramerate = 0;
							FlxG.updateFramerate = 0;
						}
						else
						{
							if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
								FlxG.updateFramerate = ClientPrefs.data.framerate;
								FlxG.drawFramerate = ClientPrefs.data.framerate;
							} else {
								FlxG.drawFramerate = ClientPrefs.data.framerate;
								FlxG.updateFramerate = ClientPrefs.data.framerate;
							}
						}
					default:
				}
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