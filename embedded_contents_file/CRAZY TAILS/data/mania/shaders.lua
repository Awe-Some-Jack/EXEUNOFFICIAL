function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')

	if shadersEnabled and not lowQuality then
		runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader)];")
	end
end

local defaultBright = 1
local _sat = 0
local _s = 1
local _lerp = 0
local istwning = false
local thing = 0
function onUpdatePost(e)
	thing = thing + e * 3
	_lerp = bound(lerp(_lerp, _sat, e * 10), 0, 1)

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
	setShaderFloat('bloom', 'saturation', (_lerp * 5) + _s)
end

function onEvent(n,v1)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.1)
		doTweenX('bloom', 'bloom', 0, crochet / 350, 'cubeOut')
	end
	if n == 'saturation' then
		_s = tonumber(v1)
	end
	if n == 'Dadbattle Spotlight' then
		cancelTimer('xd')
		_sat = 1
		runTimer('xd', crochet / 500)
	end
end

function onTimerCompleted(t)
	if t == 'xd' then
		_sat = 0
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end