package options;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;

import backend.ClientPrefs;
import backend.InputFormatter;
import backend.Language;

typedef ExeControlOption = {
	var label:String;
	var saveKey:String;
	var defaultKeys:Array<FlxKey>;
	var defaultGamepad:Array<FlxGamepadInputID>;
	var keyIndex:Int;
}

class ExeControlsState extends ExeBaseOptionsState
{
	var noteOptions:Array<ExeControlOption> = [
		{label: "LEFT",  saveKey: "note_left",  defaultKeys: [A, LEFT],  defaultGamepad: [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT], keyIndex: 0},
		{label: "DOWN",  saveKey: "note_down",  defaultKeys: [S, DOWN],  defaultGamepad: [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN], keyIndex: 0},
		{label: "UP",	 saveKey: "note_up",    defaultKeys: [W, UP],    defaultGamepad: [DPAD_UP,    LEFT_STICK_DIGITAL_UP], keyIndex: 0},
		{label: "RIGHT", saveKey: "note_right", defaultKeys: [D, RIGHT], defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT], keyIndex: 0}
	];
	var notesFlat:Array<ExeControlOption> = [];
	var uiOptions:Array<ExeControlOption> = [
		{label: "LEFT",  saveKey: "ui_left",  defaultKeys: [A, LEFT],  defaultGamepad: [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT], keyIndex: 0},
		{label: "DOWN",  saveKey: "ui_down",  defaultKeys: [S, DOWN],  defaultGamepad: [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN], keyIndex: 0},
		{label: "UP",	 saveKey: "ui_up",    defaultKeys: [W, UP],    defaultGamepad: [DPAD_UP,    LEFT_STICK_DIGITAL_UP], keyIndex: 0},
		{label: "RIGHT", saveKey: "ui_right", defaultKeys: [D, RIGHT], defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT], keyIndex: 0}
	];
	var actionOptions:Array<ExeControlOption> = [
		{label: "ACCEPT", saveKey: "accept", defaultKeys: [SPACE, ENTER], defaultGamepad: [A, START], keyIndex: 0},
		{label: "BACK",   saveKey: "back",   defaultKeys: [ESCAPE],       defaultGamepad: [B], keyIndex: 0},
		{label: "PAUSE",  saveKey: "pause",  defaultKeys: [ENTER],        defaultGamepad: [START], keyIndex: 0},
		{label: "RESET",  saveKey: "reset",  defaultKeys: [R],            defaultGamepad: [BACK], keyIndex: 0},
	];
	var dagardenOptions:Array<ExeControlOption> = [
		{label: "PLAY/PAUSE", saveKey: "dagarden_play",    defaultKeys: [P],         defaultGamepad: [A], keyIndex: 0},
		{label: "STOP",       saveKey: "dagarden_stop",    defaultKeys: [BACKSPACE],  defaultGamepad: [B], keyIndex: 0},
		{label: "REWIND",     saveKey: "dagarden_rewind",  defaultKeys: [Q],          defaultGamepad: [DPAD_LEFT], keyIndex: 0},
		{label: "FORWARD",    saveKey: "dagarden_forward", defaultKeys: [E],          defaultGamepad: [DPAD_RIGHT], keyIndex: 0},
	];
	var dagardenOptions2:Array<ExeControlOption> = [
		{label: "LOOP",       saveKey: "dagarden_loop",    defaultKeys: [L],          defaultGamepad: [DPAD_UP], keyIndex: 0},
		{label: "INST",       saveKey: "dagarden_vocals",  defaultKeys: [I],          defaultGamepad: [DPAD_DOWN], keyIndex: 0},
	];
	var dagardenFlat:Array<ExeControlOption> = [];

	var sections:Array<String> = [];
	public static var curSectionIdx:Int = 0;
	public static var curSelected:Int = 0;
	var onKeyboardMode:Bool = true;

	override public function create()
	{
		curSelected = 0;
		scrollOffset = 0;

		var lbl = Language.getArray('options.controls.labels', ["NOTES", "UI", "ACTIONS", "LEFT", "DOWN", "UP", "RIGHT", "ACCEPT", "BACK", "PAUSE", "RESET"]);
		var dag = Language.getArray('extras.dagarden', ["BY", "INST", "PLAY/PAUSE", "REWIND", "FORWARD", "STOP", "LOOP"]);
		sections = [lbl[0], lbl[1], lbl[2], "D.A GARDEN"];

		noteOptions[0].label = lbl[3]; noteOptions[1].label = lbl[4];
		noteOptions[2].label = lbl[5]; noteOptions[3].label = lbl[6];

		uiOptions[0].label = lbl[5]; uiOptions[1].label = lbl[4];
		uiOptions[2].label = lbl[3]; uiOptions[3].label = lbl[6];

		actionOptions[0].label = lbl[7]; actionOptions[1].label = lbl[8];
		actionOptions[2].label = lbl[9]; actionOptions[3].label = lbl[10];

		dagardenOptions[0].label = dag[2]; dagardenOptions[1].label = dag[5];
		dagardenOptions[2].label = dag[3]; dagardenOptions[3].label = dag[4];
		dagardenOptions2[0].label = dag[6]; dagardenOptions2[1].label = dag[1];

		for (opt in noteOptions)
			notesFlat.push({label: opt.label, saveKey: opt.saveKey, defaultKeys: opt.defaultKeys, defaultGamepad: opt.defaultGamepad, keyIndex: 0});
		for (opt in noteOptions)
			notesFlat.push({label: opt.label + " 2", saveKey: opt.saveKey, defaultKeys: opt.defaultKeys, defaultGamepad: opt.defaultGamepad, keyIndex: 1});

		dagardenFlat = dagardenOptions.concat(dagardenOptions2);

		menuTitle = sections[curSectionIdx];
		super.create();
	}

	function changeSection(dir:Int):Void
	{
		if (introAnimating || backLock || editingValue) return;

		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSectionIdx = FlxMath.wrap(curSectionIdx + dir, 0, sections.length - 1);
		curSelected = 0;
		scrollOffset = 0;
		loadPage();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected - scrollOffset; }

	function getKeyLabel(saveKey:String, keyIndex:Int = 0):String
	{
		var keys = ClientPrefs.keyBinds.get(saveKey);
		return InputFormatter.getKeyName(keys != null && keys.length > keyIndex ? keys[keyIndex] : NONE).toUpperCase();
	}

	function getOptsForSection(sectionIdx:Int):Array<ExeControlOption>
	{
		return switch (sectionIdx) {
			case 1: uiOptions;
			case 2: actionOptions;
			case 3: dagardenFlat;
			default: notesFlat;
		};
	}

	function getRowData(i:Int):ExeBaseOptionsState.ExeRowData
	{
		var opts = getOptsForSection(curSectionIdx);
		return {label: opts[i].label, value: getKeyLabel(opts[i].saveKey, opts[i].keyIndex)};
	}

	override public function loadPage()
	{
		clearPage();
		var opts = getOptsForSection(curSectionIdx);
		titlebarTxt.text = sections[curSectionIdx];

		buildVisibleRows(opts.length, getRowData, ExeBaseOptionsState.FONT, ExeBaseOptionsState.FONT_SIZE);

		if (!introAnimating) changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (introAnimating || backLock) { backLock = false; return; }

		if (editingValue)
		{
			var pressed:FlxKey = FlxG.keys.firstJustPressed();
			if (pressed != NONE)
			{
				if (pressed == FlxKey.ESCAPE) FlxG.sound.play(Paths.sound('cancelMenu'));
				else
				{
					var opts = getOptsForSection(curSectionIdx);
					var opt = opts[curSelected];

					var current = ClientPrefs.keyBinds.get(opt.saveKey);
					current = current != null ? current.copy() : [];
					while (current.length <= opt.keyIndex) current.push(NONE);
					current[opt.keyIndex] = pressed;

					ClientPrefs.keyBinds.set(opt.saveKey, current);
					optionGroups[curSelected - scrollOffset].valueText.text = InputFormatter.getKeyName(pressed).toUpperCase();
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				editingValue = false; backLock = true; nudgeSelectedText(false);
			}
			return;
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			changeSection(controls.UI_RIGHT_P ? 1 : -1);
		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			var opts = getOptsForSection(curSectionIdx);
			var visibleCount = Std.int(Math.min(opts.length, ExeBaseOptionsState.MAX_VISIBLE_ROWS));
			var maxScroll = Std.int(Math.max(0, opts.length - visibleCount));
			scrollOffset = Std.int(Math.max(0, Math.min(scrollOffset, maxScroll)));
			curSelected = Std.int(Math.max(0, Math.min(curSelected, opts.length - 1)));

			var dir = controls.UI_UP_P ? -1 : 1;
			var newSelected = curSelected + dir;

			if (newSelected >= 0 && newSelected <= opts.length - 1)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected = newSelected;

				if (newSelected < scrollOffset)
				{
					scrollOffset += dir;
					scrollList(dir, opts.length, getRowData, ExeBaseOptionsState.FONT, ExeBaseOptionsState.FONT_SIZE);
				}
				else if (newSelected >= scrollOffset + visibleCount)
				{
					scrollOffset += dir;
					scrollList(dir, opts.length, getRowData, ExeBaseOptionsState.FONT, ExeBaseOptionsState.FONT_SIZE);
				}
				else
				{
					changeSelection();
				}
			}
		}
		if (controls.ACCEPT) { FlxG.sound.play(Paths.sound('scrollMenu')); editingValue = true; nudgeSelectedText(true); }
		if (controls.BACK #if mobile || backPressed #end) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}