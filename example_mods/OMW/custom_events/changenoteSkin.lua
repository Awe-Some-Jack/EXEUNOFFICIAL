local changeNotes = false
function onEvent(n, v1)
    if n == 'changenoteSkin' then
        for i = 0, 8 do
            if i ~= 6 then
                setPropertyFromGroup('strumLineNotes', i, 'texture', 'noteSkins/'..v1)
            end
        end
        for i = 0,getProperty('unspawnNotes.length')-1 do
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/'..v1)
        end
        for i = 0,getProperty('notes.length')-1 do
            setPropertyFromGroup('notes', i, 'texture', 'noteSkins/'..v1)
        end
    end
end