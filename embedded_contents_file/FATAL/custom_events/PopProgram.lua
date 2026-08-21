local isFatalitySong = false
local corruptionTriggered = false
local lastSentCorruptionSquares = -1

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

function onCreatePost()
	isFatalitySong = (songName == 'Fatality' or songName:lower() == 'fatality')
	corruptionTriggered = false
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
	closeAllPopups()
	closeCorruptionBar()
	return Function_Continue
end

function onGameOver()
	closeAllPopups()
	closeCorruptionBar()
	return Function_Continue
end

function onDestroy()
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

			if (processes.length >= 16) {
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
	if tag == 'fatalCorruptionFlood' then
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

	local corruptionPercent = (aliveCount / 16) * 100
	if corruptionPercent > 100 then corruptionPercent = 100 end

	local squares = math.floor((corruptionPercent / 100) * 22 + 0.5)
	if squares ~= lastSentCorruptionSquares then
		lastSentCorruptionSquares = squares
		runHaxeCode('var proc = getVar("corruptionBarProcess"); if (proc != null) { try { proc.stdin.writeString("corruption:' .. corruptionPercent .. '\\n"); proc.stdin.flush(); } catch (e:Dynamic) {} }')
	end

	if aliveCount >= 16 then
		corruptionTriggered = true
		shakeEverything()
		runTimer('fatalCorruptionFlood', 0.6)
	end
end
