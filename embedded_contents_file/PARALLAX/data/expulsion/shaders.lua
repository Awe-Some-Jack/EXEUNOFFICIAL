local started = false;
local useRedBG = false;
local tweening = false
local tweening4 = false

luaDebugMode = true;
function onCreate()
    if shadersEnabled then 
        initLuaShader('glow')
    end
end

function onCreatePost()
    if shadersEnabled then
        makeLuaSprite('sexo')
        setSpriteShader('sexo', 'brightness')
        setShaderFloat('sexo', 'brightness', 0)
        setShaderFloat('sexo', 'saturation', 1)
        setShaderFloat('sexo', 'contrast', 1)

        makeLuaSprite('sexo2')
        setSpriteShader('sexo2', 'brightness')
        setShaderFloat('sexo2', 'saturation', 1)
        setShaderFloat('sexo2', 'contrast', 1)
        makeLuaSprite('chromX', nil, 0, 0)

        setProperty('sexo.y', 1);
        setProperty('sexo2.y', 1);
        -- setProperty('glitch.y', 1);

        for uniform, neutral in pairs({brightness = 0, contrast = 1, saturation = 1}) do
            addPrunedFilter('camGame', 'sexo', uniform, neutral)
        end
    end
end

function onSongStart()
    if shadersEnabled then 
        setSpriteShader("gf", "glow")
        setShaderFloat("gf", "glowSize", 5.0)
        setShaderFloat("gf", "glowIntensity", 1)
        setShaderFloatArray("gf", 'glowColor', {0.7, 0.0, 0.0})
        started = true;
    end
end

function onStepHit()
    if curStep == 1215 or curStep == 1695 then
        useRedBG = true;
    end

    if curStep == 1647 then
        useRedBG = false;
    end
end

function onEvent(eventName, value1, value2)
    if shadersEnabled then
        
        if eventName == "bloomFlash" and flashingLights then
            local bloomValues = stringSplit(value1, ',')
            local tweenSettings = stringSplit(value2, ',')
            cancelTween('sexoX')
            cancelTween('sexoX2')
            setProperty('sexo.x', tonumber(bloomValues[1]))
            setProperty('sexo2.x', tonumber(bloomValues[1]))
            doTweenX('sexoX', 'sexo', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            doTweenX('sexoX2', 'sexo2', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            tweening = true
        end
        
        if eventName == 'pixelshadertween' then
            pixelChange = true
            local boolDefault = stringSplit(value1, ',')
            local set = boolDefault[1]
            local fin = boolDefault[2]
            local valueZoom = stringSplit(value2, ',')
            local steps = valueZoom[1]
            local ease = valueZoom[2]
            cancelTween('pixel')
            setProperty('pixel.x', set)
            doTweenX('pixel', 'pixel', fin, steps, ease);
        end
        
        if eventName == "saturationFlash" and flashingLights then
            local satValues = stringSplit(value1, ',')
            local tweenSettings = stringSplit(value2, ',')
            cancelTween('sexoY')
            cancelTween('sexoY2')
            setProperty('sexo.y', tonumber(satValues[1]))
            setProperty('sexo2.y', tonumber(satValues[1]))
            doTweenY('sexoY', 'sexo', tonumber(satValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            doTweenY('sexoY2', 'sexo2', tonumber(satValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            tweening4 = true
        end
    end
end

local thing = 0;
function onUpdatePost(e)
    if shadersEnabled then
        
        setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
        setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))
        
        setShaderFloat('sexo2', 'brightness', getProperty('sexo2.x') * 2)
        setShaderFloat('sexo2', 'contrast', 1 + (getProperty('sexo2.x') * 4))
        
        setShaderFloat('sexo', 'saturation', getProperty('sexo.y'))
        setShaderFloat('sexo2', 'saturation', getProperty('sexo2.y'))
        
        if started then
            setShaderFloat("gf", "glowIntensity", getProperty('gf.alpha'))
        end
    end
    
    if getProperty('gf.alpha') < 1 and getProperty('dad.alpha') == 1 or useRedBG then
        setBlendMode('gf', 'screen')
    else
        setBlendMode('gf', 'nothing')
    end

--     thing = thing + e
--     setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
--     setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))

--     setShaderFloat('sexo2', 'brightness', getProperty('sexo2.x') * 2)
--     setShaderFloat('sexo2', 'contrast', 1 + (getProperty('sexo2.x') * 4))

--     setShaderFloat('sexo', 'saturation', getProperty('sexo.y'))
--     setShaderFloat('sexo2', 'saturation', getProperty('sexo2.y'))
end

function onTweenCompleted(t)
    if t == 'sexoX' then
        tweening = false
    end
    if t == 'sexoY' then
        tweening4 = false;
    end
    if t == 'pixel' then
        pixelChange = false
    end
end