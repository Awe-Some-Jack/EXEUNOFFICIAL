package states;

class CreditsState extends MusicBeatState
{
	static var credits:Array<Array<String>> = [
		// Section headers have only one element
		// People have [Name, Role]
		["Source Code"],
		["Shadow Mario",      "Main Programmer & Head of Psych Engine"],
		["Riveren",           "Main Artist & Animator of Psych Engine"],
		[""],
		["Former Members"],
		["bb-panzu",          "Ex-Programmer of Psych Engine"],
		[""],
		["Contributors"],
		["crowplexus",        "Linux Support, HScript Iris, Input System v3"],
		["Kamizeta",          "Creator of Pessy, Psych Engine's mascot"],
		["MaxNeton",          "Loading Screen Easter Egg Artist & Animator"],
		["Keoiki",            "Note Splash Animations and Latin Alphabet"],
		["SqirraRNG",         "Crash Handler & Chart Editor Waveform"],
		["EliteMasterEric",   "Runtime Shaders Support"],
		["MAJigsaw77",        "MP4 Video Loader Library (hxvlc)"],
		["iFlicky",           "Composer of Psync and Tea Time"],
		["KadeDev",           "Chart Editor Fixes"],
		["superpowers04",     "LUA JIT Fork"],
		["CheemsAndFriends",  "Creator of FlxAnimate"],
		[""],
		["Friday Night Funkin'"],
		["ninjamuffin99",     "Programmer of Friday Night Funkin'"],
		["PhantomArcade",     "Animator of Friday Night Funkin'"],
		["evilsk8r",          "Artist of Friday Night Funkin'"],
		["kawaisprite",       "Composer of Friday Night Funkin'"],
	];

	static inline var SCROLL_SPEED:Float = 40;
	static inline var LINE_HEIGHT:Float  = 54;
	static inline var HEADER_HEIGHT:Float = 80;

	var container:FlxSprite;
	var texts:Array<FlxText> = [];
	var totalHeight:Float = 0;
	var scrollY:Float = 0;
	var done:Bool = false;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		buildTexts();

		super.create();
	}

	function buildTexts():Void
	{
		var y:Float = FlxG.height;

		for (entry in credits)
		{
			if (entry.length == 0 || (entry.length == 1 && entry[0] == ""))
			{
				y += LINE_HEIGHT * 0.6;
				continue;
			}

			if (entry.length == 1)
			{
				// Section header
				var t = new FlxText(0, y, FlxG.width, entry[0]);
				t.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER);
				t.alpha = 0.5;
				t.scrollFactor.set();
				add(t);
				texts.push(t);
				y += HEADER_HEIGHT;
			}
			else
			{
				// Name
				var name = new FlxText(0, y, FlxG.width, entry[0]);
				name.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER);
				name.scrollFactor.set();
				add(name);
				texts.push(name);
				y += LINE_HEIGHT;

				// Role
				var role = new FlxText(0, y, FlxG.width, entry[1]);
				role.setFormat(Paths.font("vcr.ttf"), 24, 0xFFAAAAAA, CENTER);
				role.scrollFactor.set();
				add(role);
				texts.push(role);
				y += LINE_HEIGHT * 1.1;
			}
		}

		totalHeight = y + FlxG.height;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new EXEMenu());
			return;
		}

		if (done) return;

		var speed = SCROLL_SPEED;
		if (FlxG.keys.pressed.SHIFT) speed *= 4;

		scrollY += speed * elapsed;

		for (t in texts)
			t.y -= speed * elapsed;

		// finished when all text scrolled off screen
		if (texts.length > 0 && texts[texts.length - 1].y + texts[texts.length - 1].height < 0)
		{
			done = true;
			new FlxTimer().start(1, function(_) MusicBeatState.switchState(new EXEMenu()));
		}
	}
}
