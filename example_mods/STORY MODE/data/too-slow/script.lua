function opponentNoteHit(id,nd,nt,isn)
    if isn then return end
    health = getProperty('health')
    if getProperty('health') > 0.10 then
        setProperty('health', health - 0.016)
    end
end

function onUpdatePost()
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
end