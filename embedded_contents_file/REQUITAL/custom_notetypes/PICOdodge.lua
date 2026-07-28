local dodgeNotes = {}

function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'PICOdodge' then
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
	if nt == 'PICOdodge' and nd == 2 then
		st = math.floor(getProperty('notes.members['..id..'].strumTime'))
		makeLuaSprite('PICODodge'..st, 'noteSkins/dodgeNotePICO', getProperty('playerStrums.members[2].x'))
		addToGroup('noteGroup', 'PICODodge'..st)
		table.insert(dodgeNotes, st)
	end
end

function onUpdatePost(e)
	for i = 0,getProperty('notes.length')-1 do
		if luaSpriteExists('PICODodge'..math.floor(getProperty('notes.members['..i..'].strumTime'))) then
			setProperty('PICODodge'..math.floor(getProperty('notes.members['..i..'].strumTime'))..'.y', getProperty('notes.members['..i..'].y'))
		end
	end

	for n,i in pairs(dodgeNotes) do
		local noteKillOffset = math.max(stepCrochet, 350 / getProperty('songSpeed') * playbackRate) - 5
		if getSongPosition() - noteKillOffset > i then
			if luaSpriteExists('PICODodge'..i) then
				removeLuaSprite('PICODodge'..i, true)
				dodgeNotes[i] = nil
			end
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	if nt == 'PICOdodge' then
		if luaSpriteExists('PICODodge'..math.floor(getProperty('notes.members['..id..'].strumTime'))) then
			removeLuaSprite('PICODodge'..math.floor(getProperty('notes.members['..id..'].strumTime')), true)
		end
	end
end