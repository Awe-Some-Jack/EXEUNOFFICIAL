local shaders = {
    {name = 'chrom', shader = 'chromabber', x = 0,
    uniforms = {
        amount = 0.05
    }},

    {name = 'bw', shader = 'blackwhite', x = 0,
    uniforms = {
        grayness = 0
    }},

    {name = 'pixel', shader = 'pixelsplash', x = 0,
    uniforms = {
        pixelsize = 0.1
    }},

    {name = 'sexo', shader = 'brightness', x = 0,
    uniforms = {
        brightness = 0,
        contrast = 1,
        saturation = 1,
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

    setCharShaders()
end

function setCharShaders()
    if shadersEnabled then
        setSpriteShader('boyfriend', 'DropShadowShader')

        setShaderFloat('boyfriend', 'hue', 5)
        setShaderFloat('boyfriend', 'saturation', -60)
        setShaderFloat('boyfriend', 'brightness', -5)
        setShaderFloat('boyfriend', 'contrast', 5)

        setShaderFloat('boyfriend', 'ang', 0)
        setShaderFloat('boyfriend', 'dist', 0)
        setShaderFloat('boyfriend', 'str', 0)
        setShaderFloat('boyfriend', 'thr', 0)
        setShaderFloatArray('boyfriend', 'dropColor', {0,0,0})

        setSpriteShader('dad', 'DropShadowShader')

        setShaderFloat('dad', 'hue', 5)
        setShaderFloat('dad', 'saturation', -25)
        setShaderFloat('dad', 'brightness', -5)
        setShaderFloat('dad', 'contrast', 5)

        setShaderFloat('dad', 'ang', 0)
        setShaderFloat('dad', 'dist', 0)
        setShaderFloat('dad', 'str', 0)
        setShaderFloat('dad', 'thr', 0)
        setShaderFloatArray('dad', 'dropColor', {0,0,0})
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
        cancelTween('sexoX')
        setProperty('sexo.x', tonumber(shaderValues[1]))
        doTweenX('sexoX', 'sexo', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
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
    if eventName == "pixelFlash" then
        cancelTween('pixelX')
        setProperty('pixel.x', tonumber(shaderValues[1]))
        doTweenX('pixelX', 'pixel', tonumber(shaderValues[2]), tonumber(tweenSettings[1]) / playbackRate, tweenSettings[2])
        onTween4 = true
    end

    if eventName == "Change Character" then
        if shadersEnabled and not lowQuality then
            setSpriteShader('dad', 'DropShadowShader')

            setShaderFloat('dad', 'hue', 5)
            setShaderFloat('dad', 'saturation', -35)
            setShaderFloat('dad', 'brightness', -5)
            setShaderFloat('dad', 'contrast', 5)

            setShaderFloat('dad', 'ang', 0)
            setShaderFloat('dad', 'dist', 0)
            setShaderFloat('dad', 'str', 0)
            setShaderFloat('dad', 'thr', 0)
            setShaderFloatArray('dad', 'dropColor', {0,0,0})
        end
    end
end

local holdYes = 0
function onUpdatePost(yes)
    holdYes = holdYes + yes
    if shadersEnabled then
        if onTween1 then
            setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
            setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))
        end
        if onTween2 then
            setShaderFloat('chrom', 'amount', getProperty('chrom.x'))
        end
        if onTween3 then
            setShaderFloat('bw', 'grayness', getProperty('bw.x'))
        end
        if onTween4 then
            setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
        end
    end
end

function onTweenCompleted(tag)
    if shadersEnabled then
        if tag == 'sexoX' then
            onTween1 = false
        end
        if tag == 'chromX' then
            onTween2 = false
        end
        if tag == 'bwX' then
            onTween3 = false
        end
        if tag == 'pixelX' then
            onTween4 = false
        end
    end
end