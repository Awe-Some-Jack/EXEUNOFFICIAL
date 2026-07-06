function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'Alt Hey!' then
			setProperty('unspawnNotes['..i..'].noAnimation', true)
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	if nt == 'Alt Hey!' then
		playAnim('boyfriend', 'yeah', true)
		setProperty('boyfriend.specialAnim', true)
		setProperty('boyfriend.heyTimer', 0.6)
	end
end