function onCreatePost()
	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.1)

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('ca2')
	setSpriteShader('ca2', 'chromatic')
	setShaderFloat('ca2', 'amount', 0.15)
	
	makeLuaSprite('colorOut')
	setSpriteShader('colorOut', 'colorOut')
	setShaderBool('colorOut','invert', true)
	setShaderFloat('colorOut', 'lowerBound', 0)
	setShaderFloatArray('colorOut', 'borderTint', {0, 0, 0})

	setShaderFloat('colorOut', 'upperBound', 0.5)
	setShaderFloatArray('colorOut', 'tint', {0, 0, 0.9})

	setProperty('camVideo.alpha', 0)

	if shadersEnabled and not lowQuality then
		runHaxeCode([[
			game.camGame.filters = [
				new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('ca2').shader)
			];

			game.camVideo.filters = [new ShaderFilter(game.getLuaObject("colorOut").shader)];

			game.camHUD.filters = [
				new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('ca2').shader)
			];
		]])
	end
end

local isTransition = false
local thing = 0
function onUpdatePost(e)
	thing = thing + e * 3

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

	if isTransition then
		setShaderFloat('colorOut', 'upperBound', 0.5 - (getProperty('colorOut.x') / 2))
		setShaderFloatArray('colorOut', 'tint', {0 + getProperty('colorOut.x'), 0 + getProperty('colorOut.x'), 0.9 + (getProperty('colorOut.x') / 10)})
	end
end

function onEvent(n,v1,v2)
	if n == 'bright zoom' and flashingLights then
		local divide = v2 == '' and 4 or tonumber(v2)
		local amount = v1 == '' and 0.1 or tonumber(v1)
		cancelTween('bloom')
		setProperty('bloom.x', amount)
		doTweenX('bloom', 'bloom', 0, crochet / (1000 / divide), 'cubeOut')
	end
	if n == 'saturation' then
		setShaderFloat('bloom', 'saturation', tonumber(v1))
	end
	if n == 'omwEvents' then
		if v1 == 'fadeIn' then
			isTransition = true
			setProperty('colorOut.x', 0)
			doTweenX('colorOut', 'colorOut', 1, 0.5) doTweenAlpha('camVideo', 'camVideo', 1, 0.5)
		end
		if v1 == 'removevideoxd' then
			isTransition = false
			cancelTween('colorOut') cancelTween('camVideo')
			setProperty('camVideo.alpha', 1)
			runHaxeCode([[game.camVideo.filters = [];]])
		end
	end
end

function onTweenCompleted(t)
	if t == 'colorOut' then
		isTransition = false
		runHaxeCode([[game.camVideo.filters = [];]])
	end
end