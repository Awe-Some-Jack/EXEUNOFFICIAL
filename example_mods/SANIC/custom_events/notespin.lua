function onEvent(n,v1,v2)
	if n == 'notespin' then
		for i = 0,7 do
			cancelTween('notes'..i)
			if math.abs(getProperty('strumLineNotes.members['..i..'].angle')) >= 360 then setProperty('strumLineNotes.members['..i..'].angle', 0) end
			noteTweenAngle('notes'..i, i, tonumber(v1), tonumber(v2), 'cubeOut')
		end
	end
end