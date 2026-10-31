import flixel.FlxG;
import backend.Controls;

final isMobile:Bool = (buildTarget == 'ios' || buildTarget == 'android');

var isRestarting:Bool = false;
var luaCallback:Dynamic = null;

function onCreate()
{
    if (isMobile) return;
    if (!PlayState.firstPlay) 
    {
        PlayState.hasRestarted = false;
    }
    PlayState.isFixedAspectRatio = true;
    PlayState.instance.closeOpponentStrumGap = true;
}

function onCreatePost() 
{
    if (isMobile) return;
    if(!ClientPrefs.data.middleScroll) comboGroup.y += 100 * (ClientPrefs.data.downScroll ? -1 : 1);
}

function onDestroy()
{
    if (isMobile) return;
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
    if (isMobile) return;
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
    if (isMobile) return;
    if (luaCallback != null) {
        FlxG.signals.postUpdate.remove(luaCallback);
        setVar('luaCallback', null);
        luaCallback = null;
    }
}

function onGameOverConfirm(retry)
{
    if (isMobile) return;
    if (retry) isRestarting = true;
}