package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import backend.Paths;
import backend.ClientPrefs;
import backend.Language;

class ExeLanguageState extends ExeBaseOptionsState
{
	static final LANG_KEYS:Array<String> = ["auto", "en-US", "es-419", "pt-BR", "fr-FR", "uz-UZ", "ja-JP", "zh-CN", "ko-KR", "ru-RU", "uk-UA", "de-DE", "pi-PI"];
	var curLangIdx:Int = 0;

	override public function create()
	{
		menuTitle = Language.get("options.language", "LANGUAGE");

		final saved = LANG_KEYS.indexOf(ClientPrefs.data.language);
		curLangIdx = saved >= 0 ? saved : 0;
		
		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return 0; }

	function getLangLabel():String
	{
		return LANG_KEYS[curLangIdx] == "auto" ? Language.get("language_auto", "System Default") : Language.get("language", LANG_KEYS[curLangIdx]);
	}

	override public function loadPage()
	{
		clearPage();

		final offRight:Float = FlxG.width + 200;
		final rowY = ExeBaseOptionsState.NB_Y;
		
		final fontPath = Paths.font(Language.getFontForLanguage());
		final fontSize = Language.scaledFontSize(ExeBaseOptionsState.FONT_SIZE);
		
		final nameBG = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/propertyBG.png'));
		nameBG.scale.set(ExeBaseOptionsState.NB_SCALE_X, ExeBaseOptionsState.NB_SCALE_Y); nameBG.updateHitbox();
		nameBG.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X; nameBG.y = rowY; nameBG.scrollFactor.set(0, 0);
		add(nameBG); rightGroup.push(nameBG);

		final valueBG = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/options/propertyBG.png'));
		valueBG.scale.set(ExeBaseOptionsState.VB_SCALE_X, ExeBaseOptionsState.VB_SCALE_Y); valueBG.updateHitbox();
		valueBG.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X; valueBG.y = rowY;
		valueBG.scrollFactor.set(0, 0);
		add(valueBG); rightGroup.push(valueBG);

		final nameTxt = new FlxText(0, 0, Std.int(nameBG.width), menuTitle, fontSize);
		nameTxt.setFormat(fontPath, fontSize, FlxColor.WHITE, LEFT);
		nameTxt.x = introAnimating ? offRight : ExeBaseOptionsState.NB_X + 120;
		nameTxt.y = rowY + (nameBG.height - nameTxt.height) / 2; nameTxt.scrollFactor.set(0, 0);
		add(nameTxt); rightGroup.push(cast nameTxt);

		final valueTxt = new FlxText(0, 0, Std.int(valueBG.width), getLangLabel(), fontSize);
		valueTxt.setFormat(fontPath, fontSize, FlxColor.WHITE, CENTER);
		valueTxt.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X + (valueBG.width - valueTxt.width) / 2;
		valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2; valueTxt.scrollFactor.set(0, 0);
		add(valueTxt); rightGroup.push(cast valueTxt);

		optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});

		if (!introAnimating) changeSelection();
	}

	function applyLanguage():Void
	{
		final key = LANG_KEYS[curLangIdx];
		ClientPrefs.data.language = key;
		ClientPrefs.saveSettings();
		
		Language.reload();

		final g = optionGroups[0];
		final newFontPath = Paths.font(Language.getFontForLanguage());
		
		g.valueText.font = newFontPath;
		g.valueText.text = getLangLabel();
		g.valueText.x = ExeBaseOptionsState.VB_X + (g.valueBG.width - g.valueText.width) / 2;

		menuTitle = Language.get("options.language", "LANGUAGE");
		g.nameText.font = newFontPath;
		g.nameText.text = menuTitle;

		titlebarTxt.font = newFontPath;
		titlebarTxt.text = menuTitle;
		titlebarTxt.x = ExeBaseOptionsState.TB_X + (titlebar.width - titlebarTxt.width) / 2;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (introAnimating || backLock) { backLock = false; return; }

		if (editingValue)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				curLangIdx = FlxMath.wrap(curLangIdx + (controls.UI_RIGHT_P ? 1 : -1), 0, LANG_KEYS.length - 1);
				applyLanguage();
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
}