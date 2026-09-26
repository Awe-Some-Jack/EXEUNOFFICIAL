package states;

import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import openfl.utils.Assets as AssetPaths;

class CreditsRollState extends MusicBeatState
{
	var timer:Float = 0;
	var credits:String = 'Not Found';
	var canLeave:Bool = false;
	override function create()
	{
		super.create();

		credits = AssetPaths.getText("assets/exe/credits.txt");

		var y:Float = FlxG.height / 2;
		for (line in credits.split('\n'))
		{
			if (line.trim() == '') { y += 30; continue; }
			var text = line;
			var size = 22;
			if (line.startsWith('=='))
			{
				text = line.substr(2);
				size = 36;
			}
			else if (line.startsWith('='))
			{
				text = line.substr(1);
				size = 28;
			}

			text = StringTools.replace(text, "{user}", DiscordClient.username ?? 'boyfriend');

			var creditsTxt:FlxText = new FlxText(15, y, Std.int(FlxG.width * 0.6), text);
			creditsTxt.setFormat(Paths.font("sonic4.ttf"), size, 0xFFFFFFFF, "left");
			add(creditsTxt);
			y += creditsTxt.height + 4;
		}

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/credits.ogg'));
		trace(backend.EXEAchievements.isUnlocked('credits'));
		if (backend.EXEAchievements.isUnlocked('credits')) canLeave = true;
	}

	var speed:Float = 1;
	var activateOnce:Bool = true;
	var lastTxt:FlxText;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		speed = (FlxG.keys.pressed.SHIFT ? 3 : 1);

		if (((controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end) || (controls.BACK #if mobile || backPressed #end)) && canLeave)
		{
			canLeave = false;
			FlxG.camera.fade(0xFF000000, 5, false, () -> { FlxG.switchState(() -> new states.EXEMenu()); }, true);
			FlxG.sound.music?.fadeOut(5);
		}

		if (timer > 3)
		{
			if (lastTxt != null && lastTxt.y <= FlxG.height / 2)
			{
				if (activateOnce) {
					backend.EXEAchievements.unlock('credits');
					backend.EXEAchievements.save();
					activateOnce = false;
					new FlxTimer().start(3, _ -> {
						canLeave = false;
						FlxG.camera.fade(0xFF000000, 5, false, () -> { FlxG.switchState(() -> new states.EXEMenu()); }, true);
					});
				}
				return;
			}

			for (member in members)
			{
				if (Std.isOfType(member, FlxText))
				{
					final text:FlxText = cast(member, FlxText);
					text.y -= 62 * elapsed * speed;
					lastTxt = text;
				}
			}
		}
		else timer += elapsed * speed;
	}

	override function destroy()
	{
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		super.destroy();
	}
}