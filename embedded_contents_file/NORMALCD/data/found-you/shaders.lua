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
    
    {name = 'wave', shader = 'wavyDistortion', x = 0,
    uniforms = {
        amount = 0,
        iTime = 0,
    }},
    
    {name = 'color', shader = 'DropShadowShader', x = 0, angle = 0, scaleX = 1, scaleY = 1,
    uniforms = {
        hue        =   1,
        contrast   =  10,
        saturation =   0,
        brightness = -15,
    }},

    {name = 'pixel', shader = 'pixelsplash', x = 0,
    uniforms = {
        pixelsize = 0.1
    }},
}

luaDebugMode = true

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
end

local onTween1 = false
local onTween2 = false
local onTween3 = false
local onTween5 = false
local onTween6 = false
local onTween7Hue = false
local onTween7Brightness = false
local onTween7Contrast = false
local onTween7Saturation = false
local onTween8 = false
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
    if eventName == "pseudoFlash" then
        cancelTween('pseudoX')
        setProperty('pseudo.x', tonumber(shaderValues[1]))
        doTweenX('pseudoX', 'pseudo', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween5 = true
    end
    if eventName == "waveFlash" then
        cancelTween('waveTween')
        setProperty('wave.x', tonumber(shaderValues[1]))
        doTweenX('waveTween', 'wave', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween6 = true
    end
    if eventName == "hueFlash" then
        cancelTween('colorAngle')
        setProperty('color.angle', tonumber(shaderValues[1]))
        doTweenAngle('colorAngle', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween7Hue = true
    end
    if eventName == "contrastFlash" then
        cancelTween('colorScaleX')
        setProperty('color.scale.x', tonumber(shaderValues[1]))
        doTweenX('colorX', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween7Contrast = true
    end
    if eventName == "brightnessFlash" then
        cancelTween('colorY')
        setProperty('color.scale.y', tonumber(shaderValues[1]))
        doTweenY('colorY', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween7Brightness = true
    end
    if eventName == "saturationFlash" then
        cancelTween('colorX')
        setProperty('color.x', tonumber(shaderValues[1]))
        doTweenX('colorX', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween7Saturation = true
    end
    if eventName == "pixelFlash" then
        cancelTween('pixelX')
        setProperty('pixel.x', tonumber(shaderValues[1]))
        doTweenX('pixelX', 'pixel', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween8 = true
    end
end

local holdYes = 0
function onUpdatePost(yes)
    holdYes = holdYes + yes
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
    if onTween5 then
        setShaderFloat('pseudo', 'sort', getProperty('pseudo.x'))
    end
    if onTween6 then
        setShaderFloat('wave', 'amount', getProperty('wave.x'))
    end
    if onTween7Hue        then setShaderFloat('color',        'hue',   getProperty('color.angle')) end
    if onTween7Brightness then setShaderFloat('color', 'brightness', getProperty('color.scale.y')) end
    if onTween7Contrast   then setShaderFloat('color', 'contrast',   getProperty('color.scale.x')) end
    if onTween7Saturation then setShaderFloat('color', 'saturation',       getProperty('color.x')) end
    if luaSpriteExists('wave') then setShaderFloat('wave', 'iTime', holdYes) end
    if onTween8 then
        setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
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
    if tag == 'pseudoX' then
        onTween5 = false
    end
    if tag == 'waveTween' then
        onTween6 = false
    end
    if tag == 'colorY' then onTween7Brightness = false elseif tag == 'colorScaleX' then onTween7Contrast = false elseif tag == 'colorX' then onTween7Saturation = false elseif tag == 'colorAngle' then onTween7Hue = false end
    if tag == 'pixelX' then
        onTween8 = false
    end
end