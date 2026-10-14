local allowCountdown = false

function onStartCountdown()
    if not allowCountdown and not seenCutscene and isStoryMode then
        runTimer('xdd', 0.1)
        allowCountdown = true
        return Function_Stop
    end
    return Function_Continue
end

function onVideoCompleted()
    startCountdown()
end

function onTimerCompleted(t) if t == 'xdd' then startVideo('soulless') end end