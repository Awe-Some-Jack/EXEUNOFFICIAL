package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;


import backend.Paths;
import backend.ClientPrefs;
import backend.Language;

class ExeVisualsState extends ExeBaseOptionsState
{
	var allOptions:Array<ExeBaseOptionsState.ExeGenericOption>;
	var pageOptions:Array<Array<ExeBaseOptionsState.ExeGenericOption>> = [];

	public static var curSelected:Int = 0;
	public static var curPage:Int = 0;

	override public function create()
	{
		menuTitle = Language.get('options.visuals', 'VISUALS');
		var lbl = Language.getArray('options.visuals.labels', ["HIDE HUD", "FLASHING LIGHTS", "CAMERA ZOOMS", "SCORE TEXT ZOOM"]);
		allOptions = [
			{label: lbl[0], getValue: () -> ClientPrefs.data.hideHud,   setValue: (v) -> ClientPrefs.data.hideHud   = v},
			{label: lbl[1], getValue: () -> ClientPrefs.data.flashing,  setValue: (v) -> ClientPrefs.data.flashing  = v},
			{label: lbl[2], getValue: () -> ClientPrefs.data.camZooms,  setValue: (v) -> ClientPrefs.data.camZooms  = v},
			{label: lbl[3], getValue: () -> ClientPrefs.data.scoreZoom, setValue: (v) -> ClientPrefs.data.scoreZoom = v}
		];
		var i = 0;
		while (i < allOptions.length) { pageOptions.push(allOptions.slice(i, i + ExeBaseOptionsState.OPTIONS_PAGE_SIZE)); i += ExeBaseOptionsState.OPTIONS_PAGE_SIZE; }

		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return curSelected; }

	override public function loadPage()
	{
		clearPage();
		FlxG.sound.play(Paths.sound('scrollMenu'));
		var page = pageOptions[curPage];
		titlebarTxt.text = menuTitle;
		var offRight:Float = FlxG.width + 200;

		for (i in 0...page.length)
		{
			var opt = page[i];
			var rowY = ExeBaseOptionsState.NB_Y + i * ExeBaseOptionsState.ROW_GAP;

			var nameBG = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/propertyBG.webp'));
			nameBG.scale.set(ExeBaseOptionsState.NB_SCALE_X, ExeBaseOptionsState.NB_SCALE_Y); nameBG.updateHitbox();
			nameBG.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X; nameBG.y = rowY; nameBG.scrollFactor.set(0, 0);
			add(nameBG); rightGroup.push(nameBG);

			var valueBG = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/propertyBG.webp'));
			valueBG.scale.set(ExeBaseOptionsState.VB_SCALE_X, ExeBaseOptionsState.VB_SCALE_Y); valueBG.updateHitbox();
			valueBG.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X; valueBG.y = rowY; valueBG.scrollFactor.set(0, 0);
			add(valueBG); rightGroup.push(valueBG);

			var lblSize = Language.scaledFontSize(ExeBaseOptionsState.FONT_SIZE);
			var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), opt.label, lblSize);
			nameTxt.setFormat(Paths.font(ExeBaseOptionsState.getLangFont()), lblSize, FlxColor.WHITE, LEFT);
			nameTxt.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X + 120;
			nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2; nameTxt.scrollFactor.set(0, 0);
			add(nameTxt); rightGroup.push(cast nameTxt);

			var val = opt.getValue();
			var on = Language.get('options.on', 'ON'); var off = Language.get('options.off', 'OFF');
			var valStr = Std.isOfType(val, Bool) ? (cast(val, Bool) ? on : off) : Std.string(val);
			var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), valStr, lblSize);
			valueTxt.setFormat(Paths.font(ExeBaseOptionsState.getLangFont()), lblSize, FlxColor.WHITE, CENTER);
			valueTxt.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X + (valueBG.width - valueTxt.width) / 2;
			valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2; valueTxt.scrollFactor.set(0, 0);
			add(valueTxt); rightGroup.push(cast valueTxt);

			optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});
		}

		if (!introAnimating) changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (introAnimating || backLock) { backLock = false; return; }

		if (editingValue)
		{
			if (#if mobile ((FlxG.mouse.overlaps(arrowRight) || FlxG.mouse.overlaps(arrowLeft)) && shortPress) || swipeLEFT || swipeRIGHT || #end controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				var isRight = #if mobile (FlxG.mouse.overlaps(arrowRight) && shortPress) || swipeRIGHT || #end controls.UI_RIGHT_P;
				var opt = pageOptions[curPage][curSelected];
				var val = opt.getValue();
				var txt = optionGroups[curSelected].valueText;
				
				if (Std.isOfType(val, Bool))
				{
					var b = !cast(val, Bool); opt.setValue(b);
					txt.text = b ? Language.get('options.on', 'ON') : Language.get('options.off', 'OFF');
				}
				else if (opt.isFloat == true)
				{
					var n = Math.round((cast(val, Float) + (isRight ? 0.1 : -0.1)) * 10) / 10;
					n = isRight ? Math.min(n, 1.0) : Math.max(n, 0.0);
					opt.setValue(n); txt.text = Std.string(n);
				}
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if ((controls.ACCEPT || controls.BACK) #if mobile || backPressed #end)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				editingValue = false; backLock = true; 
				hideArrows(); nudgeSelectedText(false);
			}
			return;
		}

		#if mobile
		if(pressHolding && deltaMouseY != 0 && cooldownTimer <= 0) {
			if(deltaMouseY < -5) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected = FlxMath.wrap(curSelected - 1, 0, optionGroups.length - 1);
				hideArrows(); changeSelection();
			} else if(deltaMouseY > 5) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected = FlxMath.wrap(curSelected + 1, 0, optionGroups.length - 1);
				hideArrows(); changeSelection();
			}
		}
		#end

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = FlxMath.wrap(curSelected + (controls.UI_UP_P ? -1 : 1), 0, optionGroups.length - 1);
			hideArrows(); changeSelection();
		}
		if (#if mobile swipeLEFT || swipeRIGHT || #end controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			var isRight = #if mobile swipeRIGHT || #end controls.UI_RIGHT_P;
			if (isRight && curPage < pageOptions.length - 1) { curPage++; curSelected = 0; loadPage(); }
			else if (!isRight && curPage > 0) { curPage--; curSelected = 0; loadPage(); }
		}
		if (controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end) { 
			FlxG.sound.play(Paths.sound('scrollMenu')); 
			editingValue = true; nudgeSelectedText(true); 
			var g = optionGroups[curSelected];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}
		if (controls.BACK #if mobile || backPressed #end) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}
}