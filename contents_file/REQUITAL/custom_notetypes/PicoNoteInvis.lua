local anims = {
    'singLEFT',
    'singDOWN',
    'singUP',
    'singRIGHT'
}

function onSpawnNote(index, noteDir, noteType) if noteType == 'PicoNoteInvis' then setProperty('notes.members[0].visible', not getProperty('notes.members[0].gfNote')) end end

function opponentNoteHit(index, noteDir, noteType)
    if noteType == 'PicoNoteInvis' then
        callMethod('opponentStrums.members['..noteDir..'].playAnim', {'static', true})
        playAnim('gf', anims[noteDir + 1], true)
    end
end