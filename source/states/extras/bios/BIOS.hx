package states.extras.bios;

import flixel.addons.display.FlxBackdrop;
import flixel.*;
import objects.*;

class BIOS extends MusicBeatState
{
	
	public var biosCharacter:BIOSCharacter; 
	public var biosShowcase:BIOSShowcase;   
	public var biosInfo:BIOSInfo;           

	public var bgSprite:FlxSprite;
	public var bgColorTarget:FlxColor  = 0xFFAA0000;
	var        bgColorCurrent:FlxColor = 0xFFAA0000;

	public var editorOverride:Bool = false;

	override function create()
	{
		super.create();

		bgSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFAA0000);
		bgSprite.scrollFactor.set();
		add(bgSprite);

		var fondo = new FlxSprite(0, 0);
		fondo.loadGraphic(Assets.getBitmapData('assets/exe/extras/fondo.png'));
		fondo.scrollFactor.set();
		fondo.antialiasing = ClientPrefs.data.antialiasing;
		add(fondo);

		var spikestop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/extras/bios/backdrop.png'), Y);
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.y = 60;
		spikestop.screenCenter();
		spikestop.scrollFactor.set();
		add(spikestop);

		biosCharacter = new BIOSCharacter(this);
		biosShowcase  = new BIOSShowcase(this);
		biosInfo      = new BIOSInfo(this);

		var bc = biosCharacter;
		if (bc.bgColors_list.length > 0) {
			bgColorTarget  = bc.bgColors_list[0];
			bgColorCurrent = bgColorTarget;
			bgSprite.color = bgColorCurrent;
		}

		biosCharacter.bringNamesToFront();

		if (bc.chars_list.length > 0) biosCharacter.changeCharBio();
	}

	override function update(elapsed:Float)
	{
		
		if (!editorOverride && biosCharacter.chars_list.length > 0)
		{
			var ch  = biosShowcase.character;
			var idx = biosCharacter.curChar;
			var variants = biosCharacter.variants_list[idx];
			var ox:Float, oy:Float;
			if (variants != null && variants.length > 0)
			{
				var v:Dynamic = variants[biosCharacter.curVariant];
				ox = (v.char_offset != null) ? v.char_offset[0] : biosCharacter.offsets_list[idx][0];
				oy = (v.char_offset != null) ? v.char_offset[1] : biosCharacter.offsets_list[idx][1];
			}
			else
			{
				ox = biosCharacter.offsets_list[idx][0];
				oy = biosCharacter.offsets_list[idx][1];
			}
			ch.x = ox - ch.offset.x;
			ch.y = oy - ch.offset.y;
		}

		super.update(elapsed);

		var tr = bgColorTarget.red   + (bgColorCurrent.red   - bgColorTarget.red)   * Math.exp(-10 * elapsed);
		var tg = bgColorTarget.green + (bgColorCurrent.green - bgColorTarget.green) * Math.exp(-10 * elapsed);
		var tb = bgColorTarget.blue  + (bgColorCurrent.blue  - bgColorTarget.blue)  * Math.exp(-10 * elapsed);
		bgColorCurrent = FlxColor.fromRGB(Std.int(tr), Std.int(tg), Std.int(tb));
		bgSprite.color = bgColorCurrent;

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new ExtrasMenu());
		}

		if (FlxG.keys.justPressed.F1)
			openSubState(new BiosEditorSubState(this));

		if (controls.RESET) FlxG.resetState();

		biosShowcase.update(elapsed);
		biosInfo.update(elapsed);
		biosCharacter.update(elapsed);
	}

	override function destroy()
	{
		biosInfo.destroy();
		super.destroy();
	}
}