package psychlua;

import backend.WeekData;
import objects.Character;
import backend.StageData;

import openfl.display.BlendMode;
import Type.ValueType;

import states.substates.GameOverSubstate;

typedef LuaTweenOptions = {
	type:FlxTweenType,
	startDelay:Float,
	onUpdate:Null<String>,
	onStart:Null<String>,
	onComplete:Null<String>,
	loopDelay:Float,
	ease:EaseFunction
}

class LuaUtils
{
	public static final Function_Stop:String         = '##PSYCHLUA_FUNCTIONSTOP';
	public static final Function_Continue:String     = '##PSYCHLUA_FUNCTIONCONTINUE';
	public static final Function_StopLua:String      = '##PSYCHLUA_FUNCTIONSTOPLUA';
	public static final Function_StopHScript:String  = '##PSYCHLUA_FUNCTIONSTOPHSCRIPT';
	public static final Function_StopAll:String      = '##PSYCHLUA_FUNCTIONSTOPALL';

	public static function getLuaTween(options:Dynamic):Null<LuaTweenOptions>
	{
		if (options == null) return null;
		return {
			type:       getTweenTypeByString(options.type),
			startDelay: options.startDelay,
			onUpdate:   options.onUpdate,
			onStart:    options.onStart,
			onComplete: options.onComplete,
			loopDelay:  options.loopDelay,
			ease:       getTweenEaseByString(options.ease)
		};
	}

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
	{
		var splitProps = variable.split('[');
		if (splitProps.length > 1)
		{
			var target:Dynamic = MusicBeatState.getVariables().exists(splitProps[0])
				? MusicBeatState.getVariables().get(splitProps[0])
				: Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				if (i >= splitProps.length - 1) target[j] = value;
				else target = target[j];
			}
			return target;
		}

		if (allowMaps && isMap(instance))
		{
			instance.set(variable, value);
			return value;
		}

		if (instance is MusicBeatState && MusicBeatState.getVariables().exists(variable))
		{
			MusicBeatState.getVariables().set(variable, value);
			return value;
		}

		Reflect.setProperty(instance, variable, value);
		return value;
	}

	public static function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
	{
		var splitProps = variable.split('[');
		if (splitProps.length > 1)
		{
			var target:Dynamic = MusicBeatState.getVariables().exists(splitProps[0])
				? MusicBeatState.getVariables().get(splitProps[0])
				: Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var idx:String = splitProps[i].substr(0, splitProps[i].length - 1);
				var parsed = Std.parseInt(idx);
				target = (parsed != null) ? (target : Array<Dynamic>)[parsed] : Reflect.field(target, idx);
			}

			return target;
		}

		if (allowMaps && isMap(instance)) return instance.get(variable);

		if (instance is MusicBeatState && MusicBeatState.getVariables().exists(variable))
		{
			var retVal:Dynamic = MusicBeatState.getVariables().get(variable);
			if (retVal != null) return retVal;
		}

		return Reflect.getProperty(instance, variable);
	}

	public static function getModSetting(saveTag:String, modName:String = null):Dynamic
	{
		#if MODS_ALLOWED
		if (FlxG.save.data.modSettings == null)
			FlxG.save.data.modSettings = new Map<String, Dynamic>();

		var settings:Map<String, Dynamic> = FlxG.save.data.modSettings.get(modName);
		var path:String = Paths.mods('$modName/data/settings.json');

		if (FileSystem.exists(path))
		{
			if (settings == null || !settings.exists(saveTag))
			{
				if (settings == null) settings = new Map<String, Dynamic>();
				try
				{
					var parsedJson:Dynamic = tjson.TJSON.parse(File.getContent(path));
					for (i in 0...parsedJson.length)
					{
						var sub:Dynamic = parsedJson[i];
						if (sub != null && sub.save != null && !settings.exists(sub.save))
						{
							if (sub.type != 'keybind' && sub.type != 'key')
							{
								if (sub.value != null) settings.set(sub.save, sub.value);
							}
							else
							{
								settings.set(sub.save, {
									keyboard: (sub.keyboard != null ? sub.keyboard : 'NONE'),
									gamepad:  (sub.gamepad  != null ? sub.gamepad  : 'NONE')
								});
							}
						}
					}
					FlxG.save.data.modSettings.set(modName, settings);
				}
				catch (e:Dynamic)
				{
					var title = 'Mod name: ' + Mods.currentModDirectory;
					var msg   = 'An error occurred: $e';
					#if windows lime.app.Application.current.window.alert(msg, title); #end
					trace('$title - $msg');
				}
			}
		}
		else
		{
			FlxG.save.data.modSettings.remove(modName);
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			PlayState.instance.addTextToDebug('getModSetting: $path could not be found!', FlxColor.RED);
			#else
			FlxG.log.warn('getModSetting: $path could not be found!');
			#end
			return null;
		}

		if (settings.exists(saveTag)) return settings.get(saveTag);

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		PlayState.instance.addTextToDebug('getModSetting: "$saveTag" could not be found inside $modName\'s settings!', FlxColor.RED);
		#else
		FlxG.log.warn('getModSetting: "$saveTag" could not be found inside $modName\'s settings!');
		#end
		#end
		return null;
	}

	public static function isMap(variable:Dynamic):Bool
		return variable != null && variable.exists != null && variable.keyValueIterator != null;

	public static function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Dynamic
	{
		var split = variable.split('.');
		if (split.length > 1)
		{
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length - 1) obj = Reflect.getProperty(obj, split[i]);
			leArray = obj;
			variable = split[split.length - 1];
		}
		if (allowMaps && isMap(leArray)) leArray.set(variable, value);
		else Reflect.setProperty(leArray, variable, value);
		return value;
	}

	public static function getGroupStuff(leArray:Dynamic, variable:String, allowMaps:Bool = false):Dynamic
	{
		var split = variable.split('.');
		if (split.length > 1)
		{
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length - 1) obj = Reflect.getProperty(obj, split[i]);
			leArray = obj;
			variable = split[split.length - 1];
		}
		if (allowMaps && isMap(leArray)) return leArray.get(variable);
		return Reflect.getProperty(leArray, variable);
	}

	public static function getPropertyLoop(split:Array<String>, getProperty:Bool = true, allowMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObjectDirectly(split[0]);
		var end = getProperty ? split.length - 1 : split.length;
		for (i in 1...end) obj = getVarInArray(obj, split[i], allowMaps);
		return obj;
	}

	public static function getObjectDirectly(objectName:String, allowMaps:Bool = false):Dynamic
	{
		return switch (objectName)
		{
			case 'this' | 'instance' | 'game':
				PlayState.instance;
			default:
				var obj = MusicBeatState.getVariables().get(objectName);
				obj != null ? obj : getVarInArray(MusicBeatState.getState(), objectName, allowMaps);
		};
	}

	public static function isOfTypes(value:Any, types:Array<Dynamic>):Bool
	{
		for (t in types)
			if (Std.isOfType(value, t)) return true;
		return false;
	}

	public static function isLuaSupported(value:Any):Bool
		return value == null || isOfTypes(value, [Bool, Int, Float, String, Array]) || Type.typeof(value) == ValueType.TObject;

	public static function getTargetInstance():Dynamic
	{
		if (PlayState.instance != null)
			return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
		return MusicBeatState.getState();
	}

	public static inline function getLowestCharacterGroup():FlxSpriteGroup
	{
		var stageData:StageFile = StageData.getStageFile(PlayState.SONG.stage);
		var group:FlxSpriteGroup = stageData.hide_girlfriend ? PlayState.instance.boyfriendGroup : PlayState.instance.gfGroup;
		var pos:Int = PlayState.instance.members.indexOf(group);

		var newPos = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
		if (newPos < pos) { group = PlayState.instance.boyfriendGroup; pos = newPos; }

		newPos = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
		if (newPos < pos) group = PlayState.instance.dadGroup;

		return group;
	}

	public static function addAnimByIndices(obj:String, name:String, prefix:String, indices:Any = null, framerate:Float = 24, loop:Bool = false):Bool
	{
		var spr:FlxSprite = cast getObjectDirectly(obj);
		if (spr == null || spr.animation == null) return false;

		if (indices == null)
			indices = [0];
		else if (Std.isOfType(indices, String))
			indices = cast (indices, String).trim().split(',').map(s -> Std.parseInt(s));

		if (prefix != null) spr.animation.addByIndices(name, prefix, indices, '', framerate, loop);
		else spr.animation.add(name, indices, framerate, loop);

		if (spr.animation.curAnim == null)
		{
			var dyn:Dynamic = cast spr;
			if (dyn.playAnim != null) dyn.playAnim(name, true);
			else dyn.animation.play(name, true);
		}
		return true;
	}

	public static function loadFrames(spr:FlxSprite, image:String, spriteType:String):Void
	{
		switch (spriteType.toLowerCase().replace(' ', ''))
		{
			case 'aseprite', 'ase', 'json', 'jsoni8':
				spr.frames = Paths.getAsepriteAtlas(image);
			case 'packer', 'packeratlas', 'pac':
				spr.frames = Paths.getPackerAtlas(image);
			case 'sparrow', 'sparrowatlas', 'sparrowv2':
				spr.frames = Paths.getSparrowAtlas(image);
			default:
				spr.frames = Paths.getAtlas(image);
		}
	}

	public static function destroyObject(tag:String):Void
	{
		var variables = MusicBeatState.getVariables();
		var obj:FlxSprite = variables.get(tag);
		if (obj == null || obj.destroy == null) return;
		getTargetInstance().remove(obj, true);
		obj.destroy();
		variables.remove(tag);
	}

	public static function cancelTween(tag:String):Void
	{
		if (!tag.startsWith('tween_')) tag = 'tween_' + formatVariable(tag);
		var variables = MusicBeatState.getVariables();
		var twn:FlxTween = variables.get(tag);
		if (twn != null) { twn.cancel(); twn.destroy(); variables.remove(tag); }
	}

	public static function cancelTimer(tag:String):Void
	{
		if (!tag.startsWith('timer_')) tag = 'timer_' + formatVariable(tag);
		var variables = MusicBeatState.getVariables();
		var tmr:FlxTimer = variables.get(tag);
		if (tmr != null) { tmr.cancel(); tmr.destroy(); variables.remove(tag); }
	}

	public static inline function formatVariable(tag:String):String
		return tag.trim().replace(' ', '_').replace('.', '');

	public static function tweenPrepare(tag:String, vars:String):Dynamic
	{
		if (tag != null) cancelTween(tag);
		var variables = vars.split('.');
		var prop:Dynamic = getObjectDirectly(variables[0]);
		if (variables.length > 1) prop = getVarInArray(getPropertyLoop(variables), variables[variables.length - 1]);
		return prop;
	}

	public static function getBuildTarget():String
	{
		#if windows
			#if x86_BUILD return 'windows_x86'; #else return 'windows'; #end
		#elseif linux
			return 'linux';
		#elseif mac
			return 'mac';
		#elseif html5
			return 'browser';
		#elseif android
			return 'android';
		#elseif switch
			return 'switch';
		#else
			return 'unknown';
		#end
	}

	public static function getTweenTypeByString(type:String = ''):FlxTweenType
	{
		return switch (type.toLowerCase().trim())
		{
			case 'backward':        FlxTweenType.BACKWARD;
			case 'looping' | 'loop': FlxTweenType.LOOPING;
			case 'persist':         FlxTweenType.PERSIST;
			case 'pingpong':        FlxTweenType.PINGPONG;
			default:                FlxTweenType.ONESHOT;
		};
	}

	public static function getTweenEaseByString(ease:String = ''):EaseFunction
	{
		return switch (ease.toLowerCase().trim())
		{
			case 'backin':           FlxEase.backIn;
			case 'backinout':        FlxEase.backInOut;
			case 'backout':          FlxEase.backOut;
			case 'bouncein':         FlxEase.bounceIn;
			case 'bounceinout':      FlxEase.bounceInOut;
			case 'bounceout':        FlxEase.bounceOut;
			case 'circin':           FlxEase.circIn;
			case 'circinout':        FlxEase.circInOut;
			case 'circout':          FlxEase.circOut;
			case 'cubein':           FlxEase.cubeIn;
			case 'cubeinout':        FlxEase.cubeInOut;
			case 'cubeout':          FlxEase.cubeOut;
			case 'elasticin':        FlxEase.elasticIn;
			case 'elasticinout':     FlxEase.elasticInOut;
			case 'elasticout':       FlxEase.elasticOut;
			case 'expoin':           FlxEase.expoIn;
			case 'expoinout':        FlxEase.expoInOut;
			case 'expoout':          FlxEase.expoOut;
			case 'quadin':           FlxEase.quadIn;
			case 'quadinout':        FlxEase.quadInOut;
			case 'quadout':          FlxEase.quadOut;
			case 'quartin':          FlxEase.quartIn;
			case 'quartinout':       FlxEase.quartInOut;
			case 'quartout':         FlxEase.quartOut;
			case 'quintin':          FlxEase.quintIn;
			case 'quintinout':       FlxEase.quintInOut;
			case 'quintout':         FlxEase.quintOut;
			case 'sinein':           FlxEase.sineIn;
			case 'sineinout':        FlxEase.sineInOut;
			case 'sineout':          FlxEase.sineOut;
			case 'smoothstepin':     FlxEase.smoothStepIn;
			case 'smoothstepinout':  FlxEase.smoothStepInOut;
			case 'smoothstepout':    FlxEase.smoothStepOut;
			case 'smootherstepin':   FlxEase.smootherStepIn;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'smootherstepout':  FlxEase.smootherStepOut;
			default:                 FlxEase.linear;
		};
	}

	public static function blendModeFromString(blend:String):BlendMode
	{
		return switch (blend.toLowerCase().trim())
		{
			case 'add':        ADD;
			case 'alpha':      ALPHA;
			case 'darken':     DARKEN;
			case 'difference': DIFFERENCE;
			case 'erase':      ERASE;
			case 'hardlight':  HARDLIGHT;
			case 'invert':     INVERT;
			case 'layer':      LAYER;
			case 'lighten':    LIGHTEN;
			case 'multiply':   MULTIPLY;
			case 'overlay':    OVERLAY;
			case 'screen':     SCREEN;
			case 'shader':     SHADER;
			case 'subtract':   SUBTRACT;
			default:           NORMAL;
		};
	}

	public static function typeToString(type:Int):String
	{
		#if LUA_ALLOWED
		switch (type)
		{
			case Lua.LUA_TBOOLEAN: return 'boolean';
			case Lua.LUA_TNUMBER:  return 'number';
			case Lua.LUA_TSTRING:  return 'string';
			case Lua.LUA_TTABLE:   return 'table';
			case Lua.LUA_TFUNCTION: return 'function';
		}
		if (type <= Lua.LUA_TNIL) return 'nil';
		#end
		return 'unknown';
	}

	public static function cameraFromString(cam:String):FlxCamera
	{
		switch (cam.toLowerCase())
		{
			case 'camgame' | 'game':   return PlayState.instance.camGame;
			case 'camvideo'  | 'video':    return PlayState.instance.camVideo;
			case 'camhud'  | 'hud':    return PlayState.instance.camHUD;
			case 'camother' | 'other': return PlayState.instance.camOther;
		}
		var camera:FlxCamera = MusicBeatState.getVariables().get(cam);
		if (camera == null || !Std.isOfType(camera, FlxCamera)) camera = PlayState.instance.camGame;
		return camera;
	}
}
