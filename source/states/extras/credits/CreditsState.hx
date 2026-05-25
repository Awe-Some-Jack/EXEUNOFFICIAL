package states.extras.credits;

import flixel.util.FlxGradient;
import haxe.Json;
import openfl.Assets;
import states.extras.ExtrasMenu;

typedef Credit =
{
	var name:String;
	var icon:String;
	var description:String;
	@:optional var quote:String;
	@:optional var color:Array<Array<Int>>;
	@:optional var nation:String;
	@:optional var youtube:String;
	@:optional var twitter:String;
	@:optional var bluesky:String;
}

class CreditsState extends MusicBeatState
{
	var credits:Map<String, Array<Credit>> = [];

	var devs:FlxCamera;
	var devList:FlxText;
	var og:FlxCamera;
	var ogList:FlxText;
	var external:FlxCamera;
	var externalList:FlxText;
	var transition:FlxCamera;

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/credits.ogg'));

		var bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF730E4E, 0xFFA9171E], 1, 90);
		add(bg);

		var json:Dynamic = Json.parse( Assets.getText("assets/exe/extras/credits/credits.json"));
		for(cat in Reflect.fields(json))
		{
			var daCreds:Array<Credit> = cast Reflect.field(json, cat);
			credits.set(cat, daCreds);
		}

		var spacing:Int = 10;
		devs = new FlxCamera();
		devs.bgColor = 0x22000000;
		FlxG.cameras.add(devs, false);
		devs.setSize(Std.int((FlxG.width - (spacing * 4)) / 3), FlxG.height - (spacing * 8)); devs.setPosition(spacing, spacing * 7);
		var devTitle:FlxText = new FlxText(devs.x, spacing * 2, devs.width, "Unofficial Dev Team").setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		devTitle.borderSize = 2;
		add(devTitle);
		devList = new FlxText(5, 5, devs.width - 10, "Null").setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
		devList.borderSize = 2;
		devList.text = [for(dev in credits.get("unofficial")) dev.name].join("\n");
		devList.camera = devs;
		add(devList);

		og = new FlxCamera();
		og.bgColor = 0x22000000;
		FlxG.cameras.add(og, false);
		og.setSize(Std.int((FlxG.width - (spacing * 4)) / 3), FlxG.height - (spacing * 8)); og.setPosition(spacing * 2 + og.width, spacing * 7);
		var ogTitle:FlxText = new FlxText(og.x, spacing * 2, og.width, "Original Team").setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		ogTitle.borderSize = 2;
		add(ogTitle);
		ogList = new FlxText(5, 5, og.width - 10, "Null").setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
		ogList.borderSize = 2;
		ogList.text = [for(dev in credits.get("original")) dev.name].join("\n");
		ogList.camera = og;
		add(ogList);

		external = new FlxCamera();
		external.bgColor = 0x22000000;
		FlxG.cameras.add(external, false);
		external.setSize(Std.int((FlxG.width - (spacing * 4)) / 3), FlxG.height - (spacing * 8)); external.setPosition(spacing * 3 + external.width * 2, spacing * 7);
		var externalTitle:FlxText = new FlxText(external.x, spacing * 2, external.width, "External Credits").setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		externalTitle.borderSize = 2;
		add(externalTitle);
		externalList = new FlxText(5, 5, external.width - 10, "Null").setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
		externalList.borderSize = 2;
		externalList.text = [for(dev in credits.get("external")) dev.name].join("\n");
		externalList.camera = external;
		add(externalList);

		transition = new FlxCamera();
		transition.bgColor.alpha = 0;
		FlxG.cameras.add(transition, false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menu");
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.instance.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new ExtrasMenu());
			FlxG.sound.music.fadeOut(0.3);
		}

		if (FlxG.mouse.overlaps(devList, devs))
		{
			devList.y += FlxG.mouse.wheel * 40;

			if (devList.height <= devs.height - 10)
				devList.y = 5;
			else
				devList.y = FlxMath.bound(devList.y, devs.height - devList.height - 5, 5);
		}

		if (FlxG.mouse.overlaps(ogList, og))
		{
			ogList.y += FlxG.mouse.wheel * 40;
			if (ogList.height <= og.height - 10)
				ogList.y = 5;
			else
				ogList.y = FlxMath.bound(ogList.y, og.height - ogList.height - 5, 5);
		}

		if (FlxG.mouse.overlaps(externalList, external))
		{
			externalList.y += FlxG.mouse.wheel * 40;

			if (externalList.height <= external.height - 10)
				externalList.y = 5;
			else
				externalList.y = FlxMath.bound(externalList.y, external.height - externalList.height - 5, 5);
		}
	}
}