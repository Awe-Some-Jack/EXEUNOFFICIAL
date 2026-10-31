import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import backend.LineProcess;
import backend.EXEMouse;

var isFatalitySong:Bool = false;
var corruptionTriggered = false;
var warningActive = false;
var mechanicActive = true;
var lastSentCorruptionSquares = -1;
final squareCount = 22;
final maxPopups = 25;
final dangerPopups = 15;
final warningSeconds = 2;

var warningTimer:FlxTimer = null;
var floodTimer:FlxTimer = null;
var floodSpawnTimer:FlxTimer = null;
var shutdownTimer:FlxTimer = null;

var lastRefocusAttempt:Float = 0;
var refocusCooldown:Float = 1;
var windowHasFocus:Bool = true;

var popupHost:LineProcess = null;
var alivePopups:Int = 0;

function killProcess(proc:Dynamic) {
    killProcesses([proc]);
}

function killProcesses(procs:Array<Dynamic>) {
    if(procs == null || procs.length == 0) return;

    if(Sys.systemName() == 'Windows') {
        for(proc in procs) {
            try {
                proc.kill();
            } catch (e:Dynamic) {
                trace('killProcesses failed: ' + e);
            }
        }
        return;
    }

    var pids:Array<String> = [];
    for(proc in procs) {
        try {
            pids.push(Std.string(proc.getPid()));
        } catch (e:Dynamic) {
            trace('killProcesses failed to get pid: ' + e);
        }
    }

    if(pids.length == 0) return;

    try {
        Sys.command('kill', ['-9'].concat(pids));
    } catch (e:Dynamic) {
        trace('killProcesses batch failed: ' + e);
    }
}

function onWindowFocusLost() {
    windowHasFocus = false;
}

function onWindowFocusGained() {
    windowHasFocus = true;
}

function tryRefocusWindow() {
    if(windowHasFocus) return;

    var now = Sys.time();
    if(now - lastRefocusAttempt < refocusCooldown) return;

    lastRefocusAttempt = now;
    Lib.application.window.focus();
    trace("REFOCUSING");
}

function startWarningTimer() {
    if(warningTimer != null) warningTimer.cancel();
    warningTimer = new FlxTimer().start(warningSeconds, function(_) onCorruptionWarningDone());
}

function cancelWarningTimer() {
    if(warningTimer != null) {
        warningTimer.cancel();
        warningTimer = null;
    }
}

function onCorruptionWarningDone() {
    if(warningActive) {
        warningActive = false;
        corruptionTriggered = true;
        sendCorruptionCommand('calm');
        shakeEverything();

        if(floodTimer != null) floodTimer.cancel();
        floodTimer = new FlxTimer().start(0.6, function(_) onCorruptionFloodDone());
    }
}

function onCorruptionFloodDone() {
    floodWithPopups();
}

function startPopupHost():Bool {
    if(popupHost != null && popupHost.isRunning()) return true;
    stopPopupHost();

    var exeName = switch (Sys.systemName()) {
        case 'Windows': 'PopUp.exe';
        case 'Mac': 'PopUp-mac';
        default: 'PopUp-linux';
    }
    try {
        popupHost = new LineProcess('contents/FATAL/tools/' + exeName, ['--host']);
        popupHost.send('max:' + maxPopups);
        setVar('fatalPopupHost', popupHost);
        if(Sys.systemName() == 'Mac') EXEMouse.forceSystemCursor = true;
        return true;
    } catch (e:Dynamic) {
        trace('popup host failed to start: ' + e);
        popupHost = null;
        return false;
    }
}

function stopPopupHost() {
    if(popupHost != null) {
        popupHost.kill();
        popupHost = null;
    }
    setVar('fatalPopupHost', null);
    alivePopups = 0;
    if(Sys.systemName() == 'Mac') EXEMouse.forceSystemCursor = false;
}

function spawnPopup(ignoreLimit:Bool) {
    if(!startPopupHost()) return;

    var vol = FlxG.sound.muted ? 0.0 : FlxG.sound.volume;
    popupHost.send((ignoreLimit ? 'flood:' : 'spawn:') + vol);
}

function closeAllPopups() {
    if(popupHost != null) popupHost.send('clear');
}

function closeCorruptionBar() {
    var proc = getVar('corruptionBarProcess');
    if(proc != null) {
        killProcess(proc);
        setVar('corruptionBarProcess', null);
    }
}

function sendCorruptionCommand(cmd:String) {
    var proc = getVar('corruptionBarProcess');
    if(proc != null) {
        try {
            proc.stdin.writeString(cmd + "\n");
            proc.stdin.flush();
        } catch (e:Dynamic) {
            trace(e);
        }
    }
}

function onCreatePost() {
    if(Sys.systemName() == 'Mac') {
        refocusCooldown = 0.05;
    }
    FlxG.autoPause = false;
    isFatalitySong = (songName.toLowerCase() == 'fatality');
    corruptionTriggered = false;
    warningActive = false;
    mechanicActive = true;
    lastSentCorruptionSquares = -1;
    if(!isFatalitySong) return;

    windowHasFocus = true;
    FlxG.signals.focusLost.add(onWindowFocusLost);
    FlxG.signals.focusGained.add(onWindowFocusGained);

    var processClass = Type.resolveClass('sys.io.Process');
    if(processClass != null) {
        try {
            var exeName = switch (Sys.systemName()) {
                case 'Windows': 'CorruptionBar.exe';
                case 'Mac': 'CorruptionBar-mac';
                default: 'CorruptionBar-linux';
            }
            var noArgs:Array<String> = [];
            var proc = Type.createInstance(processClass, ['contents/FATAL/tools/' + exeName, noArgs]);
            setVar('corruptionBarProcess', proc);
        } catch (e:Dynamic) {
            trace(e);
        }
    }

    startPopupHost();
}

function onStartCountdown() tryRefocusWindow();

function onPause() {
    if(isFatalitySong)
		return Function_Stop;
	return Function_Continue;
}

function onStepHit() {
    if(!isFatalitySong) return;

    switch(curStep) {
        case 2559:
            closeAllPrograms();
            showFatalScreen();
        case 255:
            var proc = getVar('corruptionBarProcess');
			if(proc != null) {
				try {
					proc.stdin.writeString('slide\n');
					proc.stdin.flush();
				} catch (e:Dynamic) {
                    trace(e);
				}
			}
    }
}

function disableCorruptionMechanic() {
    if(!isFatalitySong || !mechanicActive) return;

    mechanicActive = false;
    if(warningActive) {
        warningActive = false;
        cancelWarningTimer();
    }
    sendCorruptionCommand('hide');
    setVar('corruptionBarProcess', null);
}

function onEndSong() {
    warningActive = false;
	cancelWarningTimer();
	stopPopupHost();
	closeCorruptionBar();
	return Function_Continue;
}

function onGameOver() {
	warningActive = false;
	cancelWarningTimer();
	stopPopupHost();
	closeCorruptionBar();
	return Function_Continue;
}

function onDestroy() {
    FlxG.autoPause = true;
	warningActive = false;
	cancelWarningTimer();
	stopPopupHost();
	closeCorruptionBar();
	FlxG.signals.focusLost.remove(onWindowFocusLost);
	FlxG.signals.focusGained.remove(onWindowFocusGained);
}

function onEvent(n:Dynamic, v1:Dynamic, v2:Dynamic, v3:Dynamic) {
    switch(n) {
        case 'PopProgram':
            spawnPopup(false);

        case 'Clear Fatal Popups':
            trace('Clear Fatal Popups event received');
            closeAllPopups();

        case 'Disable Fatal Corruption':
            disableCorruptionMechanic();
    }
}

function shakeEverything() {
    FlxG.sound.music.pause();
    vocals.pause();
    opponentVocals.pause();

    FlxG.camera.shake(0.015, 0.6);
    camHUD.shake(0.015, 0.6);

    var hbProc = getVar('healthBarProcess');
    if(hbProc != null) { try { hbProc.stdin.writeString('shake\n'); hbProc.stdin.flush(); } catch (e:Dynamic) {} }

    var cbProc = getVar('corruptionBarProcess');
    if(cbProc != null) { try { cbProc.stdin.writeString('shake\n'); cbProc.stdin.flush(); } catch (e:Dynamic) {} }

    if(popupHost != null) popupHost.send('shake');
}

var noteSpawnTimer:Float = 0;
function onSpawnNote(note:Dynamic) {
    if(note.mustPress && Sys.systemName() == 'Mac') {
        noteSpawnTimer = 0.5;
        if(!windowHasFocus)
            tryRefocusWindow();
    }
}

function goodNoteHitPre(note:Dynamic) {
    if(Sys.systemName() == 'Mac') {
        noteSpawnTimer = 1;
        if(!windowHasFocus)
            tryRefocusWindow();
    }
}

function floodWithPopups() {
    if(floodSpawnTimer != null) floodSpawnTimer.cancel();
    floodSpawnTimer = new FlxTimer().start(0.05, function(tmr) {
        spawnPopup(true);
        if(tmr.loopsLeft <= 0) {
            if(shutdownTimer != null) shutdownTimer.cancel();
            shutdownTimer = new FlxTimer().start(1.5, function(_) shutEverythingDown());
        }
    }, 24);
}

function closeAllPrograms() {
    stopPopupHost();
    closeCorruptionBar();

    var hbProc = getVar('healthBarProcess');
    if(hbProc != null) {
        killProcess(hbProc);
        setVar('healthBarProcess', null);
    }
}

var fatalScreen:FlxSprite = null;
function showFatalScreen() {
    if(fatalScreen != null) return;

    PlayState.isFixedAspectRatio = false;
    FlxG.fullscreen = true;

    fatalScreen = new FlxSprite().loadGraphic(Paths.image('fatality/fatalscreen'));
    fatalScreen.antialiasing = false;
    fatalScreen.setGraphicSize(FlxG.width, FlxG.height);
    fatalScreen.updateHitbox();
    fatalScreen.screenCenter();
    fatalScreen.scrollFactor.set();
    fatalScreen.cameras = [game.camOther];
    game.add(fatalScreen);
}

function shutEverythingDown() {
	stopPopupHost();
	closeCorruptionBar();

    var hbProc = getVar('healthBarProcess');
    if(hbProc != null) killProcess(hbProc);
    Sys.exit(0);
}

function onUpdatePost(elapsed:Float) {
    if(!isFatalitySong) return;

    if(noteSpawnTimer > 0 && !windowHasFocus && Sys.systemName() == 'Mac')
        tryRefocusWindow();
    else if(Sys.systemName() == 'Mac')
        noteSpawnTimer -= elapsed;

    if(!windowHasFocus && FlxG.keys.pressed.ANY) {
        var pressedKey = FlxG.keys.firstPressed();
        trace('Key pressed: ' + FlxKey.toStringMap.get(pressedKey));
        tryRefocusWindow();
    }

    var closedOne = false;
    if(popupHost != null) {
        for(line in popupHost.poll()) {
            if(line.indexOf('count:') == 0) {
                var count = Std.parseInt(line.substr(6));
                if(count != null) {
                    if(count < alivePopups) closedOne = true;
                    alivePopups = count;
                }
            }
        }
        if(!popupHost.isRunning()) alivePopups = 0;
    }
    setVar('aliveFatalPopups', alivePopups);
    setVar('fatalPopupJustClosed', closedOne);

    if(corruptionTriggered || !mechanicActive) return;

    var aliveCount = alivePopups;

    var squares = Std.int(Math.min(Math.floor(aliveCount * squareCount / dangerPopups), squareCount));
    if(squares != lastSentCorruptionSquares) {
        lastSentCorruptionSquares = squares;
        var proc = getVar("corruptionBarProcess"); if(proc != null) { try { proc.stdin.writeString('corruption:${squares}\n'); proc.stdin.flush(); } catch (e:Dynamic) {} }
    }

    if(aliveCount >= dangerPopups) {
        if(!warningActive) {
            warningActive = true;
            sendCorruptionCommand('danger');
            startWarningTimer();
        }
    } else if(warningActive) {
        warningActive = false;
        cancelWarningTimer();
        sendCorruptionCommand('calm');
    }
}
