package options;

import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.util.FlxAxes;
import flixel.util.FlxGradient;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.util.FlxTimer;

import openfl.display.BitmapData;
import openfl.display.Shape;

import shaders.CirclesShader;
import states.EXEMenu;
import backend.Language;

class OptionsState extends MusicBeatState
{
	var bg:FlxSprite;
	var title:FlxSprite;
	var circleRadius:Float = 100;
	var circleThickness:Int = 22;
	var orbitAngle:Float = 0;
	var orbitDotA:FlxSprite;
	var orbitDotB:FlxSprite;
	var orbitDotScale:Float = 1.0;

	var circleRadius2:Float = 100;
	var orbitAngle2:Float = 0;
	var orbitDotA2:FlxSprite;
	var orbitDotB2:FlxSprite;
	var orbitDotScale2:Float = 1.0;

	var circleShader:CirclesShader;
	static final SECTION_KEYS = ["CONTROLS", "VISUALS", "GAMEPLAY", "GRAPHICS", "LANGUAGE", "GAMEJOLT"];
	static final SECTION_NEIGHBORS:Array<Array<Int>> = [
		[-1,    1,    -1,    2],
		[ 0,   -1,    -1,    3],
		[-1,    3,     0,    4],
		[ 2,   -1,     1,    5],
		[-1,    5,     2,   -1],
		[ 4,   -1,     3,   -1],
	];

	var sectionsList:Array<String> = [];
	var sectionsGrp:FlxTypedGroup<FlxText>;
	var sectionBGGrp:FlxTypedGroup<FlxSprite>;
	var sectionBGClone:FlxSprite;
	var sectionBGCloneWhite:FlxSprite;
	var selectionTween:FlxTween;
	var cloneColorTween:FlxTween;
	var titleAlphaTween:FlxTween;
	var sectionPos:Array<Dynamic> = [];

	var canAction:Bool = true;
	public static var curSelected:Int = 0;
	public static var onPlayState:Bool = false;

	public static var standaloneReturnState:Void->flixel.FlxState = null;

	final GLOBAL_SCALE:Float = (FlxG.width / 3840);

	override public function create()
	{
		super.create();

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF7a1520, 0xFF4a0910], 1, 90);
		add(bg);

		final tileSize:Int = 40;
		final bmpChecker = new BitmapData(tileSize * 2, tileSize * 2, false, 0xFF000000);
		bmpChecker.fillRect(new openfl.geom.Rectangle(0, 0, tileSize, tileSize), 0xFF5a0a0a);
		bmpChecker.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF5a0a0a);

		final checker = new FlxBackdrop(bmpChecker, FlxAxes.XY);
		checker.antialiasing = false;
		checker.velocity.set(60, 60);
		checker.alpha = 0.10;
		add(checker);

		var maxRadius:Int = 600;

		final bgCanvas = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		bgCanvas.scale.set(FlxG.width, FlxG.height);
		bgCanvas.updateHitbox();
		bgCanvas.screenCenter();

		circleShader = new CirclesShader();
		circleShader.u_resolution.value = [FlxG.width, FlxG.height];
		circleShader.u_thickness.value = [circleThickness];
		bgCanvas.shader = circleShader;
		add(bgCanvas);

		final dotSize:Int = 160;
		final dotShape = new Shape();
		dotShape.graphics.beginFill(0x4a0008);
		dotShape.graphics.drawCircle(dotSize / 2, dotSize / 2, dotSize / 2);
		dotShape.graphics.endFill();
		final bmpDotA = new BitmapData(dotSize, dotSize, true, 0x00000000); bmpDotA.draw(dotShape);
		orbitDotA = new FlxSprite().loadGraphic(bmpDotA); add(orbitDotA);
		orbitDotB = new FlxSprite().loadGraphic(bmpDotA); add(orbitDotB);

		final dotShape2 = new Shape();
		dotShape2.graphics.beginFill(0x3b060c, 1);
		dotShape2.graphics.drawCircle(dotSize / 2, dotSize / 2, dotSize / 2);
		dotShape2.graphics.endFill();

		final bmpDotA2 = new BitmapData(dotSize, dotSize, true, 0x00000000); bmpDotA2.draw(dotShape2);
		orbitDotA2 = new FlxSprite().loadGraphic(bmpDotA2); add(orbitDotA2);
		orbitDotB2 = new FlxSprite().loadGraphic(bmpDotA2); add(orbitDotB2);
		FlxTween.tween(this, {orbitDotScale: 0.3}, 14.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		FlxTween.tween(this, {orbitDotScale2: 0.3}, 14.0, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

		circleRadius = 100;
		circleRadius2 = 100;

		FlxTween.tween(this, {circleRadius: maxRadius}, 8.0, {
			ease: FlxEase.sineInOut, 
			type: FlxTweenType.PINGPONG
		});
		new FlxTimer().start(4.0, function(_) {
			FlxTween.tween(this, {circleRadius2: maxRadius}, 8.0, {
				ease: FlxEase.sineInOut, 
				type: FlxTweenType.PINGPONG
			});
		});

		final vigWLeft:Int  = 420;
		final vigWRight:Int = 420;
		final vigH:Int      = 200;

		final vigLeft:FlxSprite = FlxGradient.createGradientFlxSprite(vigWLeft, FlxG.height, [0x55000000, 0x00000000], 1, 0);
		vigLeft.x = -vigWLeft / 2;
		vigLeft.scrollFactor.set(0, 0);
		add(vigLeft);
		
		final vigRight:FlxSprite = FlxGradient.createGradientFlxSprite(vigWRight, FlxG.height, [0x00000000, 0x55000000], 1, 0);
		vigRight.x = FlxG.width - vigWRight / 2;
		vigRight.scrollFactor.set(0, 0);
		add(vigRight);

		final vigTop:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, vigH, [0x66000000, 0x00000000], 1, 90);
		vigTop.scrollFactor.set(0, 0);
		add(vigTop);

		title = new FlxSprite(0, 20).loadGraphic(Paths.getBitmapData('assets/exe/options/optionsTitle.jxl'));
		title.setGraphicSize(Std.int(title.width * GLOBAL_SCALE * 0.75));
		title.updateHitbox();
		title.screenCenter(X);
		add(title);

		sectionBGClone = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/sectionBGClone.jxl'));
		sectionBGClone.setGraphicSize(Std.int(sectionBGClone.width * GLOBAL_SCALE));
		sectionBGClone.updateHitbox();
		add(sectionBGClone);
		sectionBGCloneWhite = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/sectionBGWhite.jxl'));
		sectionBGCloneWhite.setGraphicSize(Std.int(sectionBGCloneWhite.width * GLOBAL_SCALE));
		sectionBGCloneWhite.updateHitbox();
		sectionBGCloneWhite.color = FlxColor.WHITE;
		sectionBGCloneWhite.alpha = 0;
		add(sectionBGCloneWhite);

		sectionBGGrp = new FlxTypedGroup<FlxSprite>();
		add(sectionBGGrp);
		sectionsGrp = new FlxTypedGroup<FlxText>();
		add(sectionsGrp);

		for (i in 0...SECTION_KEYS.length)
		{
			final section = new FlxText(0, 0, 0, "", 12);
			section.ID = i;
			sectionsGrp.add(section);
			sectionPos.push({x: 0, y: 0});

			final sectionBG = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/propertyBG.jxl'));
			sectionBG.setGraphicSize(Std.int(sectionBG.width * GLOBAL_SCALE));
			sectionBG.updateHitbox();
			sectionBG.ID = i;
			sectionBGGrp.add(sectionBG);
		}

		refreshSectionTexts();
		changeSelect();
		
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/options.ogg'), 1, true);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		#if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (circleShader != null)
		{
			circleShader.u_radius1.value[0] = circleRadius;
			circleShader.u_radius2.value[0] = circleRadius2;
		}

		if (orbitDotA != null && orbitDotB != null)
		{
			orbitAngle += elapsed * 20;

			final rad = orbitAngle * Math.PI / 180;
			final cx = FlxG.width / 2;
			final cy = FlxG.height / 2;
			final orbitR = circleRadius;

			final scaleA = orbitDotScale;
			final scaleB = 1.0 - orbitDotScale + 0.3;

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

			final rad2 = orbitAngle2 * Math.PI / 180;
			final cx = FlxG.width / 2;
			final cy = FlxG.height / 2;

			final scaleA2 = orbitDotScale2;
			final scaleB2 = 1.0 - orbitDotScale2 + 0.3;

			orbitDotA2.scale.set(scaleA2, scaleA2);
			orbitDotA2.updateHitbox();

			final orbitR2 = circleRadius2 - circleThickness / 2;
			orbitDotA2.x = cx + Math.cos(rad2) * orbitR2 - orbitDotA2.width / 2;
			orbitDotA2.y = cy + Math.sin(rad2) * orbitR2 - orbitDotA2.height / 2;

			orbitDotB2.scale.set(scaleB2, scaleB2);
			orbitDotB2.updateHitbox();
			orbitDotB2.x = cx + Math.cos(rad2 + Math.PI) * orbitR2 - orbitDotB2.width / 2;
			orbitDotB2.y = cy + Math.sin(rad2 + Math.PI) * orbitR2 - orbitDotB2.height / 2;
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
				var sep = 14;
				var bg = sectionBGGrp.members[txt.ID];
				bg.x = txt.x + (txt.width - bg.width) / 2;
				bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
			}
		});
		
		if (!canAction || subState != null) return;

		var moved = false;
		if (controls.UI_LEFT_P)  { final n = SECTION_NEIGHBORS[curSelected][0]; if (n != -1) { curSelected = n; moved = true; } }
		if (controls.UI_RIGHT_P) { final n = SECTION_NEIGHBORS[curSelected][1]; if (n != -1) { curSelected = n; moved = true; } }
		if (controls.UI_UP_P)    { final n = SECTION_NEIGHBORS[curSelected][2]; if (n != -1) { curSelected = n; moved = true; } }
		if (controls.UI_DOWN_P)  { final n = SECTION_NEIGHBORS[curSelected][3]; if (n != -1) { curSelected = n; moved = true; } }

		if (moved)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelect(0);
		}

		#if mobile
		for(i in 0...SECTION_KEYS.length) {
			if(curSelected != i && FlxG.mouse.overlaps(sectionBGGrp.members[i])) {
				curSelected = i;
				changeSelect(0);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}
		#end

		if (controls.ACCEPT #if mobile || (shortPress && FlxG.mouse.overlaps(sectionBGGrp.members[curSelected])) #end)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			select();
		}

		if (controls.BACK #if mobile || backPressed #end)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (onPlayState)
			{
				onPlayState = false;
				if (PlayState.SONG != null)
				{
					backend.StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
				}
				else
				{
					var returnState = standaloneReturnState;
					standaloneReturnState = null;
					FlxG.switchState(returnState != null ? returnState : () -> new states.EXEFreeplay());
				}
			}
			else
			{
				FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'), 1, true);
				FlxG.switchState(() -> new EXEMenu());
			}
		}
	}

	var selectionCloneTween:FlxTween = null;
	function changeSelect(x:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + x, 0, SECTION_KEYS.length - 1);
		if (sectionBGGrp.members[curSelected] == null) return;

		final curSectionBG = sectionBGGrp.members[curSelected];
		final curSectionText = sectionsGrp.members[curSelected];
		final currentPos = sectionPos[curSelected];
		
		sectionBGClone.setPosition(curSectionBG.x - 3, curSectionBG.y - 3);
		curSectionBG.x -= 8;
		curSectionBG.y -= 8;
		curSectionText.x -= 8;
		curSectionText.y -= 8;

		selectionTween?.cancel();
		selectionTween = FlxTween.tween(curSectionText, {x: currentPos.x - 12, y: currentPos.y - 16}, 0.18, {
			ease: FlxEase.quadInOut,
			onComplete: (_) -> selectionTween = null
		});

		selectionCloneTween?.cancel();
		selectionCloneTween = FlxTween.tween(sectionBGClone, {x: curSectionBG.x + 13, y: curSectionBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> sectionBGCloneWhite.setPosition(sectionBGClone.x, sectionBGClone.y),
			onComplete: (_) -> selectionCloneTween = null
		});
		
		cloneColorTween?.cancel();
		sectionBGCloneWhite.setPosition(sectionBGClone.x, sectionBGClone.y);
		sectionBGCloneWhite.alpha = 0;
		cloneColorTween = FlxTween.tween(sectionBGCloneWhite, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
	}

	function select()
	{
		canAction = false;
		final curSectionText = sectionsGrp.members[curSelected];
		FlxFlicker.flicker(curSectionText, 1, 0.06, true, false);

		new FlxTimer().start(0.4, function(_)
		{
			if (titleAlphaTween != null) titleAlphaTween.cancel();
			titleAlphaTween = FlxTween.tween(title, {alpha: 0.5}, 0.3, {ease: FlxEase.sineInOut, onComplete: (_) -> titleAlphaTween = null});

			switch (SECTION_KEYS[curSelected])
			{
				case "CONTROLS":  openSubState(new #if mobile options.ExeMobileControlsState() #else options.ExeControlsState() #end);
				case "VISUALS":   openSubState(new options.ExeVisualsState());
				case "GRAPHICS":  openSubState(new options.ExeGraphicsState());
				case "GAMEPLAY":  openSubState(new options.ExeGameplayState());
				case "LANGUAGE":  openSubState(new options.ExeLanguageState());
				case "GAMEJOLT":  openSubState(new options.ExeGameJoltState());
			}
		});
	}

	function refreshSectionTexts():Void
	{
		sectionsList = [
			Language.get('options.controls',  'CONTROLS'),
			Language.get('options.visuals',   'VISUALS'),
			Language.get('options.gameplay',  'GAMEPLAY'),
			Language.get('options.graphics',  'GRAPHICS'),
			Language.get('options.language',  'LANGUAGE'),
			Language.get('options.gamejolt',  'GAMEJOLT')
		];

		var langFont = ExeBaseOptionsState.getLangFont();
		var langSize = Language.scaledFontSize(26);
		var rowSpacing:Float = 180;
		var colOffset:Float = 220;
		var baseY:Float = FlxG.height / 2 - rowSpacing;
		var cx:Float = FlxG.width / 2;
		final centerXs:Array<Float> = [cx - colOffset, cx + colOffset, cx - colOffset, cx + colOffset, cx - colOffset, cx + colOffset];
		final centerYs:Array<Float> = [baseY, baseY, baseY + rowSpacing, baseY + rowSpacing, baseY + rowSpacing * 2, baseY + rowSpacing * 2];

		sectionsGrp.forEachExists((txt) -> {
			txt.font = Paths.font(langFont);
			txt.size = langSize;
			txt.text = sectionsList[txt.ID];
			
			txt.x = centerXs[txt.ID] - txt.width / 2;
			txt.y = centerYs[txt.ID];
			sectionPos[txt.ID] = {x: txt.x, y: txt.y};

			var bg = sectionBGGrp.members[txt.ID];
			if (bg != null) {
				bg.x = txt.x + (txt.width - bg.width) / 2;
				bg.y = (txt.y - (txt.size / 2)) + 35;
			}
		});
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		
		refreshSectionTexts();
		
		//neccesary shit
		final curSectionBG = sectionBGGrp.members[curSelected];
		final curSectionText = sectionsGrp.members[curSelected];
		final currentPos = sectionPos[curSelected];

		curSectionBG.x -= 8;
		curSectionBG.y -= 8;
		
		curSectionText.x = currentPos.x - 12;
		curSectionText.y = currentPos.y - 16;

		sectionBGClone.setPosition(curSectionBG.x + 13, curSectionBG.y + 13);
		sectionBGCloneWhite.setPosition(sectionBGClone.x, sectionBGClone.y);
		sectionBGCloneWhite.alpha = 0;
		
		canAction = true;

		titleAlphaTween?.cancel();
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
		bg = null; title = null; orbitDotA = null; orbitDotB = null; orbitDotA2 = null; orbitDotB2 = null;
		sectionsGrp = null; sectionBGGrp = null;
		sectionBGClone = null; sectionBGCloneWhite = null; sectionPos = null;
		super.destroy();
	}
}