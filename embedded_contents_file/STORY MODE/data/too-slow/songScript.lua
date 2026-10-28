function onCreatePost()
    setProperty('BlackGraphicGame.alpha', 1)
    for _, hideHud in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do setProperty(hideHud..'.alpha', 0) end
end

function onCountdownStarted()
    for i = 0, 7 do setPropertyFromGroup('strumLineNotes', i, 'y', downscroll and 800 or -400) end
end

function onSongStart() doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 0, 4) end

local waveX = false
local waveY = false

local intensity = 0.2
local speed = 250

local tooSlowEvents = {
    -- SONG EVENTS --
    ['tweenObject'] = function(spr, alp, time)
        cancelTween(spr..'AlphaTween')
        doTweenAlpha(spr..'AlphaTween', spr, alp, time)
    end,
    ['darkBG'] = function(darken)
        if darken == 'true' then
            for _, frontBGOp in ipairs({'b1_front', 'ojos_tails', 'eggman'}) do
                doTweenAlpha(frontBGOp..'AlphaTween', frontBGOp, 0.4, 0.9)
            end
            doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0.7, 0.9)
        else
            doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0, 0.5)
            for _, frontBGOp in ipairs({'b1_front', 'ojos_tails', 'eggman'}) do
                doTweenAlpha(frontBGOp..'AlphaTween', frontBGOp, 1, 0.5)
            end
        end
    end,
    ['revealHUD'] = function()
        for _, cmereHud in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do doTweenAlpha(cmereHud..'Alpha', cmereHud, 1, 0.5) end
    end,
    ['redGraphicTween'] = function(show)
        if show == 'true' then
            doTweenAlpha('RedGraphicGameBlendADDAlpha', 'RedGraphicGameBlendADD', 0.8, 5)
        else
            cancelTween('RedGraphicGameBlendADDAlpha')
            doTweenAlpha('RedGraphicGameBlendADDAlpha', 'RedGraphicGameBlendADD', 0, 0.5)
        end
    end,

    -- MODCHARTS --
    ['revealNotes'] = function(strums)
        if strums == 'opponent' then
            for i = 0, 3 do
                doTweenY(i..'OppNoteY', 'opponentStrums.members['..i..']', _G['defaultOpponentStrumY'..i], math.random(2, 4) + (i * 0.1), 'smootherStepOut')
            end
        elseif strums == 'player' then
            for i = 0, 3 do
                doTweenY(i..'PlayerNoteY', 'playerStrums.members['..i..']', _G['defaultPlayerStrumY'..i], math.random(2, 4) + (i * 0.1), 'smootherStepOut')
            end
        end
    end,
    ['notesMovement'] = function(mode)
        if mode == 'x' then
            waveX = true
            waveY = false
            for i = 0, 3 do doTweenY(i..'OppY','opponentStrums.members['..i..']', _G['defaultOpponentStrumY'..i], 0.9, 'circOut') doTweenY(i..'PlayerY','playerStrums.members['..i..']', _G['defaultPlayerStrumY'..i], 0.9, 'circOut') end
        elseif mode == 'y' then
            waveX = false
            waveY = true
        end
    end,
    ['setModchartSettings'] = function(i, s)
        intensity = i
        speed = s
    end,
}

function onEvent(e, v1, v2)
    if e == 'tooSlowEvents' then
        local split = stringSplit(v2, ', ')
        tooSlowEvents[v1](split[1], split[2], split[3])
    end
end
local time = 0
function onUpdatePost(elapsed)
    time = time + elapsed / 2

    if waveX then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') + (math.cos(time / speed + i)) * intensity)
        end
    end
    if waveY then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + (math.sin(getSongPosition() / speed + i)) * intensity)
        end
    end
end