local tweening = false
function onCreate()
	if shadersEnabled then
		
		makeLuaSprite('hws')
		setSpriteShader('hws', 'HeatwaveShader')
		setShaderSampler2D('hws', 'distortTexture', 'bg/heatwave')
		
		makeLuaSprite('cab')
		setSpriteShader('cab', 'chromabber')
		setShaderFloat('cab', 'amount', 0.1)
	end

	if shadersEnabled and not lowQuality then runHaxeCode([[game.camGame.filters = [
		new ShaderFilter(game.getLuaObject('hws').shader),
			new ShaderFilter(game.getLuaObject('cab').shader)
		];]])
	end
end

local thing = 0
function onUpdatePost(e)
	if shadersEnabled then
		thing = thing + e
		setShaderFloat('hws', 'iTime', thing)
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n,v1)
	if n == 'BGchange' then
		if shadersEnabled then
			if v1 == 'blackout' then if shadersEnabled and not lowQuality then runHaxeCode("game.camGame.filters = [];") end end

			if v1 == 'blackin' then
				if shadersEnabled then runHaxeCode([[game.camGame.filters = [
					new ShaderFilter(game.getLuaObject('hws').shader),
					new ShaderFilter(game.getLuaObject('cab').shader)
					];]])
				end
			end
		end
	end
end