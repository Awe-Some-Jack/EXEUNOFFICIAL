package options;

import backend.Paths;
import backend.ClientPrefs;
import backend.Language;

class ExeGameplayState extends ExeBaseOptionsState
{
	var allOptions:Array<ExeBaseOptionsState.ExeGenericOption>;

	public static var curSelected:Int = 0;

	var holdTimer:Float = 0;
	var holdRepeat:Float = 0;
	var confirmReset:Bool = false;

	override public function create()
	{
		curSelected = 0;
		scrollOffset = 0;

		menuTitle = Language.get('options.gameplay', 'GAMEPLAY');
		var lbl = Language.getArray('options.gameplay.labels', ["DOWNSCROLL", "GHOST TAPPING", "SICK WINDOW", "GOOD WINDOW", "BAD WINDOW", "SAFE FRAMES", "STREAMED AUDIO", "RESET SAVE DATA"]);
		allOptions = [
			{label: lbl[0], getValue: () -> ClientPrefs.data.downScroll,   setValue: (v) -> ClientPrefs.data.downScroll   = v},
			{label: lbl[1], getValue: () -> ClientPrefs.data.ghostTapping, setValue: (v) -> ClientPrefs.data.ghostTapping = v},
			{label: lbl[2], getValue: () -> ClientPrefs.data.sickWindow,   setValue: (v) -> ClientPrefs.data.sickWindow   = v, isFloat: true},
			{label: lbl[3], getValue: () -> ClientPrefs.data.goodWindow,   setValue: (v) -> ClientPrefs.data.goodWindow   = v, isFloat: true},
			{label: lbl[4], getValue: () -> ClientPrefs.data.badWindow,    setValue: (v) -> ClientPrefs.data.badWindow    = v, isFloat: true},
			{label: lbl[5], getValue: () -> ClientPrefs.data.safeFrames,   setValue: (v) -> ClientPrefs.data.safeFrames   = v, isFloat: true},
			{label: lbl[6], getValue: () -> ClientPrefs.data.streamedAudio,   setValue: (v) -> ClientPrefs.data.streamedAudio   = v, isFloat: true},
			{label: lbl[7] ?? 'RESET SAVE DATA', getValue: () -> confirmReset ? Language.get('options.reset.confirm', 'ARE YOU SURE?') : Language.get('options.reset.select', 'SELECT'), setValue: (v) -> {}},
		];

		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected - scrollOffset; }

	function formatValue(opt:ExeBaseOptionsState.ExeGenericOption, optIdx:Int):String
	{
		var val = opt.getValue();
		if (optIdx == allOptions.length - 1) return Std.string(val);
		var on = Language.get('options.on', 'ON'); var off = Language.get('options.off', 'OFF');

		if (Std.isOfType(val, Bool))
			return (optIdx == 1) ? (cast(val, Bool) ? Language.get('options.ghosttapping.on', 'PUSSY') : Language.get('options.ghosttapping.off', 'OFF')) : (cast(val, Bool) ? on : off);
		else if (Std.isOfType(val, Float))
		{
			var suffix = (optIdx >= 2 && optIdx <= 4) ? "MS" : "";
			return Std.string(Math.round(cast(val, Float) * 10) / 10) + suffix;
		}
		return Std.string(val);
	}

	function getRowData(i:Int):ExeBaseOptionsState.ExeRowData
		return {label: allOptions[i].label, value: formatValue(allOptions[i], i)};

	override public function loadPage()
	{
		clearPage();
		titlebarTxt.text = menuTitle;

		buildVisibleRows(allOptions.length, getRowData);

		if (!introAnimating) changeSelection();
	}

	function refreshResetRow():Void
	{
		final row = allOptions.length - 1 - scrollOffset;
		if (row >= 0 && row < optionGroups.length)
			optionGroups[row].valueText.text = formatValue(allOptions[allOptions.length - 1], allOptions.length - 1);
	}

	function resetSaveData():Void
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		backLock = true;
		confirmReset = false;

		states.access.FatalAccess.resetForTesting();

		final songs:flixel.util.FlxSave = new flixel.util.FlxSave();
		songs.bind('savedSongs', backend.CoolUtil.getSavePath());
		songs.erase();
		songs.flush();

		FlxG.save.erase();
		FlxG.save.flush();

		backend.Highscore.weekScores.clear();
		backend.Highscore.songScores.clear();
		backend.Highscore.songRating.clear();
		states.StoryModeState.weekCompleted = new Map<String, Bool>();
		states.EXETitle.initialized = false;
		ClientPrefs.saveSettings();

		FlxG.sound.music?.stop();
		restartGame();
	}

	function restartGame():Void
	{
		#if (sys && !mobile && !switch)
		try
		{
			final exe:String = Sys.programPath();
			final dir:String = haxe.io.Path.directory(exe);
			#if windows
			new sys.io.Process('cmd', ['/c', 'start', '', '/D', dir, exe]);
			#else
			new sys.io.Process('sh', ['-c', "cd \"$0\" && nohup \"$1\" >/dev/null 2>&1 &", dir, exe]);
			#end
			Sys.exit(0);
		}
		catch (e:Dynamic) {}
		#end
		FlxG.resetGame();
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

					var suffix = (optIdx >= 2 && optIdx <= 4) ? "MS" : "";
					txt.text = Std.string(n) + suffix;
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
				if (confirmReset) { confirmReset = false; refreshResetRow(); }

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
			if (curSelected == allOptions.length - 1)
			{
				if (confirmReset) { resetSaveData(); return; }
				FlxG.sound.play(Paths.sound('scrollMenu'));
				confirmReset = true;
				refreshResetRow();
				return;
			}
			FlxG.sound.play(Paths.sound('scrollMenu'));
			editingValue = true; backLock = true; nudgeSelectedText(true);
			var g = optionGroups[curSelected - scrollOffset];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}
		if (controls.BACK #if mobile || backPressed #end) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}
