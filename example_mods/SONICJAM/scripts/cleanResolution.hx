import openfl.Lib;
import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import states.substates.PauseSubState;
import backend.Controls;

var isRestarting:Bool = false;
var luaCallback:Dynamic = null;

var isFixedAspectRatio(default, set):Bool = false;

var _originalWidth:Int = FlxG.initialWidth;
var _originalHeight:Int = FlxG.initialHeight;

function set_isFixedAspectRatio(value:Bool):Bool
{
    if (isFixedAspectRatio == value) return value;
    
    isFixedAspectRatio = value; 
    
    if (value) {
        final screen = FlxG.stage.window.display;
        var screenWidth = screen.bounds.width;
        var screenHeight = screen.bounds.height;
        
        FlxG.fullscreen = false;
        FlxG.stage.window.resizable = false;
        
        FlxG.scaleMode = new StageSizeScaleMode();
        FlxG.camera.setSize(960, 720);
        FlxG.resizeGame(960, 720);
        FlxG.resizeWindow(960, 720);
        
        var winX = Std.int((screenWidth - 960) / 2);
        var winY = Std.int((screenHeight - 720) / 2);
        FlxG.stage.window.move(winX, winY);
    } else {
        FlxG.stage.window.resizable = true;

        final screen = FlxG.stage.window.display;
        var screenWidth = screen.bounds.width;
        var screenHeight = screen.bounds.height;
        
        FlxG.scaleMode = new RatioScaleMode();
        FlxG.camera.setSize(_originalWidth, _originalHeight);
        FlxG.resizeGame(_originalWidth, _originalHeight);
        FlxG.resizeWindow(_originalWidth, _originalHeight);
        
        var winX = Std.int((screenWidth - _originalWidth) / 2);
        var winY = Std.int((screenHeight - _originalHeight) / 2);
        FlxG.stage.window.move(winX, winY);

        FlxG.fullscreen = PlayState._wasFullscreen;
    }
    
    return value;
}

function onCreate()
{
    if (!PlayState.firstPlay) 
    {
        isFixedAspectRatio = true;
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
        FlxG.width = isFixedAspectRatio ? 960 : _originalWidth;
        if (FlxG.fullscreen && isFixedAspectRatio)  FlxG.game.x = (1280 - 960) * 0.75;
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
    
    isFixedAspectRatio = false; 
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