local shaders = {
    {name = 'chrom', shader = 'chromabber', x = 0,
    uniforms = {
        amount = 0
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

    {name = 'idk', shader = 'pseudo', x = 0,
    uniforms = {
        sort = 0.0000001,
        iTime = 0,
    }},

    {name = 'binaryGlitch', shader = 'NewGlitch2', x = 0,
    uniforms = {
        binaryIntensity = 0.00000001,
        negativity = 0,
    }},

    {name = 'chromGlitch', shader = 'glitchChromatic', x = 0,
    uniforms = {
        GLITCH = 0,
        iTime = 0,
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
function onCreatePost()
    dashads = 'game.camGame.filters = ['
    for num, shad in ipairs(shaders) do
        makeLuaSprite(shad.name, nil, shad.x)
        setSpriteShader(shad.name, shad.shader)
        for u, v in pairs(shad.uniforms) do
            setShaderFloat(shad.name, u, v)
        end
        if num == 1 then dashads = dashads..'new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)'
        elseif num > 1 then dashads = dashads..', new ShaderFilter(game.getLuaObject("'..shad.name..'").shader)' end
    end
    dashads = dashads..']; return;'
    if shadersEnabled then runHaxeCode(dashads) end

    setSpriteShader('boyfriend', 'DropShadowShader')

    setShaderFloat('boyfriend', 'hue', 10)
    setShaderFloat('boyfriend', 'saturation', -70)
    setShaderFloat('boyfriend', 'brightness', 0)
    setShaderFloat('boyfriend', 'contrast', 0)
end

local onTween1 = false
local onTween2 = false
local onTween3 = false
local onTween4 = false
local glitchTime = false
local shaderPseudoTween = false
local shaderBinaryTween = false
local shaderGlitchTween = false
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
        cancelTween('colorScaleY')
        setProperty('color.scale.y', tonumber(shaderValues[1]))
        doTweenY('colorScaleY', 'color.scale', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end
    if eventName == "saturationFlash" then
        cancelTween('colorAngle')
        setProperty('color.angle', tonumber(shaderValues[1]))
        doTweenAngle('colorAngle', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end

    if eventName == "pseudoFlash" then
        cancelTween('pseudoX')
        setProperty('idk.x', tonumber(shaderValues[1]))
        doTweenX('pseudoX', 'idk', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        shaderPseudoTween = true
    end

    if eventName == "binaryFlash" then
        cancelTween('binaryGlitchX')
        setProperty('binaryGlitch.x', tonumber(shaderValues[1]))
        doTweenX('binaryGlitchX', 'binaryGlitch', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        shaderBinaryTween = true
    end
    if eventName == "chromGlitchFlash" then
        cancelTween('chromGlitchX')
        setProperty('chromGlitch.x', tonumber(shaderValues[1]))
        doTweenX('chromGlitchX', 'chromGlitch', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        shaderGlitchTween = true
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

math.randomseed(os.clock())
local holdShit = 0
function onUpdatePost(e)
    holdShit = holdShit + e
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

    -- Glitch --
    if glitchTime then
        setShaderFloat('lordXBite', 'binaryIntensity', math.random(0.3, 0.9))
    end

    if shaderPseudoTween then
        setShaderFloat('idk', 'sort', getProperty('idk.x'))
    end

    if shaderBinaryTween then
        setShaderFloat('binaryGlitch', 'binaryIntensity', getProperty('binaryGlitch.x'))
    end

    if shaderGlitchTween then
        setShaderFloat('chromGlitch', 'GLITCH', getProperty('chromGlitch.x'))
    end

    for _, iTimeShit in ipairs( {'idk', 'chromGlitch'}) do setShaderFloat(iTimeShit, 'iTime', holdShit) end
end

function onTweenCompleted(tag)
    if tag == 'shineX' then onTween1 = false end

    if tag == 'chromX' then onTween2 = false end
    if tag == 'bwX' then onTween3 = false end

    if tag == 'pseudoX' then shaderPseudoTween = false end
    if tag == 'binaryGlitchX' then shaderBinaryTween = false end

    if tag == 'colorX' or tag == 'colorScaleX' or tag == 'colorAngle' or tag == 'colorScaleY' then onTween4 = false end
end