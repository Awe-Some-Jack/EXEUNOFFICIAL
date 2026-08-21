local isFatalitySong = false
local corruptionTriggered = false
local warningActive = false
local lastSentCorruptionSquares = -1
local squareCount = 22
local popupsPerSquare = 2
local maxPopups = squareCount * popupsPerSquare

local function closeAllPopups()
	runHaxeCode([[
		var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
		if (processes != null) {
			for (proc in processes) {
				try {
					if (proc.exitCode(false) == null) {
						proc.stdin.writeString('close\n');
						proc.stdin.flush();
					}
				} catch (e:Dynamic) {
				}
			}
			setVar('fatalErrorProcesses', []);
		}
	]]);
end

local function closeCorruptionBar()
	runHaxeCode([[
		var proc = getVar('corruptionBarProcess');
		if (proc != null) {
			try {
				proc.stdin.writeString('close\n');
				proc.stdin.flush();
			} catch (e:Dynamic) {
			}
			setVar('corruptionBarProcess', null);
		}
	]]);
end

local function sendCorruptionCommand(cmd)
	runHaxeCode('var proc = getVar("corruptionBarProcess"); if (proc != null) { try { proc.stdin.writeString("' .. cmd .. '\\n"); proc.stdin.flush(); } catch (e:Dynamic) {} }')
end

function onCreatePost()
	isFatalitySong = (songName == 'Fatality' or songName:lower() == 'fatality')
	corruptionTriggered = false
	warningActive = false
	lastSentCorruptionSquares = -1
	if not isFatalitySong then return end

	runHaxeCode([[
		var processClass = Type.resolveClass('sys.io.Process');
		if (processClass != null) {
			try {
				var noArgs:Array<String> = [];
				var proc = Type.createInstance(processClass, ['contents/FATAL/tools/CorruptionBar.exe', noArgs]);
				setVar('corruptionBarProcess', proc);
			} catch (e:Dynamic) {
			}
		}
	]]);
end

function onStepHit()
	if not isFatalitySong then return end

	if curStep == 255 then
		runHaxeCode([[
			var proc = getVar('corruptionBarProcess');
			if (proc != null) {
				try {
					proc.stdin.writeString('slide\n');
					proc.stdin.flush();
				} catch (e:Dynamic) {
				}
			}
		]]);
	end
end

function onEndSong()
	warningActive = false
	cancelTimer('fatalCorruptionWarning')
	closeAllPopups()
	closeCorruptionBar()
	return Function_Continue
end

function onGameOver()
	warningActive = false
	cancelTimer('fatalCorruptionWarning')
	closeAllPopups()
	closeCorruptionBar()
	return Function_Continue
end

function onDestroy()
	warningActive = false
	cancelTimer('fatalCorruptionWarning')
	closeAllPopups()
	closeCorruptionBar()
end

function onEvent(n, v1)
	if n == 'PopProgram' then
		runHaxeCode([[
			var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
			if (processes == null) {
				processes = [];
			}

			if (processes.length >= ]] .. maxPopups .. [[) {
				var oldest = processes.shift();
				try {
					if (oldest.exitCode(false) == null) {
						oldest.stdin.writeString('close\n');
						oldest.stdin.flush();
					}
				} catch (e:Dynamic) {
				}
			}

			var processClass = Type.resolveClass('sys.io.Process');
			if (processClass != null) {
				try {
					var noArgs:Array<String> = [];
					var proc = Type.createInstance(processClass, ['contents/FATAL/tools/PopUp.exe', noArgs]);
					processes.push(proc);
				} catch (e:Dynamic) {
				}
			}

			setVar('fatalErrorProcesses', processes);
		]]);
	end
end

local function shakeEverything()
	runHaxeCode([[
		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.camera.shake(0.015, 0.6);
		camHUD.shake(0.015, 0.6);

		var hbProc = getVar('healthBarProcess');
		if (hbProc != null) { try { hbProc.stdin.writeString('shake\n'); hbProc.stdin.flush(); } catch (e:Dynamic) {} }

		var cbProc = getVar('corruptionBarProcess');
		if (cbProc != null) { try { cbProc.stdin.writeString('shake\n'); cbProc.stdin.flush(); } catch (e:Dynamic) {} }

		var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
		if (processes != null) {
			for (p in processes) {
				try { p.stdin.writeString('shake\n'); p.stdin.flush(); } catch (e:Dynamic) {}
			}
		}
	]]);
end

local function floodWithPopups()
	for i = 1, 24 do
		runHaxeCode([[
			var processClass = Type.resolveClass('sys.io.Process');
			if (processClass != null) {
				try {
					var noArgs:Array<String> = [];
					var proc = Type.createInstance(processClass, ['contents/FATAL/tools/PopUp.exe', noArgs]);
					var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
					if (processes == null) processes = [];
					processes.push(proc);
					setVar('fatalErrorProcesses', processes);
				} catch (e:Dynamic) {
				}
			}
		]]);
	end
end

local function shutEverythingDown()
	closeAllPopups()
	closeCorruptionBar()
	runHaxeCode([[
		var hbProc = getVar('healthBarProcess');
		if (hbProc != null) { try { hbProc.stdin.writeString('close\n'); hbProc.stdin.flush(); } catch (e:Dynamic) {} }
		Sys.exit(0);
	]]);
end

function onTimerCompleted(tag)
	if tag == 'fatalCorruptionWarning' then
		if warningActive then
			warningActive = false
			corruptionTriggered = true
			sendCorruptionCommand('calm')
			shakeEverything()
			runTimer('fatalCorruptionFlood', 0.6)
		end
	elseif tag == 'fatalCorruptionFlood' then
		floodWithPopups()
		runTimer('fatalCorruptionShutdown', 1.5)
	elseif tag == 'fatalCorruptionShutdown' then
		shutEverythingDown()
	end
end

function onUpdatePost(elapsed)
	if not isFatalitySong or corruptionTriggered then return end

	runHaxeCode([[
		var processes:Array<Dynamic> = getVar('fatalErrorProcesses');
		if (processes == null) processes = [];
		var alive:Array<Dynamic> = [];
		for (p in processes) {
			try {
				if (p.exitCode(false) == null) alive.push(p);
			} catch (e:Dynamic) {
			}
		}
		setVar('fatalErrorProcesses', alive);
		setVar('aliveFatalPopups', alive.length);
	]]);

	local aliveCount = getVar('aliveFatalPopups')
	if aliveCount == nil then aliveCount = 0 end

	local squares = math.min(math.floor(aliveCount / popupsPerSquare), squareCount)
	if squares ~= lastSentCorruptionSquares then
		lastSentCorruptionSquares = squares
		runHaxeCode('var proc = getVar("corruptionBarProcess"); if (proc != null) { try { proc.stdin.writeString("corruption:' .. aliveCount .. '\\n"); proc.stdin.flush(); } catch (e:Dynamic) {} }')
	end

	if aliveCount >= maxPopups then
		if not warningActive then
			warningActive = true
			sendCorruptionCommand('danger')
			runTimer('fatalCorruptionWarning', 3)
		end
	elseif warningActive then
		warningActive = false
		cancelTimer('fatalCorruptionWarning')
		sendCorruptionCommand('calm')
	end
end
