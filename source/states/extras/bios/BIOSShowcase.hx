package states.extras.bios;

import flixel.*;
import flixel.util.FlxSpriteUtil;
import objects.*;
import flixel.addons.display.shapes.*;

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

	static inline var TITLE_X:Int  = 443;
	static inline var TITLE_Y:Int  = 34;
	static inline var TITLE_W:Int  = 328;
	static inline var TITLE_H:Int  = 100;

	var charBiosSprite:FlxSprite;

	var cbDebug:Bool     = false;
	var cbTarget:Int     = 0; 
	var cbLabel:FlxText;

	public function new(parent:BIOS)
	{
		bios = parent;
		var bc = bios.biosCharacter;

		if (bc.charMods_list.length > 0 && bc.charMods_list[0] != '')
			Mods.currentModDirectory = bc.charMods_list[0];

		character = new Character(0, 0, bc.chars_list.length > 0 ? bc.chars_list[0] : 'bf', true);
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

		artistName = new FlxText(525, 585, 0, '', 40);
		artistName.setFormat(Paths.font('NiseSegaSonic.TTF'), 40, FlxColor.WHITE, CENTER);
		artistName.antialiasing = true;
		artistName.scrollFactor.set();
		artistName.text = bc.artist_list.length > 0 ? 'by\n${bc.artist_list[0]}' : '';
		bios.add(artistName);

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
	}

	public function onCharChanged(index:Int)
	{
		var bc = bios.biosCharacter;

		if (character.curCharacter != bc.chars_list[index])
			character.changeCharacter(bc.chars_list[index]);
		if (icon.getCharacter() != bc.healthicon_list[index])
			icon.changeIcon(bc.healthicon_list[index]);

		if (!bios.editorOverride)
		{
			var s = bc.scales_list[index];
			character.scale.set(s, s);
			character.flipX = bc.flipX_list[index];
			character.updateHitbox();
			character.setPosition(
				bc.offsets_list[index][0] - character.offset.x,
				bc.offsets_list[index][1] - character.offset.y
			);
		}

		icon.setPosition(bc.icon_offset[index][0], bc.icon_offset[index][1]);
		charName.text = bc.displayNames_list[index];
		_fitCharName();
		artistName.text = 'by\n${bc.artist_list[index]}';

		_forceIdleLoop();
		_updateDots();
	}

	public function onVariantChanged(v:Dynamic)
	{
		var bc = bios.biosCharacter;

		var charId  = (v.char != null) ? Std.string(v.char) : bc.chars_list[bc.curChar];
		var iconId  = (v.icon != null) ? Std.string(v.icon) : bc.healthicon_list[bc.curChar];
		if (character.curCharacter != charId) character.changeCharacter(charId);
		if (icon.getCharacter() != iconId)    icon.changeIcon(iconId);

		if (!bios.editorOverride)
		{
			var s:Float = (v.char_scale != null) ? v.char_scale : bc.scales_list[bc.curChar];
			character.scale.set(s, s);
			character.flipX = (v.flip_x == true);
			character.updateHitbox();
			var ox:Float = (v.char_offset != null) ? v.char_offset[0] : bc.offsets_list[bc.curChar][0];
			var oy:Float = (v.char_offset != null) ? v.char_offset[1] : bc.offsets_list[bc.curChar][1];
			character.setPosition(ox - character.offset.x, oy - character.offset.y);
		}

		var ix:Float = (v.icon_offset != null) ? v.icon_offset[0] : bc.icon_offset[bc.curChar][0];
		var iy:Float = (v.icon_offset != null) ? v.icon_offset[1] : bc.icon_offset[bc.curChar][1];
		icon.setPosition(ix, iy);

		var dispName = (v.display_name != null) ? Std.string(v.display_name) : bc.displayNames_list[bc.curChar];
		var artist   = (v.artist != null) ? Std.string(v.artist) : bc.artist_list[bc.curChar];
		charName.text = dispName;
		_fitCharName();
		artistName.text = 'by\n$artist';

		_forceIdleLoop();
		_updateDots();
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

	function _forceIdleLoop()
	{
		if (character.animation == null) return;
		for (animName in ['idle', 'danceLeft', 'danceRight'])
		{
			var anim = character.animation.getByName(animName);
			if (anim != null) anim.looped = true;
		}
	}

	public function update(elapsed:Float)
	{
		variantDots.x = charName.x + (charName.width - variantDots.width) / 2;
		variantDots.y = charName.y + charName.height + 4;

		if (FlxG.keys.justPressed.F4)
		{
			cbDebug = !cbDebug;
			cbLabel.visible = cbDebug;
			if (cbDebug) _cbUpdateLabel();
		}

		if (!cbDebug) return;

		if (FlxG.keys.justPressed.TAB)
		{
			cbTarget = (cbTarget == 0) ? 1 : 0;
			_cbUpdateLabel();
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
			if (cbTarget == 0)
			{
				charBiosSprite.x += dx;
				charBiosSprite.y += dy;
			}
			else
			{
				var s = charBiosSprite.scale.x + dx * 0.005;
				s = Math.max(0.05, s);
				charBiosSprite.scale.set(s, s);
				charBiosSprite.updateHitbox();
			}
			_cbUpdateLabel();
		}
	}

	function _cbUpdateLabel()
	{
		var mode = cbTarget == 0 ? 'MOVE' : 'SCALE';
		cbLabel.text = '[F4] CHARBIOS DEBUG  |  TAB = $mode\npos: (${Std.int(charBiosSprite.x)}, ${Std.int(charBiosSprite.y)})\nscale: ${Math.round(charBiosSprite.scale.x * 1000) / 1000}';
	}
}