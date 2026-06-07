package options;

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.util.FlxGradient;
import openfl.Assets;
import openfl.display.BitmapData;

typedef LangOptionGroup = {
	var nameBG:FlxSprite;
	var valueBG:FlxSprite;
	var nameText:FlxText;
	var valueText:FlxText;
}

class ExeLanguageState extends MusicBeatSubstate
{
	static final TB_X:Float       = -134;
	static final TB_Y:Float       = 143;
	static final TB_SCALE_X:Float = 0.85;
	static final TB_SCALE_Y:Float = 0.475;

	static final NB_X:Float       = 105;
	static final NB_Y:Float       = 270;
	static final NB_SCALE_X:Float = 0.575;
	static final NB_SCALE_Y:Float = 0.275;

	static final VB_X:Float       = 683;
	static final VB_Y:Float       = 270;
	static final VB_SCALE_X:Float = 0.508;
	static final VB_SCALE_Y:Float = 0.275;

	static final FONT:String    = "SonicCD.ttf";
	static final FONT_SIZE:Int  = 18;

	static final LANG_KEYS:Array<String>   = ["en-US", "es-ES", "pt-BR", "ja-JP", "zh-CN", "ru-RU"];
	static final LANG_LABELS:Array<String> = ["ENGLISH", "SPANISH", "PORTUGUESE", "JAPANESE", "CHINESE", "RUSSIAN"];

	var titlebar:FlxSprite;
	var titlebarTxt:FlxText;
	var optionGroups:Array<LangOptionGroup> = [];

	var curLangIdx:Int = 0;
	var editingValue:Bool = false;
	var backLock:Bool = false;
	var introAnimating:Bool = true;

	var leftGroup:Array<FlxSprite>  = [];
	var rightGroup:Array<FlxSprite> = [];

	var selectionClone:FlxSprite;
	var selectionCloneWhite:FlxSprite;
	var selectionCloneV:FlxSprite;
	var selectionCloneWhiteV:FlxSprite;
	var selectionCloneTween:FlxTween;
	var cloneColorTween:FlxTween;
	var selectionCloneTweenV:FlxTween;
	var cloneColorTweenV:FlxTween;

	var debugMode:Bool = false;
	var debugSprites:Array<FlxSprite> = [];
	var debugSelected:Int = 0;
	var debugInfoText:FlxText;
	var debugHintText:FlxText;
	var debugOverlay:FlxSprite;
	var moveSpeed:Float = 120;
	var scaleSpeed:Float = 0.5;

	override public function create()
	{
		super.create();

		var saved = LANG_KEYS.indexOf(ClientPrefs.data.language);
		curLangIdx = saved >= 0 ? saved : 0;

		buildUI();
	}

	function buildUI()
	{
		var rectX:Int = -20;
		var rectY:Int = 145;
		var rectW:Int = 1450;
		var rectH:Int = 500;

		var offLeft:Float  = -(rectW + 200);
		var offRight:Float = FlxG.width + 200;

		var bg = FlxGradient.createGradientFlxSprite(rectW, rectH, [0xFF920e1e, 0xFF6b0b15], 1, 90);
		bg.x = offRight; bg.y = rectY; bg.scrollFactor.set(0, 0);
		add(bg);
		rightGroup.push(bg);

		var borderH:Int = 5;
		var borderTop = new FlxSprite().makeGraphic(rectW, borderH, 0xFF5a0912);
		borderTop.x = offRight; borderTop.y = rectY; borderTop.scrollFactor.set(0, 0);
		var borderBot = new FlxSprite().makeGraphic(rectW, borderH, 0xFF5a0912);
		borderBot.x = offRight; borderBot.y = rectY + rectH - borderH; borderBot.scrollFactor.set(0, 0);

		var gridSize:Int = 20;
		var gridTile = new BitmapData(gridSize, gridSize, true, 0x00000000);
		for (px in 0...gridSize) { gridTile.setPixel32(px, 0, 0x22000000); gridTile.setPixel32(0, px, 0x22000000); }
		var tilesX:Int = Math.ceil(rectW / gridSize) + 1;
		var gridFullBmp = new BitmapData(tilesX * gridSize, rectH, true, 0x00000000);
		for (tx in 0...tilesX)
			for (ty in 0...Math.ceil(rectH / gridSize))
				gridFullBmp.copyPixels(gridTile, gridTile.rect, new openfl.geom.Point(tx * gridSize, ty * gridSize));
		var grid = new FlxBackdrop(gridFullBmp, X);
		grid.x = offRight; grid.y = rectY; grid.velocity.x = -40; grid.scrollFactor.set(0, 0);
		grid.clipRect = new flixel.math.FlxRect(0, 0, rectW, rectH);
		add(grid);
		rightGroup.push(grid);

		add(borderTop);
		add(borderBot);
		rightGroup.push(borderTop);
		rightGroup.push(borderBot);

		titlebar = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		titlebar.scale.set(TB_SCALE_X, TB_SCALE_Y); titlebar.updateHitbox();
		titlebar.x = offLeft; titlebar.y = TB_Y; titlebar.scrollFactor.set(0, 0);
		add(titlebar);
		leftGroup.push(titlebar);

		titlebarTxt = new FlxText(0, 0, Std.int(titlebar.width), "LANGUAGE", 28);
		titlebarTxt.setFormat(Paths.font(FONT), 28, FlxColor.WHITE, CENTER);
		titlebarTxt.x = offLeft;
		titlebarTxt.y = TB_Y + (titlebar.height - titlebarTxt.height) / 2 - 15;
		titlebarTxt.scrollFactor.set(0, 0);
		add(titlebarTxt);
		leftGroup.push(cast titlebarTxt);

		selectionClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGClone.png'));
		selectionClone.scale.set(NB_SCALE_X, NB_SCALE_Y); selectionClone.updateHitbox();
		selectionClone.x = offRight; selectionClone.scrollFactor.set(0, 0); add(selectionClone);
		rightGroup.push(selectionClone);

		selectionCloneWhite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		selectionCloneWhite.scale.set(NB_SCALE_X, NB_SCALE_Y); selectionCloneWhite.updateHitbox();
		selectionCloneWhite.alpha = 0; selectionCloneWhite.x = offRight; selectionCloneWhite.scrollFactor.set(0, 0); add(selectionCloneWhite);
		rightGroup.push(selectionCloneWhite);

		selectionCloneV = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGClone.png'));
		selectionCloneV.scale.set(VB_SCALE_X, VB_SCALE_Y); selectionCloneV.updateHitbox();
		selectionCloneV.x = offRight; selectionCloneV.scrollFactor.set(0, 0); add(selectionCloneV);
		rightGroup.push(selectionCloneV);

		selectionCloneWhiteV = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		selectionCloneWhiteV.scale.set(VB_SCALE_X, VB_SCALE_Y); selectionCloneWhiteV.updateHitbox();
		selectionCloneWhiteV.alpha = 0; selectionCloneWhiteV.x = offRight; selectionCloneWhiteV.scrollFactor.set(0, 0); add(selectionCloneWhiteV);
		rightGroup.push(selectionCloneWhiteV);

		debugOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xAA000000);
		debugOverlay.scrollFactor.set(0, 0); debugOverlay.visible = false; add(debugOverlay);

		debugInfoText = new FlxText(10, 10, 0, "", 16);
		debugInfoText.setFormat(Paths.font(FONT), 16, FlxColor.WHITE, LEFT);
		debugInfoText.scrollFactor.set(0, 0); debugInfoText.visible = false; add(debugInfoText);

		debugHintText = new FlxText(10, FlxG.height - 80, 0, "[F1] toggle  [Z] spawn  [Tab] select  [WASD] move X/Y  [Q/E] scale all  [Arrows] scale X/Y  [T] trace  [Del] delete", 13);
		debugHintText.setFormat(Paths.font(FONT), 13, 0xFFAAAAAA, LEFT);
		debugHintText.scrollFactor.set(0, 0); debugHintText.visible = false; add(debugHintText);

		buildRow();
		playIntro(rectX);
	}

	function buildRow()
	{
		for (g in optionGroups)
		{
			rightGroup.remove(g.nameBG);  remove(g.nameBG); g.nameBG.destroy();
			rightGroup.remove(g.valueBG); remove(g.valueBG); g.valueBG.destroy();
			rightGroup.remove(g.nameText); remove(g.nameText); g.nameText.destroy();
			rightGroup.remove(g.valueText); remove(g.valueText); g.valueText.destroy();
		}
		optionGroups = [];

		var offRight:Float = FlxG.width + 200;
		var rowY = NB_Y;

		var nameBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		nameBG.scale.set(NB_SCALE_X, NB_SCALE_Y); nameBG.updateHitbox();
		nameBG.x = introAnimating ? offRight : NB_X; nameBG.y = rowY; nameBG.scrollFactor.set(0, 0);
		insert(members.indexOf(debugOverlay), nameBG);
		rightGroup.push(nameBG);

		var valueBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		valueBG.scale.set(VB_SCALE_X, VB_SCALE_Y); valueBG.updateHitbox();
		valueBG.x = introAnimating ? offRight : VB_X; valueBG.y = rowY; valueBG.scrollFactor.set(0, 0);
		insert(members.indexOf(debugOverlay), valueBG);
		rightGroup.push(valueBG);

		var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), "LANGUAGE", FONT_SIZE);
		nameTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, LEFT);
		nameTxt.x = introAnimating ? offRight : NB_X + 120;
		nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2;
		nameTxt.scrollFactor.set(0, 0);
		insert(members.indexOf(debugOverlay), nameTxt);
		rightGroup.push(cast nameTxt);

		var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), LANG_LABELS[curLangIdx], FONT_SIZE);
		valueTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, CENTER);
		valueTxt.x = introAnimating ? offRight : VB_X + (valueBG.width - valueTxt.width) / 2;
		valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2;
		valueTxt.scrollFactor.set(0, 0);
		insert(members.indexOf(debugOverlay), valueTxt);
		rightGroup.push(cast valueTxt);

		optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});

		if (!introAnimating) changeSelection();
	}

	function playIntro(rectX:Int)
	{
		var dur:Float = 0.45;
		var ease = FlxEase.quartOut;

		FlxTween.tween(titlebar,    {x: TB_X}, dur, {ease: ease});
		FlxTween.tween(titlebarTxt, {x: TB_X + (titlebar.width - titlebarTxt.width) / 2}, dur, {ease: ease});

		for (spr in rightGroup)
			FlxTween.tween(spr, {x: getTargetX(spr)}, dur, {ease: ease});

		new flixel.util.FlxTimer().start(dur + 0.05, (_) -> {
			introAnimating = false;
			changeSelection();
		});
	}

	function playOutro()
	{
		introAnimating = true;
		var dur:Float = 0.35;
		var ease = FlxEase.quartIn;
		var offLeft:Float  = -(FlxG.width + 200);
		var offRight:Float = FlxG.width + 200;

		for (spr in leftGroup)
			FlxTween.tween(spr, {x: offLeft}, dur, {ease: ease});
		for (spr in rightGroup)
			FlxTween.tween(spr, {x: offRight}, dur, {ease: ease});

		new flixel.util.FlxTimer().start(dur + 0.05, (_) -> close());
	}

	function getTargetX(spr:FlxSprite):Float
	{
		if (spr == selectionClone || spr == selectionCloneWhite)
		{
			var g = optionGroups.length > 0 ? optionGroups[0] : null;
			return g != null ? g.nameBG.x - 3 : NB_X - 3;
		}
		if (spr == selectionCloneV || spr == selectionCloneWhiteV)
		{
			var g = optionGroups.length > 0 ? optionGroups[0] : null;
			return g != null ? g.valueBG.x - 3 : VB_X - 3;
		}
		for (g in optionGroups)
		{
			if (spr == g.nameBG)    return NB_X;
			if (spr == g.nameText)  return NB_X + 120;
			if (spr == g.valueBG)   return VB_X;
			if (spr == g.valueText) return VB_X + (g.valueBG.width - g.valueText.width) / 2;
		}
		return -20;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F1)
		{
			debugMode = !debugMode;
			debugOverlay.visible = debugMode;
			debugInfoText.visible = debugMode;
			debugHintText.visible = debugMode;
			if (debugMode && debugSprites.length == 0) spawnDebugSprite();
		}

		if (debugMode) { updateDebugMode(elapsed); return; }
		if (introAnimating) return;

		if (backLock) { backLock = false; return; }

		if (editingValue)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				curLangIdx = FlxMath.wrap(curLangIdx + (controls.UI_RIGHT_P ? 1 : -1), 0, LANG_KEYS.length - 1);
				ClientPrefs.data.language = LANG_KEYS[curLangIdx];
				ClientPrefs.saveSettings();
				#if TRANSLATIONS_ALLOWED
				Language.reloadPhrases();
				#end
				var g = optionGroups[0];
				g.valueText.text = LANG_LABELS[curLangIdx];
				g.valueText.x = VB_X + (g.valueBG.width - g.valueText.width) / 2;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				editingValue = false;
				backLock = true;
				nudgeSelectedText(false);
			}
			return;
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			editingValue = true;
			nudgeSelectedText(true);
		}

		if (controls.BACK) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}

	function changeSelection()
	{
		if (optionGroups.length == 0) return;
		var group = optionGroups[0];

		selectionClone.setPosition(group.nameBG.x - 3, group.nameBG.y - 3);
		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(selectionClone, {x: group.nameBG.x + 13, y: group.nameBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y),
			onComplete: (_) -> selectionCloneTween = null
		});
		if (cloneColorTween != null) cloneColorTween.cancel();
		selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y);
		selectionCloneWhite.alpha = 0;
		cloneColorTween = FlxTween.tween(selectionCloneWhite, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

		selectionCloneV.setPosition(group.valueBG.x - 3, group.valueBG.y - 3);
		if (selectionCloneTweenV != null) selectionCloneTweenV.cancel();
		selectionCloneTweenV = FlxTween.tween(selectionCloneV, {x: group.valueBG.x + 13, y: group.valueBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhiteV.setPosition(selectionCloneV.x, selectionCloneV.y),
			onComplete: (_) -> selectionCloneTweenV = null
		});
		if (cloneColorTweenV != null) cloneColorTweenV.cancel();
		selectionCloneWhiteV.setPosition(selectionCloneV.x, selectionCloneV.y);
		selectionCloneWhiteV.alpha = 0;
		cloneColorTweenV = FlxTween.tween(selectionCloneWhiteV, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
	}

	function nudgeSelectedText(up:Bool)
	{
		if (optionGroups.length == 0) return;
		var g = optionGroups[0];
		var baseY = g.nameBG.y + (g.nameBG.height - g.nameText.height) / 2;
		var targetY = up ? baseY - 5 : baseY;
		FlxTween.tween(g.nameText,  {y: targetY}, 0.15, {ease: FlxEase.quadOut});
		FlxTween.tween(g.valueText, {y: targetY}, 0.15, {ease: FlxEase.quadOut});
	}

	function updateDebugMode(elapsed:Float)
	{
		if (debugSprites.length == 0) return;
		var spr = debugSprites[debugSelected];
		if (FlxG.keys.justPressed.TAB)
		{
			spr.color = FlxColor.WHITE;
			debugSelected = FlxG.keys.pressed.SHIFT
				? FlxMath.wrap(debugSelected - 1, 0, debugSprites.length - 1)
				: FlxMath.wrap(debugSelected + 1, 0, debugSprites.length - 1);
			spr = debugSprites[debugSelected];
		}
		for (i in 0...debugSprites.length) debugSprites[i].color = (i == debugSelected) ? 0xFFFFFF00 : FlxColor.WHITE;
		var spd = FlxG.keys.pressed.SHIFT ? moveSpeed * 3 : moveSpeed;
		if (FlxG.keys.pressed.A) spr.x -= spd * elapsed;
		if (FlxG.keys.pressed.D) spr.x += spd * elapsed;
		if (FlxG.keys.pressed.W) spr.y -= spd * elapsed;
		if (FlxG.keys.pressed.S) spr.y += spd * elapsed;
		if (FlxG.keys.pressed.E) { spr.scale.x += scaleSpeed * elapsed; spr.scale.y += scaleSpeed * elapsed; spr.updateHitbox(); }
		if (FlxG.keys.pressed.Q) { spr.scale.x = Math.max(0.01, spr.scale.x - scaleSpeed * elapsed); spr.scale.y = Math.max(0.01, spr.scale.y - scaleSpeed * elapsed); spr.updateHitbox(); }
		if (FlxG.keys.pressed.RIGHT) { spr.scale.x += scaleSpeed * elapsed; spr.updateHitbox(); }
		if (FlxG.keys.pressed.LEFT)  { spr.scale.x = Math.max(0.01, spr.scale.x - scaleSpeed * elapsed); spr.updateHitbox(); }
		if (FlxG.keys.pressed.DOWN) { spr.scale.y += scaleSpeed * elapsed; spr.updateHitbox(); }
		if (FlxG.keys.pressed.UP)   { spr.scale.y = Math.max(0.01, spr.scale.y - scaleSpeed * elapsed); spr.updateHitbox(); }
		if (FlxG.keys.justPressed.Z) spawnDebugSprite();
		if (FlxG.keys.justPressed.DELETE && debugSprites.length > 0)
		{
			remove(spr); spr.destroy(); debugSprites.splice(debugSelected, 1);
			if (debugSprites.length > 0) debugSelected = FlxMath.wrap(debugSelected, 0, debugSprites.length - 1);
		}
		if (FlxG.keys.justPressed.T) traceDebugSprites();
		if (debugSprites.length > 0)
		{
			var s = debugSprites[debugSelected];
			debugInfoText.text = '[DEBUG MODE]  sprite ${debugSelected + 1}/${debugSprites.length}\nx: ${Math.round(s.x)}  y: ${Math.round(s.y)}\nscaleX: ${Math.round(s.scale.x * 1000) / 1000}  scaleY: ${Math.round(s.scale.y * 1000) / 1000}\nwidth: ${Math.round(s.width)}  height: ${Math.round(s.height)}';
		}
		else debugInfoText.text = '[DEBUG MODE]  no sprites\n[Z] to spawn one';
	}

	function spawnDebugSprite()
	{
		var spr = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		spr.scale.set(TB_SCALE_X, TB_SCALE_Y); spr.updateHitbox(); spr.screenCenter(); spr.scrollFactor.set(0, 0);
		add(spr); debugSprites.push(spr); debugSelected = debugSprites.length - 1;
	}

	function traceDebugSprites()
	{
		trace('=== debug sprites (${debugSprites.length}) ===');
		for (i in 0...debugSprites.length)
		{
			var s = debugSprites[i];
			trace('[$i]  x=${Math.round(s.x)}  y=${Math.round(s.y)}  scaleX=${s.scale.x}  scaleY=${s.scale.y}  w=${Math.round(s.width)}  h=${Math.round(s.height)}');
		}
	}

	override function destroy()
	{
		titlebar = null; optionGroups = null; debugSprites = null;
		leftGroup = null; rightGroup = null;
		super.destroy();
	}
}
