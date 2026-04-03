package psychlua;

import flixel.FlxObject;

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua):Void
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, 'openCustomSubstate', openCustomSubstate);
		Lua_helper.add_callback(lua, 'closeCustomSubstate', closeCustomSubstate);
		Lua_helper.add_callback(lua, 'insertToCustomSubstate', insertToCustomSubstate);
	}
	#end

	public static function openCustomSubstate(name:String, pauseGame:Bool = false):Void
	{
		if (pauseGame)
		{
			FlxG.camera.followLerp = 0;
			PlayState.instance.persistentUpdate = false;
			PlayState.instance.persistentDraw = true;
			PlayState.instance.paused = true;
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				PlayState.instance.vocals.pause();
			}
		}
		PlayState.instance.openSubState(new CustomSubstate(name));
	}

	public static function closeCustomSubstate():Bool
	{
		if (instance == null) return false;
		PlayState.instance.closeSubState();
		return true;
	}

	public static function insertToCustomSubstate(tag:String, pos:Int = -1):Bool
	{
		if (instance == null) return false;
		var tagObject:FlxObject = cast MusicBeatState.getVariables().get(tag);
		if (tagObject == null) return false;
		if (pos < 0) instance.add(tagObject);
		else instance.insert(pos, tagObject);
		return true;
	}

	public function new(name:String)
	{
		CustomSubstate.name = name;
		PlayState.instance.setOnHScript('customSubstateName', name);
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function create():Void
	{
		instance = this;
		PlayState.instance.setOnHScript('customSubstate', instance);
		PlayState.instance.callOnScripts('onCustomSubstateCreate', [name]);
		super.create();
		PlayState.instance.callOnScripts('onCustomSubstateCreatePost', [name]);
	}

	override function update(elapsed:Float):Void
	{
		PlayState.instance.callOnScripts('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		PlayState.instance.callOnScripts('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy():Void
	{
		PlayState.instance.callOnScripts('onCustomSubstateDestroy', [name]);
		instance = null;
		name = 'unnamed';
		PlayState.instance.setOnHScript('customSubstate', null);
		PlayState.instance.setOnHScript('customSubstateName', name);
		super.destroy();
	}
}
