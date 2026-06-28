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
local dashads = ''
function onCreatePost()
    local dashads = 'game.camGame.filters = ['
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
		setShaderFloat('boyfriend', 'ang', math.rad(115))
		setShaderFloat('dad', 'dist', 10)
		setShaderFloat('boyfriend', 'dist', 20)
        setShaderBool('boyfriend', 'doBlend', true)
        setShaderBool('boyfriend', 'pixelPerfect', true)
        setShaderBool('boyfriend', 'useOverlay', true)

        runHaxeCode(dashads)
    end
end

local onTween1 = false
local onTween2 = false
function onEvent(eventName, value1, value2)
    local shaderValues = stringSplit(value1, ',')
    local tweenSettings = stringSplit(value2, ',')
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

    if eventName == "Change Character" then
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
            setShaderFloat('boyfriend', 'ang', math.rad(115))
            setShaderFloat('dad', 'dist', 10)
            setShaderFloat('boyfriend', 'dist', 20)
            setShaderBool('boyfriend', 'doBlend', true)
            setShaderBool('boyfriend', 'pixelPerfect', true)
            setShaderBool('boyfriend', 'useOverlay', true)
        end
    end
end

function onUpdatePost(e)
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