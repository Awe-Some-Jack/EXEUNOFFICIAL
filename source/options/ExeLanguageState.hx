package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import backend.Paths;
import backend.ClientPrefs;
import haxe.Json;

class ExeLanguageState extends ExeBaseOptionsState
{
	static final LANG_KEYS:Array<String> = ["en-US", "es-ES", "pt-BR", "fr-FR", "uz-UZ", "ja-JP", "zh-CN", "ko-KR", "ru-RU", "uk-UA", "de-DE", "pi-PI"];

	static final LANG_FONTS:Map<String, String> = [
		"ja-JP" => "japanese.ttf",
		"zh-CN" => "chinese.ttf",
		"ko-KR" => "korean.ttf",
		"ru-RU" => "Pixellari.ttf",
		"uk-UA" => "Pixellari.ttf"
	];

	var curLangIdx:Int = 0;
	var langData:Dynamic = null;

	override public function create()
	{
		menuTitle = "LANGUAGE";
		var saved = LANG_KEYS.indexOf(ClientPrefs.data.language);
		curLangIdx = saved >= 0 ? saved : 0;
		loadLangData(LANG_KEYS[curLangIdx]);
		super.create();
	}

	override public function getCurrentSelectionIndex():Int { return 0; }

	function loadLangData(key:String):Void
	{
		var path = 'assets/exe/options/language/$key.json';
		try {
			var text = openfl.Assets.getText(path);
			langData = (text != null && text.length > 0) ? Json.parse(text) : null;
		} catch (e:Dynamic) { langData = null; }
	}

	function getLangLabel():String
	{
		if (langData != null && Reflect.hasField(langData, "language"))
			return Reflect.field(langData, "language");
		return LANG_KEYS[curLangIdx];
	}

	function getFontForLang(key:String):String
	{
		if (!LANG_FONTS.exists(key)) return ExeBaseOptionsState.FONT;
		var f = LANG_FONTS.get(key);
		return openfl.Assets.exists('assets/fonts/$f') ? f : ExeBaseOptionsState.FONT;
	}

	override public function loadPage()
	{
		clearPage();
		var offRight:Float = FlxG.width + 200;
		var rowY = ExeBaseOptionsState.NB_Y;
		var font = getFontForLang(LANG_KEYS[curLangIdx]);

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

		var valueTxt = new FlxText(0, 0, Std.int(valueBG.width), getLangLabel(), ExeBaseOptionsState.FONT_SIZE);
		valueTxt.setFormat(Paths.font(font), ExeBaseOptionsState.FONT_SIZE, FlxColor.WHITE, CENTER);
		valueTxt.x = introAnimating ? offRight : ExeBaseOptionsState.VB_X + (valueBG.width - valueTxt.width) / 2;
		valueTxt.y = rowY + (valueBG.height - valueTxt.height) / 2; valueTxt.scrollFactor.set(0, 0);
		add(valueTxt); rightGroup.push(cast valueTxt);

		optionGroups.push({nameBG: nameBG, valueBG: valueBG, nameText: nameTxt, valueText: valueTxt});

		if (!introAnimating) changeSelection();
	}

	function applyLanguage():Void
	{
		var key = LANG_KEYS[curLangIdx];
		ClientPrefs.data.language = key;
		ClientPrefs.saveSettings();
		loadLangData(key);
		backend.Language.reload();

		var g = optionGroups[0];
		var font = getFontForLang(key);
		g.valueText.font = Paths.font(font);
		g.valueText.text = getLangLabel();
		g.valueText.x = ExeBaseOptionsState.VB_X + (g.valueBG.width - g.valueText.width) / 2;
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
