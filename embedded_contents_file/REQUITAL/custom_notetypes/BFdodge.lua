local dodgeNotes = {}
local dodgeCount = 0

local function removeDodge(st)
	if dodgeNotes[st] then
		removeLuaSprite('BFDodge'..st, true)
		dodgeNotes[st] = nil
		dodgeCount = dodgeCount - 1
	end
end

function onCreate()
	precacheImage('noteSkins/dodgeNoteBF')

	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'BFdodge' then
			setProperty('unspawnNotes['..i..'].noAnimation', true)
			setProperty('unspawnNotes['..i..'].noMissAnimation', true)
			setProperty('unspawnNotes['..i..'].ignoreNote', true)
			setProperty('unspawnNotes['..i..'].ratingDisabled', true)
			setProperty('unspawnNotes['..i..'].multAlpha', 0)
			setProperty('unspawnNotes['..i..'].earlyHitMult', 0.75)
			setProperty('unspawnNotes['..i..'].lateHitMult', 0.75)
		end
	end
end

function onSpawnNote(id,nd,nt,isn)
	if nt == 'BFdodge' and nd == 0 then
		local st = math.floor(getProperty('notes.members['..id..'].strumTime'))
		makeLuaSprite('BFDodge'..st, 'noteSkins/dodgeNoteBF', getProperty('playerStrums.members[0].x'))
		addToGroup('noteGroup', 'BFDodge'..st)
		dodgeNotes[st] = true
		dodgeCount = dodgeCount + 1
	end
end

function onUpdatePost(e)
	if dodgeCount == 0 then return end

	for i = 0,getProperty('notes.length')-1 do
		local st = math.floor(getProperty('notes.members['..i..'].strumTime'))
		if dodgeNotes[st] then
			setProperty('BFDodge'..st..'.y', getProperty('notes.members['..i..'].y'))
		end
	end

	local noteKillOffset = math.max(stepCrochet, 350 / getProperty('songSpeed') * playbackRate) - 5
	local songPos = getSongPosition()
	for st in pairs(dodgeNotes) do
		if songPos - noteKillOffset > st then
			removeDodge(st)
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	if nt == 'BFdodge' and dodgeCount > 0 then
		removeDodge(math.floor(getProperty('notes.members['..id..'].strumTime')))
	end
end
