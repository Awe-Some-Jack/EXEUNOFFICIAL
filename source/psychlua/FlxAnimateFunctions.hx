#if (LUA_ALLOWED && flixel_animate)
package psychlua;

import openfl.utils.Assets;
import backend.Paths;

import animate.FlxAnimate;

class FlxAnimateFunctions
{
	public static function implement(funk:FunkinLua):Void
	{
		var lua:Null<RawPointer<Lua_State>> = funk.lua;

		LuaUtilsHx.addFunction(lua, 'makeFlxAnimateSprite', function(tag:String, x:Float = 0, y:Float = 0, loadFolder:String = null) {
			tag = tag.replace('.', '');
			var lastSprite = MusicBeatState.getVariables().get(tag);
			if (lastSprite != null)
			{
				lastSprite.kill();
				PlayState.instance.remove(lastSprite);
				lastSprite.destroy();
			}
			var mySprite:ModchartAnimateSprite = new ModchartAnimateSprite(x, y);
			if (loadFolder != null) mySprite.frames = Paths.getAnimateAtlas(loadFolder);
			MusicBeatState.getVariables().set(tag, mySprite);
			mySprite.active = true;
		});

		LuaUtilsHx.addFunction(lua, 'loadAnimateAtlas', function(tag:String, folderOrImg:String, spriteJson:String = null, animationJson:String = null) {
			var spr:animate.FlxAnimate = MusicBeatState.getVariables().get(tag);
			if (spr != null) spr.frames = Paths.getAnimateAtlas(folderOrImg);
		});

		LuaUtilsHx.addFunction(lua, 'addAnimationBySymbol', function(tag:String, name:String, symbol:String, framerate:Float = 24, loop:Bool = false) {
			var obj:animate.FlxAnimate = cast MusicBeatState.getVariables().get(tag);
			if (obj == null) return false;
			
			obj.anim.addBySymbol(name, symbol, framerate, loop);
			
			var obj2:ModchartAnimateSprite = cast obj;
			if (obj2 != null) obj2.playAnim(name, true);
			else obj.anim.play(name, true);
			
			return true;
		});

		LuaUtilsHx.addFunction(lua, 'addAnimationBySymbolIndices', function(tag:String, name:String, symbol:String, indices:Any = null, framerate:Float = 24, loop:Bool = false) {
			var obj:animate.FlxAnimate = cast MusicBeatState.getVariables().get(tag);
			if (obj == null) return false;

			if (indices == null)
				indices = [0];
			else if (Std.isOfType(indices, String))
			{
				var strIndices:Array<String> = cast (indices, String).trim().split(',');
				indices = strIndices.map(s -> Std.parseInt(s));
			}

			obj.anim.addBySymbolIndices(name, symbol, indices, framerate, loop);
			
			var obj2:ModchartAnimateSprite = cast obj;
			if (obj2 != null) obj2.playAnim(name, true);
			else obj.anim.play(name, true);
			
			return true;
		});
	}
}
#end