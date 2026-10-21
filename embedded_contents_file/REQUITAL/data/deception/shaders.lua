local tweening = false
function onCreate()
	makeLuaSprite('hws')
	setSpriteShader('hws', 'HeatwaveShader')
	setShaderSampler2D('hws', 'distortTexture', 'bg/heatwave')

	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.05)

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'brightness', 0)
	setShaderFloat('bloom', 'contrast', 1)
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('speedLines')
	setSpriteShader('speedLines', 'speedLines')

	if shadersEnabled and not lowQuality then
		local neutrals = {
			bloom = {brightness = 0, contrast = 1, saturation = 1},
		}
		local cameraFilters = {
			{'camGame', {'hws', 'bloom', 'cab'}},
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
		addStaticFilter('camGame', 'speedLines', false)
	end
end

local thing = 0
function onUpdatePost(e)
	thing = thing + e
	setShaderFloat('hws', 'iTime', thing)
	setShaderFloat('speedLines', 'iTime', thing)

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2.6)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 5))
	setShaderFloat('cab', 'amount', 0.05 + (getProperty('bloom.x') * 4) + getProperty('cab.x'))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n, v1)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.2)
		doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
	end
	if n == 'Add Camera Zoom' then
		cancelTween('cab.x')
		setProperty('cab.x', 0.2)
		doTweenX('cab', 'cab', 0, crochet / 250 / playbackRate, 'cubeOut')
		setProperty('camHUD.zoom', 1)
	end
	if n == 'BGchange' then
		if v1 == 'back' or v1 == 'running' then
			setStaticFilterActive('camGame', 'speedLines', true)
		end
		if v1 == 'endcine' or v1 == 'xdddd' then
			setStaticFilterActive('camGame', 'speedLines', false)
		end
	end
end

function onSectionHit()
	if getProperty('camZoomingMult') > 0 then
		cancelTween('cab.x')
		setProperty('cab.x', 0.2)
		doTweenX('cab', 'cab', 0, crochet / 250 / playbackRate, 'cubeOut')
		setProperty('camHUD.zoom', 1)
	end
end