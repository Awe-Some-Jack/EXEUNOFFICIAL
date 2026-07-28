function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'glitchPose' then
			setProperty('unspawnNotes['..i..'].noAnimation', true)
		end
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if nt == 'glitchPose' then
		playAnim('dad', getProperty('singAnimations['..nd..']')..(getProperty('singAnimations['..nd..']') == 'singLEFT' and 'G' or 'g'), true)
		setProperty('dad.holdTimer', 0)
	end
end