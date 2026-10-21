local shaders = {
    {name = 'chrom', shader = 'chromabber', x = 0,
    uniforms = {
        amount = 0.1
    }},

    {name = 'bw', shader = 'blackwhite', x = 0,
    uniforms = {
        grayness = 0
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
        contrast = 10,
        saturation = 0,
        brightness = -15,
    }},
}
luaDebugMode = true
function onCreatePost()
    for num, shad in ipairs(shaders) do
        makeLuaSprite(shad.name, nil, shad.x)
        setSpriteShader(shad.name, shad.shader)
        setProperty(shad.name..'.alpha', shad.alpha)
        setProperty(shad.name..'.angle', shad.angle)
        scaleObject(shad.name, shad.scaleX, shad.scaleY)
        for u, v in pairs(shad.uniforms) do
            setShaderFloat(shad.name, u, v)
        end
    end
    if shadersEnabled then
        local neutrals = {
            chrom = {amount = 0},
            bw = {grayness = 0},
            shine = {brightness = 0, contrast = 1, saturation = 1},
        }
        local cameraFilters = {
            {'camGame', {'chrom', 'bw', 'shine', 'color'}},
            {'camHUD', {'color'}},
        }
        for _, entry in ipairs(cameraFilters) do
            for _, name in ipairs(entry[2]) do
                if neutrals[name] then
                    for uniform, neutral in pairs(neutrals[name]) do
                        addPrunedFilter(entry[1], name, uniform, neutral)
                    end
                else
                    addStaticFilter(entry[1], name)
                end
            end
        end
    end
end

local onTween1 = false
local onTween2 = false
local onTween3 = false
local onTween4 = false
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
        setShaderFloat('shine', 'brightness', getProperty('shine.x') * 2)
        setShaderFloat('shine', 'contrast', 1 + (getProperty('shine.x') * 4))
    end
    if onTween2 then
        setShaderFloat('chrom', 'amount', getProperty('chrom.x'))
    end
    if onTween3 then
        setShaderFloat('bw', 'grayness', getProperty('bw.x'))
    end
    if onTween4 then
        setShaderFloat('color', 'hue', getProperty('color.x'))
        setShaderFloat('color', 'brightness', getProperty('color.scale.y'))
        setShaderFloat('color', 'saturation', getProperty('color.angle'))
        setShaderFloat('color', 'contrast', getProperty('color.scale.x'))
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