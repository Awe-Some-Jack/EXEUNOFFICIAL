local allowCountdown = false

function onCreatePost()
    if not seenCutscene and cutsceneSkippable then
        local skipMsg = (buildTarget == 'ios' or buildTarget == 'android') and 'Press and hold to skip cutscene!' or 'Hold "SPACE" to skip cutscene!'
        makeLuaText('skipTxt', skipMsg, 0, 24, 655)
        setTextSize('skipTxt', 30)
        setTextFont('skipTxt', 'sonic4.ttf')
        setProperty('skipTxt.alpha', 0)
        doTweenAlpha('skipTxt', 'skipTxt', 1, 2)
        setObjectCamera('skipTxt', 'other')
        addLuaText('skipTxt')
        runTimer('adasdas', 5)
    end
end

function onStartCountdown()
    if not allowCountdown and not seenCutscene then
        startVideo('tooslow')
        allowCountdown = true
        return Function_Stop
    end
    return Function_Continue
end

function onEndVideo() startCountdown() end

function onCountdownStarted()
    removeLuaText('skipTxt', true)
end

function onTimerCompleted(t)
    if t == 'adasdas' then
        doTweenAlpha('skipTxt', 'skipTxt', 0, 2)
    end
end