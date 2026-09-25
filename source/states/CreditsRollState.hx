package states;

import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import openfl.utils.Assets as AssetPaths;

class CreditsRollState extends MusicBeatState
{
	var timer:Float = 0;
	var credits:String = 'Not Found';
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

			var creditsTxt:FlxText = new FlxText(15, y, Std.int(FlxG.width * 0.6), text);
			creditsTxt.setFormat(Paths.font("sonic4.ttf"), size, 0xFFFFFFFF, "left");
			add(creditsTxt);
			y += creditsTxt.height + 4;
		}
	}

	var lastTxt:FlxText;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (timer > 3)
		{
			if (lastTxt != null && lastTxt.y <= FlxG.height / 2) return;

			for (member in members)
			{
				if (Std.isOfType(member, FlxText))
				{
					final text:FlxText = cast(member, FlxText);
					text.y -= 62 * elapsed;
					lastTxt = text;
				}
			}
		}
		else timer += elapsed;
	}
}