function onCreate()
	makeLuaSprite("VHS")
	setSpriteShader("VHS", "tvcrt")

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite("pixel", nil, 200)
	setSpriteShader("pixel", "pixelsplash")
	setShaderFloat('pixel', 'pixelsize', 0.001)
end

function onCountdownStarted()
	if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then
		for i = 0, 3 do
			local strumW = getProperty('opponentStrums.members[' .. i .. '].width')
			setProperty('opponentStrums.members[' .. i .. '].x', 10 + (strumW * i))
			setProperty('playerStrums.members[' .. i .. '].x', (screenWidth - 10 - (strumW * 4)) + (strumW * i))
		end
	end
end

function onUpdate(e)
	if isTweening then
		setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
	end
	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
end

function onEvent(n,v1,v2)
	if n == 'bright zoom' and flashingLights then
		local divide = v2 == '' and 4 or tonumber(v2)
		local amount = v1 == '' and 0.1 or tonumber(v1)
		cancelTween('bloom')
		setProperty('bloom.x', amount * 3)
		doTweenX('bloom', 'bloom', 0, crochet / (1000 / divide), 'cubeOut')
	end
	if n == 'saturation' then
		setShaderFloat('bloom', 'saturation', tonumber(v1))
	end
end