package states.parallax;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

typedef RenderData = {
	var asset:String;
	var offset:{x:Float, y:Float};
	var front:Bool;
}

typedef CharData = {
	var name:String;
	var info:String;
	var render:Array<RenderData>;
	var order:Int;
	var folder:String;
}

class InfoBioParallaxState extends MusicBeatState
{
	var ringdown:FlxSprite;
	var charRenders:Array<FlxSprite> = [];
	var ring:FlxSprite;

	var charBG:FlxSprite;
	var charName:FlxText;
	var charInfo:FlxText;
	var charDivider:FlxSprite;
	var arrowLeft:FlxText;
	var arrowRight:FlxText;
	var pageText:FlxText;
	var whiteFade:FlxSprite;

	var chars:Array<CharData> = [];
	var currentIndex:Int = 0;

	var characterSine:Float = 0;
	var transitioning:Bool = false;
	var needsBGUpdate:Bool = false;
	var renderBasePos:Array<{x:Float, y:Float}> = [];

	override function create()
	{
		super.create();

		loadCharData();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFFDE3F3F, 0xFF92454C));
		grid.antialiasing = false;
		grid.velocity.set(40, 40);
		add(grid);

		var spikestop:FlxBackdrop = new FlxBackdrop(Paths.getBitmapData('assets/exe/parallax/spike.webp'), X);
		spikestop.velocity.x = 60;
		spikestop.flipY = true;
		add(spikestop);

		var spikesbot:FlxBackdrop = new FlxBackdrop(Paths.getBitmapData('assets/exe/parallax/spike.webp'), X);
		spikesbot.y = FlxG.height - spikesbot.height;
		spikesbot.velocity.x = -60;
		add(spikesbot);

		charBG = new FlxSprite(20, 40).makeGraphic(550, 1, 0xAA000000);
		charBG.alpha = 0;
		add(charBG);

		charDivider = new FlxSprite(30, 0).makeGraphic(530, 4, 0xFFDE3F3F);
		charDivider.alpha = 0;
		add(charDivider);

		charName = new FlxText(30, 0, 530, '');
		charName.setFormat(Paths.font("Plaza Regular.ttf"), 72, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charName.borderSize = 2;
		charName.antialiasing = ClientPrefs.data.antialiasing;
		charName.alpha = 0;
		add(charName);

		charInfo = new FlxText(30, 0, 530, '');
		charInfo.setFormat(Paths.font("Plaza Regular.ttf"), 32, 0xFFEEEEEE, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		charInfo.borderSize = 1;
		charInfo.antialiasing = ClientPrefs.data.antialiasing;
		charInfo.alpha = 0;

		var fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 8;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;
		add(charInfo);

		arrowLeft = new FlxText(30, 0, 0, '<');
		arrowLeft.setFormat(Paths.font("Plaza Regular.ttf"), 50, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		arrowLeft.borderSize = 2;
		arrowLeft.antialiasing = ClientPrefs.data.antialiasing;
		arrowLeft.alpha = 0;
		add(arrowLeft);

		arrowRight = new FlxText(0, 0, 0, '>');
		arrowRight.setFormat(Paths.font("Plaza Regular.ttf"), 50, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		arrowRight.borderSize = 2;
		arrowRight.antialiasing = ClientPrefs.data.antialiasing;
		arrowRight.alpha = 0;
		add(arrowRight);

		pageText = new FlxText(0, 0, 0, '');
		pageText.setFormat(Paths.font("Plaza Regular.ttf"), 30, 0xFFCCCCCC, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		pageText.borderSize = 2;
		pageText.antialiasing = ClientPrefs.data.antialiasing;
		pageText.alpha = 0;
		add(pageText);

		ringdown = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/info/ringdown.webp'));
		ringdown.scale.set(0.25, 0.25);
		ringdown.updateHitbox();
		ringdown.x = (FlxG.width - ringdown.width) + 100;
		add(ringdown);

		ring = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/info/ring.webp'));
		ring.scale.set(0.25, 0.25);
		ring.updateHitbox();
		ring.x = (FlxG.width - ring.width) + 100;
		add(ring);

		whiteFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteFade.alpha = 1;
		add(whiteFade);

		if (chars.length > 0)
			loadChar(0);

		FlxTween.tween(whiteFade, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut});

		charBG.x = -40;
		FlxTween.tween(charBG, {alpha: 1, x: 20}, 0.5, {ease: FlxEase.cubeOut, startDelay: 0.1});
		FlxTween.tween(charName, {alpha: 1, x: 30}, 0.5, {ease: FlxEase.cubeOut, startDelay: 0.15});
		FlxTween.tween(charDivider, {alpha: 1}, 0.4, {ease: FlxEase.cubeOut, startDelay: 0.25});
		FlxTween.tween(charInfo, {alpha: 1, x: 30}, 0.5, {ease: FlxEase.cubeOut, startDelay: 0.2});
		FlxTween.tween(arrowLeft, {alpha: chars.length > 1 ? 1.0 : 0.0}, 0.4, {startDelay: 0.35});
		FlxTween.tween(arrowRight, {alpha: chars.length > 1 ? 1.0 : 0.0}, 0.4, {startDelay: 0.35});
		FlxTween.tween(pageText, {alpha: chars.length > 1 ? 0.8 : 0.0}, 0.4, {startDelay: 0.35});

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Parallax Menus", 'Checking Info Bios');
		#end

		#if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
	}

	function loadCharData():Void
	{
		var basePath:String = 'assets/exe/parallax/info/';
		var folders:Array<String> = Paths.readDirectory(basePath);

		for (folder in folders)
		{
			if (folder.contains('.')) continue;

			var jsonPath:String = basePath + folder + '/info-' + folder + '.json';
			#if !sys
			continue;
			#end
			if (!sys.FileSystem.exists(jsonPath)) continue;
			var jsonContent:String = Paths.getContent(jsonPath);

			var json:Dynamic = haxe.Json.parse(jsonContent);
			var renderArray:Array<RenderData> = [];

			if (json.render != null)
			{
				var rawRender:Array<Dynamic> = cast json.render;
				for (r in rawRender)
				{
					renderArray.push({
						asset: r[0],
						offset: {x: r[1][0], y: r[1][1]},
						front: r[2] == true
					});
				}
			}
			else
			{
				renderArray.push({asset: folder, offset: {x: 0, y: 0}, front: false});
			}

			chars.push({
				name:   json.name ?? 'Unknown',
				info:   json.info ?? 'No info.',
				render: renderArray,
				order:  json.order ?? 999,
				folder: folder
			});
		}

		chars.sort((a, b) -> a.order - b.order);
	}

	function loadChar(index:Int):Void
	{
		currentIndex = index;
		var data:CharData = chars[index];
		
		for (spr in charRenders)
			remove(spr);
		charRenders = [];
		renderBasePos = [];

		for (renders in data.render)
		{
			final basePath = 'assets/exe/parallax/info/' + data.folder + '/' + renders.asset + '.webp';
			final bitmap = Paths.getBitmapData(basePath);

			if (bitmap != null)
			{
				final spr:FlxSprite = new FlxSprite();
				spr.loadGraphic(bitmap);
				spr.scale.set(0.25, 0.25);
				spr.updateHitbox();
				spr.setPosition(ring.x + renders.offset.x, ((FlxG.height - ring.height) / 2) + renders.offset.y);
				spr.alpha = 0;

				renderBasePos.push({x: spr.x, y: spr.y});
				charRenders.push(spr);

				final targetIndex = members.indexOf(ring);
				insert(renders.front ? targetIndex + 1 : targetIndex, spr);

				FlxTween.tween(spr, {alpha: 1}, 0.35, {ease: FlxEase.cubeOut});
			}
			else
			{
				trace('Render asset not found: $basePath');
			}
		}

		charName.text = data.name;
		charInfo.text = data.info;

		final fmt:openfl.text.TextFormat = charInfo.textField.defaultTextFormat;
		fmt.leading = 8;
		charInfo.textField.setTextFormat(fmt);
		charInfo.textField.defaultTextFormat = fmt;

		if (chars.length > 1)
			pageText.text = (currentIndex + 1) + ' / ' + chars.length;

		needsBGUpdate = true;
	}

	function switchChar(newIndex:Int):Void
	{
		if (transitioning) return;
		transitioning = true;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (spr in charRenders)
			FlxTween.tween(spr, {alpha: 0}, 0.18, {ease: FlxEase.cubeIn});

		FlxTween.cancelTweensOf(charName);
		FlxTween.cancelTweensOf(charInfo);
		FlxTween.tween(charName, {alpha: 0, x: -30}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(charInfo, {alpha: 0, x: -30}, 0.18, {ease: FlxEase.cubeIn, onComplete: _ -> {
			loadChar(newIndex);
			charName.x = 90;
			charInfo.x = 90;
			FlxTween.tween(charName, {alpha: 1, x: 30}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(charInfo, {alpha: 1, x: 30}, 0.25, {ease: FlxEase.cubeOut, onComplete: _ -> transitioning = false});
		}});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (subState != null) return;

		if (!transitioning)
		{
			if (controls.BACK #if mobile || backPressed #end)
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(whiteFade, {alpha: 1}, 0.4, {ease: FlxEase.cubeIn, onComplete: _ ->
					FlxG.switchState(() -> new states.parallax.ParallaxState())
				});
			}

			if (chars.length > 1)
			{
				if (controls.UI_LEFT_P)
					switchChar(FlxMath.wrap(currentIndex - 1, 0, chars.length - 1));
				if (controls.UI_RIGHT_P)
					switchChar(FlxMath.wrap(currentIndex + 1, 0, chars.length - 1));
			}
		}

		if (needsBGUpdate)
		{
			needsBGUpdate = false;
			var contentH:Float = charName.height + 6 + charDivider.height + 10 + charInfo.height;
			var panelH:Float = contentH + 32;
			var panelY:Float = (FlxG.height - panelH) / 2;
			charBG.makeGraphic(550, Std.int(panelH), 0xAA000000);
			charBG.setPosition(20, panelY);
			charName.y = panelY + 16;
			charDivider.y = charName.y + charName.height + 6;
			charInfo.y = charDivider.y + charDivider.height + 10;
			var panelMid:Float = panelY + panelH / 2;
			arrowLeft.y = panelMid - arrowLeft.height / 2;
			arrowRight.x = 560 - arrowRight.width;
			arrowRight.y = panelMid - arrowRight.height / 2;
			pageText.x = 30 + (530 - pageText.width) / 2;
			pageText.y = panelY + panelH - pageText.height - 8;
		}

		characterSine += elapsed;

		if (chars.length > 1)
		{
			var arrowPulse:Float = 0.7 + Math.abs(Math.sin(characterSine * 2.5)) * 0.3;
			arrowLeft.alpha = arrowPulse;
			arrowRight.alpha = arrowPulse;
		}

		for (i in 0...charRenders.length)
			charRenders[i].y = renderBasePos[i].y + Math.sin(characterSine) * 10;

		ringdown.y = ((FlxG.height - ringdown.height) / 2) + (Math.sin(characterSine - 0.2) * 10);
		ring.y = ((FlxG.height - ring.height) / 2) + (Math.sin(characterSine - 0.2) * 10);
	}
}
