function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'NoteShoot' then
			setProperty('unspawnNotes['..i..'].texture', 'noteSkins/bullet_notes')
			setProperty('unspawnNotes['..i..'].noAnimation', true)
			setProperty('unspawnNotes['..i..'].noMissAnimation', true)
			setProperty('unspawnNotes['..i..'].ignoreNote', true)
			setProperty('unspawnNotes['..i..'].ratingDisabled', true)
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	if isn then return end
	if nt == 'NoteShoot' then
		playAnim('gf', 'shoot'..((nd % 2) + 1), true)
		setProperty('gf.specialAnim', true)
		playAnim('dad', 'dodged', true)
		setProperty('dad.specialAnim', true)
	end
end