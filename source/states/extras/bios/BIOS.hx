package states.extras.bios;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if mobile
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
#end

import objects.HealthIcon;

import flixel.*;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

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
	var antialiasing:Bool;
	var charAngle:Float;
	var charOffset:Array<Float>;
	var iconOffset:Array<Float>;
	var listOrder:Int;
	var filePath:String;
	var variants:Array<Dynamic>;
}

class BIOS extends SonicSubState
{
	static inline final BIO_DIR = 'assets/exe/extras/bios/characters';

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

	public var bioBox:FlxSprite;
	var bioTxt:FlxText;
	var bioScrollTrack:FlxSprite;
	var bioScrollThumb:FlxSprite;
	var _draggingBioThumb:Bool = false;
	final _bioClipRect:flixel.math.FlxRect = new flixel.math.FlxRect();

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

	static var _frameCache:Map<String, { ?bmp:BitmapData, ?graphic:flixel.graphics.FlxGraphic, #if mobile ?frames:FlxAtlasFrames, ?frame:FlxFrame, #end offset:Array<Float> }> = new Map();

	var iconBoundsBox:FlxSprite;

	#if mobile public var cooldownTimer:Float = 0.0; #end

	override function create():Void
	{
		super.create();

		loadEntries();
		_loadIdleAtlas();

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
			bmd.setPixel32(x, 0, 0xFF000000 | (r << 16) | (g << 8) | b);
		}
		final rowRect = new Rectangle(0, 0, w, 1);
		final rowDest = new Point(0, 0);
		for (y in 1...h)
		{
			rowDest.y = y;
			bmd.copyPixels(bmd, rowRect, rowDest);
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

		final spikestop = new FlxBackdrop(Paths.getBitmapData('assets/exe/extras/bios/backdrop.webp'), Y);
		spikestop.velocity.y = 60;
		spikestop.screenCenter();
		spikestop.scrollFactor.set();
		spikestop.blend = openfl.display.BlendMode.MULTIPLY;
		add(spikestop);

		_buildShowcase();
		_buildInfoBox();
		_buildList();
		_buildOverlays();

		iconBoundsBox = _makeBoundsBox(692, 466, 74,  72);

		if (entries.length > 0)
			_applyEntry(0, 0);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Bios Menu", null);
		#end

		#if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
	}

	function loadEntries():Void
	{
		entries = [];
		var scanPath = BIO_DIR.endsWith('/') ? BIO_DIR : BIO_DIR + '/';

		for (file in Paths.readDirectory(scanPath))
		{
			if (!file.endsWith('.json')) continue;
			
			final path = scanPath + file;
			var jsonText:String = Paths.getContent(path);
			
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
			final antialiasing:Bool = (base.antialiasing == false) ? false : ClientPrefs.data.antialiasing;
			final charAngle:Float  = (base.char_angle != null) ? base.char_angle : 0.0;
			final charOff          = _arr2(base.char_offset, [300.0, 100.0]);
			final iconOff          = _arr2(base.icon_offset, [786.0, 425.0]);
			final order:Int        = (d.list_position != null) ? d.list_position : 9999;

			entries.push({
				displayName: displayName, charId: charId, iconId: iconId,
				mod: mod, bio: bio, artist: artist, scale: scale,
				flipX: flipX, antialiasing: antialiasing, charAngle: charAngle, charOffset: charOff, iconOffset: iconOff,
				listOrder: order, filePath: path, variants: variants
			});
		}

		entries.sort((a, b) -> a.listOrder - b.listOrder);
	}

	function _collectModCharPairs():Array<{mod:String, charId:String}>
	{
		final seen = new Map<String, Bool>();
		final pairs:Array<{mod:String, charId:String}> = [];

		function add(mod:String, charId:String):Void
		{
			final key = '$mod|$charId';
			if (seen.exists(key)) return;
			seen.set(key, true);
			pairs.push({mod: mod, charId: charId});
		}

		for (e in entries)
		{
			add(e.mod, e.charId);
			for (v in e.variants)
				add(_str(v.mod, e.mod), _str(v.char, e.charId));
		}

		return pairs;
	}

	function _loadIdleAtlas():Void
	{
		if (!BIOSCharacter.exists())
			BIOSCharacter.generate(_collectModCharPairs());

		if (!BIOSCharacter.exists())
			return;

		var manifest:Dynamic;
		try
		{
			final atlasBmp = BitmapData.fromFile(BIOSCharacter.atlasPng());
			manifest = Json.parse(File.getContent(BIOSCharacter.atlasJson()));

			for (key in Reflect.fields(manifest))
			{
				if (_frameCache.exists(key)) continue;

				final e:Dynamic = Reflect.field(manifest, key);
				final w:Int = e.w, h:Int = e.h;
				final crop = new BitmapData(w, h, true, 0x00000000);
				crop.copyPixels(atlasBmp, new Rectangle(e.x, e.y, w, h), new Point(0, 0));
				_frameCache.set(key, { bmp: crop, offset: [e.offX, e.offY] });
			}

			atlasBmp.dispose();
		}
		catch (e:Dynamic)
		{
			trace('BIOS: failed to load idle atlas: $e');
		}
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
		if (icon.getCharacter() == "face"){
			icon.visible = false;
		}else if (icon.getCharacter().contains("requital")){
			//betterr
			icon.replaceColor(0xFFFFFFFF, FlxColor.TRANSPARENT);
		}
		savedIconScale = icon.scale.x;
		add(icon);

		charName = new FlxText(460, 34, 0, e0 != null ? e0.displayName : '', 136);
		charName.setFormat(Paths.font(Language.fontOrCJK('NiseSegaSonic.ttf')), 136, FlxColor.WHITE, CENTER);
		charName.antialiasing = ClientPrefs.data.antialiasing;
		charName.scale.set(0.5, 0.5);
		charName.scrollFactor.set();
		add(charName);
		_fitCharName();

		artistName = new FlxText(471, 588, 0, '', 80);
		artistName.setFormat(Paths.font(Language.fontOrCJK('NiseSegaSonic.ttf')), 80, FlxColor.WHITE, CENTER);
		artistName.antialiasing = ClientPrefs.data.antialiasing;
		artistName.scale.set(0.5, 0.5);
		artistName.scrollFactor.set();
		add(artistName);
		if (e0 != null) _setArtists(e0.artist);

		variantDots = new FlxText(0, FlxG.height - 60, 0, '', 44);
		variantDots.setFormat(Paths.font('NiseSegaSonic.ttf'), 44, FlxColor.WHITE, CENTER);
		variantDots.scale.set(0.5, 0.5);
		variantDots.scrollFactor.set();
		variantDots.visible = false;
		add(variantDots);

		final charBiosSprite = new FlxSprite(36, 19);
		charBiosSprite.loadGraphic(Paths.getBitmapData('assets/exe/extras/bios/characterbios.webp'));
		charBiosSprite.scrollFactor.set();
		add(charBiosSprite);
	}

	function _buildInfoBox():Void
	{
		bioBox = new FlxSprite(845, 36);
		bioBox.makeGraphic(407, 642, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRect(bioBox, 0, 0, 407, 642, FlxColor.TRANSPARENT, {thickness: 7, color: FlxColor.WHITE});
		bioBox.scrollFactor.set();
		add(bioBox);

		bioTxt = new FlxText(845 + 16, 36 + 13, 407 - 16 - 80, '', Language.cjkSize(23));
		bioTxt.setFormat(Paths.font(Language.fontOrCJK('smallass.ttf')), Language.cjkSize(23), FlxColor.WHITE, LEFT);
		bioTxt.antialiasing = ClientPrefs.data.antialiasing;
		bioTxt.scrollFactor.set();
		_bioClipRect.set(0, 0, 407 - 16 - 80, 642 - 13);
		bioTxt.clipRect = _bioClipRect;
		add(bioTxt);

		final trackH = 642 - 10 * 2;
		final tx = 407 - 8 - 10;
		final ty = 10;

		bioScrollTrack = new FlxSprite(845 + tx, 36 + ty).makeGraphic(8, trackH, 0x44FFFFFF);
		bioScrollTrack.scrollFactor.set();
		bioScrollTrack.visible = false;
		add(bioScrollTrack);

		bioScrollThumb = new FlxSprite(845 + tx, 36 + ty).makeGraphic(8, 40, FlxColor.WHITE);
		bioScrollThumb.scrollFactor.set();
		bioScrollThumb.visible = false;
		add(bioScrollThumb);
	}

	function _buildList():Void
	{
		listScrollTrack = new FlxSprite(10, 138).makeGraphic(6, Std.int(484), 0x44FFFFFF);
		listScrollTrack.scrollFactor.set();
		add(listScrollTrack);

		listScrollThumb = new FlxSprite(10, 138).makeGraphic(6, 40, FlxColor.WHITE);
		listScrollThumb.scrollFactor.set();
		add(listScrollThumb);

		namesGrp = new FlxTypedGroup<FlxText>();
		_rebuildNames();
		add(namesGrp);
	}

	function _buildOverlays():Void
	{
		final charBiosOverlay = new FlxSprite(36, 19);
		if (Assets.exists('assets/exe/extras/bios/characterbios_overlay.webp'))
		{
			charBiosOverlay.loadGraphic(Paths.getBitmapData('assets/exe/extras/bios/characterbios_overlay.webp'));
			charBiosOverlay.scrollFactor.set();
			add(charBiosOverlay);
		}
	}

	function _rebuildNames():Void
	{
		namesGrp.clear();
		final font = Paths.font(Language.fontOrCJK('NiseSegaSonic.ttf'));
		final size = Language.cjkSize(68);
		final aa   = ClientPrefs.data.antialiasing;
		for (i in 0...entries.length)
		{
			final t = new FlxText(52, 0, 0, entries[i].displayName, size);
			t.setFormat(font, size, FlxColor.WHITE, LEFT);
			t.antialiasing = aa;
			t.scale.set(0.5, 0.5);
			t.updateHitbox();
			t.scrollFactor.set(0, 0);
			t.ID = i;
			namesGrp.add(t);
		}
	}

	public function isXenoLuis(?x:String){
		return (x != null) ? x.toLowerCase() == "luis" : entries[curEntry].displayName.toLowerCase() == "luis";
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
		var antialiasing = e.antialiasing;
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
			antialiasing = (v.antialiasing == false) ? false : ClientPrefs.data.antialiasing;
			charAngle = (v.char_angle != null) ? v.char_angle : charAngle;
			charOff   = _arr2(v.char_offset, charOff);
			iconOff   = _arr2(v.icon_offset, iconOff);
			mod       = _str(v.mod,          mod);
		}

		if (isXenoLuis(dispName)){
			final chance = ((dispName.length > 0) ? dispName.length*7 : FlxG.random.int(20, 50));
			if (!FlxG.random.bool(chance)){
				dispName = "Xenophanes";
				if (bio.toLowerCase().contains("luis")) bio = bio.replace("Luis", "Xenophanes");
			}
		}
		
		charName.text = dispName;
		
		_fitCharName();
		_setArtists(artist);
		_updateDots();
		_updateVariantDots();

		bioTxt.text = bio;
		bioTxt.y = 36 + 13;
		_bioClipRect.set(0, 0, 407 - 16 - 80, 642 - 13);
		bioTxt.clipRect = _bioClipRect;

		for (t in namesGrp.members)
			t.color = (t.ID == index) ? FlxColor.YELLOW : FlxColor.WHITE;

		Mods.currentModDirectory = mod;
		if (icon.getCharacter() != iconId) _swapIcon(iconId);
		icon.setPosition(iconOff[0], iconOff[1]);

		_loadCharFrame(charId, mod, scale, flipX, antialiasing, charOff);
		_fitToBoxes(charAngle);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Bios Menu", 'Checking $dispName');
		#end
	}

	var charYOffset:Float = 0;
	function _loadCharFrame(charId:String, mod:String, scale:Float, flipX:Bool, antialiasing:Bool, charOff:Array<Float>):Void
	{
		if (_lastCharId == charId && _lastCharMod == mod)
		{
			charSprite.scale.set(scale, scale);
			charSprite.flipX = flipX;
			charSprite.antialiasing = antialiasing;
			charSprite.updateHitbox();
			// charSprite.setPosition(lockedX, lockedY);
			charSprite.visible = true;
			return;
		}

		final cacheKey = '$mod|$charId';
		var cached = _frameCache.get(cacheKey);

		if (cached == null)
		{
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

			#if mobile
			final atlasFrames:FlxAtlasFrames = Paths.getAtlas(imageKey);
			if (atlasFrames == null) { charSprite.visible = false; return; }

			var matched:FlxFrame = _findFrameByPrefix(atlasFrames, idleAnim.prefix);
			if (matched == null && idleAnim.altPrefix != null && idleAnim.altPrefix != idleAnim.prefix)
				matched = _findFrameByPrefix(atlasFrames, idleAnim.altPrefix);

			if (matched == null) { charSprite.visible = false; return; }

			cached = { frames: atlasFrames, frame: matched, offset: animOffset };
			#else
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

			final frameBmp:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0x00000000);
			frameBmp.copyPixels(sheetBmp, rect, new Point(0, 0));
			sheetBmp.dispose();

			cached = { bmp: frameBmp, offset: animOffset };
			#end
			_frameCache.set(cacheKey, cached);
		}

		if (cached.bmp != null)
		{
			if (cached.graphic == null || cached.graphic.bitmap == null || cached.graphic.bitmap.width == 0)
			{
				cached.graphic = flixel.graphics.FlxGraphic.fromBitmapData(cached.bmp, false, 'bios_char_$cacheKey');
				cached.graphic.persist = true;
				cached.graphic.destroyOnNoUse = false;
			}
			charSprite.loadGraphic(cached.graphic);
		}
		#if mobile
		else
		{
			charSprite.frames = cached.frames;
			charSprite.frame  = cached.frame;
		}
		#end

		charSprite.scale.set(scale, scale);
		charSprite.flipX = flipX;
		charSprite.antialiasing = antialiasing;
		charSprite.updateHitbox();

		lockedX = charOff[0] - cached.offset[0] * scale;
		lockedY = charOff[1] - cached.offset[1] * scale;
		charSprite.setPosition(charOff[0], charOff[1]);
		charSprite.alpha = 0;
		charYOffset = charSprite.y;
		charSprite.y = charYOffset - 20;
		FlxTween.cancelTweensOf(charSprite);
		FlxTween.tween(charSprite, { alpha: 1, y: charYOffset }, 0.33, { ease: FlxEase.cubeOut});
		charSprite.visible = true;


		_lastCharId  = charId;
		_lastCharMod = mod;
	}

	#if mobile
	function _findFrameByPrefix(atlasFrames:FlxAtlasFrames, prefix:String):FlxFrame
	{
		if (prefix == null || prefix == '') return null;
		for (f in atlasFrames.frames)
			if (f.name != null && f.name.indexOf(prefix) == 0)
				return f;
		return null;
	}
	#else
	function _resolveImagePath(imageKey:String, mod:String):String
	{
		final pngKey = 'images/$imageKey.webp';
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
	#end

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
		#if mobile cooldownTimer = 0.15; #end
		if (entries.length <= 1) return;
		virtualIdx += delta;
		final n = entries.length;
		curEntry = ((Std.int(Math.round(virtualIdx)) % n) + n) % n;
		curVariant = 0;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		_applyEntry(curEntry, 0);
	}

	function _changeVariant(dir:Int):Void
	{
		if (entries.length == 0) return;
		final e = entries[curEntry];
		if (e.variants.length == 0) return;
		curVariant = FlxMath.wrap(curVariant + dir, 0, e.variants.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		_applyEntry(curEntry, curVariant);
	}

	public function reloadEntries():Void
	{
		for (c in _frameCache) if (c.bmp != null) c.bmp.dispose();
		_frameCache = new Map();
		_lastCharId  = '';
		_lastCharMod = '';

		loadEntries();
		_loadIdleAtlas();
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

		#if mobile if (cooldownTimer > 0) cooldownTimer -= elapsed; #end

		if (subState != null || _closing) return;

		_updateArtistCycle(elapsed);
		_updateListScroll(elapsed);
		_updateBioScroll();

		if (entries.length > 1)
		{
			if ((FlxG.mouse.deltaWheel.y != 0 #if mobile || (Math.abs(deltaMouseY) >= 5 && pressHolding && cooldownTimer <= 0) #end) && !FlxG.mouse.overlaps(bioBox))
				_changeEntry(Math.round(#if !mobile -FlxG.mouse.deltaWheel.y #else -deltaMouseY/Math.abs(deltaMouseY) #end));
			if (controls.UI_UP_P || controls.UI_DOWN_P) _changeEntry(controls.UI_UP_P ? -1 : 1);
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) _changeVariant(controls.UI_LEFT_P ? -1 : 1);

		if (controls.RESET) FlxG.resetState();

		if (controls.BACK #if mobile || backPressed #end)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}
	}

	function _fitToBoxes(charAngle:Float = 0):Void
	{
		if (charSprite != null && charSprite.visible && charSprite.frameWidth > 0 && charSprite.frameHeight > 0)
		{
			charSprite.angle = charAngle;
			charSprite.updateHitbox();
			// charSprite.setPosition(lockedX, lockedY);
		}

		if (icon != null)
		{
			final bx:Float = iconBoundsBox.x;
			final by:Float = iconBoundsBox.y;
			final bw:Float = iconBoundsBox.width;
			final bh:Float = iconBoundsBox.height;
			final fw:Float = icon.frameWidth  > 0 ? icon.frameWidth  : (icon.width  / icon.scale.x);
			final fh:Float = icon.frameHeight > 0 ? icon.frameHeight : (icon.height / icon.scale.y);
			final s:Float  = Math.min(bw / fw, bh / fh);
			icon.scale.set(s, s);
			icon.updateHitbox();
			icon.x = bx + (bw - fw * s) * 0.5;
			icon.y = by + (bh - fh * s) * 0.5;
		}
	}

	function _makeBoundsBox(x:Float, y:Float, w:Int, h:Int):FlxSprite
	{
		final s = new FlxSprite(x, y);
		s.makeGraphic(w, h, 0x00000000, true);
		s.scrollFactor.set();
		s.visible = false;
		add(s);
		return s;
	}

	function _updateArtistCycle(elapsed:Float):Void
	{
		if (artists.length <= 1) return;
		_artistTimer += elapsed;
		if (!artistFading)
		{
			if (_artistTimer >= 5.0)
			{
				artistFading  = true;
				artistFadeDir = 1;
				_artistTimer  = 0;
			}
		}
		else
		{
			artistName.alpha -= (elapsed / 0.5) * artistFadeDir;
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
		for (t in namesGrp.members)
		{
			final raw     = t.ID - listScrollOffset;
			final wrapped = raw - Math.round(raw / n) * n;
			t.y     = 380 + wrapped * 44 - t.height * 0.5;
			final dist = Math.abs(wrapped);
			t.color   = (dist < 0.6) ? FlxColor.YELLOW : FlxColor.WHITE;
			t.alpha   = dist < 3.5 ? 1.0 : dist < 4.5 ? 0.5 : dist < 5.5 ? 0.2 : 0.0;
			t.visible = t.alpha > 0;
		}

		if (n > 0 && listScrollThumb != null)
		{
			final thumbH = Std.int(Math.max(16, 484 / (n * 0.5)));
			if (listScrollThumb.height != thumbH)
				listScrollThumb.makeGraphic(6, thumbH, FlxColor.WHITE);
			final pos = n > 1 ? ((virtualIdx % n) + n) % n / n : 0.0;
			listScrollThumb.y = 138 + pos * (484 - thumbH);
		}
	}

	function _updateBioScroll():Void
	{
		final viewH = 642 - 13;
		final textTaller = bioTxt.height > viewH;
		bioScrollTrack.visible = textTaller;
		bioScrollThumb.visible = textTaller;

		if (textTaller)
		{
			if ((FlxG.mouse.deltaWheel.y != 0 #if mobile || (deltaMouseY != 0 && pressHolding) #end) && FlxG.mouse.overlaps(bioBox))
			{
				bioTxt.y += #if !mobile FlxG.mouse.deltaWheel.y * 10 #else deltaMouseY #end;
				bioTxt.y  = FlxMath.bound(bioTxt.y, 36 - (bioTxt.height - 642), 36 + 13);
				_bioClipRect.set(0, (36 + 13) - bioTxt.y, 407 - 16 - 80, viewH);
				bioTxt.clipRect = _bioClipRect;
			}

			if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(bioScrollThumb))
				_draggingBioThumb = true;
			if (FlxG.mouse.justReleased) 
				_draggingBioThumb = false;

			final trackH    = 642 - 10 * 2;
			final totalText = bioTxt.height;
			final ratio     = viewH / totalText;
			final thumbH    = Std.int(Math.max(20, trackH * ratio));
			if (bioScrollThumb.height != thumbH)
				bioScrollThumb.makeGraphic(8, thumbH, FlxColor.WHITE);

			if (_draggingBioThumb)
			{
				final trackTop = bioScrollTrack.y;
				final usableTrack = trackH - thumbH;
				final thumbTopY = FlxMath.bound(FlxG.mouse.y - thumbH * 0.5, trackTop, trackTop + usableTrack);
				final dragScrollPos = usableTrack > 0 ? (thumbTopY - trackTop) / usableTrack : 0.0;
				final dragRange = totalText - viewH;
				bioTxt.y = 36 + 13 - dragScrollPos * dragRange;
				bioTxt.y = FlxMath.bound(bioTxt.y, 36 - (bioTxt.height - 642), 36 + 13);
				_bioClipRect.set(0, (36 + 13) - bioTxt.y, 407 - 16 - 80, viewH);
				bioTxt.clipRect = _bioClipRect;
			}
			 
			final scrollRange = totalText - viewH;
			final scrollPos   = scrollRange > 0 ? FlxMath.bound((36 + 13 - bioTxt.y) / scrollRange, 0, 1) : 0.0;
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
		try {
			icon.changeIcon(iconId);
			if (icon.getCharacter() == "face"){
				icon.visible = false;
			}else if (icon.getCharacter().contains("requital")){
				icon.replaceColor(0xFFFFFFFF, FlxColor.TRANSPARENT);
			} 
		}
		catch (e:Dynamic) { trace('BIOS: failed to load icon "$iconId": $e'); }
	}

	function _fitCharName():Void
	{
		charName.fieldWidth = 0;
		var size = 136;
		charName.size = size;
		final maxW = 328 / 0.5;
		if (charName.width > maxW)
		{
			size = Std.int(Math.max(32, Math.floor(size * maxW / charName.width)));
			charName.size = size;
			while (charName.width > maxW && size > 32) { size--; charName.size = size; }
		}
		charName.fieldWidth = Std.int(maxW);
		charName.updateHitbox();
		charName.y = 34 + (100 - charName.height * 0.5) * 0.5;
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
		var size = 80;
		artistName.size = size;
		final maxW = 332 / 0.5;
		while (artistName.width > maxW && size > 28) { size--; artistName.size = size; }
		artistName.fieldWidth = Std.int(maxW);
		artistName.updateHitbox();
		artistName.x = 471;
		artistName.y = 588 + (100 - artistName.height * 0.5) * 0.5;
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

}
