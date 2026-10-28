function onCreatePost()
	if shadersEnabled then
		
		makeLuaSprite('bloom2', nil, -1)
		makeLuaSprite('bloom3')
		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'brightness', 0)
		setShaderFloat('bloom', 'contrast', 1)
		setShaderFloat('bloom', 'saturation', 1)
		
		makeLuaSprite('cab', nil, 0.05)
		setSpriteShader('cab', 'chromabber')
		setShaderFloat('cab', 'amount', 0.05)
		
		makeLuaSprite('fisheye')
		setSpriteShader('fisheye', 'fisheye')
		setShaderFloat('fisheye', 'amount', -0.1)
		
		if shadersEnabled and not lowQuality then
			local neutrals = {
				bloom = {brightness = 0, contrast = 1, saturation = 1},
				cab = {amount = 0},
			}
			local cameraFilters = {
				{'camGame', {'bloom', 'cab'}},
			}
			for _, entry in ipairs(cameraFilters) do
				for _, name in ipairs(entry[2]) do
					for uniform, neutral in pairs(neutrals[name]) do
						addPrunedFilter(entry[1], name, uniform, neutral)
					end
				end
			end
			addStaticFilter('camGame', 'fisheye')
		end
	end
end

function onUpdatePost(e)
	if shadersEnabled then
		setShaderFloat('bloom', 'brightness', getProperty('bloom2.x') + getProperty('bloom.x') * 2)
		setShaderFloat('bloom', 'contrast', getProperty('bloom3.x') + (getProperty('bloom.x') * 4))
		setShaderFloat('cab', 'amount', 0.05 + getProperty('bloom.x'))
	end
end

function onEvent(n,v1,v2)
	if shadersEnabled then
		
		if n == 'bright zoom' and flashingLights then
			cancelTween('bloom')
			setProperty('bloom.x', tonumber(v1 == '' and '0.2' or v1))
			doTweenX('bloom', 'bloom', 0, crochet / (250 * tonumber(v2 == '' and '1' or v2)), 'cubeOut')
		end
		if n == 'saturation' then setShaderFloat('bloom', 'saturation', tonumber(v1)) end
		if n == 'brightness' then setProperty('bloom2.x', tonumber(v1 == '' and '0.2' or v1)) end
		if n == 'contrast' then setProperty('bloom3.x', tonumber(v1 == '' and '0.2' or v1)) end
		if n == 'innocenceEvents' then
			if v1 == 'appear' then
				doTweenX('bloom2', 'bloom2', 0, crochet / (1000 / 8), 'expoOut')
				doTweenX('bloom3', 'bloom3', 1, crochet / (1000 / 8), 'expoOut')
			end
			if v1 == 'daprespeedup' then
				if getSongPosition() < 62020 then
					cancelTween('bloom3')
					doTweenX('bloom3', 'bloom3', 5, crochet / (1000 / 3), 'expoIn')
				end
			end
			if v1 == 'changebg' then
				cancelTween('bloom3')
				setProperty('bloom3.x', 1)
			end
			if v1 == 'lol' then
				cancelTween('bloom2')
				setProperty('bloom2.x', -0.25)
				setProperty('bloom3.x', 1.5)
			end
			if v1 == 'sexo' then
				setProperty('bloom2.x', 0)
				setProperty('bloom3.x', 1)
			end
			if v1 == 'changebgfinal' then
				setShaderFloat('fisheye', 'amount', -0.4)
			end
			if v1 == 'redfadein' then
				setProperty('bloom2.x', 0)
				setProperty('bloom3.x', 1)
			end
		end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end
