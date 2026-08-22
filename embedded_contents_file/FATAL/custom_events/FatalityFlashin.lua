function onCreate()
    makeAnimatedLuaSprite('FlashingShitFatality','statix',0,0)
    addAnimationByPrefix('FlashingShitFatality','glitch','idle',44,true)
    scaleObject('FlashingShitFatality',3.2,2.45)
    setObjectCamera('FlashingShitFatality','hud')
end

function onEvent(name,value1)
    if name == 'FatalityFlashin' then
        if value1 ~= 'flash' and value1 ~= '3rdbg' then return end
        addLuaSprite('FlashingShitFatality',true)
        playSound('simplejumpsound')
        if value2 ~= '' and value2 ~= nil then
            runTimer('destroyFlashShitfatality',value2/5)
        else
            runTimer('destroyFlashShitfatality',0.2)
        end
    end
end
function onTimerCompleted(tag)
    if tag == 'destroyFlashShitfatality' then
        removeLuaSprite('FlashingShitFatality',false)
    end
end