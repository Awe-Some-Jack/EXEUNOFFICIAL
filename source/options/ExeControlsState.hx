package options;

import flixel.FlxObject;
import flixel.addons.display.FlxRuntimeShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Assets;

import backend.InputFormatter;

typedef ExeControlOption = {
	var label:String;
	var saveKey:String;
	var defaultKeys:Array<FlxKey>;
	var defaultGamepad:Array<FlxGamepadInputID>;
	@:optional var isCategory:Bool;
}

class ExeControlsState extends MusicBeatState
{
	var bg:FlxSprite;
	var objsGrp:FlxTypedGroup<FlxSprite>;
	var title:FlxSprite;

	var sectionsList:Array<ExeControlOption> = [];

	var sectionsGrp:FlxTypedGroup<FlxText>;
	var sectionBGGrp:FlxTypedGroup<FlxSprite>;
	var propertieTxtGrp:FlxTypedGroup<FlxText>;
	var propertiesBG:FlxTypedGroup<FlxSprite>;
	var propertieArrows:FlxTypedGroup<FlxSprite>;
	var sectionBGClone:FlxSprite;
	var propertieBGClone:FlxSprite;
	var selectionTween:FlxTween;
	var sectionPos:Array<Dynamic> = [];
	var propertiesPos:Array<Dynamic> = [];
	var propBGCloneShader:FlxRuntimeShader;

	public static var curSelected:Int = 0;
	var onKeyboardMode:Bool = true;

	var canAction:Bool = true;
	var binding:Bool = false;
	var holdingEsc:Float = 0;

	var bindingText:FlxText;
	var bindingBg:FlxSprite;

	final GLOBAL_SCALE:Float = (FlxG.width / 3840);

	var currentColumn:Int = 0;
	var currentRow:Int = 0;
	var categoryRowInColumn:Int = 0;
	var optionID:Int = -1;
	var currentStartX:Float = 0;
	var currentStartY:Float = 0;

	override public function create()
	{
		super.create();

		sectionsList = [
			{label: "NOTES",   saveKey: "", defaultKeys: [], defaultGamepad: [], isCategory: true},
			{label: "LEFT",    saveKey: "note_left",  defaultKeys: [A, LEFT],    defaultGamepad: [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]},
			{label: "DOWN",    saveKey: "note_down",  defaultKeys: [S, DOWN],    defaultGamepad: [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]},
			{label: "UP",      saveKey: "note_up",    defaultKeys: [W, UP],      defaultGamepad: [DPAD_UP, LEFT_STICK_DIGITAL_UP]},
			{label: "RIGHT",   saveKey: "note_right", defaultKeys: [D, RIGHT],   defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]},
			{label: "UI",      saveKey: "", defaultKeys: [], defaultGamepad: [], isCategory: true},
			{label: "LEFT",    saveKey: "ui_left",    defaultKeys: [A, LEFT],    defaultGamepad: [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]},
			{label: "DOWN",    saveKey: "ui_down",    defaultKeys: [S, DOWN],    defaultGamepad: [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]},
			{label: "UP",      saveKey: "ui_up",      defaultKeys: [W, UP],      defaultGamepad: [DPAD_UP, LEFT_STICK_DIGITAL_UP]},
			{label: "RIGHT",   saveKey: "ui_right",   defaultKeys: [D, RIGHT],   defaultGamepad: [DPAD_RIGHT, RIGHT_STICK_DIGITAL_RIGHT]},
			{label: "ACTIONS", saveKey: "", defaultKeys: [], defaultGamepad: [], isCategory: true},
			{label: "ACCEPT",  saveKey: "accept",     defaultKeys: [SPACE, ENTER],   defaultGamepad: [A, START]},
			{label: "BACK",    saveKey: "back",       defaultKeys: [BACKSPACE, ESCAPE], defaultGamepad: [B, BACK]},
			{label: "PAUSE",   saveKey: "pause",      defaultKeys: [ENTER, ESCAPE],  defaultGamepad: [START]},
			{label: "RESET",   saveKey: "reset",      defaultKeys: [R],              defaultGamepad: [RIGHT_SHOULDER]}
		];

		buildUI();
	}

	function buildUI()
	{
		bg = new FlxSprite(-100, -100).loadGraphic(Assets.getBitmapData('assets/exe/options/bg.png'));
		bg.setGraphicSize(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0.1, 0.1);
		add(bg);

		objsGrp = new FlxTypedGroup<FlxSprite>();
		add(objsGrp);

		for (i in 0...15)
		{
			var obj = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/objs/' + ((i % 7) + 1) + '.png'));
			obj.setGraphicSize(Std.int(obj.width * GLOBAL_SCALE));
			obj.updateHitbox();
			obj.ID = i;
			obj.antialiasing = ClientPrefs.data.antialiasing;
			objsGrp.add(obj);
			resetObj(obj);
		}

		title = new FlxSprite(0, 20).loadGraphic(Assets.getBitmapData('assets/exe/options/optionsTitle.png'));
		title.setGraphicSize(Std.int(title.width * GLOBAL_SCALE));
		title.updateHitbox();
		title.screenCenter(X);
		title.antialiasing = ClientPrefs.data.antialiasing;
		add(title);

		sectionBGClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionsBG.png'));
		sectionBGClone.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		sectionBGClone.updateHitbox();
		add(sectionBGClone);

		#if !html5
		if (ClientPrefs.data.shaders)
		{
			try
			{
				var shaderPath = Paths.shaderFragment('adjustColor');
				if (Assets.exists(shaderPath))
				{
					propBGCloneShader = new FlxRuntimeShader(Assets.getText(shaderPath));
					propBGCloneShader.setFloat("hue", 0);
					propBGCloneShader.setFloat("brightness", 100);
					propBGCloneShader.setFloat("contrast", 100);
					propBGCloneShader.setFloat("saturation", 100);
					sectionBGClone.shader = propBGCloneShader;
				}
			}
			catch (e:Dynamic) { trace("Shader error: " + e); }
		}
		#end

		propertieBGClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		propertieBGClone.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		propertieBGClone.updateHitbox();
		add(propertieBGClone);

		#if !html5
		if (ClientPrefs.data.shaders && propBGCloneShader != null)
			propertieBGClone.shader = propBGCloneShader;
		#end

		sectionBGGrp = new FlxTypedGroup<FlxSprite>();
		add(sectionBGGrp);
		sectionsGrp = new FlxTypedGroup<FlxText>();
		add(sectionsGrp);
		propertiesBG = new FlxTypedGroup<FlxSprite>();
		add(propertiesBG);
		propertieArrows = new FlxTypedGroup<FlxSprite>();
		add(propertieArrows);
		propertieTxtGrp = new FlxTypedGroup<FlxText>();
		add(propertieTxtGrp);

		for (i in 0...sectionsList.length)
		{
			if (sectionsList[i].label == "NOTES")
			{
				currentColumn = 0;
				currentRow = 0;
				currentStartX = FlxG.width * 0.18;
				currentStartY = title.y + 80;
			}
			else if (sectionsList[i].label == "UI")
			{
				currentColumn = 1;
				currentRow = 0;
				currentStartX = FlxG.width * 0.38;
				currentStartY = title.y + 220;
			}
			else if (sectionsList[i].label == "ACTIONS")
			{
				currentColumn = 2;
				currentRow = 0;
				currentStartX = FlxG.width * 0.62;
				currentStartY = title.y + 80;
			}

			if (sectionsList[i].isCategory == true)
				addCategory(sectionsList[i].label);
			else
				addOption(sectionsList[i].label, sectionsList[i].saveKey);
		}

		for (i in 0...sectionsList.length)
		{
			if (sectionsList[i].isCategory != true)
			{
				curSelected = i;
				break;
			}
		}

		changeSelect();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		objsGrp.forEachExists(function(o)
		{
			if (o.y > FlxG.height || o.x > FlxG.width || o.y < -o.height || o.x < -o.width)
				resetObj(o);
		});

		sectionsGrp.forEachExists(function(txt)
		{
			if (sectionPos.length > 0 && txt.ID < sectionPos.length)
			{
				if (txt.ID != curSelected)
				{
					txt.x = FlxMath.lerp(txt.x, sectionPos[txt.ID].x, elapsed * 9);
					txt.y = FlxMath.lerp(txt.y, sectionPos[txt.ID].y, elapsed * 9);
				}
				if (txt.ID < sectionBGGrp.members.length && sectionBGGrp.members[txt.ID] != null)
				{
					var sep = 14;
					var bg = sectionBGGrp.members[txt.ID];
					var sectionWidth = 24 * sectionsList[txt.ID].label.length;
					bg.x = txt.x + ((sectionWidth - bg.width) / 2) - 20;
					bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
				}
			}
		});

		propertieTxtGrp.forEachExists(function(txt)
		{
			if (propertiesPos.length > 0 && txt.ID < propertiesPos.length)
			{
				if (txt.ID != curSelected)
				{
					txt.x = FlxMath.lerp(txt.x, propertiesPos[txt.ID].x, elapsed * 9);
					txt.y = FlxMath.lerp(txt.y, propertiesPos[txt.ID].y, elapsed * 9);
				}
				if (txt.ID < propertiesBG.members.length && propertiesBG.members[txt.ID] != null)
				{
					var sep = 14;
					var bg = propertiesBG.members[txt.ID];
					var propSectionWidth = 20 * txt.text.length;
					bg.x = txt.x + ((propSectionWidth - bg.width) / 2);
					bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
					if (txt.ID < propertieArrows.members.length && propertieArrows.members[txt.ID] != null)
					{
						var arrows = propertieArrows.members[txt.ID];
						arrows.x = bg.x;
						arrows.y = bg.y;
					}
				}
			}
		});

		if (binding)
		{
			bindingUpdate(elapsed);
			return;
		}

		if (!canAction) return;

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			var change = controls.UI_UP_P ? -1 : 1;
			do {
				curSelected = FlxMath.wrap(curSelected + change, 0, sectionsList.length - 1);
			} while (sectionsList[curSelected].isCategory == true);
			changeSelect();
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			startBinding();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new options.OptionsState());
		}
	}

	function startBinding()
	{
		if (sectionsList[curSelected].isCategory == true) return;

		binding = true;
		holdingEsc = 0;

		bindingBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bindingBg.alpha = 0.7;
		add(bindingBg);

		bindingText = new FlxText(0, FlxG.height / 2 - 50, FlxG.width, "Press a key...\nHold ESC to cancel\nHold BACKSPACE to clear", 32);
		bindingText.setFormat(Paths.font("SonicCD.ttf"), 28, FlxColor.WHITE, CENTER);
		add(bindingText);

		ClientPrefs.toggleVolumeKeys(false);
	}

	function bindingUpdate(elapsed:Float)
	{
		if (FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
		{
			holdingEsc += elapsed;
			if (holdingEsc > 0.5)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
		{
			holdingEsc += elapsed;
			if (holdingEsc > 0.5)
			{
				var option = sectionsList[curSelected];
				if (onKeyboardMode)
					ClientPrefs.keyBinds.get(option.saveKey)[0] = NONE;
				else
					ClientPrefs.gamepadBinds.get(option.saveKey)[0] = NONE;
				ClientPrefs.clearInvalidKeys(option.saveKey);
				updatePropertyText(curSelected);
				FlxG.sound.play(Paths.sound('cancelMenu'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed = false;
			var option = sectionsList[curSelected];
			var curKeys = ClientPrefs.keyBinds.get(option.saveKey);
			var curButtons = ClientPrefs.gamepadBinds.get(option.saveKey);

			if (onKeyboardMode)
			{
				if (FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
				{
					var keyPressed = FlxG.keys.firstJustPressed();
					var keyReleased = FlxG.keys.firstJustReleased();
					if (keyPressed > -1 && keyPressed != FlxKey.ESCAPE && keyPressed != FlxKey.BACKSPACE)
					{
						curKeys[0] = keyPressed;
						changed = true;
					}
					else if (keyReleased > -1 && (keyReleased == FlxKey.ESCAPE || keyReleased == FlxKey.BACKSPACE))
					{
						curKeys[0] = keyReleased;
						changed = true;
					}
				}
			}
			else if (FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
			{
				var keyPressed:Null<FlxGamepadInputID> = NONE;
				var keyReleased:Null<FlxGamepadInputID> = NONE;
				if (FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)) keyPressed = LEFT_TRIGGER;
				else if (FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)) keyPressed = RIGHT_TRIGGER;
				else
				{
					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if (gamepad != null)
						{
							keyPressed = gamepad.firstJustPressedID();
							keyReleased = gamepad.firstJustReleasedID();
							if (keyPressed == null) keyPressed = NONE;
							if (keyReleased == null) keyReleased = NONE;
							if (keyPressed != NONE || keyReleased != NONE) break;
						}
					}
				}

				if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
				{
					curButtons[0] = keyPressed;
					changed = true;
				}
				else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
				{
					curButtons[0] = keyReleased;
					changed = true;
				}
			}

			if (changed)
			{
				ClientPrefs.clearInvalidKeys(option.saveKey);
				updatePropertyText(curSelected);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				closeBinding();
			}
		}
	}

	function closeBinding()
	{
		binding = false;
		if (bindingBg != null) { remove(bindingBg); bindingBg.destroy(); bindingBg = null; }
		if (bindingText != null) { remove(bindingText); bindingText.destroy(); bindingText = null; }
		ClientPrefs.toggleVolumeKeys(true);
		ClientPrefs.reloadVolumeKeys();
	}

	var selectionCloneTween:FlxTween;
	var propTween:FlxTween;
	var propArrowTween:FlxTween;
	var propCloneTween:FlxTween;

	function changeSelect(x:Int = 0)
	{
		if (curSelected >= sectionBGGrp.members.length || sectionBGGrp.members[curSelected] == null) return;

		for (i in 0...sectionsList.length)
		{
			if (sectionsList[i].isCategory != true)
				updatePropertyText(i);
		}

		var curSectionBG = sectionBGGrp.members[curSelected];
		var curSectionText = sectionsGrp.members[curSelected];
		var currentPos = sectionPos[curSelected];

		sectionBGClone.setPosition(curSectionBG.x - 3, curSectionBG.y - 3);
		curSectionBG.x -= 8; curSectionBG.y -= 8;
		curSectionText.x -= 8; curSectionText.y -= 8;

		if (selectionTween != null) selectionTween.cancel();
		selectionTween = FlxTween.tween(curSectionText, {x: currentPos.x - 12, y: currentPos.y - 16}, 0.18, {ease: FlxEase.quadInOut, onComplete: (_) -> selectionTween = null});

		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(sectionBGClone, {x: curSectionBG.x + 13, y: curSectionBG.y + 13}, 0.2, {ease: FlxEase.quadInOut, onComplete: (_) -> selectionCloneTween = null});

		if (sectionsList[curSelected].isCategory == true) return;
		if (curSelected >= propertieTxtGrp.members.length || propertieTxtGrp.members[curSelected] == null) return;
		if (curSelected >= propertiesBG.members.length || propertiesBG.members[curSelected] == null) return;
		if (curSelected >= propertieArrows.members.length || propertieArrows.members[curSelected] == null) return;

		var curPropertieBG = propertiesBG.members[curSelected];
		var curPropertieTxt = propertieTxtGrp.members[curSelected];
		var curPropertieArrows = propertieArrows.members[curSelected];
		var currentPropPos = propertiesPos[curSelected];

		propertieBGClone.setPosition(curPropertieBG.x - 3, curPropertieBG.y - 3);
		curPropertieBG.x -= 8; curPropertieBG.y -= 8;
		curPropertieTxt.x -= 8; curPropertieTxt.y -= 8;

		if (propTween != null) propTween.cancel();
		propTween = FlxTween.tween(curPropertieTxt, {x: currentPropPos.x - 12, y: currentPropPos.y - 16}, 0.18, {ease: FlxEase.quadInOut, onComplete: (_) -> propTween = null});

		if (propArrowTween != null) propArrowTween.cancel();
		propArrowTween = FlxTween.tween(curPropertieArrows, {x: currentPropPos.x - 12, y: currentPropPos.y - 16}, 0.18, {ease: FlxEase.quadInOut, onComplete: (_) -> propArrowTween = null});

		if (propCloneTween != null) propCloneTween.cancel();
		propCloneTween = FlxTween.tween(propertieBGClone, {x: curPropertieBG.x + 13, y: curPropertieBG.y + 13}, 0.2, {ease: FlxEase.quadInOut, onComplete: (_) -> propCloneTween = null});
	}

	function addCategory(label:String)
	{
		optionID++;
		currentRow = categoryRowInColumn;

		var section = new FlxText(0, 0, 0, label, 50);
		section.setFormat(Paths.font("SonicCD.ttf"), 16, FlxColor.YELLOW, LEFT);
		section.ID = optionID;
		section.x = currentStartX;
		section.y = currentStartY + (currentRow * 42);
		sectionsGrp.add(section);
		sectionPos.push({x: section.x, y: section.y});

		var sectionBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionsBG.png'));
		sectionBG.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		sectionBG.updateHitbox();
		sectionBG.ID = optionID;
		var sep = 14;
		var sectionWidth = 18 * label.length;
		sectionBG.x = section.x + ((sectionWidth - sectionBG.width) / 2) - 20;
		sectionBG.y = (section.y - (section.size / 2)) + (sep * 2.5);
		sectionBG.alpha = 0.5;
		sectionBGGrp.add(sectionBG);
		currentRow++;

		var emptyTxt = new FlxText(0, 0, 0, "", 50);
		emptyTxt.ID = optionID;
		emptyTxt.visible = false;
		propertieTxtGrp.add(emptyTxt);
		propertiesPos.push({x: 0, y: 0});

		var emptyBG = new FlxSprite(0, 0);
		emptyBG.ID = optionID;
		emptyBG.visible = false;
		propertiesBG.add(emptyBG);

		var emptyArrow = new FlxSprite(0, 0);
		emptyArrow.ID = optionID;
		emptyArrow.visible = false;
		propertieArrows.add(emptyArrow);
	}

	function addOption(label:String, saveKey:String)
	{
		optionID++;

		var section = new FlxText(0, 0, 0, label, 50);
		section.setFormat(Paths.font("SonicCD.ttf"), 15, FlxColor.WHITE, LEFT);
		section.ID = optionID;
		var columnX = currentStartX;
		section.x = columnX;
		section.y = currentStartY + (currentRow * 42);
		sectionsGrp.add(section);
		sectionPos.push({x: section.x, y: section.y});

		var sectionBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionsBG.png'));
		sectionBG.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		sectionBG.updateHitbox();
		sectionBG.ID = optionID;
		var sep = 14;
		var sectionWidth = 15 * label.length;
		sectionBG.x = section.x + ((sectionWidth - sectionBG.width) / 2);
		sectionBG.y = (section.y - (section.size / 2)) + (sep * 2.5);
		sectionBGGrp.add(sectionBG);

		var keys:Array<FlxKey> = ClientPrefs.keyBinds.get(saveKey);
		var gamepadKeys:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(saveKey);
		var keyText = onKeyboardMode
			? InputFormatter.getKeyName(keys != null && keys.length > 0 ? keys[0] : NONE)
			: InputFormatter.getGamepadName(gamepadKeys != null && gamepadKeys.length > 0 ? gamepadKeys[0] : NONE);

		var propTxt = new FlxText(0, 0, 0, keyText.toUpperCase(), 50);
		propTxt.setFormat(Paths.font("SonicCD.ttf"), 15, FlxColor.WHITE, LEFT);
		propTxt.ID = optionID;
		propTxt.x = columnX + 380;
		propTxt.y = section.y;
		propertieTxtGrp.add(propTxt);
		propertiesPos.push({x: propTxt.x, y: propTxt.y});

		var propBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		propBG.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		propBG.updateHitbox();
		propBG.ID = optionID;
		var propSectionWidth = 20 * propTxt.text.length;
		propBG.x = propTxt.x + ((propSectionWidth - propBG.width) / 2);
		propBG.y = (propTxt.y - (propTxt.size / 2)) + (sep * 2.5);
		propertiesBG.add(propBG);

		var propArrow = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionArrow.png'));
		propArrow.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		propArrow.updateHitbox();
		propArrow.ID = optionID;
		propArrow.x = propBG.x;
		propArrow.y = propBG.y;
		propertieArrows.add(propArrow);

		currentRow++;
	}

	function updatePropertyText(id:Int)
	{
		if (sectionsList[id].isCategory == true) return;
		var option = sectionsList[id];
		var keys = ClientPrefs.keyBinds.get(option.saveKey);
		var gamepadKeys = ClientPrefs.gamepadBinds.get(option.saveKey);
		var keyText = onKeyboardMode
			? InputFormatter.getKeyName(keys != null && keys.length > 0 ? keys[0] : NONE)
			: InputFormatter.getGamepadName(gamepadKeys != null && gamepadKeys.length > 0 ? gamepadKeys[0] : NONE);
		if (id < propertieTxtGrp.members.length && propertieTxtGrp.members[id] != null)
			propertieTxtGrp.members[id].text = keyText.toUpperCase();
	}

	function resetObj(m:FlxSprite)
	{
		m.x = FlxG.random.int(0, FlxG.width);
		m.y = FlxG.random.int(0, FlxG.height);
		m.velocity.x = FlxG.random.float(-20, 20);
		m.velocity.y = FlxG.random.float(-20, 20);
		m.angularVelocity = FlxG.random.float(-14, 14);
		m.updateHitbox();
	}

	override function destroy()
	{
		if (selectionTween != null)      { selectionTween.cancel();      selectionTween = null; }
		if (selectionCloneTween != null) { selectionCloneTween.cancel(); selectionCloneTween = null; }
		if (propTween != null)           { propTween.cancel();           propTween = null; }
		if (propArrowTween != null)      { propArrowTween.cancel();      propArrowTween = null; }
		if (propCloneTween != null)      { propCloneTween.cancel();      propCloneTween = null; }
		closeBinding();
		bg = null; title = null; objsGrp = null;
		sectionsGrp = null; sectionBGGrp = null;
		propertieTxtGrp = null; propertiesBG = null; propertieArrows = null;
		sectionBGClone = null; propertieBGClone = null;
		propBGCloneShader = null; sectionPos = null; propertiesPos = null;
		super.destroy();
	}
}
