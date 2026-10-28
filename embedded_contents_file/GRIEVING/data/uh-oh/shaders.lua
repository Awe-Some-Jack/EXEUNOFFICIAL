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
        for _,char in ipairs({'dad', 'boyfriend'}) do
			setSpriteShader(char, 'DropShadowShader')
			setShaderFloat(char, 'hue', 0)
			setShaderFloat(char, 'saturation', 0)
			setShaderFloat(char, 'contrast', 0)
			setShaderFloat(char, 'str', 1)
			setShaderFloat(char, 'brightness', -30)
            setShaderFloat(char, 'thr', 0.1)
            setShaderFloat(char, 'uSpriteAlpha', 1.0)
            setShaderFloat(char, 'AA_STAGES', 1.0)
			setShaderFloatArray(char, 'dropColor', {255 / 255, 0 / 255, 0 / 255})
			runHaxeFunction('setShaderFrameInfo', {char})
		end
		setShaderFloat('dad', 'ang', math.rad(75))
		setShaderFloat('dad', 'dist', 10)
		setShaderFloat('boyfriend', 'dist', 0)
		setShaderFloat('boyfriend', 'brightness', -40)
		setShaderFloat('boyfriend', 'contrast', 15)

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