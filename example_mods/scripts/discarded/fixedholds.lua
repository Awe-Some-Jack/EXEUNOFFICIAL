local framerate = 2
local pausedFrames = {}
local enabledHolds = {}
local canNewHold = {}
local savedDurations = {}
function onCreatePost()
	loadJson('boyfriend') loadJson('dad') loadJson('gf')
end

function goodNoteHitPre(id,nd,nt,isn)
	local targ = (nt == 'GF Sing' and 'gf' or 'boyfriend')
	local newSystem = enabledHolds[targ]
	if nt == 'Alt Holds' then newSystem = not newSystem end
	canNewHold[targ] = newSystem
	if newSystem then
		if isn and stringStartsWith(getProperty(targ..'.animation.curAnim.name'), getProperty('singAnimations['..nd..']')) then
			setPropertyFromGroup('notes', id, 'noAnimation', true)
		end
	else
		if isn and stringStartsWith(getProperty(targ..'.animation.curAnim.name'), 'sing') and getProperty(targ..'.animation.curAnim.curFrame') < framerate then
			setPropertyFromGroup('notes', id, 'noAnimation', true)
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	local targ = (nt == 'GF Sing' and 'gf' or 'boyfriend')
	local newSystem = enabledHolds[targ]
	if nt == 'Alt Holds' then newSystem = not newSystem end
	canNewHold[targ] = newSystem
	if newSystem then
		if isn then
			setProperty(targ..'.holdTimer', 0)
		end

		if getProperty(targ..'.animation.paused') and stringEndsWith(getProperty('notes.members['..id..'].animation.curAnim.name'), 'holdend') then
			setProperty(targ..'.animation.paused', false)
			setProperty(targ..'.animation.curAnim.curFrame', pausedFrames[targ] + 1)
		end
	else
		if isn and stringStartsWith(getProperty(targ..'.animation.curAnim.name'), 'sing') and getProperty(targ..'.animation.curAnim.curFrame') < framerate then
			setProperty(targ..'.holdTimer', 0)
		end
	end
end

function opponentNoteHitPre(id,nd,nt,isn)
	local targ = (nt == 'GF Sing' and 'gf' or 'dad')
	local newSystem = enabledHolds[targ]
	if nt == 'Alt Holds' then newSystem = not newSystem end
	canNewHold[targ] = newSystem
	if newSystem then
		if isn and stringStartsWith(getProperty(targ..'.animation.curAnim.name'), getProperty('singAnimations['..nd..']')) then
			setPropertyFromGroup('notes', id, 'noAnimation', true)
		end
	else
		if isn and stringStartsWith(getProperty(targ..'.animation.curAnim.name'), 'sing') and getProperty(targ..'.animation.curAnim.curFrame') < framerate then
			setPropertyFromGroup('notes', id, 'noAnimation', true)
		end
	end
end

function opponentNoteHit(id,nd,nt,isn)
	local targ = (nt == 'GF Sing' and 'gf' or 'dad')
	local newSystem = enabledHolds[targ]
	if nt == 'Alt Holds' then newSystem = not newSystem end
	canNewHold[targ] = newSystem
	if newSystem then
		if isn then
			setProperty(targ..'.holdTimer', 0)
		end

		if getProperty(targ..'.animation.paused') and stringEndsWith(getProperty('notes.members['..id..'].animation.curAnim.name'), 'holdend') then
			setProperty(targ..'.animation.paused', false)
			setProperty(targ..'.animation.curAnim.curFrame', pausedFrames[targ] + 1)
		end
	else
		if isn and stringStartsWith(getProperty(targ..'.animation.curAnim.name'), 'sing') and getProperty(targ..'.animation.curAnim.curFrame') < framerate then
			setProperty(targ..'.holdTimer', 0)
		end
	end
end

function onUpdatePost(e)
	for i,char in ipairs({'dad', 'boyfriend', 'gf'}) do
		if canNewHold[char] then
			if pausedFrames[char] ~= nil and getProperty(char..'.animation.curAnim.curFrame') == pausedFrames[char] and getProperty(char) and stringStartsWith(getProperty(char..'.animation.curAnim.name'), 'sing') then
				setProperty(char..'.animation.paused', true)
			end
		end
	end
	
	if getProperty('boyfriend.holdTimer') >= stepCrochet * (0.0011 / getPropertyFromClass('flixel.FlxG', 'sound.music.pitch')) * getProperty('boyfriend.singDuration') then
		playAnim('boyfriend', 'idle', true)
	end
end

function onEvent(n,v1,v2)
	if n == 'Change Character' then
		loadJson(v1:lower():gsub(' ', ''))
	end
end

function loadJson(target)
	local char = (target == 'bf' and ('boyfriendName') or (target..'Name'))
	enabledHolds[target] = false
	if checkFileExists('characters/'.._G[char]..'.json') then
		json = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('characters/'.._G[char]..'.json')})
		for j,v in pairs(json) do
			if j == 'paused_frame' and v ~= nil then pausedFrames[target] = v end
			if j == 'enable_new_holds' and v ~= nil then enabledHolds[target] = v end
		end
	end
	enabledHolds[target] = true
	debugPrint(enabledHolds[target])
	savedDurations[target] = getProperty(target..'.singDuration')
	if enabledHolds[target] then setProperty(target..'.singDuration', getProperty(target..'.singDuration') * 0.5) end
end