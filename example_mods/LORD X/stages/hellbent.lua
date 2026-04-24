local phase2Active = false
local floatTime = 0

local FLOAT_SPEED = 1.5
local FLOAT_Y = 50
local FLOAT_X = 25

local floatingPairs = {
	{char = 'boyfriend', baseX = 650,  baseY = 1100, plat = 'platform2', platX = 440,  platY = 1250, phase = 0},
	{char = 'dad',       baseX = -700, baseY = 960,  plat = 'platform',  platX = -950, platY = 1200, phase = 0.5},
}

local stage1HQ = {
	{name = 'bg',     path = 'hellbent/GUARDIAN-N',   x = -1000, y = -430, scrollX = 0.7, scrollY = 0.7},
	{name = 'bgAlt',  path = 'hellbent/GUARDIAN',     x = -1000, y = -430, scrollX = 0.7, scrollY = 0.7, hidden = true},
	{name = 'chair',     path = 'hellbent/BG-N1', x = -1080, y = -430},
	{name = 'chairAlt',  path = 'hellbent/BG-1',  x = -1080, y = -430, hidden = true},
	{name = 'pilars',    path = 'hellbent/murofuego 1', x = -1140, y = -240, animated = true, prefix = 'Símbolo 31'},
	{name = 'pilarsAlt', path = 'hellbent/murofuego 2', x = -1140, y = -400, animated = true, prefix = 'Símbolo 30', hidden = true},
}

local stage1LQ = {
	{name = 'chair',    path = 'hellbent/GUARDIAN-N-lq', x = -1080, y = -430},
	{name = 'chairAlt', path = 'hellbent/GUARDIAN-lq',   x = -1080, y = -430, hidden = true},
}

local stage2HQ = {
	{name = 'hellBg', path = 'hellbent/hell',   x = -2500, y = -800, scale = 3, animated = true, prefix = 'hell'},
	{name = 'ring',   path = 'hellbent/anillo', x = -650,  y = -450, scale = 1.25, animated = true, prefix = 'ring'},
	{name = 'souls',  path = 'hellbent/almas',  x = -2150, y = -1420, scale = 6, animated = true, prefix = 'soul', fps = 18},
}

local normalNames = {'bg', 'chair', 'pilars'}
local altNames    = {'bgAlt', 'chairAlt', 'pilarsAlt'}

local function addSprite(def)
	if def.animated then
		makeAnimatedLuaSprite(def.name, def.path, def.x, def.y)
		addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps or 24, true)
	else
		makeLuaSprite(def.name, def.path, def.x, def.y)
	end
	if def.scale then scaleObject(def.name, def.scale, def.scale) end
	if def.scrollX then setScrollFactor(def.name, def.scrollX, def.scrollY or def.scrollX) end
	addLuaSprite(def.name)
	if def.hidden then setProperty(def.name .. '.alpha', 0.0001) end
end

function onCreatePost()
	local sprites = lowQuality and stage1LQ or stage1HQ
	for _, spr in ipairs(sprites) do addSprite(spr) end

	if not lowQuality then
		makeLuaSprite('glow', 'hellbent/glow', -1420, -620)
		setBlendMode('glow', 'add')
		addLuaSprite('glow')
	end

	makeLuaSprite('vignette', 'VG')
	setProperty('vignette.color', getColorFromHex('000000'))
	setObjectCamera('vignette', 'hud')
	addLuaSprite('vignette', true)

	setProperty('boyfriend.alpha', 0)

	makeAnimatedLuaSprite('eyes', 'characters/ojos')
	addAnimationByPrefix('eyes', 'idle', 'idle', 0, false)
	setObjectCamera('eyes', 'other')
	addLuaSprite('eyes', true)

	if not lowQuality then
		for _, spr in ipairs(stage2HQ) do addSprite(spr) end
		for _, spr in ipairs(stage2HQ) do setProperty(spr.name .. '.alpha', 0.0001) end
	else
		makeLuaSprite('hellBg', 'hellbent/bg-lq', -2500, -800)
		scaleObject('hellBg', 3, 3)
		addLuaSprite('hellBg')
		setProperty('hellBg.alpha', 0.0001)
	end

	for i, data in ipairs(floatingPairs) do
		makeLuaSprite(data.plat, 'hellbent/plataformna', data.platX, data.platY)
		if i == 1 then setProperty(data.plat .. '.flipX', true) end
		scaleObject(data.plat, 0.55, 0.55)
		setProperty(data.plat .. '.alpha', 0.0001)
		addLuaSprite(data.plat)
	end

	addCharacterToList('bf hellbent', 'bf')
	addCharacterToList('hellbemnt', 'dad')
end

function onEvent(n, v1)
	if n ~= 'hellbentEvents' then return end

	if v1 == 'startwhite' then
		for _, name in ipairs(normalNames) do
			removeLuaSprite(name, true)
		end
		for _, name in ipairs(altNames) do
			setProperty(name .. '.alpha', 1)
		end

	elseif v1 == 'changeBG' then
		phase2Active = true

		for _, name in ipairs(normalNames) do
			if luaSpriteExists(name) then removeLuaSprite(name, true) end
		end
		for _, name in ipairs(altNames) do
			removeLuaSprite(name, true)
		end
		removeLuaSprite('glow', true)
		removeLuaSprite('vignette', true)
		removeLuaSprite('eyes', true)

		setProperty('hellBg.alpha', 1)
		if not lowQuality then
			setProperty('ring.alpha', 1)
			setProperty('souls.alpha', 1)
		end

		for _, data in ipairs(floatingPairs) do
			setProperty(data.plat .. '.alpha', 1)
		end

		setProperty('boyfriend.alpha', 1)
		triggerEvent('Change Character', 'bf', 'bf hellbent')
		triggerEvent('Change Character', 'dad', 'hellbemnt')
		callMethod('boyfriend.setPosition', {650, 1100})
		callMethod('dad.setPosition', {-700, 960})
	end
end

function onUpdatePost(elapsed)
	if not phase2Active then
		local zoom = getProperty('camGame.zoom')
		setProperty('eyes.alpha', getProperty('BlackGraphicHUD.alpha'))
		scaleObject('eyes', zoom * 0.5, zoom * 0.5, false)
		setProperty('eyes.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))
		setProperty('eyes.visible', getProperty('dad.animation.curAnim.name') == 'idle')

		local scrollX = getProperty('camGame.scroll.x')
		local scrollY = getProperty('camGame.scroll.y')
		local offsetFactor = 1 - zoom
		setProperty('eyes.x', ((getProperty('dad.x') - 54 - scrollX) * zoom) + (screenWidth * 0.5) * offsetFactor)
		setProperty('eyes.y', ((getProperty('dad.y') + 4 - scrollY) * zoom) + (screenHeight * 0.5) * offsetFactor)
	else
		floatTime = floatTime + elapsed * FLOAT_SPEED
		for _, p in ipairs(floatingPairs) do
			local t = floatTime + p.phase
			setProperty(p.char .. '.y', p.baseY + math.sin(t) * FLOAT_Y)
			setProperty(p.char .. '.x', p.baseX + math.cos(t) * FLOAT_X)
			setProperty(p.plat .. '.y', p.platY + math.sin(t) * FLOAT_Y)
			setProperty(p.plat .. '.x', p.platX + math.cos(t) * FLOAT_X)
		end
	end
end
