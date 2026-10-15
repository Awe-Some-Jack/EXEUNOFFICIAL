package states;

import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import openfl.utils.Assets as AssetPaths;

class CreditsRollState extends MusicBeatState
{
	var timer:Float = 0;
	var credits:String = 'Not Found';
	var canLeave:Bool = false;

	var video:VideoSprite;
	var image1:FlxSprite;
	var image2:FlxSprite;
	var ring:FlxSprite;
	var bandana:FlxSprite;
	var logotxt:FlxSprite;
	var eyes:FlxSprite;
	var savedRingY:Float = 0;
	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;
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

			#if DISCORD_ALLOWED
			text = StringTools.replace(text, "{user}", DiscordClient.username ?? 'boyfriend');
			#else
			text = StringTools.replace(text, "{user}", 'boyfriend');
			#end

			var creditsTxt:FlxText = new FlxText(15, y, Std.int(FlxG.width * 0.6), text);
			creditsTxt.setFormat(Paths.font("sonic4.ttf"), size, 0xFFFFFFFF, "left");
			creditsTxt.antialiasing = ClientPrefs.data.antialiasing;
			add(creditsTxt);
			y += creditsTxt.height + 4;
		}

		final path:String = 'assets/exe/title/logo/';
		ring = new FlxSprite().loadGraphic(Paths.getBitmapData(path + 'ring.webp'));
		ring.scale.set(0.3, 0.3);
		ring.updateHitbox();
		ring.screenCenter(X);
		add(ring);

		savedRingY = ring.y;
		bandana = new FlxSprite(ring.x + (329 * 0.3)).loadGraphic(Paths.getBitmapData(path + 'bandana.webp'));
		bandana.scale.set(0.3, 0.3);
		bandana.updateHitbox();
		add(bandana);
		
		logotxt = new FlxSprite(ring.x + (711 * 0.3)).loadGraphic(Paths.getBitmapData(path + 'sonic.webp'));
		logotxt.scale.set(0.3, 0.3);
		logotxt.updateHitbox();
		add(logotxt);

		eyes = new FlxSprite(ring.x + (1074 * 0.3)).loadGraphic(Paths.getBitmapData(path + 'eyes.webp'));
		eyes.scale.set(0.3, 0.3);
		eyes.updateHitbox();
		add(eyes);

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/creditsroll.ogg'), 1, false);
		FlxG.sound.music.pause();
		new FlxTimer().start(0.1, _ -> {
			FlxG.sound.music.resume();
			Conductor.bpm = 89;
		});
		if (backend.EXEAchievements.isUnlocked('credits')) canLeave = true;
	}

	public var speed(default, set):Float = 1;
	var activateOnce:Bool = true;
	var lastTxt:FlxText;

	function set_speed(value:Float):Float
	{
		#if FLX_PITCH FlxG.sound.music.pitch = value; #end
		speed = value;
		return value;
	}

	var logoSine:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((FlxG.keys.pressed.SHIFT #if mobile || pressHolding #end) && speed != 3) speed = 3;
		else if (FlxG.keys.pressed.CONTROL && speed != 0.4) speed = 0.4;
		else if (!(FlxG.keys.pressed.SHIFT #if mobile || pressHolding #end) && !FlxG.keys.pressed.CONTROL && speed != 1) speed = 1;

		if (((controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end) || (controls.BACK #if mobile || backPressed #end)) && canLeave)
		{
			canLeave = false;
			FlxG.camera.fade(0xFF000000, 5, false, () -> { FlxG.switchState(() -> new states.EXEMenu()); }, true);
			FlxG.sound.music?.fadeOut(5);
		}

		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		if (timer >= 2.8)
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
						FlxG.sound.music?.fadeOut(5);
					});
				}
				return;
			}

			final amount:Float = 106 * elapsed * speed;
			for (member in members)
			{
				if (Std.isOfType(member, FlxText))
				{
					final text:FlxText = cast(member, FlxText);
					text.y -= amount;
					lastTxt = text;
				}
			}
			if (video != null) video.video.y -= amount;
			if (image1 != null) image1.y -= amount;
			if (image2 != null) image2.y -= amount;
			savedRingY -= amount;
		}
		else timer += elapsed * speed;

		logoSine += elapsed;
		if (ring != null) ring.y = savedRingY + Math.sin(logoSine) * 5;
		if (bandana != null) bandana.y = ring.y + (873 * 0.3) + Math.sin(logoSine - 0.02) * 4;
		if (logotxt != null) logotxt.y = ring.y + (777 * 0.3) + Math.sin(logoSine - 0.025) * 4;
		if (eyes != null) eyes.y = ring.y + (517 * 0.3) + Math.sin(logoSine - 0.5) * 2.5;
	}

	override function beatHit():Void
	{
		super.beatHit();
		trace(curBeat);
		switch(curBeat)
		{
			case 4: playVideo('assets/videos/introcutscene.mp4');
			case 20: playVideo('assets/videos/postIntro.mp4');
			case 36: playVideo('contents/STORY MODE/videos/tooslow.mp4');
			case 44: addImage('assets/exe/creditsroll/ts.webp');
			case 52: playVideo('contents/STORY MODE/videos/YRC.mp4');
			case 60: addImage('assets/exe/creditsroll/ycr.webp');
			case 68: playVideo('contents/STORY MODE/videos/tripletrouble.mp4');
			case 76: addImage('assets/exe/creditsroll/tt.webp');
			case 84: playVideo('contents/STORY MODE/videos/fake intro.mp4');
			case 92: addImage('contents/STORY MODE/images/final/finale.webp');
			case 110: playVideo('contents/STORY MODE/videos/EYE_TO_EYE intro.mp4');
			case 121: addImage('assets/exe/creditsroll/y.webp');
			case 130: trace('XD');
			case 137: trace('XD');
			case 144: addImage('assets/exe/creditsroll/xeno.webp');
			case 157: addImage('assets/exe/creditsroll/byebye.webp'); 
			case 170: addImage('assets/exe/creditsroll/scorched.webp');
			case 183: addImage('assets/exe/creditsroll/omw.webp');
			case 211: trace('XD');
			case 232: trace('XD');
			case 251: addImage('assets/exe/creditsroll/everyone.webp', 2.1, true);
		}
	}

	function playVideo(path:String)
	{
		video?.destroy();

		video = new VideoSprite(FlxG.random.float(FlxG.width / 2, FlxG.width - (FlxG.width * 0.45)), FlxG.height + 30);
		video.loadVideo(path, [VideoSprite.ARG_MUTED]);
		video.onFormat(() -> {
			final scaleFactor:Float = Math.min((FlxG.width * 0.4) / video.video.width, (FlxG.height * 0.4) / video.video.height);
			video.setGraphicSize(Std.int(video.video.width * scaleFactor), Std.int(video.video.height * scaleFactor));
		});
		video.playDelayed();
		video.video.angle = FlxG.random.float(-10, 10);
		add(video);
	}

	var _imageTurn:Int = 0;
	function addImage(path:String, ?scale:Float = 1, ?centered:Bool = false)
	{
		_imageTurn = (_imageTurn + 1) % 2;
		if (_imageTurn == 0)
		{
			image1?.destroy();

			image1 = new FlxSprite(FlxG.random.float(FlxG.width / 2, FlxG.width - (FlxG.width * 0.45)), FlxG.height + 50).loadGraphic(path);
			final scaleFactor:Float = Math.min((FlxG.width * 0.4) / image1.width, (FlxG.height * 0.4) / image1.height);
			image1.setGraphicSize(Std.int(image1.width * scaleFactor * scale), Std.int(image1.height * scaleFactor * scale));
			image1.updateHitbox();
			if (centered) image1.screenCenter(X);
			image1.angle = FlxG.random.float(-10, 10);
			add(image1);
		}
		else
		{
			image2?.destroy();

			image2 = new FlxSprite(FlxG.random.float(FlxG.width / 2, FlxG.width - (FlxG.width * 0.45)), FlxG.height + 50).loadGraphic(path);
			final scaleFactor:Float = Math.min((FlxG.width * 0.4) / image2.width, (FlxG.height * 0.4) / image2.height);
			image2.setGraphicSize(Std.int(image2.width * scaleFactor * scale), Std.int(image2.height * scaleFactor * scale));
			image2.updateHitbox();
			if (centered) image2.screenCenter(X);
			image2.angle = FlxG.random.float(-10, 10);
			add(image2);
		}
	}

	override function destroy()
	{
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		super.destroy();
	}
}