import openfl.Lib;
import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import states.substates.PauseSubState;

final DEFAULT_WIDTH:Int = 1280;
final TARGET_WIDTH:Int = 960;
final RESTART_MENU_ITEM:String = 'restart';

var window:Dynamic;
var isRestarting:Bool = false;
var isFirstRun:Bool = false;
var luaCallback:Dynamic = null;
var widthOffset:Float;

function initializeState():Void {
    isRestarting = false;
    isFirstRun = false;
    
    if (window == null) {
        window = Lib.application.window;
        widthOffset = (DEFAULT_WIDTH - TARGET_WIDTH) / 2;
    }
}

function setupPauseMonitoring():Void {
    try {
        luaCallback = () -> {
            if (FlxG.state != null && FlxG.state.subState != null) {
                handlePauseUpdate();
            }
        };
        setVar('luaCallback', luaCallback);
        FlxG.signals.postUpdate.add(luaCallback);
    } catch (e:Dynamic) {
    }
}

function handlePauseUpdate():Void {
    try {
        var subState = FlxG.state.subState;
        if (subState.selectionButtons != null && 
            subState.curSelected >= 0 && 
            subState.curSelected < subState.selectionButtons.length) {
            
            var selectedItem = subState.selectionButtons[subState.curSelected];
            isRestarting = (selectedItem == RESTART_MENU_ITEM);

            if (isFirstRun) subState.camPause.x = ((DEFAULT_WIDTH - TARGET_WIDTH) / 2); else subState.camPause.x = 0;
        }
    } catch (e:Dynamic) {
    }
}

function cleanupPauseMonitoring():Void {
    try {
        if (luaCallback != null) {
            FlxG.signals.postUpdate.remove(luaCallback);
            setVar('luaCallback', null);
            luaCallback = null;
        }
    } catch (e:Dynamic) {
    }
}

function applyTargetResolution():Void {
    try {
        FlxG.scaleMode = new RatioScaleMode(true);
        FlxG.game.x = 0;
        FlxG.width = TARGET_WIDTH;
        FlxG.camera.width = TARGET_WIDTH;
        game.camHUD.width = TARGET_WIDTH;
        game.camOther.width = TARGET_WIDTH;

        if (window != null) {
            window.resizable = false;
 
            if (window.width != TARGET_WIDTH) {
                isFirstRun = true;
                PauseSubState.cameraWidth = TARGET_WIDTH;
                window.width = TARGET_WIDTH;
                window.x += widthOffset;
            }
        }
    } catch (e:Dynamic) {
    }
}

function centerCameras():Void {
    if (!isFirstRun) return;
    
    try {
        for (camera in FlxG.cameras.list) {
            camera.x = widthOffset;
        }
    } catch (e:Dynamic) {
    }
}

function restoreDefaultResolution():Void {
    try {
        var shouldRestore = window != null && 
                           window.width != DEFAULT_WIDTH && 
                           !isRestarting && 
                           PlayState.startOnTime == 0 && 
                           PlayState.deathCounter == 0;
        
        if (shouldRestore) {
            FlxG.scaleMode = new RatioScaleMode();
            FlxG.width = DEFAULT_WIDTH;
            FlxG.camera.width = DEFAULT_WIDTH;
            
            window.resizable = true;
            window.width = DEFAULT_WIDTH;
            window.x -= widthOffset;
        }
    } catch (e:Dynamic) {
    }
}

function destroy():Void {
    cleanupPauseMonitoring();
    restoreDefaultResolution();
    initializeState();
}

function onCreate():Void {
    initializeState();
    applyTargetResolution();
}

function onCreatePost():Void {
    centerCameras();
}

function onPause():Void {
    setupPauseMonitoring();
}

function onResume():Void {
    cleanupPauseMonitoring();
}

function onDestroy():Void {
    destroy();
}