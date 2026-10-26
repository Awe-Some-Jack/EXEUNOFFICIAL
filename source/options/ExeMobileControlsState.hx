package options;

import backend.Paths;
import backend.ClientPrefs;
import backend.Language;
import Main;

class ExeMobileControlsState extends ExeBaseOptionsState
{
	var allOptions:Array<ExeBaseOptionsState.ExeGenericOption>;

	static final CONTROL_TYPES:Array<String> = ["psych", "base", "buttons", "mixed"];
	static final MIDDLESCROLL_TYPES:Array<String> = ["pc", "mobile"];
	var controlsIndex:Int = 0;

	public static var curSelected:Int = 0;

	var holdTimer:Float = 0;
	var holdRepeat:Float = 0;

	var controlTypeLabels:Array<String>;
	var middlescrollTypeLabels:Array<String>;
	var controlsTypeOption:ExeBaseOptionsState.ExeGenericOption;
	var middlescrollTypeOption:ExeBaseOptionsState.ExeGenericOption;

	override public function create()
	{
		curSelected = 0;
		scrollOffset = 0;

		menuTitle = Language.get('options.mobilecontrols', 'MOBILE CONTROLS');
		var lbl = Language.getArray('options.mobilecontrols.labels', ["NOTE SLIDE", "MIDDLESCROLL", "MOBILE OPPONENT NOTES", "CONTROLS TYPE", "MIDDLESCROLL TYPE", "DEFAULT HITBOX ALPHA", "PRESSED HITBOX ALPHA", "VISIBLE PAUSE BUTTON"]);
		controlTypeLabels = Language.getArray('controls_type.labels', ["PSYCH", "BASE", "BUTTONS", "D-PAD"]);
		middlescrollTypeLabels = Language.getArray('middlescroll_type.labels', ["PC", "MOBILE"]);
		controlsTypeOption = {label: lbl[3], getValue: () -> ClientPrefs.data.controlsType, setValue: (v) -> ClientPrefs.data.controlsType = v};
		middlescrollTypeOption = {label: lbl[4], getValue: () -> ClientPrefs.data.middlescrollType, setValue: (v) -> ClientPrefs.data.middlescrollType = v};
		allOptions = [
			{label: lbl[0], getValue: () -> ClientPrefs.data.slideMechanic,  setValue: (v) -> ClientPrefs.data.slideMechanic = v},
			{label: lbl[1], getValue: () -> ClientPrefs.data.middleScroll, setValue: (v) -> ClientPrefs.data.middleScroll = v},
			{label: lbl[2], getValue: () -> ClientPrefs.data.mobileOpponentNotes, setValue: (v) -> ClientPrefs.data.mobileOpponentNotes = v},
			controlsTypeOption,
			middlescrollTypeOption,
			{label: lbl[5], getValue: () -> ClientPrefs.data.defHitboxAlpha, setValue: (v) -> ClientPrefs.data.defHitboxAlpha = v, isFloat: true},
			{label: lbl[6], getValue: () -> ClientPrefs.data.pressHitboxAlpha, setValue: (v) -> ClientPrefs.data.pressHitboxAlpha = v, isFloat: true},
			{label: lbl[7], getValue: () -> ClientPrefs.data.visiblePauseButton, setValue: (v) -> ClientPrefs.data.visiblePauseButton = v},
			{label: lbl.length > 8 ? lbl[8] : 'D-PAD SCALE', getValue: () -> ClientPrefs.data.dpadScale, setValue: (v) -> ClientPrefs.data.dpadScale = v, isFloat: true, min: 0.5, max: 2, step: 0.05},
			{label: lbl.length > 9 ? lbl[9] : 'D-PAD ALPHA', getValue: () -> ClientPrefs.data.dpadAlpha, setValue: (v) -> ClientPrefs.data.dpadAlpha = v, isFloat: true, min: 0, max: 1, step: 0.05},
		];

		final saved = CONTROL_TYPES.indexOf(ClientPrefs.data.controlsType);
		controlsIndex = saved >= 0 ? saved : 0;

		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected - scrollOffset; }

	function getControlLabel(type:String):String
	{
		final idx = CONTROL_TYPES.indexOf(type);
		return (idx >= 0 && idx < controlTypeLabels.length) ? controlTypeLabels[idx] : type;
	}

	function getMiddlescrollLabel(type:String):String
	{
		final idx = MIDDLESCROLL_TYPES.indexOf(type);
		return (idx >= 0 && idx < middlescrollTypeLabels.length) ? middlescrollTypeLabels[idx] : type;
	}

	function formatValue(opt:ExeBaseOptionsState.ExeGenericOption):String
	{
		var val = opt.getValue();
		var on = Language.get('options.on', 'ON'); var off = Language.get('options.off', 'OFF');
		if (Std.isOfType(val, Bool)) return cast(val, Bool) ? on : off;
		if (opt == controlsTypeOption) return getControlLabel(cast(val, String));
		if (opt == middlescrollTypeOption) return getMiddlescrollLabel(cast(val, String));
		if (opt.isFloat == true) return Std.string(Math.round(cast(val, Float) * 100) / 100);
		return Std.string(val);
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
				controlsIndex = FlxMath.wrap(controlsIndex + (#if mobile (FlxG.mouse.overlaps(arrowRight) && shortPress) || swipeRIGHT || #end controls.UI_RIGHT_P ? 1 : -1), 0, CONTROL_TYPES.length - 1);
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
					n = isRight ? Std.int(Math.min(n, 240)) : Std.int(Math.max(n, 30));
					opt.setValue(n); txt.text = Std.string(n);
				}
				else if (opt == controlsTypeOption)
				{
					var newType = CONTROL_TYPES[controlsIndex];
					opt.setValue(newType); txt.text = getControlLabel(newType);
				}
				else if (opt == middlescrollTypeOption)
				{
					var idx = FlxMath.wrap(MIDDLESCROLL_TYPES.indexOf(cast(val, String)) + (isRight ? 1 : -1), 0, MIDDLESCROLL_TYPES.length - 1);
					var newType = MIDDLESCROLL_TYPES[idx];
					opt.setValue(newType); txt.text = getMiddlescrollLabel(newType);
				}
				else if (opt.isFloat == true)
				{
					final step:Float = opt.step != null ? opt.step : 0.01;
					final lo:Float = opt.min != null ? opt.min : 0.0;
					final hi:Float = opt.max != null ? opt.max : 1.0;
					var n = Math.round((cast(val, Float) + (isRight ? step : -step)) * 100) / 100;
					n = Math.max(lo, Math.min(hi, n));
					opt.setValue(n); txt.text = Std.string(n);
				}
				ClientPrefs.saveSettings();
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
		if (controls.BACK #if mobile || backPressed #end) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}
