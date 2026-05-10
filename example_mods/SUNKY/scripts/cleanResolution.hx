import openfl.Lib;
import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import states.substates.PauseSubState;
import lime.system.System;

final DEFAULT_WIDTH:Int = 1280;
final DEFAULT_HEIGHT:Int = 720;
final TARGET_WIDTH:Int = 960;
final TARGET_HEIGHT:Int = 720;
final RESTART_MENU_ITEM:String = 'restart';

var window:Dynamic;
var isRestarting:Bool = false;
var isFirstRun:Bool = false;
var wasFullscreen:Bool = false;
var luaCallback:Dynamic = null;
var widthOffset:Float;
var savedWindowX:Int = 0;
var savedWindowY:Int = 0;

function initializeState():Void {
    isRestarting = false;
    isFirstRun = false;
    wasFullscreen = false;
    savedWindowX = 0;
    savedWindowY = 0;

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
        if (window != null && window.fullscreen) {
            wasFullscreen = true;
            window.fullscreen = false;
        }

        FlxG.scaleMode = new RatioScaleMode(true);
        FlxG.game.x = 0;
        FlxG.width = TARGET_WIDTH;
        FlxG.camera.width = TARGET_WIDTH;
        game.camHUD.width = TARGET_WIDTH;
        game.camOther.width = TARGET_WIDTH;

        if (window != null) {
            window.resizable = false;

            if (window.width != TARGET_WIDTH || window.height != TARGET_HEIGHT) {
                isFirstRun = true;
                PauseSubState.cameraWidth = TARGET_WIDTH;

                savedWindowX = window.x;
                savedWindowY = window.y;

                var screenW:Int = System.screenResolution.width;
                var screenH:Int = System.screenResolution.height;

                window.width = TARGET_WIDTH;
                window.height = TARGET_HEIGHT;
                window.x = Std.int((screenW - TARGET_WIDTH) / 2);
                window.y = Std.int((screenH - TARGET_HEIGHT) / 2);
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
                           !isRestarting &&
                           PlayState.startOnTime == 0 &&
                           PlayState.deathCounter == 0;

        if (shouldRestore) {
            FlxG.scaleMode = new RatioScaleMode();
            FlxG.width = DEFAULT_WIDTH;
            FlxG.camera.width = DEFAULT_WIDTH;

            window.resizable = true;

            if (wasFullscreen) {
                window.fullscreen = true;
            } else {
                window.width = DEFAULT_WIDTH;
                window.height = DEFAULT_HEIGHT;
                window.x = savedWindowX;
                window.y = savedWindowY;
            }
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