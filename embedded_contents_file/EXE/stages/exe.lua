local exe = {
	{name = '7', path = '7', x = -1200, y = -1850, scroll = 0.4},
	{name = '6', path = '6', x = -1200, y = -1850, scroll = 0.4},
	{name = '52', path = '52', x = -1100, y = -1900, scroll = 0.6},
	{name = '51', path = '51', x = -1100, y = -1900, scroll = 0.7},
	{name = '53', path = '53', x = -1100, y = -1900, scroll = 0.8},
	{name = '5', path = '5', x = -1100, y = -1050, scroll = 0.9},
	{name = '4', path = '4', x = -900, y = -900, scroll = 1},
	{name = '2', path = '2', x = 660, y = 690, scroll = 1, front = true},
	{name = 't', path = 't', x = 250, y = 280, scroll = 1, scale = 1.6},
	{name = 'k', path = 'k', x = 700, y = 600, scroll = 1, front = true, scale = 1.6},
	{name = '3', path = '3', x = -1100, y = 200, scroll = 1.1, front = true},
	{name = '1', path = '1', x = -1050, y = 0, scroll = 1.2, front = true},
}

setProperty('camGame.visible', false) setProperty('camHUD.visible', false)
setProperty('cameraSpeed', 99999)
setProperty('camGame.targetOffset.y', -280)
setProperty('camGame.targetOffset.x', -150)
setPropertyFromClass('flixel.addons.transition.FlxTransitionableState', 'skipNextTransIn', true)
function onCreatePost()
	for _,e in ipairs(exe) do
		if not (lowQuality and e.lowQualityHide) then
			if e.alpha == nil then e.alpha = 1 end
			if e.front == nil then e.front = false end
			if e.scale == nil then e.scale = 2 end
			makeLuaSprite(e.name, 'black sun/'..e.path, e.x, e.y)
			setScrollFactor(e.name, e.scroll, e.scroll)
			scaleObject(e.name, ((e.scaleX == nil) and e.scale or e.scaleX), ((e.scaleY == nil) and e.scale or e.scaleY))
			setProperty(e.name..'.alpha', e.alpha)
			addLuaSprite(e.name, e.front)
		end

		if lowQuality then setProperty(e.name..'.antialiasing', false) end
	end

	makeLuaSprite('blackbgxd',nil, -1000, -600)
	makeGraphic('blackbgxd', 3500, 1500, '000000')
	addLuaSprite('blackbgxd')
	setProperty('blackbgxd.alpha', 0)

	setScrollFactor('gf', 1, 1)
	setProperty('cameraSpeed', 1)
	runTimer('xd', 0.1)
	if seenCutscene then
		setProperty('camGame.targetOffset.y', 0)
		setProperty('camGame.zoom', 0.45)
		setProperty('defaultCamZoom', 0.45)
	end
end

function onTimerCompleted(t) if t == 'xd' then setProperty('camGame.visible', true) setProperty('camHUD.visible', true) end end

function onSongStart()
	if firstPlay then return end
	setProperty('camGame.targetOffset.y', 0)
	setProperty('camZooming', true)
	setProperty('defaultCamZoom', 0.45)
end

function onEvent(n) if n == 'cambiarsolxd' then setProperty('7.y', -1400) setProperty('6.y', -1400) end end