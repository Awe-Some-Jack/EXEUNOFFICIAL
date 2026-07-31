local allowCountdown = false
local finalCutscene = false
local seenVideo = false

function onCreatePost()
    if not seenCutscene then
        makeLuaText('skipTxt', 'Hold "SPACE" to skip cutscene!', 0, 24, 655)
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

function onEndVideo()
    if finalCutscene then endSong()
    else startCountdown() end
end

function onCountdownStarted()
    removeLuaText('skipTxt', true)
end

function onTimerCompleted(t)
    if t == 'adasdas' then
        doTweenAlpha('skipTxt', 'skipTxt', 0, 2)
    end
end

function onEndSong()
    if seenVideo == false then
        finalCutscene = true
        startVideo('YRC')
        setProperty('camGame.visible', false)  setProperty('camHUD.visible', false)
        seenVideo = true
        return Function_Stop
    end
    
    return Function_Continue
end