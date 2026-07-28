package psychlua;

import flixel.FlxBasic;
import objects.Character;
import psychlua.LuaUtils;
import psychlua.CustomSubstate;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;

import haxe.ValueException;

typedef HScriptInfos = {
	> haxe.PosInfos,
	var ?funcName:String;
	var ?showLine:Null<Bool>;
	#if LUA_ALLOWED
	var ?isLua:Null<Bool>;
	#end
}

class HScript extends Iris
{
	public var filePath:String;
	public var modFolder:String;
	public var returnValue:Dynamic;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;

	public static function initHaxeModule(parent:FunkinLua):Void
	{
		if (parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, varsToBring:Any = null):Void
	{
		var hs:HScript = try parent.hscript catch (e) null;
		if (hs == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			try
			{
				parent.hscript = new HScript(parent, code, varsToBring);
			}
			catch (e:IrisError)
			{
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if (parent.lastCalledFunction != '') pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				parent.hscript = null;
			}
		}
		else
		{
			try
			{
				hs.scriptCode = code;
				hs.varsToBring = varsToBring;
				hs.parse(true);
				hs.returnValue = hs.execute();
			}
			catch (e:IrisError)
			{
				var pos:HScriptInfos = cast hs.interp.posInfos();
				pos.isLua = true;
				if (parent.lastCalledFunction != '') pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				hs.returnValue = null;
			}
		}
	}
	#end

	public var origin:String;

	override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false)
	{
		if (file == null) file = '';

		filePath = file;
		if (filePath != null && filePath.length > 0)
		{
			origin = filePath;
			#if MODS_ALLOWED
			var parts = filePath.split('/');
			if (parts[0] + '/' == Paths.mods() && (Mods.currentModDirectory == parts[1] || Mods.getGlobalMods().contains(parts[1])))
				modFolder = parts[1];
			#end
		}

		var scriptThing:String = file;
		var scriptName:String = null;

		if (parent == null && file != null)
		{
			var f:String = file.replace('\\', '/');
			if (f.contains('/') && !f.contains('\n'))
			{
				scriptThing = null;
				
				#if sys
				if (sys.FileSystem.exists(f))
					scriptThing = sys.io.File.getContent(f);
				#end
				
				if (scriptThing == null && openfl.utils.Assets.exists(f))
					scriptThing = openfl.utils.Assets.getText(f);
				
				scriptThing ??= file; 
				scriptName = f;
			}
		}

		#if LUA_ALLOWED
		if (scriptName == null && parent != null) scriptName = parent.scriptName;
		#end

		super(scriptThing, new IrisConfig(scriptName, false, false));

		var customInterp = new CustomInterp();
		customInterp.parentInstance = FlxG.state;
		customInterp.showPosOnLog = false;
		interp = customInterp;

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null) { origin = parent.scriptName; modFolder = parent.modFolder; }
		#end

		preset();
		this.varsToBring = varsToBring;

		if (!manualRun)
		{
			try
			{
				returnValue = execute();
			}
			catch (e:IrisError)
			{
				returnValue = null;
				destroy();
				throw e;
			}
		}
	}

	var varsToBring(default, set):Any = null;

	override function preset():Void
	{
		super.preset();

		set('Type', Type);
		#if sys
		set('File', File);
		set('FileSystem', FileSystem);
		#end
		set('FlxG',            flixel.FlxG);
		set('FlxMath',         flixel.math.FlxMath);
		set('FlxSprite',       flixel.FlxSprite);
		set('FlxSpriteGroup',  flixel.group.FlxSpriteGroup);
		set('FlxText',         flixel.text.FlxText);
		set('FlxCamera',       flixel.FlxCamera);
		set('PsychCamera',     backend.PsychCamera);
		set('FlxTimer',        flixel.util.FlxTimer);
		set('FlxTween',        flixel.tweens.FlxTween);
		set('FlxEase',         flixel.tweens.FlxEase);
		set('FlxColor',        CustomFlxColor);
		set('CoolUtil',        backend.CoolUtil);
		set('Countdown',       backend.BaseStage.Countdown);
		set('PlayState',       PlayState);
		set('Paths',           Paths);
		set('Conductor',       Conductor);
		set('ClientPrefs',     ClientPrefs);
		set('Achievements',    Achievements);
		set('Character',       Character);
		set('Alphabet',        Alphabet);
		set('Note',            objects.Note);
		set('CustomSubstate',  CustomSubstate);
		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		set('ErrorHandledRuntimeShader', shaders.ErrorHandledShader.ErrorHandledRuntimeShader);
		#end
		set('ShaderFilter',    openfl.filters.ShaderFilter);
		set('StringTools',     StringTools);
		#if flixel_animate
		set('FlxAnimate', animate.FlxAnimate);
		#end
		set('Reflect',  Reflect);
		set('Sys',      Sys);

		set('setVar', function(name:String, value:Dynamic) {
			MusicBeatState.getVariables().set(name, value);
			return value;
		});
		set('getVar', function(name:String) {
			return MusicBeatState.getVariables().exists(name) ? MusicBeatState.getVariables().get(name) : null;
		});
		set('removeVar', function(name:String) {
			if (MusicBeatState.getVariables().exists(name)) { MusicBeatState.getVariables().remove(name); return true; }
			return false;
		});
		set('debugPrint', function(text:String, color:FlxColor = null) {
			if (color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});
		set('getModSetting', function(saveTag:String, modName:String = null) {
			if (modName == null)
			{
				if (modFolder == null) { Iris.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', interp.posInfos()); return null; }
				modName = modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});

		set('keyboardJustPressed', (name:String) -> Reflect.getProperty(FlxG.keys.justPressed, name));
		set('keyboardPressed',     (name:String) -> Reflect.getProperty(FlxG.keys.pressed, name));
		set('keyboardReleased',    (name:String) -> Reflect.getProperty(FlxG.keys.justReleased, name));

		set('anyGamepadJustPressed', (name:String) -> FlxG.gamepads.anyJustPressed(name));
		set('anyGamepadPressed',     (name:String) -> FlxG.gamepads.anyPressed(name));
		set('anyGamepadReleased',    (name:String) -> FlxG.gamepads.anyJustReleased(name));

		set('gamepadAnalogX', function(id:Int, leftStick:Bool = true) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null ? ctrl.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK) : 0.0;
		});
		set('gamepadAnalogY', function(id:Int, leftStick:Bool = true) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null ? ctrl.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK) : 0.0;
		});
		set('gamepadJustPressed', function(id:Int, name:String) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null && Reflect.getProperty(ctrl.justPressed, name) == true;
		});
		set('gamepadPressed', function(id:Int, name:String) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null && Reflect.getProperty(ctrl.pressed, name) == true;
		});
		set('gamepadReleased', function(id:Int, name:String) {
			var ctrl = FlxG.gamepads.getByID(id);
			return ctrl != null && Reflect.getProperty(ctrl.justReleased, name) == true;
		});

		set('keyJustPressed', function(name:String = '') {
			return switch (name.toLowerCase()) {
				case 'left':  Controls.instance.NOTE_LEFT_P;
				case 'down':  Controls.instance.NOTE_DOWN_P;
				case 'up':    Controls.instance.NOTE_UP_P;
				case 'right': Controls.instance.NOTE_RIGHT_P;
				default:      Controls.instance.justPressed(name);
			};
		});
		set('keyPressed', function(name:String = '') {
			return switch (name.toLowerCase()) {
				case 'left':  Controls.instance.NOTE_LEFT;
				case 'down':  Controls.instance.NOTE_DOWN;
				case 'up':    Controls.instance.NOTE_UP;
				case 'right': Controls.instance.NOTE_RIGHT;
				default:      Controls.instance.pressed(name);
			};
		});
		set('keyReleased', function(name:String = '') {
			return switch (name.toLowerCase()) {
				case 'left':  Controls.instance.NOTE_LEFT_R;
				case 'down':  Controls.instance.NOTE_DOWN_R;
				case 'up':    Controls.instance.NOTE_UP_R;
				case 'right': Controls.instance.NOTE_RIGHT_R;
				default:      Controls.instance.justReleased(name);
			};
		});

		#if LUA_ALLOWED
		set('createGlobalCallback', function(name:String, func:Dynamic) {
			for (script in PlayState.instance.luaArray)
				if (script != null && script.lua != null && !script.closed)
					LuaUtilsHx.addFunction(script.lua, name, func);
			FunkinLua.customFunctions.set(name, func);
		});
		set('createCallback', function(name:String, func:Dynamic, funk:FunkinLua = null) {
			if (funk == null) funk = parentLua;
			if (funk != null) funk.addLocalCallback(name, func);
			else Iris.error('createCallback ($name): 3rd argument is null', interp.posInfos());
		});
		#end

		set('addHaxeLibrary', function(libName:String, libPackage:String = '') {
			try
			{
				var str = libPackage.length > 0 ? libPackage + '.' : '';
				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:IrisError)
			{
				Iris.error(Printer.errorToString(e, false), interp.posInfos());
			}
		});

		#if LUA_ALLOWED
		set('parentLua', parentLua);
		#else
		set('parentLua', null);
		#end

		set('this',              this);
		set('game',              FlxG.state);
		set('controls',          Controls.instance);
		set('buildTarget',       LuaUtils.getBuildTarget());
		set('customSubstate',    CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);
		set('Function_Stop',     LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('Function_StopLua',  LuaUtils.Function_StopLua);
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll',  LuaUtils.Function_StopAll);
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua):Void
	{
		funk.addLocalCallback('runHaxeCode', function(codeToRun:String, varsToBring:Any = null, funcToRun:String = null, funcArgs:Array<Dynamic> = null):Dynamic {
			initHaxeModuleCode(funk, codeToRun, varsToBring);
			if (funk.hscript != null)
			{
				var retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null) return LuaUtils.isLuaSupported(retVal.returnValue) ? retVal.returnValue : null;
				if (funk.hscript.returnValue != null) return funk.hscript.returnValue;
			}
			return null;
		});

		funk.addLocalCallback('runHaxeFunction', function(funcToRun:String, funcArgs:Array<Dynamic> = null) {
			if (funk.hscript != null)
			{
				var retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null) return LuaUtils.isLuaSupported(retVal.returnValue) ? retVal.returnValue : null;
			}
			else
			{
				var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
				if (funk.lastCalledFunction != '') pos.funcName = funk.lastCalledFunction;
				Iris.error('runHaxeFunction: HScript has not been initialized yet! Use "runHaxeCode" to initialize it', pos);
			}
			return null;
		});

		funk.addLocalCallback('addHaxeLibrary', function(libName:String, libPackage:String = '') {
			var str = libPackage.length > 0 ? libPackage + '.' : '';
			if (libName == null) libName = '';

			var c:Dynamic = (Type.resolveClass(str + libName) : Dynamic) ?? (Type.resolveEnum(str + libName) : Dynamic);

			if (funk.hscript == null) initHaxeModule(funk);

			var pos:HScriptInfos = cast funk.hscript.interp.posInfos();
			pos.showLine = false;
			if (funk.lastCalledFunction != '') pos.funcName = funk.lastCalledFunction;

			try { if (c != null) funk.hscript.set(libName, c); }
			catch (e:IrisError) { Iris.error(Printer.errorToString(e, false), pos); }

			FunkinLua.lastCalledScript = funk;
		});
	}
	#end

	override function call(funcToRun:String, ?args:Array<Dynamic>):IrisCall
	{
		if (funcToRun == null || interp == null) return null;
		if (!exists(funcToRun)) { Iris.error('No function named: $funcToRun', interp.posInfos()); return null; }

		try
		{
			var func:Dynamic = interp.variables.get(funcToRun);
			var ret = Reflect.callMethod(null, func, args ?? []);
			return {funName: funcToRun, signature: func, returnValue: ret};
		}
		catch (e:IrisError)
		{
			var pos:HScriptInfos = cast interp.posInfos();
			pos.funcName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null) { pos.isLua = true; if (parentLua.lastCalledFunction != '') pos.funcName = parentLua.lastCalledFunction; }
			#end
			Iris.error(Printer.errorToString(e, false), pos);
		}
		catch (e:ValueException)
		{
			var pos:HScriptInfos = cast interp.posInfos();
			pos.funcName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null) { pos.isLua = true; if (parentLua.lastCalledFunction != '') pos.funcName = parentLua.lastCalledFunction; }
			#end
			Iris.error('$e', pos);
		}
		return null;
	}

	override public function destroy():Void
	{
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end
		super.destroy();
	}

	function set_varsToBring(values:Any):Any
	{
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if (exists(key.trim())) interp.variables.remove(key.trim());

		if (values != null)
			for (key in Reflect.fields(values))
			{
				key = key.trim();
				set(key, Reflect.field(values, key));
			}

		return varsToBring = values;
	}
}

class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int       = FlxColor.BLACK;
	public static var WHITE(default, null):Int       = FlxColor.WHITE;
	public static var GRAY(default, null):Int        = FlxColor.GRAY;
	public static var GREEN(default, null):Int       = FlxColor.GREEN;
	public static var LIME(default, null):Int        = FlxColor.LIME;
	public static var YELLOW(default, null):Int      = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int      = FlxColor.ORANGE;
	public static var RED(default, null):Int         = FlxColor.RED;
	public static var PURPLE(default, null):Int      = FlxColor.PURPLE;
	public static var BLUE(default, null):Int        = FlxColor.BLUE;
	public static var BROWN(default, null):Int       = FlxColor.BROWN;
	public static var PINK(default, null):Int        = FlxColor.PINK;
	public static var MAGENTA(default, null):Int     = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int        = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int                                                                   return cast FlxColor.fromInt(Value);
	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int                               return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int                    return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int                           return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int                         return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	public static function fromString(str:String):Int                                                               return cast FlxColor.fromString(str);

	// Channel readers — pass any Int color value to extract individual channels.
	public static function getAlpha(color:Int):Int        return (color >> 24) & 0xFF;
	public static function getRed(color:Int):Int          return (color >> 16) & 0xFF;
	public static function getGreen(color:Int):Int        return (color >> 8)  & 0xFF;
	public static function getBlue(color:Int):Int         return  color        & 0xFF;

	public static function getAlphaFloat(color:Int):Float return getAlpha(color) / 255;
	public static function getRedFloat(color:Int):Float   return getRed(color)   / 255;
	public static function getGreenFloat(color:Int):Float return getGreen(color) / 255;
	public static function getBlueFloat(color:Int):Float  return getBlue(color)  / 255;

	// Channel writers — return a new Int with the channel replaced.
	public static function setAlpha(color:Int, alpha:Int):Int  return (color & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
	public static function setRed(color:Int, red:Int):Int      return (color & 0xFF00FFFF) | ((red   & 0xFF) << 16);
	public static function setGreen(color:Int, green:Int):Int  return (color & 0xFFFF00FF) | ((green & 0xFF) << 8);
	public static function setBlue(color:Int, blue:Int):Int    return (color & 0xFFFFFF00) |  (blue  & 0xFF);

	// Utilities
	public static function toHexString(color:Int, alpha:Bool = true):String
	{
		return alpha
			? '#' + StringTools.hex(color, 8)
			: '#' + StringTools.hex(color & 0xFFFFFF, 6);
	}

	public static function toWebString(color:Int):String  return '0x' + StringTools.hex(color & 0xFFFFFF, 6);

	public static function interpolate(color1:Int, color2:Int, factor:Float = 0.5):Int
		return cast FlxColor.interpolate(cast color1, cast color2, factor);

	public static function blend(src:Int, dst:Int):Int
	{
		final sA:Int = (src >> 24) & 0xFF;
		final sR:Int = (src >> 16) & 0xFF;
		final sG:Int = (src >>  8) & 0xFF;
		final sB:Int =  src        & 0xFF;
		final dA:Int = (dst >> 24) & 0xFF;
		final dR:Int = (dst >> 16) & 0xFF;
		final dG:Int = (dst >>  8) & 0xFF;
		final dB:Int =  dst        & 0xFF;
		final a:Int  = sA + Std.int(dA * (255 - sA) / 255);
		final r:Int  = sR + Std.int(dR * (255 - sA) / 255);
		final g:Int  = sG + Std.int(dG * (255 - sA) / 255);
		final b:Int  = sB + Std.int(dB * (255 - sA) / 255);
		return (a << 24) | (r << 16) | (g << 8) | b;
	}

	public static function getLightness(color:Int):Float
	{
		final r = getRed(color)   / 255;
		final g = getGreen(color) / 255;
		final b = getBlue(color)  / 255;
		return (Math.max(r, Math.max(g, b)) + Math.min(r, Math.min(g, b))) * 0.5;
	}

	public static function getSaturation(color:Int):Float
	{
		final r = getRed(color)   / 255;
		final g = getGreen(color) / 255;
		final b = getBlue(color)  / 255;
		final max = Math.max(r, Math.max(g, b));
		final min = Math.min(r, Math.min(g, b));
		final delta = max - min;
		if (delta == 0) return 0;
		final l = (max + min) * 0.5;
		return delta / (1 - Math.abs(2 * l - 1));
	}

	public static function getHue(color:Int):Float
	{
		final r = getRed(color)   / 255;
		final g = getGreen(color) / 255;
		final b = getBlue(color)  / 255;
		final max = Math.max(r, Math.max(g, b));
		final min = Math.min(r, Math.min(g, b));
		final delta = max - min;
		if (delta == 0) return 0;
		var hue:Float;
		if (max == r)      hue = ((g - b) / delta) % 6;
		else if (max == g) hue = (b - r) / delta + 2;
		else               hue = (r - g) / delta + 4;
		hue *= 60;
		if (hue < 0) hue += 360;
		return hue;
	}

	public static function getBrightness(color:Int):Float
		return Math.max(getRed(color), Math.max(getGreen(color), getBlue(color))) / 255;

	public static function getDarkened(color:Int, factor:Float = 0.2):Int
	{
		final f = 1 - factor;
		return fromRGB(
			Std.int(getRed(color)   * f),
			Std.int(getGreen(color) * f),
			Std.int(getBlue(color)  * f),
			getAlpha(color)
		);
	}

	public static function getLightened(color:Int, factor:Float = 0.2):Int
	{
		return fromRGB(
			Std.int(getRed(color)   + (255 - getRed(color))   * factor),
			Std.int(getGreen(color) + (255 - getGreen(color)) * factor),
			Std.int(getBlue(color)  + (255 - getBlue(color))  * factor),
			getAlpha(color)
		);
	}

	public static function getInverted(color:Int):Int
		return fromRGB(255 - getRed(color), 255 - getGreen(color), 255 - getBlue(color), getAlpha(color));
}

class CustomInterp extends crowplexus.hscript.Interp
{
	public var parentInstance(default, set):Dynamic = [];
	var _instanceFields:Array<String>;

	function set_parentInstance(inst:Dynamic):Dynamic
	{
		parentInstance = inst;
		_instanceFields = inst != null ? Type.getInstanceFields(Type.getClass(inst)) : [];
		return inst;
	}

	public function new() super();

	override function fcall(o:Dynamic, funcToRun:String, args:Array<Dynamic>):Dynamic
	{
		for (_using in usings)
		{
			var v = _using.call(o, funcToRun, args);
			if (v != null) return v;
		}
		var f = get(o, funcToRun);
		if (f == null) { Iris.error('Tried to call null function $funcToRun', posInfos()); return null; }
		return Reflect.callMethod(o, f, args);
	}

	override function resolve(id:String):Dynamic
	{
		if (locals.exists(id)) return locals.get(id).r;
		if (variables.exists(id)) return variables.get(id);
		if (imports.exists(id)) return imports.get(id);
		if (parentInstance != null && _instanceFields.contains(id)) return Reflect.getProperty(parentInstance, id);
		error(EUnknownVariable(id));
		return null;
	}
}

#else

class HScript
{
	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua):Void
	{
		var unsupported = function(?a:Dynamic, ?b:Dynamic, ?c:Dynamic, ?d:Dynamic) {
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		};
		funk.addLocalCallback('runHaxeCode',    unsupported);
		funk.addLocalCallback('runHaxeFunction', unsupported);
		funk.addLocalCallback('addHaxeLibrary', unsupported);
	}
	#end
}
#end
