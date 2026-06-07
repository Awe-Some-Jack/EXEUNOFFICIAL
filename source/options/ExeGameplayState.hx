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

typedef ExeGameplayOption = {
	var label:String;
	var getValue:Void->Dynamic;
	var setValue:Dynamic->Void;
	@:optional var isInt:Bool;
	@:optional var isFloat:Bool;
}

typedef GameplayOptionGroup = {
	var nameBG:FlxSprite;
	var valueBG:FlxSprite;
	var nameText:FlxText;
	var valueText:FlxText;
}

class ExeGameplayState extends MusicBeatSubstate
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

	static final ROW_GAP:Float    = 80;
	static final FONT:String      = "SonicCD.ttf";
	static final FONT_SIZE:Int    = 18;
	static final PAGE_SIZE:Int    = 4;

	static final ARR_L_X:Float   = 773;
	static final ARR_R_X:Float   = 1075;
	static final ARR_SCALE:Float = 0.125;

	var titlebar:FlxSprite;
	var titlebarTxt:FlxText;
	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	var arrowTweenL:FlxTween;
	var arrowTweenR:FlxTween;
	var optionGroups:Array<GameplayOptionGroup> = [];

	var allOptions:Array<ExeGameplayOption>;
	var pageOptions:Array<Array<ExeGameplayOption>> = [];

	public static var curSelected:Int = 0;
	public static var curPage:Int = 0;
	var editingValue:Bool = false;
	var backLock:Bool = false;
	var introAnimating:Bool = true;
	var holdTimer:Float = 0;
	var holdRepeat:Float = 0;

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


	override public function create()
	{
		super.create();

		allOptions = [
			{label: "DOWNSCROLL",  getValue: () -> ClientPrefs.data.downScroll,  setValue: (v) -> ClientPrefs.data.downScroll  = v},
			{label: "SICK WINDOW", getValue: () -> ClientPrefs.data.sickWindow,  setValue: (v) -> ClientPrefs.data.sickWindow  = v, isFloat: true},
			{label: "GOOD WINDOW", getValue: () -> ClientPrefs.data.goodWindow,  setValue: (v) -> ClientPrefs.data.goodWindow  = v, isFloat: true},
			{label: "BAD WINDOW",  getValue: () -> ClientPrefs.data.badWindow,   setValue: (v) -> ClientPrefs.data.badWindow   = v, isFloat: true},
			{label: "SAFE FRAMES", getValue: () -> ClientPrefs.data.safeFrames,  setValue: (v) -> ClientPrefs.data.safeFrames  = v, isFloat: true},
		];

		var i = 0;
		while (i < allOptions.length) { pageOptions.push(allOptions.slice(i, i + PAGE_SIZE)); i += PAGE_SIZE; }

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

		titlebarTxt = new FlxText(0, 0, Std.int(titlebar.width), "GAMEPLAY", 28);
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

		arrowLeft = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/arrow.png'));
		arrowLeft.scale.set(ARR_SCALE, ARR_SCALE); arrowLeft.updateHitbox();
		arrowLeft.x = ARR_L_X; arrowLeft.scrollFactor.set(0, 0); arrowLeft.visible = false;

		arrowRight = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/arrow.png'));
		arrowRight.scale.set(ARR_SCALE, ARR_SCALE); arrowRight.updateHitbox();
		arrowRight.x = ARR_R_X; arrowRight.flipX = true; arrowRight.scrollFactor.set(0, 0); arrowRight.visible = false;

		loadPage();
		add(arrowLeft);
		add(arrowRight);
		playIntro(rectX);
	}

	function playIntro(rectX:Int)
	{
		var dur:Float = 0.45;
		var ease = FlxEase.quartOut;

		FlxTween.tween(titlebar,    {x: TB_X},  dur, {ease: ease});
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
			var g = optionGroups.length > 0 ? optionGroups[curSelected] : null;
			return g != null ? g.nameBG.x - 3 : NB_X - 3;
		}
		if (spr == selectionCloneV || spr == selectionCloneWhiteV)
		{
			var g = optionGroups.length > 0 ? optionGroups[curSelected] : null;
			return g != null ? g.valueBG.x - 3 : VB_X - 3;
		}
		for (g in optionGroups)
		{
			if (spr == g.nameBG || spr == g.nameText) return NB_X + (spr == g.nameText ? 120 : 0);
			if (spr == g.valueBG) return VB_X;
			if (spr == g.valueText) return VB_X + (g.valueBG.width - g.valueText.width) / 2;
		}
		return -20;
	}

	function loadPage()
	{
		for (g in optionGroups)
		{
			rightGroup.remove(g.nameBG);   remove(g.nameBG);   g.nameBG.destroy();
			rightGroup.remove(g.valueBG);  remove(g.valueBG);  g.valueBG.destroy();
			rightGroup.remove(g.nameText); remove(g.nameText); g.nameText.destroy();
			rightGroup.remove(g.valueText);remove(g.valueText);g.valueText.destroy();
		}
		optionGroups = [];

		var page = pageOptions[curPage];
		titlebarTxt.text = 'GAMEPLAY';

		var offRight:Float = FlxG.width + 200;

		for (i in 0...page.length)
		{
			var opt = page[i];
			var rowY = NB_Y + i * ROW_GAP;

			var nameBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			nameBG.scale.set(NB_SCALE_X, NB_SCALE_Y); nameBG.updateHitbox();
			nameBG.x = introAnimating ? offRight : NB_X; nameBG.y = rowY; nameBG.scrollFactor.set(0, 0);
			add(nameBG);
			rightGroup.push(nameBG);

			var valueBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			valueBG.scale.set(VB_SCALE_X, VB_SCALE_Y); valueBG.updateHitbox();
			valueBG.x = introAnimating ? offRight : VB_X; valueBG.y = rowY; valueBG.scrollFactor.set(0, 0);
			add(valueBG);
			rightGroup.push(valueBG);

			var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), opt.label, FONT_SIZE);
			nameTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, LEFT);
			nameTxt.x = introAnimating ? offRight : NB_X + 120;
			nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2;
			nameTxt.scrollFactor.set(0, 0);
			add(nameTxt);
			rightGroup.push(cast nameTxt);

			var val = opt.getValue();
			var label = opt.label;
			var valStr = "";
			if (Std.isOfType(val, Bool))
				valStr = cast(val, Bool) ? "ON" : "OFF";
			else if (Std.isOfType(val, Float))
			{
				var suffix = (label.indexOf("WINDOW") != -1 || label == "SAFE FRAMES") ? "MS" : "";
				valStr = Std.string(Math.round(cast(val, Float) * 10) / 10) + suffix;
			}
			else
				valStr = Std.string(val);
			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), valStr.toUpperCase(), FONT_SIZE);
			valueTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, CENTER);
			valueTxt.x = introAnimating ? offRight : VB_X + (valueBG.width - valueTxt.width) / 2;
			valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2;
			valueTxt.scrollFactor.set(0, 0);
			add(valueTxt);
			rightGroup.push(cast valueTxt);

			optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});
		}

		if (!introAnimating) changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (introAnimating) return;

		if (backLock) { backLock = false; return; }

		if (editingValue)
		{
			var isLeft  = controls.UI_LEFT_P  || (controls.UI_LEFT  && holdTimer > 0.4 && holdRepeat <= 0);
			var isRight = controls.UI_RIGHT_P || (controls.UI_RIGHT && holdTimer > 0.4 && holdRepeat <= 0);

			if (controls.UI_LEFT || controls.UI_RIGHT)
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (holdRepeat > 0) holdRepeat -= elapsed;

			if (isLeft || isRight)
			{
				if (controls.UI_LEFT_P || controls.UI_RIGHT_P) holdRepeat = 0;
				else holdRepeat = 0.07;

				var opt = pageOptions[curPage][curSelected];
				var val = opt.getValue();
				var txt = optionGroups[curSelected].valueText;
				var label = opt.label;
				if (Std.isOfType(val, Bool))
				{
					var b = !cast(val, Bool);
					opt.setValue(b);
					txt.text = b ? "ON" : "OFF";
				}
				else if (opt.isFloat == true)
				{
					var n = cast(val, Float);
					var step = 0.1; var mn = 0.0; var mx = 1.0;
					if (label == "SICK WINDOW")      { step = 0.5; mn = 15.0; mx = 45.0; }
					else if (label == "GOOD WINDOW") { step = 1.0; mn = 15.0; mx = 90.0; }
					else if (label == "BAD WINDOW")  { step = 1.5; mn = 15.0; mx = 135.0; }
					else if (label == "SAFE FRAMES") { step = 0.1; mn = 2.0;  mx = 10.0; }
					n = Math.round((n + (isRight ? step : -step)) * 10) / 10;
					n = Math.max(mn, Math.min(mx, n));
					opt.setValue(n);
					var suffix = (label.indexOf("WINDOW") != -1 || label == "SAFE FRAMES") ? "MS" : "";
					txt.text = Std.string(n) + suffix;
				}
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				editingValue = false;
				holdTimer = 0; holdRepeat = 0;
				backLock = true;
				hideArrows();
				nudgeSelectedText(false);
			}
			return;
		}

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = FlxMath.wrap(curSelected + (controls.UI_UP_P ? -1 : 1), 0, optionGroups.length - 1);
			hideArrows();
			changeSelection();
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			var isRight = controls.UI_RIGHT_P;
			if (isRight && curPage < pageOptions.length - 1)
			{
				curPage++; curSelected = 0; loadPage();
			}
			else if (!isRight && curPage > 0)
			{
				curPage--; curSelected = 0; loadPage();
			}
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			editingValue = true;
			nudgeSelectedText(true);
			var g = optionGroups[curSelected];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}

		if (controls.BACK) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}

	function changeSelection()
	{
		if (optionGroups.length == 0) return;
		var group = optionGroups[curSelected];
		var nbg = group.nameBG;
		var vbg = group.valueBG;

		selectionClone.setPosition(nbg.x - 3, nbg.y - 3);
		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(selectionClone, {x: nbg.x + 13, y: nbg.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y),
			onComplete: (_) -> selectionCloneTween = null
		});
		if (cloneColorTween != null) cloneColorTween.cancel();
		selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y);
		selectionCloneWhite.alpha = 0;
		cloneColorTween = FlxTween.tween(selectionCloneWhite, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

		selectionCloneV.setPosition(vbg.x - 3, vbg.y - 3);
		if (selectionCloneTweenV != null) selectionCloneTweenV.cancel();
		selectionCloneTweenV = FlxTween.tween(selectionCloneV, {x: vbg.x + 13, y: vbg.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhiteV.setPosition(selectionCloneV.x, selectionCloneV.y),
			onComplete: (_) -> selectionCloneTweenV = null
		});
		if (cloneColorTweenV != null) cloneColorTweenV.cancel();
		selectionCloneWhiteV.setPosition(selectionCloneV.x, selectionCloneV.y);
		selectionCloneWhiteV.alpha = 0;
		cloneColorTweenV = FlxTween.tween(selectionCloneWhiteV, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

	}

	function showArrows(rowY:Float)
	{
		if (arrowTweenL != null) arrowTweenL.cancel();
		if (arrowTweenR != null) arrowTweenR.cancel();

		arrowLeft.y  = rowY; arrowLeft.x  = ARR_L_X + 12; arrowLeft.visible  = true;
		arrowRight.y = rowY; arrowRight.x = ARR_R_X - 12; arrowRight.visible = true;
		arrowLeft.alpha  = 0;
		arrowRight.alpha = 0;

		FlxTween.tween(arrowLeft,  {x: ARR_L_X, alpha: 1}, 0.18, {ease: FlxEase.backOut, onComplete: (_) -> {
			arrowTweenL = FlxTween.tween(arrowLeft,  {x: ARR_L_X - 6}, 0.4, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		}});
		FlxTween.tween(arrowRight, {x: ARR_R_X, alpha: 1}, 0.18, {ease: FlxEase.backOut, onComplete: (_) -> {
			arrowTweenR = FlxTween.tween(arrowRight, {x: ARR_R_X + 6}, 0.4, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		}});
	}

	function hideArrows()
	{
		if (arrowTweenL != null) { arrowTweenL.cancel(); arrowTweenL = null; }
		if (arrowTweenR != null) { arrowTweenR.cancel(); arrowTweenR = null; }
		arrowLeft.visible  = false;
		arrowRight.visible = false;
	}

	function nudgeSelectedText(up:Bool)
	{
		if (optionGroups.length == 0) return;
		var g = optionGroups[curSelected];
		var baseY = g.nameBG.y + (g.nameBG.height - g.nameText.height) / 2;
		var targetY = up ? baseY - 5 : baseY;
		FlxTween.tween(g.nameText,  {y: targetY}, 0.15, {ease: FlxEase.quadOut});
		FlxTween.tween(g.valueText, {y: targetY}, 0.15, {ease: FlxEase.quadOut});
	}

	override function destroy()
	{
		titlebar = null; optionGroups = null;
		leftGroup = null; rightGroup = null;
		super.destroy();
	}
}
