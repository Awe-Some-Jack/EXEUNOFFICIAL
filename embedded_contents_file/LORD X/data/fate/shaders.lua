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

    {name = 'pseudo', shader = 'pseudo', x = 0,
    uniforms = {
        sort = 0,
    }}
}

local dashads = ''
local dashadsHUD = ''
luaDebugMode = true
function onCreatePost()
    dashads = 'game.camGame.filters = ['
    dashadsHUD = 'game.camHUD.filters = ['
    for num, shad in ipairs(shaders) do
        makeLuaSprite(shad.name, nil, shad.x)
        setSpriteShader(shad.name, shad.shader)
        setProperty(shad.name..'.alpha', shad.alpha)
        setProperty(shad.name..'.angle', shad.angle)
        scaleObject(shad.name, shad.scaleX, shad.scaleY)
        for u, v in pairs(shad.uniforms) do
            setShaderFloat(shad.name, u, v)
        end
        if num == 1 then dashads = dashads..'new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)' dashadsHUD = dashadsHUD..'new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)'
        elseif num > 1 then dashads = dashads..', new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)' dashadsHUD = dashadsHUD..', new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)' end
    end

    dashads = dashads..']; return;'
    dashadsHUD = dashadsHUD..']; return;'
    if shadersEnabled and not lowQuality then runHaxeCode(dashads) runHaxeCode(dashadsHUD) end

    setSpriteShader('boyfriend', 'DropShadowShader')

    setShaderFloat('boyfriend', 'hue', 10)
    setShaderFloat('boyfriend', 'saturation', -70)
    setShaderFloat('boyfriend', 'brightness', 0)
    setShaderFloat('boyfriend', 'contrast', 0)
end

local onTween1 = false
local onTween2 = false
local onTween3 = false
local onTween4Hue = false
local onTween4Brightness = false
local onTween4Saturation = false
local onTween4Contrast = false
local onTween5 = false
local glitchTime = false

function onEvent(eventName, value1, value2)
    local shaderValues = stringSplit(value1, ',')
    local tweenSettings = stringSplit(value2, ',')
    if eventName == "bloomFlash" then
        cancelTween('shineX')
        setProperty('shine.x', tonumber(shaderValues[1]))
        doTweenX('shineX', 'shine', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween1 = true
    end
    if eventName == "chromFlash" then
        cancelTween('chromX')
        setProperty('chrom.x', tonumber(shaderValues[1]))
        doTweenX('chromX', 'chrom', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween2 = true
    end
    if eventName == "bwFlash" then
        cancelTween('bwX')
        setProperty('bw.x', tonumber(shaderValues[1]))
        doTweenX('bwX', 'bw', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween3 = true
    end
    if eventName == "hueFlash" then
        cancelTween('hueTween')
        setProperty('color.angle', tonumber(shaderValues[1]))
        doTweenAngle('hueTween', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween4Hue = true
    end
    if eventName == "contrastFlash" then
        cancelTween('contrastTween')
        setProperty('color.scale.x', tonumber(shaderValues[1]))
        doTweenX('contrastTween', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween4Contrast = true
    end
    if eventName == "brightnessFlash" then
        cancelTween('brightnessTween')
        setProperty('color.scale.y', tonumber(shaderValues[1]))
        doTweenY('brightnessTween', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween4Brightness = true
    end
    if eventName == "saturationFlash" then
        cancelTween('saturationTween')
        setProperty('color.x', tonumber(shaderValues[1]))
        doTweenX('saturationTween', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween4Saturation = true
    end
    if eventName == "pseudoFlash" then
        cancelTween('pseudoX')
        setProperty('pseudo.x', tonumber(shaderValues[1]))
        doTweenX('pseudoX', 'pseudo', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween5 = true
    end

    -- Glitch --
    if eventName == 'glitchChar' then
        if value2 == 'remove' then
            removeSpriteShader(value1)
            glitchTime = false
        elseif value2 == 'stop' then
            glitchTime = false
        else
            setSpriteShader(value1, 'NewGlitch2')
            glitchTime = true
        end
    end
end


function onUpdatePost()
    if shadersEnabled and not lowQuality then
        if getProperty('dad.shader') ~= nil then setShaderFloat('dad', 'uSpriteAlpha', getProperty('dad.alpha')) end
        if getProperty('boyfriend.shader') ~= nil then setShaderFloat('boyfriend', 'uSpriteAlpha', getProperty('boyfriend.alpha')) end
    end
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
    if onTween4Hue then
        if getProperty('boyfriend.shader') ~= nil then setShaderFloat('boyfriend', 'hue', getProperty('color.angle')) end
        if getProperty('dad.shader') ~= nil then setShaderFloat('dad', 'hue', getProperty('color.angle')) end
    end
    if onTween4Brightness then 
        if getProperty('boyfriend.shader') ~= nil then setShaderFloat('boyfriend', 'brightness', getProperty('color.scale.y')) end
        if getProperty('dad.shader') ~= nil then setShaderFloat('dad', 'brightness', getProperty('color.scale.y')) end
    end
    if onTween4Saturation then
        if getProperty('boyfriend.shader') ~= nil then setShaderFloat('boyfriend', 'saturation', getProperty('color.x')) end
        if getProperty('dad.shader') ~= nil then setShaderFloat('dad', 'saturation', getProperty('color.x')) end
    end
    if onTween4Contrast then
        if getProperty('boyfriend.shader') ~= nil then setShaderFloat('boyfriend', 'contrast', getProperty('color.scale.x')) end
        if getProperty('dad.shader') ~= nil then setShaderFloat('dad', 'contrast', getProperty('color.scale.x')) end
    end

    if onTween5 then
        setShaderFloat('pseudo', 'sort', getProperty('pseudo.x'))
    end

    -- Glitch --
    if glitchTime then
        setShaderFloat('lordXBite', 'binaryIntensity', math.random(0.3, 0.9))
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
    if tag == 'hueTween' then onTween4Hue = false elseif tag == 'contrastTween' then onTween4Contrast = false elseif tag == 'brightnessTween' then onTween4Brightness = false elseif tag == 'saturationTween' then onTween4Saturation = false end

    if tag == 'pseudoX' then
        onTween5 = false
    end
end