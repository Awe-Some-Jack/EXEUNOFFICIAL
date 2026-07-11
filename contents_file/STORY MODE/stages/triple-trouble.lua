--[==[local curSect = 'tails'
local onFlashback = false
local canMakeParticles = false
local hideParticles = false
local particles = {}
local shaderTimer = 0
local frameCounter = 0

local PATHS = {
	normal = 'tt/bgn/',
	xeno   = 'tt/bgx/',
	tails  = 'tt/tails/',
	knux   = 'tt/knux/',
	egg    = 'tt/egg/',
}

local normal = {
	{name = 'bg',         path = 'bg',         x = -600,  y = -200,  scroll = 0.3,   front = false},
	{name = 'trees4',     path = 'trees4',      x = -600,  y = -300,  scroll = 0.3,   front = false, lowQualityHide = true},
	{name = 'trees3',     path = 'trees3',      x = -900,  y = -200,  scroll = 0.55,  front = false, lowQualityHide = true},
	{name = 'fire4',      path = 'fire/FIRE 2',  x = -1000, y = -2700, scroll = 0.55,  front = false, scale = 6, scaleY = 10, animated = true, animation = {'fire instancia 1', 24, true}},
	{name = 'trees2',     path = 'trees2',      x = -800,  y = -200,  scroll = 0.7,   front = false, fireOffset = -662, lowQualityHide = true},
	{name = 'fire3',      path = 'fire/FIRE',    x = -600,  y = 100,   scroll = 0.85,  front = false, scale = 3, animated = true, animation = {'fuego true instancia 1', 24, true}, active = true, lowQualityHide = true},
	{name = 'trees1',     path = 'trees1',      x = -600,  y = -200,  scroll = 0.85,  front = false, fireOffset = -684, lowQualityHide = true},
	{name = 'fire2',      path = 'fire/FIRE',    x = -800,  y = 400,   scroll = 0.925, front = false, scale = 3, animated = true, animation = {'fuego true instancia 1', 24, true}, active = true},
	{name = 'floor',      path = 'floor',       x = -600,  y = -200,  scroll = 1,     front = false, fireOffset = -679},
	{name = 'foreground', path = 'foreground',   x = -600,  y = -200,  scroll = 1.2,   front = true,  fireOffset = -347, lowQualityHide = true},
	{name = 'fire1',      path = 'fire/FIRE 2',  x = -800,  y = 100,   scroll = 1.2,   front = true,  scale = 6, scaleY = 6, animated = true, animation = {'fire instancia 1', 24, true}, active = true, lowQualityHide = true},
}

local xeno = {
	{name = 'bgx',          path = 'bg',              x = -1000, y = -1000, scroll = 0.3,  front = false},
	{name = 'trees4x',      path = 'trees4',           x = -800,  y = -800,  scroll = 0.3,  front = false, lowQualityHide = true},
	{name = 'trees3x',      path = 'trees3',           x = -700,  y = -600,  scroll = 0.55, front = false, lowQualityHide = true},
	{name = 'xfire4',       path = 'fire/FIRE 2',      x = -1000, y = -700,  scroll = 0.55, front = false, scale = 6, scaleY = 10, animated = true, animation = {'fire instancia 1', 24, true}, active = true},
	{name = 'trees2x',      path = 'trees2',           x = -600,  y = -600,  scroll = 0.7,  front = false, lowQualityHide = true},
	{name = 'staticx',      path = 'NewTitleMenuBG',    x = -300,  y = -200,  scroll = 0.85, front = false, scale = 6, animated = true, animation = {'TitleMenuSSBG instance 1', 24, true}, active = false},
	{name = 'xfire3',       path = 'fire/FIRE',         x = -600,  y = 2250,  scroll = 0.85, front = false, scale = 3, animated = true, animation = {'fuego true instancia 1', 24, true}, active = true, lowQualityHide = true},
	{name = 'trees1x',      path = 'trees1',           x = -600,  y = -200,  scroll = 0.9,  front = false, lowQualityHide = true},
	{name = 'xfire2',       path = 'fire/FIRE',         x = -800,  y = 2400,  scroll = 0.9,  front = false, scale = 3, animated = true, animation = {'fuego true instancia 1', 24, true}, active = true},
	{name = 'crystalsx',    path = 'crystals',          x = -400,  y = 600,   scroll = 1,    front = false, lowQualityHide = true},
	{name = 'floorx',       path = 'floor',            x = -600,  y = -800,  scroll = 1,    front = false},
	{name = 'foreground2x', path = 'foreground2',       x = -600,  y = -200,  scroll = 1.2,  front = true,  lowQualityHide = true},
	{name = 'xfire1',       path = 'fire/FIRE 2',      x = -800,  y = 2300,  scroll = 1.2,  front = true,  scale = 6, scaleY = 6, animated = true, animation = {'fire instancia 1', 24, true}, active = true, lowQualityHide = true},
	{name = 'foregroundx',  path = 'foreground',        x = -1700, y = 1300,  scroll = 1.3,  front = true,  lowQualityHide = true},
}

local tails = {
	{name = 'bg5t', path = 'bg5', x = -650, y = -900, scroll = 0.3, front = false},
	{name = 'bg4t', path = 'bg4', x = -450, y = -850, scroll = 0.55, front = false},
	{name = 'bg3t', path = 'bg3', x = -450, y = -850, scroll = 0.6, front = false},
	{name = 'bg2t', path = 'bg2', x = -450, y = -850, scroll = 0.65, front = false},
	{name = 'bg1t', path = 'bg1', x = -450, y = -850, scroll = 0.7, front = false},
	{name = 'floort', path = 'floor', x = -1850, y = -2350, scroll = 1, front = false},
}

local knux = {
	{name = 'bgk',        path = 'bg',        x = -600, y = -300, scroll = 0.4, scale = 0.7, front = false},
	{name = 'platform3k', path = 'platform3',  x = -800, y = -300, scroll = 0.5, scale = 0.7, front = false, lowQualityHide = true},
	{name = 'fog2k',      path = 'fog2',       x = -500, y = -300, scroll = 0.5, scale = 0.7, front = false, lowQualityHide = true},
	{name = 'platform2k', path = 'platform2',  x = -500, y = -300, scroll = 0.6, scale = 0.6, front = false, lowQualityHide = true},
	{name = 'platformk',  path = 'platform',   x = -450, y = -200, scroll = 0.7, scale = 0.6, front = false, lowQualityHide = true},
	{name = 'fogk',       path = 'fog',        x = -700, y = -500, scroll = 0.8, front = false},
	{name = 'floork',     path = 'floor',      x = -700, y = -350, scroll = 1,   front = false},
}

local egg = {
	{name = 'skye', path = 'sky', x = -680, y = -850, scroll = 0.3, front = false},
	{name = 'bg1e', path = 'bg1', x = -630, y = -770, scroll = 0.45, front = false},
	{name = 'bg2e', path = 'bg2', x = -580, y = -670, scroll = 0.65, front = false},
	{name = 'bg3e', path = 'bg3', x = -520, y = -600, scroll = 0.8, front = false},
	{name = 'floore', path = 'floor', x = -500, y = -650, scroll = 1, front = false},
	{name = 'overlaye', path = 'overlay', x = -500, y = -650, scroll = 1, front = true}
}

local function getScale(def, isAnimated, defaultScale)
	local base = def.scale or defaultScale
	local sy = def.scaleY or base
	if isAnimated then
		return base, sy
	end
	return base * 1.5, sy * 1.5
end

local function addStageSprite(def, basePath, opts)
	if def.lowQualityHide and lowQuality then return end

	local defaultScale = opts.defaultScale or 0.8
	local startVisible = opts.startVisible
	local startAlpha = opts.startAlpha
	local createFire = opts.createFire or false
	local isAnimated = def.animated == true

	if startVisible == nil then startVisible = true end
	if startAlpha == nil then startAlpha = 1 end

	local sx, sy = getScale(def, isAnimated, defaultScale)

	if isAnimated then
		makeAnimatedLuaSprite(def.name, basePath .. def.path, def.x, def.y)
		local animFps = lowQuality and math.floor(def.animation[2] * 0.6) or def.animation[2]
		addAnimationByPrefix(def.name, def.animation[1], def.animation[1], animFps, def.animation[3])
		playAnim(def.name, def.animation[1], true)

		if not startVisible then
			setProperty(def.name .. '.visible', false)
		end
	else
		makeLuaSprite(def.name, basePath .. def.path, def.x, def.y)
	end

	scaleObject(def.name, sx, sy)
	setScrollFactor(def.name, def.scroll, def.scroll)
	setProperty(def.name .. '.antialiasing', not lowQuality)
	addLuaSprite(def.name, def.front)

	if startAlpha ~= 1 then
		setProperty(def.name .. '.alpha', startAlpha)
	end

	if opts.xenoStyle then
		setProperty(def.name .. '.alpha', (def.active ~= false) and 1 or 0)
		setProperty(def.name .. '.visible', false)
	end

	if isAnimated and startVisible and not opts.xenoStyle then
		setProperty(def.name .. '.visible', false)
	end

	if createFire and not isAnimated then
		local fireOffset = def.fireOffset or 0
		local firePath = basePath .. 'fire/' .. def.path
		local fireName = def.name .. 'fire'

		makeLuaSprite(fireName, firePath, def.x, def.y + fireOffset)
		setScrollFactor(fireName, def.scroll, def.scroll)
		scaleObject(fireName, sx, sy)
		setProperty(fireName .. '.antialiasing', not lowQuality)
		addLuaSprite(fireName, def.front)
		setProperty(fireName .. '.alpha', 0)

		if not startVisible then
			setProperty(fireName .. '.visible', false)
		end
	end
end

local function addStageGroup(group, basePath, opts)
	for _, def in ipairs(group) do
		addStageSprite(def, basePath, opts)
	end
end

local function destroyGroup(group, alsoFire)
	for _, def in ipairs(group) do
		if not (def.lowQualityHide and lowQuality) then
			removeLuaSprite(def.name, true)
			if alsoFire and not def.animated then
				removeLuaSprite(def.name .. 'fire', true)
			end
		end
	end
end

local function setGroupVisible(group, visible)
	for _, def in ipairs(group) do
		if not (def.lowQualityHide and lowQuality) then
			setProperty(def.name .. '.visible', visible)
		end
	end
end

local function setGroupAlpha(group, alpha, alsoFire)
	for _, def in ipairs(group) do
		if not (def.lowQualityHide and lowQuality) then
			setProperty(def.name .. '.alpha', alpha)
			if alsoFire and not def.animated then
				setProperty(def.name .. 'fire.alpha', alpha)
			end
		end
	end
end

local function spawnParticle(xMin, xMax, spawnY)
	local id = 'particle' .. math.floor(getSongPosition())
	local pScale = getRandomFloat(0.6, 1.3)
	local pScroll = getRandomFloat(0.8, 1.2)

	makeLuaSprite(id, 'tt/particles/dust' .. getRandomInt(1, 6), getRandomInt(xMin, xMax), spawnY)
	setScrollFactor(id, pScroll, pScroll)
	scaleObject(id, pScale, pScale)
	setProperty(id .. '.acceleration.x', getRandomFloat(-300, 50))
	setProperty(id .. '.acceleration.y', getRandomFloat(-400, -100))
	setProperty(id .. '.antialiasing', not lowQuality)
	setProperty(id .. '.angularVelocity', getRandomFloat(25, 240))
	addLuaSprite(id, getRandomBool())
	setProperty(id .. '.alpha', hideParticles and 0 or 1)

	table.insert(particles, id)
end

local function fadeParticles(duration)
	canMakeParticles = false
	for _, p in ipairs(particles) do
		doTweenAlpha(p, p, 0, crochet / (1000 / duration) / playbackRate)
	end
end

local function setParticlesAlpha(alpha)
	for _, p in ipairs(particles) do
		setProperty(p .. '.alpha', alpha)
	end
end

local function removeParticle(tag)
	for i, p in ipairs(particles) do
		if p == tag then
			table.remove(particles, i)
			break
		end
	end
	removeLuaSprite(tag, true)
end

function onCreate()
	addStageGroup(normal, PATHS.normal, {defaultScale = 0.8, createFire = true, startVisible = true})
	addStageGroup(tails, PATHS.tails, {defaultScale = 0.8, startAlpha = 0.001})
	addStageGroup(knux, PATHS.knux, {defaultScale = 0.8, startAlpha = 0.001})
	addStageGroup(egg, PATHS.egg, {defaultScale = 0.8, startAlpha = 0.001})
	addStageGroup(xeno, PATHS.xeno, {defaultScale = 1, createFire = true, startVisible = false, xenoStyle = true})

	makeLuaSprite('overlayt')
	makeGraphic('overlayt', screenWidth, screenHeight, 'FF7100')
	setProperty('overlayt.alpha', 0.3)
	setObjectCamera('overlayt', 'hud')
	setBlendMode('overlayt', 'add')
	addLuaSprite('overlayt')
	setProperty('overlayt.visible', false)

	makeLuaSprite('glow', 'tt/bgn/glow', -700, 500)
	setScrollFactor('glow', 1.2, 1.2)
	scaleObject('glow', 2.5, 1.5)
	setProperty('glow.alpha', 0.3)
	setProperty('glow.antialiasing', not lowQuality)
	setBlendMode('glow', 'add')
	addLuaSprite('glow', true)

	makeLuaSprite('vg', 'VG')
	setProperty('vg.color', getColorFromHex('FF0000'))
	setObjectCamera('vg', 'other')
	addLuaSprite('vg')
	setProperty('vg.visible', false)

	makeLuaSprite('fogOverlay', 'overlay/fog')
	setObjectCamera('fogOverlay', 'other')
	addLuaSprite('fogOverlay')
	setProperty('fogOverlay.visible', false)
	if not lowQuality then
		setSpriteShader('fogOverlay', 'wavyDistortion')
		setBlendMode('fogOverlay', 'shader')
		setShaderFloat('fogOverlay', 'amount', 2)
	end
	setProperty('fogOverlay.alpha', 0.4)

	if not lowQuality then
		addCharacterToList('BEAST', 'dad')
		addCharacterToList('BEAST-RIGHT', 'dad')
		addCharacterToList('knux', 'dad')
		addCharacterToList('bf-perspective-right', 'bf')
		addCharacterToList('bf-perspectiveLeft', 'bf')
		addCharacterToList('bf-mirror', 'bf')
	end
	addCharacterToList('eggman', 'dad')
end

function onUpdatePost(elapsed)
	frameCounter = frameCounter + 1
	if frameCounter % 30 == 0 and canMakeParticles and not lowQuality then
		spawnParticle(0, 2000, 1500)
	end

	if not lowQuality then
		shaderTimer = shaderTimer + elapsed * playbackRate
		setShaderFloat('fogOverlay', 'iTime', shaderTimer)
	end
end

function onBeatHit()
	if curBeat % 4 == 0 then
		doTweenAlpha('vg1', 'vg', 1, crochet / (1000 / 2) / playbackRate)
	elseif curBeat % 4 == 2 then
		doTweenAlpha('vg2', 'vg', 0, crochet / (1000 / 2) / playbackRate)
	end
end

local function onBGChange(phase)
	if phase == 'xeno' then
		if onFlashback then triggerEvent('flashbackstt', '', '') end

		triggerEvent('Change Character', 'dad', 'BEAST')
		triggerEvent('Change Character', 'bf', 'bf-perspective-right')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') + 400, getProperty('dadGroup.y') + 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 100, getProperty('boyfriendGroup.y') + 150})

		setGroupVisible(normal, false)
		setGroupVisible(xeno, true)

		setProperty('staticx.alpha', 1)

	elseif phase == 'xeno2' then
		if onFlashback then triggerEvent('flashbackstt', '', '') end

		triggerEvent('Change Character', 'dad', 'BEAST-RIGHT')
		triggerEvent('Change Character', 'bf', 'bf-perspectiveLeft')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') + 300, getProperty('dadGroup.y') + 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 0, getProperty('boyfriendGroup.y') + 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) then
				if not def.animated then
					removeLuaSprite(def.name, true)
				end
				setProperty(def.name .. 'fire.alpha', 0.001)
			end
		end

		for _, def in ipairs(xeno) do
			if not (def.lowQualityHide and lowQuality) then
				setProperty(def.name .. '.visible', true)
				setProperty(def.name .. '.flipX', true)
				if not def.animated then
					setProperty(def.name .. 'fire.flipX', true)
					setProperty(def.name .. 'fire.alpha', 0.001)
				end
			end
		end

		removeLuaSprite('staticx', true)

	elseif phase == 'xeno3' then
		if onFlashback then triggerEvent('flashbackstt', '', '') end

		triggerEvent('Change Character', 'dad', 'BEAST')
		triggerEvent('Change Character', 'bf', 'bf-perspective-right')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') + 400, getProperty('dadGroup.y') + 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 100, getProperty('boyfriendGroup.y') + 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) and not def.animated then
				removeLuaSprite(def.name .. 'fire', true)
			end
		end

		for _, def in ipairs(xeno) do
			if not (def.lowQualityHide and lowQuality) then
				if def.animated then
					setProperty(def.name .. '.visible', true)
				end
				if not def.animated then
					setProperty(def.name .. 'fire.visible', true)
					setProperty(def.name .. 'fire.flipX', false)
				end
			end
		end

		setProperty('vg.visible', true)

		if not lowQuality then
			removeLuaSprite('bgxfire', true)
			removeLuaSprite('trees4x', true)
			removeLuaSprite('trees3x', true)
			removeLuaSprite('fire4x', true)
			removeLuaSprite('trees2x', true)
		end

	elseif phase == 'knux' then
		triggerEvent('Change Character', 'dad', 'knux')
		triggerEvent('Change Character', 'bf', 'bf-mirror')
		triggerEvent('Knux', '', '')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') - 300, getProperty('dadGroup.y') - 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') - 300, getProperty('boyfriendGroup.y') - 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) and not def.animated then
				setProperty(def.name .. '.visible', true)
				setProperty(def.name .. '.flipX', true)
			end
		end
		setGroupVisible(xeno, false)

		if not lowQuality then
			setProperty('trees1.x', getProperty('trees1.x') + 150)
			setProperty('trees2.x', getProperty('trees2.x') + 50)
			setProperty('trees3.x', getProperty('trees3.x') + 500)
			setProperty('trees4.x', getProperty('trees4.x') + 100)
		end

		curSect = 'knux'

	elseif phase == 'egg' then
		triggerEvent('Change Character', 'dad', 'eggman')
		triggerEvent('Change Character', 'bf', 'bf')
		triggerEvent('Knux', '', '')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') - 350, getProperty('dadGroup.y') - 500})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 200, getProperty('boyfriendGroup.y') - 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) then
				setProperty(def.name .. '.visible', true)
				if not def.animated then
					setProperty(def.name .. 'fire.alpha', 1)
				end
			end
		end
		for _, def in ipairs(xeno) do
			if not (def.lowQualityHide and lowQuality) then
				setProperty(def.name .. '.visible', false)
				if not def.animated then
					setProperty(def.name .. 'fire.visible', false)
				end
			end
		end

		curSect = 'egg'
	end
end

local function onFireStart()
	for _, def in ipairs(xeno) do
		if not (def.lowQualityHide and lowQuality) and not def.animated then
			setProperty(def.name .. 'fire.visible', true)
			doTweenAlpha(def.name, def.name .. 'fire', 1, crochet / (1000 / 8) / playbackRate)
		end
	end

	local fireDuration = crochet / (1000 / 10) / playbackRate
	doTweenY('xfire4', 'xfire4', -2700, fireDuration, 'cubeOut')
	if not lowQuality then doTweenY('xfire3', 'xfire3', 250, fireDuration, 'cubeOut') end
	doTweenY('xfire2', 'xfire2', 400, fireDuration, 'cubeOut')
	if not lowQuality then doTweenY('xfire1', 'xfire1', 300, fireDuration, 'cubeOut') end

	canMakeParticles = true
end

local function onFlashbackToggle()
	onFlashback = not onFlashback
	setProperty('fogOverlay.visible', onFlashback)
	setProperty('glow.visible', not onFlashback)

	if curSect == 'tails' then
		if onFlashback then
			if flashingLights then triggerEvent('Flash', 'FFFFFF,1', 'game') end
			setGroupAlpha(normal, 0)
			setGroupAlpha(tails, 1)
			setProperty('overlayt.visible', true)
		else
			setGroupAlpha(normal, 1)
			destroyGroup(tails, false)
			setProperty('overlayt.visible', false)
		end

	elseif curSect == 'knux' then
		if onFlashback then
			if flashingLights then triggerEvent('Flash', 'FFFFFF,1', 'game') end
			setGroupAlpha(normal, 0)
			setGroupAlpha(knux, 1)
		else
			setGroupAlpha(normal, 1)
			destroyGroup(knux, false)
		end

	elseif curSect == 'egg' then
		if onFlashback then
			if flashingLights then triggerEvent('Flash', 'FFFFFF,1', 'game') end
			setGroupAlpha(normal, 0, true)
			setGroupAlpha(egg, 1)
			hideParticles = true
			setParticlesAlpha(0)

			if shadersEnabled and not lowQuality then
				runHaxeCode("game.camGame.filters = [];")
			end
		else
			setGroupAlpha(normal, 1, true)
			destroyGroup(egg, false)
			hideParticles = false
			setParticlesAlpha(1)

			if shadersEnabled and not lowQuality then
				runHaxeCode([[game.camGame.filters = [
					new ShaderFilter(game.getLuaObject('hws').shader),
					new ShaderFilter(game.getLuaObject('cab').shader),
					new ShaderFilter(game.getLuaObject('glitch').shader)
					];]])
			end
		end
	end
end

function onEvent(n, v1, v2)
	if n == 'tripletroublebgchange' then
		onBGChange(v1)
	elseif n == 'ttfirestart' then
		onFireStart()
	elseif n == 'flashbackstt' then
		onFlashbackToggle()
	elseif n == 'fadecam' then
		fadeParticles(tonumber(v2))
	elseif n == 'fadeHUD' then
		doTweenAlpha('camHUDAlpha', 'camHUD', 0, 2.8)
	end
end

function onTweenCompleted(tag)
	if stringEndsWith(tag, 'x') then
		removeLuaSprite(tag, true)
	end

	if tag:match('particle') then
		removeParticle(tag)
	end
end

function makeParticle(xMin, xMax, spawnY)
	spawnParticle(xMin, xMax, spawnY)
end]==]