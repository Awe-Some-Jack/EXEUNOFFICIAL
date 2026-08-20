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

function onEndSong()
	closeAllPopups()
	return Function_Continue
end

function onGameOver()
	closeAllPopups()
	return Function_Continue
end

function onExitSong()
	closeAllPopups()
	return Function_Continue
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
