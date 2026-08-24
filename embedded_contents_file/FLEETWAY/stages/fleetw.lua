local fleetBG = {
	{name = '4', path = 'bg/4', animated = false, x = 0, y = 0, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false},
	{name = '42', path = 'bg/4-alt', animated = false, x = 0, y = 0, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false},
	{name = '1', path = 'bg/1', animated = false, x = 650, y = 1320, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false, lowQualityHide = true},
	{name = '2', path = 'bg/2', animated = false, x = 850, y = 1170, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false, lowQualityHide = true},
	{name = '3', path = 'bg/3', animated = false, x = 780, y = 1790, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false, lowQualityHide = true},
	{name = '5', path = 'bg/5', animated = false, x = 1600, y = 200, scaleX = 2, scaleY = 2, scrollX = 0.9, scrollY = 0.9, front = false, lowQualityHide = true},
	{name = '5f', path = 'bg/5', animated = false, x = 3100, y = 1300, angle = 180, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false, lowQualityHide = true},
	{name = 'XDD', path = 'bg/DUDU', animated = true, animName = 'idle', animPrefix = 'Emerald Beam Charged', fps = 24, loop = true,  x = 1480, y = -1000, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false},
	{name = 'XDD2', path = 'bg/DUDU2', animated = true, animName = 'idle', animPrefix = 'Emerald Beam Charged', fps = 24, loop = true,  x = 1480, y = -1000, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false},
	{name = 'emeralds', path = 'bg/esmeraldas', animated = true, animName = 'idle', animPrefix = 'TheEmeralds', fps = 24, loop = true, x = 2140, y = 1200, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = false},
	{name = 'fuentes-2', path = 'bg/fuentes-2', animated = false, x = 1910, y = 1890, scaleX = 0.51, scaleY = 0.51, scrollX = 1, scrollY = 1, front = false},
	{name = 'fuente', path = 'bg/fuentes', animated = true, animName = 'fuente', animPrefix = 'Símbolo 466', fps = 24, loop = false,  x = 1910, y = (1890 - 220), scaleX = 0.51, scaleY = 0.51, scrollX = 1, scrollY = 1, front = false},
	{name = '6', path = 'bg/6', animated = false, x = 3500, y = 750, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, front = true, lowQualityHide = true},
	{name = '7', path = 'bg/7', animated = false, x = 1400, y = 500, scaleX = 2, scaleY = 2, scrollX = 1.2, scrollY = 1.2, front = true, lowQualityHide = true},
	{name = '6f', path = 'bg/6', animated = false, x = 4400, y = 400, scaleX = 2.8, scaleY = 2.8, scrollX = 1.2, scrollY = 1.2, front = true, lowQualityHide = true},
	{name = 'cochinito', path = 'bg/puelco', animated = true, animName = 'idle', animPrefix = 'Porker Lewis', fps = 24, loop = true,  x = 3750, y = 1750, scaleX = 1.8, scaleY = 1.8, scrollX = 1.2, scrollY = 1.2, front = true, lowQualityHide = true},
}

local firstTime = true

function onCreatePost()
	for _, e in ipairs(fleetBG) do
		if not (lowQuality and e.lowQualityHide) then
			if e.animated == true then
				makeAnimatedLuaSprite(e.name, e.path, e.x, e.y)
				addAnimationByPrefix(e.name, e.animName, e.animPrefix, e.fps, e.loop)
			else
				makeLuaSprite(e.name, e.path, e.x, e.y)
			end
			
			scaleObject(e.name, e.scaleX, e.scaleY)
			setScrollFactor(e.name, e.scrollX, e.scrollY)
			setProperty(e.name..'.angle', (e.angle == nil and 0 or e.angle))
			addLuaSprite(e.name, e.front)
			if not isStoryMode then
				setProperty('fuente.visible', false)

				setProperty('4.visible', true)
				setProperty('42.visible', false)

				setProperty('XDD.visible', true)
				setProperty('XDD2.visible', false)
			else
				if seenCutscene == true then
				setProperty('fuente.visible', false)

				setProperty('4.visible', true)
				setProperty('42.visible', false)

				setProperty('XDD.visible', true)
				setProperty('XDD2.visible', false)
			else
				setProperty('fuente.visible', true)

				setProperty('4.visible', false)
				setProperty('42.visible', true)

				setProperty('XDD.visible', false)
				setProperty('XDD2.visible', true)
			end
			end
		end
		if lowQuality then setProperty(e.name..'.antialiasing', false) end
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnim('cochinito', 'idle', true)
	end
end

function onStartCountdown()
	runTimer('pipipi', 0.02)
	if not isStoryMode then return end
	if seenCutscene then return end
	if firstTime then
		setProperty('boyfriend.visible', false)
		setProperty('camHUD.alpha', 0)
		setProperty('camGame.zoom', 1.1)

		runTimer('startanim', 0.4)
		runTimer('lol', 1.3)
		runTimer('xdddddd', 5.3)

		firstTime = false
		return Function_Stop
	end

	return Function_Continue
end

function onTimerCompleted(t)
	if t == 'pipipi' then callMethod('camGame.snapToTarget') end
	if t == 'startanim' then
		doTweenZoom('fuckyeah', 'camGame', 1.3, 1.2, 'circInOut')
		doTweenY('CamTweenY', 'camGame.targetOffset', 20, 1.2, 'circInOut')
		playAnim('fuente', 'fuente', true)
		playSound('robot')
		cameraFlash('game', 'FF0000', 0.7, true)
	end
	if t == 'lol' then
		playSound('sonicscream', 0.85)
	end
	if t == 'xdddddd' then
		setObjectOrder('fuentes-2', getObjectOrder('dadGroup') + 1)
		startCountdown()
		playSound('beam', 0.6)
		cameraFlash('game', 'FFFFBB', 1, true)
		setProperty('fuente.visible', false)
		setProperty('4.visible', true)
		setProperty('42.visible', false)
		doTweenAlpha('camdasdadsHUD', 'camHUD', 1, 1)
		setProperty('boyfriend.visible', true)

		doTweenZoom('fuckyeah', 'camGame', 0.9, 0.6, 'circOut')

		setProperty('XDD.visible', true)
		setProperty('XDD2.visible', false)
	end
end

function noteMissPress(nt) if curBeat >= 252 then playAnim('boyfriend', getProperty('singAnimations['..nt..']') .. 'miss-alt', true) end end