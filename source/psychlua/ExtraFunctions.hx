package psychlua;

import flixel.util.FlxSave;
import openfl.utils.Assets;

class ExtraFunctions
{
	public static function implement(funk:FunkinLua):Void
	{
		var lua:Null<RawPointer<Lua_State>> = funk.lua;

		LuaUtilsHx.addFunction(lua, 'keyboardJustPressed', (name:String) -> Reflect.getProperty(FlxG.keys.justPressed, name));
		LuaUtilsHx.addFunction(lua, 'keyboardPressed',     (name:String) -> Reflect.getProperty(FlxG.keys.pressed, name));
		LuaUtilsHx.addFunction(lua, 'keyboardReleased',    (name:String) -> Reflect.getProperty(FlxG.keys.justReleased, name));

		LuaUtilsHx.addFunction(lua, 'anyGamepadJustPressed', (name:String) -> FlxG.gamepads.anyJustPressed(name));
		LuaUtilsHx.addFunction(lua, 'anyGamepadPressed',     (name:String) -> FlxG.gamepads.anyPressed(name));
		LuaUtilsHx.addFunction(lua, 'anyGamepadReleased',    (name:String) -> FlxG.gamepads.anyJustReleased(name));

		LuaUtilsHx.addFunction(lua, 'gamepadAnalogX', function(id:Int, leftStick:Bool = true) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null ? ctrl.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK) : 0.0;
		});
		LuaUtilsHx.addFunction(lua, 'gamepadAnalogY', function(id:Int, leftStick:Bool = true) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null ? ctrl.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK) : 0.0;
		});
		LuaUtilsHx.addFunction(lua, 'gamepadJustPressed', function(id:Int, name:String) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null && Reflect.getProperty(ctrl.justPressed, name) == true;
		});
		LuaUtilsHx.addFunction(lua, 'gamepadPressed', function(id:Int, name:String) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null && Reflect.getProperty(ctrl.pressed, name) == true;
		});
		LuaUtilsHx.addFunction(lua, 'gamepadReleased', function(id:Int, name:String) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null && Reflect.getProperty(ctrl.justReleased, name) == true;
		});

		LuaUtilsHx.addFunction(lua, 'keyJustPressed', function(name:String = '') {
			return switch (name.toLowerCase().trim()) {
				case 'left':  PlayState.instance.controls.NOTE_LEFT_P;
				case 'down':  PlayState.instance.controls.NOTE_DOWN_P;
				case 'up':    PlayState.instance.controls.NOTE_UP_P;
				case 'right': PlayState.instance.controls.NOTE_RIGHT_P;
				default:      PlayState.instance.controls.justPressed(name);
			};
		});
		LuaUtilsHx.addFunction(lua, 'keyPressed', function(name:String = '') {
			return switch (name.toLowerCase().trim()) {
				case 'left':  PlayState.instance.controls.NOTE_LEFT;
				case 'down':  PlayState.instance.controls.NOTE_DOWN;
				case 'up':    PlayState.instance.controls.NOTE_UP;
				case 'right': PlayState.instance.controls.NOTE_RIGHT;
				default:      PlayState.instance.controls.pressed(name);
			};
		});
		LuaUtilsHx.addFunction(lua, 'keyReleased', function(name:String = '') {
			return switch (name.toLowerCase().trim()) {
				case 'left':  PlayState.instance.controls.NOTE_LEFT_R;
				case 'down':  PlayState.instance.controls.NOTE_DOWN_R;
				case 'up':    PlayState.instance.controls.NOTE_UP_R;
				case 'right': PlayState.instance.controls.NOTE_RIGHT_R;
				default:      PlayState.instance.controls.justReleased(name);
			};
		});

		LuaUtilsHx.addFunction(lua, 'initSaveData', function(name:String, folder:String = 'psychenginemods') {
			var variables = MusicBeatState.getVariables();
			var key = 'save_$name';
			if (!variables.exists(key))
			{
				var save:FlxSave = new FlxSave();
				save.bind(name, CoolUtil.getSavePath() + '/' + folder);
				variables.set(key, save);
				return;
			}
			FunkinLua.luaTrace('initSaveData: Save file already initialized: $name');
		});
		LuaUtilsHx.addFunction(lua, 'flushSaveData', function(name:String) {
			var variables = MusicBeatState.getVariables();
			var key = 'save_$name';
			if (variables.exists(key)) { variables.get(key).flush(); return; }
			FunkinLua.luaTrace('flushSaveData: Save file not initialized: $name', false, false, FlxColor.RED);
		});
		LuaUtilsHx.addFunction(lua, 'getDataFromSave', function(name:String, field:String, defaultValue:Dynamic = null) {
			var variables = MusicBeatState.getVariables();
			var key = 'save_$name';
			if (variables.exists(key))
			{
				var data = variables.get(key).data;
				return Reflect.hasField(data, field) ? Reflect.field(data, field) : defaultValue;
			}
			FunkinLua.luaTrace('getDataFromSave: Save file not initialized: $name', false, false, FlxColor.RED);
			return defaultValue;
		});
		LuaUtilsHx.addFunction(lua, 'setDataFromSave', function(name:String, field:String, value:Dynamic) {
			var variables = MusicBeatState.getVariables();
			var key = 'save_$name';
			if (variables.exists(key)) { Reflect.setField(variables.get(key).data, field, value); return; }
			FunkinLua.luaTrace('setDataFromSave: Save file not initialized: $name', false, false, FlxColor.RED);
		});
		LuaUtilsHx.addFunction(lua, 'eraseSaveData', function(name:String) {
			var variables = MusicBeatState.getVariables();
			var key = 'save_$name';
			if (variables.exists(key)) { variables.get(key).erase(); return; }
			FunkinLua.luaTrace('eraseSaveData: Save file not initialized: $name', false, false, FlxColor.RED);
		});

		LuaUtilsHx.addFunction(lua, 'checkFileExists', function(filename:String, absolute:Bool = false) {
			#if MODS_ALLOWED
			return absolute ? FileSystem.exists(filename) : FileSystem.exists(Paths.getPath(filename, TEXT));
			#else
			return absolute ? Assets.exists(filename, TEXT) : Assets.exists(Paths.getPath(filename, TEXT));
			#end
		});
		LuaUtilsHx.addFunction(lua, 'saveFile', function(path:String, content:String, absolute:Bool = false) {
			try {
				#if MODS_ALLOWED
				File.saveContent(absolute ? path : Paths.mods(path), content);
				#else
				File.saveContent(path, content);
				#end
				return true;
			} catch (e:Dynamic) {
				FunkinLua.luaTrace('saveFile: Error trying to save $path: $e', false, false, FlxColor.RED);
			}
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'deleteFile', function(path:String, ignoreModFolders:Bool = false, absolute:Bool = false) {
			try {
				var lePath:String = absolute ? path : Paths.getPath(path, TEXT, !ignoreModFolders);
				if (FileSystem.exists(lePath)) { FileSystem.deleteFile(lePath); return true; }
			} catch (e:Dynamic) {
				FunkinLua.luaTrace('deleteFile: Error trying to delete $path: $e', false, false, FlxColor.RED);
			}
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'getTextFromFile',   (path:String, ignoreModFolders:Bool = false) -> Paths.getTextFromFile(path, ignoreModFolders));
		LuaUtilsHx.addFunction(lua, 'directoryFileList', function(folder:String) {
			var list:Array<String> = [];
			#if sys
			if (FileSystem.exists(folder))
				for (f in FileSystem.readDirectory(folder))
					if (!list.contains(f)) list.push(f);
			#end
			return list;
		});

		LuaUtilsHx.addFunction(lua, 'stringStartsWith', (str:String, start:String) -> str.startsWith(start));
		LuaUtilsHx.addFunction(lua, 'stringEndsWith',   (str:String, end:String)   -> str.endsWith(end));
		LuaUtilsHx.addFunction(lua, 'stringSplit',      (str:String, sep:String)   -> str.split(sep));
		LuaUtilsHx.addFunction(lua, 'stringTrim',       (str:String)               -> str.trim());

		LuaUtilsHx.addFunction(lua, 'getRandomInt', function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var toExclude:Array<Int> = [];
			if (exclude != '')
				for (s in exclude.split(',')) toExclude.push(Std.parseInt(s.trim()));
			return FlxG.random.int(min, max, toExclude);
		});
		LuaUtilsHx.addFunction(lua, 'getRandomFloat', function(min:Float, max:Float = 1, exclude:String = '') {
			var toExclude:Array<Float> = [];
			if (exclude != '')
				for (s in exclude.split(',')) toExclude.push(Std.parseFloat(s.trim()));
			return FlxG.random.float(min, max, toExclude);
		});
		LuaUtilsHx.addFunction(lua, 'getRandomBool', (chance:Float = 50) -> FlxG.random.bool(chance));

		LuaUtilsHx.addFunction(lua, 'fpsLerp', (amount:Float, elapsed:Float) -> CoolUtil.fpsLerp(amount, elapsed));
		LuaUtilsHx.addFunction(lua, 'lerp',    (from:Float, to:Float, factor:Float, elapsed:Float) -> CoolUtil.lerp(from, to, factor, elapsed));

		LuaUtilsHx.addFunction(lua, 'lerpX', function(obj:String, targetX:Float, factor:Float, elapsed:Float) {
			var spr = LuaUtils.getObjectDirectly(obj);
			if (spr != null) CoolUtil.lerpX(spr, targetX, factor, elapsed);
		});
		LuaUtilsHx.addFunction(lua, 'lerpY', function(obj:String, targetY:Float, factor:Float, elapsed:Float) {
			var spr = LuaUtils.getObjectDirectly(obj);
			if (spr != null) CoolUtil.lerpY(spr, targetY, factor, elapsed);
		});
		LuaUtilsHx.addFunction(lua, 'lerpPos', function(obj:String, targetX:Float, targetY:Float, factor:Float, elapsed:Float) {
			var spr = LuaUtils.getObjectDirectly(obj);
			if (spr != null) CoolUtil.lerpPos(spr, targetX, targetY, factor, elapsed);
		});
		LuaUtilsHx.addFunction(lua, 'lerpScale', function(obj:String, target:Float, factor:Float, elapsed:Float) {
			var spr = LuaUtils.getObjectDirectly(obj);
			if (spr != null && Std.isOfType(spr, flixel.FlxSprite)) CoolUtil.lerpScale(cast spr, target, factor, elapsed);
		});
		LuaUtilsHx.addFunction(lua, 'lerpAlpha', function(obj:String, target:Float, factor:Float, elapsed:Float) {
			var spr = LuaUtils.getObjectDirectly(obj);
			if (spr != null && Std.isOfType(spr, flixel.FlxSprite)) CoolUtil.lerpAlpha(cast spr, target, factor, elapsed);
		});
		LuaUtilsHx.addFunction(lua, 'lerpZoom', function(cam:String, target:Float, factor:Float, elapsed:Float) {
			var c = LuaUtils.cameraFromString(cam);
			if (c != null) CoolUtil.lerpZoom(c, target, factor, elapsed);
		});

		LuaUtilsHx.addFunction(lua, 'getLanguage', function():String {
			var lang = ClientPrefs.data.language ?? 'auto';
			if (lang.length == 0) lang = 'auto';

			return lang == 'auto' ? backend.Language.getSystemLanguage() : lang;
		});

		LuaUtilsHx.addFunction(lua, 'getSongLyric', function(key:String, ?fallback:String):String {
			final songName = PlayState.SONG?.song?.toLowerCase()?.replace(' ', '-') ?? '';
			final modDir = backend.Mods.currentModDirectory;
			
			var lang = ClientPrefs.data.language ?? 'auto';
			if (lang.length == 0) lang = 'auto';
			if (lang == 'auto') lang = backend.Language.getSystemLanguage(); 

			final paths:Array<String> = [];
			if (modDir != null && modDir.length > 0)
				paths.push('mods/$modDir/data/$songName/lyrics.json');
			paths.push('mods/data/$songName/lyrics.json');
			paths.push('assets/data/$songName/lyrics.json');

			var data:Dynamic = null;
			for (path in paths) {
				try {
					var text:String = null;

					#if sys
					if (sys.FileSystem.exists(path))
						text = sys.io.File.getContent(path);
					else
					#end
					if (openfl.utils.Assets.exists(path))
						text = openfl.utils.Assets.getText(path);

					if (text?.length > 0) {
						data = haxe.Json.parse(text);
						break;
					}
				} catch(e:Dynamic) {
					trace('Error on text reading (Lyrics): ' + e);
				}
			}

			if (data == null) return fallback ?? key;

			final langData:Dynamic = Reflect.field(data, lang) ?? Reflect.field(data, 'en-US');
			if (langData == null) return fallback ?? key;

			final val:Dynamic = Reflect.field(langData, key);
			return val != null ? Std.string(val) : (fallback ?? key);
		});

		LuaUtilsHx.addFunction(lua, 'getPhrase', (key:String, ?fallback:String, ?vars:Array<Dynamic>) -> {
			return backend.Language.getPhrase(key, fallback, vars);
		});
	}
}
