package states.extras.bios;

import flixel.addons.display.FlxBackdrop;
import flixel.*;
import objects.*;

class BIOS extends MusicBeatState
{
	
	public var biosCharacter:BIOSCharacter; 
	public var biosShowcase:BIOSShowcase;   
	public var biosInfo:BIOSInfo;           


	public var editorOverride:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		var fondo = new FlxSprite(0, 0);
		fondo.loadGraphic(Assets.getBitmapData('assets/exe/extras/fondo.png'));
		fondo.scale.set(FlxG.width / fondo.width, FlxG.height / fondo.height);
		fondo.updateHitbox();
		fondo.scrollFactor.set();
		fondo.antialiasing = ClientPrefs.data.antialiasing;
		add(fondo);

		var spikestop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/extras/bios/backdrop.png'), Y);
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.y = 60;
		spikestop.screenCenter();
		spikestop.scrollFactor.set();
		spikestop.blend = openfl.display.BlendMode.MULTIPLY;
		add(spikestop);

		biosCharacter = new BIOSCharacter(this);
		biosShowcase  = new BIOSShowcase(this);
		biosInfo      = new BIOSInfo(this);

		biosCharacter.bringNamesToFront();

		if (biosCharacter.chars_list.length > 0) biosCharacter.changeCharBio();
	}

	override function update(elapsed:Float)
	{
		
		super.update(elapsed);

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

		if (!editorOverride && biosCharacter.chars_list.length > 0)
		{
			var ch = biosShowcase.character;
			ch.x = biosShowcase.lockedX;
			ch.y = biosShowcase.lockedY;
		}
	}

	override function destroy()
	{
		biosInfo.destroy();
		biosShowcase.destroy();
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		super.destroy();
	}
}