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

    {name = 'color', shader = 'DropShadowShader', x = 0,
    uniforms = {
        ang = 90,
        thr = 1,
        hue = 1,
        contrast = -10,
        saturation = -50,
        brightness = -15,
    }},

    {name = 'distortion', shader = 'distortion', x = 0,
    uniforms = {
        xPos = 0,
        yPos = 0,
        size = 0,
        amount = 0
    }},
}

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
    if shadersEnabled then runHaxeCode(dashads) end
    if shadersEnabled then runHaxeCode("game.camHUD.filters = [new ShaderFilter(game.getLuaObject('color').shader)]; return;") end

    for _,char in ipairs({'boyfriend', 'dad'}) do
            setSpriteShader(char, 'DropShadowShader')
            setShaderFloat(char, 'hue', 0)
            setShaderFloat(char, 'saturation', 0)
            setShaderFloat(char, 'contrast', 0)
            setShaderFloat(char, 'str', 1)
            setShaderFloat(char, 'brightness', 0)
            setShaderFloat(char, 'thr', 0.05)
            setShaderFloatArray(char, 'dropColor', {0 / 225, 64 / 255, 128 / 255})
            runHaxeFunction('setShaderFrameInfo', {char})
        end
        setShaderFloat('boyfriend', 'ang', math.rad(75))
        setShaderFloat('boyfriend', 'dist', 20)
        setShaderFloat('dad', 'ang', math.rad(75))
        setShaderFloat('dad', 'dist', 20)
end

local sexo = false
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
    if eventName == "colorFlash" then
        cancelTween('colorX')
        setProperty('color.x', tonumber(shaderValues[1]))
        doTweenX('colorX', 'color', tonumber(shaderValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        onTween4 = true
    end

    if eventName == 'BG Freaks Expression' then
        sexo = not sexo
        setProperty('distortion.x', 0)
        setShaderFloat('distortion', 'size', 0)
        if sexo then
            setProperty('distortion.x', 0.2)
        else
            doTweenX('distortion', 'distortion', 0, 1, 'cubeInOut')
        end
    end
end

local _pos = {1220, 1280}
function opponentNoteHit(id,nd,nt,isn)
    if nd == 0 then
        _pos = {1220, 1250}
    elseif nd == 1 then
        _pos = {1335, 1360}
    elseif nd == 2 then
        _pos = {1280, 1165}
    elseif nd == 3 then
        _pos = {1520, 1280}
    end
end

local iTime = 0
function onUpdatePost(e)
    iTime = iTime + e
    setShaderFloat('distortion', 'iTime', iTime * 2)
    setShaderFloat('distortion', 'amount', getProperty('distortion.x'))
    setShaderFloat('distortion', 'size', (10 + math.sin(iTime * 2) * 0.15) * getProperty('camGame.zoom'))
    setShaderFloat('distortion', 'xPos', (_pos[1] - (getProperty('camGame.scroll.x') + screenWidth / 2)) * getProperty('camGame.zoom') + screenWidth / 2)
    setShaderFloat('distortion', 'yPos', (_pos[2] - (getProperty('camGame.scroll.y') + screenHeight / 2)) * getProperty('camGame.zoom') + screenHeight / 2)
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