local noteProps = {
	{hold = 0, offset = {0,0}},
	{hold = 0, offset = {0,0}},
	{hold = 0, offset = {0,0}},
	{hold = 0, offset = {0,0}}
}

function onCreatePost()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Glitch Note' then
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
			setPropertyFromGroup('unspawnNotes', i, 'earlyHitMult', 0.3)
			setPropertyFromGroup('unspawnNotes', i, 'lateHitMult', 0.3)
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)
			setPropertyFromGroup('unspawnNotes', i, 'ratingDisabled', true)
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', 0)
		end
	end
end

function onUpdatePost(e)
	for i = 0,getProperty('notes.length')-1 do
		if getPropertyFromGroup('notes', i, 'noteType') == 'Glitch Note' then
			if math.abs(getPropertyFromGroup('notes', i, 'distance')) < 450 and getPropertyFromGroup('notes', i, 'texture') ~= 'noteSkins/glitch-note' then
				removeSpriteShader('notes.members['..i..']')
				setPropertyFromGroup('notes', i, 'texture', 'noteSkins/glitch-note')
				setPropertyFromGroup('notes', i, 'offsetX', getPropertyFromGroup('notes', i, 'offsetX') - 30)
				setPropertyFromGroup('notes', i, 'offsetY', getPropertyFromGroup('notes', i, 'offsetY') - 30)
			end
		end
	end

	for l,prop in ipairs(noteProps) do
		if noteProps[l].hold > 0 then
			noteProps[l].hold = noteProps[l].hold - e
			setProperty('playerStrums.members['..(l - 1)..'].x', _G['defaultPlayerStrumX'..(l - 1)] + noteProps[l].offset[1] + getRandomFloat(-4, 4))
			setProperty('playerStrums.members['..(l - 1)..'].y', _G['defaultPlayerStrumY'..(l - 1)] + noteProps[l].offset[2] + getRandomFloat(-4, 4))
			setProperty('playerStrums.members['..(l - 1)..'].angle', getRandomFloat(-2, 2))
			setProperty('playerStrums.members['..(l - 1)..'].alpha', getRandomFloat(0.5, 0.9))
		elseif noteProps[l].hold < 0 then
			noteProps[l].hold = 0
			for i = 0,getProperty('notes.length')-1 do
				if getPropertyFromGroup('notes', i, 'noteType') ~= 'Glitch Note' and getPropertyFromGroup('notes', i, 'noteData') == (l - 1) then
					setPropertyFromGroup('notes', i, 'blockHit', false)
				end
			end
			for i = 0,getProperty('unspawnNotes.length')-1 do
				if getPropertyFromGroup('unspawnNotes', i, 'noteType') ~= 'Glitch Note' and getPropertyFromGroup('unspawnNotes', i, 'noteData') == (l - 1) then
					setPropertyFromGroup('unspawnNotes', i, 'blockHit', false)
				end
			end

			setProperty('playerStrums.members['..(l - 1)..'].x', _G['defaultPlayerStrumX'..(l - 1)])
			setProperty('playerStrums.members['..(l - 1)..'].y', _G['defaultPlayerStrumY'..(l - 1)])
			setProperty('playerStrums.members['..(l - 1)..'].angle', 0)
			setProperty('playerStrums.members['..(l - 1)..'].alpha', 1)
		end
	end
end

function onSpawnNote(id,nd,nt,isn)
	if nt == 'Glitch Note' then
		setSpriteShader('notes.members['..id..']', 'brightness')
		setShaderFloat('notes.members['..id..']', 'saturation', 0.35)
		setShaderFloat('notes.members['..id..']', 'brightness', -0.1)
		setShaderFloat('notes.members['..id..']', 'contrast', 1.1)
	end
end

function goodNoteHit(id,nd,nt,isn)
	if nt == 'Glitch Note' then
		if noteProps[nd + 1].hold <= 12 then noteProps[nd + 1].hold = noteProps[nd + 1].hold + 4 end
		noteProps[nd + 1].offset = {getRandomFloat(-35, 35), getRandomFloat(-35, 35)}

		for i = 0,getProperty('notes.length')-1 do
			if getPropertyFromGroup('notes', i, 'noteType') ~= 'Glitch Note' and getPropertyFromGroup('notes', i, 'noteData') == nd then
				setPropertyFromGroup('notes', i, 'blockHit', true)
			end
		end
		for i = 0,getProperty('unspawnNotes.length')-1 do
			if getPropertyFromGroup('unspawnNotes', i, 'noteType') ~= 'Glitch Note' and getPropertyFromGroup('unspawnNotes', i, 'noteData') == nd then
				setPropertyFromGroup('unspawnNotes', i, 'blockHit', true)
			end
		end
	end
end