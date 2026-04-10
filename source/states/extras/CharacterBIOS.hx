package states.extras;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

typedef CharData = {
	var name:String;
	var info:String;
	var render:String;
	var order:Int;
	var folder:String;
}

class InfoBioParallaxState extends MusicBeatState
{
	var ringdown:FlxSprite;
	var charRender:FlxSprite;
	var ring:FlxSprite;

	var charBG:FlxSprite;
	var charName:FlxText;
	var charInfo:FlxText;

	var chars:Array<CharData> = [];
	var currentIndex:Int = 0;

	override function create()
	{
		super.create();

		loadCharData();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFDE3F3F, 0xFF92454C));
		grid.velocity.set(40, 40);
		add(grid);

		var spikestop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/spike.png'), X);
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.x = 60;
		spikestop.flipY = true;
		add(spikestop);

		var spikesbot:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/parallax/spike.png'), X);
		spikesbot.antialiasing = ClientPrefs.data.antialiasing;
		spikesbot.y = FlxG.height - spikesbot.height;
		spikesbot.velocity.x = -60;
		add(spikesbot);

		ringdown = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/ringdown.png'));
		ringdown.antialiasing = ClientPrefs.data.antialiasing;
		ringdown.scale.set(0.25, 0.25);
		ringdown.updateHitbox();
		add(ringdown);

		charRender = new FlxSprite();
		charRender.antialiasing = ClientPrefs.data.antialiasing;
		add(charRender);

		ring = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/info/ring.png'));
		ring.antialiasing = ClientPrefs.data.antialiasing;
		ring.scale.set(0.25, 0.25);
		ring.updateHitbox();
		add(ring);

		charBG = new FlxSprite(0, 0).makeGraphic(1, 1, 0x77000000);
		add(charBG);

		charName = new FlxText(40, 90, 0, '');
		charName.setFormat("assets/fonts/Plaza Regular.ttf", 100, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charName.borderSize = 2;
		charName.antialiasing = ClientPrefs.data.antialiasing;
		add(charName);

		charInfo = new FlxText(40, 200, 580, '');
		charInfo.setFormat("assets/fonts/Plaza Regular.ttf", 50, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charInfo.borderSize = 2;
		charInfo.antialiasing = ClientPrefs.data.antialiasing;
		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;
		add(charInfo);

		if (chars.length > 0)
			loadChar(0);
	}

	function loadCharData():Void
	{
		var basePath:String = 'assets/exe/parallax/info/';
		var folders:Array<String> = sys.FileSystem.readDirectory(basePath);

		for (folder in folders)
		{
			var folderPath:String = basePath + folder;
			if (!sys.FileSystem.isDirectory(folderPath)) continue;

			var jsonPath:String = folderPath + '/info-' + folder + '.json';
			if (!sys.FileSystem.exists(jsonPath)) continue;

			var json:Dynamic = haxe.Json.parse(sys.io.File.getContent(jsonPath));
			chars.push({
				name:   (json.name   != null) ? json.name   : 'Unknown',
				info:   (json.info   != null) ? json.info   : 'No info.',
				render: (json.render != null) ? json.render : folder,
				order:  (json.order  != null) ? json.order  : 999,
				folder: folder
			});
		}

		chars.sort((a, b) -> a.order - b.order);
	}

	function loadChar(index:Int):Void
	{
		currentIndex = index;
		var data:CharData = chars[index];

		var renderPath:String = 'assets/exe/parallax/info/' + data.folder + '/' + data.render + '.png';
		charRender.loadGraphic(Assets.getBitmapData(renderPath));
		charRender.scale.set(0.25, 0.25);
		charRender.updateHitbox();

		charName.text = data.name;
		charInfo.text = data.info;

		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 5;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;

		charBG.setPosition(charInfo.x - 10, charInfo.y - 10);
		charBG.makeGraphic(Std.int(charInfo.width + 20), Std.int(charInfo.height + 20), 0x77000000);
	}

	var characterSine:Float = 0;
	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!transitioning)
		{
			if (Controls.instance.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new ParallaxState());
			}

			if (FlxG.mouse.overlaps(scrollTxt))
			{
				scrollTxt.color = FlxColor.YELLOW;

				if (FlxG.mouse.justPressed)
				{
					canScrollAutomactially = !canScrollAutomactially;
					
					if (!canScrollAutomactially)
					{
						if (moveTween != null){
				moveTween.cancel();
				moveTween = null;
			}
			moveCounter = 0;
					canMove = true;
					}
				}
			}
			else
			{
				scrollTxt.color = FlxColor.WHITE;
			}

			if (canScrollAutomactially) scrollTxt.text = "auto scroll: on";
			else scrollTxt.text = "auto scroll: off";

			charName.x = textCenter.x + (textCenter.width - charName.width) / 2;
			artistName.x = textCenter.x + (textCenter.width - artistName.width) / 2;
			scrollTxt.x = bioBox.x + (bioBox.width - scrollTxt.width) / 2;

			if (controls.RESET)
				FlxG.resetState();

			var canScroll:Bool = bioTxt.height > 600;

			if (canScrollAutomactially)
			{

				moveCounter += elapsed;

			if (canScroll && moveCounter > 5 && canMove)
			{
				canMove = false;
				moveTween = FlxTween.tween(bioTxt, {y: -(bioTxt.height - 600)}, 10);
			}
			}

			if (FlxG.mouse.wheel != 0 && FlxG.mouse.overlaps(bioBox) && canScroll)
			{
				if (canScrollAutomactially)
				{
					if (moveTween != null){
						moveTween.cancel();
						moveTween = null;
					}

					moveCounter = 0;
					canMove = true;
				}

				bioTxt.y += FlxG.mouse.wheel * 10;

				if (bioTxt.y > 0) bioTxt.y = 0;
				if (bioTxt.y < -(bioTxt.height - 600)) bioTxt.y = -(bioTxt.height - 600); 
			}

			if (chars_list.length > 1)
			{
			if (FlxG.mouse.wheel != 0 && !FlxG.mouse.overlaps(bioBox))
				changeCharBio(-FlxG.mouse.wheel * 1);
			if (controls.UI_UP_P)
				changeCharBio(-1);
			if (controls.UI_DOWN_P)
				changeCharBio(1);
			}
	}

	function moveDebbug(obj:FlxCamera)
	{
		if (FlxG.keys.justPressed.I)
				obj.scroll.y -= 10;
			if (FlxG.keys.justPressed.K)
				obj.scroll.y += 10;
			if (FlxG.keys.justPressed.J)
				obj.scroll.x -= 10;
			if (FlxG.keys.justPressed.L)
				obj.scroll.x += 10;

			if (FlxG.keys.justPressed.ANY)
				trace('x: ${obj.x} y: ${obj.y}');
			
	}

	function scaleDebbug(obj:FlxShape)
	{
		if (FlxG.keys.justPressed.F)
				obj.shapeWidth -= 10;
			if (FlxG.keys.justPressed.H)
				obj.shapeWidth += 10;
			if (FlxG.keys.justPressed.T)
				obj.shapeHeight -= 10;
			if (FlxG.keys.justPressed.G)
				obj.shapeHeight += 10;

			if (FlxG.keys.justPressed.ANY)
				trace('x: ${obj.shapeWidth} y: ${obj.shapeHeight}');
			
	}

	function changeCharBio(ola:Int = 0)
	{
		if (canScrollAutomactially)
		{
			if (moveTween != null){
				moveTween.cancel();
				moveTween = null;
			}
		
			moveCounter = 0;
			canMove = true;
		}

		curChar = FlxMath.wrap(curChar + ola, 0, chars_list.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);

		character.changeCharacter(chars_list[curChar]);
		icon.changeIcon(chars_list[curChar]);
		character.scale.set(0.5, 0.5);
		character.setPosition(offsets_list[curChar][0], offsets_list[curChar][1]);


		bioTxt.text = bios_list[curChar];
		bioTxt.y = 0;

		icon.setPosition(icon_offset[curChar][0], icon_offset[curChar][1]);

		charName.text = chars_list[curChar];
		artistName.text = 'by\n${artist_list[curChar]}';

		namesGrp.forEach(function(t:FlxText){
			if (t.ID == curChar)
			{
				t.color = FlxColor.YELLOW;
				CAM_FOLLOW.setPosition(t.x, t.y);
			}
			else
				t.color = FlxColor.WHITE;
		});
	}
}
