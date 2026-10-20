package psychlua;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
import backend.FilterPruner;
#end

class ShaderFunctions
{
	public static function implement(funk:FunkinLua):Void
	{
		var lua = funk.lua;

		funk.addLocalCallback('initLuaShader', function(name:String, ?force:Bool = false) {
			if (!ClientPrefs.data.shaders && !force) return false;
			#if (!flash && MODS_ALLOWED && sys)
			return funk.initLuaShader(name, force);
			#else
			FunkinLua.luaTrace('initLuaShader: Platform unsupported for Runtime Shaders!', false, false, FlxColor.RED);
			return false;
			#end
		});

		funk.addLocalCallback('setSpriteShader', function(obj:String, shader:String, ?force:Bool = false) {
			if (!ClientPrefs.data.shaders && !force) return false;
			#if (!flash && sys)
			if (!funk.runtimeShaders.exists(shader) && !funk.initLuaShader(shader, force))
			{
				FunkinLua.luaTrace('setSpriteShader: Shader $shader is missing!', false, false, FlxColor.RED);
				return false;
			}
			var leObj = _resolveSprite(obj);
			if (leObj != null)
			{
				var arr = funk.runtimeShaders.get(shader);
				leObj.shader = new shaders.ErrorHandledShader.ErrorHandledRuntimeShader(shader, arr[0], arr[1]);
				return true;
			}
			#else
			FunkinLua.luaTrace('setSpriteShader: Platform unsupported for Runtime Shaders!', false, false, FlxColor.RED);
			#end
			return false;
		});

		LuaUtilsHx.addFunction(lua, 'removeSpriteShader', function(obj:String) {
			var leObj = _resolveSprite(obj);
			if (leObj != null) { leObj.shader = null; return true; }
			return false;
		});

		#if (!flash && MODS_ALLOWED && sys)
		_addShaderGet(lua, 'getShaderBool',       (s, p) -> s.getBool(p));
		_addShaderGet(lua, 'getShaderBoolArray',  (s, p) -> s.getBoolArray(p));
		_addShaderGet(lua, 'getShaderInt',        (s, p) -> s.getInt(p));
		_addShaderGet(lua, 'getShaderIntArray',   (s, p) -> s.getIntArray(p));
		_addShaderGet(lua, 'getShaderFloat',      (s, p) -> s.getFloat(p));
		_addShaderGet(lua, 'getShaderFloatArray', (s, p) -> s.getFloatArray(p));

		_addShaderSet(lua, 'setShaderBool',       (s, p, v) -> s.setBool(p, v));
		_addShaderSet(lua, 'setShaderBoolArray',  (s, p, v) -> s.setBoolArray(p, v));
		_addShaderSet(lua, 'setShaderInt',        (s, p, v) -> s.setInt(p, v));
		_addShaderSet(lua, 'setShaderIntArray',   (s, p, v) -> s.setIntArray(p, v));
		_addShaderSet(lua, 'setShaderFloat',      (s, p, v) -> { s.setFloat(p, v); FilterPruner.onSet(s, p); });
		_addShaderSet(lua, 'setShaderFloatArray', (s, p, v) -> s.setFloatArray(p, v));

		LuaUtilsHx.addFunction(lua, 'addPrunedFilter', function(cam:String, obj:String, uniform:String, neutral:Dynamic) {
			var shader = getShader(obj);
			if (shader == null) return false;
			var neutralValue:Float = neutral;
			FilterPruner.add(LuaUtils.cameraFromString(cam), shader, uniform, neutralValue);
			return true;
		});

		LuaUtilsHx.addFunction(lua, 'setCameraFilterScale', function(cam:String, scale:Float) {
			FilterPruner.setResolutionScale(LuaUtils.cameraFromString(cam), scale);
		});

		LuaUtilsHx.addFunction(lua, 'addStaticFilter', function(cam:String, obj:String) {
			var shader = getShader(obj);
			if (shader == null) return false;
			FilterPruner.addStatic(LuaUtils.cameraFromString(cam), shader);
			return true;
		});

		LuaUtilsHx.addFunction(lua, 'setShaderSampler2D', function(obj:String, prop:String, bitmapdataPath:String) {
			#if (!flash && MODS_ALLOWED && sys)
			var shader = getShader(obj);
			if (shader == null) { FunkinLua.luaTrace('setShaderSampler2D: Shader is not FlxRuntimeShader!', false, false, FlxColor.RED); return false; }
			var value = Paths.image(bitmapdataPath);
			if (value != null && value.bitmap != null) { shader.setSampler2D(prop, value.bitmap); return true; }
			return false;
			#else
			FunkinLua.luaTrace('setShaderSampler2D: Platform unsupported for Runtime Shaders!', false, false, FlxColor.RED);
			return false;
			#end
		});
		#else
		for (name in ['getShaderBool', 'getShaderBoolArray', 'getShaderInt', 'getShaderIntArray', 'getShaderFloat', 'getShaderFloatArray'])
			LuaUtilsHx.addFunction(lua, name, function(obj:String, prop:String) {
				FunkinLua.luaTrace('$name: Platform unsupported for Runtime Shaders!', false, false, FlxColor.RED);
				return null;
			});
		for (name in ['setShaderBool', 'setShaderBoolArray', 'setShaderInt', 'setShaderIntArray', 'setShaderFloat', 'setShaderFloatArray', 'setShaderSampler2D'])
			LuaUtilsHx.addFunction(lua, name, function(obj:String, prop:String, value:Dynamic) {
				FunkinLua.luaTrace('$name: Platform unsupported for Runtime Shaders!', false, false, FlxColor.RED);
				return false;
			});
		#end
	}

	static function _resolveSprite(obj:String):FlxSprite
	{
		var split = obj.split('.');
		if (split.length > 1) return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
		return LuaUtils.getObjectDirectly(split[0]);
	}

	#if (!flash && MODS_ALLOWED && sys)
	static inline function _addShaderGet(lua:Null<RawPointer<Lua_State>>, name:String, fn:FlxRuntimeShader->String->Dynamic):Void
	{
		LuaUtilsHx.addFunction(lua, name, function(obj:String, prop:String) {
			var shader = getShader(obj);
			if (shader == null) { FunkinLua.luaTrace('$name: Shader is not FlxRuntimeShader!', false, false, FlxColor.RED); return null; }
			return fn(shader, prop);
		});
	}

	static inline function _addShaderSet(lua:Null<RawPointer<Lua_State>>, name:String, fn:FlxRuntimeShader->String->Dynamic->Void):Void
	{
		LuaUtilsHx.addFunction(lua, name, function(obj:String, prop:String, value:Dynamic) {
			var shader = getShader(obj);
			if (shader == null) { FunkinLua.luaTrace('$name: Shader is not FlxRuntimeShader!', false, false, FlxColor.RED); return false; }
			fn(shader, prop, value);
			return true;
		});
	}

	public static function getShader(obj:String):FlxRuntimeShader
	{
		var target = _resolveSprite(obj);
		if (target == null)
		{
			FunkinLua.luaTrace('Error on getting shader: Object $obj not found', false, false, FlxColor.RED);
			return null;
		}
		return cast (target.shader, FlxRuntimeShader);
	}
	#end
}
