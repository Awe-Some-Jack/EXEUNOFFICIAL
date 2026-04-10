package states.extras;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.ui.*;
import objects.*;
import states.editors.content.PsychJsonPrinter;

class BiosEditorSubState extends MusicBeatSubstate implements PsychUIEventHandler.PsychUIEvent
{
	var allNames:Array<String> = [];
	var allMods:Array<String>  = [];
	var allPaths:Array<String> = [];
	var curSelected:Int        = 0;

	var charData:Dynamic;

	var listBox:PsychUIBox;
	var editBox:PsychUIBox;
	var listTexts:FlxTypedGroup<FlxText>;

	var bioAppearCheck:PsychUICheckBox;
	var flipXCheck:PsychUICheckBox;
	var charOffX:PsychUINumericStepper;
	var charOffY:PsychUINumericStepper;
	var charScale:PsychUINumericStepper;
	var iconOffX:PsychUINumericStepper;
	var iconOffY:PsychUINumericStepper;
	var bioOrderStepper:PsychUINumericStepper;
	var bioArtistInput:PsychUIInputText;
	var bioInfoInput:PsychUIInputText;
	var bgColorR:PsychUINumericStepper;
	var bgColorG:PsychUINumericStepper;
	var bgColorB:PsychUINumericStepper;
	var colorPreview:FlxSprite;

	var camSub:FlxCamera;
	var parentState:CharacterBios;

	public function new(parent:CharacterBios)
	{
		super();
		parentState = parent;
	}

	override function create()
	{
		camSub = new FlxCamera();
		camSub.bgColor = 0x00000000;
		FlxG.cameras.add(camSub, false);

		scanCharacters();

		listTexts = new FlxTypedGroup<FlxText>();
		listTexts.cameras = [camSub];
		add(listTexts);

		buildListBox();
		buildEditBox();

		if (allNames.length > 0)
			loadChar(0);

		var hint = new FlxText(0, FlxG.height - 22, FlxG.width,
			'F1/ESC = close  |  Ctrl+S = save  |  UP/DOWN = select', 12);
		hint.alignment = CENTER;
		hint.color = 0xFFFFFFFF;
		hint.cameras = [camSub];
		add(hint);

		FlxG.mouse.visible = true;
		super.create();
	}

	function scanCharacters()
	{
		var scan = function(dir:String, mod:String) {
			if (!FileSystem.exists(dir)) return;
			for (file in FileSystem.readDirectory(dir)) {
				if (!file.endsWith('.json')) continue;
				var name = haxe.io.Path.withoutExtension(file);
				if (allNames.contains(name)) continue;
				var path = dir + '/' + file;
				var d:Dynamic = Json.parse(File.getContent(path));
				if (d.animations == null) continue;
				allNames.push(name);
				allMods.push(mod);
				allPaths.push(path);
			}
		};
		scan('assets/shared/characters', '');
		for (mod in Mods.getModDirectories())
			scan('mods/' + mod + '/characters', mod);
	}

	function buildListBox()
	{
		listBox = new PsychUIBox(10, 10, 200, FlxG.height - 40, ['Characters']);
		listBox.cameras = [camSub];
		listBox.scrollFactor.set();
		add(listBox);
		rebuildList();
	}

	function rebuildList()
	{
		var tab = listBox.getTab('Characters').menu;
		tab.clear();
		listTexts.clear();
		for (i in 0...allNames.length) {
			var t = new FlxText(8, 10 + i * 20, 180, allNames[i], 14);
			t.color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.cameras = [camSub];
			t.ID = i;
			tab.add(t);
			listTexts.add(t);
		}
	}

	function buildEditBox()
	{
		var boxX = FlxG.width - 260;
		editBox = new PsychUIBox(boxX, 10, 250, FlxG.height - 40, ['Bio Fields']);
		editBox.cameras = [camSub];
		editBox.scrollFactor.set();
		add(editBox);

		var tab = editBox.getTab('Bio Fields').menu;

		bioAppearCheck = new PsychUICheckBox(10, 10, 'Appear in Bios', 180);
		flipXCheck     = new PsychUICheckBox(10, bioAppearCheck.y + 24, 'Flip X', 100);

		var scaleLbl = new FlxText(10, flipXCheck.y + 26, 0, 'Scale:');
		charScale = new PsychUINumericStepper(10, scaleLbl.y + 14, 0.05, 0.5, 0.05, 10, 2);

		var charOffLbl = new FlxText(10, charScale.y + 36, 0, 'Char Offset X / Y:');
		charOffX = new PsychUINumericStepper(10,  charOffLbl.y + 14, 5, 300, -9000, 9000, 0);
		charOffY = new PsychUINumericStepper(120, charOffLbl.y + 14, 5, 100, -9000, 9000, 0);

		var iconOffLbl = new FlxText(10, charOffX.y + 36, 0, 'Icon Offset X / Y:');
		iconOffX = new PsychUINumericStepper(10,  iconOffLbl.y + 14, 5, 786, -9000, 9000, 0);
		iconOffY = new PsychUINumericStepper(120, iconOffLbl.y + 14, 5, 425, -9000, 9000, 0);

		var orderLbl = new FlxText(10, iconOffX.y + 36, 0, 'Order:');
		bioOrderStepper = new PsychUINumericStepper(10, orderLbl.y + 14, 1, 9999, 0, 9999, 0);

		var artistLbl = new FlxText(10, bioOrderStepper.y + 36, 0, 'Artist:');
		bioArtistInput = new PsychUIInputText(10, artistLbl.y + 14, 228, '', 8);

		var infoLbl = new FlxText(10, bioArtistInput.y + 36, 0, 'Bio Text:');
		bioInfoInput = new PsychUIInputText(10, infoLbl.y + 14, 228, '', 8);

		var bgLbl = new FlxText(10, bioInfoInput.y + 36, 0, 'BG Color R/G/B:');
		bgColorR = new PsychUINumericStepper(10,  bgLbl.y + 14, 5, 170, 0, 255, 0);
		bgColorG = new PsychUINumericStepper(90,  bgLbl.y + 14, 5, 0,   0, 255, 0);
		bgColorB = new PsychUINumericStepper(170, bgLbl.y + 14, 5, 0,   0, 255, 0);

		colorPreview = new FlxSprite(10, bgColorR.y + 28).makeGraphic(228, 16, 0xFFAA0000);
		colorPreview.cameras = [camSub];

		var saveBtn = new PsychUIButton(10, colorPreview.y + 24, 'Save  (Ctrl+S)', function() saveData());
		saveBtn.normalStyle.bgColor = 0xFF337733;

		tab.add(bioAppearCheck);
		tab.add(flipXCheck);
		tab.add(scaleLbl);
		tab.add(charScale);
		tab.add(charOffLbl);
		tab.add(charOffX);
		tab.add(charOffY);
		tab.add(iconOffLbl);
		tab.add(iconOffX);
		tab.add(iconOffY);
		tab.add(orderLbl);
		tab.add(bioOrderStepper);
		tab.add(artistLbl);
		tab.add(bioArtistInput);
		tab.add(infoLbl);
		tab.add(bioInfoInput);
		tab.add(bgLbl);
		tab.add(bgColorR);
		tab.add(bgColorG);
		tab.add(bgColorB);
		tab.add(colorPreview);
		tab.add(saveBtn);
	}

	function loadChar(index:Int)
	{
		curSelected = index;
		rebuildList();

		charData = Json.parse(File.getContent(allPaths[index]));
		var mod = allMods[index];
		if (mod != null && mod != '') Mods.currentModDirectory = mod;

		var parentIndex = parentState.chars_list.indexOf(allNames[index]);
		if (parentIndex >= 0) parentState.jumpToChar(parentIndex);

		bioAppearCheck.checked = (charData.bio_appear == true);
		flipXCheck.checked     = (charData.bio_flip_x == true);
		charScale.value        = (charData.bio_scale       != null) ? charData.bio_scale       : 0.5;
		charOffX.value         = (charData.bio_char_offset != null) ? charData.bio_char_offset[0] : 300;
		charOffY.value         = (charData.bio_char_offset != null) ? charData.bio_char_offset[1] : 100;
		iconOffX.value         = (charData.bio_icon_offset != null) ? charData.bio_icon_offset[0] : 786;
		iconOffY.value         = (charData.bio_icon_offset != null) ? charData.bio_icon_offset[1] : 425;
		bioOrderStepper.value  = (charData.bio_order  != null) ? charData.bio_order  : 9999;
		bioArtistInput.text    = (charData.bio_artist != null) ? charData.bio_artist : '';
		bioInfoInput.text      = (charData.bio_info   != null) ? charData.bio_info   : '';

		var col:FlxColor = (charData.bio_bg_color != null) ? Std.parseInt(charData.bio_bg_color) : 0xFFAA0000;
		bgColorR.value = col.red;
		bgColorG.value = col.green;
		bgColorB.value = col.blue;
		updateColorPreview();
		syncFromSteppers();
	}

	function saveData()
	{
		if (allPaths.length == 0) return;
		charData.bio_appear      = bioAppearCheck.checked;
		charData.bio_flip_x      = flipXCheck.checked;
		charData.bio_scale       = charScale.value;
		charData.bio_info        = bioInfoInput.text;
		charData.bio_artist      = bioArtistInput.text;
		charData.bio_order       = Std.int(bioOrderStepper.value);
		charData.bio_char_offset = [charOffX.value, charOffY.value];
		charData.bio_icon_offset = [iconOffX.value, iconOffY.value];
		var col = FlxColor.fromRGB(Std.int(bgColorR.value), Std.int(bgColorG.value), Std.int(bgColorB.value));
		charData.bio_bg_color    = '0x' + StringTools.hex(col, 8);

		File.saveContent(allPaths[curSelected], PsychJsonPrinter.print(charData, [
			'offsets', 'position', 'healthbar_colors', 'camera_position', 'indices',
			'bio_char_offset', 'bio_icon_offset'
		]));
		FlxG.sound.play(Paths.sound('confirmMenu'));

		parentState.reloadCharList();
	}

	function syncFromSteppers()
	{
		if (parentState.character != null)
		{
			parentState.character.setPosition(charOffX.value, charOffY.value);
			parentState.character.flipX = flipXCheck.checked;
			var s = charScale.value;
			parentState.character.scale.set(s, s);
			parentState.character.updateHitbox();
		}
		if (parentState.icon != null)
			parentState.icon.setPosition(iconOffX.value, iconOffY.value);

		var col = FlxColor.fromRGB(Std.int(bgColorR.value), Std.int(bgColorG.value), Std.int(bgColorB.value));
		parentState.bgColorTarget = col;
		updateColorPreview();
	}

	function updateColorPreview()
	{
		if (colorPreview == null) return;
		colorPreview.makeGraphic(228, 16,
			FlxColor.fromRGB(Std.int(bgColorR.value), Std.int(bgColorG.value), Std.int(bgColorB.value)));
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.justPressed)
		{
			var mp = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			for (t in listTexts.members)
				if (t != null && t.overlapsPoint(mp)) { loadChar(t.ID); break; }
		}

		if (controls.UI_UP_P)   loadChar(FlxMath.wrap(curSelected - 1, 0, allNames.length - 1));
		if (controls.UI_DOWN_P) loadChar(FlxMath.wrap(curSelected + 1, 0, allNames.length - 1));

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S) saveData();
		if (controls.BACK || FlxG.keys.justPressed.F1) close();

		super.update(elapsed);
	}

	public function UIEvent(id:String, sender:Dynamic)
	{
		if (id == PsychUINumericStepper.CHANGE_EVENT || id == PsychUICheckBox.CLICK_EVENT)
			syncFromSteppers();
	}

	override function destroy()
	{
		FlxG.cameras.remove(camSub);
		super.destroy();
	}
}
