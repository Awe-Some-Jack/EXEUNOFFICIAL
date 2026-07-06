local dodgeNotes = {}

function onCreate()
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
		st = math.floor(getProperty('notes.members['..id..'].strumTime'))
		makeLuaSprite('BFDodge'..st, 'noteSkins/dodgeNoteBF', getProperty('playerStrums.members[0].x'))
		addToGroup('noteGroup', 'BFDodge'..st)
		table.insert(dodgeNotes, st)
	end
end

function onUpdatePost(e)
	for i = 0,getProperty('notes.length')-1 do
		if luaSpriteExists('BFDodge'..math.floor(getProperty('notes.members['..i..'].strumTime'))) then
			setProperty('BFDodge'..math.floor(getProperty('notes.members['..i..'].strumTime'))..'.y', getProperty('notes.members['..i..'].y'))
		end
	end

	for n,i in pairs(dodgeNotes) do
		local noteKillOffset = math.max(stepCrochet, 350 / getProperty('songSpeed') * playbackRate) - 5
		if getSongPosition() - noteKillOffset > i then
			if luaSpriteExists('BFDodge'..i) then
				removeLuaSprite('BFDodge'..i, true)
				dodgeNotes[i] = nil
			end
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	if nt == 'BFdodge' then
		if luaSpriteExists('BFDodge'..math.floor(getProperty('notes.members['..id..'].strumTime'))) then
			removeLuaSprite('BFDodge'..math.floor(getProperty('notes.members['..id..'].strumTime')), true)
		end
	end
end