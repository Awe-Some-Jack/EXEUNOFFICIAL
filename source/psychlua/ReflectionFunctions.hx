package psychlua;

import Type.ValueType;
import haxe.Constraints;

import substates.GameOverSubstate;

class ReflectionFunctions
{
	static final instanceStr:Dynamic = '##PSYCHLUA_STRINGTOOBJ';

	public static function implement(funk:FunkinLua):Void
	{
		var lua:State = funk.lua;

		Lua_helper.add_callback(lua, 'getProperty', function(variable:String, allowMaps:Bool = false) {
			var split = variable.split('.');
			if (split.length > 1) return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length - 1], allowMaps);
			return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
		});

		Lua_helper.add_callback(lua, 'setProperty', function(variable:String, value:Dynamic, allowMaps:Bool = false, allowInstances:Bool = false) {
			var val = allowInstances ? parseInstances(value) : value;
			var split = variable.split('.');
			if (split.length > 1) { LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length - 1], val, allowMaps); return value; }
			LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, val, allowMaps);
			return value;
		});

		Lua_helper.add_callback(lua, 'getPropertyFromClass', function(classVar:String, variable:String, allowMaps:Bool = false) {
			var myClass:Dynamic = Type.resolveClass(classVar);
			if (myClass == null) { FunkinLua.luaTrace('getPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED); return null; }
			var split = variable.split('.');
			if (split.length > 1)
			{
				var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
				for (i in 1...split.length - 1) obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);
				return LuaUtils.getVarInArray(obj, split[split.length - 1], allowMaps);
			}
			return LuaUtils.getVarInArray(myClass, variable, allowMaps);
		});

		Lua_helper.add_callback(lua, 'setPropertyFromClass', function(classVar:String, variable:String, value:Dynamic, allowMaps:Bool = false, allowInstances:Bool = false) {
			var myClass:Dynamic = Type.resolveClass(classVar);
			if (myClass == null) { FunkinLua.luaTrace('setPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED); return null; }
			var val = allowInstances ? parseInstances(value) : value;
			var split = variable.split('.');
			if (split.length > 1)
			{
				var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
				for (i in 1...split.length - 1) obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);
				LuaUtils.setVarInArray(obj, split[split.length - 1], val, allowMaps);
				return value;
			}
			LuaUtils.setVarInArray(myClass, variable, val, allowMaps);
			return value;
		});

		Lua_helper.add_callback(lua, 'getPropertyFromGroup', function(group:String, index:Int, variable:Dynamic, allowMaps:Bool = false) {
			var split = group.split('.');
			var realObject:Dynamic = split.length > 1
				? LuaUtils.getPropertyLoop(split, false, allowMaps)
				: Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (groupOrArray != null)
			{
				switch (Type.typeof(groupOrArray))
				{
					case TClass(Array):
						var leArray:Dynamic = realObject[index];
						if (leArray != null)
						{
							return Type.typeof(variable) == ValueType.TInt
								? leArray[variable]
								: LuaUtils.getGroupStuff(leArray, variable, allowMaps);
						}
						FunkinLua.luaTrace('getPropertyFromGroup: Object #$index from group: $group doesn\'t exist!', false, false, FlxColor.RED);
					default:
						return LuaUtils.getGroupStuff(realObject.members[index], variable, allowMaps);
				}
			}
			FunkinLua.luaTrace('getPropertyFromGroup: Group/Array $group doesn\'t exist!', false, false, FlxColor.RED);
			return null;
		});

		Lua_helper.add_callback(lua, 'setPropertyFromGroup', function(group:String, index:Int, variable:Dynamic, value:Dynamic, allowMaps:Bool = false, allowInstances:Bool = false) {
			var split = group.split('.');
			var realObject:Dynamic = split.length > 1
				? LuaUtils.getPropertyLoop(split, false, allowMaps)
				: Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			if (realObject != null)
			{
				var val = allowInstances ? parseInstances(value) : value;
				switch (Type.typeof(realObject))
				{
					case TClass(Array):
						var leArray:Dynamic = realObject[index];
						if (leArray != null)
						{
							if (Type.typeof(variable) == ValueType.TInt) leArray[variable] = val;
							else LuaUtils.setGroupStuff(leArray, variable, val, allowMaps);
						}
					default:
						LuaUtils.setGroupStuff(realObject.members[index], variable, val, allowMaps);
				}
			}
			else FunkinLua.luaTrace('setPropertyFromGroup: Group/Array $group doesn\'t exist!', false, false, FlxColor.RED);
			return value;
		});

		Lua_helper.add_callback(lua, 'addToGroup', function(group:String, tag:String, index:Int = -1) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
			if (obj == null || obj.destroy == null) { FunkinLua.luaTrace('addToGroup: Object $tag is not valid!', false, false, FlxColor.RED); return; }
			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (groupOrArray == null) { FunkinLua.luaTrace('addToGroup: Group/Array $group is not valid!', false, false, FlxColor.RED); return; }
			if (index < 0)
			{
				switch (Type.typeof(groupOrArray)) { case TClass(Array): groupOrArray.push(obj); default: groupOrArray.add(obj); }
			}
			else groupOrArray.insert(index, obj);
		});

		Lua_helper.add_callback(lua, 'removeFromGroup', function(group:String, index:Int = -1, tag:String = null, destroy:Bool = true) {
			var obj:FlxSprite = null;
			if (tag != null)
			{
				obj = LuaUtils.getObjectDirectly(tag);
				if (obj == null || obj.destroy == null) { FunkinLua.luaTrace('removeFromGroup: Object $tag is not valid!', false, false, FlxColor.RED); return; }
			}
			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (groupOrArray == null) { FunkinLua.luaTrace('removeFromGroup: Group/Array $group is not valid!', false, false, FlxColor.RED); return; }
			switch (Type.typeof(groupOrArray))
			{
				case TClass(Array):
					if (obj != null) { groupOrArray.remove(obj); if (destroy) obj.destroy(); }
					else groupOrArray.remove(groupOrArray[index]);
				default:
					if (obj == null) obj = groupOrArray.members[index];
					groupOrArray.remove(obj, true);
					if (destroy) obj.destroy();
			}
		});

		Lua_helper.add_callback(lua, 'callMethod', function(funcToRun:String, args:Array<Dynamic> = null) {
			var parent:Dynamic = PlayState.instance;
			var split = funcToRun.split('.');
			var varParent:Dynamic = MusicBeatState.getVariables().get(split[0].trim());
			if (varParent != null) { split.shift(); funcToRun = split.join('.').trim(); parent = varParent; }
			if (funcToRun.length > 0) return callMethodFromObject(parent, funcToRun, parseInstances(args));
			return Reflect.callMethod(null, parent, parseInstances(args));
		});

		Lua_helper.add_callback(lua, 'callMethodFromClass', function(className:String, funcToRun:String, args:Array<Dynamic> = null) {
			return callMethodFromObject(Type.resolveClass(className), funcToRun, parseInstances(args));
		});

		Lua_helper.add_callback(lua, 'createInstance', function(variableToSave:String, className:String, args:Array<Dynamic> = null) {
			if (!Std.isOfType(args, Array)) args = [];
			variableToSave = variableToSave.trim().replace('.', '');
			if (MusicBeatState.getVariables().get(variableToSave) != null)
			{
				FunkinLua.luaTrace('createInstance: Variable $variableToSave is already being used and cannot be replaced!', false, false, FlxColor.RED);
				return false;
			}
			var myType:Dynamic = Type.resolveClass(className);
			if (myType == null) { FunkinLua.luaTrace('createInstance: Class $className not found', false, false, FlxColor.RED); return false; }
			var obj:Dynamic = Type.createInstance(myType, parseInstances(args ?? []));
			if (obj != null) MusicBeatState.getVariables().set(variableToSave, obj);
			else FunkinLua.luaTrace('createInstance: Failed to create $variableToSave, arguments are possibly wrong.', false, false, FlxColor.RED);
			return obj != null;
		});

		Lua_helper.add_callback(lua, 'addInstance', function(objectName:String, inFront:Bool = false) {
			var savedObj:Dynamic = MusicBeatState.getVariables().get(objectName);
			if (savedObj == null) { FunkinLua.luaTrace('addInstance: Can\'t add what doesn\'t exist~ ($objectName)', false, false, FlxColor.RED); return; }
			if (inFront)
				LuaUtils.getTargetInstance().add(savedObj);
			else
			{
				if (!PlayState.instance.isDead)
					PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), savedObj);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), savedObj);
			}
		});

		Lua_helper.add_callback(lua, 'instanceArg', function(instanceName:String, className:String = null) {
			var retStr = '$instanceStr::$instanceName';
			if (className != null) retStr += '::$className';
			return retStr;
		});
	}

	static function parseInstanceArray(arg:Array<Dynamic>):Array<Dynamic>
		return arg.map(v -> parseInstances(v));

	public static function parseInstances(arg:Dynamic):Dynamic
	{
		if (arg == null) return null;
		return Std.isOfType(arg, Array) ? parseInstanceArray(arg) : parseSingleInstance(arg);
	}

	public static function parseSingleInstance(arg:Dynamic):Dynamic
	{
		var argStr:String = cast arg;
		if (argStr != null && argStr.length > instanceStr.length)
		{
			var index:Int = argStr.indexOf('::');
			if (index > -1)
			{
				argStr = argStr.substring(index + 2);
				var lastIndex:Int = argStr.lastIndexOf('::');
				var split:Array<String> = (lastIndex > -1) ? argStr.substring(0, lastIndex).split('.') : argStr.split('.');
				arg = (lastIndex > -1) ? Type.resolveClass(argStr.substring(lastIndex + 2)) : PlayState.instance;
				for (j in 0...split.length)
					arg = LuaUtils.getVarInArray(arg, split[j].trim());
			}
		}
		return arg;
	}

	static function callMethodFromObject(classObj:Dynamic, funcStr:String, args:Array<Dynamic>):Dynamic
	{
		if (classObj == null) return null;
		var split = funcStr.split('.');
		var obj:Dynamic = classObj;
		for (part in split) obj = LuaUtils.getVarInArray(obj, part.trim());
		var funcToRun:Function = cast obj;
		return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
	}
}
