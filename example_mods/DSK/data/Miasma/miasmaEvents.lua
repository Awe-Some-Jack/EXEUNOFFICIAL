-- EVENT VARS --
local startBeating = false

-- EVENTS --
function onSongStart()
    setProperty('BlackGraphicHUD.alpha', 1)
end

function onSongStart()
    doTweenAlpha('blackHUDAlpha', 'BlackGraphicHUD', 0, 0.4)
end

function onEvent(e, v1, v2)
    if e == 'miasmaEvents' then
        if v1 == 'idk' then

        end
    end
end

function onBeatHit()
    if startBeating then triggerEvent('chromFlash', '0.6, 0', '0.5, circOut') end
end