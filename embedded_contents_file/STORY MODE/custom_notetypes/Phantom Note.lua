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
	if getVar('rings') > 0 then return end
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
		debugPrint('a')
		debugPrint('a2: '..getVar('rings'))
		if getVar('rings') > 0 then
			local rings = math.max(getVar('rings') - 1, 0)
			setVar('rings', rings)
			setTextString('ringTxt', tostring(rings))
			return
		end
		debugPrint('d')
		playSound('phantom', 0.35)
		healthDrop = healthDrop + 0.00025
		dropTime = 10
	end
end

function ringHit()
	dropTime = math.max(dropTime - 2, 0)
end