function onCreatePost()
	makeLuaSprite('bloom2', nil, -1)
	makeLuaSprite('bloom3')
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('cab', nil, 0.05)
	setSpriteShader('cab', 'chromabber')

	makeLuaSprite('bruh')
	setSpriteShader('bruh', 'followedglitch')
	setShaderFloat('bruh', 'size', 0.0)

	makeLuaSprite('fisheye')
	setSpriteShader('fisheye', 'fisheye')
	setShaderFloat('fisheye', 'amount', -0.1)

	if shadersEnabled and not lowQuality then
		setSpriteShader('dad', 'followedglitch')
		setShaderFloat('dad', 'size', 0.002)

		runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('bruh').shader), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('fisheye').shader)];")
	end
end

function onUpdatePost(e)
	setShaderFloat('bruh', 'iTime', getRandomFloat(0,1))
	setShaderFloat('bruh', 'size', getProperty('bruh.x') + (getProperty('bloom.x') / 40))

	setShaderFloat('bloom', 'brightness', getProperty('bloom2.x') + getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', getProperty('bloom3.x') + (getProperty('bloom.x') * 4))
	setShaderFloat('cab', 'amount', 0.05 + getProperty('bloom.x'))
end

function onEvent(n,v1,v2)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', tonumber(v1 == '' and '0.2' or v1))
		doTweenX('bloom', 'bloom', 0, crochet / (250 * tonumber(v2 == '' and '1' or v2)), 'cubeOut')
	end
	if n == 'saturation' then
		setShaderFloat('bloom', 'saturation', tonumber(v1))
	end
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
			setProperty('bruh.x', 0.002)
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
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end
