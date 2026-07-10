package options;

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

import openfl.display.BitmapData;

typedef ExeMenuOptionGroup = {
	var nameBG:FlxSprite;
	var valueBG:FlxSprite;
	var nameText:FlxText;
	var valueText:FlxText;
}

typedef ExeGenericOption = {
	var label:String;
	var getValue:Void->Dynamic;
	var setValue:Dynamic->Void;
	@:optional var isInt:Bool;
	@:optional var isFloat:Bool;
}

class ExeBaseOptionsState extends MusicBeatSubstate
{
	public static final TB_X:Float       = -134;
	public static final TB_Y:Float       = 143;
	public static final TB_SCALE_X:Float = 0.85;
	public static final TB_SCALE_Y:Float = 0.475;

	public static final NB_X:Float       = 105;
	public static final NB_Y:Float       = 270;
	public static final NB_SCALE_X:Float = 0.575;
	public static final NB_SCALE_Y:Float = 0.275;

	public static final VB_X:Float       = 683;
	public static final VB_Y:Float       = 270;
	public static final VB_SCALE_X:Float = 0.508;
	public static final VB_SCALE_Y:Float = 0.275;

	public static final ROW_GAP:Float    = 80;
	public static final FONT:String      = "SonicCD.ttf";

	public static function getLangFont():String
	{
		final f = backend.Language.getFontForLanguage();
		return Assets.exists('assets/fonts/$f') ? f : FONT;
	}
	public static final FONT_SIZE:Int    = 18;
	public static final OPTIONS_PAGE_SIZE:Int    = 4;

	public static final ARR_L_X:Float   = 773;
	public static final ARR_R_X:Float   = 1075;
	public static final ARR_SCALE:Float = 0.125;

	public var menuTitle:String = "OPTIONS";

	public var titlebar:FlxSprite;
	public var titlebarTxt:FlxText;
	public var arrowLeft:FlxSprite;
	public var arrowRight:FlxSprite;
	
	public var optionGroups:Array<ExeMenuOptionGroup> = [];
	public var leftGroup:Array<FlxSprite>  = [];
	public var rightGroup:Array<FlxSprite> = [];

	public var editingValue:Bool = false;
	public var backLock:Bool = false;
	public var introAnimating:Bool = true;

	var arrowTweenL:FlxTween;
	var arrowTweenR:FlxTween;

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
		buildUI();
	}

	function buildUI()
	{
		final rectX:Int = -20;
		final rectY:Int = 145;
		final rectW:Int = 1450;
		final rectH:Int = 500;
		final offLeft:Float  = -(rectW + 200);
		final offRight:Float = FlxG.width + 200;

		final bg = FlxGradient.createGradientFlxSprite(rectW, rectH, [0xFF920e1e, 0xFF6b0b15], 1, 90);
		bg.x = offRight; bg.y = rectY; bg.scrollFactor.set(0, 0);
		add(bg);
		rightGroup.push(bg);

		final borderH:Int = 5;
		final borderTop = new FlxSprite().makeGraphic(rectW, borderH, 0xFF5a0912);
		borderTop.x = offRight; borderTop.y = rectY; borderTop.scrollFactor.set(0, 0);

		final borderBot = new FlxSprite().makeGraphic(rectW, borderH, 0xFF5a0912);
		borderBot.x = offRight; borderBot.y = rectY + rectH - borderH; borderBot.scrollFactor.set(0, 0);

		final gridSize:Int = 20;
		final gridTile = new BitmapData(gridSize, gridSize, true, 0x00000000);
		for (px in 0...gridSize) { gridTile.setPixel32(px, 0, 0x22000000); gridTile.setPixel32(0, px, 0x22000000); }
		final tilesX:Int = Math.ceil(rectW / gridSize) + 1;
		final gridFullBmp = new BitmapData(tilesX * gridSize, rectH, true, 0x00000000);
		for (tx in 0...tilesX)
			for (ty in 0...Math.ceil(rectH / gridSize))
				gridFullBmp.copyPixels(gridTile, gridTile.rect, new openfl.geom.Point(tx * gridSize, ty * gridSize));
		
		final grid = new FlxBackdrop(gridFullBmp, X);
		grid.x = offRight; grid.y = rectY; grid.velocity.x = -40; grid.scrollFactor.set(0, 0);
		grid.clipRect = new flixel.math.FlxRect(0, 0, rectW, rectH);
		add(grid);
		rightGroup.push(grid);

		add(borderTop);
		add(borderBot);
		rightGroup.push(borderTop);
		rightGroup.push(borderBot);

		titlebar = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/propertyBG.png'));
		titlebar.scale.set(TB_SCALE_X, TB_SCALE_Y); titlebar.updateHitbox();
		titlebar.x = offLeft; titlebar.y = TB_Y; titlebar.scrollFactor.set(0, 0);
		add(titlebar);
		leftGroup.push(titlebar);

		final titleSize = backend.Language.scaledFontSize(36);
		titlebarTxt = new FlxText(0, 0, Std.int(titlebar.width), menuTitle, titleSize);
		titlebarTxt.setFormat(Paths.font(getLangFont()), titleSize, FlxColor.WHITE, CENTER);
		titlebarTxt.x = offLeft;
		titlebarTxt.y = TB_Y + (titlebar.height - titlebarTxt.height) / 2 - 15;
		titlebarTxt.scrollFactor.set(0, 0);
		add(titlebarTxt);
		leftGroup.push(cast titlebarTxt);

		selectionClone = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/sectionBGClone.png'));
		selectionClone.scale.set(NB_SCALE_X, NB_SCALE_Y); selectionClone.updateHitbox();
		selectionClone.x = offRight; selectionClone.scrollFactor.set(0, 0); add(selectionClone);
		rightGroup.push(selectionClone);

		selectionCloneWhite = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		selectionCloneWhite.scale.set(NB_SCALE_X, NB_SCALE_Y); selectionCloneWhite.updateHitbox();
		selectionCloneWhite.alpha = 0; selectionCloneWhite.x = offRight; selectionCloneWhite.scrollFactor.set(0, 0); add(selectionCloneWhite);
		rightGroup.push(selectionCloneWhite);

		selectionCloneV = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/sectionBGClone.png'));
		selectionCloneV.scale.set(VB_SCALE_X, VB_SCALE_Y); selectionCloneV.updateHitbox();
		selectionCloneV.x = offRight; selectionCloneV.scrollFactor.set(0, 0); add(selectionCloneV);
		rightGroup.push(selectionCloneV);

		selectionCloneWhiteV = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		selectionCloneWhiteV.scale.set(VB_SCALE_X, VB_SCALE_Y); selectionCloneWhiteV.updateHitbox();
		selectionCloneWhiteV.alpha = 0; selectionCloneWhiteV.x = offRight; selectionCloneWhiteV.scrollFactor.set(0, 0); add(selectionCloneWhiteV);
		rightGroup.push(selectionCloneWhiteV);

		arrowLeft = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/arrow.png'));
		arrowLeft.scale.set(ARR_SCALE, ARR_SCALE); arrowLeft.updateHitbox();
		arrowLeft.x = ARR_L_X; arrowLeft.scrollFactor.set(0, 0); arrowLeft.visible = false;

		arrowRight = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/arrow.png'));
		arrowRight.scale.set(ARR_SCALE, ARR_SCALE); arrowRight.updateHitbox();
		arrowRight.x = ARR_R_X; arrowRight.flipX = true; arrowRight.scrollFactor.set(0, 0); arrowRight.visible = false;

		loadPage();
		playIntro(rectX);
	}

	public dynamic function loadPage() {}
	public dynamic function getCurrentSelectionIndex():Int { return 0; }

	public function clearPage()
	{
		for (g in optionGroups)
		{
			rightGroup.remove(g.nameBG);   remove(g.nameBG);   g.nameBG.destroy();
			rightGroup.remove(g.valueBG);  remove(g.valueBG);  g.valueBG.destroy();
			rightGroup.remove(g.nameText); remove(g.nameText); g.nameText.destroy();
			rightGroup.remove(g.valueText);remove(g.valueText);g.valueText.destroy();
		}
		optionGroups = [];
	}

	function playIntro(rectX:Int)
	{
		final dur:Float = 0.45;
		final ease = FlxEase.quartOut;

		FlxTween.tween(titlebar,    {x: TB_X},  dur, {ease: ease});
		FlxTween.tween(titlebarTxt, {x: TB_X + (titlebar.width - titlebarTxt.width) / 2}, dur, {ease: ease});
		
		for (spr in rightGroup)
			FlxTween.tween(spr, {x: getTargetX(spr)}, dur, {ease: ease});

		new FlxTimer().start(dur + 0.05, (_) -> {
			introAnimating = false;
			changeSelection();
		});
	}

	public function playOutro()
	{
		introAnimating = true;

		final dur:Float = 0.35;
		final ease = FlxEase.quartIn;
		final offLeft:Float  = -(FlxG.width + 200);
		final offRight:Float = FlxG.width + 200;

		for (spr in leftGroup)
			FlxTween.tween(spr, {x: offLeft}, dur, {ease: ease});

		for (spr in rightGroup)
			FlxTween.tween(spr, {x: offRight}, dur, {ease: ease});

		new FlxTimer().start(dur + 0.05, (_) -> close());
	}

	function getTargetX(spr:FlxSprite):Float
	{
		final idx = getCurrentSelectionIndex();
		if (spr == selectionClone || spr == selectionCloneWhite)
		{
			final g = (optionGroups.length > idx) ? optionGroups[idx] : (optionGroups.length > 0 ? optionGroups[0] : null);
			return g.nameBG?.x - 3 ?? NB_X - 3;
		}
		if (spr == selectionCloneV || spr == selectionCloneWhiteV)
		{
			final g = (optionGroups.length > idx) ? optionGroups[idx] : (optionGroups.length > 0 ? optionGroups[0] : null);
			return g?.valueBG.x - 3 ?? VB_X - 3;
		}
		for (g in optionGroups)
		{
			if (spr == g.nameBG || spr == g.nameText) return NB_X + (spr == g.nameText ? 120 : 0);
			if (spr == g.valueBG) return VB_X;
			if (spr == g.valueText) return VB_X + (g.valueBG.width - g.valueText.width) / 2;
		}
		return -20;
	}

	public function changeSelection()
	{
		final idx = getCurrentSelectionIndex();
		if (optionGroups.length == 0 || idx >= optionGroups.length) return;

		final group = optionGroups[idx];
		selectionClone.setPosition(group.nameBG.x - 3, group.nameBG.y - 3);

		selectionCloneTween?.cancel();
		selectionCloneTween = FlxTween.tween(selectionClone, {x: group.nameBG.x + 13, y: group.nameBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y),
			onComplete: (_) -> selectionCloneTween = null
		});
		
		cloneColorTween?.cancel();
		selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y);
		selectionCloneWhite.alpha = 0;
		cloneColorTween = FlxTween.tween(selectionCloneWhite, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

		selectionCloneV.setPosition(group.valueBG.x - 3, group.valueBG.y - 3);

		selectionCloneTweenV?.cancel();
		selectionCloneTweenV = FlxTween.tween(selectionCloneV, {x: group.valueBG.x + 13, y: group.valueBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhiteV.setPosition(selectionCloneV.x, selectionCloneV.y),
			onComplete: (_) -> selectionCloneTweenV = null
		});
		
		cloneColorTweenV?.cancel();
		selectionCloneWhiteV.setPosition(selectionCloneV.x, selectionCloneV.y);
		selectionCloneWhiteV.alpha = 0;
		cloneColorTweenV = FlxTween.tween(selectionCloneWhiteV, {alpha: 1.0}, 0.2, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
	}

	public function showArrows(rowY:Float)
	{
		arrowTweenL?.cancel();
		arrowTweenR?.cancel();

		add(arrowLeft);
		add(arrowRight);

		arrowLeft.y  = rowY; arrowLeft.x  = ARR_L_X + 12; arrowLeft.visible  = true; arrowLeft.alpha  = 0;
		arrowRight.y = rowY; arrowRight.x = ARR_R_X - 12; arrowRight.visible = true; arrowRight.alpha = 0;
		
		FlxTween.tween(arrowLeft,  {x: ARR_L_X, alpha: 1}, 0.18, {ease: FlxEase.backOut, onComplete: (_) -> {
			arrowTweenL = FlxTween.tween(arrowLeft,  {x: ARR_L_X - 6}, 0.4, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		}});
		FlxTween.tween(arrowRight, {x: ARR_R_X, alpha: 1}, 0.18, {ease: FlxEase.backOut, onComplete: (_) -> {
			arrowTweenR = FlxTween.tween(arrowRight, {x: ARR_R_X + 6}, 0.4, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		}});
	}

	public function hideArrows()
	{
		if (arrowTweenL != null) { arrowTweenL.cancel(); arrowTweenL = null; }
		if (arrowTweenR != null) { arrowTweenR.cancel(); arrowTweenR = null; }
		arrowLeft.visible  = false;
		arrowRight.visible = false;
	}

	public function nudgeSelectedText(up:Bool)
	{
		final idx = getCurrentSelectionIndex();
		if (optionGroups.length == 0 || idx >= optionGroups.length) return;

		final g = optionGroups[idx];
		final baseY = g.nameBG.y + (g.nameBG.height - g.nameText.height) / 2;
		final targetY = up ? baseY - 5 : baseY;
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