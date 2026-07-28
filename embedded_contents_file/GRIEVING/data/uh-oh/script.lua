function onCreatePost()
    makeAnimatedLuaSprite('griatos', 'characters/ui', getProperty('dad.x') - 320, getProperty('dad.y') - 300)
    addAnimationByPrefix('griatos', 'idle', 'xd', 24, true)
    getObjectOrder('griatos', getObjectOrder('dadGroup'))
    scaleObject('griatos', 2, 2)
    setProperty('griatos.alpha', 0)
    addLuaSprite('griatos')

    makeLuaSprite('griatoseyes', 'characters/eyes', getProperty('dad.x') + 130, getProperty('dad.y') - 160)
    getObjectOrder('griatoseyes', getObjectOrder('dadGroup'))
    scaleObject('griatoseyes', 2, 2)
    setProperty('griatoseyes.alpha', 0)
    addLuaSprite('griatoseyes')
end

function onEvent(n, v1)
    if n == 'fade' then
        if v1 == 'bg' then
            makeLuaSprite('blackOnBF', nil, getMidpointX('boyfriend') - 120, getMidpointY('boyfriend') - 188)
            makeGraphic('blackOnBF', getProperty('boyfriend.width'), getProperty('boyfriend.height'), '000000')
            setProperty('blackOnBF.alpha', 0)
            addLuaSprite('blackOnBF', true)
            doTweenAlpha('blackOnBFAlpha', 'blackOnBF', 1, 10)
            doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 1, 5)
            doTweenAlpha('foredasda', 'fore', 0, 5)
        end
        if v1 == 'hud' then
            doTweenAlpha('camHUDAlpha', 'camHUD', 0, 3)
        end
        if v1 == 'game' then
            setProperty('camGame.alpha', 0)
        end
        if v1 == 'griatos' then
            doTweenAlpha('griatosAlpha', 'griatos', 0.25, 2)
            doTweenAlpha('griatos2Alpha', 'griatoseyes', 1, 1)
        end
    end
end

function opponentNoteHit(index, noteDir)
    cancelTween("OppMove"..noteDir)
    cancelTween("OppAngle"..noteDir)
    setPropertyFromGroup('opponentStrums', noteDir,'y', _G['defaultOpponentStrumY'..noteDir] + (downscroll and 15 or -15))
    setPropertyFromGroup('opponentStrums', noteDir,'angle', getRandomInt(-5, 5))
    noteTweenY("OppMove"..noteDir, noteDir, _G['defaultOpponentStrumY'..noteDir], 1, 'backOut')
    noteTweenAngle("OppAngle"..noteDir, noteDir, 0, 1, 'backOut')
end

function goodNoteHit(index, noteDir, noteType, isSustainNote)
    cancelTween("PlayerMove"..noteDir)
    cancelTween("PlayerAngle"..noteDir)
    setPropertyFromGroup('playerStrums', noteDir,'y', _G['defaultPlayerStrumY'..noteDir] + (downscroll and 15 or -15))
    setPropertyFromGroup('playerStrums', noteDir,'angle', getRandomInt(-5, 5))
    noteTweenY("PlayerMove"..noteDir, (noteDir + 4), _G['defaultPlayerStrumY'..noteDir], 1, 'backOut')
    noteTweenAngle("PlayerAngle"..noteDir, (noteDir + 4), 0, 1, 'backOut')
end