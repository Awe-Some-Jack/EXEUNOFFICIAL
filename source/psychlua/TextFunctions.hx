package psychlua;

class TextFunctions
{
	public static function implement(funk:FunkinLua):Void
	{
		var lua = funk.lua;

		LuaUtilsHx.addFunction(lua, 'makeLuaText', function(tag:String, text:String = '', width:Int = 0, x:Float = 0, y:Float = 0) {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leText:FlxText = new FlxText(x, y, width, text, 16);
			var fontPath = Paths.font('vcr.ttf');
			if (fontPath != null) {
				leText.setFormat(fontPath, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
			if (PlayState.instance != null) leText.cameras = [PlayState.instance.camHUD];
			leText.scrollFactor.set();
			leText.borderSize = 2;
			MusicBeatState.getVariables().set(tag, leText);
		});

		inline function getTextObj(tag:String):FlxText
		{
			var split = tag.split('.');
			return split.length > 1
				? LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1])
				: LuaUtils.getObjectDirectly(split[0]);
		}

		LuaUtilsHx.addFunction(lua, 'setTextString', function(tag:String, text:String) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.text = text; return true; }
			FunkinLua.luaTrace('setTextString: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextSize', function(tag:String, size:Int) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.size = size; return true; }
			FunkinLua.luaTrace('setTextSize: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextWidth', function(tag:String, width:Float) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.fieldWidth = width; return true; }
			FunkinLua.luaTrace('setTextWidth: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextHeight', function(tag:String, height:Float) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.fieldHeight = height; return true; }
			FunkinLua.luaTrace('setTextHeight: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextAutoSize', function(tag:String, value:Bool) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.autoSize = value; return true; }
			FunkinLua.luaTrace('setTextAutoSize: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextBorder', function(tag:String, size:Float, color:String, style:String = 'outline') {
			var obj = getTextObj(tag);
			if (obj != null)
			{
				CoolUtil.setTextBorderFromString(obj, size > 0 ? style : 'none');
				if (size > 0) obj.borderSize = size;
				obj.borderColor = CoolUtil.colorFromString(color);
				return true;
			}
			FunkinLua.luaTrace('setTextBorder: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextColor', function(tag:String, color:String) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.color = CoolUtil.colorFromString(color); return true; }
			FunkinLua.luaTrace('setTextColor: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextFont', function(tag:String, newFont:String) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.font = Paths.font(newFont); return true; }
			FunkinLua.luaTrace('setTextFont: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextItalic', function(tag:String, italic:Bool) {
			var obj = getTextObj(tag);
			if (obj != null) { obj.italic = italic; return true; }
			FunkinLua.luaTrace('setTextItalic: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setTextAlignment', function(tag:String, alignment:String = 'left') {
			var obj = getTextObj(tag);
			if (obj != null)
			{
				obj.alignment = switch (alignment.trim().toLowerCase()) {
					case 'right':   RIGHT;
					case 'center':  CENTER;
					case 'justify': JUSTIFY;
					default:        LEFT;
				};
				return true;
			}
			FunkinLua.luaTrace('setTextAlignment: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});

		LuaUtilsHx.addFunction(lua, 'getTextString', function(tag:String) {
			var obj = getTextObj(tag);
			if (obj != null && obj.text != null) return obj.text;
			FunkinLua.luaTrace('getTextString: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return null;
		});
		LuaUtilsHx.addFunction(lua, 'getTextSize', function(tag:String) {
			var obj = getTextObj(tag);
			if (obj != null) return obj.size;
			FunkinLua.luaTrace('getTextSize: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return -1;
		});
		LuaUtilsHx.addFunction(lua, 'getTextFont', function(tag:String) {
			var obj = getTextObj(tag);
			if (obj != null) return obj.font;
			FunkinLua.luaTrace('getTextFont: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return null;
		});
		LuaUtilsHx.addFunction(lua, 'getTextWidth', function(tag:String) {
			var obj = getTextObj(tag);
			if (obj != null) return obj.fieldWidth;
			FunkinLua.luaTrace('getTextWidth: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return 0;
		});

		LuaUtilsHx.addFunction(lua, 'addLuaText', function(tag:String) {
			var text:FlxText = MusicBeatState.getVariables().get(tag);
			if (text != null) LuaUtils.getTargetInstance().add(text);
		});
		LuaUtilsHx.addFunction(lua, 'removeLuaText', function(tag:String, destroy:Bool = true) {
			var variables = MusicBeatState.getVariables();
			var text:FlxText = variables.get(tag);
			if (text == null) return;
			var inst:Dynamic = CustomSubstate.instance != null ? CustomSubstate.instance : LuaUtils.getTargetInstance();
			inst.remove(text, true);
			if (destroy) { text.destroy(); variables.remove(tag); }
		});
	}
}
