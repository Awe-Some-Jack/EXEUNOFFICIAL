function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Flow Notes' then
			setPropertyFromGroup('unspawnNotes', i, 'animSuffix', '-flow')
		end
	end
end