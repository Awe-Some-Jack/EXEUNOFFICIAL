
--[[Writting event ideas here:

- Start everything all black except the Countdown sprites
- Fade the screen out with Xeno only visible. Zooming out slowly, then going back on the center of the stage.
- The camera tweens slowly to whoever is singing. Once Xeno starts laughing, the game will flash red, and the cameras will move as usual. There will be some zooms in and out over there.
- I have no more ideas LMAO.

--]]

local ogNotesPosition = {}
function onCreatePost()
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('BlackGraphicGame.alpha', 1)
    for _, hideHud in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do
        setProperty(hideHud..'.alpha', 0)
    end
    ogNotesPosition = {getPropertyFromGroup('strumLineNotes', i, 'x'), getPropertyFromGroup('strumLineNotes', i, 'y')}
end

function onCountdownStarted()
    for i = 0, 7 do
        if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll', true) then
            setPropertyFromGroup('strumLineNotes', i, 'y', 800)
        else
            setPropertyFromGroup('strumLineNotes', i, 'y', -400)
        end
    end
end

function onSongStart()
     doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 0, 4)
end

function onTweenCompleted(tag)
    for i = 0, 7 do
        if tag == i..'NoteY' then
            ogNotesPosition = {getPropertyFromGroup('strumLineNotes', i, 'x'), getPropertyFromGroup('strumLineNotes', i, 'y')}
        end
    end
end

local intensity = 0.2
local speed = 250

function onEvent(e, v1, v2)
    if e == 'tooSlowEvents' then
        if v1 == '' then
            if v2 == '' then
                
            end
        end
    end
end
function onStepHit()
    if curStep == 220 then
        for i = 0, 3 do
            if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll', true) then
                noteTweenY(i..'NoteY', i, 570, math.random(2, 4) + (i * 0.1), 'smootherStepOut')
            else
                noteTweenY(i..'NoteY', i, 50, math.random(2, 4) + (i * 0.1), 'smootherStepOut')
            end
        end
    end
    if curStep == 360 then
        for i = 4, 7 do
            if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll', true) then
                noteTweenY(i..'NoteY', i, 570, math.random(2, 4) + (i * 0.1), 'smootherStepOut')
            else
                noteTweenY(i..'NoteY', i, 50, math.random(2, 4) + (i * 0.1), 'smootherStepOut')
            end
        end
    end
    if curStep == 748 then
        doTweenAlpha('camHUDAlpha', 'camHUD', 0, 0.9)
    end
    if curStep == 752 then
        for _, frontBGOp in ipairs({'b1_front', 'ojos_tails', 'eggman'}) do
            doTweenAlpha(frontBGOp..'AlphaTween', frontBGOp, 0.4, 0.9)
        end
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0.7, 0.9)
    end
    if curStep == 767 then
        doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 1, 0.1)
    end
    if curStep == 772 then
        setProperty('BlackGraphicGame.alpha', 0)
        cameraFlash('camGame', 'FF0000', 2, true)
    end
    if curStep == 796 then
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0, 0.5)
        for _, frontBGOp in ipairs({'b1_front', 'ojos_tails', 'eggman'}) do
            doTweenAlpha(frontBGOp..'AlphaTween', frontBGOp, 1, 0.5)
        end
        doTweenAlpha('camHUDAlpha', 'camHUD', 1, 0.4)
        for _, cmereHud in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do
            doTweenAlpha(cmereHud..'Alpha', cmereHud, 1, 0.5)
        end
    end
    if curStep == 920 then
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0.7, 0.7)
    end
    if curStep == 928 then
        cancelTween('BlackGraphicBehindAlpha')
        setProperty('BlackGraphicBehind.alpha', 0)
        cameraFlash('camHUD', 'FF0000', 0.8, true)
    end
    if curStep == 1568 then
        doTweenAlpha('camHUDAlpha', 'camHUD', 0, 0.9)
    end
    if curStep == 1626 then
        cameraShake('camGame', 0.006, 1.1)
    end
    if curStep == 1668 then
        for _, frontBGOp in ipairs({'b1_front', 'ojos_tails', 'eggman'}) do
            doTweenAlpha(frontBGOp..'AlphaTween', frontBGOp, 0.4, 1)
        end
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0.8, 1)
    end
    if curStep == 1696 then
        doTweenAlpha('camHUDAlpha', 'camHUD', 1, 0.9)
        cameraFlash('camGame', 'FF0000', 0.8, true)
        setProperty('BlackGraphicBehind.alpha', 0)
        for _, frontBGOp in ipairs({'b1_front', 'ojos_tails', 'eggman'}) do
            setProperty(frontBGOp..'.alpha', 1)
        end
    end
    if curStep == 1992 or curStep == 2056 or curStep == 2120 or curStep == 2184 then
        doTweenAlpha('RedGraphicGameBlendADDAlpha', 'RedGraphicGameBlendADD', 0.8, 5)
        
    end
    if curStep == 2016 or curStep == 2080 or curStep == 2144 or curStep == 2208 then
        cancelTween('RedGraphicGameBlendADDAlpha')
        doTweenAlpha('RedGraphicGameBlendADDAlpha', 'RedGraphicGameBlendADD', 0, .5)
    end
    if curStep == 1955 then
        intensity = 0.4
        speed = 50
    end
    if curStep == 2209 then
        cameraShake('camGame', 0.006, 4)
    end
    if curStep == 2220 then
        doTweenAlpha('camHUDAlpha', 'camHUD', 0, 2)
    end
    if curStep == 2249 then
        setProperty('camGame.alpha', 0)
    end
end
local time = 0
function onUpdatePost(elapsed)
    time = time + elapsed / 2
    if curStep >= 788 then
        for i = 0, 7 do
            noteTweenY(i, i, getPropertyFromGroup('strumLineNotes', i, 'y') + (math.sin(getSongPosition()/speed+i)) * intensity, 0.001)
        end
    end
    if curStep >= 1056 then
        for i = 0, 7 do
            noteTweenX(i, i, getPropertyFromGroup('strumLineNotes', i, 'x') + (math.sin(getSongPosition()/speed + i)) * 0.2, 0.001)
            noteTweenY(i..'Y', i, ogNotesPosition[2], 0.9, 'circOut')
        end
    end
end