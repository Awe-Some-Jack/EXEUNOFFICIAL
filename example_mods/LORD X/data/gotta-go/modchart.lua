local separation = 50

function onCountdownStarted()
	for i = 0,3 do
		setProperty('opponentStrums.members['..i..'].visible', false)
		setProperty('playerStrums.members['..i..'].color', getColorFromHex('8B2020'))
	end

	for i = 0,getProperty('unspawnNotes.length') - 1 do
		if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
			setPropertyFromGroup('unspawnNotes', i, 'alpha', 0.0001)
		end
	end
end

function onSongStart()
	for i = 0,3 do
		noteTweenX('center'..i, i + 4,
			(screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + (getProperty('playerStrums.members['..i..'].width') + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i,
		0.5, 'cubeInOut')
	end
end

function onSpawnNote(id)
	if not getPropertyFromGroup('notes', id, 'mustPress') then
		setPropertyFromGroup('notes', id, 'alpha', 0.0001)
	else
		setProperty('notes.members['..id..'].color', getColorFromHex('8B2020'))
	end
end

function onUpdatePost()
	for i = 0,3 do
		setProperty('opponentStrums.members['..i..'].visible', false)
	end
	for i = 0,getProperty('notes.length') - 1 do
		if getPropertyFromGroup('notes', i, 'mustPress') == false then
			setPropertyFromGroup('notes', i, 'alpha', 0.0001)
		end
	end
end
