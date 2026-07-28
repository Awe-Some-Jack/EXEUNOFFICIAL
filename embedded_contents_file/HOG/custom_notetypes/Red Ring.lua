local speedMult = 1

function onCreatePost()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Red Ring' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/red-ring')
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
			setPropertyFromGroup('unspawnNotes', i, 'ratingDisabled', true)
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', 0)
			setPropertyFromGroup('unspawnNotes', i, 'earlyHitMult', 0.6)
			setPropertyFromGroup('unspawnNotes', i, 'lateHitMult', 0.6)
		end
	end
end

function onUpdatePost(e)
	for i = 0,getProperty('notes.length')-1 do
		setPropertyFromGroup('notes', i, 'multSpeed', lerp(getPropertyFromGroup('notes', i, 'multSpeed'), speedMult, e * 5))
	end
end

function goodNoteHit(_,_,nt)
	if nt == 'Red Ring' then speedMult = math.min(speedMult * 1.2, 1.6) end
	if nt == 'Yellow Ring' then speedMult = 1 end 
end

function onSpawnNote(id,_,nt)
	if speedMult > 1 and nt == 'Yellow Ring' then
		setPropertyFromGroup('notes', i, 'texture', 'noteSkins/yellow-ring')
		setPropertyFromGroup('notes', i, 'earlyHitMult', 1.35)
		setPropertyFromGroup('notes', i, 'lateHitMult', 1.35)
	end
end


function lerp(a, b, t)
	return a + t * (b - a)
end

function onBeatHit() if songPath == 'manual-blast' and curBeat >= 1040 and speedMult > 1 then speedMult = 1 end end