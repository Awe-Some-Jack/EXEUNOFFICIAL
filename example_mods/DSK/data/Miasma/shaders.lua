local shaders = {
    {name = 'chrom', shader = 'chromabber', x = 0,
    uniforms = {
        amount = 0.5
    }},

    {name = 'bw', shader = 'blackwhite', x = 0,
    uniforms = {
        grayness = 1
    }},

    {name = 'shine', shader = 'brightness', x = 0,
    uniforms = {
        brightness = 0,
        contrast = 1,
        saturation = 1,
    }},

    {name = 'color', shader = 'DropShadowShader', x = 0, angle = 0, scaleX = 1, scaleY = 1,
    uniforms = {
        hue = 1,
        contrast = 0,
        saturation = 0,
        brightness = 0,
    }},
}
local dashads = ''
luaDebugMode = true
function onCreatePost()
    dashads = 'game.camGame.filters = ['
    for num, shad in ipairs(shaders) do
        makeLuaSprite(shad.name, nil, shad.x)
        setSpriteShader(shad.name, shad.shader)
        setProperty(shad.name..'.alpha', shad.alpha)
        setProperty(shad.name..'.angle', shad.angle)
        scaleObject(shad.name, shad.scaleX, shad.scaleY)
        for u, v in pairs(shad.uniforms) do
            setShaderFloat(shad.name, u, v)
        end
        if num == 1 then dashads = dashads..'new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)'
        elseif num > 1 then dashads = dashads..', new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)' end
    end
    dashads = dashads..']; return;'
    if shadersEnabled then runHaxeCode(dashads) end
    if shadersEnabled then runHaxeCode("game.camHUD.filters = [new ShaderFilter(game.getLuaObject('color').shader)]; return;") end
end

local onTween1 = false
local onTween2 = false
local onTween3 = false
local onTween4 = false

local cachedColorAlpha = -1
local cachedColorColor = -1
local floor = math.floor
function onEvent(eventName, value1, value2)
    local shaderValues = stringSplit(value1, ',')
    local tweenSettings = stringSplit(value2, ',')
    if eventName == "bloomFlash" then
        cancelTween('shineX')
        setProperty('shine.x', tonumber(shaderValues[1]))
        doTweenX('shineX', 'shine', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween1 = true
    end
    if eventName == "chromFlash" then
        cancelTween('chromX')
        setProperty('chrom.x', tonumber(shaderValues[1]))
        doTweenX('chromX', 'chrom', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween2 = true
    end
    if eventName == "bwFlash" then
        cancelTween('bwX')
        setProperty('bw.x', tonumber(shaderValues[1]))
        doTweenX('bwX', 'bw', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween3 = true
    end
    if eventName == "hueFlash" then
        cancelTween('colorX')
        setProperty('color.x', tonumber(shaderValues[1]))
        doTweenX('colorX', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end
    if eventName == "contrastFlash" then
        cancelTween('colorX')
        setProperty('color.scale.x', tonumber(shaderValues[1]))
        doTweenX('colorX', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end
    if eventName == "brightnessFlash" then
        cancelTween('colorY')
        setProperty('color.scale.y', tonumber(shaderValues[1]))
        doTweenY('colorY', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end
    if eventName == "saturationFlash" then
        cancelTween('colorAngle')
        setProperty('color.angle', tonumber(shaderValues[1]))
        doTweenAngle('colorAngle', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end
end

function onUpdatePost()
    if onTween1 then
        local shineX = getProperty('shine.x')
        setShaderFloat('shine', 'brightness', shineX * 2)
        setShaderFloat('shine', 'contrast', 1 + (shineX * 4))
    end
    if onTween2 then
        setShaderFloat('chrom', 'amount', getProperty('chrom.x'))
    end
    if onTween3 then
        setShaderFloat('bw', 'grayness', getProperty('bw.x'))
    end
    if onTween4 then
        setShaderFloat('color', 'hue',        getProperty('color.x'))
        setShaderFloat('color', 'brightness', getProperty('color.scale.y'))
        setShaderFloat('color', 'saturation', getProperty('color.angle'))
        setShaderFloat('color', 'contrast',   getProperty('color.scale.x'))
    end

    local alpha = getProperty('color.alpha')
    if alpha ~= cachedColorAlpha then
        setShaderFloat('color', 'uSpriteAlpha', alpha)
        cachedColorAlpha = alpha
    end

    local col = getProperty('color.color')
    if col ~= cachedColorColor then
        setShaderFloatArray('color', 'uSpriteColor', {
            (floor(col / 65536) % 256) / 255,
            (floor(col / 256)   % 256) / 255,
            (col % 256) / 255
        })
        cachedColorColor = col
    end
end

function onTweenCompleted(tag)
    if tag == 'shineX' then
        onTween1 = false
    end
    if tag == 'chromX' then
        onTween2 = false
    end
    if tag == 'bwX' then
        onTween3 = false
    end
    if tag == 'colorX' then
        onTween4 = false
    end
end