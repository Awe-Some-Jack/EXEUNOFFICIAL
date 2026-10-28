function onCreatePost()
	if shadersEnabled then
		
		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'brightness', 0)
		setShaderFloat('bloom', 'contrast', 1)
		setShaderFloat('bloom', 'saturation', 1)
	end

	if shadersEnabled and not lowQuality then
		local neutrals = {
			bloom = {brightness = 0, contrast = 1, saturation = 1},
		}
		local cameraFilters = {
			{'camGame', {'bloom'}},
		}
		for _, entry in ipairs(cameraFilters) do
			for _, name in ipairs(entry[2]) do
				for uniform, neutral in pairs(neutrals[name]) do
					addPrunedFilter(entry[1], name, uniform, neutral)
				end
			end
		end
	end
end

local defaultBright = 1
local _sat = 0
local _s = 1
local _lerp = 0
local istwning = false
local thing = 0
function onUpdatePost(e)
	if shadersEnabled then
		
		thing = thing + e * 3
		_lerp = bound(lerp(_lerp, _sat, e * 10), 0, 1)
		
		setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
		setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
		setShaderFloat('bloom', 'saturation', (_lerp * 5) + _s)
	end
end

function onEvent(n,v1)
	if shadersEnabled then
		
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