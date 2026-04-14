package states.extras.bios;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.ui.*;
import objects.*;

class BiosEditorSubState extends MusicBeatSubstate implements PsychUIEventHandler.PsychUIEvent
{
	var allNames:Array<String> = [];
	var allChars:Array<String> = [];
	var allPaths:Array<String> = [];
	var curSelected:Int = 0;

	var noBioChars:Array<String> = [];
	var noBioMods:Array<String>  = [];
	var noBioSelected:Int = 0;

	var charData:Dynamic;

	var listBox:PsychUIBox;
	var editBox:PsychUIBox; 

	var displayNameInput:PsychUIInputText;
	var bioAppearCheck:PsychUICheckBox;
	var bioOrderStepper:PsychUINumericStepper;

	var curVariantIdx:Int = 0;
	var vIndexLabel:FlxText;
	var vDispNameInput:PsychUIInputText;
	var vCharInput:PsychUIInputText;
	var vIconInput:PsychUIInputText;
	var vModInput:PsychUIInputText;
	var vFlipXCheck:PsychUICheckBox;
	var vCharScale:PsychUINumericStepper;
	var vCharOffX:PsychUINumericStepper;
	var vCharOffY:PsychUINumericStepper;
	var vIconOffX:PsychUINumericStepper;
	var vIconOffY:PsychUINumericStepper;
	var vArtistInput:PsychUIInputText;
	var vBioInput:PsychUIInputText;
	var ghostBtn:PsychUIButton;

	var camSub:FlxCamera;
	var parentState:BIOS;
	var listScrollY:Float = 0;
	var ghostChar:Character = null;
	var ghostActive:Bool = false;
	var isLoading:Bool = false;

	static inline var BIO_DIR = 'assets/exe/extras/bios/characters';

	public function new(parent:BIOS)
	{
		super();
		parentState = parent;
	}

	override function create()
	{
		camSub = new FlxCamera();
		camSub.bgColor = 0x00000000;
		FlxG.cameras.add(camSub, false);

		scanBios();
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
		parentState.editorOverride = true;
		super.create();
	}

	function scanBios()
	{
		var existingBios = new Map<String, String>();
		if (FileSystem.exists(BIO_DIR))
		{
			for (file in FileSystem.readDirectory(BIO_DIR))
			{
				if (!file.endsWith('.json')) continue;
				var path = BIO_DIR + '/' + file;
				var d:Dynamic = Json.parse(File.getContent(path));
				var base:Dynamic = (d.variants != null && (d.variants:Array<Dynamic>).length > 0) ? (d.variants:Array<Dynamic>)[0] : d;
				var charId = (base.char != null) ? Std.string(base.char) : haxe.io.Path.withoutExtension(file);
				existingBios.set(charId, path);
			}
		}

		var scanDir = function(dir:String, mod:String) {
			if (!FileSystem.exists(dir)) return;
			for (file in FileSystem.readDirectory(dir)) {
				if (!file.endsWith('.json')) continue;
				var charId = haxe.io.Path.withoutExtension(file);
				if (allChars.contains(charId)) continue;
				var charPath = dir + '/' + file;
				var d:Dynamic = Json.parse(File.getContent(charPath));
				if (d.animations == null) continue;

				if (existingBios.exists(charId))
				{
					var bd:Dynamic = Json.parse(File.getContent(existingBios.get(charId)));
					var dispName = (bd.display_name != null) ? Std.string(bd.display_name) : charId;
					allNames.push(dispName);
					allChars.push(charId);
					allPaths.push(existingBios.get(charId));
				}
				else
				{
					noBioChars.push(charId);
					noBioMods.push(mod);
				}
			}
		};

		scanDir('assets/shared/characters', '');
		for (mod in Mods.getModDirectories())
			scanDir('mods/' + mod + '/characters', mod);
	}

	function buildListBox()
	{
		listBox = new PsychUIBox(10, 10, 200, FlxG.height - 40, ['Characters', 'Add New']);
		listBox.cameras = [camSub];
		listBox.scrollFactor.set();
		add(listBox);
		rebuildList();
		rebuildNoBioList();
	}

	function rebuildList()
	{
		var tab = listBox.getTab('Characters').menu;
		tab.clear();
		var itemH = 20;
		var visibleH = listBox.height - 30;
		var selectedY = curSelected * itemH;
		if (selectedY < listScrollY) listScrollY = selectedY;
		if (selectedY + itemH > listScrollY + visibleH) listScrollY = selectedY + itemH - visibleH;
		for (i in 0...allNames.length) {
			var t = new FlxText(8, 10 + i * itemH - Std.int(listScrollY), 180, allNames[i], 14);
			t.color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.cameras = [camSub];
			t.ID = i;
			tab.add(t);
		}
	}

	function rebuildNoBioList()
	{
		var tab = listBox.getTab('Add New').menu;
		tab.clear();
		var itemH = 20;
		for (i in 0...noBioChars.length) {
			var t = new FlxText(8, 10 + i * itemH, 180, noBioChars[i], 14);
			t.color = (i == noBioSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.cameras = [camSub];
			t.ID = i;
			tab.add(t);
		}
		var addBtn = new PsychUIButton(8, 10 + noBioChars.length * itemH + 8, 'Create Bio JSON', function() createBioForSelected());
		addBtn.normalStyle.bgColor = 0xFF226622;
		addBtn.cameras = [camSub];
		tab.add(addBtn);
	}

	function createBioForSelected()
	{
		if (noBioChars.length == 0) return;
		var charId = noBioChars[noBioSelected];
		var mod    = noBioMods[noBioSelected];
		var safeFile = new EReg('[\\\\/:*?"<>|]', 'g').replace(charId, '-');
		var bioPath = BIO_DIR + '/' + safeFile + '.json';
		var defaultBio:Dynamic = {
			display_name: charId, list_position: 9999, bio_appear: true,
			variants: [{
				display_name: charId, char: charId, char_scale: 0.5,
				char_offset: [300, 100], icon_offset: [786, 425],
				icon: charId, flip_x: false, mod: mod, artist: '', bio: ''
			}]
		};
		if (!FileSystem.exists(BIO_DIR)) FileSystem.createDirectory(BIO_DIR);
		File.saveContent(bioPath, haxe.Json.stringify(defaultBio, null, '\t'));
		FlxG.sound.play(Paths.sound('confirmMenu'));

		allNames.push(charId); allChars.push(charId); allPaths.push(bioPath);
		noBioChars.splice(noBioSelected, 1); noBioMods.splice(noBioSelected, 1);
		noBioSelected = FlxMath.wrap(noBioSelected, 0, Std.int(Math.max(0, noBioChars.length - 1)));
		rebuildList(); rebuildNoBioList();
		parentState.biosCharacter.reloadCharList();
		loadChar(allNames.length - 1);
	}

	function buildEditBox()
	{
		var boxX = 220;
		var boxW = FlxG.width - boxX - 360;
		editBox = new PsychUIBox(boxX, 10, boxW, 530, ['Entry', 'Variant']);
		editBox.cameras = [camSub];
		editBox.scrollFactor.set();
		add(editBox);

		_buildEntryTab(boxW);
		_buildVariantTab(boxW);
	}

	function _buildEntryTab(boxW:Int)
	{
		var tab = editBox.getTab('Entry').menu;
		var w = boxW - 30;
		var y = 10;

		var lbl1 = new FlxText(10, y, 0, 'List Display Name:'); y += 14;
		displayNameInput = new PsychUIInputText(10, y, w, '', 12); y += 30;

		bioAppearCheck = new PsychUICheckBox(10, y, 'Appear in Bios', 200); y += 28;

		var lbl2 = new FlxText(10, y, 0, 'List Position:'); y += 14;
		bioOrderStepper = new PsychUINumericStepper(10, y, 1, 9999, 0, 9999, 0); y += 36;

		var saveBtn = new PsychUIButton(10, y, 'Save Entry  (Ctrl+S)', function() saveEntry());
		saveBtn.normalStyle.bgColor = 0xFF337733;

		tab.add(lbl1); tab.add(displayNameInput);
		tab.add(bioAppearCheck);
		tab.add(lbl2); tab.add(bioOrderStepper);
		tab.add(saveBtn);
	}

	function _buildVariantTab(boxW:Int)
	{
		var tab = editBox.getTab('Variant').menu;
		var w = boxW - 30;
		var half = Std.int(w / 2) - 5;
		var y = 10;

		vIndexLabel = new FlxText(10, y, w, 'Variant 1 / 1', 14);
		vIndexLabel.color = FlxColor.YELLOW;
		vIndexLabel.cameras = [camSub]; y += 20;

		var prevBtn = new PsychUIButton(10,       y, '< Prev', function() changeVariantEdit(-1));
		var nextBtn = new PsychUIButton(10 + 90,  y, 'Next >', function() changeVariantEdit(1));
		var addBtn  = new PsychUIButton(10 + 180, y, '+ Add',  function() addVariant());
		var delBtn  = new PsychUIButton(10 + 250, y, '- Del',  function() deleteVariant());
		addBtn.normalStyle.bgColor = 0xFF226622;
		delBtn.normalStyle.bgColor = 0xFF662222;
		y += 30;

		var l1 = new FlxText(10, y, 0, 'Variant Display Name:'); y += 14;
		vDispNameInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		var l2 = new FlxText(10, y, 0, 'Char ID:'); y += 14;
		vCharInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		var l3 = new FlxText(10, y, 0, 'Icon:'); y += 14;
		vIconInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		var l4 = new FlxText(10, y, 0, 'Mod:'); y += 14;
		vModInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		vFlipXCheck = new PsychUICheckBox(10, y, 'Flip X', 100); y += 26;

		var l5 = new FlxText(10, y, 0, 'Scale:'); y += 14;
		vCharScale = new PsychUINumericStepper(10, y, 0.05, 0.5, 0.05, 10, 2); y += 28;

		var l6 = new FlxText(10, y, 0, 'Char Offset X / Y:'); y += 14;
		vCharOffX = new PsychUINumericStepper(10,    y, 5, 300, -9000, 9000, 0);
		vCharOffY = new PsychUINumericStepper(half + 15, y, 5, 100, -9000, 9000, 0); y += 28;

		var l7 = new FlxText(10, y, 0, 'Icon Offset X / Y:'); y += 14;
		vIconOffX = new PsychUINumericStepper(10,    y, 5, 786, -9000, 9000, 0);
		vIconOffY = new PsychUINumericStepper(half + 15, y, 5, 425, -9000, 9000, 0); y += 28;

		var l8 = new FlxText(10, y, 0, 'Artist:'); y += 14;
		vArtistInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		var l9 = new FlxText(10, y, 0, 'Bio Text:'); y += 14;
		vBioInput = new PsychUIInputText(10, y, w, '', 12); y += 32;

		ghostBtn = new PsychUIButton(10, y, 'Ghost: OFF', function() toggleGhost());
		ghostBtn.normalStyle.bgColor = 0xFF444444;
		var saveVBtn = new PsychUIButton(10 + 110, y, 'Save Variant  (Ctrl+S)', function() saveVariant());
		saveVBtn.normalStyle.bgColor = 0xFF337733;

		for (spr in [vIndexLabel, prevBtn, nextBtn, addBtn, delBtn,
		             l1, vDispNameInput, l2, vCharInput, l3, vIconInput,
		             l4, vModInput, vFlipXCheck, l5, vCharScale,
		             l6, vCharOffX, vCharOffY, l7, vIconOffX, vIconOffY,
		             l8, vArtistInput, l9, vBioInput, ghostBtn, saveVBtn])
			tab.add(spr);
	}

	function getVariants():Array<Dynamic>
	{
		if (charData == null) return [];
		if (charData.variants == null) charData.variants = [];
		return cast(charData.variants, Array<Dynamic>);
	}

	function loadVariant(idx:Int)
	{
		var variants = getVariants();
		if (variants.length == 0) return;
		curVariantIdx = FlxMath.wrap(idx, 0, variants.length - 1);
		var v:Dynamic = variants[curVariantIdx];

		isLoading = true;
		vIndexLabel.text    = 'Variant ${curVariantIdx + 1} / ${variants.length}';
		vDispNameInput.text = (v.display_name != null) ? Std.string(v.display_name) : '';
		vCharInput.text     = (v.char   != null) ? Std.string(v.char)   : '';
		vIconInput.text     = (v.icon   != null) ? Std.string(v.icon)   : '';
		vModInput.text      = (v.mod    != null) ? Std.string(v.mod)    : '';
		vFlipXCheck.checked = (v.flip_x == true);
		vCharScale.value    = (v.char_scale  != null) ? v.char_scale       : 0.5;
		vCharOffX.value     = (v.char_offset != null) ? v.char_offset[0]   : 300;
		vCharOffY.value     = (v.char_offset != null) ? v.char_offset[1]   : 100;
		vIconOffX.value     = (v.icon_offset != null) ? v.icon_offset[0]   : 786;
		vIconOffY.value     = (v.icon_offset != null) ? v.icon_offset[1]   : 425;
		vArtistInput.text   = (v.artist != null) ? Std.string(v.artist) : '';
		vBioInput.text      = (v.bio    != null) ? Std.string(v.bio)    : '';
		isLoading = false;

		syncVariantPreview();
	}

	function syncVariantPreview()
	{
		if (isLoading || charData == null) return;
		try
		{
			var charId = vCharInput.text;
			if (charId != '' && parentState.biosShowcase.character != null)
			{
				var ch = parentState.biosShowcase.character;
				if (ch.curCharacter != charId) ch.changeCharacter(charId);
				ch.flipX = vFlipXCheck.checked;
				var s = vCharScale.value;
				ch.scale.set(s, s);
				ch.updateHitbox();
				ch.setPosition(vCharOffX.value - ch.offset.x, vCharOffY.value - ch.offset.y);
			}
			if (parentState.biosShowcase.icon != null && vIconInput.text != '')
			{
				if (parentState.biosShowcase.icon.getCharacter() != vIconInput.text)
					parentState.biosShowcase.icon.changeIcon(vIconInput.text);
				parentState.biosShowcase.icon.setPosition(vIconOffX.value, vIconOffY.value);
			}
		}
		catch(e:Dynamic) { trace('syncVariantPreview error: ' + e); }
	}

	function changeVariantEdit(dir:Int)
	{
		if (getVariants().length == 0) return;
		loadVariant(curVariantIdx + dir);
	}

	function addVariant()
	{
		if (charData == null) return;
		var variants = getVariants();
		variants.push({
			display_name: 'New Variant',
			char: allChars.length > 0 ? allChars[curSelected] : '',
			char_scale: 0.5, char_offset: [300, 100], icon_offset: [786, 425],
			icon: allChars.length > 0 ? allChars[curSelected] : '',
			flip_x: false, mod: '', artist: '', bio: ''
		});
		loadVariant(variants.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
	}

	function deleteVariant()
	{
		var variants = getVariants();
		if (variants.length <= 1) return;
		variants.splice(curVariantIdx, 1);
		loadVariant(Std.int(Math.min(curVariantIdx, variants.length - 1)));
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
	}

	function saveVariant()
	{
		if (charData == null || allPaths.length == 0) return;
		var variants = getVariants();
		if (variants.length == 0) return;
		var v:Dynamic = variants[curVariantIdx];
		v.display_name = vDispNameInput.text;
		v.char         = vCharInput.text;
		v.icon         = vIconInput.text;
		v.mod          = vModInput.text;
		v.flip_x       = vFlipXCheck.checked;
		v.char_scale   = vCharScale.value;
		v.char_offset  = [vCharOffX.value, vCharOffY.value];
		v.icon_offset  = [vIconOffX.value, vIconOffY.value];
		v.artist       = vArtistInput.text;
		v.bio          = vBioInput.text;
		_writeJson();
	}

	function saveEntry()
	{
		if (allPaths.length == 0) return;
		charData.display_name  = displayNameInput.text;
		charData.bio_appear    = bioAppearCheck.checked;
		charData.list_position = Std.int(bioOrderStepper.value);
		_writeJson();
		allNames[curSelected] = displayNameInput.text;
		rebuildList();
	}

	function _writeJson()
	{
		File.saveContent(allPaths[curSelected], haxe.Json.stringify(charData, null, '\t'));
		FlxG.sound.play(Paths.sound('confirmMenu'));
		parentState.biosCharacter.reloadCharList();
	}

	function loadChar(index:Int)
	{
		isLoading = true;
		curSelected = index;
		rebuildList();

		charData = Json.parse(File.getContent(allPaths[index]));
		var variants:Array<Dynamic> = (charData.variants != null) ? cast(charData.variants, Array<Dynamic>) : [];
		var base:Dynamic = (variants.length > 0) ? variants[0] : charData;

		Mods.currentModDirectory = (base.mod != null && base.mod != '') ? Std.string(base.mod) : '';

		if (parentState.biosShowcase.character != null)
			parentState.biosShowcase.character.changeCharacter(allChars[index]);

		var parentIndex = parentState.biosCharacter.chars_list.indexOf(allChars[index]);
		if (parentIndex >= 0) parentState.biosCharacter.jumpToChar(parentIndex);

		displayNameInput.text  = (charData.display_name != null) ? Std.string(charData.display_name) : allChars[index];
		bioAppearCheck.checked = (charData.bio_appear != false);
		bioOrderStepper.value  = (charData.list_position != null) ? charData.list_position : 9999;

		isLoading = false;

		curVariantIdx = 0;
		loadVariant(0);
	}

	function toggleGhost()
	{
		if (!ghostActive)
		{
			ghostActive = true;
			if (ghostChar != null) { parentState.remove(ghostChar); ghostChar.destroy(); }
			ghostChar = new Character(
				parentState.biosShowcase.character.x, parentState.biosShowcase.character.y,
				allChars[curSelected], true
			);
			ghostChar.scrollFactor.set();
			ghostChar.scale.set(vCharScale.value, vCharScale.value);
			ghostChar.flipX = vFlipXCheck.checked;
			ghostChar.updateHitbox();
			ghostChar.alpha = 0.3;
			ghostChar.active = false;
			parentState.add(ghostChar);
			parentState.remove(parentState.biosShowcase.character);
			parentState.add(parentState.biosShowcase.character);
			ghostBtn.text.text = 'Ghost: ON';
			ghostBtn.normalStyle.bgColor = 0xFF336633;
		}
		else
		{
			ghostActive = false;
			if (ghostChar != null) { parentState.remove(ghostChar); ghostChar.destroy(); ghostChar = null; }
			ghostBtn.text.text = 'Ghost: OFF';
			ghostBtn.normalStyle.bgColor = 0xFF444444;
		}
	}

	override function update(elapsed:Float)
	{
		var inputFocused = PsychUIInputText.focusOn != null;

		if (!inputFocused)
		{
			if (controls.UI_UP_P)   loadChar(FlxMath.wrap(curSelected - 1, 0, allNames.length - 1));
			if (controls.UI_DOWN_P) loadChar(FlxMath.wrap(curSelected + 1, 0, allNames.length - 1));
			if (controls.BACK || FlxG.keys.justPressed.F1) close();
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			saveEntry();
			saveVariant();
		}

		if (!isLoading && charData != null)
		{
			var ch = parentState.biosShowcase.character;
			if (ch != null)
			{
				ch.x = vCharOffX.value - ch.offset.x;
				ch.y = vCharOffY.value - ch.offset.y;
			}
		}

		if (FlxG.mouse.justPressed)
		{
			var mp = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			for (spr in listBox.getTab('Characters').menu.members)
			{
				var t = Std.downcast(spr, FlxText);
				if (t != null && t.overlapsPoint(mp)) { loadChar(t.ID); break; }
			}
			for (spr in listBox.getTab('Add New').menu.members)
			{
				var t = Std.downcast(spr, FlxText);
				if (t != null && t.overlapsPoint(mp)) { noBioSelected = t.ID; rebuildNoBioList(); break; }
			}
		}

		super.update(elapsed);
	}

	public function UIEvent(id:String, sender:Dynamic)
	{
		if (isLoading || charData == null) return;
		if (PsychUIInputText.focusOn != null) return;
		if (!(sender is PsychUINumericStepper) && !(sender is PsychUICheckBox)) return;
		if (id == PsychUINumericStepper.CHANGE_EVENT || id == PsychUICheckBox.CLICK_EVENT)
			syncVariantPreview();
	}

	override function destroy()
	{
		if (ghostChar != null) { parentState.remove(ghostChar); ghostChar.destroy(); ghostChar = null; }
		parentState.editorOverride = false;
		FlxG.cameras.remove(camSub);
		super.destroy();
	}
}