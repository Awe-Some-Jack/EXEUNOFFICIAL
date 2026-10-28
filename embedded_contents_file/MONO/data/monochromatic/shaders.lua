local tweening = false
local doGlitch = false

local monoBGlol = {'cielo 7','nubes 6','mar','montanas 4','suelo 3','torre fea con bocas bien feas 2','roca 1'}

function onCreatePost()
	if shadersEnabled then
		
		makeLuaSprite('cab')
		setSpriteShader('cab', 'chromabber')
		setShaderFloat('cab', 'amount', 0.05)
		
		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'brightness', 0)
		setShaderFloat('bloom', 'contrast', 1)
		setShaderFloat('bloom', 'saturation', 1)
		
		makeLuaSprite('pixel', nil, 0.0001)
		setSpriteShader('pixel', 'pixel')
		setShaderFloat('pixel', 'pixelsize', 0.0001)
		
		makeLuaSprite('bwOther')
		setSpriteShader('bwOther', 'brightness')
		setShaderFloat('bwOther', 'brightness', 0)
		setShaderFloat('bwOther', 'contrast', 1)
		setShaderFloat('bwOther', 'saturation', 0)
	end

	if shadersEnabled and not lowQuality then
		local neutrals = {
			bloom = {brightness = 0, contrast = 1, saturation = 1},
			cab = {amount = 0},
			pixel = {pixelsize = 0.0001},
		}
		local cameraFilters = {
			{'camGame', {'bloom', 'cab', 'pixel'}},
			{'camOther', {'bwOther'}},
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

function onUpdatePost(e)
	if shadersEnabled then
		
		setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
		setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
		
		setShaderFloat('cab', 'amount', 0.05 + getProperty('cab.x'))
		
		if pixelChange then
			setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
		end
		
		if doGlitch then
			if getRandomBool(75) == true then
				for _,i in ipairs(monoBGlol) do
					setProperty('cab.x', getRandomFloat(1, 7))
					setProperty(i..'.visible', not getProperty(i..'.visible'))
					setProperty(i..'glitch.visible', not getProperty(i..'glitch.visible'))
				end
			end
		end
	end
end


function lerp(a, b, t)
	return a + t * (b - a)
end

local angleLeft = false
function onEvent(n, v1, v2)
	if shadersEnabled then
		
		if n == 'bright zoom' and flashingLights then
			cancelTween('bloom')
			setProperty('bloom.x', 0.35)
			doTweenX('bloom', 'bloom', 0, crochet / (1000 /(v2 == '' and 4 or v2)) / playbackRate, 'cubeOut')
			
			cancelTween('cab')
			setProperty('cab.x', 0.35)
			doTweenX('cab', 'cab', 0, crochet / (1000 /(v2 == '' and 4 or v2)) / playbackRate, 'cubeOut')
		end
		if n == 'pixelshadertween' then
			pixelChange = true
			if v1 == 'out' then
				setProperty('pixel.x', 70)
				setShaderFloat('pixel', 'pixelsize', 70)
				cancelTween('pixel')
				doTweenX('pixel', 'pixel', 0.0001, crochet / (1000 /(v2 == '' and 4 or v2)) / playbackRate, 'cubeOut')
				cancelTween('BlackGraphicHUD')
				doTweenAlpha('BlackGraphicHUD', 'BlackGraphicHUD', 0, crochet / (1000 /(v2 == '' and 4 or v2)) / playbackRate, 'cubeOut')
			elseif v1 == 'instant' then
				pixelChange = false
				cancelTween('pixel')
				setProperty('pixel.x', 0.0001)
				setShaderFloat('pixel', 'pixelsize', 0.0001)
				cancelTween('BlackGraphicHUD')
				setProperty('BlackGraphicHUD.alpha', 0)
			else
				setProperty('pixel.x', 0.0001)
				setShaderFloat('pixel', 'pixelsize', 0.0001)
				cancelTween('pixel')
				doTweenX('pixel', 'pixel', 70, crochet / (1000 /(v2 == '' and 4 or v2)) / playbackRate, 'cubeIn')
				cancelTween('BlackGraphicHUD')
				doTweenAlpha('BlackGraphicHUD', 'BlackGraphicHUD', 1, crochet / (1000 /(v2 == '' and 4 or v2)) / playbackRate, 'cubeIn')
			end
		end
	end

	if n == 'Add Camera Zoom' then
		if canAngle then
			angleLeft = not angleLeft
			cancelTween('camgameangle')
			setProperty('camGame.angle', 2 * (angleLeft and -1 or 1))
			doTweenAngle('camgameangle', 'camGame', 0, stepCrochet / 250 / playbackRate, 'cubeOut')
		end
	end

	if shadersEnabled then
		
		if n == 'blackbg' and v1 ~= 'start' then
			cancelTween('cab')
			setProperty('cab.x', 0.75)
			doTweenX('cab', 'cab', 0, crochet / (1000 / 32), 'cubeInOut')
		end
		
		if n == 'glitch' and flashingLights then
			if doGlitch == true then
				setProperty('cab.x', 0)
				for _,i in ipairs(monoBGlol) do
					setProperty(i..'.visible', true)
					setProperty(i..'glitch.visible', false)
				end
			end
			doGlitch = not doGlitch
		end
	end
end

function onSectionHit()
	if canAngle then
		angleLeft = not angleLeft
		cancelTween('camgameangle')
		setProperty('camGame.angle', 2 * (angleLeft and -1 or 1))
		doTweenAngle('camgameangle', 'camGame', 0, stepCrochet / 250 / playbackRate, 'cubeOut')
	end
end

function onStepHit()
	if curStep >= 1540 and curStep <= 1806 then
		canAngle = true
	else
		canAngle = false
	end
end

function onTweenCompleted(t) if t == 'pixel' then pixelChange = false end end