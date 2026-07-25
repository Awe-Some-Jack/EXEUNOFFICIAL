local seenVideo = false

function onEndSong()
    if seenVideo == false then
        cancelTween('BlackGraphicOtherAlpha')
        setProperty('BlackGraphicOther.alpha', 0)
        startVideo('soundtestcodes')
        setProperty('camGame.visible', false)  setProperty('camHUD.visible', false)
        seenVideo = true
        return Function_Stop
    end

    return Function_Continue
end

function onEndVideo()
    setProperty('BlackGraphicOther.alpha', 1)
    endSong()
end