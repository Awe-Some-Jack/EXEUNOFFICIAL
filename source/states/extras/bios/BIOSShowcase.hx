package states.extras.bios;

import flixel.*;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSpriteUtil;
import objects.*;
import flixel.addons.display.shapes.*;
import sys.thread.Thread;
import sys.thread.Mutex;
import openfl.display.BitmapData;

class BIOSShowcase
{
	var bios:BIOS;

	public var character:Character;
	public var icon:HealthIcon;

	var textCenter:FlxSprite;
	var charName:FlxText;
	var artistName:FlxText;
	var circle:FlxShapeCircle;
	var circleBig:FlxShapeCircle;
	var variantDots:FlxText;

	static inline final TITLE_X:Int  = 460;
	static inline final TITLE_Y:Int  = 34;
	static inline final TITLE_W:Int  = 328;
	static inline final TITLE_H:Int  = 100;

	static inline final ARTIST_X:Int = 471;
	static inline final ARTIST_Y:Int = 588;
	static inline final ARTIST_W:Int = 332;
	static inline final ARTIST_H:Int = 100;
	static inline final ARTIST_MAX_SIZE:Int = 40;
	static inline final ARTIST_MIN_SIZE:Int = 14;

	var charBiosSprite:FlxSprite;

	var abDebug:Bool   = false;
	var abTarget:Int   = 0; // 0=move, 1=size
	var abLabel:FlxText;
	var abBox:FlxSprite;

	var _ax:Float = ARTIST_X;
	var _ay:Float = ARTIST_Y;
	var _aw:Float = ARTIST_W;
	var _ah:Float = ARTIST_H;

	static inline final ARTIST_CYCLE_TIME:Float = 5.0;
	static inline final ARTIST_FADE_TIME:Float  = 0.5;
	var _artists:Array<String> = [];
	var _artistIdx:Int   = 0;
	var _artistTimer:Float = 0;
	var _artistFading:Bool = false;
	var _artistFadeDir:Int = 1; // 1=fadeout, -1=fadein

	var _danceTimer:Float = 0;
	var _danced:Bool = false;
	var _danceLeftTag:String  = null;
	var _danceRightTag:String = null;

	public var lockedX:Float = 0;
	public var lockedY:Float = 0;

	var _preloadMutex:Mutex = new Mutex();
	var _pendingBitmaps:Map<String, BitmapData> = [];
	var _preloadCancelToken:{ cancelled:Bool } = { cancelled: false };

	public function new(parent:BIOS)
	{
		bios = parent;
		var bc = bios.biosCharacter;

		if (bc.charMods_list.length > 0 && bc.charMods_list[0] != '')
			Mods.currentModDirectory = bc.charMods_list[0];

		character = new Character(0, 0, bc.chars_list.length > 0 ? bc.chars_list[0] : 'bf', false);
		character.scrollFactor.set();
		if (bc.scales_list.length > 0) { var s = bc.scales_list[0]; character.scale.set(s, s); character.updateHitbox(); }
		if (bc.flipX_list.length  > 0) character.flipX = bc.flipX_list[0];
		bios.add(character);
		_forceIdleLoop();

		circle = new FlxShapeCircle(727, 501, 40, {thickness:0, color:FlxColor.TRANSPARENT}, FlxColor.BLACK);
		circle.alpha = 0.75;
		circle.scrollFactor.set();
		bios.add(circle);

		circleBig = new FlxShapeCircle(721, 495, 46, {thickness:4, color:FlxColor.BLACK}, FlxColor.TRANSPARENT);
		circleBig.alpha = 0.75;
		circleBig.scrollFactor.set();
		bios.add(circleBig);

		icon = new HealthIcon(bc.healthicon_list.length > 0 ? bc.healthicon_list[0] : 'face', true);
		icon.scale.set(0.7, 0.7);
		icon.setPosition(786, 425);
		bios.add(icon);

		textCenter = new FlxSprite(690, 320);
		textCenter.makeGraphic(50, 50, FlxColor.TRANSPARENT);
		textCenter.scrollFactor.set();
		bios.add(textCenter);

		charName = new FlxText(TITLE_X, TITLE_Y, TITLE_W, bc.displayNames_list.length > 0 ? bc.displayNames_list[0] : '', 68);
		charName.setFormat(Paths.font('NiseSegaSonic.TTF'), 68, FlxColor.WHITE, CENTER);
		charName.antialiasing = true;
		charName.scrollFactor.set();
		bios.add(charName);
		_fitCharName();

		artistName = new FlxText(ARTIST_X, ARTIST_Y, ARTIST_W, '', ARTIST_MAX_SIZE);
		artistName.setFormat(Paths.font('NiseSegaSonic.TTF'), ARTIST_MAX_SIZE, FlxColor.WHITE, CENTER);
		artistName.antialiasing = true;
		artistName.scrollFactor.set();
		artistName.text = bc.artist_list.length > 0 ? 'by\n${bc.artist_list[0]}' : '';
		bios.add(artistName);
		_fitArtistName();

		variantDots = new FlxText(0, FlxG.height - 60, 0, '', 22);
		variantDots.setFormat(Paths.font('NiseSegaSonic.TTF'), 22, FlxColor.WHITE, CENTER);
		variantDots.scrollFactor.set();
		variantDots.visible = false;
		bios.add(variantDots);

		charBiosSprite = new FlxSprite(36, 19);
		charBiosSprite.loadGraphic(openfl.utils.Assets.getBitmapData('assets/exe/extras/bios/characterbios.png'));
		charBiosSprite.scrollFactor.set();
		charBiosSprite.antialiasing = true;
		bios.add(charBiosSprite);

		abBox = new FlxSprite(ARTIST_X, ARTIST_Y);
		abBox.makeGraphic(ARTIST_W, ARTIST_H, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRect(abBox, 0, 0, ARTIST_W, ARTIST_H, FlxColor.TRANSPARENT, {thickness: 2, color: 0xFF00FF00});
		abBox.scrollFactor.set();
		abBox.visible = false;
		bios.add(abBox);

		abLabel = new FlxText(10, 30, 0, '', 18);
		abLabel.setFormat(Paths.font('smallass.TTF'), 18, FlxColor.LIME, LEFT);
		abLabel.scrollFactor.set();
		abLabel.visible = false;
		bios.add(abLabel);
	}

	public function onCharChanged(index:Int)
	{
		var bc = bios.biosCharacter;

		_swapChar(bc.chars_list[index]);
		_swapIcon(bc.healthicon_list[index]);

		_forceIdleLoop();
		_preloadNeighbors(index);

		if (!bios.editorOverride)
		{
			var s = bc.scales_list[index];
			character.scale.set(s, s);
			character.flipX = bc.flipX_list[index];
			character.updateHitbox();
			lockedX = bc.offsets_list[index][0] - character.offset.x;
			lockedY = bc.offsets_list[index][1] - character.offset.y;
			character.setPosition(lockedX, lockedY);
		}

		icon.setPosition(bc.icon_offset[index][0], bc.icon_offset[index][1]);
		charName.text = bc.displayNames_list[index];
		_fitCharName();
		_setArtist(bc.artist_list[index]);

		_updateDots();
	}

	public function onVariantChanged(v:Dynamic)
	{
		var bc = bios.biosCharacter;

		var charId = (v.char != null) ? Std.string(v.char) : bc.chars_list[bc.curChar];
		var iconId = (v.icon != null) ? Std.string(v.icon) : bc.healthicon_list[bc.curChar];
		_swapChar(charId);
		_swapIcon(iconId);

		_forceIdleLoop();
		_preloadNeighbors(bc.curChar);

		if (!bios.editorOverride)
		{
			var s:Float = (v.char_scale != null) ? v.char_scale : bc.scales_list[bc.curChar];
			character.scale.set(s, s);
			character.flipX = (v.flip_x == true);
			character.updateHitbox();
			var ox:Float = (v.char_offset != null) ? v.char_offset[0] : bc.offsets_list[bc.curChar][0];
			var oy:Float = (v.char_offset != null) ? v.char_offset[1] : bc.offsets_list[bc.curChar][1];
			lockedX = ox - character.offset.x;
			lockedY = oy - character.offset.y;
			character.setPosition(lockedX, lockedY);
		}

		var ix:Float = (v.icon_offset != null) ? v.icon_offset[0] : bc.icon_offset[bc.curChar][0];
		var iy:Float = (v.icon_offset != null) ? v.icon_offset[1] : bc.icon_offset[bc.curChar][1];
		icon.setPosition(ix, iy);

		var dispName = (v.display_name != null) ? Std.string(v.display_name) : bc.displayNames_list[bc.curChar];
		var artist   = (v.artist != null) ? Std.string(v.artist) : bc.artist_list[bc.curChar];
		charName.text = dispName;
		_fitCharName();
		_setArtist(artist);

		_updateDots();
	}

	public function destroy()
	{
		_preloadCancelToken.cancelled = true;
		_preloadMutex.acquire();
		for (key in _pendingBitmaps.keys())
		{
			_pendingBitmaps.get(key).dispose();
			_pendingBitmaps.remove(key);
		}
		_preloadMutex.release();
	}

	function _preloadNeighbors(centerIdx:Int)
	{
		_preloadCancelToken.cancelled = true;
		var token = { cancelled: false };
		_preloadCancelToken = token;

		var bc     = bios.biosCharacter;
		var n      = bc.chars_list.length;
		if (n == 0) return;

		var indices:Array<Int> = [];
		for (delta in [-1, 1, -2, 2])
		{
			var idx = ((centerIdx + delta) % n + n) % n;
			if (!indices.contains(idx)) indices.push(idx);
		}

		var charIds:Array<String> = [];
		var modDirs:Array<String> = [];
		for (idx in indices)
		{
			var variants = bc.variants_list[idx];
			if (variants != null && variants.length > 0)
			{
				for (v in variants)
				{
					var cid = (v.char != null) ? Std.string(v.char) : bc.chars_list[idx];
					var mod = (v.mod  != null) ? Std.string(v.mod)  : bc.charMods_list[idx];
					if (!charIds.contains(cid)) { charIds.push(cid); modDirs.push(mod); }
				}
			}
			else
			{
				var cid = bc.chars_list[idx];
				var mod = bc.charMods_list[idx];
				if (!charIds.contains(cid)) { charIds.push(cid); modDirs.push(mod); }
			}
		}

		Thread.create(function() {
			for (i in 0...charIds.length)
			{
				if (token.cancelled) return;

				var charId = charIds[i];
				var mod    = modDirs[i];

				var charPath = 'characters/$charId.json';
				var fullPath:String;
				if (mod != null && mod != '')
					fullPath = 'mods/$mod/$charPath';
				else
				{
					var shared = Paths.getSharedPath(charPath);
					fullPath = FileSystem.exists(shared) ? shared : shared;
					#if MODS_ALLOWED
					var modded = Paths.modFolders(charPath);
					if (FileSystem.exists(modded)) fullPath = modded;
					#end
				}

				if (!FileSystem.exists(fullPath)) continue;

				var json:Dynamic;
				try { json = haxe.Json.parse(sys.io.File.getContent(fullPath)); }
				catch(e:Dynamic) { continue; }

				if (json.image == null) continue;
				var images:Array<String> = Std.string(json.image).split(',');

				for (imgKey in images)
				{
					if (token.cancelled) return;
					imgKey = StringTools.trim(imgKey);

					var cacheKey = 'images/$imgKey.png';

					_preloadMutex.acquire();
					var skip = _pendingBitmaps.exists(cacheKey);
					_preloadMutex.release();
					if (skip) continue;

					var imgFile:String;
					if (mod != null && mod != '')
						imgFile = Paths.modFolders('images/$imgKey.png');
					else
					{
						imgFile = Paths.getSharedPath('images/$imgKey.png');
						#if MODS_ALLOWED
						var m = Paths.modFolders('images/$imgKey.png');
						if (FileSystem.exists(m)) imgFile = m;
						#end
					}

					if (!FileSystem.exists(imgFile)) continue;

					var bmp:BitmapData;
					try { bmp = BitmapData.fromFile(imgFile); }
					catch(e:Dynamic) { continue; }

					if (token.cancelled) { bmp.dispose(); return; }

					_preloadMutex.acquire();
					if (!_pendingBitmaps.exists(cacheKey))
						_pendingBitmaps.set(cacheKey, bmp);
					else
						bmp.dispose();
					_preloadMutex.release();
				}
			}
		});
	}

	function _swapChar(charId:String)
	{
		if (character.curCharacter == charId) return;
		var old = character.graphic;
		character.changeCharacter(charId);
		_releaseGraphic(old, character.graphic);
	}

	function _swapIcon(iconId:String)
	{
		if (icon.getCharacter() == iconId) return;
		var old = icon.graphic;
		icon.changeIcon(iconId);
		_releaseGraphic(old, icon.graphic);
	}

	function _releaseGraphic(oldGfx:FlxGraphic, newGfx:FlxGraphic)
	{
		if (oldGfx == null || oldGfx == newGfx) return;
		if (oldGfx.key != null)
			Paths.currentTrackedAssets.remove(oldGfx.key);
		oldGfx.persist        = false;
		oldGfx.destroyOnNoUse = true;
		FlxG.bitmap.remove(oldGfx);
	}

	function _updateDots()
	{
		var bc = bios.biosCharacter;
		var variants = bc.variants_list[bc.curChar];
		if (variants == null || variants.length == 0) { variantDots.visible = false; return; }

		variantDots.visible = true;
		var dots = '';
		for (i in 0...variants.length)
			dots += (i == bc.curVariant) ? '● ' : '○ ';
		variantDots.text = dots.rtrim();
	}

	function _fitCharName()
	{
		charName.fieldWidth = 0;
		var size = 68;
		charName.size = size;
		while (charName.width > TITLE_W && size > 16)
		{
			size--;
			charName.size = size;
		}
		charName.fieldWidth = TITLE_W;
		charName.y = TITLE_Y + (TITLE_H - charName.height) * 0.5;
	}

	function _setArtist(raw:String)
	{
		var parts:Array<String> = [];
		for (p in ~/\s*[\/&\+]\s*/.split(raw))
		{
			var s = StringTools.trim(p);
			if (s.length > 0) parts.push(s);
		}
		if (parts.length == 0) parts = [''];

		_artists     = parts;
		_artistIdx   = 0;
		_artistTimer = 0;
		_artistFading = false;
		artistName.alpha = 1;

		artistName.text = parts.length > 1 ? 'by\n${parts[0]}' : (raw != '' ? 'by\n$raw' : '');
		_fitArtistName();
	}

	function _fitArtistName()
	{
		artistName.fieldWidth = 0;
		var size = ARTIST_MAX_SIZE;
		artistName.size = size;
		while (artistName.width > _aw && size > ARTIST_MIN_SIZE)
		{
			size--;
			artistName.size = size;
		}
		// Center inside the box
		artistName.fieldWidth = Std.int(_aw);
		artistName.x = _ax;
		artistName.y = _ay + (_ah - artistName.height) * 0.5;
	}

	function _forceIdleLoop()
	{
		if (character.animation == null) return;

		var hasDanceLeft  = character.animation.getByName('danceLeft')  != null;
		var hasDanceRight = character.animation.getByName('danceRight') != null;
		var isDance = hasDanceLeft || hasDanceRight;

		_danceTimer = 0;
		_danced = false;

		if (isDance)
		{
			_danceLeftTag  = hasDanceLeft  ? 'danceLeft'  : 'danceRight';
			_danceRightTag = hasDanceRight ? 'danceRight' : 'danceLeft';
			character.playAnim(_danceLeftTag, true);
		}
		else
		{
			_danceLeftTag  = null;
			_danceRightTag = null;

			var idleTag:String = null;
			if (character.animation.getByName('idle') != null)
				idleTag = 'idle';
			else
			{
				for (anim in character.animationsArray)
					if (anim.name.toLowerCase().indexOf('idle') >= 0) { idleTag = anim.anim; break; }
			}
			if (idleTag == null) idleTag = 'idle';

			var a = character.animation.getByName(idleTag);
			if (a != null) a.looped = true;
			character.playAnim(idleTag, true);
		}
	}

	function _abUpdateLabel()
	{
		var mode = abTarget == 0 ? 'MOVE' : 'SIZE';
		abLabel.text = '[F3] ARTIST DEBUG  |  TAB = $mode\npos: (${Std.int(_ax)}, ${Std.int(_ay)})  size: (${Std.int(_aw)} x ${Std.int(_ah)})';
	}

	function _abRebuildBox()
	{
		abBox.x = _ax;
		abBox.y = _ay;
		abBox.makeGraphic(Std.int(_aw), Std.int(_ah), FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRect(abBox, 0, 0, _aw, _ah, FlxColor.TRANSPARENT, {thickness: 2, color: 0xFF00FF00});
	}

	public function update(elapsed:Float)
	{
		_preloadMutex.acquire();
		if (_pendingBitmaps.keys().hasNext())
		{
			for (key in _pendingBitmaps.keys())
			{
				if (!Paths.currentTrackedAssets.exists(key))
				{
					var bmp = _pendingBitmaps.get(key);
					var graph = FlxGraphic.fromBitmapData(bmp, false, key);
					graph.persist        = true;
					graph.destroyOnNoUse = false;
					Paths.currentTrackedAssets.set(key, graph);
					Paths.localTrackedAssets.push(key);
				}
				else
				{
					_pendingBitmaps.get(key).dispose();
				}
				_pendingBitmaps.remove(key);
			}
		}
		_preloadMutex.release();

		if (character != null && _danceLeftTag != null)
		{
			_danceTimer += elapsed;
			var curAnim = character.animation.curAnim;
			var animDur = (curAnim != null && curAnim.frameRate > 0)
				? curAnim.numFrames / curAnim.frameRate
				: 0.5;
			if (_danceTimer >= animDur)
			{
				_danceTimer -= animDur;
				_danced = !_danced;
				character.playAnim(_danced ? _danceRightTag : _danceLeftTag, true);
			}
		}

		variantDots.x = charName.x + (charName.width - variantDots.width) / 2;
		variantDots.y = charName.y + charName.height + 4;

		if (_artists.length > 1)
		{
			_artistTimer += elapsed;

			if (!_artistFading)
			{
				if (_artistTimer >= ARTIST_CYCLE_TIME)
				{
					_artistFading  = true;
					_artistFadeDir = 1;
					_artistTimer   = 0;
				}
			}
			else
			{
				var fadeDelta = elapsed / ARTIST_FADE_TIME * _artistFadeDir;
				artistName.alpha -= fadeDelta;

				if (_artistFadeDir == 1 && artistName.alpha <= 0)
				{
					artistName.alpha = 0;
					_artistIdx = (_artistIdx + 1) % _artists.length;
					artistName.text = 'by\n${_artists[_artistIdx]}';
					_fitArtistName();
					_artistFadeDir = -1;
				}
				else if (_artistFadeDir == -1 && artistName.alpha >= 1)
				{
					artistName.alpha  = 1;
					_artistFading     = false;
					_artistTimer      = 0;
				}
			}
		}

		if (FlxG.keys.justPressed.F3)
		{
			abDebug = !abDebug;
			abBox.visible   = abDebug;
			abLabel.visible = abDebug;
			if (abDebug) _abUpdateLabel();
		}

		if (!abDebug) return;

		if (FlxG.keys.justPressed.TAB)
		{
			abTarget = (abTarget == 0) ? 1 : 0;
			_abUpdateLabel();
		}

		var speed:Float = FlxG.keys.pressed.SHIFT ? 5 : 1;
		var dx:Float = 0;
		var dy:Float = 0;
		if (FlxG.keys.pressed.LEFT)  dx -= speed;
		if (FlxG.keys.pressed.RIGHT) dx += speed;
		if (FlxG.keys.pressed.UP)    dy -= speed;
		if (FlxG.keys.pressed.DOWN)  dy += speed;

		if (dx != 0 || dy != 0)
		{
			if (abTarget == 0)
			{
				_ax += dx;
				_ay += dy;
			}
			else
			{
				_aw = Math.max(20, _aw + dx);
				_ah = Math.max(20, _ah + dy);
				_abRebuildBox();
			}
			_fitArtistName();
			abBox.x = _ax;
			abBox.y = _ay;
			_abUpdateLabel();
		}
	}
}
