local canMidFade = false

function onCreatePost()
    for i = 0, getProperty('unspawnNotes.length')-1 do
        setPropertyFromGroup('unspawnNotes', i, 'copyAlpha', false)
    end
end

function onUpdatePost()
    if canMidFade then
        for i = 0, getProperty('notes.length') - 1 do
            setProperty('notes.members['..i..'].alpha', (math.sin(math.abs(getProperty('notes.members['..i..'].distance') / 125) + (math.pi / 2)) / 2) + 0.525)
        end
    end
end

function onStepHit()
    if curStep == 800 or curStep == 1568 then
        canMidFade = true
    elseif curStep == 1040 or curStep == 1824 then
        canMidFade = false
    end
end