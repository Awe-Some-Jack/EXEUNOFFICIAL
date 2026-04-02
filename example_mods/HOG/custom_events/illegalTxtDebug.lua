function onEvent(n)
	if n == 'illegalTxtDebug' then
		local tag = 'illegal'..math.floor(getSongPosition())
		makeLuaSprite(tag, 'manual-blast/glitch/illegalinstruction')
		setObjectCamera(tag, 'hud')
		setProperty(tag..'.antialiasing', false)
		callMethod(tag..'.setPosition', {getRandomInt(-(getProperty(tag..'.width') / 2), screenWidth - (getProperty(tag..'.width') / 2)), getRandomInt(-(getProperty(tag..'.height') / 2), screenHeight - (getProperty(tag..'.height') / 2))})
		if getRandomBool(25) then setProperty(tag..'.color', getColorFromHex('0000000')) end
		addLuaSprite(tag, true)
		runTimer(tag, 5)
	end
end

function onTimerCompleted(t)
	if stringStartsWith(t, 'illegal') then
		removeLuaSprite(t, true)
	end
end