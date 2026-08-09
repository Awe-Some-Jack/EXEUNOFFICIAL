package backend;

import haxe.Json;
import lime.system.Locale;

class Language
{
	static var phrases:Map<String, Dynamic> = [];
	static var currentKey:String = 'en-US';

	public static function getSystemLanguage():String {
		var sysLang:String = Locale.systemLocale.language; 
		if (sysLang != null) sysLang = sysLang.toLowerCase();

		return switch (sysLang) {
			case 'es': 'es-419';
			case 'pt': 'pt-BR';
			case 'fr': 'fr-FR';
			case 'uz': 'uz-UZ';
			case 'ja': 'ja-JP';
			case 'zh': 'zh-CN';
			case 'ko': 'ko-KR';
			case 'ru': 'ru-RU';
			case 'uk': 'uk-UA';
			case 'de': 'de-DE';
			case 'it': 'it-IT';
			case 'pl': 'pl-PL';
			case 'tr': 'tr-TR';
			default: 'en-US';
		};
	}

	public static function reload():Void
	{
		var key:String = ClientPrefs.data.language;
		if (key == null || key.length == 0) key = 'auto';

		currentKey = (key == 'auto') ? getSystemLanguage() : key;
		
		phrases = new Map<String, Dynamic>();

		final files:Array<String> = getLanguageFiles(currentKey);
		for (file in files)
			loadLanguageFile(file);
	}

	public static function getLanguageFiles(lang:String):Array<String>
	{
		var files:Array<String> = [];

		final basePath = Paths.getPath('$lang.json', "language", false);
		if (fileExists(basePath))
			files.push(basePath);

		#if MODS_ALLOWED
		for (contents in Mods.parseList().enabled)
		{
			final modPath = Paths.mods('$contents/language/$lang.json');
			if (fileExists(modPath) && !files.contains(modPath))
				files.push(modPath);
		}

		if (Mods.currentModDirectory?.length > 0)
		{
			final currentModPath = Paths.mods('${Mods.currentModDirectory}/language/$lang.json');
			if (fileExists(currentModPath) && !files.contains(currentModPath))
				files.push(currentModPath);
		}
		#end

		return files;
	}

	private static function fileExists(path:String):Bool
	{
		#if sys
		if (FileSystem.exists(path)) return true;
		#end
		return Assets.exists(path);
	}

	private static function loadLanguageFile(file:String):Void
	{
		try {
			var text:String = null;
			text = Paths.getContent(file);

			if (text?.length > 0) {
				final data:Dynamic = Json.parse(text);
				for (field in Reflect.fields(data))
					phrases.set(field, Reflect.field(data, field));
			}
		} catch (e:Dynamic) {
			trace('Error loading language file "$file": ' + e);
		}
	}

	public static function get(key:String, ?fallback:String):String
	{
		final val = phrases.get(key);

		if (val == null) return fallback ?? key;
		if (Std.isOfType(val, String)) return cast(val, String);
		return fallback ?? key;
	}

	public static function getArray(key:String, ?fallback:Array<String>):Array<String>
	{
		final val = phrases.get(key);

		if (val == null) return fallback ?? [];
		if (Std.isOfType(val, Array)) return cast val;
		return fallback ?? [];
	}

	public static function getFontForLanguage():String
	{
		return switch (currentKey) {
			case 'ja-JP': 'japanese.ttf';
			case 'ko-KR': 'korean.ttf';
			case 'zh-CN': 'chinese.ttf';
			default: 'SonicCD.ttf';
		}
	}

	public static function isCJK():Bool
	{
		return currentKey == 'ja-JP' || currentKey == 'ko-KR' || currentKey == 'zh-CN';
	}

	public static function needsCustomFont():Bool
	{
		return getFontForLanguage() != 'SonicCD.ttf';
	}

	public static function fontOrCJK(defaultFont:String):String
	{
		return needsCustomFont() ? getFontForLanguage() : defaultFont;
	}

	public static function scaledFontSize(base:Int):Int
	{
		return  Std.int(base * (isCJK() ? 1.6 : 1.4));
	}

	public static function cjkSize(base:Int, ?factor:Float = 0.75):Int
	{
		return isCJK() ? Std.int(base * factor) : base;
	}

	public static function cjkBorder(base:Int, ?factor:Float = 0.5):Int
	{
		return isCJK() ? Math.round(Math.max(1, base * factor)) : base;
	}

	public static function getPhrase(key:String, ?fallback:String, ?vars:Array<Dynamic>):String
	{
		final val = phrases.get(key);

		var result:String = (val != null && Std.isOfType(val, String)) ? cast(val, String) : (fallback ?? key);
		for (i in 0...vars?.length)
			result = result.replace('{${i + 1}}', Std.string(vars[i]));

		return result;
	}

	public static function getFileTranslation(key:String):String
	{
		return key;
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:Null<RawPointer<Lua_State>>) {
		LuaUtilsHx.addFunction(lua, "getTranslationPhrase", function(key:String, ?fallback:String) {
			return get(key, fallback);
		});
	}
	#end
}
