function onCreatePost()
    for i = 0, getProperty('unspawnNotes.length')-1 do
        setPropertyFromGroup('unspawnNotes', i, 'copyAlpha', false)
    end
end

function onUpdate(elapsed)
    for i = 0, getProperty('notes.length') - 1 do
        setProperty('notes.members['..i..'].alpha', (math.sin(math.abs(getProperty('notes.members['..i..'].distance') / 125) + (math.pi / 2)) / 2) + 0.525)
    end
end