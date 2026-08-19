local canShake = true
local shakeIntensity = 0.005
local vignetteMode = 'none' -- 'none', 'slow', '1beat', '2beat'
local ogGfPosition = {0, 0}
local canFloat = false
local floatTimer = 0
local gfFloatPos = {0, 0}

local vignette = {
	{name = 'RedVG', path = 'VG', centered = true, scaleX = 1, scaleY = 1, alpha = 0, camera = 'camOther', front = true}
}

local GeneralBG = {
	{name = 'sky',           path = 'yrc/vc',            x = -650,  y = -520,               scrollX = 1, scrollY = 1, lowQualityHide = true},
	{name = 'stars',         path = 'yrc/sky',           x = -650,  y = -520,               scrollX = 1, scrollY = 1, lowQualityHide = true},
	{name = 'backBackRocks', path = 'yrc/backBackRocks', x = -1050, y = -520,               scrollX = 1, scrollY = 1, lowQualityHide = true},
	{name = 'middleRocks',   path = 'yrc/middleRocks',   x = -1050, y = -520,               scrollX = 1,  scrollY = 1},
	{name = 'middleRocks2',  path = 'yrc/middleRocks',   x = -1450, y = -520,               scrollX = 1,  scrollY = 1},
}

local YCRBG = {
	{name = 'backRocks',  path = 'yrc/backRocks',   x = -1050, y = -520, scrollX = 1,   scrollY = 1},
	{name = 'floor',      path = 'yrc/floor',       x = -1050, y = -520, scrollX = 1,   scrollY = 1},
	{name = 'frontRocks', path = 'yrc/frontRocks',  x = -1050, y = -800, scrollX = 0.8, scrollY = 1, front = true},
}

local YCRPixelBG = {
	{name = 'pixelCave',       path = 'yrc/caverna',       x = 520, y = 50,   animated = true, animPrefix = 'caverna_gif', fps = 24, scaleX = 2, scaleY = 2, scrollX = 1,   scrollY = 1},
	{name = 'pixelCaveBG',     path = 'yrc/fondocaberna',  x = 0,   y = -260, scaleX = 2, scaleY = 2, scrollX = 0.9, scrollY = 0.9},
	{name = 'pixelFloorRight', path = 'yrc/piso2',         x = 790, y = 130,  scaleX = 2, scaleY = 2, scrollX = 1,   scrollY = 1},
	{name = 'pixelFloor',      path = 'yrc/piso',          x = 0,   y = 130,  animated = true, animPrefix = 'piso_gif', fps = 24, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1},
}

local YCRCrystalBG = {
	{name = 'backRocksCrystal',  path = 'yrc/backRocksCrystal',   x = -1050, y = -520, scrollX = 1,   scrollY = 1, lowQualityHide = true},
	{name = 'floorCrystal',      path = 'yrc/floorCrystal',       x = -1050, y = -520, scrollX = 1,   scrollY = 1},
	{name = 'frontRocksCrystal', path = 'yrc/frontRocksCrystal',  x = -1050, y = -800, scrollX = 1,   scrollY = 1,   front = true},
	{name = 'glow',              path = 'yrc/glow',               x = -700,  y =  500, scrollX = 1.2, scrollY = 1.2, scaleX = 2.5, scaleY = 1.5, front = true, lowQualityHide = true},
}


local function addSprite(def)
	if def.lowQualityHide and lowQuality then return end

	local startAlpha = def.alpha or 1

	if def.animated then
		makeAnimatedLuaSprite(def.name, def.path, def.x or 0, def.y or 0)
		addAnimationByPrefix(def.name, 'idle', def.animPrefix, def.fps or 24, true)
	else
		makeLuaSprite(def.name, def.path, def.x or 0, def.y or 0)
	end

	-- scale 
	scaleObject(def.name, def.scaleX or 1, def.scaleY or 1)
	setScrollFactor(def.name, def.scrollX or 1, def.scrollY or 1)
	setProperty(def.name .. '.antialiasing', false)
	setProperty(def.name .. '.alpha', startAlpha)

	if def.centered        then screenCenter(def.name) end

	if def.camera          then setObjectCamera(def.name, def.camera) end

	if def.behindbackRocks then setObjectOrder(def.name, getObjectOrder('backRocks')) end

	if def.behind then setObjectOrder(def.name, getObjectOrder(def.behind)) end

	addLuaSprite(def.name, def.front or false)
end

local function addSpriteGroup(group)
	for _, def in ipairs(group) do addSprite(def) end
end

local function destroyStage(group)
	for _, def in ipairs(group) do
		if not (def.lowQualityHide and lowQuality) then
			removeLuaSprite(def.name, true)
		end
	end
end

local function showStage(group)
	for _, def in ipairs(group) do
		if not (def.lowQualityHide and lowQuality) then
			setProperty(def.name..'.alpha', 1)
		end
	end
end

local function reloadAllNotes()
	for i = 0, 7 do callMethod('strumLineNotes.members[' .. i .. '].reloadNote', {''}) end
	for i = 0, getProperty('unspawnNotes.length') - 1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == '' then callMethod('unspawnNotes[' .. i .. '].reloadNote', {''}) end
	end
	for i = 0, getProperty('notes.length') - 1 do
		if getPropertyFromGroup('notes', i, 'noteType') == '' then callMethod('notes.members[' .. i .. '].reloadNote', {''}) end
	end
end

local function setVignette(mode)
	vignetteMode = mode or 'none'

	if mode == 'slow' then
		doTweenAlpha('VGAlphaLoop', 'RedVG', 1, 0.95)

	elseif mode == '1beat' or mode == '2beat' then
		cancelTween('VGAlphaLoop') cancelTween('VGAlphaLoop2')

	else
		vignetteMode = 'none'
		cancelTween('VGAlpha1Beat') cancelTween('VGAlpha2Beat')
		cancelTween('VGAlphaLoop')  cancelTween('VGAlphaLoop2')
		doTweenAlpha('VGAlphaOff', 'RedVG', 0, 0.7)
	end
end

function onCreate()
	--Precaching everything
	for _, def in ipairs(vignette)     do precacheImage(def.path) end
	for _, def in ipairs(GeneralBG)    do precacheImage(def.path) end
	for _, def in ipairs(YCRBG)        do precacheImage(def.path) end
	for _, def in ipairs(YCRPixelBG)   do precacheImage(def.path) end
	for _, def in ipairs(YCRCrystalBG) do precacheImage(def.path) end

	addCharacterToList("sonic.exe 2 p", 'dad')
	addCharacterToList("sonic.exe 2-grito", 'dad')
	addCharacterToList("bfpixel", 'bf')
	addCharacterToList("gf pixel yrc", 'gf')
end

function onCreatePost()
	setProperty('camHUD.alpha', 0)
    triggerEvent('Tweening Camera', '-500, 0', '0.001, linear')
    triggerEvent('Tween Camera Zoom', '1.4, true', '0.001, linear')

	ogGfPosition = {getProperty('gf.x'), getProperty('gf.y')}

	addSpriteGroup(vignette)
	setProperty('RedVG.color', getColorFromHex('FF0000'))
	addSpriteGroup(GeneralBG)
	addSpriteGroup(YCRBG)

	for _, def in ipairs(YCRPixelBG)   do def.alpha = 0 addSprite(def) end
	for _, def in ipairs(YCRCrystalBG) do def.alpha = 0 addSprite(def) end

	setScrollFactor('gfGroup', 1, 1)
end

function opponentNoteHit()
	if canShake then cameraShake('game', shakeIntensity, 0.05) end
end

function onBeatHit()
	if vignetteMode == '1beat' then
		setProperty('RedVG.alpha', 0.6)
		doTweenAlpha('VGAlpha1Beat', 'RedVG', 0, 0.6)

	elseif vignetteMode == '2beat' and curBeat % 2 == 0 then
		setProperty('RedVG.alpha', 0.6)
		doTweenAlpha('VGAlpha2Beat', 'RedVG', 0, 0.6)
	end
end

function onTweenCompleted(tag)
	if vignetteMode ~= 'slow' then return end

	if tag == 'VGAlphaLoop' then
		doTweenAlpha('VGAlphaLoop2', 'RedVG', 0, 0.95)
	elseif tag == 'VGAlphaLoop2' then
		doTweenAlpha('VGAlphaLoop', 'RedVG', 1, 1)
	end
end

function onUpdatePost(elapsed)
	if not canFloat or lowQuality then return end

	floatTimer = floatTimer + elapsed
	local sinVal = math.sin(floatTimer) * 10
	local cosVal = math.cos(floatTimer * 0.5) * 10

	setProperty('pixelFloorRight.y', 130 + sinVal)
	setProperty('gf.y', gfFloatPos[2] + sinVal)

	setProperty('pixelFloorRight.x', 790 + cosVal)
	setProperty('gf.x', gfFloatPos[1] + cosVal)

	if getPropertyFromClass('states.PlayState', 'stageUI') == 'pixel' then
		for i = 0,getProperty('notes.length')-1 do
			if getProperty('notes.members['..i..'].isSustainNote') then
				if not stringEndsWith(getProperty('notes.members['..i..'].animation.curAnim.name'), 'end') then
					scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x'), ((stepCrochet / 100 * 1.05) * 1.19) * 18.6)
				else
					scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x'), 6)
				end
				setProperty('notes.members['..i..'].offset.x', getProperty('notes.members['..i..'].offset.x') - 10)
				setProperty('notes.members['..i..'].offset.y', getProperty('notes.members['..i..'].offset.y') - 10)
			end
		end
	end
end

local savedScale = {1, 1}
local stageMode = {
	["PixelMode"] = function()
		destroyStage(YCRBG)

		showStage(YCRPixelBG)

		setVignette('none')
		shakeIntensity = 0.001

		setProperty('dad.x', getProperty('dad.x') - 210 - 133)
		setProperty('dad.y', getProperty('dad.y') - 395 - 57)
		setProperty('boyfriend.x', getProperty('boyfriend.x') - 780)
		setProperty('boyfriend.y', getProperty('boyfriend.y') - 420)
		setProperty('gf.x', getProperty('gf.x') - 105)
		setProperty('gf.y', getProperty('gf.y') - 280)

		triggerEvent('Set customCamera Position',     'bf', '900, 120')
		triggerEvent('Set customCamera Position',    'dad', '800, 120')
		triggerEvent('Set customCamera Position', 'middle', '850, 110')

		triggerEvent('Set customCamera Zoom',     'OGZoom', '2.2')
		triggerEvent('Set customCamera Zoom', 'MiddleZoom', '1.8')

		triggerEvent('Set Character Offset',  'bf', '5')
		triggerEvent('Set Character Offset', 'dad', '5')

		setProperty('gameplayCam.settings.OverrideZoom', false)

		gfFloatPos = {getProperty('gf.x'), getProperty('gf.y')}

		scaleObject('boyfriend', 2, 2)
		scaleObject('dad', 2, 2)
		scaleObject('gf', 2, 2)

		canFloat = true

		for i = 0,getProperty('notes.length')-1 do
			if getProperty('notes.members['..i..'].isSustainNote') then
				if not stringEndsWith(getProperty('notes.members['..i..'].animation.curAnim.name'), 'end') then
					savedScale[1] = getProperty('notes.members['..i..'].scale.y')
				else
					savedScale[2] = getProperty('notes.members['..i..'].scale.y')
				end
				setProperty('notes.members['..i..'].offset.x', getProperty('notes.members['..i..'].offset.x') + 10)
				setProperty('notes.members['..i..'].offset.y', getProperty('notes.members['..i..'].offset.y') + 10)
			end
		end

		setPropertyFromClass('states.PlayState', 'stageUI', 'pixel')
		reloadAllNotes()
	end,
	["CrystalMode"] = function()
		destroyStage(YCRPixelBG)

		showStage(YCRCrystalBG)

		canFloat = false
		shakeIntensity = 0.005

		setVignette('2beat')

		setProperty('gf.x', ogGfPosition[1])
		setProperty('gf.y', ogGfPosition[2])

		triggerEvent('Set customCamera Position',     'bf', '1200, 590')
		triggerEvent('Set customCamera Position',    'dad', '650, 590')
		triggerEvent('Set customCamera Position', 'middle', '930, 530')

		triggerEvent('Set customCamera Zoom',     'OGZoom',  '0.7')
		triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.65')

		triggerEvent('Set Character Offset',  'bf', '25')
		triggerEvent('Set Character Offset', 'dad', '25')

		setProperty('gameplayCam.settings.OverrideZoom', false)

		if not lowQuality then setProperty('glow.alpha', 0.5) end

		setPropertyFromClass('states.PlayState', 'stageUI', 'normal')
		reloadAllNotes()

		for i = 0,getProperty('notes.length')-1 do
			if getProperty('notes.members['..i..'].isSustainNote') then
				if not stringEndsWith(getProperty('notes.members['..i..'].animation.curAnim.name'), 'end') then
					scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x'), savedScale[1])
				else
					scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x'), savedScale[2])
				end
				setProperty('notes.members['..i..'].offset.x', getProperty('notes.members['..i..'].offset.x') + 10)
				setProperty('notes.members['..i..'].offset.y', getProperty('notes.members['..i..'].offset.y') + 10)
			end
		end
	end
}

function onEvent(n, v1, v2)
	if n == 'ycrEvents' then
		local split = stringSplit(v2, ', ')
		if v1 == 'tweenObjectAlpha' then cancelTween(split[1]..'OP') doTweenAlpha(split[1]..'OP', split[1], split[2], split[3]) end
		if v1 == 'stageMode'        then stageMode[split[1]]() end
		if v1 == 'vignetteMode'     then setVignette(split[1]) end
	end
end
