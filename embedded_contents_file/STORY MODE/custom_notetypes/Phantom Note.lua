local dropTime = 0
local healthDrop = 0

function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Phantom Note' then
			setProperty('unspawnNotes['..i..'].texture', 'noteSkins/dani')
			setProperty('unspawnNotes['..i..'].noteSplashDisabled', true)
			setProperty('unspawnNotes['..i..'].ignoreNote', true)
			setProperty('unspawnNotes['..i..'].noAnimation', true)
			setProperty('unspawnNotes['..i..'].hitHealth', 0)
			setProperty('unspawnNotes['..i..'].ratingDisabled', true)
		end
	end
end

function onUpdatePost(e)
	if dropTime > 0 then
		dropTime = dropTime - e
		addHealth(-healthDrop * (e / (1 / 120)))
	end
	if dropTime <= 0 then
		healthDrop = 0
		dropTime = 0
	end
end

function goodNoteHit(id,nd,nt,isn)
	if not isn and nt == 'Phantom Note' then
		healthDrop = healthDrop + 0.00025
		dropTime = 10
	end
end

function ringHit()
	dropTime = math.max(dropTime - 2, 0)
end