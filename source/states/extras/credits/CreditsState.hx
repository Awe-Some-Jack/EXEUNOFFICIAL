package states.extras.credits;

import flixel.util.FlxGradient;
import haxe.Json;
import openfl.Assets;
import states.extras.ExtrasMenu;

import states.extras.credits.CreditPopup;

typedef Credit =
{
	var name:String;
	var icon:String;
	var description:String;
	@:optional var quote:String;
	@:optional var colors:Array<Array<Int>>;
	@:optional var nation:String;
	@:optional var youtube:String;
	@:optional var twitter:String;
	@:optional var extra:Array<Dynamic>;
}

class CreditsState extends MusicBeatState
{
	public static var credits:Map<String, Array<Credit>> = [];
	public static var userSelected:Array<Dynamic> = ['unofficial', 0];

	var devs:FlxCamera;
	var og:FlxCamera;
	var external:FlxCamera;
	
	var devList:FlxTypedGroup<FlxText>;
	var ogList:FlxTypedGroup<FlxText>;
	var externalList:FlxTypedGroup<FlxText>;

	var transition:FlxCamera;

	var inPopup:Bool = false;

	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/credits.ogg'));

		var json:Dynamic = Json.parse( Assets.getText("assets/exe/extras/credits/credits.json"));
		for(cat in Reflect.fields(json))
		{
			var daCreds:Array<Credit> = cast Reflect.field(json, cat);
			credits.set(cat, daCreds);
		}

		var bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF730E4E, 0xFFA9171E], 1, 90);
		add(bg);

		var spacing:Int = 10;
		devs = new FlxCamera();
		devs.bgColor = 0x22000000;
		FlxG.cameras.add(devs, false);
		devs.setSize(Std.int((FlxG.width - (spacing * 4)) / 3), FlxG.height - (spacing * 8)); devs.setPosition(spacing, spacing * 7);
		var devTitle:FlxText = new FlxText(devs.x, spacing * 2, devs.width, "Unofficial Dev Team").setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		devTitle.borderSize = 2;
		add(devTitle);
		devList = new FlxTypedGroup<FlxText>();
		add(devList);
		for(i in 0...credits.get("unofficial").length)
		{
			var text = new FlxText(5, 5 + (i * 32),devs.width - 10, credits.get("unofficial")[i].name).setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
			text.borderSize = 2;
			text.camera = devs;
			devList.add(text);
		}

		og = new FlxCamera();
		og.bgColor = 0x22000000;
		FlxG.cameras.add(og, false);
		og.setSize(Std.int((FlxG.width - (spacing * 4)) / 3), FlxG.height - (spacing * 8)); og.setPosition(spacing * 2 + og.width, spacing * 7);
		var ogTitle:FlxText = new FlxText(og.x, spacing * 2, og.width, "Original Team").setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		ogTitle.borderSize = 2;
		add(ogTitle);
		ogList = new FlxTypedGroup<FlxText>();
		add(ogList);
		for(i in 0...credits.get("original").length)
		{
			var text = new FlxText(5, 5 + (i * 32), og.width - 10, credits.get("original")[i].name).setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
			text.borderSize = 2;
			text.camera = og;
			ogList.add(text);
		}

		external = new FlxCamera();
		external.bgColor = 0x22000000;
		FlxG.cameras.add(external, false);
		external.setSize(Std.int((FlxG.width - (spacing * 4)) / 3), FlxG.height - (spacing * 8)); external.setPosition(spacing * 3 + external.width * 2, spacing * 7);
		var externalTitle:FlxText = new FlxText(external.x, spacing * 2, external.width, "External Credits").setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		externalTitle.borderSize = 2;
		add(externalTitle);
		externalList = new FlxTypedGroup<FlxText>();
		add(externalList);
		for(i in 0...credits.get("external").length)
		{
			var text = new FlxText(5, 5 + (i * 32), external.width - 10, credits.get("external")[i].name).setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
			text.borderSize = 2;
			text.camera = external;
			externalList.add(text);
		}

		transition = new FlxCamera();
		transition.bgColor.alpha = 0;
		FlxG.cameras.add(transition, false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menu");
		#end
	}

	var canSelect:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (inPopup) return;

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new ExtrasMenu());
			FlxG.sound.music.fadeOut(0.3);
		}

		defaultValues();

		if (overlapCamera(devs))
		{
			if (FlxG.mouse.deltaWheel.y != 0)
			{
				devs.scroll.y -= FlxG.mouse.deltaWheel.y * 32;
				devs.scroll.y = FlxMath.bound(devs.scroll.y, 0, Math.max(0, (devList.length * 32) - devs.height + 10));
			}

			for(i in 0...devList.length)
			{
				var text = devList.members[i];
				if (FlxG.mouse.overlaps(text, devs))
				{
					if (text.color != 0xFFFFFF00)
					{
						canSelect = true;
						text.color = 0xFFFFFF00;
						userSelected = ['unofficial', i];
					}
				}
			}
		}

		if (overlapCamera(og))
		{
			if (FlxG.mouse.deltaWheel.y != 0)
			{
				og.scroll.y -= FlxG.mouse.deltaWheel.y * 32;
				og.scroll.y = FlxMath.bound(og.scroll.y, 0, Math.max(0, (ogList.length * 32) - og.height + 10));
			}

			for(i in 0...ogList.length)
			{
				var text = ogList.members[i];
				if (FlxG.mouse.overlaps(text, og))
				{
					if (text.color != 0xFFFFFF00)
					{
						canSelect = true;
						text.color = 0xFFFFFF00;
						userSelected = ['original', i];
					}
				}
			}
		}

		if (overlapCamera(external))
		{
			if (FlxG.mouse.deltaWheel.y != 0)
			{
				external.scroll.y -= FlxG.mouse.deltaWheel.y * 32;
				external.scroll.y = FlxMath.bound(external.scroll.y, 0, Math.max(0, (externalList.length * 32) - external.height + 10));
			}

			for(i in 0...externalList.length)
			{
				var text = externalList.members[i];
				if (FlxG.mouse.overlaps(text, external))
				{
					if (text.color != 0xFFFFFF00)
					{
						canSelect = true;
						text.color = 0xFFFFFF00;
						userSelected = ['external', i];
					}
				}
			}
		}

		if ((controls.ACCEPT || FlxG.mouse.justPressed) && canSelect)
		{
			inPopup = true;
			openSubState(new CreditPopup());
		}
	}

	function defaultValues():Void
	{
		canSelect = false;
		for(text in devList.members)
			if (text != null)
				text.color = 0xFFFFFFFF;

		for(text in ogList.members)
			if (text != null)
				text.color = 0xFFFFFFFF;

		for(text in externalList.members)
			if (text != null)
				text.color = 0xFFFFFFFF;
	}

	function overlapCamera(cam:FlxCamera):Bool
		return FlxG.mouse.viewX >= cam.x && FlxG.mouse.viewX <= cam.x + cam.width && FlxG.mouse.viewY >= cam.y && FlxG.mouse.viewY <= cam.y + cam.height;

	override function closeSubState()
	{
		if (FlxG.sound.music.volume < 1)
		{
			FlxTween.cancelTweensOf(FlxG.sound.music);
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.6);
		}
		super.closeSubState();
		inPopup = false;
	}
}