package backend;

import haxe.Json;
import openfl.Assets;

class Language
{
	static var phrases:Map<String, Dynamic> = [];
	static var currentKey:String = 'en-US';

	public static function reload():Void
	{
		var key = ClientPrefs.data.language;
		if (key == null || key.length == 0) key = 'en-US';
		currentKey = key;
		phrases = [];

		var path = 'assets/exe/options/language/$key.json';
		try {
			var text = Assets.getText(path);
			if (text != null && text.length > 0) {
				var data:Dynamic = Json.parse(text);
				for (field in Reflect.fields(data))
					phrases.set(field, Reflect.field(data, field));
			}
		} catch (e:Dynamic) {}
	}

	public static function get(key:String, ?fallback:String):String
	{
		var val = phrases.get(key);
		if (val == null) return fallback != null ? fallback : key;
		if (Std.isOfType(val, String)) return cast(val, String);
		return fallback != null ? fallback : key;
	}

	public static function getArray(key:String, ?fallback:Array<String>):Array<String>
	{
		var val = phrases.get(key);
		if (val == null) return fallback != null ? fallback : [];
		if (Std.isOfType(val, Array)) return cast val;
		return fallback != null ? fallback : [];
	}

	public static function getFontForLanguage():String
	{
		return switch (currentKey) {
			case 'ja-JP': 'japanese.ttf';
			case 'ko-KR': 'korean.ttf';
			case 'zh-CN': 'chinese.ttf';
			case 'ru-RU' | 'uk-UA': 'Pixellari.ttf';
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

	public static function scaledFontSize(base:Int):Int
	{
		return isCJK() ? Std.int(base * 1.6) : base;
	}

	public static function cjkSize(base:Int, ?factor:Float = 0.75):Int
	{
		return isCJK() ? Std.int(base * factor) : base;
	}

	public static function getPhrase(key:String, ?fallback:String, ?vars:Array<Dynamic>):String
	{
		var val = phrases.get(key);
		var result:String = (val != null && Std.isOfType(val, String)) ? cast(val, String) : (fallback != null ? fallback : key);
		if (vars != null)
			for (i in 0...vars.length)
				result = StringTools.replace(result, '{${i + 1}}', Std.string(vars[i]));
		return result;
	}

	public static function getFileTranslation(key:String):String
	{
		return key;
	}

	public static function reloadPhrases():Void
	{
		reload();
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:llua.State) {
		Lua_helper.add_callback(lua, "getTranslationPhrase", function(key:String, ?fallback:String) {
			return get(key, fallback);
		});
	}
	#end
}
