function onCreatePost()
    makeAnimatedLuaSprite('caraputa', 'characters/caraM', getProperty('gf.x') + 80 , getProperty('gf.y') + 266)
    addAnimationByPrefix('caraputa', 'idle', 'Símbolo 408', 24, true)
    setObjectOrder('caraputa', getObjectOrder('gfGroup') + 1)
    addLuaSprite('caraputa', false)

    makeLuaSprite('ojosPuta', 'characters/ojosM', getProperty('gf.x') + 140, getProperty('gf.y') + 331)
    setObjectOrder('ojosPuta', getObjectOrder('gfGroup') + 1)
    scaleObject('ojosPuta', 0.75, 1)
    addLuaSprite('ojosPuta', false)

    makeLuaSprite('ojosPuta2', 'characters/ojosM2', getProperty('gf.x') + 115, getProperty('gf.y') + 301)
    setObjectOrder('ojosPuta2', getObjectOrder('gfGroup') + 1)
    scaleObject('ojosPuta2', 0.82, 0.9)
    addLuaSprite('ojosPuta2', false)

    for _, yes in ipairs({'caraputa', 'ojosPuta', 'ojosPuta2'}) do
        setProperty(yes..'.visible', false)
    end
end

function onSectionHit() doTweenX('ojosPutaX', 'ojosPuta', (mustHitSection and getProperty('gf.x') + 130 or getProperty('gf.x') + 100), 0.9, 'smootherStepInOut') end

local holdMove = 0
function onUpdatePost(elapsed)
    holdMove = holdMove + elapsed

    callMethod('ojosPuta.setPosition', {
        getProperty('ojosPuta.x') + math.cos(holdMove + 0.5) * 0.05,
        getProperty('ojosPuta.y') + math.sin(holdMove + 0.5) * 0.05
    })
end

function onEvent(eventName, value1, value2)
    if eventName == 'fateEvents' then
        local split = stringSplit(value2, ',')
        if value1 == 'stageMode' and split[1] == '1' then
            for _, yes in ipairs({'caraputa', 'ojosPuta', 'ojosPuta2'}) do setProperty(yes..'.visible', true) end
        end
        if value1 == 'stageMode' and split[1] == 'fadeStage' and split[2] == ' gf' then
            for _, yes in ipairs({'caraputa', 'ojosPuta', 'ojosPuta2'}) do doTweenAlpha(yes..'Fade', yes, 0, 2) end
        end
        if value1 == 'stageMode' and split[1] == '2' then
            for _, yes in ipairs({'caraputa', 'ojosPuta', 'ojosPuta2'}) do removeLuaSprite(yes, true) end
        end
    end
end