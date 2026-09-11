local first = true


function onCreate()
    if seenCutscene or not isStoryMode then return end

    precacheSound('introSong')
    addCharacterToList('exetior-intro', 'dad')

end

local _cut = false
function onSongStart() setProperty('cameraSpeed', 1) end
function onStartCountdown()
    if seenCutscene or not isStoryMode then return end
    if first then
        _cut = true
        playAnim('gf', 'danceRight', true)
        -- PROPERTIES --
        setProperty('camHUD.alpha', 0)
        setProperty('cameraSpeed', 999)
        callMethod('camGame.targetOffset.set', {-140, 140})
        setProperty('camGame.zoom', 0.8)
        -- TIMERS --
        runTimer('startIntro', 0.01)

        runTimer('tweenCamToBF', 3)

        runTimer('u!', 4.72)

        runTimer('tweenBackToExetior', 6.5)

        runTimer('tweenToExetior2', 9.5)

        runTimer('tweenToExetior3', 12.5)

        runTimer('startCountdown', 13.5)

        first = false
        return Function_Stop
    end
    _cut = false
end

function onUpdatePost()
    if _cut then
        if getProperty('gf.animation.curAnim.name') == 'danceLeft' and getProperty('gf.animation.curAnim.finished') then
            playAnim('gf', 'danceRight', true)
            if getProperty('boyfriend.animation.curAnim.name') == 'idle' then playAnim('boyfriend', 'idle', true) end
            runHaxeCode([[
                for (obj in PlayState.instance.members)
                {
                    if (obj != null && obj.ID != null && obj.ID == 123)
                    {
                        obj.animation.play('eggman', true);
                        break;
                    }
                }
            ]])
        end
        if getProperty('gf.animation.curAnim.name') == 'danceRight' and getProperty('gf.animation.curAnim.finished') then
            playAnim('gf', 'danceLeft', true)
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'startIntro' then
        playSound('introSong', 1, 'intro')
        triggerEvent('Change Character', 'dad', 'exetior-intro')
        playAnim('dad', 'intro')
    end
    if tag == 'tweenCamToBF' then
        doTweenX('camXTween', 'camGame.targetOffset', 450, 2, 'cubeInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 160, 2, 'cubeInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 1, 2, 'cubeInOut')
    end
    if tag == 'u!' then
        playAnim('boyfriend', 'singDOWN')
    end
    if tag == 'tweenBackToExetior' then
        doTweenX('camXTween', 'camGame.targetOffset', -140, 1.3, 'sineInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 120, 1.3, 'sineInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 0.85, 1.3, 'sineInOut')
    end
    if tag == 'tweenToExetior2' then
        doTweenX('camXTween', 'camGame.targetOffset', -140, 1, 'sineInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 150, 1, 'sineInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 1, 1, 'sineInOut')
    end

    if tag == 'tweenToExetior3' then
        doTweenX('camXTween', 'camGame.targetOffset', 0, 2, 'sineInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 0, 2, 'sineInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 0.85, 2, 'sineInOut')
    end
    if tag == 'startCountdown' then
        startCountdown()
        doTweenAlpha('HUDTween', 'camHUD', 1, 1)
    end
end

function onSoundFinished(tag)
    if tag == 'intro' then
        triggerEvent('Change Character', 'dad', 'exetior')
    end
end