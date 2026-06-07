package options;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.util.FlxGradient;
import openfl.Assets;
import openfl.display.BitmapData;

import backend.InputFormatter;

typedef ExeControlOption = {
	var label:String;
	var saveKey:String;
	var defaultKeys:Array<FlxKey>;
	var defaultGamepad:Array<FlxGamepadInputID>;
}

typedef OptionGroup = {
	var nameBG:FlxSprite;
	var valueBG:FlxSprite;
	var nameText:FlxText;
	var valueText:FlxText;
}

class ExeControlsState extends MusicBeatSubstate
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

	var titlebar:FlxSprite;
	var titlebarTxt:FlxText;
	var optionGroups:Array<OptionGroup> = [];

	var noteOptions:Array<ExeControlOption> = [
		{label: "LEFT",  saveKey: "note_left",  defaultKeys: [A, LEFT],  defaultGamepad: [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT]},
		{label: "DOWN",  saveKey: "note_down",  defaultKeys: [S, DOWN],  defaultGamepad: [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN]},
		{label: "UP",    saveKey: "note_up",    defaultKeys: [W, UP],    defaultGamepad: [DPAD_UP,    LEFT_STICK_DIGITAL_UP]},
		{label: "RIGHT", saveKey: "note_right", defaultKeys: [D, RIGHT], defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]},
	];

	var uiOptions:Array<ExeControlOption> = [
		{label: "UP",    saveKey: "ui_up",    defaultKeys: [W, UP],    defaultGamepad: [DPAD_UP,    LEFT_STICK_DIGITAL_UP]},
		{label: "DOWN",  saveKey: "ui_down",  defaultKeys: [S, DOWN],  defaultGamepad: [DPAD_DOWN,  LEFT_STICK_DIGITAL_DOWN]},
		{label: "LEFT",  saveKey: "ui_left",  defaultKeys: [A, LEFT],  defaultGamepad: [DPAD_LEFT,  LEFT_STICK_DIGITAL_LEFT]},
		{label: "RIGHT", saveKey: "ui_right", defaultKeys: [D, RIGHT], defaultGamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]},
	];

	var actionOptions:Array<ExeControlOption> = [
		{label: "ACCEPT", saveKey: "accept", defaultKeys: [SPACE, ENTER], defaultGamepad: [A, START]},
		{label: "BACK",   saveKey: "back",   defaultKeys: [ESCAPE],       defaultGamepad: [B]},
		{label: "PAUSE",  saveKey: "pause",  defaultKeys: [ENTER],        defaultGamepad: [START]},
		{label: "RESET",  saveKey: "reset",  defaultKeys: [R],            defaultGamepad: [BACK]},
	];

	var sections:Array<String> = ["NOTES", "UI", "ACTIONS"];
	public static var curSectionIdx:Int = 0;
	public static var curSelected:Int = 0;
	var onKeyboardMode:Bool = true;
	var editingValue:Bool = false;
	var backLock:Bool = false;

	var selectionClone:FlxSprite;
	var selectionCloneWhite:FlxSprite;
	var selectionCloneV:FlxSprite;
	var selectionCloneWhiteV:FlxSprite;
	var selectionTween:FlxTween;
	var selectionCloneTween:FlxTween;
	var cloneColorTween:FlxTween;
	var selectionCloneTweenV:FlxTween;
	var cloneColorTweenV:FlxTween;

	var introAnimating:Bool = true;
	var leftGroup:Array<FlxSprite>  = [];
	var rightGroup:Array<FlxSprite> = [];


	override public function create()
	{
		super.create();
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

		var debugRect = FlxGradient.createGradientFlxSprite(rectW, rectH, [0xFF920e1e, 0xFF6b0b15], 1, 90);
		debugRect.x = offRight;
		debugRect.y = rectY;
		debugRect.scrollFactor.set(0, 0);
		add(debugRect);
		rightGroup.push(debugRect);

		var borderH:Int = 5;
		var borderTop = new FlxSprite().makeGraphic(rectW, borderH, 0xFF5a0912);
		borderTop.x = offRight;
		borderTop.y = rectY;
		borderTop.scrollFactor.set(0, 0);

		var borderBot = new FlxSprite().makeGraphic(rectW, borderH, 0xFF5a0912);
		borderBot.x = offRight;
		borderBot.y = rectY + rectH - borderH;
		borderBot.scrollFactor.set(0, 0);

		var gridSize:Int = 20;
		var gridTile = new BitmapData(gridSize, gridSize, true, 0x00000000);
		for (px in 0...gridSize)
		{
			gridTile.setPixel32(px, 0, 0x22000000);
			gridTile.setPixel32(0, px, 0x22000000);
		}
		var tilesX:Int = Math.ceil(rectW / gridSize) + 1;
		var gridFullBmp = new BitmapData(tilesX * gridSize, rectH, true, 0x00000000);
		for (tx in 0...tilesX)
			for (ty in 0...Math.ceil(rectH / gridSize))
				gridFullBmp.copyPixels(gridTile, gridTile.rect, new openfl.geom.Point(tx * gridSize, ty * gridSize));
		var grid = new FlxBackdrop(gridFullBmp, X);
		grid.x = offRight;
		grid.y = rectY;
		grid.velocity.x = -40;
		grid.scrollFactor.set(0, 0);
		grid.clipRect = new flixel.math.FlxRect(0, 0, rectW, rectH);
		add(grid);
		rightGroup.push(grid);

		add(borderTop);
		add(borderBot);
		rightGroup.push(borderTop);
		rightGroup.push(borderBot);

		titlebar = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		titlebar.scale.set(TB_SCALE_X, TB_SCALE_Y);
		titlebar.updateHitbox();
		titlebar.x = offLeft;
		titlebar.y = TB_Y;
		titlebar.scrollFactor.set(0, 0);
		add(titlebar);
		leftGroup.push(titlebar);

		titlebarTxt = new FlxText(0, 0, Std.int(titlebar.width), "NOTES", 28);
		titlebarTxt.setFormat(Paths.font(FONT), 28, FlxColor.WHITE, CENTER);
		titlebarTxt.x = offLeft;
		titlebarTxt.y = TB_Y + (titlebar.height - titlebarTxt.height) / 2 - 15;
		titlebarTxt.scrollFactor.set(0, 0);
		add(titlebarTxt);
		leftGroup.push(cast titlebarTxt);

		selectionClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGClone.png'));
		selectionClone.scale.set(NB_SCALE_X, NB_SCALE_Y);
		selectionClone.updateHitbox();
		selectionClone.x = offRight;
		selectionClone.scrollFactor.set(0, 0);
		add(selectionClone);
		rightGroup.push(selectionClone);

		selectionCloneWhite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		selectionCloneWhite.scale.set(NB_SCALE_X, NB_SCALE_Y);
		selectionCloneWhite.updateHitbox();
		selectionCloneWhite.alpha = 0;
		selectionCloneWhite.x = offRight;
		selectionCloneWhite.scrollFactor.set(0, 0);
		add(selectionCloneWhite);
		rightGroup.push(selectionCloneWhite);

		selectionCloneV = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGClone.png'));
		selectionCloneV.scale.set(VB_SCALE_X, VB_SCALE_Y);
		selectionCloneV.updateHitbox();
		selectionCloneV.x = offRight;
		selectionCloneV.scrollFactor.set(0, 0);
		add(selectionCloneV);
		rightGroup.push(selectionCloneV);

		selectionCloneWhiteV = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/sectionBGWhite.png'));
		selectionCloneWhiteV.scale.set(VB_SCALE_X, VB_SCALE_Y);
		selectionCloneWhiteV.updateHitbox();
		selectionCloneWhiteV.alpha = 0;
		selectionCloneWhiteV.x = offRight;
		selectionCloneWhiteV.scrollFactor.set(0, 0);
		add(selectionCloneWhiteV);
		rightGroup.push(selectionCloneWhiteV);

		for (i in 0...noteOptions.length)
		{
			var opt = noteOptions[i];
			var rowY = NB_Y + i * ROW_GAP;

			var nameBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			nameBG.scale.set(NB_SCALE_X, NB_SCALE_Y);
			nameBG.updateHitbox();
			nameBG.x = offRight;
			nameBG.y = rowY;
			nameBG.scrollFactor.set(0, 0);
			add(nameBG);
			rightGroup.push(nameBG);

			var valueBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			valueBG.scale.set(VB_SCALE_X, VB_SCALE_Y);
			valueBG.updateHitbox();
			valueBG.x = offRight;
			valueBG.y = rowY;
			valueBG.scrollFactor.set(0, 0);
			add(valueBG);
			rightGroup.push(valueBG);

			var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), opt.label, FONT_SIZE);
			nameTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, LEFT);
			nameTxt.x = offRight;
			nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2;
			nameTxt.scrollFactor.set(0, 0);
			add(nameTxt);
			rightGroup.push(cast nameTxt);

			var keys = ClientPrefs.keyBinds.get(opt.saveKey);
			var keyText = InputFormatter.getKeyName(keys != null && keys.length > 0 ? keys[0] : NONE);
			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), keyText.toUpperCase(), FONT_SIZE);
			valueTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, CENTER);
			valueTxt.x = offRight;
			valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2;
			valueTxt.scrollFactor.set(0, 0);
			add(valueTxt);
			rightGroup.push(cast valueTxt);

			optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});
		}

		playIntro(rectX);
	}

	function playIntro(rectX:Int)
	{
		var dur:Float = 0.45;
		var ease = FlxEase.quartOut;

		FlxTween.tween(titlebar,    {x: TB_X}, dur, {ease: ease});
		FlxTween.tween(titlebarTxt, {x: TB_X + (titlebar.width - titlebarTxt.width) / 2}, dur, {ease: ease});

		for (spr in rightGroup)
			FlxTween.tween(spr, {x: getIntroTargetX(spr)}, dur, {ease: ease});

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

	function getIntroTargetX(spr:FlxSprite):Float
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
			if (spr == g.nameBG) return NB_X;
			if (spr == g.nameText) return NB_X + 120;
			if (spr == g.valueBG) return VB_X;
			if (spr == g.valueText) return VB_X + (g.valueBG.width - g.valueText.width) / 2;
		}
		return -20;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (introAnimating) return;

		if (backLock) { backLock = false; return; }

		if (editingValue)
		{
			var pressed:FlxKey = FlxG.keys.firstJustPressed();
			if (pressed != NONE)
			{
				if (pressed == FlxKey.ESCAPE)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
				else
				{
					var opts = switch (curSectionIdx) { case 1: uiOptions; case 2: actionOptions; default: noteOptions; };
					var saveKey = opts[curSelected].saveKey;
					ClientPrefs.keyBinds.set(saveKey, [pressed]);
					optionGroups[curSelected].valueText.text = InputFormatter.getKeyName(pressed).toUpperCase();
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				editingValue = false;
				backLock = true;
				nudgeSelectedText(false);
			}
			return;
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSectionIdx = FlxMath.wrap(curSectionIdx + (controls.UI_RIGHT_P ? 1 : -1), 0, sections.length - 1);
			curSelected = 0;
			loadSection();
		}

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = FlxMath.wrap(curSelected + (controls.UI_UP_P ? -1 : 1), 0, optionGroups.length - 1);
			changeSelection();
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			editingValue = true;
			nudgeSelectedText(true);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			playOutro();
		}
	}

	function getKeyLabel(saveKey:String):String
	{
		var keys = ClientPrefs.keyBinds.get(saveKey);
		return InputFormatter.getKeyName(keys != null && keys.length > 0 ? keys[0] : NONE).toUpperCase();
	}

	function loadSection()
	{
		for (g in optionGroups)
		{
			rightGroup.remove(g.nameBG);   remove(g.nameBG);   g.nameBG.destroy();
			rightGroup.remove(g.valueBG);  remove(g.valueBG);  g.valueBG.destroy();
			rightGroup.remove(g.nameText); remove(g.nameText); g.nameText.destroy();
			rightGroup.remove(g.valueText);remove(g.valueText);g.valueText.destroy();
		}
		optionGroups = [];

		var opts = switch (curSectionIdx) {
			case 1: uiOptions;
			case 2: actionOptions;
			default: noteOptions;
		};

		titlebarTxt.text = sections[curSectionIdx];

		for (i in 0...opts.length)
		{
			var opt = opts[i];
			var rowY = NB_Y + i * ROW_GAP;

			var nameBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			nameBG.scale.set(NB_SCALE_X, NB_SCALE_Y);
			nameBG.updateHitbox();
			nameBG.x = NB_X;
			nameBG.y = rowY;
			nameBG.scrollFactor.set(0, 0);
			add(nameBG);
			rightGroup.push(nameBG);

			var valueBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			valueBG.scale.set(VB_SCALE_X, VB_SCALE_Y);
			valueBG.updateHitbox();
			valueBG.x = VB_X;
			valueBG.y = rowY;
			valueBG.scrollFactor.set(0, 0);
			add(valueBG);
			rightGroup.push(valueBG);

			var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), opt.label, FONT_SIZE);
			nameTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, LEFT);
			nameTxt.x = nameBG.x + 120;
			nameTxt.y = nameBG.y + (nameBG.height - nameTxt.height) / 2;
			nameTxt.scrollFactor.set(0, 0);
			add(nameTxt);
			rightGroup.push(cast nameTxt);

			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), getKeyLabel(opt.saveKey), FONT_SIZE);
			valueTxt.setFormat(Paths.font(FONT), FONT_SIZE, FlxColor.WHITE, CENTER);
			valueTxt.x = valueBG.x + (valueBG.width - valueTxt.width) / 2;
			valueTxt.y = valueBG.y + (valueBG.height - valueTxt.height) / 2;
			valueTxt.scrollFactor.set(0, 0);
			add(valueTxt);
			rightGroup.push(cast valueTxt);

			optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});
		}

		changeSelection();
	}

	function changeSelection()
	{
		if (optionGroups.length == 0) return;

		var group = optionGroups[curSelected];
		var bg = group.nameBG;
		var vbg = group.valueBG;

		selectionClone.setPosition(bg.x - 3, bg.y - 3);
		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(selectionClone, {x: bg.x + 13, y: bg.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onUpdate: (_) -> selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y),
			onComplete: (_) -> selectionCloneTween = null
		});

		if (cloneColorTween != null) cloneColorTween.cancel();
		selectionCloneWhite.setPosition(selectionClone.x, selectionClone.y);
		selectionCloneWhite.alpha = 0;
		cloneColorTween = FlxTween.tween(selectionCloneWhite, {alpha: 1.0}, 0.2, {
			ease: FlxEase.sineInOut,
			type: FlxTweenType.PINGPONG
		});

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
		cloneColorTweenV = FlxTween.tween(selectionCloneWhiteV, {alpha: 1.0}, 0.2, {
			ease: FlxEase.sineInOut,
			type: FlxTweenType.PINGPONG
		});

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
		titlebar = null;
		optionGroups = null;
		leftGroup = null;
		rightGroup = null;
		super.destroy();
	}
}
