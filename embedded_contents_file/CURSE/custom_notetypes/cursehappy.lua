local danceAnims = {
	[0] = 'singLEFT-dance',
	[3] = 'singRIGHT-dance'
}

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if noteType ~= 'cursehappy' then return end

	local anim = danceAnims[noteData]
	if anim == nil then return end

	playAnim('dad', anim, true)
end
