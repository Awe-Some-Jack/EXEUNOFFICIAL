
local HEALTH_DRAIN = 0.016
local MIN_HEALTH = 0.10
local CAM_X = 500
local START_ZOOM = 1.7
local END_ZOOM = 0.64
local END_CAM_Y = 1100
local TRANSITION_TIME = 6
local UI_REVEAL_STEP = 120
local CAM_UNLOCK_STEP = 101

local HB_ELEMENTS = {'hbHealth', 'hbHealth2', 'separatorHealth'}

local sprites = {
	{name = 'sky',       path = 'cycles/sky',                        x = -1079, y = -212,  scaleX = 1.3, scaleY = 1.2},
	{name = 'mountains', path = 'cycles/motains_alph',               x = -1250, y = 13,   scaleX = 0.81, scaleY = 0.7},
	{name = 'clouds',    path = 'cycles/clouds',                     x = -1499, y = -500, scaleX = 0.95, scaleY = 0.55, alpha = 0.2},
	{name = 'hills',     path = 'cycles/motains',                    x = -1075, y = 44,   scaleX = 0.76, scaleY = 0.75},
	{name = 'waterfalls',path = 'cycles/fondo animado/waterfalls',   x = -1075, y = 44,   animated = true, prefix = "idle", scaleX = 0.76, scaleY = 0.75, fps = 12},
	{name = 'water',     path = 'cycles/water',                      x = -1069, y = 1000, scaleX = 0.8, scaleY = 0.55},
	{name = 'grass',     path = 'cycles/grass',                      x = -1027, y = 85,   scaleX = 0.75, scaleY = 0.7},
	{name = 'knuxd',     path = 'cycles/knuxd',                      x = -339,  y = 243,  animated = true, prefix = 'knuxd'},
	{name = 'treesBack', path = 'cycles/fondo animado/plant 1',      x = -1047, y = 0,    animated = true, prefix = "Símbolo 43", scaleX = 0.82, scaleY = 0.85},
	{name = 'eye',       path = 'cycles/fondo animado/ojo',          x = -614,  y = 722,  scaleX = 0.8, scaleY = 0.8, animated = true, prefix = 'Símbolo 12'},
	{name = 'flor1',     path = 'cycles/fondo animado/flor',         x = 914,   y = 922,  scaleX = 0.8, scaleY = 0.8, animated = true, prefix = 'Símbolo 39'},
	{name = 'eye',       path = 'cycles/fondo animado/ojo',          x = -614,  y = 722,  scaleX = 0.8, scaleY = 0.8, animated = true, prefix = 'Símbolo 12'},
	{name = 'flor2',     path = 'cycles/fondo animado/flor 2',       x = -414,  y = 1022,  scaleX = 0.8, scaleY = 0.8, animated = true, prefix = 'Símbolo 40'},
	{name = 'treeFront', path = 'cycles/fondo animado/plant t',      x = 1372,  y = 390,  animated = true, prefix = 'Símbolo 50',  scaleX = 0.67, scaleY = 0.72},
}

local function addSprite(def)
	if def.animated then
		makeAnimatedLuaSprite(def.name, def.path, def.x, def.y)
		addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps or 24, true)
	else
		makeLuaSprite(def.name, def.path, def.x, def.y)
	end
	local sx = def.scaleX or 1
	local sy = def.scaleY or 1
	if sx ~= 1 or sy ~= 1 then scaleObject(def.name, sx, sy) end
	if def.alpha and def.alpha ~= 1 then setProperty(def.name .. '.alpha', def.alpha) end
	addLuaSprite(def.name)
end

local function easeOutQuad(t)
	return 1 - (1 - t) * (1 - t)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local cameraLocked = true
local transitionStarted = false
local currentCamY = 0
local currentZoom = START_ZOOM
local transitionStartTime = 0

local hbOriginalY = 0
local hbHidden = false
local uiRevealed = false
local strumsY = 50
local shaderTime = 0

function onCreate()
	for _, spr in ipairs(sprites) do addSprite(spr) end
	setProperty('gf.visible', false)

	--OVERLAY--
	makeLuaSprite('overlay', 'cycles/BlackVG', 0, 0)
	setObjectCamera('overlay', 'camHUD')
	setProperty('overlay.alpha', 0)
	setBlendMode('overlay', 'add')
	addLuaSprite('overlay')

	-- EYES --
	makeLuaSprite('ais', 'characters/ojos cycles', getMidpointX('dad') - 280, getMidpointY('dad') - 530)
	setProperty('ais.alpha', 0)
	setBlendMode('ais', 'add')
	scaleObject('ais', 0.9, 0.9)
	addLuaSprite('ais', true)
end

function onCreatePost()
	setProperty('camFollow.x', CAM_X)
	setProperty('camFollow.y', currentCamY)
	setProperty('cameraFollowPos.x', CAM_X)
	setProperty('cameraFollowPos.y', currentCamY)
	setProperty('defaultCamZoom', currentZoom)
	setProperty('camGame.zoom', currentZoom)

	strumsY = downscroll and 570 or 50

	initLuaShader('water')
	setSpriteShader('water', 'water')

	addHaxeLibrary('FlxBackdrop', 'flixel.addons.display')
	runHaxeCode([[
		var oldClouds = game.getLuaObject('clouds');
		if (oldClouds != null) {
			var idx = game.members.indexOf(oldClouds);
			var clouds = new FlxBackdrop(Paths.image('cycles/clouds'), 1, 1, true, false);
			clouds.x = oldClouds.x;
			clouds.y = oldClouds.y;
			clouds.scale.set(oldClouds.scale.x, oldClouds.scale.y);
			clouds.alpha = oldClouds.alpha;
			clouds.scrollFactor.set(1, 1);
			clouds.velocity.x = 60;
			game.remove(oldClouds);
			game.insert(idx, clouds);
		}
	]])
end

function onSongStart()
	runTimer('startTransition', 1)
end

function opponentNoteHit()
	if getProperty('health') > MIN_HEALTH then
		setProperty('health', getProperty('health') - HEALTH_DRAIN)
	end
end

function onUpdate(elapsed)
	shaderTime = shaderTime + elapsed
	setShaderFloat('water', 'iTime', shaderTime)

	if not hbHidden and luaSpriteExists('hbBG') then
		hbHidden = true
		hbOriginalY = getProperty('hbBG.y')
		local hiddenY = 800
		setProperty('hbBG.y', hiddenY)
		setProperty('exeScoreTxt.y', hiddenY + (downscroll and 30 or -30))
		for _, name in ipairs(HB_ELEMENTS) do
			setProperty(name .. '.y', hiddenY + 5)
		end
	end
end

function onUpdatePost()
	if not cameraLocked then return end

	if transitionStarted then
		local elapsed = getSongPosition() / 1000 - transitionStartTime
		local eased = easeOutQuad(math.min(elapsed / TRANSITION_TIME, 1))
		currentCamY = lerp(0, END_CAM_Y, eased)
		currentZoom = lerp(START_ZOOM, END_ZOOM, eased)
	end

	setProperty('camFollow.x', CAM_X)
	setProperty('camFollow.y', currentCamY)
	setProperty('cameraFollowPos.x', CAM_X)
	setProperty('cameraFollowPos.y', currentCamY)
	setProperty('defaultCamZoom', currentZoom)
	setProperty('camGame.zoom', currentZoom)
end

function onEvent(e, v1, v2)
	if e == 'cyclesEvents' then
		if v1 == 'tweenObject' then
			local split = stringSplit(v2, ', ')
			doTweenAlpha(split[1]..'Alpha', split[1], split[2], split[3])
		end
		if v1 == 'overlay' then
			if v2 == 'hide' then
				doTweenAlpha('overlayHide', 'overlay', 0, 1)
			elseif v2 == 'show' then
				doTweenAlpha('overlayHide', 'overlay', 1, 1)
			end
		end
		if v1 == 'hideEverything' then
			for _, bg in ipairs(sprites) do
				setProperty(bg.name..'.alpha', 0)
			end
			for _, chars in ipairs({"dad", "boyfriend"}) do
				setProperty(chars..'.alpha', 0)
			end

			setProperty('ais.alpha', 1)
			doTweenAlpha('aisAlpha', 'ais', 0, 0.5)
		end
	end
end
function onStepHit()
	if cameraLocked and curStep > CAM_UNLOCK_STEP then
		cameraLocked = false
		triggerEvent('cyclesIntroEnd', '', '')
	end

	if not uiRevealed and curStep == UI_REVEAL_STEP then
		uiRevealed = true
		for i = 0, 3 do
			noteTweenY('playerStrum' .. i, i, strumsY, 0.8, 'quartOut')
			noteTweenY('opponentStrum' .. i, i + 4, strumsY, 0.8, 'quartOut')
		end
		doTweenY('hbBGTween', 'hbBG', hbOriginalY, 0.8, 'quartOut')
		doTweenY('exeScoreTxtTween', 'exeScoreTxt', hbOriginalY + (downscroll and 30 or -30), 0.8, 'quartOut')
		for _, name in ipairs(HB_ELEMENTS) do
			doTweenY(name .. 'Tween', name, hbOriginalY + 5, 0.8, 'quartOut')
		end
	end
end

function onTimerCompleted(tag)
	if tag == 'startTransition' then
		transitionStarted = true
		transitionStartTime = getSongPosition() / 1000
	end
end
