-- luaDebugMode = true;
function onCreate()
	initLuaShader("glow")
end
function onCreatePost()
	makeLuaSprite('sexo')
    setSpriteShader('sexo', 'brightness', 0)
    setShaderFloat('sexo', 'saturation', 1)
    setShaderFloat('sexo', 'contrast', 1)

	makeLuaSprite('sexo2')
    setSpriteShader('sexo2', 'brightness', 0)
    setShaderFloat('sexo2', 'saturation', 1)
    setShaderFloat('sexo2', 'contrast', 1)

	setProperty('sexo.y', 1);
	setProperty('sexo2.y', 1);

	if shadersEnabled and not lowQuality then
		runHaxeCode([[
			game.camGame.filters = [
				new ShaderFilter(game.getLuaObject('sexo').shader)
			];

			game.camHUD.filters = [
				new ShaderFilter(game.getLuaObject('sexo2').shader)
			];
		]])
	end
end
local tweening = false
local tweening2 = false
local tweening3 = false
local tweening4 = false
function onEvent(eventName, value1, value2)
	if eventName == "Change Character" then
		if value2 == 'bf-falling' or value2 == 'soink-falling' then
		    setSpriteShader("dad", "glow")
			setShaderFloat("dad", "glowSize", 15.0)
			setShaderFloat("dad", "glowIntensity", 1)
			setShaderFloatArray("dad", 'glowColor', {0.0, 0.7, 0.0})

			setSpriteShader("boyfriend", "glow")
			setShaderFloat("boyfriend", "glowSize", 15.0)
			setShaderFloat("boyfriend", "glowIntensity", 1)
			setShaderFloatArray("boyfriend", 'glowColor', {0.0, 0.7, 0.0})
		end
	end
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
end

local thing = 0;
function onUpdatePost(e)
	thing = thing + e
	setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
	setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))

	setShaderFloat('sexo2', 'brightness', getProperty('sexo2.x') * 2)
	setShaderFloat('sexo2', 'contrast', 1 + (getProperty('sexo2.x') * 4))

	setShaderFloat('sexo', 'saturation', getProperty('sexo.y'))
	setShaderFloat('sexo2', 'saturation', getProperty('sexo2.y'))
end

function onTweenCompleted(t)
	if t == 'sexoX' then
        tweening = false
    end
	if t == 'sexoY' then
		tweening4 = false;
	end
end