import flixel.FlxG;
import backend.Controls;
import openfl.Lib;

var isRestarting:Bool = false;
var luaCallback:Dynamic = null;

function onCreate()
{
    if (!PlayState.firstPlay) 
    {
        PlayState.hasRestarted = false;
    }
    PlayState.isLetterboxedAspectRatio = true;
}

function onCreatePost() 
{
    comboGroup.y += 100 * (ClientPrefs.data.downScroll ? -1 : 1);
}

function onDestroy()
{
    if (luaCallback != null) {
        FlxG.signals.postUpdate.remove(luaCallback);
        setVar('luaCallback', null);
        luaCallback = null;
    }

    if (isRestarting) return;

    PlayState.isLetterboxedAspectRatio = false;
}

var canCheck:Bool = true;
function onPause()
{
    canCheck = true;
    luaCallback = () -> { if (FlxG.state?.subState != null) {
        var subState = FlxG.state.subState;
        if (canCheck) {
            isRestarting = (subState.curSelected == 1);
            if (Controls.instance.ACCEPT) canCheck = false;
        }
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