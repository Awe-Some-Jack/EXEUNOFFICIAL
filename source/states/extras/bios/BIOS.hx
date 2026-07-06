package states.extras.bios;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import objects.HealthIcon;

import flixel.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

typedef BioEntry =
{
	var displayName:String;
	var charId:String;
	var iconId:String;
	var mod:String;
	var bio:String;
	var artist:String;
	var scale:Float;
	var flipX:Bool;
	var charAngle:Float;
	var charOffset:Array<Float>;
	var iconOffset:Array<Float>;
	var listOrder:Int;
	var filePath:String;
	var variants:Array<Dynamic>;
}

class BIOS extends MusicBeatSubstate
{
	static inline final BIO_DIR = 'assets/exe/extras/bios/characters';

	static inline final LIST_X:Float        = 52;
	static inline final LIST_CENTER_Y:Float = 380;
	static inline final LIST_ITEM_H:Float   = 44;
	static inline final LIST_FONT_SIZE:Int  = 68;
	static inline final LIST_FONT_SCALE:Float = 0.5;
	static inline final LSB_W:Int           = 6;
	static inline final LSB_X:Float         = 10;
	static inline final LSB_Y:Float         = 138;
	static inline final LSB_H:Float         = 484;

	static inline final TITLE_X:Int  = 460;
	static inline final TITLE_Y:Int  = 34;
	static inline final TITLE_W:Int  = 328;
	static inline final TITLE_H:Int  = 100;
	static inline final TITLE_FONT_SIZE:Int   = 136;
	static inline final TITLE_FONT_SCALE:Float = 0.5;

	static inline final ARTIST_X:Float      = 471;
	static inline final ARTIST_Y:Float      = 588;
	static inline final ARTIST_W:Float      = 332;
	static inline final ARTIST_H:Float      = 100;
	static inline final ARTIST_MAX_SIZE:Int = 80;
	static inline final ARTIST_MIN_SIZE:Int = 28;
	static inline final ARTIST_FONT_SCALE:Float = 0.5;
	static inline final ARTIST_CYCLE_TIME:Float = 5.0;
	static inline final ARTIST_FADE_TIME:Float  = 0.5;

	static inline final INFO_X:Int     = 845;
	static inline final INFO_Y:Int     = 36;
	static inline final INFO_W:Int     = 407;
	static inline final INFO_H:Int     = 642;
	static inline final INFO_PAD_X:Int = 16;
	static inline final INFO_PAD_TOP:Int = 13;
	static inline final INFO_PAD_RIGHT:Int = 80;
	static inline final SCROLL_W:Int   = 8;
	static inline final SCROLL_PAD:Int = 10;

	public var entries:Array<BioEntry> = [];
	var curEntry:Int = 0;
	var curVariant:Int = 0;
	var virtualIdx:Float = 0;
	var listScrollOffset:Float = 0;

	var namesGrp:FlxTypedGroup<FlxText>;
	var listScrollTrack:FlxSprite;
	var listScrollThumb:FlxSprite;

	public var charSprite:FlxSprite;
	public var icon:HealthIcon;
	var charName:FlxText;
	var artistName:FlxText;
	var variantDots:FlxText;

	var bioCamera:FlxCamera;
	public var bioBox:FlxSprite;
	var bioTxt:FlxText;
	var bioScrollTrack:FlxSprite;
	var bioScrollThumb:FlxSprite;

	var charLoadTimer:FlxTimer;

	var artists:Array<String> = [];
	var artistIdx:Int = 0;
	var artistTimer:Float = 0;
	var artistFading:Bool = false;
	var artistFadeDir:Int = 1;
	var _artistTimer:Float = 0;

	public var lockedX:Float = 0;
	public var lockedY:Float = 0;
	var savedIconScale:Float = 1;

	var _lastCharId:String  = '';
	var _lastCharMod:String = '';
	var _charBmp:BitmapData = null;

	var _debugMode:Bool = false;
	var _debugSelected:FlxSprite = null;
	var _debugDragging:Bool = false;
	var _debugDragOffX:Float = 0;
	var _debugDragOffY:Float = 0;
	var _debugRotating:Bool = false;
	var _debugOpacity:Bool = false;
	var _debugResizeW:Bool = false;
	var _debugResizeH:Bool = false;
	var _debugLabel:FlxText;
	var _debugHistory:Map<String, { charX:Float, charY:Float, charScale:Float, charAngle:Float, charAlpha:Float, iconX:Float, iconY:Float, iconScale:Float }> = [];

	var _debugBox1:FlxSprite;
	var _debugBox2:FlxSprite;

	static var _ghosts:Array<FlxSprite> = [];

	override function create():Void
	{
		super.create();

		loadEntries();

		final w:Int = FlxG.width;
		final h:Int = FlxG.height;
		final bmd = new BitmapData(w, h, false, 0xFFbd0033);
		final lr = {r: 0xbd, g: 0x00, b: 0x33};
		final rr = {r: 0x57, g: 0x00, b: 0x0b};
		for (x in 0...w)
		{
			final t:Float = x / (w - 1);
			final r:Int = Math.round(lr.r + (rr.r - lr.r) * t);
			final g:Int = Math.round(lr.g + (rr.g - lr.g) * t);
			final b:Int = Math.round(lr.b + (rr.b - lr.b) * t);
			bmd.fillRect(new Rectangle(x, 0, 1, h), 0xFF000000 | (r << 16) | (g << 8) | b);
		}
		final bgSprite = new FlxSprite(0, 0);
		bgSprite.loadGraphic(bmd);
		bgSprite.scrollFactor.set();
		add(bgSprite);

		final tileSize:Int = 40;
		final cbmd = new BitmapData(tileSize * 2, tileSize * 2, true, 0x00000000);
		cbmd.fillRect(new Rectangle(0,        0,        tileSize, tileSize), 0xFF3d0008);
		cbmd.fillRect(new Rectangle(tileSize, 0,        tileSize, tileSize), 0xFF831826);
		cbmd.fillRect(new Rectangle(0,        tileSize, tileSize, tileSize), 0xFF831826);
		cbmd.fillRect(new Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF3d0008);
		final checkers = new FlxBackdrop(cbmd, XY, 0, 0);
		checkers.alpha = 0.10;
		checkers.velocity.x = -60;
		checkers.scrollFactor.set();
		add(checkers);

		final spikestop = new FlxBackdrop(openfl.utils.Assets.getBitmapData('assets/exe/extras/bios/backdrop.png'), Y);
		spikestop.velocity.y = 60;
		spikestop.screenCenter();
		spikestop.scrollFactor.set();
		spikestop.blend = openfl.display.BlendMode.MULTIPLY;
		add(spikestop);

		_buildShowcase();
		_buildInfoBox();
		_buildList();
		_buildOverlays();

		for (g in _ghosts) add(g);

		_debugBox1 = _makeDebugBox(473, 161, 298, 408);
		_debugBox2 = _makeDebugBox(692, 466, 74,  72);

		_debugLabel = new FlxText(4, 4, 0, '', 14);
		_debugLabel.setFormat(null, 14, FlxColor.WHITE, LEFT);
		_debugLabel.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		_debugLabel.scrollFactor.set(0, 0);
		_debugLabel.visible = false;
		add(_debugLabel);

		if (entries.length > 0)
			_applyEntry(0, 0);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Bios Menu", null);
		#end
	}

	function loadEntries():Void
	{
		entries = [];
		var scanPath = BIO_DIR.endsWith('/') ? BIO_DIR : BIO_DIR + '/';

		for (file in Paths.readDirectory(scanPath))
		{
			if (!file.endsWith('.json')) continue;
			
			final path = scanPath + file;
			var jsonText:String = Paths.getTextFromFile(path, true);
			
			if (jsonText == null) continue;

			var d:Dynamic;
			try { d = Json.parse(jsonText); }
			catch (e:Dynamic) { continue; }
			
			if (d.bio_appear != true) continue;

			final variants:Array<Dynamic> = (d.variants != null) ? cast(d.variants, Array<Dynamic>) : [];
			final base:Dynamic = (variants.length > 0) ? variants[0] : d;

			final displayName = _str(d.display_name, haxe.io.Path.withoutExtension(file));
			final charId      = _str(base.char, haxe.io.Path.withoutExtension(file));
			final iconId      = _str(base.icon, charId);
			final mod         = _str(base.mod, '');
			final bio         = _str(base.bio, '');
			final artist      = _str(base.artist, '');
			final scale:Float      = (base.char_scale != null) ? base.char_scale : 0.5;
			final flipX:Bool       = (base.flip_x == true);
			final charAngle:Float  = (base.char_angle != null) ? base.char_angle : 0.0;
			final charOff          = _arr2(base.char_offset, [300.0, 100.0]);
			final iconOff          = _arr2(base.icon_offset, [786.0, 425.0]);
			final order:Int        = (d.list_position != null) ? d.list_position : 9999;

			entries.push({
				displayName: displayName, charId: charId, iconId: iconId,
				mod: mod, bio: bio, artist: artist, scale: scale,
				flipX: flipX, charAngle: charAngle, charOffset: charOff, iconOffset: iconOff,
				listOrder: order, filePath: path, variants: variants
			});
		}

		entries.sort((a, b) -> a.listOrder - b.listOrder);
	}

	function _buildShowcase():Void
	{
		final e0 = entries.length > 0 ? entries[0] : null;

		final circle = new FlxShapeCircle(727, 501, 40, {thickness: 0, color: FlxColor.TRANSPARENT}, FlxColor.BLACK);
		circle.alpha = 0.75;
		circle.scrollFactor.set();
		add(circle);

		final circleBig = new FlxShapeCircle(721, 495, 46, {thickness: 4, color: FlxColor.BLACK}, FlxColor.TRANSPARENT);
		circleBig.alpha = 0.75;
		circleBig.scrollFactor.set();
		add(circleBig);

		charSprite = new FlxSprite(e0 != null ? e0.charOffset[0] : 300, e0 != null ? e0.charOffset[1] : 100);
		charSprite.scrollFactor.set();
		add(charSprite);

		icon = new HealthIcon(e0 != null ? e0.iconId : 'face', true);
		icon.scale.set(0.7, 0.7);
		icon.setPosition(e0 != null ? e0.iconOffset[0] : 786, e0 != null ? e0.iconOffset[1] : 425);
		icon.updateHitbox();
		savedIconScale = icon.scale.x;
		add(icon);

		charName = new FlxText(TITLE_X, TITLE_Y, 0, e0 != null ? e0.displayName : '', TITLE_FONT_SIZE);
		charName.setFormat(Paths.font('NiseSegaSonic.TTF'), TITLE_FONT_SIZE, FlxColor.WHITE, CENTER);
		charName.antialiasing = ClientPrefs.data.antialiasing;
		charName.scale.set(TITLE_FONT_SCALE, TITLE_FONT_SCALE);
		charName.scrollFactor.set();
		add(charName);
		_fitCharName();

		artistName = new FlxText(ARTIST_X, ARTIST_Y, 0, '', ARTIST_MAX_SIZE);
		artistName.setFormat(Paths.font('NiseSegaSonic.TTF'), ARTIST_MAX_SIZE, FlxColor.WHITE, CENTER);
		artistName.antialiasing = ClientPrefs.data.antialiasing;
		artistName.scale.set(ARTIST_FONT_SCALE, ARTIST_FONT_SCALE);
		artistName.scrollFactor.set();
		add(artistName);
		if (e0 != null) _setArtists(e0.artist);

		variantDots = new FlxText(0, FlxG.height - 60, 0, '', 44);
		variantDots.setFormat(Paths.font('NiseSegaSonic.TTF'), 44, FlxColor.WHITE, CENTER);
		variantDots.scale.set(0.5, 0.5);
		variantDots.scrollFactor.set();
		variantDots.visible = false;
		add(variantDots);

		final charBiosSprite = new FlxSprite(36, 19);
		charBiosSprite.loadGraphic(openfl.utils.Assets.getBitmapData('assets/exe/extras/bios/characterbios.png'));
		charBiosSprite.scrollFactor.set();
		add(charBiosSprite);
	}

	function _buildInfoBox():Void
	{
		bioCamera = null;

		bioBox = new FlxSprite(INFO_X, INFO_Y);
		bioBox.makeGraphic(INFO_W, INFO_H, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRect(bioBox, 0, 0, INFO_W, INFO_H, FlxColor.TRANSPARENT, {thickness: 7, color: FlxColor.WHITE});
		bioBox.scrollFactor.set();
		add(bioBox);

		bioTxt = new FlxText(INFO_X + INFO_PAD_X, INFO_Y + INFO_PAD_TOP, INFO_W - INFO_PAD_X - INFO_PAD_RIGHT, '', 23);
		bioTxt.setFormat(Paths.font('smallass.TTF'), 23, FlxColor.WHITE, LEFT);
		bioTxt.antialiasing = ClientPrefs.data.antialiasing;
		bioTxt.scrollFactor.set();
		bioTxt.clipRect = new flixel.math.FlxRect(0, 0, INFO_W - INFO_PAD_X - INFO_PAD_RIGHT, INFO_H);
		add(bioTxt);

		final trackH = INFO_H - SCROLL_PAD * 2;
		final tx = INFO_W - SCROLL_W - SCROLL_PAD;
		final ty = SCROLL_PAD;

		bioScrollTrack = new FlxSprite(INFO_X + tx, INFO_Y + ty).makeGraphic(SCROLL_W, trackH, 0x44FFFFFF);
		bioScrollTrack.scrollFactor.set();
		bioScrollTrack.visible = false;
		add(bioScrollTrack);

		bioScrollThumb = new FlxSprite(INFO_X + tx, INFO_Y + ty).makeGraphic(SCROLL_W, 40, FlxColor.WHITE);
		bioScrollThumb.scrollFactor.set();
		bioScrollThumb.visible = false;
		add(bioScrollThumb);
	}

	function _buildList():Void
	{
		listScrollTrack = new FlxSprite(LSB_X, LSB_Y).makeGraphic(LSB_W, Std.int(LSB_H), 0x44FFFFFF);
		listScrollTrack.scrollFactor.set();
		add(listScrollTrack);

		listScrollThumb = new FlxSprite(LSB_X, LSB_Y).makeGraphic(LSB_W, 40, FlxColor.WHITE);
		listScrollThumb.scrollFactor.set();
		add(listScrollThumb);

		namesGrp = new FlxTypedGroup<FlxText>();
		_rebuildNames();
		add(namesGrp);
	}

	function _buildOverlays():Void
	{
		final charBiosOverlay = new FlxSprite(36, 19);
		if (Assets.exists('assets/exe/extras/bios/characterbios_overlay.png'))
		{
			charBiosOverlay.loadGraphic(openfl.utils.Assets.getBitmapData('assets/exe/extras/bios/characterbios_overlay.png'));
			charBiosOverlay.scrollFactor.set();
			add(charBiosOverlay);
		}
	}

	function _rebuildNames():Void
	{
		namesGrp.clear();
		for (i in 0...entries.length)
		{
			final t = new FlxText(LIST_X, 0, 0, entries[i].displayName, LIST_FONT_SIZE);
			t.setFormat(Paths.font('NiseSegaSonic.TTF'), LIST_FONT_SIZE, FlxColor.WHITE, LEFT);
			t.antialiasing = ClientPrefs.data.antialiasing;
			t.scale.set(LIST_FONT_SCALE, LIST_FONT_SCALE);
			t.updateHitbox();
			t.scrollFactor.set(0, 0);
			t.ID = i;
			namesGrp.add(t);
		}
	}

	function _applyEntry(index:Int, variantIdx:Int):Void
	{
		if (entries.length == 0) return;
		curEntry = index;
		curVariant = variantIdx;

		final e = entries[index];
		var charId   = e.charId;
		var iconId   = e.iconId;
		var dispName = e.displayName;
		var artist   = e.artist;
		var bio      = e.bio;
		var scale      = e.scale;
		var flipX      = e.flipX;
		var charAngle  = e.charAngle;
		var charOff    = e.charOffset;
		var iconOff    = e.iconOffset;
		var mod        = e.mod;

		if (e.variants.length > 0 && variantIdx < e.variants.length)
		{
			final v:Dynamic = e.variants[variantIdx];
			charId    = _str(v.char,         charId);
			iconId    = _str(v.icon,         iconId);
			dispName  = _str(v.display_name, dispName);
			artist    = _str(v.artist,       artist);
			bio       = _str(v.bio,          bio);
			scale     = (v.char_scale  != null) ? v.char_scale  : scale;
			flipX     = (v.flip_x == true);
			charAngle = (v.char_angle != null) ? v.char_angle : charAngle;
			charOff   = _arr2(v.char_offset, charOff);
			iconOff   = _arr2(v.icon_offset, iconOff);
			mod       = _str(v.mod,          mod);
		}

		charName.text = dispName;
		_fitCharName();
		_setArtists(artist);
		_updateDots();

		bioTxt.text = bio;
		bioTxt.y = INFO_Y + INFO_PAD_TOP;

		namesGrp.forEach((t:FlxText) -> {
			t.color = (t.ID == index) ? FlxColor.YELLOW : FlxColor.WHITE;
		});

		Mods.currentModDirectory = mod;
		if (icon.getCharacter() != iconId) _swapIcon(iconId);
		icon.setPosition(iconOff[0], iconOff[1]);

		charLoadTimer?.cancel();
		Mods.currentModDirectory = mod;
		_loadCharFrame(charId, mod, scale, flipX, charOff);
		_fitToBoxes(charAngle);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Bios Menu", 'Checking $dispName');
		#end
	}

	function _loadCharFrame(charId:String, mod:String, scale:Float, flipX:Bool, charOff:Array<Float>):Void
	{

		if (_lastCharId == charId && _lastCharMod == mod)
		{
			charSprite.scale.set(scale, scale);
			charSprite.flipX = flipX;
			charSprite.updateHitbox();
			charSprite.setPosition(lockedX, lockedY);
			charSprite.visible = true;
			return;
		}

		final charPath = 'characters/$charId.json';
		var fullPath = Paths.getSharedPath(charPath);
		#if MODS_ALLOWED
		if (mod != '')
		{
			final mp = Paths.mods('$mod/$charPath');
			if (FileSystem.exists(mp)) fullPath = mp;
		}
		else
		{
			final mp = Paths.modFolders(charPath);
			if (FileSystem.exists(mp)) fullPath = mp;
		}
		#end

		if (!FileSystem.exists(fullPath)) { charSprite.visible = false; return; }

		var json:Dynamic;
		try { json = Json.parse(File.getContent(fullPath)); }
		catch (e:Dynamic) { charSprite.visible = false; return; }

		if (json.image == null) { charSprite.visible = false; return; }

		final idleAnim = _findIdleAnim(json);
		if (idleAnim == null) { charSprite.visible = false; return; }
		final animOffset:Array<Float> = idleAnim.offset;

		final imageKey:String = Std.string(json.image).split(',')[0].trim();

		final pngPath = _resolveImagePath(imageKey, mod);
		if (pngPath == null) { charSprite.visible = false; return; }

		var sheetBmp:BitmapData;
		try { sheetBmp = BitmapData.fromFile(pngPath); }
		catch (e:Dynamic) { charSprite.visible = false; return; }

		var rect = _findFrameRect(imageKey, mod, idleAnim.prefix);
		if (rect == null && idleAnim.altPrefix != null && idleAnim.altPrefix != idleAnim.prefix)
			rect = _findFrameRect(imageKey, mod, idleAnim.altPrefix);

		if (rect == null)
		{
			sheetBmp.dispose();
			charSprite.visible = false;
			return;
		}

		var frameBmp:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x00000000);
		frameBmp.copyPixels(sheetBmp, rect, new Point(0, 0));
		sheetBmp.dispose();

		charSprite.makeGraphic(frameBmp.width, frameBmp.height, 0x00000000, true);
		charSprite.pixels.copyPixels(frameBmp, frameBmp.rect, new Point(0, 0));
		charSprite.dirty = true;
		if (_charBmp != null) { _charBmp.dispose(); _charBmp = null; }
		_charBmp = frameBmp;

		charSprite.scale.set(scale, scale);
		charSprite.flipX = flipX;
		charSprite.updateHitbox();

		lockedX = charOff[0] - animOffset[0] * scale;
		lockedY = charOff[1] - animOffset[1] * scale;
		charSprite.setPosition(lockedX, lockedY);
		charSprite.visible = true;

		_lastCharId  = charId;
		_lastCharMod = mod;
	}

	function _releaseCharBmp():Void
	{
		if (_charBmp != null) { _charBmp.dispose(); _charBmp = null; }
	}

	function _resolveImagePath(imageKey:String, mod:String):String
	{
		final pngKey = 'images/$imageKey.png';
		#if MODS_ALLOWED
		if (mod != '')
		{
			final p = 'contents/$mod/$pngKey';
			if (FileSystem.exists(p)) return p;
		}
		final mp = Paths.modFolders(pngKey);
		if (FileSystem.exists(mp)) return mp;
		#end
		final sp = Paths.getSharedPath(pngKey);
		if (FileSystem.exists(sp)) return sp;
		return null;
	}

	function _findFrameRect(imageKey:String, mod:String, prefix:String):openfl.geom.Rectangle
	{
		final xmlKey = 'images/$imageKey.xml';
		var xmlPath:String = null;
		#if MODS_ALLOWED
		if (mod != '')
		{
			final p = 'contents/$mod/$xmlKey';
			if (FileSystem.exists(p)) xmlPath = p;
		}
		if (xmlPath == null)
		{
			final mp = Paths.modFolders(xmlKey);
			if (FileSystem.exists(mp)) xmlPath = mp;
		}
		#end
		if (xmlPath == null)
		{
			final sp = Paths.getSharedPath(xmlKey);
			if (FileSystem.exists(sp)) xmlPath = sp;
		}

		if (xmlPath != null)
		{
			try
			{
				final root = Xml.parse(File.getContent(xmlPath)).firstElement();
				for (node in root.elements())
				{
					final name = node.get('name') ?? node.get('n') ?? '';
					if (name.startsWith(prefix))
					{
						final x = Std.parseInt(node.get('x') ?? '0');
						final y = Std.parseInt(node.get('y') ?? '0');
						final w = Std.parseInt(node.get('width') ?? node.get('w') ?? '0');
						final h = Std.parseInt(node.get('height') ?? node.get('h') ?? '0');
						if (w > 0 && h > 0)
							return new openfl.geom.Rectangle(x, y, w, h);
					}
				}
			}
			catch (e:Dynamic) {}
		}

		final txtKey = 'images/$imageKey.txt';
		var txtPath:String = null;
		#if MODS_ALLOWED
		if (mod != '')
		{
			final p = 'contents/$mod/$txtKey';
			if (FileSystem.exists(p)) txtPath = p;
		}
		if (txtPath == null)
		{
			final mp = Paths.modFolders(txtKey);
			if (FileSystem.exists(mp)) txtPath = mp;
		}
		#end
		if (txtPath == null)
		{
			final sp = Paths.getSharedPath(txtKey);
			if (FileSystem.exists(sp)) txtPath = sp;
		}

		if (txtPath != null)
		{
			try
			{
				for (line in File.getContent(txtPath).split('\n'))
				{
					final t = line.trim();
					if (t.length == 0) continue;
					final parts = t.split('=');
					if (parts.length < 2) continue;
					final frameName = parts[0].trim();
					if (!frameName.startsWith(prefix)) continue;
					final nums = parts[1].trim().split(' ');
					if (nums.length < 4) continue;
					final x = Std.parseInt(nums[0]);
					final y = Std.parseInt(nums[1]);
					final w = Std.parseInt(nums[2]);
					final h = Std.parseInt(nums[3]);
					if (w > 0 && h > 0)
						return new openfl.geom.Rectangle(x, y, w, h);
				}
			}
			catch (e:Dynamic) {}
		}

		return null;
	}

	function _findIdleAnim(json:Dynamic):{ prefix:String, altPrefix:String, offset:Array<Float> }
	{
		if (json.animations == null) return null;
		final anims:Array<Dynamic> = cast(json.animations, Array<Dynamic>);
		for (priority in ['danceLeft', 'idle'])
		{
			for (anim in anims)
			{
				final animField:String = _str(anim.anim, '');
				if (animField == priority || animField.startsWith(priority))
				{
					final nameField:String = _str(anim.name, '');
					final offsets:Array<Dynamic> = (anim.offsets != null) ? cast(anim.offsets, Array<Dynamic>) : null;
					final offset = (offsets != null && offsets.length >= 2) ? [offsets[0] * 1.0, offsets[1] * 1.0] : [0.0, 0.0];
					return { prefix: animField, altPrefix: nameField, offset: offset };
				}
			}
		}
		for (priority in ['danceLeft', 'idle'])
		{
			for (anim in anims)
			{
				final nameField:String = _str(anim.name, '');
				if (nameField == priority || nameField.startsWith(priority))
				{
					final animField:String = _str(anim.anim, nameField);
					final offsets:Array<Dynamic> = (anim.offsets != null) ? cast(anim.offsets, Array<Dynamic>) : null;
					final offset = (offsets != null && offsets.length >= 2) ? [offsets[0] * 1.0, offsets[1] * 1.0] : [0.0, 0.0];
					return { prefix: animField, altPrefix: nameField, offset: offset };
				}
			}
		}
		if (anims.length > 0)
		{
			final anim = anims[0];
			final animField:String = _str(anim.anim, '');
			final nameField:String = _str(anim.name, '');
			final offsets:Array<Dynamic> = (anim.offsets != null) ? cast(anim.offsets, Array<Dynamic>) : null;
			final offset = (offsets != null && offsets.length >= 2) ? [offsets[0] * 1.0, offsets[1] * 1.0] : [0.0, 0.0];
			return { prefix: animField != '' ? animField : nameField, altPrefix: nameField, offset: offset };
		}
		return null;
	}

	function _changeEntry(delta:Int):Void
	{
		if (entries.length <= 1) return;
		if (_debugMode) _debugSaveHistory();
		virtualIdx += delta;
		final n = entries.length;
		curEntry = ((Std.int(Math.round(virtualIdx)) % n) + n) % n;
		curVariant = 0;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		_applyEntry(curEntry, 0);
		bioTxt.y = INFO_Y + INFO_PAD_TOP;
	}

	function _changeVariant(dir:Int):Void
	{
		if (entries.length == 0) return;
		if (_debugMode) _debugSaveHistory();
		final e = entries[curEntry];
		if (e.variants.length == 0) return;
		curVariant = FlxMath.wrap(curVariant + dir, 0, e.variants.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		_applyEntry(curEntry, curVariant);
	}

	public function reloadEntries():Void
	{
		loadEntries();
		curEntry  = Std.int(FlxMath.bound(curEntry, 0, entries.length - 1));
		virtualIdx = curEntry;
		listScrollOffset = curEntry;
		_rebuildNames();
		if (entries.length > 0) _applyEntry(curEntry, 0);
	}

	public function jumpToEntry(index:Int):Void
	{
		if (index < 0 || index >= entries.length) return;
		final delta = index - curEntry;
		virtualIdx += delta;
		curEntry = index;
		curVariant = 0;
		_applyEntry(index, 0);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (subState != null) return;

		_updateArtistCycle(elapsed);
		_updateListScroll(elapsed);
		_updateBioScroll();
		_updateVariantDots();

		if (FlxG.keys.justPressed.F3)
		{
			_debugMode = !_debugMode;
			_debugLabel.visible = _debugMode;
			_debugBox1.visible  = _debugMode;
			_debugBox2.visible  = _debugMode;
			if (!_debugMode) { _debugSaveHistory(); _debugSelected = null; _debugDragging = false; }
		}

		if (_debugMode) { _updateDebug(); return; }

		if (entries.length > 1)
		{
			if (FlxG.mouse.deltaWheel.y != 0 && !FlxG.mouse.overlaps(bioBox))
				_changeEntry(Math.round(-FlxG.mouse.deltaWheel.y));
			if (controls.UI_UP_P   || FlxG.keys.justPressed.W) _changeEntry(-1);
			if (controls.UI_DOWN_P || FlxG.keys.justPressed.S) _changeEntry(1);
		}
		if (FlxG.keys.justPressed.A) _changeVariant(-1);
		if (FlxG.keys.justPressed.D) _changeVariant(1);

		if (charSprite != null)
		{
			charSprite.x = lockedX;
			charSprite.y = lockedY;
		}

		if (controls.RESET) FlxG.resetState();

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
	}

	function _updateDebug():Void
	{
		final mx:Float = FlxG.mouse.x;
		final my:Float = FlxG.mouse.y;

		if (FlxG.keys.justPressed.T)
			_debugPrintHistory();

		if (FlxG.mouse.justPressed)
		{
			_debugSelected = null;
			_debugDragging = false;
			_debugRotating = false;
			_debugOpacity  = false;
			_debugResizeW  = false;
			_debugResizeH  = false;

			final pt = new flixel.math.FlxPoint(mx, my);
			final candidates:Array<FlxSprite> = [charSprite, cast icon, _debugBox1, _debugBox2];
			for (g in _ghosts) candidates.push(g);

			for (s in candidates)
			{
				if (s != null && s.visible && s.overlapsPoint(pt))
				{
					_debugSelected = s;
					_debugDragOffX = mx - s.x;
					_debugDragOffY = my - s.y;
					_debugDragging = true;
					break;
				}
			}
		}

		if (FlxG.mouse.justReleased) _debugDragging = false;

		final isBox = _debugSelected == _debugBox1 || _debugSelected == _debugBox2;

		if (_debugSelected != null)
		{
			_debugRotating = !isBox && FlxG.keys.pressed.R;
			_debugOpacity  = !isBox && FlxG.keys.pressed.O;
			_debugResizeW  = isBox  && FlxG.keys.pressed.W;
			_debugResizeH  = isBox  && FlxG.keys.pressed.H;
		}

		var didModify = false;

		if (_debugDragging && _debugSelected != null && !_debugRotating && !_debugOpacity)
		{
			_debugSelected.x = mx - _debugDragOffX;
			_debugSelected.y = my - _debugDragOffY;
			if (_debugSelected == charSprite)
			{
				lockedX = charSprite.x;
				lockedY = charSprite.y;
			}
			didModify = !isBox;
		}

		if (_debugSelected != null && FlxG.mouse.wheel != 0)
		{
			if (_debugRotating)
				_debugSelected.angle += FlxG.mouse.wheel * 2.0;
			else if (_debugOpacity)
				_debugSelected.alpha = Math.max(0, Math.min(1, _debugSelected.alpha + FlxG.mouse.wheel * 0.05));
			else if (_debugResizeW && isBox)
			{
				final newW = Std.int(Math.max(10, _debugSelected.width + FlxG.mouse.wheel * 4));
				_redrawDebugBox(_debugSelected, newW, Std.int(_debugSelected.height));
			}
			else if (_debugResizeH && isBox)
			{
				final newH = Std.int(Math.max(10, _debugSelected.height + FlxG.mouse.wheel * 4));
				_redrawDebugBox(_debugSelected, Std.int(_debugSelected.width), newH);
			}
			else if (!isBox)
			{
				final delta:Float = FlxG.mouse.wheel * 0.01;
				_debugSelected.scale.x = Math.max(0.01, _debugSelected.scale.x + delta);
				_debugSelected.scale.y = Math.max(0.01, _debugSelected.scale.y + delta);
				_debugSelected.updateHitbox();
			}
			didModify = didModify || (!isBox && FlxG.mouse.wheel != 0);
		}

		if (didModify) _debugSaveHistory();

		if (FlxG.keys.justPressed.G && charSprite != null && charSprite.visible && _charBmp != null)
			_addGhost();

		if (FlxG.keys.justPressed.C)
			_clearGhosts();

		final isChar  = _debugSelected == charSprite;
		final isIcon  = _debugSelected == (cast icon : FlxSprite);
		final isGhost = _ghosts.indexOf(_debugSelected) >= 0;
		final boxNum  = _debugSelected == _debugBox1 ? 1 : _debugSelected == _debugBox2 ? 2 : 0;
		final selName = isChar ? 'charSprite' : isIcon ? 'icon' : isGhost ? 'ghost#${_ghosts.indexOf(_debugSelected)}' : isBox ? 'box$boxNum' : 'none';
		final modeStr = isBox
			? (_debugResizeW ? ' [W=ancho]' : _debugResizeH ? ' [H=alto]' : ' [W+scroll=ancho  H+scroll=alto]')
			: (_debugRotating ? ' [R=rotate]' : (_debugOpacity ? ' [O=opacity]' : ' [scroll=scale]'));

		if (_debugSelected != null)
			_debugLabel.text = '[F3] DEBUG$modeStr  |  $selName  [G]=ghost  [C]=clear  [T]=print all\nx:${Math.round(_debugSelected.x)}  y:${Math.round(_debugSelected.y)}  w:${Math.round(_debugSelected.width)}  h:${Math.round(_debugSelected.height)}${!isBox ? '  scale:${Math.round(_debugSelected.scale.x * 1000) / 1000}  angle:${Math.round(_debugSelected.angle)}  alpha:${Math.round(_debugSelected.alpha * 100)}%' : ''}';
		else
			_debugLabel.text = '[F3] DEBUG  |  click char/icon/box  |  R+scroll=rotate  |  O+scroll=opacity  |  scroll=scale  |  W+scroll=ancho  H+scroll=alto  |  [G]=ghost  [C]=clear  [T]=print all';
	}

	function _fitToBoxes(charAngle:Float = 0):Void
	{
		if (charSprite != null && charSprite.visible && charSprite.frameWidth > 0 && charSprite.frameHeight > 0)
		{
			final bx:Float = _debugBox1.x;
			final by:Float = _debugBox1.y;
			final bw:Float = _debugBox1.width;
			final bh:Float = _debugBox1.height;
			final rotated:Bool = (charAngle % 180 != 0);
			final fw:Float = rotated ? charSprite.frameHeight : charSprite.frameWidth;
			final fh:Float = rotated ? charSprite.frameWidth  : charSprite.frameHeight;
			final s:Float  = Math.min(bw / fw, bh / fh);
			charSprite.scale.set(s, s);
			charSprite.angle = charAngle;
			charSprite.updateHitbox();
			charSprite.x = bx + (bw - charSprite.width)  * 0.5;
			charSprite.y = by + (bh - charSprite.height) * 0.5;
			lockedX = charSprite.x;
			lockedY = charSprite.y;
		}

		if (icon != null)
		{
			final bx:Float = _debugBox2.x;
			final by:Float = _debugBox2.y;
			final bw:Float = _debugBox2.width;
			final bh:Float = _debugBox2.height;
			final fw:Float = icon.frameWidth  > 0 ? icon.frameWidth  : (icon.width  / icon.scale.x);
			final fh:Float = icon.frameHeight > 0 ? icon.frameHeight : (icon.height / icon.scale.y);
			final s:Float  = Math.min(bw / fw, bh / fh);
			icon.scale.set(s, s);
			icon.updateHitbox();
			icon.x = bx + (bw - fw * s) * 0.5;
			icon.y = by + (bh - fh * s) * 0.5;
		}
	}

	function _makeDebugBox(x:Float, y:Float, w:Int, h:Int):FlxSprite
	{
		final s = new FlxSprite(x, y);
		s.scrollFactor.set();
		s.visible = false;
		_redrawDebugBox(s, w, h);
		add(s);
		return s;
	}

	function _redrawDebugBox(s:FlxSprite, w:Int, h:Int):Void
	{
		s.makeGraphic(w, h, 0x00000000, true);
		final bmd = s.pixels;
		final col:Int = 0xFFFF0000;
		final t:Int = 2;
		bmd.fillRect(new openfl.geom.Rectangle(0,     0,     w,  t), col);
		bmd.fillRect(new openfl.geom.Rectangle(0,     h - t, w,  t), col);
		bmd.fillRect(new openfl.geom.Rectangle(0,     0,     t,  h), col);
		bmd.fillRect(new openfl.geom.Rectangle(w - t, 0,     t,  h), col);
		s.dirty = true;
	}

	function _debugKey():String
	{
		final e = entries.length > 0 ? entries[curEntry] : null;
		if (e == null) return '?';
		var dispName = e.displayName;
		var charId   = e.charId;
		if (e.variants.length > 0 && curVariant < e.variants.length)
		{
			final v:Dynamic = e.variants[curVariant];
			if (v.display_name != null) dispName = Std.string(v.display_name);
			if (v.char        != null) charId   = Std.string(v.char);
		}
		return '$dispName [$charId]${curVariant > 0 ? " (v$curVariant)" : ""}';
	}

	function _debugSaveHistory():Void
	{
		final key = _debugKey();
		_debugHistory.set(key, {
			charX:     charSprite.x,
			charY:     charSprite.y,
			charScale: charSprite.scale.x,
			charAngle: charSprite.angle,
			charAlpha: charSprite.alpha,
			iconX:     icon.x,
			iconY:     icon.y,
			iconScale: icon.scale.x
		});
	}

	function _debugPrintHistory():Void
	{
		_debugSaveHistory();
		trace('=== BIOS DEBUG HISTORY (${Lambda.count(_debugHistory)} personajes) ===');
		for (key => data in _debugHistory)
			trace('[$key]\n  char  => x:${Math.round(data.charX)}  y:${Math.round(data.charY)}  scale:${data.charScale}  angle:${Math.round(data.charAngle)}  alpha:${Math.round(data.charAlpha * 100)}%\n  icon  => x:${Math.round(data.iconX)}  y:${Math.round(data.iconY)}  scale:${data.iconScale}');
		trace('=== FIN ===');
	}

	function _addGhost():Void
	{
		final ghost = new FlxSprite(charSprite.x, charSprite.y);
		ghost.makeGraphic(charSprite.frameWidth, charSprite.frameHeight, 0x00000000, true);
		ghost.pixels.copyPixels(_charBmp, _charBmp.rect, new Point(0, 0));
		ghost.dirty   = true;
		ghost.scale.copyFrom(charSprite.scale);
		ghost.angle   = charSprite.angle;
		ghost.flipX   = charSprite.flipX;
		ghost.alpha   = 0.3;
		ghost.scrollFactor.set();
		ghost.updateHitbox();
		_ghosts.push(ghost);
		add(ghost);
		remove(charSprite, true);
		add(charSprite);
		if (_debugLabel != null) { remove(_debugLabel, true); add(_debugLabel); }
	}

	function _clearGhosts():Void
	{
		for (g in _ghosts) { remove(g, true); g.destroy(); }
		_ghosts = [];
		_debugSelected = null;
	}

	function _updateArtistCycle(elapsed:Float):Void
	{
		if (artists.length <= 1) return;
		_artistTimer += elapsed;
		if (!artistFading)
		{
			if (_artistTimer >= ARTIST_CYCLE_TIME)
			{
				artistFading  = true;
				artistFadeDir = 1;
				_artistTimer  = 0;
			}
		}
		else
		{
			artistName.alpha -= (elapsed / ARTIST_FADE_TIME) * artistFadeDir;
			if (artistFadeDir == 1 && artistName.alpha <= 0)
			{
				artistName.alpha = 0;
				artistIdx = (artistIdx + 1) % artists.length;
				artistName.text = 'by\n${artists[artistIdx]}';
				_fitArtistName();
				artistFadeDir = -1;
			}
			else if (artistFadeDir == -1 && artistName.alpha >= 1)
			{
				artistName.alpha = 1;
				artistFading     = false;
				_artistTimer     = 0;
			}
		}
	}

	function _updateListScroll(elapsed:Float):Void
	{
		listScrollOffset += (virtualIdx - listScrollOffset) * (1 - Math.exp(-elapsed * 12));
		final n = entries.length;
		namesGrp.forEach((t:FlxText) -> {
			final raw     = t.ID - listScrollOffset;
			final wrapped = raw - Math.round(raw / n) * n;
			t.y     = LIST_CENTER_Y + wrapped * LIST_ITEM_H - t.height * 0.5;
			final dist = Math.abs(wrapped);
			t.color   = (dist < 0.6) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.alpha   = dist < 3.5 ? 1.0 : dist < 4.5 ? 0.5 : dist < 5.5 ? 0.2 : 0.0;
			t.visible = t.alpha > 0;
		});

		if (n > 0 && listScrollThumb != null)
		{
			final thumbH = Std.int(Math.max(16, LSB_H / (n * 0.5)));
			if (listScrollThumb.height != thumbH)
				listScrollThumb.makeGraphic(LSB_W, thumbH, FlxColor.WHITE);
			final pos = n > 1 ? ((virtualIdx % n) + n) % n / n : 0.0;
			listScrollThumb.y = LSB_Y + pos * (LSB_H - thumbH);
		}
	}

	function _updateBioScroll():Void
	{
		final textTaller = bioTxt.height > INFO_H;
		bioScrollTrack.visible = textTaller;
		bioScrollThumb.visible = textTaller;

		if (textTaller)
		{
			if (FlxG.mouse.deltaWheel.y != 0 && FlxG.mouse.overlaps(bioBox))
			{
				bioTxt.y += FlxG.mouse.deltaWheel.y * 10;
				bioTxt.y  = FlxMath.bound(bioTxt.y, INFO_Y - (bioTxt.height - INFO_H), INFO_Y + INFO_PAD_TOP);
				bioTxt.clipRect = new flixel.math.FlxRect(0, INFO_Y - bioTxt.y, INFO_W - INFO_PAD_X - INFO_PAD_RIGHT, INFO_H);
			}

			final trackH    = INFO_H - SCROLL_PAD * 2;
			final totalText = bioTxt.height;
			final ratio     = INFO_H / totalText;
			final thumbH    = Std.int(Math.max(20, trackH * ratio));
			if (bioScrollThumb.height != thumbH)
				bioScrollThumb.makeGraphic(SCROLL_W, thumbH, FlxColor.WHITE);

			final scrollRange = totalText - INFO_H;
			final scrollPos   = scrollRange > 0 ? FlxMath.bound((INFO_Y + INFO_PAD_TOP - bioTxt.y) / scrollRange, 0, 1) : 0.0;
			bioScrollThumb.y  = bioScrollTrack.y + scrollPos * (trackH - thumbH);
		}
	}

	function _updateVariantDots():Void
	{
		if (variantDots.visible)
		{
			variantDots.x = charName.x + (charName.width - variantDots.width) * 0.5;
			variantDots.y = charName.y + charName.height + 4;
		}
	}

	function _swapIcon(iconId:String):Void
	{
		if (icon.getCharacter() == iconId) return;
		try { icon.changeIcon(iconId); }
		catch (e:Dynamic) { trace('BIOS: failed to load icon "$iconId": $e'); }
	}

	function _fitCharName():Void
	{
		charName.fieldWidth = 0;
		var size = TITLE_FONT_SIZE;
		charName.size = size;
		final maxW = TITLE_W / TITLE_FONT_SCALE;
		while (charName.width > maxW && size > 32) { size--; charName.size = size; }
		charName.fieldWidth = Std.int(maxW);
		charName.updateHitbox();
		charName.y = TITLE_Y + (TITLE_H - charName.height * TITLE_FONT_SCALE) * 0.5;
	}

	function _setArtists(raw:String):Void
	{
		var parts:Array<String> = [];
		for (p in ~/\s*[\/&\+]\s*/.split(raw))
		{
			final s = p.trim();
			if (s.length > 0) parts.push(s);
		}
		if (parts.length == 0) parts = [''];
		artists      = parts;
		artistIdx    = 0;
		_artistTimer = 0;
		artistFading = false;
		artistName.alpha = 1;
		artistName.text  = raw != '' ? 'by\n${parts[0]}' : '';
		_fitArtistName();
	}

	function _fitArtistName():Void
	{
		artistName.fieldWidth = 0;
		var size = ARTIST_MAX_SIZE;
		artistName.size = size;
		final maxW = ARTIST_W / ARTIST_FONT_SCALE;
		while (artistName.width > maxW && size > ARTIST_MIN_SIZE) { size--; artistName.size = size; }
		artistName.fieldWidth = Std.int(maxW);
		artistName.updateHitbox();
		artistName.x = ARTIST_X;
		artistName.y = ARTIST_Y + (ARTIST_H - artistName.height * ARTIST_FONT_SCALE) * 0.5;
	}

	function _updateDots():Void
	{
		final e = entries.length > 0 ? entries[curEntry] : null;
		if (e == null || e.variants.length <= 1) { variantDots.visible = false; return; }
		variantDots.visible = true;
		var dots = '';
		for (i in 0...e.variants.length) dots += (i == curVariant) ? '● ' : '○ ';
		variantDots.text = dots.rtrim();
	}

	inline function _str(v:Dynamic, fallback:String):String
		return (v != null) ? Std.string(v) : fallback;

	inline function _arr2(v:Dynamic, fallback:Array<Float>):Array<Float>
		return (v != null && (v:Array<Dynamic>).length >= 2) ? [v[0], v[1]] : fallback;

	override function destroy():Void
	{
		charLoadTimer?.cancel();
		_releaseCharBmp();
		super.destroy();
	}
}
