local changeNotes = false
function onEvent(n, v1)
    if n == 'changenoteSkin' then
        if v1 == '' then
            changeNotes = true
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'texture', 'noteSkins/'..v1)
            end
        end
    end
end

function onSpawnNote(i)
    if changeNotes then
        setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/NOTE_assets_ENDLESS')
    end
end