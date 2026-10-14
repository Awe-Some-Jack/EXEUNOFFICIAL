local countdownFinished = false
local firstTime = seenCutscene

function onStartCountdown()
    if not countdownFinished or not firstTime then
        runTimer('countdown', 1)
        cameraFlash('camHUD', "000000", 2, true)
        countdownFinished = true
        firstTime = true
        return Function_Stop
    end

    return Function_Continue
end

function onTimerCompleted(t)
    if t == 'countdown' then
        startCountdown()
        for i = 0, 3 do
            callMethod('opponentStrums.members['..i..'].setPosition', {-120, downscroll and 670 or -50})
            callMethod(  'playerStrums.members['..i..'].setPosition', {1420, downscroll and 670 or -50})
        end
    end
end