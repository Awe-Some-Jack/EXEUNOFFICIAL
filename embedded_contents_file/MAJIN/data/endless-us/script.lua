local chillModchart = false
local fastModchart = false
function onEvent(n, v1)
    if n == 'USModchart' then
        if v1 == 'slow' then
            chillModchart = true
        elseif v1 == 'fast' then
            chillModchart = false
            fastModchart = true
        end
    end
    if n == 'fade' then
        if v1 == 'hud' then
            doTweenAlpha('camHUDAlpha', 'camHUD', 0, 3)
        end
    end
end

local holdMove = 0
function onUpdatePost(elapsed)
    holdMove = holdMove + elapsed * 5
    if chillModchart then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') + math.cos(holdMove + i) * 0.2)
            setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + math.sin(holdMove + i) * 0.1)
        end
    end
    if fastModchart then
        holdMove = holdMove + elapsed * 10
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') + math.cos(holdMove + i) * 0.3)
            setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + math.sin(holdMove + i) * 0.5)
        end
    end
end