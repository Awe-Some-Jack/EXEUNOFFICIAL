package hxluajit.wrapper;

import haxe.Exception;
import hxluajit.Lua;
import hxluajit.Types;

/**
 * Utility class for Lua-Haxe interactions.
 * 
 * @author Mihai Alexandru (MAJigsaw77)
 */
class LuaUtils
{
	/**
	 * Runs a Lua script from a file.
	 * 
	 * @param L The Lua state pointer.
	 * @param path The Lua file path.
	 * @return The script results as a Haxe array.
	 */
	public static function doFile(L:cpp.RawPointer<Lua_State>, path:String):Array<Dynamic>
	{
		final status:Int = LuaL.dofile(L, path);

		if (status != Lua.OK)
		{
			if (LuaError.errorHandler != null)
				LuaError.errorHandler(LuaError.getMessage(L, status));

			return [];
		}

		final args:Array<Dynamic> = [];

		{
			final count:Int = Lua.gettop(L);

			for (i in 0...count)
				args.push(LuaConverter.fromLua(L, i + 1));

			Lua.pop(L, count);
		}

		return args;
	}

	/**
	 * Runs a Lua script from a string.
	 * 
	 * @param L The Lua state pointer.
	 * @param content The Lua script as a string.
	 * @return The script results as a Haxe array.
	 */
	public static function doString(L:cpp.RawPointer<Lua_State>, content:String):Array<Dynamic>
	{
		final status:Int = LuaL.dostring(L, content);

		if (status != Lua.OK)
		{
			if (LuaError.errorHandler != null)
				LuaError.errorHandler(LuaError.getMessage(L, status));

			return [];
		}

		final args:Array<Dynamic> = [];

		{
			final count:Int = Lua.gettop(L);

			for (i in 0...count)
				args.push(LuaConverter.fromLua(L, i + 1));

			Lua.pop(L, count);
		}

		return args;
	}

	/**
	 * Sets a Lua variable.
	 * 
	 * @param L The Lua state pointer.
	 * @param name The variable name or path.
	 * @param value The value to set.
	 */
	public static function setVariable(L:cpp.RawPointer<Lua_State>, name:String, value:Dynamic):Void
	{
		final parts:Array<String> = name.split('.');

		if (parts.length > 1)
		{
			ensureTablePath(L, parts);

			final last:String = parts[parts.length - 1];

			LuaConverter.toLua(L, value);

			Lua.setfield(L, -2, last);

			Lua.pop(L, parts.length);
		}
		else
		{
			LuaConverter.toLua(L, value);

			Lua.setglobal(L, name);
		}
	}

	/**
	 * Gets a Lua variable.
	 * 
	 * @param L The Lua state pointer.
	 * @param name The variable name or path.
	 * @return The variable value.
	 */
	public static function getVariable(L:cpp.RawPointer<Lua_State>, name:String):Dynamic
	{
		final parts:Array<String> = name.split('.');

		Lua.getglobal(L, parts[0]);

		if (Lua.isnil(L, -1) != 0)
		{
			Lua.pop(L, 1);
			return null;
		}

		for (i in 1...parts.length)
		{
			if (Lua.istable(L, -1) == 0)
			{
				Lua.pop(L, 1);
				return null;
			}

			Lua.getfield(L, -1, parts[i]);

			if (Lua.isnil(L, -1) != 0)
			{
				Lua.pop(L, 2);
				return null;
			}

			Lua.remove(L, -2);
		}

		final result:Dynamic = LuaConverter.fromLua(L, -1);

		Lua.pop(L, 1);

		return result;
	}

	/**
	 * Calls a Lua function on the stack.
	 * 
	 * @param L The Lua state pointer.
	 * @param args The function arguments.
	 * @return The function results as a Haxe array.
	 */
	public static function callFunctionWithoutName(L:cpp.RawPointer<Lua_State>, args:Array<Dynamic>):Array<Dynamic>
	{
		for (arg in args)
			LuaConverter.toLua(L, arg);

		final status:Int = Lua.pcall(L, args.length, Lua.MULTRET, 0);

		if (status != Lua.OK)
		{
			if (LuaError.errorHandler != null)
				LuaError.errorHandler(LuaError.getMessage(L, -1));

			return [];
		}

		final args:Array<Dynamic> = [];

		{
			final count:Int = Lua.gettop(L);

			for (i in 0...count)
				args.push(LuaConverter.fromLua(L, i + 1));

			Lua.pop(L, count);
		}

		return args;
	}

	/**
	 * Calls a Lua function by name.
	 * 
	 * @param L The Lua state pointer.
	 * @param name The function name or path.
	 * @param args The function arguments.
	 * @return The function results as a Haxe array.
	 */
	public static function callFunctionByName(L:cpp.RawPointer<Lua_State>, name:String, args:Array<Dynamic>):Array<Dynamic>
	{
		final parts:Array<String> = name.split('.');

		Lua.getglobal(L, parts[0]);

		if (Lua.isnil(L, -1) != 0)
		{
			Lua.pop(L, 1);

			if (LuaError.errorHandler != null)
				LuaError.errorHandler('Function or table "${parts[0]}" not found.');

			return [];
		}

		for (i in 1...parts.length)
		{
			if (Lua.istable(L, -1) != 0)
			{
				Lua.getfield(L, -1, parts[i]);
				Lua.remove(L, -2);
			}
			else
			{
				Lua.pop(L, 1);

				if (LuaError.errorHandler != null)
					LuaError.errorHandler('Invalid function path: "$name"');

				return [];
			}
		}

		if (Lua.isfunction(L, -1) == 0)
		{
			Lua.pop(L, 1);

			if (LuaError.errorHandler != null)
				LuaError.errorHandler('"${name}" is not a function.');

			return [];
		}

		for (arg in args)
			LuaConverter.toLua(L, arg);

		final status:Int = Lua.pcall(L, args.length, Lua.MULTRET, 0);

		if (status != Lua.OK)
		{
			if (LuaError.errorHandler != null)
				LuaError.errorHandler(LuaError.getMessage(L, -1));

			return [];
		}

		final args:Array<Dynamic> = [];

		{
			final count:Int = Lua.gettop(L);

			for (i in 0...count)
				args.push(LuaConverter.fromLua(L, i + 1));

			Lua.pop(L, count);
		}

		return args;
	}

	@:noCompletion
	private static function ensureTablePath(L:cpp.RawPointer<Lua_State>, parts:Array<String>):Void
	{
		Lua.getglobal(L, parts[0]);

		if (Lua.istable(L, -1) == 0)
		{
			Lua.pop(L, 1);
			Lua.newtable(L);
			Lua.setglobal(L, parts[0]);
			Lua.getglobal(L, parts[0]);
		}

		for (i in 1...parts.length - 1)
		{
			Lua.getfield(L, -1, parts[i]);

			if (Lua.istable(L, -1) == 0)
			{
				Lua.pop(L, 1);
				Lua.newtable(L);
				Lua.setfield(L, -2, parts[i]);
				Lua.getfield(L, -1, parts[i]);
			}
		}
	}

	@:noCompletion
	private static final functionIds:Map<cpp.RawPointer<Lua_State>, Map<String, Int>> = [];

	// Functions are called by numeric id (stored as the closure's upvalue) so a call needs no string conversion or map lookups.
	@:noCompletion
	private static final functionList:Array<Dynamic> = [];

	@:noCompletion
	private static final functionNames:Array<Null<String>> = [];

	@:noCompletion
	private static final freeFunctionIds:Array<Int> = [];

	/**
	 * Registers a Haxe function in Lua.
	 * 
	 * @param L The Lua state pointer.
	 * @param name The function name in Lua.
	 * @param fn The Haxe function.
	 */
	public static function addFunction(L:cpp.RawPointer<Lua_State>, name:String, fn:Dynamic):Void
	{
		var ids = functionIds.get(L);

		if (ids == null)
		{
			ids = [];
			functionIds.set(L, ids);
		}

		final existing:Null<Int> = ids.get(name);
		var id:Int;

		if (existing != null)
			id = existing;
		else
		{
			final recycled:Null<Int> = freeFunctionIds.pop();
			id = recycled != null ? recycled : functionList.length;
			ids.set(name, id);
		}

		functionList[id] = fn;
		functionNames[id] = name;

		final parts:Array<String> = name.split('.');

		if (parts.length > 1)
		{
			ensureTablePath(L, parts);

			final last:String = parts[parts.length - 1];

			Lua.pushinteger(L, id);
			Lua.pushcclosure(L, cpp.Function.fromStaticFunction(functionHandler), 1);

			Lua.setfield(L, -2, last);

			Lua.pop(L, parts.length);
		}
		else
		{
			Lua.pushinteger(L, id);
			Lua.pushcclosure(L, cpp.Function.fromStaticFunction(functionHandler), 1);
			Lua.setglobal(L, name);
		}
	}

	/**
	 * Removes all registered functions for a Lua state.
	 * 
	 * @param L The Lua state pointer.
	 */
	public static function cleanupStateFunctions(L:cpp.RawPointer<Lua_State>):Void
	{
		final ids = functionIds.get(L);

		if (ids != null)
		{
			for (id in ids)
			{
				functionList[id] = null;
				functionNames[id] = null;
				freeFunctionIds.push(id);
			}

			functionIds.remove(L);
		}
	}

	@:noCompletion
	private static function functionHandler(L:cpp.RawPointer<Lua_State>):Int
	{
		final id:Int = cast Lua.tointeger(L, Lua.upvalueindex(1));

		final count:Int = Lua.gettop(L);
		final args:Array<Dynamic> = [];

		if (count > 0)
		{
			args.resize(count);

			for (i in 0...count)
				args[i] = LuaConverter.fromLua(L, i + 1);
		}

		try
		{
			@:nullSafety(Off)
			final ret:Dynamic = Reflect.callMethod(null, functionList[id], args);

			if (ret != null)
			{
				LuaConverter.toLua(L, ret);
				return 1;
			}
		}
		catch (e:Exception)
			LuaL.error(L, 'Error executing function "${functionNames[id] ?? "?"}": ${e.toString()}');

		return 0;
	}
}
