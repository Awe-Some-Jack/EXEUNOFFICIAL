import openfl.Lib;
import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import states.substates.PauseSubState;

var window:Dynamic;
var isRestarting:Bool = false;
var luaCallback:Dynamic = null;

function onCreate()
{
	window = Lib.application.window;
	if (!PlayState.firstPlay)
	{
		FlxG.fullscreen = false;
		window.resizable = false;
		FlxG.scaleMode = new RatioScaleMode(true);
		window.width = 960;
		window.height = 720;
		window.x += (1280 - 960) / 2;
		FlxG.width = 960;
		FlxG.game.x = 0;
		for (cam in FlxG.cameras.list) cam.width = 960;
	}
}

function onCreatePost()
{
	comboGroup.y -= 100;
}

var oldFullscreen:Bool = false;
function onUpdate(elapsed:Float)
{
	if (oldFullscreen != FlxG.fullscreen)
	{
		FlxG.width = 960;
		if (FlxG.fullscreen)  FlxG.game.x = (1280 - 960) * 0.75;
		else FlxG.game.x = 0;
		oldFullscreen = FlxG.fullscreen;
	}
}

function onDestroy()
{
	if (luaCallback != null) {
		FlxG.signals.postUpdate.remove(luaCallback);
		setVar('luaCallback', null);
		luaCallback = null;
	}

	if (isRestarting) return;
	window.x -= (1280 - 960) / 2;
	window.width = 1280;
	window.height = 720;
	FlxG.scaleMode = new RatioScaleMode();
	window.resizable = true;
}

function onPause()
{
	luaCallback = () -> { if (FlxG.state != null && FlxG.state.subState != null) {
		var subState = FlxG.state.subState;
		isRestarting = (subState.curSelected == 1);
	}};
	setVar('luaCallback', luaCallback);
	FlxG.signals.postUpdate.add(luaCallback);
}

function onResume()
{
	if (luaCallback != null) {
		FlxG.signals.postUpdate.remove(luaCallback);
		setVar('luaCallback', null);
		luaCallback = null;
	}
}

function onGameOverConfirm(retry)
{
	if (retry) isRestarting = true;
}