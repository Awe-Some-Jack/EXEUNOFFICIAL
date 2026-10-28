local shaders = {
    {name = 'chrom', shader = 'chromabber', x = 0,
    uniforms = {
        amount = 0
    }},

    {name = 'shine', shader = 'brightness', x = 0,
    uniforms = {
        brightness = 0,
        contrast = 1,
        saturation = 1,
    }},

    {name = 'bw', shader = 'blackwhite', x = 0,
    uniforms = {
        grayness = 0
    }},

    {name = 'color', shader = 'DropShadowShader', x = 0,
    uniforms = {
        ang = 90,
        thr = 1,
        hue = 1,
        contrast = 0,
        saturation = 0,
        brightness = 0,
    }},
}
function onCreatePost()
    if shadersEnabled then
        
        for num, shad in ipairs(shaders) do
            makeLuaSprite(shad.name, nil, shad.x)
            setSpriteShader(shad.name, shad.shader)
            for u, v in pairs(shad.uniforms) do
                setShaderFloat(shad.name, u, v)
            end
        end
    end
        if shadersEnabled and not lowQuality then
        local neutrals = {
            chrom = {amount = 0},
            bw = {grayness = 0},
            shine = {brightness = 0, contrast = 1, saturation = 1},
        }
        local cameraFilters = {
            {'camGame', {'chrom', 'shine', 'bw', 'color'}},
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
    if shadersEnabled then
        
        if eventName == "bloomFlash" and flashingLights then
            cancelTween('shineX')
            setProperty('shine.x', tonumber(shaderValues[1]))
            doTweenX('shineX', 'shine', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            onTween1 = true
        end
        if eventName == "chromFlash" and flashingLights then
            cancelTween('chromX')
            setProperty('chrom.x', tonumber(shaderValues[1]))
            doTweenX('chromX', 'chrom', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            onTween2 = true
        end
        if eventName == "bwFlash" and flashingLights then
            cancelTween('bwX')
            setProperty('bw.x', tonumber(shaderValues[1]))
            doTweenX('bwX', 'bw', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            onTween3 = true
        end
        if eventName == "colorFlash" and flashingLights then
            cancelTween('colorX')
            setProperty('color.x', tonumber(shaderValues[1]))
            doTweenX('colorX', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
            doTweenColor('dad', 'dad', '0000FF', tonumber(tweenSettings[1]), tweenSettings[2])
            doTweenColor('boyfriend', 'boyfriend', '0000FF', tonumber(tweenSettings[1]), tweenSettings[2])
            doTweenAlpha('camUD', 'camHUD', 0, tonumber(tweenSettings[1]), tweenSettings[2])
            onTween4 = true
        end
        
        if eventName == 'mazinEvents' then
            if value1 == 'saturation' then
                setShaderFloat('shine', 'saturation', tonumber(value2))
            end
        end
    end
end


function onUpdatePost(e)
    if shadersEnabled then
        
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
            setShaderFloat('color', 'brightness', getProperty('color.x'))
        end
    end
    --setShaderFloat('uhoh', 'md', 1 + e)
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