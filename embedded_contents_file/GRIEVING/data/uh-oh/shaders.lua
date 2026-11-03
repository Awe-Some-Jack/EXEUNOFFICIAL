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
    
    --[[
    {name = 'uhoh', shader = 'uhOh', x = 0,
    uniforms = {
        brightness = 0,
        contrast = 1,
        saturation = 1,
    }},
    ]]
}

runHaxeCode([[
	import flixel.math.FlxAngle;
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
        setSpriteShader('dad', 'DropShadowShader')
        setShaderFloat('dad', 'hue', 0)
        setShaderFloat('dad', 'saturation', 0)
        setShaderFloat('dad', 'contrast', 0)
        setShaderFloat('dad', 'str', 1)
        setShaderFloat('dad', 'brightness', -30)
        setShaderFloat('dad', 'thr', 0.1)
        setShaderFloat('dad', 'uSpriteAlpha', 1.0)
        setShaderFloat('dad', 'AA_STAGES', 1.0)
        setShaderFloatArray('dad', 'dropColor', {255 / 255, 0 / 255, 0 / 255})
        runHaxeFunction('setShaderFrameInfo', {'dad'})
        setShaderFloat('dad', 'ang', math.rad(75))
        setShaderFloat('dad', 'dist', 10)

        runHaxeCode([[
            import shaders.AdjustColorShader;
            var playerColor = new AdjustColorShader();
            playerColor.brightness = -27;
            playerColor.contrast = -19;
            playerColor.hue = -10;
            playerColor.saturation = -9;
            game.boyfriend.shader = playerColor;
        ]])

        local neutrals = {
            chrom = {amount = 0},
            shine = {brightness = 0, contrast = 1, saturation = 1},
        }
        local cameraFilters = {
            {'camGame', {'chrom', 'shine', 'uhoh'}},
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
end