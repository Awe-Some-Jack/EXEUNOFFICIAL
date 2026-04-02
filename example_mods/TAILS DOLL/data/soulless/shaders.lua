local tweening = false
function onCreatePost()
	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('ca2')
	setSpriteShader('ca2', 'chromatic')
	setShaderFloat('ca2', 'amount', 0)

	if shadersEnabled and not lowQuality then
		runHaxeCode([[game.camGame.filters = [
			new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('ca2').shader)
		];]])
	end
end

function onSongStart()
	setHealth(2)
end

function onUpdatePost(e)
	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

	setShaderFloat('cab', 'amount', lerp(0.2, 3, 1 - getHealth() / 2))
	setShaderFloat('ca2', 'amount', lerp(0, 0.5, 1 - getHealth() / 2))
end


function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.2)
		doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
	end
end