package states.extras.bios;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.ui.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxCamera;
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

	static inline final BIO_DIR = 'assets/exe/extras/bios/characters';
	static inline final BOX_X:Int = 220;
	static inline final BOX_W:Int = 420;

	public function new(parent:BIOS)
	{
		super();
		parentState = parent;
	}

	override function create():Void
	{
		camSub = new FlxCamera();
		camSub.bgColor = 0x00000000;
		FlxG.cameras.add(camSub, false);

		scanBios();
		buildListBox();
		buildEditBox();

		if (allNames.length > 0) loadChar(0);
		
		final hint = new FlxText(0, FlxG.height - 22, FlxG.width, 'F1/ESC = close  |  Ctrl+S = save  |  UP/DOWN = select', 12);
		hint.alignment = CENTER;
		hint.color = 0xFFFFFFFF;
		hint.cameras = [camSub];
		add(hint);

		FlxG.mouse.visible = true;
		parentState.editorOverride = true;
		super.create();
	}

	function scanBios():Void
	{
		if (FileSystem.exists(BIO_DIR))
		{
			for (file in FileSystem.readDirectory(BIO_DIR))
			{
				if (!StringTools.endsWith(file, '.json')) continue;
				final path = BIO_DIR + '/' + file;
				try
				{
					final d:Dynamic = Json.parse(File.getContent(path));
					final dispName = (d.display_name != null) ? Std.string(d.display_name) : haxe.io.Path.withoutExtension(file);
					final variants:Array<Dynamic> = (d.variants != null) ? cast(d.variants, Array<Dynamic>) : [];
					
					var primaryChar:String;
					if (variants.length > 0 && variants[0].char != null)
						primaryChar = Std.string(variants[0].char);
					else if (d.char != null)
						primaryChar = Std.string(d.char);
					else
						primaryChar = haxe.io.Path.withoutExtension(file);
						
					allNames.push(dispName);
					allChars.push(primaryChar);
					allPaths.push(path);
				}
				catch(e:Dynamic) { trace('scanBios parse error $file: $e'); }
			}
		}

		final combined = [for (i in 0...allNames.length) {
			name: allNames[i], char: allChars[i], path: allPaths[i]
		}];
		
		combined.sort((a, b) -> {
			try {
				final da:Dynamic = Json.parse(File.getContent(a.path));
				final db:Dynamic = Json.parse(File.getContent(b.path));
				final pa:Int = (da.list_position != null) ? da.list_position : 9999;
				final pb:Int = (db.list_position != null) ? db.list_position : 9999;
				return pa - pb;
			} catch(e:Dynamic) { return 0; }
		});
		
		allNames = [for (e in combined) e.name];
		allChars = [for (e in combined) e.char];
		allPaths = [for (e in combined) e.path];

		final coveredChars = new Map<String, Bool>();
		for (i in 0...allChars.length) coveredChars.set(allChars[i], true);
		
		if (FileSystem.exists(BIO_DIR))
		{
			for (file in FileSystem.readDirectory(BIO_DIR))
			{
				if (!StringTools.endsWith(file, '.json')) continue;
				final path = BIO_DIR + '/' + file;
				try
				{
					final d:Dynamic = Json.parse(File.getContent(path));
					final variants:Array<Dynamic> = (d.variants != null) ? cast(d.variants, Array<Dynamic>) : [];
					for (v in variants)
						if (v.char != null) coveredChars.set(Std.string(v.char), true);
				}
				catch(e:Dynamic) {}
			}
		}

		final scanDir = function(dir:String, mod:String) {
			if (!FileSystem.exists(dir)) return;
			for (file in FileSystem.readDirectory(dir))
			{
				if (!StringTools.endsWith(file, '.json')) continue;
				final charId = haxe.io.Path.withoutExtension(file);
				if (coveredChars.exists(charId)) continue;
				
				final charPath = dir + '/' + file;
				try
				{
					final d:Dynamic = Json.parse(File.getContent(charPath));
					if (d.animations == null) continue;
				}
				catch(e:Dynamic) { continue; }
				noBioChars.push(charId);
				noBioMods.push(mod);
			}
		};

		scanDir('assets/shared/characters', '');
		for (mod in Mods.getModDirectories())
			scanDir('mods/' + mod + '/characters', mod);
	}

	function buildListBox():Void
	{
		listBox = new PsychUIBox(10, 10, 200, FlxG.height - 40, ['Characters', 'Add New']);
		listBox.cameras = [camSub];
		listBox.scrollFactor.set();
		add(listBox);
		rebuildList();
		rebuildNoBioList();
	}

	function rebuildList():Void
	{
		final tab = listBox.getTab('Characters').menu;
		tab.clear();
		final itemH = 20;
		final visibleH = listBox.height - 30;
		
		final selectedY = curSelected * itemH;
		if (selectedY < listScrollY) listScrollY = selectedY;
		if (selectedY + itemH > listScrollY + visibleH) listScrollY = selectedY + itemH - visibleH;
		
		for (i in 0...allNames.length)
		{
			final t = new FlxText(8, 10 + i * itemH - Std.int(listScrollY), 180, allNames[i], 14);
			t.color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.cameras = [camSub];
			t.ID = i;
			tab.add(t);
		}
	}

	function rebuildNoBioList():Void
	{
		final tab = listBox.getTab('Add New').menu;
		tab.clear();
		final itemH = 20;
		
		for (i in 0...noBioChars.length)
		{
			final t = new FlxText(8, 10 + i * itemH, 180, noBioChars[i], 14);
			t.color = (i == noBioSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.cameras = [camSub];
			t.ID = i;
			tab.add(t);
		}
		
		final addBtn = new PsychUIButton(8, 10 + noBioChars.length * itemH + 8, 'Create Bio JSON', () -> createBioForSelected());
		addBtn.normalStyle.bgColor = 0xFF226622;
		addBtn.cameras = [camSub];
		tab.add(addBtn);
	}

	function createBioForSelected():Void
	{
		if (noBioChars.length == 0) return;
		final charId = noBioChars[noBioSelected];
		final mod = noBioMods[noBioSelected];
		final safeName = new EReg('[\\\\/:*?"<>|]', 'g').replace(charId, '-');
		final bioPath  = BIO_DIR + '/' + safeName + '.json';
		
		final defaultBio:Dynamic = {
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

		allNames.push(charId); 
		allChars.push(charId); 
		allPaths.push(bioPath);
		
		noBioChars.splice(noBioSelected, 1); 
		noBioMods.splice(noBioSelected, 1);
		
		noBioSelected = FlxMath.wrap(noBioSelected, 0, Std.int(Math.max(0, noBioChars.length - 1)));
		rebuildList(); 
		rebuildNoBioList();
		parentState.biosCharacter.reloadCharList();
		loadChar(allNames.length - 1);
	}

	function buildEditBox():Void
	{
		editBox = new PsychUIBox(BOX_X, 10, BOX_W, 530, ['Entry', 'Variant']);
		editBox.cameras = [camSub];
		editBox.scrollFactor.set();
		add(editBox);
		_buildEntryTab();
		_buildVariantTab();
	}

	function _buildEntryTab():Void
	{
		final tab = editBox.getTab('Entry').menu;
		final w = BOX_W - 30;
		var y = 10;

		final lbl1 = new FlxText(10, y, 0, 'List Display Name:'); y += 14;
		displayNameInput = new PsychUIInputText(10, y, w, '', 12); y += 30;

		bioAppearCheck = new PsychUICheckBox(10, y, 'Appear in Bios', 200);
		y += 28;

		final lbl2 = new FlxText(10, y, 0, 'List Position:'); y += 14;
		bioOrderStepper = new PsychUINumericStepper(10, y, 1, 9999, 0, 9999, 0); y += 36;
		
		final saveBtn = new PsychUIButton(10, y, 'Save Entry  (Ctrl+S)', () -> saveEntry());
		saveBtn.normalStyle.bgColor = 0xFF337733;
		
		for (spr in [lbl1, displayNameInput, bioAppearCheck, lbl2, bioOrderStepper, saveBtn])
			tab.add(spr);
	}

	function _buildVariantTab():Void
	{
		final tab = editBox.getTab('Variant').menu;
		final w = BOX_W - 30;
		final half = Std.int(w / 2) - 5;
		var y = 10;
		
		vIndexLabel = new FlxText(10, y, w, 'Variant 1 / 1', 14);
		vIndexLabel.color = FlxColor.YELLOW;
		vIndexLabel.cameras = [camSub]; y += 20;
		
		final prevBtn = new PsychUIButton(10,       y, '< Prev', () -> changeVariantEdit(-1));
		final nextBtn = new PsychUIButton(10 + 90,  y, 'Next >', () -> changeVariantEdit(1));
		final addBtn  = new PsychUIButton(10 + 180, y, '+ Add',  () -> addVariant());
		final delBtn  = new PsychUIButton(10 + 250, y, '- Del',  () -> deleteVariant());
		
		addBtn.normalStyle.bgColor = 0xFF226622;
		delBtn.normalStyle.bgColor = 0xFF662222;
		y += 30;

		final l1 = new FlxText(10, y, 0, 'Variant Display Name:'); y += 14;
		vDispNameInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		final l2 = new FlxText(10, y, 0, 'Char ID:'); y += 14;
		vCharInput = new PsychUIInputText(10, y, w, '', 12); y += 28;
		
		final l3 = new FlxText(10, y, 0, 'Icon:'); y += 14;
		vIconInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		final l4 = new FlxText(10, y, 0, 'Mod:'); y += 14;
		vModInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		vFlipXCheck = new PsychUICheckBox(10, y, 'Flip X', 100); y += 26;

		final l5 = new FlxText(10, y, 0, 'Scale:'); y += 14;
		vCharScale = new PsychUINumericStepper(10, y, 0.05, 0.5, 0.05, 10, 2); y += 28;
		
		final l6 = new FlxText(10, y, 0, 'Char Offset X / Y:'); y += 14;
		vCharOffX = new PsychUINumericStepper(10, y, 5, 300, -9000, 9000, 0);
		vCharOffY = new PsychUINumericStepper(half + 15, y, 5, 100, -9000, 9000, 0); y += 28;
		
		final l7 = new FlxText(10, y, 0, 'Icon Offset X / Y:'); y += 14;
		vIconOffX = new PsychUINumericStepper(10, y, 5, 786, -9000, 9000, 0);
		vIconOffY = new PsychUINumericStepper(half + 15, y, 5, 425, -9000, 9000, 0); y += 28;
		
		final l8 = new FlxText(10, y, 0, 'Artist:'); y += 14;
		vArtistInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		final l9 = new FlxText(10, y, 0, 'Bio Text:'); y += 14;
		vBioInput = new PsychUIInputText(10, y, w, '', 12); y += 28;

		ghostBtn = new PsychUIButton(10, y, 'Ghost: OFF', () -> toggleGhost());
		ghostBtn.normalStyle.bgColor = 0xFF444444;
		
		final saveVBtn = new PsychUIButton(10 + 110, y, 'Save Variant  (Ctrl+S)', () -> saveVariant());
		saveVBtn.normalStyle.bgColor = 0xFF337733;
		
		for (spr in [vIndexLabel, prevBtn, nextBtn, addBtn, delBtn,
		             l1, vDispNameInput, l2, vCharInput, l3, vIconInput,
		             l4, vModInput, vFlipXCheck, l5, vCharScale,
		             l6, vCharOffX, vCharOffY, l7, vIconOffX, vIconOffY,
		             l8, vArtistInput, l9, vBioInput,
		             ghostBtn, saveVBtn])
			tab.add(spr);
	}

	function getVariants():Array<Dynamic>
	{
		if (charData == null) return [];
		if (charData.variants == null) charData.variants = [];
		return cast(charData.variants, Array<Dynamic>);
	}

	function loadVariant(idx:Int):Void
	{
		final variants = getVariants();
		if (variants.length == 0) return;
		curVariantIdx = FlxMath.wrap(idx, 0, variants.length - 1);
		final v:Dynamic = variants[curVariantIdx];

		isLoading = true;
		vIndexLabel.text = 'Variant ${curVariantIdx + 1} / ${variants.length}';
		vDispNameInput.text = (v.display_name != null) ? Std.string(v.display_name) : '';
		vCharInput.text     = (v.char         != null) ? Std.string(v.char)         : '';
		vIconInput.text     = (v.icon         != null) ? Std.string(v.icon)         : '';
		vModInput.text      = (v.mod          != null) ? Std.string(v.mod)          : '';
		vFlipXCheck.checked = (v.flip_x == true);
		vCharScale.value    = (v.char_scale  != null) ? v.char_scale     : 0.5;
		vCharOffX.value     = (v.char_offset != null) ? v.char_offset[0] : 300;
		vCharOffY.value     = (v.char_offset != null) ? v.char_offset[1] : 100;
		vIconOffX.value     = (v.icon_offset != null) ? v.icon_offset[0] : 786;
		vIconOffY.value     = (v.icon_offset != null) ? v.icon_offset[1] : 425;
		vArtistInput.text   = (v.artist != null) ? Std.string(v.artist) : '';
		vBioInput.text      = (v.bio    != null) ? Std.string(v.bio)    : '';
		isLoading = false;

		syncVariantPreview();
	}

	function syncVariantPreview():Void
	{
		if (charData == null) return;
		try
		{
			final ch = parentState.biosShowcase.character;
			if (ch != null && vCharInput.text != '')
			{
				if (ch.curCharacter != vCharInput.text)
					ch.changeCharacter(vCharInput.text);
				ch.flipX = vFlipXCheck.checked;
				final s = vCharScale.value;
				ch.scale.set(s, s);
				ch.updateHitbox();
				ch.setPosition(vCharOffX.value - ch.offset.x, vCharOffY.value - ch.offset.y);
			}
			
			final icon = parentState.biosShowcase.icon;
			if (icon != null && vIconInput.text != '')
			{
				if (icon.getCharacter() != vIconInput.text)
					icon.changeIcon(vIconInput.text);
				icon.setPosition(vIconOffX.value, vIconOffY.value);
			}
		}
		catch(e:Dynamic) { trace('syncVariantPreview error: $e'); }
	}

	function changeVariantEdit(dir:Int):Void
	{
		if (getVariants().length == 0) return;
		loadVariant(curVariantIdx + dir);
	}

	function addVariant():Void
	{
		if (charData == null) return;
		final variants = getVariants();
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

	function deleteVariant():Void
	{
		final variants = getVariants();
		if (variants.length <= 1) return;
		variants.splice(curVariantIdx, 1);
		loadVariant(Std.int(Math.min(curVariantIdx, variants.length - 1)));
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
	}

	function saveVariant():Void
	{
		if (charData == null || allPaths.length == 0) return;
		final variants = getVariants();
		if (variants.length == 0) return;
		
		final v:Dynamic = variants[curVariantIdx];
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

	function saveEntry():Void
	{
		if (allPaths.length == 0) return;
		charData.display_name  = displayNameInput.text;
		charData.bio_appear    = bioAppearCheck.checked;
		charData.list_position = Std.int(bioOrderStepper.value);
		_writeJson();
		allNames[curSelected] = displayNameInput.text;
		rebuildList();
	}

	function _writeJson():Void
	{
		File.saveContent(allPaths[curSelected], haxe.Json.stringify(charData, null, '\t'));
		FlxG.sound.play(Paths.sound('confirmMenu'));
		parentState.biosCharacter.reloadCharList();
	}

	function loadChar(index:Int):Void
	{
		isLoading = true;
		curSelected = index;
		rebuildList();
		charData = Json.parse(File.getContent(allPaths[index]));

		if (charData.variants == null)
		{
			final flat:Dynamic = charData;
			charData.variants = [{
				display_name: (flat.display_name != null) ? flat.display_name : allChars[index],
				char:         (flat.char         != null) ? flat.char         : allChars[index],
				icon:         (flat.icon         != null) ? flat.icon         : allChars[index],
				mod:          (flat.mod          != null) ? flat.mod          : '',
				flip_x:       (flat.flip_x == true),
				char_scale:   (flat.char_scale   != null) ? flat.char_scale   : 0.5,
				char_offset:  (flat.char_offset  != null) ? flat.char_offset  : [300, 100],
				icon_offset:  (flat.icon_offset  != null) ? flat.icon_offset  : [786, 425],
				artist:       (flat.artist       != null) ? flat.artist       : '',
				bio:          (flat.bio          != null) ? flat.bio          : ''
			}];
		}

		final variants:Array<Dynamic> = cast(charData.variants, Array<Dynamic>);
		final base:Dynamic = variants[0];
		Mods.currentModDirectory = (base.mod != null && base.mod != '') ? Std.string(base.mod) : '';
		
		final parentIndex = parentState.biosCharacter.chars_list.indexOf(allChars[index]);
		if (parentIndex >= 0) parentState.biosCharacter.jumpToChar(parentIndex);

		displayNameInput.text  = (charData.display_name != null) ? Std.string(charData.display_name) : allChars[index];
		bioAppearCheck.checked = (charData.bio_appear != false);
		bioOrderStepper.value  = (charData.list_position != null) ? charData.list_position : 9999;

		isLoading = false;
		curVariantIdx = 0;
		loadVariant(0);
	}

	function toggleGhost():Void
	{
		if (!ghostActive)
		{
			ghostActive = true;
			if (ghostChar != null) { parentState.remove(ghostChar); ghostChar.destroy(); }
			final ch = parentState.biosShowcase.character;
			ghostChar = new Character(ch.x, ch.y, vCharInput.text != '' ? vCharInput.text : allChars[curSelected], true);
			ghostChar.scrollFactor.set();
			ghostChar.scale.set(vCharScale.value, vCharScale.value);
			ghostChar.flipX = vFlipXCheck.checked;
			ghostChar.updateHitbox();
			ghostChar.alpha  = 0.3;
			ghostChar.active = false;
			parentState.add(ghostChar);
			parentState.remove(ch);
			parentState.add(ch);
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

	override function update(elapsed:Float):Void
	{
		final inputFocused = PsychUIInputText.focusOn != null;

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
			final ch = parentState.biosShowcase.character;
			if (ch != null)
			{
				ch.x = vCharOffX.value - ch.offset.x;
				ch.y = vCharOffY.value - ch.offset.y;
			}
		}

		if (FlxG.mouse.justPressed)
		{
			final mp = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			for (spr in listBox.getTab('Characters').menu.members)
			{
				final t = Std.downcast(spr, FlxText);
				if (t != null && t.overlapsPoint(mp)) { loadChar(t.ID); break; }
			}
			for (spr in listBox.getTab('Add New').menu.members)
			{
				final t = Std.downcast(spr, FlxText);
				if (t != null && t.overlapsPoint(mp)) { noBioSelected = t.ID; rebuildNoBioList(); break; }
			}
		}

		super.update(elapsed);
	}

	public function UIEvent(id:String, sender:Dynamic):Void
	{
		if (isLoading || charData == null) return;
		if (PsychUIInputText.focusOn != null) return;
		if (!(sender is PsychUINumericStepper) && !(sender is PsychUICheckBox)) return;
		
		if (id == PsychUINumericStepper.CHANGE_EVENT || id == PsychUICheckBox.CLICK_EVENT)
			syncVariantPreview();
	}

	override function destroy():Void
	{
		if (ghostChar != null) { parentState.remove(ghostChar); ghostChar.destroy(); ghostChar = null; }
		parentState.editorOverride = false;
		FlxG.cameras.remove(camSub);
		super.destroy();
	}
}