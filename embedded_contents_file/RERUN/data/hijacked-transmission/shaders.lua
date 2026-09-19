local inGameOver = false;

function onCreatePost()
	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.1)

	makeLuaSprite('ca2')
	setSpriteShader('ca2', 'chromatic')
	setShaderFloat('ca2', 'amount', 0.15)
	
	makeLuaSprite('glitch')
	setSpriteShader('glitch', 'glitchChromatic')
	setShaderFloat('glitch', 'GLITCH', 0)

	makeLuaSprite('glitch2')
	setSpriteShader('glitch2', 'glitchChromatic')
	setShaderFloat('glitch2', 'GLITCH', 0)

	makeLuaSprite('gBlur')
	setSpriteShader('gBlur', 'gaussianBlur')
	setShaderFloat('gBlur', 'distort', 0)
	setShaderFloat('gBlur', 'Directions', 4)
	setShaderFloat('gBlur', 'Quality', 0)

    makeLuaSprite('sexo') -- Wolfie midd
    setSpriteShader('sexo', 'brightness', 0)
    setShaderFloat('sexo', 'saturation', 1)
    setShaderFloat('sexo', 'contrast', 1)

	makeLuaSprite('sexo2')
    setSpriteShader('sexo2', 'brightness', 0)
    setShaderFloat('sexo2', 'saturation', 1)
    setShaderFloat('sexo2', 'contrast', 1)

	if shadersEnabled and not lowQuality then
		runHaxeCode([[
			game.camGame.filters = [
				new ShaderFilter(game.getLuaObject('glitch').shader), new ShaderFilter(game.getLuaObject('sexo').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('ca2').shader), new ShaderFilter(game.getLuaObject('gBlur').shader)
			];

			game.camHUD.filters = [
				new ShaderFilter(game.getLuaObject('glitch2').shader), new ShaderFilter(game.getLuaObject('sexo2').shader), new ShaderFilter(game.getLuaObject('ca2').shader)
			];

			game.camOther.filters = [
				new ShaderFilter(game.getLuaObject('gBlur').shader), new ShaderFilter(game.getLuaObject('glitch2').shader), new ShaderFilter(game.getLuaObject('sexo2').shader), new ShaderFilter(game.getLuaObject('ca2').shader)
			];
		]])
	end
end

local tweening = false
local tweening2 = false
local tweening3 = false
local tweening4 = false
function onEvent(eventName, value1, value2)
    if eventName == "bloomFlash" and flashingLights then
		local bloomValues = stringSplit(value1, ',')
    	local tweenSettings = stringSplit(value2, ',')
        cancelTween('sexoX')
		cancelTween('sexoX2')
        setProperty('sexo.x', tonumber(bloomValues[1]))
		setProperty('sexo2.x', tonumber(bloomValues[1]))
        doTweenX('sexoX', 'sexo', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
		doTweenX('sexoX2', 'sexo2', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        tweening = true
    end

	if eventName == "saturationFlash" and flashingLights then
		local satValues = stringSplit(value1, ',')
    	local tweenSettings = stringSplit(value2, ',')
        cancelTween('sexoY')
		cancelTween('sexoY2')
        setProperty('sexo.y', tonumber(satValues[1]))
		setProperty('sexo2.y', tonumber(satValues[1]))
        doTweenY('sexoY', 'sexo', tonumber(satValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
		doTweenY('sexoY2', 'sexo2', tonumber(satValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        tweening4 = true
    end

	if eventName == 'glitchtween' then
		local tweenS = stringSplit(value2, ',')
		cancelTween('lolfuckxd')
		cancelTween('lolfuckxd2')
		doTweenX('lolfuckxd', 'glitch', tonumber(value1), tonumber(tweenS[1]), tweenS[2])
		doTweenX('lolfuckxd2', 'glitch2', tonumber(value1), tonumber(tweenS[1]), tweenS[2])
		tweening2 = true
	end

	if eventName == 'chromTween' then
		local tweenC = stringSplit(value2, ',')
		cancelTween('chromtweenshit')
		cancelTween('chromtweenshit2')
		doTweenX('chromtweenshit', 'cab', tonumber(value1), tonumber(tweenC[1]), tweenC[2])
		doTweenX('chromtweenshit2', 'ca2', tonumber(value1), tonumber(tweenC[1]+.05), tweenC[2])
		tweening3 = true;
	end
end

function onStepHit()
	if curStep == 44 then
        doTweenX('gBlurX', 'gBlur', 0, 4.1, 'sineInOut')
	end
end

local thing = 0;
function onUpdatePost(e)
	if startedCountdown and curStep < 3 and not inGameOver then
		setProperty('ca2.x', 0.15);
		setProperty('cab.x', 0.1);
		setProperty('sexo.y', 1);
		setProperty('sexo2.y', 1);
		setProperty('gBlur.x', 100);
		setProperty('gBlur.y', 10);
	end

	thing = thing + e
	setShaderFloat('glitch', 'iTime', thing)
	setShaderFloat('glitch2', 'iTime', thing)

	if not inGameOver then
		setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
		setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))

		setShaderFloat('sexo2', 'brightness', getProperty('sexo2.x') * 2)
		setShaderFloat('sexo2', 'contrast', 1 + (getProperty('sexo2.x') * 4))

		setShaderFloat('glitch', 'GLITCH', getProperty('glitch.x'))
		setShaderFloat('glitch2', 'GLITCH', getProperty('glitch2.x'))

		setShaderFloat('gBlur', 'distort', getProperty('gBlur.x'))
		setShaderFloat('gBlur', 'Quality', getProperty('gBlur.y'))

		setShaderFloat('cab', 'amount', getProperty('cab.x'))
		setShaderFloat('ca2', 'amount', getProperty('ca2.x')+.05)
		setShaderFloat('sexo', 'saturation', getProperty('sexo.y'))
		setShaderFloat('sexo2', 'saturation', getProperty('sexo2.y'))
	end
end

function onTweenCompleted(t)
	if t == 'sexoX' then
        tweening = false
    end
	if t == 'lolfuckxd' then
		tweening2 = false
	end
	if t == 'chromtweenshit' then
		tweening3 = false;
	end
	if t == 'sexoY' then
		tweening4 = false;
	end
end

function onGameOverStart()
	inGameOver = true;

	setShaderFloat('glitch', 'GLITCH', 0.1)
	setShaderFloat('cab', 'amount', 0.9)
	setProperty('cab.x', 0.9)
	
    setShaderFloat('sexo', 'saturation', 0.4)
    setShaderFloat('sexo', 'contrast', 1.5)

	cancelTween('sexoX')
	cancelTween('sexoY')
	cancelTween('lolfuckxd')
	cancelTween('chromtweenshit')
end