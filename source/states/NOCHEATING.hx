package states;

import openfl.system.System;

class NOCHEATING extends MusicBeatSubstate
{
	override function create()
	{
		Conductor.songPosition = 0;
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.zoom = 1;

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
		new FlxTimer().start(2, _ -> System.exit(0));

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}