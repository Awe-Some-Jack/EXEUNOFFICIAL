local tweening = false
function onCreate()
	makeLuaSprite('hws')
	setSpriteShader('hws', 'HeatwaveShader')
	setShaderSampler2D('hws', 'distortTexture', 'tt/heatwave')

	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.225)

	makeLuaSprite('glitch')
	setSpriteShader('glitch', 'glitchChromatic')
	setShaderFloat('glitch', 'GLITCH', 0)

	if shadersEnabled then runHaxeCode([[game.camGame.filters = [
		new ShaderFilter(game.getLuaObject('glitch').shader)
		];]])
	end
end

local amount = 0

local lmao = false
function onEvent(n,v1,v2)
	if n == 'ttfirestart' then
		lmao = true
		if shadersEnabled then runHaxeCode([[game.camGame.filters = [
			new ShaderFilter(game.getLuaObject('hws').shader),
			new ShaderFilter(game.getLuaObject('cab').shader),
			new ShaderFilter(game.getLuaObject('glitch').shader)
			];]])
		end
	end

	if n == 'glitchtween' then
		local tweenS = stringSplit(v2, ',')
		cancelTween('lolfuckxd')
		doTweenX('lolfuckxd', 'glitch', tonumber(v1), tonumber(tweenS[1]), tweenS[2])
		tweening = true
	end
end

local thing = 0
function onUpdatePost(e)
	thing = thing + e
	setShaderFloat('hws', 'iTime', thing)
	setShaderFloat('glitch', 'iTime', thing)

	if amount > 0 then
		amount = lerp(amount, -0.01, e * 3.15 * playbackRate)
		if amount <= 0 then amount = 0 end

		for i = 0,getProperty('notes.length')-1 do
			setProperty('notes.members['..i..'].angle', getRandomFloat(-1,1) * (amount * 1000))
		end
	end

	if tweening then
		setShaderFloat('glitch', 'GLITCH', getProperty('glitch.x'))
	end
end

function opponentNoteHit()
	if stringStartsWith(dadName, 'BEAST') and lmao == true then
		cameraShake('game', 0.003, 0.25)
		cameraShake('hud', 0.0009, 0.25)
		amount = 0.0095
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onTweenCompleted(t)
	if t == 'lolfuckxd' then
		tweening = false
	end
end