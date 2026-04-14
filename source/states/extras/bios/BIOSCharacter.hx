package states.extras.bios;

import haxe.Json;
import sys.io.File;
import flixel.*;

class BIOSCharacter
{
	
	public var chars_list:Array<String>        = [];
	public var displayNames_list:Array<String> = [];
	public var offsets_list:Array<Dynamic>     = [];
	public var icon_offset:Array<Dynamic>      = [];
	public var bios_list:Array<String>         = [];
	public var artist_list:Array<String>       = [];
	public var healthicon_list:Array<String>   = [];
	public var charMods_list:Array<String>     = [];
	public var bgColors_list:Array<Int>        = [];
	public var scales_list:Array<Float>        = [];
	public var flipX_list:Array<Bool>          = [];
	public var bioFilePaths:Array<String>      = [];

	public var curChar:Int = 0;      
	var virtualIdx:Float = 0;        

	public var variants_list:Array<Array<Dynamic>> = []; 
	public var curVariant:Int = 0;

	var namesGrp:FlxTypedGroup<FlxText>;
	var listScrollOffset:Float = 0;

	var listScrollTrack:FlxSprite;
	var listScrollThumb:FlxSprite;

	static inline var LIST_ITEM_H:Float   = 44;
	static inline var LIST_CENTER_Y:Float = 380;
	static inline var LIST_X:Float        = 52;
	static inline var LIST_FONT_SIZE:Int  = 34;

	static inline var LSB_W:Int    = 6;
	static inline var LSB_X:Float  = 10;
	static inline var LSB_Y:Float  = 138;
	static inline var LSB_H:Float  = 484;

	static inline var BIO_DIR = 'assets/exe/extras/bios/characters';

	var bios:BIOS;

	public function new(parent:BIOS)
	{
		bios = parent;

		loadBioList();

		listScrollTrack = new FlxSprite(LSB_X, LSB_Y).makeGraphic(LSB_W, Std.int(LSB_H), 0x44FFFFFF);
		listScrollTrack.scrollFactor.set();
		bios.add(listScrollTrack);

		listScrollThumb = new FlxSprite(LSB_X, LSB_Y).makeGraphic(LSB_W, 40, FlxColor.WHITE);
		listScrollThumb.scrollFactor.set();
		bios.add(listScrollThumb);

		namesGrp = new FlxTypedGroup<FlxText>();
		_fillNames();
		bios.add(namesGrp);
	}

	public function loadBioList()
	{
		chars_list = []; displayNames_list = []; offsets_list = []; icon_offset = [];
		bios_list = []; artist_list = []; healthicon_list = []; charMods_list = [];
		bgColors_list = []; scales_list = []; flipX_list = []; bioFilePaths = [];
		variants_list = [];

		var orderList:Array<Int> = [];

		if (!FileSystem.exists(BIO_DIR)) return;

		for (file in FileSystem.readDirectory(BIO_DIR))
		{
			if (!file.endsWith('.json')) continue;
			var path = BIO_DIR + '/' + file;
			var d:Dynamic = Json.parse(File.getContent(path));

			if (d.bio_appear != true) continue;

			var dispName = (d.display_name != null) ? Std.string(d.display_name) : haxe.io.Path.withoutExtension(file);
			var variants:Array<Dynamic> = (d.variants != null) ? cast(d.variants, Array<Dynamic>) : [];

			var base:Dynamic = (variants.length > 0) ? variants[0] : d;

			var charId = (base.char != null) ? Std.string(base.char) : haxe.io.Path.withoutExtension(file);

			displayNames_list.push(dispName);
			chars_list.push(charId);
			offsets_list.push((base.char_offset != null) ? [base.char_offset[0], base.char_offset[1]] : [300.0, 100.0]);
			icon_offset.push( (base.icon_offset != null) ? [base.icon_offset[0],  base.icon_offset[1]] : [786.0, 425.0]);
			bios_list.push(   (base.bio    != null) ? Std.string(base.bio)    : '');
			artist_list.push( (base.artist != null) ? Std.string(base.artist) : '');
			orderList.push(   (d.list_position != null) ? d.list_position : 9999);
			healthicon_list.push((base.icon != null) ? Std.string(base.icon) : charId);
			charMods_list.push(  (base.mod  != null) ? Std.string(base.mod)  : '');
			bgColors_list.push(  (base.bg_color != null) ? Std.parseInt(base.bg_color) : 0xFFAA0000);
			scales_list.push(    (base.char_scale != null) ? base.char_scale : 0.5);
			flipX_list.push(     (base.flip_x == true));
			bioFilePaths.push(path);
			variants_list.push(variants);
		}

		var combined = [for (i in 0...chars_list.length) {
			charId: chars_list[i], dispName: displayNames_list[i],
			offset: offsets_list[i], icon: icon_offset[i],
			bio: bios_list[i], artist: artist_list[i], order: orderList[i],
			healthicon: healthicon_list[i], charMod: charMods_list[i],
			bgColor: bgColors_list[i], scale: scales_list[i], flipX: flipX_list[i],
			path: bioFilePaths[i], variants: variants_list[i]
		}];
		combined.sort((a, b) -> a.order - b.order);

		chars_list        = [for (e in combined) e.charId];
		displayNames_list = [for (e in combined) e.dispName];
		offsets_list      = [for (e in combined) e.offset];
		icon_offset       = [for (e in combined) e.icon];
		bios_list         = [for (e in combined) e.bio];
		artist_list       = [for (e in combined) e.artist];
		healthicon_list   = [for (e in combined) e.healthicon];
		charMods_list     = [for (e in combined) e.charMod];
		bgColors_list     = [for (e in combined) e.bgColor];
		scales_list       = [for (e in combined) e.scale];
		flipX_list        = [for (e in combined) e.flipX];
		bioFilePaths      = [for (e in combined) e.path];
		variants_list     = [for (e in combined) e.variants];
	}

	public function changeCharBio(ola:Int = 0)
	{
		bios.biosInfo.resetScroll();

		if (chars_list.length == 0) return;
		virtualIdx += ola;
		var n = chars_list.length;
		curChar = ((Std.int(Math.round(virtualIdx)) % n) + n) % n;
		curVariant = 0; 
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);

		var variants = variants_list[curChar];
		if (variants != null && variants.length > 0)
		{
			var v:Dynamic = variants[0];
			var modDir = (v.mod != null) ? Std.string(v.mod) : '';
			Mods.currentModDirectory = (modDir != '') ? modDir : '';
			bios.bgColorTarget = (v.bg_color != null) ? Std.parseInt(v.bg_color) : 0xFFAA0000;
			bios.biosShowcase.onVariantChanged(v);
			bios.biosInfo.onVariantChanged(v);
		}
		else
		{
			var modDir = charMods_list[curChar];
			Mods.currentModDirectory = (modDir != null && modDir != '') ? modDir : '';
			bios.bgColorTarget = bgColors_list[curChar];
			bios.biosShowcase.onCharChanged(curChar);
			bios.biosInfo.onCharChanged(curChar);
		}
		onCharChanged(curChar);
	}

	public function changeVariant(dir:Int)
	{
		var variants = variants_list[curChar];
		if (variants == null || variants.length == 0) return;

		curVariant = FlxMath.wrap(curVariant + dir, 0, variants.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var v:Dynamic = variants[curVariant];
		var modDir = (v.mod != null) ? Std.string(v.mod) : charMods_list[curChar];
		Mods.currentModDirectory = (modDir != null && modDir != '') ? modDir : '';

		bios.bgColorTarget = (v.bg_color != null) ? Std.parseInt(v.bg_color) : bgColors_list[curChar];
		bios.biosShowcase.onVariantChanged(v);
		bios.biosInfo.onVariantChanged(v);
	}

	public function reloadCharList()
	{
		loadBioList();
		curChar      = Std.int(FlxMath.bound(curChar, 0, chars_list.length - 1));
		virtualIdx   = curChar;
		listScrollOffset = virtualIdx;
		_fillNames();
		if (chars_list.length > 0) changeCharBio(0);
	}

	public function jumpToChar(index:Int) changeCharBio(index - curChar);

	function _fillNames()
	{
		namesGrp.clear();
		for (i in 0...displayNames_list.length)
		{
			var t = new FlxText(LIST_X, 0, displayNames_list[i], LIST_FONT_SIZE);
			t.setFormat(Paths.font('NiseSegaSonic.TTF'), LIST_FONT_SIZE, FlxColor.WHITE, LEFT);
			t.antialiasing = true;
			t.ID = i;
			t.scrollFactor.set(0, 0);
			namesGrp.add(t);
		}
	}

	public function bringNamesToFront()
	{
		bios.remove(listScrollTrack);
		bios.remove(listScrollThumb);
		bios.remove(namesGrp);
		bios.add(listScrollTrack);
		bios.add(listScrollThumb);
		bios.add(namesGrp);
	}

	public function onCharChanged(index:Int)
	{
		namesGrp.forEach(function(t:FlxText) {
			t.color = (t.ID == index) ? FlxColor.YELLOW : FlxColor.WHITE;
		});
	}

	public function update(elapsed:Float)
	{
		if (chars_list.length > 1)
		{
			if (FlxG.mouse.wheel != 0 && !FlxG.mouse.overlaps(bios.biosInfo.bioBox))
				changeCharBio(-FlxG.mouse.wheel);
			if (bios.controls.UI_UP_P || FlxG.keys.justPressed.W)   changeCharBio(-1);
			if (bios.controls.UI_DOWN_P || FlxG.keys.justPressed.S) changeCharBio(1);
		}
		if (FlxG.keys.justPressed.A) changeVariant(-1);
		if (FlxG.keys.justPressed.D) changeVariant(1);

		listScrollOffset += (virtualIdx - listScrollOffset) * (1 - Math.exp(-elapsed * 12));

		var n = chars_list.length;

		namesGrp.forEach(function(t:FlxText) {
			
			var raw     = t.ID - listScrollOffset;
			var wrapped = raw - Math.round(raw / n) * n;

			t.y = LIST_CENTER_Y + wrapped * LIST_ITEM_H - t.height * 0.5;

			var dist = Math.abs(wrapped);
			var a:Float;
			if      (dist < 3.5) a = 1.0;
			else if (dist < 4.5) a = 0.5;
			else if (dist < 5.5) a = 0.2;
			else                 a = 0.0;

			t.color   = (dist < 0.6) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.alpha   = a;
			t.visible = (a > 0);
		});

		if (n > 0 && listScrollThumb != null)
		{
			var thumbH = Std.int(Math.max(16, LSB_H / (n * 0.5)));
			if (listScrollThumb.height != thumbH)
				listScrollThumb.makeGraphic(LSB_W, thumbH, FlxColor.WHITE);
			var thumbRange = LSB_H - thumbH;
			
			var pos = (n > 1) ? ((virtualIdx % n) + n) % n / n : 0;
			listScrollThumb.y = LSB_Y + pos * thumbRange;
		}
	}
}