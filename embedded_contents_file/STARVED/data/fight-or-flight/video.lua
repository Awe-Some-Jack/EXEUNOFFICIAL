local allowCountdown = false

function onCreatePost() if not seenCutscene and isStoryMode then setProperty('camGame.visible', false) setProperty('camHUD.visible', false) end end

function onStartCountdown()
    if not allowCountdown and not seenCutscene and isStoryMode then
        startVideo('intro')
        allowCountdown = true
        return Function_Stop
    end
    setProperty('camGame.visible', true)
    setProperty('camHUD.visible', true)
    return Function_Continue
end

function onVideoCompleted()
    startCountdown()
end