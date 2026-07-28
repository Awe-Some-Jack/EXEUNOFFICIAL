function onCreatePost()
	for i = 0, getProperty('eventNotes.length') - 1 do
        if getPropertyFromGroup('eventNotes', i, 'event') == 'fleetwayAnim' then
			local dachar = stringSplit(getPropertyFromGroup('eventNotes', i, 'value1'), ',')
        	addCharacterToList(dachar[2], 'dad')
        end
    end
end

function onEvent(n,v1,v2)
	if n == 'fleetwayAnim' then
		local char = stringSplit(v1, ',')
		triggerEvent('Change Character', char[1], char[2])
		playAnim(char[1], v2, true)
		setProperty(char[1]..'.specialAnim', true)
	end
end