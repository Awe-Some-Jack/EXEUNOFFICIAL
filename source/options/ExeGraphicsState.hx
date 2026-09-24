package options;

import backend.Paths;
import backend.ClientPrefs;
import backend.Language;
import Main;

class ExeGraphicsState extends ExeBaseOptionsState
{
	var allOptions:Array<ExeBaseOptionsState.ExeGenericOption>;

	public static var curSelected:Int = 0;

	var holdTimer:Float = 0;
	var holdRepeat:Float = 0;

	override public function create()
	{
		curSelected = 0;
		scrollOffset = 0;

		menuTitle = Language.get('options.graphics', 'GRAPHICS');
		var lbl = Language.getArray('options.graphics.labels', ["POTATO MODE", "ANTI ALIASING", "GPU CACHING", "SHADERS", "UNCAPPED FPS", "FRAMERATE"]);
		allOptions = [
			{label: lbl[0], getValue: () -> ClientPrefs.data.lowQuality,  setValue: (v) -> ClientPrefs.data.lowQuality   = v},
			{label: lbl[1], getValue: () -> ClientPrefs.data.antialiasing, setValue: (v) -> ClientPrefs.data.antialiasing = v},
			{label: lbl[2], getValue: () -> ClientPrefs.data.cacheOnGPU,  setValue: (v) -> ClientPrefs.data.cacheOnGPU   = v},
			{label: lbl[3], getValue: () -> ClientPrefs.data.shaders,     setValue: (v) -> ClientPrefs.data.shaders      = v},
			{label: lbl[4], getValue: () -> ClientPrefs.data.uncappedFPS, setValue: (v) -> ClientPrefs.data.uncappedFPS  = v},
			{label: lbl[5], getValue: () -> ClientPrefs.data.framerate,   setValue: (v) -> ClientPrefs.data.framerate    = v, isInt: true},
		];

		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected - scrollOffset; }

	function formatValue(opt:ExeBaseOptionsState.ExeGenericOption):String
	{
		var val = opt.getValue();
		var on = Language.get('options.on', 'ON'); var off = Language.get('options.off', 'OFF');
		return Std.isOfType(val, Bool) ? (cast(val, Bool) ? on : off) : Std.string(val);
	}

	function getRowData(i:Int):ExeBaseOptionsState.ExeRowData
		return {label: allOptions[i].label, value: formatValue(allOptions[i])};

	override public function loadPage()
	{
		clearPage();
		titlebarTxt.text = menuTitle;

		buildVisibleRows(allOptions.length, getRowData);

		if (!introAnimating) changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (introAnimating || backLock) { backLock = false; return; }

		if (editingValue)
		{
			var isLeft  = (#if mobile (FlxG.mouse.overlaps(arrowLeft) && shortPress) || swipeLEFT || #end controls.UI_LEFT_P) || (controls.UI_LEFT && holdTimer > 0.4 && holdRepeat <= 0);
			var isRight = (#if mobile (FlxG.mouse.overlaps(arrowRight) && shortPress) || swipeRIGHT || #end controls.UI_RIGHT_P) || (controls.UI_RIGHT && holdTimer > 0.4 && holdRepeat <= 0);

			if (#if mobile (FlxG.mouse.overlaps(arrowLeft) || (FlxG.mouse.overlaps(arrowRight)) && pressHolding) || #end controls.UI_LEFT || controls.UI_RIGHT) holdTimer += elapsed; else holdTimer = 0;
			if (holdRepeat > 0) holdRepeat -= elapsed;

			if ((isLeft || isRight) #if mobile && cooldownTimer <= 0 #end)
			{
				#if mobile cooldownTimer = 0.1; #end
				if (#if mobile (FlxG.mouse.overlaps(arrowLeft) || FlxG.mouse.overlaps(arrowRight)) && pressHolding || #end controls.UI_LEFT_P || controls.UI_RIGHT_P) holdRepeat = 0; else holdRepeat = 0.07;
				var opt = allOptions[curSelected];
				var val = opt.getValue();
				var txt = optionGroups[curSelected - scrollOffset].valueText;

				if (Std.isOfType(val, Bool))
				{
					var b = !cast(val, Bool); opt.setValue(b);
					txt.text = b ? Language.get('options.on', 'ON') : Language.get('options.off', 'OFF');
				}
				else if (opt.isInt == true)
				{
					var n = cast(val, Int) + (isRight ? 1 : -1);
					n = isRight ? Std.int(Math.min(n, ClientPrefs.MAX_FRAMERATE)) : Std.int(Math.max(n, 30));
					opt.setValue(n); txt.text = Std.string(n);
				}
				ClientPrefs.saveSettings();

				var optIdx = allOptions.indexOf(opt);
				if (optIdx == 5) // FRAMERATE
				{
					if (!ClientPrefs.data.uncappedFPS)
					{
						if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
							FlxG.updateFramerate = ClientPrefs.data.framerate;
							FlxG.drawFramerate = ClientPrefs.data.framerate;
						} else {
							FlxG.drawFramerate = ClientPrefs.data.framerate;
							FlxG.updateFramerate = ClientPrefs.data.framerate;
						}
					}
				}
				else if (optIdx == 1) // ANTI ALIASING
					FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
				else if (optIdx == 4) // UNCAPPED FPS
				{
					if (ClientPrefs.data.uncappedFPS) {
						FlxG.drawFramerate = 0;
						FlxG.updateFramerate = 0;
					} else {
						if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
							FlxG.updateFramerate = ClientPrefs.data.framerate;
							FlxG.drawFramerate = ClientPrefs.data.framerate;
						} else {
							FlxG.drawFramerate = ClientPrefs.data.framerate;
							FlxG.updateFramerate = ClientPrefs.data.framerate;
						}
					}
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if ((controls.ACCEPT || controls.BACK) #if mobile || backPressed #end)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				editingValue = false; holdTimer = 0; holdRepeat = 0; backLock = true;
				hideArrows(); nudgeSelectedText(false);
			}
			return;
		}

		if ((controls.UI_UP_P || controls.UI_DOWN_P) #if mobile || (cooldownTimer <= 0 && (swipeUP || swipeDOWN)) #end)
		{
			var visibleCount = Std.int(Math.min(allOptions.length, ExeBaseOptionsState.MAX_VISIBLE_ROWS));
			var maxScroll = Std.int(Math.max(0, allOptions.length - visibleCount));
			scrollOffset = Std.int(Math.max(0, Math.min(scrollOffset, maxScroll)));
			curSelected = Std.int(Math.max(0, Math.min(curSelected, allOptions.length - 1)));

			var dir = (controls.UI_UP_P #if mobile || swipeUP #end) ? -1 : 1;
			var newSelected = curSelected + dir;

			if (newSelected >= 0 && newSelected <= allOptions.length - 1)
			{
				#if mobile cooldownTimer = 0.2; #end
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected = newSelected;
				hideArrows();

				if (newSelected < scrollOffset)
				{
					scrollOffset += dir;
					scrollList(dir, allOptions.length, getRowData);
				}
				else if (newSelected >= scrollOffset + visibleCount)
				{
					scrollOffset += dir;
					scrollList(dir, allOptions.length, getRowData);
				}
				else
				{
					changeSelection();
				}
			}
		}
		if (controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			editingValue = true; nudgeSelectedText(true);
			var g = optionGroups[curSelected - scrollOffset];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}
		if ((controls.BACK) #if mobile || backPressed #end) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}
