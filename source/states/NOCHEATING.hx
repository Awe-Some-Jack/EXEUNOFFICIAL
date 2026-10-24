package states;

import openfl.system.System;
import lime.app.Application;

class NOCHEATING extends MusicBeatSubstate
{
	var initialWindowX:Int = 0;
    var initialWindowY:Int = 0;
	var intensity:Int = 8;

	override function create()
	{
		if (FlxG.fullscreen) FlxG.fullscreen = false; 

		Conductor.songPosition = 0;
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.zoom = 1;

		var win = Application.current.window;
        
		if (win.maximized) win.maximized = false;

        win.x = Std.int((win.display.bounds.width - win.width) / 2);
        win.y = Std.int((win.display.bounds.height - win.height) / 2);

        initialWindowX = win.x;
        initialWindowY = win.y;

		var nocheat:FlxSprite = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/xenocheating.webp'));
		nocheat.scale.set(2, 2);
		nocheat.updateHitbox();
		nocheat.screenCenter();
		nocheat.y -= 100;
		nocheat.antialiasing = false;
		nocheat.scrollFactor.set();
		add(nocheat);

		var txt:FlxSprite = new FlxSprite(0, nocheat.y + nocheat.height + 10).loadGraphic(Paths.getBitmapData('assets/exe/textcheating.webp'));
		txt.scale.set(4, 4);
		txt.updateHitbox();
		txt.screenCenter(X);
		txt.antialiasing = false;
		txt.scrollFactor.set();
		add(txt);

		FlxG.stage.window.title = 'NO CHEATING';
		new FlxTimer().start(2.5, _ -> {
			FlxG.stage.window.x = initialWindowX;
            FlxG.stage.window.y = initialWindowY;
			System.exit(0);
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.stage.window.x = initialWindowX + FlxG.random.int(-intensity, intensity);
		FlxG.stage.window.y = initialWindowY + FlxG.random.int(-intensity, intensity);
	}
}