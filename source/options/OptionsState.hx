package options;

import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.util.FlxAxes;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.util.FlxTimer;
import openfl.Assets;

import states.EXEMenu;

class OptionsState extends MusicBeatState
{
	var bg:FlxSprite;
	var title:FlxSprite;
	var debugCircle:FlxSprite;
	var debugText:FlxText;
	var circleRadius:Float = 100;
	var circleThickness:Int = 22;
	var circleTargetRadius:Float = 100;
	var orbitAngle:Float = 0;
	var orbitDotA:FlxSprite;
	var orbitDotB:FlxSprite;
	var orbitDotScale:Float = 1.0;

	var circleRadius2:Float = 100;
	var orbitAngle2:Float = 0;
	var orbitDotA2:FlxSprite;
	
	var orbitDotB2:FlxSprite;
	var orbitDotScale2:Float = 1.0;

	var sectionsList = ["CONTROLS", "VISUALS", "GAMEPLAY", "GRAPHICS", "LANGUAGE"];
	var sectionsGrp:FlxTypedGroup<FlxText>;
	var sectionBGGrp:FlxTypedGroup<FlxSprite>;
	var sectionBGClone:FlxSprite;
	var sectionBGCloneWhite:FlxSprite;
	var selectionTween:FlxTween;
	var cloneColorTween:FlxTween;
	var titleAlphaTween:FlxTween;
	var sectionPos:Array<Dynamic> = [];

	public static var curSelected:Int = 0;
	public static var onPlayState:Bool = false;

	var canAction:Bool = true;

	final GLOBAL_SCALE:Float = (FlxG.width / 3840);

	override public function create()
	{
		super.create();
		persistentUpdate = true;

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF7a1520, 0xFF4a0910], 1, 90);
		add(bg);

		var tileSize:Int = 40;
		var bmpChecker = new BitmapData(tileSize * 2, tileSize * 2, false, 0xFF000000);
		bmpChecker.fillRect(new openfl.geom.Rectangle(0,        0,        tileSize, tileSize), 0xFF5a0a0a);
		bmpChecker.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF5a0a0a);
		var checker = new FlxBackdrop(bmpChecker, FlxAxes.XY);
		checker.antialiasing = false;
		checker.velocity.set(60, 60);
		checker.alpha = 0.10;
		add(checker);

		var maxRadius:Int = 650;
		var bmpCircle = new BitmapData(maxRadius * 2, maxRadius * 2, true, 0x00000000);
		var shape = new openfl.display.Shape();
		var circle = new FlxSprite();
		circle.makeGraphic(maxRadius * 2, maxRadius * 2, 0x00000000);
		circle.screenCenter();
		add(circle);
		debugCircle = circle;
		circleRadius = 100;

		function updateCircle()
		{
			shape.graphics.clear();
			shape.graphics.lineStyle(circleThickness, 0x4a0008, 1);
			shape.graphics.drawCircle(maxRadius, maxRadius, circleRadius);
			bmpCircle.fillRect(new openfl.geom.Rectangle(0, 0, bmpCircle.width, bmpCircle.height), 0x00000000);
			bmpCircle.draw(shape);
			circle.pixels = bmpCircle;
			circle.screenCenter();
		}

		updateCircle();
		FlxTween.tween(this, {circleRadius: 600}, 8.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG,
			onUpdate: function(_) updateCircle()
		});

		var dotSize:Int = 160;
		var dotShape = new openfl.display.Shape();
		dotShape.graphics.beginFill(0x4a0008);
		dotShape.graphics.drawCircle(dotSize / 2, dotSize / 2, dotSize / 2);
		dotShape.graphics.endFill();

		var bmpDotA = new BitmapData(dotSize, dotSize, true, 0x00000000);
		bmpDotA.draw(dotShape);
		orbitDotA = new FlxSprite();
		orbitDotA.loadGraphic(bmpDotA);
		add(orbitDotA);

		var bmpDotB = new BitmapData(dotSize, dotSize, true, 0x00000000);
		bmpDotB.draw(dotShape);
		orbitDotB = new FlxSprite();
		orbitDotB.loadGraphic(bmpDotB);
		add(orbitDotB);

		FlxTween.tween(this, {orbitDotScale: 0.3}, 14.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

		var maxRadius2:Int = 650;
		var bmpCircle2 = new BitmapData(maxRadius2 * 2, maxRadius2 * 2, true, 0x00000000);
		var shape2 = new openfl.display.Shape();
		var circle2 = new FlxSprite();
		circle2.makeGraphic(maxRadius2 * 2, maxRadius2 * 2, 0x00000000);
		circle2.screenCenter();
		add(circle2);

		function updateCircle2()
		{
			shape2.graphics.clear();
			shape2.graphics.beginFill(0x3b060c, 1);
			shape2.graphics.drawCircle(maxRadius2, maxRadius2, circleRadius2);
			shape2.graphics.drawCircle(maxRadius2, maxRadius2, circleRadius2 - circleThickness);
			shape2.graphics.endFill();
			bmpCircle2.fillRect(new openfl.geom.Rectangle(0, 0, bmpCircle2.width, bmpCircle2.height), 0x00000000);
			bmpCircle2.draw(shape2);
			circle2.pixels = bmpCircle2;
			circle2.screenCenter();
		}

		updateCircle2();

		var dotSize2:Int = 160;
		var dotShape2 = new openfl.display.Shape();
		dotShape2.graphics.beginFill(0x3b060c, 1);
		dotShape2.graphics.drawCircle(dotSize2 / 2, dotSize2 / 2, dotSize2 / 2);
		dotShape2.graphics.endFill();

		var bmpDotA2 = new BitmapData(dotSize2, dotSize2, true, 0x00000000);
		bmpDotA2.draw(dotShape2);
		orbitDotA2 = new FlxSprite();
		orbitDotA2.loadGraphic(bmpDotA2);
		add(orbitDotA2);

		var bmpDotB2 = new BitmapData(dotSize2, dotSize2, true, 0x00000000);
		bmpDotB2.draw(dotShape2);
		orbitDotB2 = new FlxSprite();
		orbitDotB2.loadGraphic(bmpDotB2);
		add(orbitDotB2);

		new FlxTimer().start(4.0, function(_) {
			FlxTween.tween(this, {circleRadius2: 600}, 8.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG,
				onUpdate: function(_) updateCircle2()
			});
			FlxTween.tween(this, {orbitDotScale2: 0.3}, 14.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		});

		var vigWLeft:Int  = 420;
		var vigWRight:Int = 420;
		var vigH:Int      = 200;
		var vigLeft:FlxSprite = FlxGradient.createGradientFlxSprite(vigWLeft, FlxG.height, [0x55000000, 0x00000000], 1, 0);
		vigLeft.x = -vigWLeft / 2;
		vigLeft.scrollFactor.set(0, 0);
		add(vigLeft);
		var vigRight:FlxSprite = FlxGradient.createGradientFlxSprite(vigWRight, FlxG.height, [0x00000000, 0x55000000], 1, 0);
		vigRight.x = FlxG.width - vigWRight / 2;
		vigRight.scrollFactor.set(0, 0);
		add(vigRight);
		var vigTop:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, vigH, [0x66000000, 0x00000000], 1, 90);
		vigTop.scrollFactor.set(0, 0);
		add(vigTop);

		debugText = new FlxText(10, 10, 0, "", 16);
		debugText.scrollFactor.set();
		debugText.visible = false;
		add(debugText);


		title = new FlxSprite(0, 20).loadGraphic(Assets.getBitmapData('assets/exe/options/optionsTitle.png'));
		title.setGraphicSize(Std.int(title.width * GLOBAL_SCALE));
		title.updateHitbox();
		title.screenCenter(X);
		add(title);

		sectionBGClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGClone.png'));
		sectionBGClone.setGraphicSize(Std.int(sectionBGClone.width * GLOBAL_SCALE));
		sectionBGClone.updateHitbox();
		add(sectionBGClone);

		sectionBGCloneWhite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		sectionBGCloneWhite.setGraphicSize(Std.int(sectionBGCloneWhite.width * GLOBAL_SCALE));
		sectionBGCloneWhite.updateHitbox();
		sectionBGCloneWhite.color = FlxColor.WHITE;
		sectionBGCloneWhite.alpha = 0;
		add(sectionBGCloneWhite);

		sectionBGGrp = new FlxTypedGroup<FlxSprite>();
		add(sectionBGGrp);

		sectionsGrp = new FlxTypedGroup<FlxText>();
		add(sectionsGrp);

		for (i in 0...sectionsList.length)
		{
			var section = new FlxText(0, 0, 0, sectionsList[i], 50);
			section.setFormat(Paths.font("SonicCD.ttf"), 26, FlxColor.WHITE, CENTER);
			section.ID = i;
			section.screenCenter(X);
			var rowSpacing:Float = 180;
			var colOffset:Float = 220;
			var baseY:Float = FlxG.height / 2 - rowSpacing;

			switch (section.ID)
			{
				case 0:
					section.x -= colOffset;
					section.y = baseY;
				case 1:
					section.x += colOffset;
				section.y = baseY;
				case 2:
					section.x -= colOffset;
					section.y = baseY + rowSpacing;
				case 3:
					section.x += colOffset;
					section.y = baseY + rowSpacing;
				case 4:
					section.y = baseY + rowSpacing * 2;
			}

			sectionsGrp.add(section);
			sectionPos.push({x: section.x, y: section.y});

			var sectionBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			var sectionWidth = 28 * sectionsList[i].length;
			sectionBG.setGraphicSize(Std.int(sectionBG.width * GLOBAL_SCALE));
			sectionBG.updateHitbox();
			sectionBG.ID = i;
			sectionBG.x = section.x + ((sectionWidth - sectionBG.width) / 2);
			sectionBG.y = (section.y - (section.size / 2)) + 35;
			sectionBGGrp.add(sectionBG);
		}

		changeSelect();

		FlxG.sound.playMusic(openfl.Assets.getSound('assets/exe/options/options.ogg'), 1, true);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (orbitDotA != null && orbitDotB != null)
		{
			orbitAngle += elapsed * 20;
			var rad = orbitAngle * Math.PI / 180;
			var cx = FlxG.width / 2;
			var cy = FlxG.height / 2;
			var orbitR = circleRadius;

			var scaleA = orbitDotScale;
			var scaleB = 1.0 - orbitDotScale + 0.3;

			orbitDotA.scale.set(scaleA, scaleA);
			orbitDotA.updateHitbox();
			orbitDotA.x = cx + Math.cos(rad) * orbitR - orbitDotA.width / 2;
			orbitDotA.y = cy + Math.sin(rad) * orbitR - orbitDotA.height / 2;

			orbitDotB.scale.set(scaleB, scaleB);
			orbitDotB.updateHitbox();
			orbitDotB.x = cx + Math.cos(rad + Math.PI) * orbitR - orbitDotB.width / 2;
			orbitDotB.y = cy + Math.sin(rad + Math.PI) * orbitR - orbitDotB.height / 2;
		}

		if (orbitDotA2 != null && orbitDotB2 != null)
		{
			orbitAngle2 += elapsed * 20;
			var rad2 = orbitAngle2 * Math.PI / 180;
			var cx = FlxG.width / 2;
			var cy = FlxG.height / 2;

			var scaleA2 = orbitDotScale2;
			var scaleB2 = 1.0 - orbitDotScale2 + 0.3;

			orbitDotA2.scale.set(scaleA2, scaleA2);
			orbitDotA2.updateHitbox();
			var orbitR2 = circleRadius2 - circleThickness / 2;
			orbitDotA2.x = cx + Math.cos(rad2) * orbitR2 - orbitDotA2.width / 2;
			orbitDotA2.y = cy + Math.sin(rad2) * orbitR2 - orbitDotA2.height / 2;

			orbitDotB2.scale.set(scaleB2, scaleB2);
			orbitDotB2.updateHitbox();
			orbitDotB2.x = cx + Math.cos(rad2 + Math.PI) * orbitR2 - orbitDotB2.width / 2;
			orbitDotB2.y = cy + Math.sin(rad2 + Math.PI) * orbitR2 - orbitDotB2.height / 2;
		}

		if (FlxG.keys.justPressed.F2)
			debugText.visible = !debugText.visible;

		if (debugText.visible && debugCircle != null)
		{
			var step:Float = FlxG.keys.pressed.SHIFT ? 0.01 : 0.1;
			if (FlxG.keys.justPressed.UP)    { debugCircle.scale.x += step; debugCircle.scale.y += step; }
			if (FlxG.keys.justPressed.DOWN)  { debugCircle.scale.x -= step; debugCircle.scale.y -= step; }
			debugCircle.scale.x = Math.max(0.01, debugCircle.scale.x);
			debugCircle.scale.y = Math.max(0.01, debugCircle.scale.y);
			debugCircle.updateHitbox();
			debugCircle.screenCenter();
			debugText.text = 'CIRCLE DEBUG [F2 toggle]\nscale: ${Math.round(debugCircle.scale.x * 100) / 100}\nUP/DOWN = +/-0.1  |  SHIFT = +/-0.01';
		}


		sectionsGrp.forEachExists(function(txt)
		{
			if (sectionPos.length > 0)
			{
				var lerpX = FlxMath.lerp(txt.x, sectionPos[txt.ID].x, elapsed * 9);
				var lerpY = FlxMath.lerp(txt.y, sectionPos[txt.ID].y, elapsed * 9);
				if (txt.ID != curSelected)
				{
					txt.x = lerpX;
					txt.y = lerpY;
				}
				var sectionWidth = 28 * sectionsList[txt.ID].length;
				var sep = 14;
				var bg = sectionBGGrp.members[txt.ID];
				bg.x = txt.x + ((sectionWidth - bg.width) / 2);
				bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
			}
		});

		if (!canAction || subState != null) return;

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelect(controls.UI_LEFT_P ? -1 : 1);
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			select();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (onPlayState)
			{
				onPlayState = false;
				backend.StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else FlxG.switchState(() -> new EXEMenu());
		}
	}

	var selectionCloneTween:FlxTween;


	function changeSelect(x:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + x, 0, sectionsList.length - 1);
		if (sectionBGGrp.members[curSelected] == null) return;

		var curSectionBG = sectionBGGrp.members[curSelected];
		var curSectionText = sectionsGrp.members[curSelected];
		var currentPos = sectionPos[curSelected];

		sectionBGClone.setPosition(curSectionBG.x - 3, curSectionBG.y - 3);
		curSectionBG.x -= 8;
		curSectionBG.y -= 8;
		curSectionText.x -= 8;
		curSectionText.y -= 8;

		if (selectionTween != null) selectionTween.cancel();
		selectionTween = FlxTween.tween(curSectionText, {x: currentPos.x - 12, y: currentPos.y - 16}, 0.18, {
			ease: FlxEase.quadInOut,
			onComplete: (_) -> selectionTween = null
		});

		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(sectionBGClone, {x: curSectionBG.x + 13, y: curSectionBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> sectionBGCloneWhite.setPosition(sectionBGClone.x, sectionBGClone.y),
			onComplete: (_) -> selectionCloneTween = null
		});

		if (cloneColorTween != null) cloneColorTween.cancel();
		sectionBGCloneWhite.setPosition(sectionBGClone.x, sectionBGClone.y);
		sectionBGCloneWhite.alpha = 0;
		cloneColorTween = FlxTween.tween(sectionBGCloneWhite, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
	}

	function select()
	{
		canAction = false;
		var curSectionText = sectionsGrp.members[curSelected];
		FlxFlicker.flicker(curSectionText, 1, 0.06, true, false, (_) -> canAction = true);

		new FlxTimer().start(1.5, function(_)
		{
			if (titleAlphaTween != null) titleAlphaTween.cancel();
			titleAlphaTween = FlxTween.tween(title, {alpha: 0.5}, 0.3, {ease: FlxEase.sineInOut, onComplete: (_) -> titleAlphaTween = null});

			switch (sectionsList[curSelected])
			{
				case "CONTROLS":  openSubState(new options.ExeControlsState());
				case "VISUALS":   openSubState(new options.ExeVisualsState());
				case "GRAPHICS":  openSubState(new options.ExeGraphicsState());
				case "GAMEPLAY":  openSubState(new options.ExeGameplayState());
				case "LANGUAGE":
					openSubState(new options.ExeLanguageState());
			}
			canAction = true;
		});
	}


	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		canAction = true;
		if (titleAlphaTween != null) titleAlphaTween.cancel();
		titleAlphaTween = FlxTween.tween(title, {alpha: 1.0}, 0.3, {ease: FlxEase.sineInOut, onComplete: (_) -> titleAlphaTween = null});
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function destroy()
	{
		if (selectionTween != null)      { selectionTween.cancel();      selectionTween = null; }
		if (selectionCloneTween != null) { selectionCloneTween.cancel(); selectionCloneTween = null; }
		if (cloneColorTween != null)     { cloneColorTween.cancel();     cloneColorTween = null; }
		if (titleAlphaTween != null)     { titleAlphaTween.cancel();     titleAlphaTween = null; }
		bg = null; title = null; orbitDotA = null; orbitDotB = null; orbitDotA2 = null; orbitDotB2 = null; debugCircle = null;
		sectionsGrp = null; sectionBGGrp = null;
		sectionBGClone = null; sectionBGCloneWhite = null; sectionPos = null;
		super.destroy();
	}
}
