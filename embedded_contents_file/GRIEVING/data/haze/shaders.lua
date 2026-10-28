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
    }},

    {name = 'wave', shader = 'wavyDistortion', x = 0,
    uniforms = {
        amount = 0,
        iTime = 0,
    }}
}

luaDebugMode = true

addHaxeLibrary('FlxAngle', 'flixel.math')

runHaxeCode([[
	function setShaderFrameInfo(obj:String) {
		var char:FlxSprite;
		switch(obj) {
			case 'boyfriend':
				char = game.boyfriend;
			case 'dad':
				char = game.dad;
			case 'gf':
				char = game.gf;
		}

        char.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
			if (char.shader != null) {
				char.shader.setFloatArray('uFrameBounds', [char.frame.uv.x, char.frame.uv.y, char.frame.uv.width, char.frame.uv.height]);
				char.shader.setFloat('angOffset', char.frame.angle * FlxAngle.TO_RAD);
			}
        }
	}
]])

luaDebugMode = true
function onCreatePost()
    if shadersEnabled and not lowQuality then
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
            local neutrals = {
                chrom = {amount = 0},
            bw = {grayness = 0},
            shine = {brightness = 0, contrast = 1, saturation = 1},
            wave = {amount = 0},
        }
        local cameraFilters = {
            {'camGame', {'chrom', 'bw', 'shine', 'pseudo', 'wave'}},
            {'camHUD', {'chrom', 'bw', 'shine', 'pseudo', 'wave'}},
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
local onTween5 = false
local onTween6 = false
function onEvent(eventName, value1, value2)
    local shaderValues = stringSplit(value1, ',')
    local tweenSettings = stringSplit(value2, ',')
    if shadersEnabled then
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
        -- HAZE Events --
        if eventName == 'hazeEvents' then
            if value1 == 'setCharShaders' then
                lightningPhase[tonumber(value2)]()
            elseif value1 == 'removeCharShaders' then
                for _, char in ipairs({'dad', 'boyfriend'}) do removeSpriteShader(char) end
            end
            if value1 == 'stageMode' then if value2 == '5' then return else triggerEvent('waveFlash', '10, 0', '1, circOut') end end
        end
    end
end

local holdYes = 0
function onUpdatePost(yes)
    holdYes = holdYes + yes
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
        if onTween5 then
            setShaderFloat('pseudo', 'sort', getProperty('pseudo.x'))
        end
        if onTween6 then
            setShaderFloat('wave', 'amount', getProperty('wave.x'))
        end
        if luaSpriteExists('wave') then setShaderFloat('wave', 'iTime', holdYes) end
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
end