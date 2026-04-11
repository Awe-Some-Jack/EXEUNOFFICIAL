function onEvent(n, val1, val2)
	if n == 'Flash' then
		splitted = stringSplit(val1:gsub(' ', ''), ',')
		config = {
			color = splitted[1] or 'FFFFFF',
			duration = splitted[2] or 1
		}
		cam = val2 or 'game'
		if flashingLights then cameraFlash(cam, config.color, config.duration, true) end
	end
end