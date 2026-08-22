local seenVideo = false

function onEndSong()
    if seenVideo == false then
        startVideo('tripletrouble')
        setProperty('camGame.visible', false)  setProperty('camHUD.visible', false)
        seenVideo = true
        return Function_Stop
    end

    return Function_Continue
end

function onEndVideo() endSong() end