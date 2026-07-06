function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	if shadersEnabled and not lowQuality then
		runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader)];")
	end
end

local defaultBright = 1

local istwning = false
local thing = 0
function onUpdatePost(e)
	thing = thing + e * 3

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
end

function onEvent(n,v1)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.1)
		doTweenX('bloom', 'bloom', 0, crochet / 350, 'cubeOut')
	end
	if n == 'saturation' then
		setShaderFloat('bloom', 'saturation', tonumber(v1))
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end
