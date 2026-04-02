function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	health = getProperty('health')
	if isSustainNote then
		setProperty('health', health + 0.015)
	else
		setProperty('health', health + 0.010)
	end
end

function onBeatHit()
	if curBeat % 2 == 0 and getProperty('dad.animation.curAnim.name') == 'idle' then
		playAnim('dad', 'idle', true)
	end
	if curBeat % 2 == 0 and getProperty('boyfriend.animation.curAnim.name') == 'idle' then
		playAnim('boyfriend', 'idle', true)
	end
end