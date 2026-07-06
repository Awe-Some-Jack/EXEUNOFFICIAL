import flixel.FlxG;
import backend.Controls;
import openfl.Lib;

var isRestarting:Bool = false;
var luaCallback:Dynamic = null;

function onCreate()
{
    if (!PlayState.firstPlay) 
    {
        PlayState.isFixedAspectRatio = true;
    }
}

function onCreatePost() 
{
    comboGroup.y -= 100;
}

function onDestroy()
{
    if (luaCallback != null) {
        FlxG.signals.postUpdate.remove(luaCallback);
        setVar('luaCallback', null);
        luaCallback = null;
    }

    if (isRestarting) return;
    
    PlayState.isFixedAspectRatio = false;
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
                FlxTween.tween(daWindow, {width: daWindow.stage.fullScreenWidth + 1, height: daWindow.stage.fullScreenHeight + 1, x: 0, y: 0}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
        }
    }
}

function onGameOverConfirm(retry)
{
    if (retry) isRestarting = true;
}