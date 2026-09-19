function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'Fast Notes' then
			setProperty('unspawnNotes['..i..'].multSpeed', getRandomFloat(1.325, 1.35))
		end
	end
end