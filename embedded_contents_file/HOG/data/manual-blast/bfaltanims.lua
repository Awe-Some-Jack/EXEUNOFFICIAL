--[==[local altAnimsXd = false

function onUpdatePost(e)
	if curBeat >= 188 and not altAnimsXd then
		altAnimsXd = true
		setProperty('boyfriend.idleSuffix', '-alt')
		for i = 0,getProperty('unspawnNotes.length')-1 do
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then setPropertyFromGroup('unspawnNotes', i, 'animSuffix', '-alt') end
		end
		for i = 0,getProperty('notes.length')-1 do
			if getPropertyFromGroup('notes', i, 'mustPress') then setPropertyFromGroup('notes', i, 'animSuffix', '-alt') end
		end
	end
end

function noteMiss()
	if altAnimsXd then setProperty('boyfriend.holdTimer', 0) end
end]==]