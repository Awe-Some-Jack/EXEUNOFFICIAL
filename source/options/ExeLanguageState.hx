package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import backend.Paths;
import backend.ClientPrefs;

class ExeLanguageState extends ExeBaseOptionsState
{
	static final LANG_KEYS:Array<String>   = ["en-US", "es-ES", "pt-BR", "uz-UZ", "ja-JP", "zh-CN", "ru-RU", "uk-UA"];
	static final LANG_LABELS:Array<String> = ["ENGLISH", "SPANISH", "PORTUGUESE", "UZBEK", "JAPANESE", "CHINESE", "RUSSIAN", "UKRAINIAN"];

	var curLangIdx:Int = 0;

	// Debug vars
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
		menuTitle = "LANGUAGE";
		var saved = LANG_KEYS.indexOf(ClientPrefs.data.language);
		curLangIdx = saved >= 0 ? saved : 0;

		super.create(); // This builds the base UI and calls loadPage()

		// Overlay features placed *after* super.create so they render above UI
		debugOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xAA000000);
		debugOverlay.scrollFactor.set(0, 0); debugOverlay.visible = false; add(debugOverlay);

		debugInfoText = new FlxText(10, 10, 0, "", 16);
		debugInfoText.setFormat(Paths.font(ExeBaseOptionsState.FONT), 16, FlxColor.WHITE, LEFT);
		debugInfoText.scrollFactor.set(0, 0); debugInfoText.visible = false; add(debugInfoText);

		debugHintText = new FlxText(10, FlxG.height - 80, 0, "[F1] toggle  [Z] spawn  [Tab] select  [WASD] move X/Y  [Q/E] scale all  [Arrows] scale X/Y  [T] trace  [Del] delete", 13);
		debugHintText.setFormat(Paths.font(ExeBaseOptionsState.FONT), 13, 0xFFAAAAAA, LEFT);
		debugHintText.scrollFactor.set(0, 0); debugHintText.visible = false; add(debugHintText);
	}

	override public function getCurrentSelectionIndex():Int { return 0; }

	override public function loadPage()
	{
		clearPage();
		var offRight:Float = FlxG.width + 200;
		var rowY = ExeBaseOptionsState.NB_Y;

		var nameBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		nameBG.scale.set(ExeBaseOptionsState.NB_SCALE_X, ExeBaseOptionsState.NB_SCALE_Y); nameBG.updateHitbox();
		nameBG.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X; nameBG.y = rowY; nameBG.scrollFactor.set(0, 0);
		add(nameBG); rightGroup.push(nameBG);

		var valueBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		valueBG.scale.set(ExeBaseOptionsState.VB_SCALE_X, ExeBaseOptionsState.VB_SCALE_Y); valueBG.updateHitbox();
		valueBG.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X; valueBG.y = rowY; valueBG.scrollFactor.set(0, 0);
		add(valueBG); rightGroup.push(valueBG);

		var nameTxt = new FlxText(0, 0, Std.int(nameBG.width), menuTitle, ExeBaseOptionsState.FONT_SIZE);
		nameTxt.setFormat(Paths.font(ExeBaseOptionsState.FONT), ExeBaseOptionsState.FONT_SIZE, FlxColor.WHITE, LEFT);
		nameTxt.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X + 120;
		nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2; nameTxt.scrollFactor.set(0, 0);
		add(nameTxt); rightGroup.push(cast nameTxt);

		var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), LANG_LABELS[curLangIdx], ExeBaseOptionsState.FONT_SIZE);
		valueTxt.setFormat(Paths.font(ExeBaseOptionsState.FONT), ExeBaseOptionsState.FONT_SIZE, FlxColor.WHITE, CENTER);
		valueTxt.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X + (valueBG.width - valueTxt.width) / 2;
		valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2; valueTxt.scrollFactor.set(0, 0);
		add(valueTxt); rightGroup.push(cast valueTxt);

		optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});

		if (!introAnimating) changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.F1)
		{
			debugMode = !debugMode;
			debugOverlay.visible = debugMode; debugInfoText.visible = debugMode; debugHintText.visible = debugMode;
			if (debugMode && debugSprites.length == 0) spawnDebugSprite();
		}
		if (debugMode) { updateDebugMode(elapsed); return; }
		if (introAnimating || backLock) { backLock = false; return; }

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
				g.valueText.x = ExeBaseOptionsState.VB_X + (g.valueBG.width - g.valueText.width) / 2;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				editingValue = false; backLock = true; 
				nudgeSelectedText(false); hideArrows();
			}
			return;
		}
		if (controls.ACCEPT) { 
			FlxG.sound.play(Paths.sound('scrollMenu')); 
			editingValue = true; nudgeSelectedText(true);
			var g = optionGroups[0];
			showArrows(g.valueBG.y + (g.valueBG.height - arrowLeft.height) / 2);
		}
		if (controls.BACK) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}

	function updateDebugMode(elapsed:Float)
	{
		if (debugSprites.length == 0) return;
		var spr = debugSprites[debugSelected];
		if (FlxG.keys.justPressed.TAB)
		{
			spr.color = FlxColor.WHITE;
			debugSelected = FlxG.keys.pressed.SHIFT ? FlxMath.wrap(debugSelected - 1, 0, debugSprites.length - 1) : FlxMath.wrap(debugSelected + 1, 0, debugSprites.length - 1);
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
		spr.scale.set(ExeBaseOptionsState.TB_SCALE_X, ExeBaseOptionsState.TB_SCALE_Y); spr.updateHitbox();
		spr.screenCenter(); spr.scrollFactor.set(0, 0);
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
}