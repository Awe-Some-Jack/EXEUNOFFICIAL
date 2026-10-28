local tweening = false
function onCreatePost()
	if shadersEnabled then
		makeLuaSprite('cab')
		setSpriteShader('cab', 'chromabber')
		setShaderFloat('cab', 'amount', 0.2)

		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'brightness', 0)
		setShaderFloat('bloom', 'contrast', 1)
		setShaderFloat('bloom', 'saturation', 1)

		makeLuaSprite('ca2')
		setSpriteShader('ca2', 'chromatic')
		setShaderFloat('ca2', 'amount', 0)
	end

	if shadersEnabled and not lowQuality then
		local neutrals = {
			bloom = {brightness = 0, contrast = 1, saturation = 1},
			cab = {amount = 0},
			ca2 = {amount = 0},
		}
		local cameraFilters = {
			{'camGame', {'bloom', 'cab', 'ca2'}},
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

function onSongStart()
	setHealth(2)
end

function onUpdatePost(e)
	if shadersEnabled then
		setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
		setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

		setShaderFloat('cab', 'amount', lerp(0.2, 3, 1 - getHealth() / 2))
		setShaderFloat('ca2', 'amount', lerp(0, 0.5, 1 - getHealth() / 2))
	end
end


function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n)
	if shadersEnabled then
		if n == 'bright zoom' and flashingLights then
			cancelTween('bloom')
			setProperty('bloom.x', 0.2)
			doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
		end
	end
end