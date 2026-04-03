package psychlua;

class DeprecatedFunctions
{
	public static function implement(funk:FunkinLua):Void
	{
		var lua:State = funk.lua;

		Lua_helper.add_callback(lua, 'addAnimationByIndicesLoop', function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			FunkinLua.luaTrace('addAnimationByIndicesLoop is deprecated! Use addAnimationByIndices instead', false, true);
			return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, true);
		});

		Lua_helper.add_callback(lua, 'objectPlayAnimation', function(obj:String, name:String, forced:Bool = false, startFrame:Int = 0) {
			FunkinLua.luaTrace('objectPlayAnimation is deprecated! Use playAnim instead', false, true);
			var luaObj = PlayState.instance.getLuaObject(obj);
			if (luaObj != null)
			{
				luaObj.animation.play(name, forced, false, startFrame);
				return true;
			}
			var spr:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
			if (spr != null)
			{
				spr.animation.play(name, forced, false, startFrame);
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, 'characterPlayAnim', function(character:String, anim:String, forced:Bool = false) {
			FunkinLua.luaTrace('characterPlayAnim is deprecated! Use playAnim instead', false, true);
			switch (character.toLowerCase())
			{
				case 'dad':
					if (PlayState.instance.dad.hasAnimation(anim))
						PlayState.instance.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if (PlayState.instance.gf != null && PlayState.instance.gf.hasAnimation(anim))
						PlayState.instance.gf.playAnim(anim, forced);
				default:
					if (PlayState.instance.boyfriend.hasAnimation(anim))
						PlayState.instance.boyfriend.playAnim(anim, forced);
			}
		});

		Lua_helper.add_callback(lua, 'luaSpriteMakeGraphic', function(tag:String, width:Int, height:Int, color:String) {
			FunkinLua.luaTrace('luaSpriteMakeGraphic is deprecated! Use makeGraphic instead', false, true);
			var obj = MusicBeatState.getVariables().get(tag);
			if (obj != null) obj.makeGraphic(width, height, CoolUtil.colorFromString(color));
		});

		Lua_helper.add_callback(lua, 'luaSpriteAddAnimationByPrefix', function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			FunkinLua.luaTrace('luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead', false, true);
			var spr:ModchartSprite = MusicBeatState.getVariables().get(tag);
			if (spr != null)
			{
				spr.animation.addByPrefix(name, prefix, framerate, loop);
				if (spr.animation.curAnim == null) spr.animation.play(name, true);
			}
		});

		Lua_helper.add_callback(lua, 'luaSpriteAddAnimationByIndices', function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			FunkinLua.luaTrace('luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead', false, true);
			var spr:ModchartSprite = MusicBeatState.getVariables().get(tag);
			if (spr != null)
			{
				var parsed:Array<Int> = indices.trim().split(',').map(s -> Std.parseInt(s));
				spr.animation.addByIndices(name, prefix, parsed, '', framerate, false);
				if (spr.animation.curAnim == null) spr.animation.play(name, true);
			}
		});

		Lua_helper.add_callback(lua, 'luaSpritePlayAnimation', function(tag:String, name:String, forced:Bool = false) {
			FunkinLua.luaTrace('luaSpritePlayAnimation is deprecated! Use playAnim instead', false, true);
			var obj = MusicBeatState.getVariables().get(tag);
			if (obj != null) obj.animation.play(name, forced);
		});

		Lua_helper.add_callback(lua, 'setLuaSpriteCamera', function(tag:String, camera:String = '') {
			FunkinLua.luaTrace('setLuaSpriteCamera is deprecated! Use setObjectCamera instead', false, true);
			var obj = MusicBeatState.getVariables().get(tag);
			if (obj != null)
			{
				obj.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			FunkinLua.luaTrace('Lua sprite with tag: $tag doesn\'t exist!');
			return false;
		});

		Lua_helper.add_callback(lua, 'setLuaSpriteScrollFactor', function(tag:String, scrollX:Float, scrollY:Float) {
			FunkinLua.luaTrace('setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead', false, true);
			var obj = MusicBeatState.getVariables().get(tag);
			if (obj != null)
			{
				obj.scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, 'scaleLuaSprite', function(tag:String, x:Float, y:Float) {
			FunkinLua.luaTrace('scaleLuaSprite is deprecated! Use scaleObject instead', false, true);
			var spr:ModchartSprite = MusicBeatState.getVariables().get(tag);
			if (spr != null)
			{
				spr.scale.set(x, y);
				spr.updateHitbox();
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, 'getPropertyLuaSprite', function(tag:String, variable:String) {
			FunkinLua.luaTrace('getPropertyLuaSprite is deprecated! Use getProperty instead', false, true);
			var obj = MusicBeatState.getVariables().get(tag);
			if (obj != null)
			{
				var parts = variable.split('.');
				if (parts.length > 1)
				{
					var cur:Dynamic = Reflect.getProperty(obj, parts[0]);
					for (i in 1...parts.length - 1) cur = Reflect.getProperty(cur, parts[i]);
					return Reflect.getProperty(cur, parts[parts.length - 1]);
				}
				return Reflect.getProperty(obj, variable);
			}
			return null;
		});

		Lua_helper.add_callback(lua, 'setPropertyLuaSprite', function(tag:String, variable:String, value:Dynamic) {
			FunkinLua.luaTrace('setPropertyLuaSprite is deprecated! Use setProperty instead', false, true);
			var obj = MusicBeatState.getVariables().get(tag);
			if (obj != null)
			{
				var parts = variable.split('.');
				if (parts.length > 1)
				{
					var cur:Dynamic = Reflect.getProperty(obj, parts[0]);
					for (i in 1...parts.length - 1) cur = Reflect.getProperty(cur, parts[i]);
					Reflect.setProperty(cur, parts[parts.length - 1], value);
					return true;
				}
				Reflect.setProperty(obj, variable, value);
				return true;
			}
			FunkinLua.luaTrace('setPropertyLuaSprite: Lua sprite with tag: $tag doesn\'t exist!');
			return false;
		});

		Lua_helper.add_callback(lua, 'musicFadeIn', function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			FunkinLua.luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);
		});

		Lua_helper.add_callback(lua, 'musicFadeOut', function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			FunkinLua.luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
		});

		Lua_helper.add_callback(lua, 'updateHitboxFromGroup', function(group:String, index:Int) {
			FunkinLua.luaTrace('updateHitboxFromGroup is deprecated! Use updateHitbox instead.', false, true);
			var prop:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (Std.isOfType(prop, FlxTypedGroup))
				(prop : FlxTypedGroup<Dynamic>).members[index].updateHitbox();
			else
				(prop : Array<Dynamic>)[index].updateHitbox();
		});
	}
}
