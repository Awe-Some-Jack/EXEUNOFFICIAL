function onCreatePost()
    makeLuaSprite('sexo')

    setSpriteShader('sexo', 'brightness', 0)
    setShaderFloat('sexo', 'brightness', 0)
    setShaderFloat('sexo', 'saturation', 1)
    setShaderFloat('sexo', 'contrast', 1)

    if shadersEnabled and not lowQuality then
        for uniform, neutral in pairs({brightness = 0, contrast = 1, saturation = 1}) do
            addPrunedFilter('camGame', 'sexo', uniform, neutral)
        end
    end
    -- Para mas de un shader: if shadersEnabled then runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('sexo').shader), new ShaderFilter(game.getLuaObject('sexo').shader)];") end
end

local tweening = false
function onEvent(eventName, value1, value2)
    local bloomValues = stringSplit(value1, ',')
    local tweenSettings = stringSplit(value2, ',')
    if eventName == "bloomFlash" and flashingLights then
        cancelTween('sexoX')
        setProperty('sexo.x', tonumber(bloomValues[1]))
        doTweenX('sexoX', 'sexo', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        tweening = true
    end
end

function onUpdatePost()
    if tweening then
        setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
        setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))
    end
end

function onTweenCompleted(tag)
    if tag == 'sexoX' then
        tweening = false
    end
end