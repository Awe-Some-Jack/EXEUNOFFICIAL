function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromatic')
	
	makeLuaSprite('glitch')
	setSpriteShader('glitch', 'glitchChromatic')

	if shadersEnabled and not lowQuality then
		runHaxeCode([[game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('glitch').shader)];]])
	end
end

local sex = 0
function onUpdatePost(e)
	sex = sex + e * playbackRate
	setShaderFloat('glitch', 'iTime', sex)

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
end

local appear = false
function onEvent(n)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.25)
		doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
	end

	if n == 'ghhcselol' then
		appear = not appear
		if appear then
			setShaderFloatArray('cab', 'rOffset', {-0.01, 0})
			setShaderFloatArray('cab', 'gOffset', {0.01, 0})
			setShaderFloatArray('cab', 'bOffset', {0.02, 0})
			setShaderFloat('glitch', 'GLITCH', 0.3)
		else
			setShaderFloatArray('cab', 'rOffset', {0, 0})
			setShaderFloatArray('cab', 'gOffset', {0, 0})
			setShaderFloatArray('cab', 'bOffset', {0, 0})
			setShaderFloat('glitch', 'GLITCH', 0)
		end
	end
end