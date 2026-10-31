local allowCountdown = false
local finalCutscene = false
local seenVideo = false

function onCreate()
    if not seenCutscene then setProperty('camGame.visible', false) setProperty('camHUD.visible', false) end
end

function onStartCountdown()
    if not allowCountdown and not seenCutscene then
        startVideo('YRC')
        allowCountdown = true
        return Function_Stop
    end
    setProperty('camGame.visible', true) setProperty('camHUD.visible', true)
    return Function_Continue
end

function onEndSong()
    if seenVideo == false then
        finalCutscene = true
        startVideo('tripletrouble')
        setProperty('camGame.visible', false)  setProperty('camHUD.visible', false) setProperty('camOther.visible', false)
        seenVideo = true
        return Function_Stop
    end

    return Function_Continue
end

function onEndVideo()
    if finalCutscene then endSong()
    else startCountdown() end
end