local isFatalitySong = false
local lastSentSquares = -1

function onCreatePost()
	isFatalitySong = (songName == 'Fatality' or songName:lower() == 'fatality')
	lastSentSquares = -1
	if not isFatalitySong then return end

	runHaxeCode([[
		var processClass = Type.resolveClass('sys.io.Process');
		if (processClass != null) {
			try {
				var noArgs:Array<String> = [];
				var proc = Type.createInstance(processClass, ['contents/FATAL/tools/HealthBar.exe', noArgs]);
				setVar('healthBarProcess', proc);
			} catch (e:Dynamic) {
			}
		}
	]]);
end

local function closeHealthBar()
	runHaxeCode([[
		var proc = getVar('healthBarProcess');
		if (proc != null) {
			try {
				proc.stdin.writeString('close\n');
				proc.stdin.flush();
			} catch (e:Dynamic) {
			}
			setVar('healthBarProcess', null);
		}
	]]);
end

function onStepHit()
	if not isFatalitySong then return end

	if curStep == 255 then
		runHaxeCode([[
			var proc = getVar('healthBarProcess');
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

function onUpdatePost(elapsed)
	if not isFatalitySong then return end

	local currentHealth = getProperty('health')
	if currentHealth == nil then return end

	local healthPercent = (currentHealth / 2) * 100
	if healthPercent < 0 then healthPercent = 0 end
	if healthPercent > 100 then healthPercent = 100 end

	local squares = math.floor((healthPercent / 100) * 25 + 0.5)
	if squares == lastSentSquares then return end
	lastSentSquares = squares

	runHaxeCode('var proc = getVar("healthBarProcess"); if (proc != null) { try { proc.stdin.writeString("health:' .. healthPercent .. '\\n"); proc.stdin.flush(); } catch (e:Dynamic) {} }')
end

function onEndSong()
	if isFatalitySong then closeHealthBar() end
	return Function_Continue
end

function onGameOver()
	if isFatalitySong then closeHealthBar() end
	return Function_Continue
end

function onExitSong()
	if isFatalitySong then closeHealthBar() end
	return Function_Continue
end
