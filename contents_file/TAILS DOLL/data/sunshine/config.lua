local intensity = 50
local velocity = 2

local dadX, dadY = 0, 0
function onCreatePost()
	dadX, dadY = getProperty('dad.x'), getProperty('dad.y')

	for i = 0, 3 do
		local strumW = getProperty('opponentStrums.members[' .. i .. '].width')
		setProperty('opponentStrums.members[' .. i .. '].x', 10 + (strumW * i))
		setProperty('playerStrums.members[' .. i .. '].x', (screenWidth - 10 - (strumW * 4)) + (strumW * i))
	end

	makeLuaSprite("creepy")
	makeLuaSprite("VHS")
	setSpriteShader("VHS", "tvcrt")

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)
	
	if shadersEnabled then
		runHaxeCode([[
			FlxG.camera.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
			game.camVideo.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
			game.camHUD.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
		]])
	end
end

local canFloat = true
local floatTime = 0
local _sat = 1
function onUpdate(e)
	floatTime = floatTime + e
	if canFloat then
		callMethod('dad.setPosition', {
			dadX + math.cos(floatTime * (velocity / 2)) * (intensity * 2),
			dadY + math.sin(floatTime * velocity) * intensity
		})
	end

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4) + (getProperty('creepy.x') * 1.25))
	setShaderFloat('bloom', 'saturation', _sat + (getProperty('creepy.x') / 2))
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
		_sat = tonumber(v1)
	end
	if n == 'sunshinEvent' then
		if v1 == 'startdark' then
			doTweenX('creepy', 'creepy', 1, crochet / (1000 / 3), 'expoIn')
		end
		if v1 == 'creepy' then
			cancelTween('creepy')
			setProperty('creepy.x', 0)
			canFloat = false
		end
		if v1 == 'back' then canFloat = true end
	end
end