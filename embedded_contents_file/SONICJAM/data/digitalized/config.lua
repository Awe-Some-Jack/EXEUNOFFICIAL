local hueThing = 0;
local hueMult = 1;

function onCreate()
	makeLuaSprite("VHS")
	setSpriteShader("VHS", "tvcrt")

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('dss')
	setSpriteShader('dss', 'colorAdjust')
	setShaderFloat('dss', 'hue', 0) -- -270
	setShaderFloat('dss', 'brightness', 0)
end

function onCreatePost()
	makeLuaSprite('blacky', '', 0, 0);
	makeGraphic('blacky', 3000, 3000, '000000');
	screenCenter('blacky');
	setScrollFactor('blacky', 0, 0);
	setProperty('blacky.alpha', 0);
	setObjectCamera('blacky', 'game');
	addLuaSprite('blacky', true);
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

function onStepHit()
	if curStep == 896 then
		doTweenX('dssTween', 'dss', -270, 21.92, 'smootherStepIn')
	end

	if curStep == 1152 then
		doTweenX('dssTween2', 'dss', 0, 0.2, 'smootherStepOut')
	end

	if curStep == 1984 then
		doTweenX('dssTween3', 'dss', 0, 5.48, 'smootherStepInOut')
	end

	if curStep == 2048 then
		setProperty('blacky.alpha', 1)
	end
end

function onUpdate(e)
	setShaderFloat('dss', 'hue', getProperty('dss.x'))
	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

	if curStep >= 1664 and curStep < 1984 then
		hueMult = hueMult + (e * 5);
		hueThing = hueThing + (e * 2 * hueMult);
		setProperty('dss.x', hueThing);
	end
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
    if n == "bloomFlash" and flashingLights then
		local bloomValues = stringSplit(v1, ',')
    	local tweenSettings = stringSplit(v2, ',')
        cancelTween('bloomX')
        setProperty('bloom.x', tonumber(bloomValues[1]))
        doTweenX('bloomX', 'bloom', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
    end
end

function onGameOver()
	setProperty('dss.x', 0)
	setProperty('bloom.x', 0)
	setProperty('blacky.alpha', 0)
end