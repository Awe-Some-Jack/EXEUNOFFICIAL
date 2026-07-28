function onCreatePost()
	makeAnimatedLuaSprite('slash', 'soullessbg/slash')
	addAnimationByPrefix('slash', 'idle', 'slash', 24, false)
	setObjectCamera('slash', 'other')
	scaleObject('slash', 1.25, 1.25)
	screenCenter('slash')
	addLuaSprite('slash', true)
	setProperty('slash.alpha', 0.0001)

	for i = 1,3 do
		makeAnimatedLuaSprite('gota'..i, 'soullessbg/gota')
		addAnimationByPrefix('gota'..i, 'idle', 'idle', 6, true)
		setObjectCamera('gota'..i, 'other')
		scaleObject('gota'..i, 0.275, 0.275)
		setProperty('gota'..i..'.y', -screenHeight)
		setProperty('gota'..i..'.x', getRandomFloat(100, screenWidth - 200))
		addLuaSprite('gota'..i, true)
		setProperty('gota'..i..'.alpha', 0.0001)
	end

	makeAnimatedLuaSprite('sangre', 'soullessbg/sangre')
	addAnimationByPrefix('sangre', 'idle', 'idle', 3, true)
	setObjectCamera('sangre', 'other')
	scaleObject('sangre', 0.43, 0.43)
	screenCenter('sangre')
	addLuaSprite('sangre', true)
	setProperty('sangre.alpha', 0.0001)
end

function onEvent(n)
	if n == 'ataque' then
		for i = 1,3 do
			setProperty('gota'..i..'.x', getRandomFloat(100, screenWidth - 200))
			cancelTween('gota'..i..'xd')
			cancelTween('gota'..i..'xdd')
			setProperty('gota'..i..'.alpha', 1)
			setProperty('gota'..i..'.y', -screenHeight)
			doTweenY('gota'..i..'xd', 'gota'..i, getRandomInt(-300, 0), getRandomInt(8,10) / playbackRate, 'cubeOut')
		end

		cancelTween('sangrexd')
		cancelTimer('sangre')
		if flashingLights then cameraFlash('hud', 'FF0000', 1, true) end
		cameraShake('game', 0.005, 0.3)
		cameraShake('hud', 0.01, 0.3)
		setProperty('sangre.alpha', 1)
		if flashingLights then setProperty('slash.alpha', 1) end
		playAnim('slash', 'idle', true)
		runTimer('sangre', 6 / playbackRate)
		playSound('slash', 0.8)
		setHealth(getHealth() > 0.45 and 0.45 or 0)
		if getHealth() > 0.25 and getHealth() <= 0.45 then
			addHealth(-0.1)
		end
	end
end

function onTimerCompleted(t)
	if t == 'sangre' then
		doTweenAlpha('sangrexd', 'sangre', 0, 1.6 / playbackRate)
		for i = 1,3 do doTweenAlpha('gota'..i..'xdd', 'gota'..i, 0, 1.6 / playbackRate) end
		setProperty('slash.alpha', 0)
	end
end