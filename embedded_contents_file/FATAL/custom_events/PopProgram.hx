import openfl.Lib;
import flixel.input.keyboard.FlxKey;

var isFatalitySong:Bool = false;
var corruptionTriggered = false;
var warningActive = false;
var mechanicActive = true;
var lastSentCorruptionSquares = -1;
final squareCount = 22;
final maxPopups = 25;
final mechanicDisableStep = 2229;

var warningTimer:FlxTimer = null;
var floodTimer:FlxTimer = null;
var floodSpawnTimer:FlxTimer = null;
var shutdownTimer:FlxTimer = null;

var lastRefocusAttempt:Float = 0;
var refocusCooldown:Float = 1;
var windowHasFocus:Bool = true;

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
    warningTimer = new FlxTimer().start(3, function(_) onCorruptionWarningDone());
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

function closeAllPopups() {
    var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
    if(processes != null) {
        killProcesses(processes);
        setVar('fatalErrorProcesses', []);
    }
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
        case mechanicDisableStep:
            mechanicActive = false;
            if(warningActive) {
                warningActive = false;
                cancelWarningTimer();
            }
            sendCorruptionCommand('hide');
            setVar('corruptionBarProcess', null);
    }
}

function onEndSong() {
    warningActive = false;
	cancelWarningTimer();
	closeAllPopups();
	closeCorruptionBar();
	return Function_Continue;
}

function onGameOver() {
	warningActive = false;
	cancelWarningTimer();
	closeAllPopups();
	closeCorruptionBar();
	return Function_Continue;
}

function onDestroy() {
	warningActive = false;
	cancelWarningTimer();
	closeAllPopups();
	closeCorruptionBar();
	FlxG.signals.focusLost.remove(onWindowFocusLost);
	FlxG.signals.focusGained.remove(onWindowFocusGained);
}

function onEvent(n:Dynamic, v1:Dynamic, v2:Dynamic, v3:Dynamic) {
    switch(n) {
        case 'PopProgram':
            var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
            if(processes == null) {
                processes = [];
            }

            if(processes.length >= maxPopups) {
                var oldest = processes.shift();
                killProcess(oldest);
            }

            var processClass = Type.resolveClass('sys.io.Process');
            if(processClass != null) {
                try {
                    var exeName = switch (Sys.systemName()) {
                        case 'Windows': 'PopUp.exe';
                        case 'Mac': 'PopUp-mac';
                        default: 'PopUp-linux';
                    }
                    var vol = FlxG.sound.muted ? 0.0 : FlxG.sound.volume;
                    var popArgs:Array<String> = [Std.string(vol)];
                    var proc = Type.createInstance(processClass, ['contents/FATAL/tools/' + exeName, popArgs]);
                    processes.push(proc);
                } catch (e:Dynamic) {
                }
            }

            setVar('fatalErrorProcesses', processes);

        case 'Clear Fatal Popups':
            trace('Clear Fatal Popups event received');
            closeAllPopups();
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

    var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
    if(processes != null) {
        for (p in processes) {
            try { p.stdin.writeString('shake\n'); p.stdin.flush(); } catch (e:Dynamic) {}
        }
    }
}

function spawnFloodPopup() {
    var processClass = Type.resolveClass('sys.io.Process');
    if(processClass != null) {
        try {
            var exeName = switch (Sys.systemName()) {
                case 'Windows': 'PopUp.exe';
                case 'Mac': 'PopUp-mac';
                default: 'PopUp-linux';
            }
            var vol = FlxG.sound.muted ? 0.0 : FlxG.sound.volume;
            var popArgs:Array<String> = [Std.string(vol)];
            var proc = Type.createInstance(processClass, ['contents/FATAL/tools/' + exeName, popArgs]);
            var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
            if(processes == null) processes = [];
            processes.push(proc);
            setVar('fatalErrorProcesses', processes);
        } catch (e:Dynamic) {
        }
    }
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
        spawnFloodPopup();
        if(tmr.loopsLeft <= 0) {
            if(shutdownTimer != null) shutdownTimer.cancel();
            shutdownTimer = new FlxTimer().start(1.5, function(_) shutEverythingDown());
        }
    }, 24);
}

function shutEverythingDown() {
	closeAllPopups();
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
        var pressedKey = FlxG.keys.firstressed();
        trace('Key pressed: ' + FlxKey.toStringMap.get(pressedKey));
        tryRefocusWindow();
    }

    var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
    if(processes == null) processes = [];
    var alive:Array<Dynamic> = [];
    var closedOne = false;
    for (p in processes) {
        try {
            if(p.exitCode(false) == null) alive.push(p);
            else closedOne = true;
        } catch (e:Dynamic) {
        }
    }
    setVar('fatalErrorProcesses', alive);
    setVar('aliveFatalPopups', alive.length);
    setVar('fatalPopupJustClosed', closedOne);

    if(corruptionTriggered || !mechanicActive) return;

    var aliveCount = getVar('aliveFatalPopups');

    if(aliveCount == null) aliveCount = 0;

    var squares = Math.min(Math.floor(aliveCount * squareCount / maxPopups), squareCount);
    if(squares != lastSentCorruptionSquares) {
        lastSentCorruptionSquares = squares;
        var proc = getVar("corruptionBarProcess"); if(proc != null) { try { proc.stdin.writeString('corruption:${aliveCount}\n'); proc.stdin.flush(); } catch (e:Dynamic) {} }
    }

    if(aliveCount >= maxPopups) {
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
