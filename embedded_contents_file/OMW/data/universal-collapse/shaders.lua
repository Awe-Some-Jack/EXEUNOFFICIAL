function onCreatePost()
	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.1)

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'brightness', 0)
	setShaderFloat('bloom', 'contrast', 1)
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
		local neutrals = {
			bloom = {brightness = 0, contrast = 1, saturation = 1},
		}
		local cameraFilters = {
			{'camGame', {'bloom', 'cab', 'ca2'}},
			{'camVideo', {'colorOut'}},
			{'camHUD', {'bloom', 'ca2'}},
		}
		for _, entry in ipairs(cameraFilters) do
			for _, name in ipairs(entry[2]) do
				if neutrals[name] then
					for uniform, neutral in pairs(neutrals[name]) do
						addPrunedFilter(entry[1], name, uniform, neutral)
					end
				else
					addStaticFilter(entry[1], name)
				end
			end
		end
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
			setStaticFilterActive('camVideo', 'colorOut', false)
		end
	end
end

function onTweenCompleted(t)
	if t == 'colorOut' then
		isTransition = false
		setStaticFilterActive('camVideo', 'colorOut', false)
	end
end