function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'specialPose' then
			setProperty('unspawnNotes['..i..'].noAnimation', true)
		end
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if nt == 'specialPose' then
		local pose = {'yeah', 'xd', 'yeah', 'xd'}
		playAnim('dad', pose[nd + 1], true)
		setProperty('dad.holdTimer', 0)
	end
end