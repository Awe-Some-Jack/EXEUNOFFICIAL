local changeNotes = false
function onEvent(n, v1)
    if n == 'changenoteSkin' then
        if v1 == '' then
            changeNotes = true
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'texture', 'noteSkins/'..v1)
            end
            for i = 0,getProperty('unspawnNotes.length')-1 do
                setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/'..v1) 
            end
            for i = 0,getProperty('notes.length')-1 do
                setPropertyFromGroup('notes', i, 'texture', 'noteSkins/'..v1)
            end
        end
    end
end