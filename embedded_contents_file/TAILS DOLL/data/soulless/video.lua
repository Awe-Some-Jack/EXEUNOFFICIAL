local allowCountdown = false

function onStartCountdown()
    if not allowCountdown and not seenCutscene and isStoryMode then
        startVideo('soulless')
        allowCountdown = true
        return Function_Stop
    end
    return Function_Continue
end

function onVideoCompleted()
    startCountdown()
end