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
    PlayState.instance.closeOpponentStrumGap = true;
}

function onCreatePost() 
{
    if(!ClientPrefs.data.middleScroll) comboGroup.y += 100 * (ClientPrefs.data.downScroll ? -1 : 1);
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

function onEvent(n,v1)
{
    if (n == 'substantialEvent')
    {
        switch(v1)
        {
            case 'fullscreen':
                PlayState.canPause = true;
                var daWindow = Lib.application.window;
                PlayState.tweenWindow(daWindow.stage.fullScreenWidth + 1, daWindow.stage.fullScreenHeight + 1, 0, 0, Conductor.crochet / (1000 / 4), FlxEase.cubeInOut, () -> PlayState.fullscreenLetterbox());
        }
    }
}

function onGameOverConfirm(retry)
{
    if (retry) isRestarting = true;
}