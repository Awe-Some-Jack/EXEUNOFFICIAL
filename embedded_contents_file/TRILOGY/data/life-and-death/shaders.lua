function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'brightness', 0)
	setShaderFloat('bloom', 'contrast', 1)
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('chrom', nil, 0)
	setSpriteShader('chrom', 'chromabber')
	setShaderFloat('chrom', 'amount', 0)

	makeLuaSprite("pixel", nil, 0.0001)
	setSpriteShader("pixel", "pixelsplash")
	setShaderFloat('pixel', 'pixelsize', 0.0001)

	if shadersEnabled and not lowQuality then
		local neutrals = {
			bloom = {brightness = 0, contrast = 1, saturation = 1},
			chrom = {amount = 0},
			pixel = {pixelsize = 0.0001},
		}
		local cameraFilters = {
			{'camGame', {'bloom', 'chrom', 'pixel'}},
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

local istwning = false
local thing = 0
function onUpdatePost(e)
	thing = thing + e * 3

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

	if istwning then
		setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
		setShaderFloat('chrom', 'amount', getProperty('chrom.x'))
	end
end

function onEvent(n,v1)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.1)
		doTweenX('bloom', 'bloom', 0, crochet / 250, 'cubeOut')
	end
	if n == 'saturation' then
		setShaderFloat('bloom', 'saturation', tonumber(v1))
	end
	if n == 'trilogyEvents' then
		if v1 == 'startEnd' then
			istwning = true
			doTweenX('xdd', 'chrom', 3, crochet / (1000 / 10), 'cubeIn')
			doTweenX('bloom', 'bloom', 0.25, crochet / (1000 / 10), 'cubeIn')
			doTweenAlpha('44123123', 'camHUD', 0, crochet / (1000 / 5), 'cubeInOut')
		end
		if v1 == 'ending' then
			doTweenX('pixel', 'pixel', 200, crochet / 500, 'expoIn')
			doTweenZoom('casdadsda', 'camGame', 0.4, crochet / 500, 'expoIn')
			doTweenAlpha('xasjdias', 'BlackGraphicOther', 1, crochet / 500, 'expoIn')
		end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end
