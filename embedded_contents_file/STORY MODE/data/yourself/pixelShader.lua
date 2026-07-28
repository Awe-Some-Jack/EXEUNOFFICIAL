function onCreate()
    makeLuaSprite('pixel', nil, 0)
    setSpriteShader('pixel', 'pixel')
    setShaderFloat('pixel', 'blockSize', 1)

    if shadersEnabled then runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('pixel').shader)];") end
end

local tweening = false
function onUpdate(elapsed)
    if tweening then
        setShaderFloat('pixel', 'blockSize', getProperty('pixel.x'))
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'pixelShader' then
        cancelTween('pixelTween')
        doTweenX('pixelTween', 'pixel', value1, value2, 'sineInOut')
        tweening = true
    end
end

function onTweenCompleted(tag)
    if tag == 'pixelTween' then
        tweening = false
    end
end