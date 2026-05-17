function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Ring Note' then
			setProperty('unspawnNotes['..i..'].texture', 'noteSkins/ring')
			setProperty('unspawnNotes['..i..'].noteSplashData.disabled', true)
			setProperty('unspawnNotes['..i..'].ignoreNote', true)
			setProperty('unspawnNotes['..i..'].blockHit', true)

			setProperty('unspawnNotes['..i..'].copyX', false)
			setProperty('unspawnNotes['..i..'].copyAlpha', false)
		end
	end
end
