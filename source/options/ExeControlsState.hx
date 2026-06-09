package options;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;

import backend.ClientPrefs;
import backend.InputFormatter;

typedef ExeControlOption = {
	var label:String;
	var saveKey:String;
	var defaultKeys:Array<FlxKey>;
	var defaultGamepad:Array<FlxGamepadInputID>;
}

class ExeControlsState extends ExeBaseOptionsState
{
	var noteOptions:Array<ExeControlOption> = [
		{label: "LEFT",  saveKey: "note_left",  defaultKeys: [A, LEFT],  defaultGamepad: [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT]},
		{label: "DOWN",  saveKey: "note_down",  defaultKeys: [S, DOWN],  defaultGamepad: [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN]},
		{label: "UP",    saveKey: "note_up",    defaultKeys: [W, UP],    defaultGamepad: [DPAD_UP,    LEFT_STICK_DIGITAL_UP]},
		{label: "RIGHT", saveKey: "note_right", defaultKeys: [D, RIGHT], defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]},
	];
	var uiOptions:Array<ExeControlOption> = [
		{label: "UP",    saveKey: "ui_up",    defaultKeys: [W, UP],    defaultGamepad: [DPAD_UP,    LEFT_STICK_DIGITAL_UP]},
		{label: "DOWN",  saveKey: "ui_down",  defaultKeys: [S, DOWN],  defaultGamepad: [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN]},
		{label: "LEFT",  saveKey: "ui_left",  defaultKeys: [A, LEFT],  defaultGamepad: [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT]},
		{label: "RIGHT", saveKey: "ui_right", defaultKeys: [D, RIGHT], defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]},
	];
	var actionOptions:Array<ExeControlOption> = [
		{label: "ACCEPT", saveKey: "accept", defaultKeys: [SPACE, ENTER], defaultGamepad: [A, START]},
		{label: "BACK",   saveKey: "back",   defaultKeys: [ESCAPE],       defaultGamepad: [B]},
		{label: "PAUSE",  saveKey: "pause",  defaultKeys: [ENTER],        defaultGamepad: [START]},
		{label: "RESET",  saveKey: "reset",  defaultKeys: [R],            defaultGamepad: [BACK]},
	];

	var sections:Array<String> = ["NOTES", "UI", "ACTIONS"];
	public static var curSectionIdx:Int = 0;
	public static var curSelected:Int = 0;
	var onKeyboardMode:Bool = true;

	override public function create()
	{
		menuTitle = sections[curSectionIdx];
		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected; }

	function getKeyLabel(saveKey:String):String
	{
		var keys = ClientPrefs.keyBinds.get(saveKey);
		return InputFormatter.getKeyName(keys != null && keys.length > 0 ? keys[0] : NONE).toUpperCase();
	}

	override public function loadPage()
	{
		clearPage();
		var opts = switch (curSectionIdx) {
			case 1: uiOptions;
			case 2: actionOptions;
			default: noteOptions;
		};

		titlebarTxt.text = sections[curSectionIdx];
		var offRight:Float = FlxG.width + 200;

		for (i in 0...opts.length)
		{
			var opt = opts[i];
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
			nameTxt.x = introAnimating ? offRight : nameBG.x + 120;
			nameTxt.y = nameBG.y + (nameBG.height - nameTxt.height) / 2; nameTxt.scrollFactor.set(0, 0);
			add(nameTxt); rightGroup.push(cast nameTxt);

			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), getKeyLabel(opt.saveKey), ExeBaseOptionsState.FONT_SIZE);
			valueTxt.setFormat(Paths.font(ExeBaseOptionsState.FONT), ExeBaseOptionsState.FONT_SIZE, FlxColor.WHITE, CENTER);
			valueTxt.x = introAnimating ? offRight : valueBG.x + (valueBG.width - valueTxt.width) / 2;
			valueTxt.y = valueBG.y + (valueBG.height - valueTxt.height) / 2; valueTxt.scrollFactor.set(0, 0);
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
			var pressed:FlxKey = FlxG.keys.firstJustPressed();
			if (pressed != NONE)
			{
				if (pressed == FlxKey.ESCAPE) FlxG.sound.play(Paths.sound('cancelMenu'));
				else
				{
					var opts = switch (curSectionIdx) { case 1: uiOptions; case 2: actionOptions; default: noteOptions; };
					var saveKey = opts[curSelected].saveKey;
					ClientPrefs.keyBinds.set(saveKey, [pressed]);
					optionGroups[curSelected].valueText.text = InputFormatter.getKeyName(pressed).toUpperCase();
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				editingValue = false; backLock = true; nudgeSelectedText(false);
			}
			return;
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSectionIdx = FlxMath.wrap(curSectionIdx + (controls.UI_RIGHT_P ? 1 : -1), 0, sections.length - 1);
			curSelected = 0; loadPage();
		}
		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = FlxMath.wrap(curSelected + (controls.UI_UP_P ? -1 : 1), 0, optionGroups.length - 1);
			changeSelection();
		}
		if (controls.ACCEPT) { FlxG.sound.play(Paths.sound('scrollMenu')); editingValue = true; nudgeSelectedText(true); }
		if (controls.BACK) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}