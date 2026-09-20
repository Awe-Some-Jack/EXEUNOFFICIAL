local staticSprites = {
	{name = 'bgf',  path = 'bg/bg-f', scale = 2.5},
	{name = 'bgg',  path = 'bg/bg-g', scale = 2.5},
}

local animatedSprites = {
	{name = 'anto',  path = 'bg/anto',   x = 1280, y = -410, prefix = 'Símbolo 9',  fps = 24, scale = 2, angle = -1.5},
	{name = 'lava',  path = 'bg/lava',   x = -250,   y = 0,    prefix = 'Símbolo 17', fps = 24, scale = 2.5, angle = -12},
}

local altAnimatedSprites = {
	{name = 'antoos',  path = 'bg/antorcha', x = 801,  y = 312, prefix = 'Símbolo 3', fps = 24,scale = 2, angle = -1, flipX = false},
}

local staticOffsetY = {bgf = -350, bgg = -350}

local function addStatic(def)
	makeLuaSprite(def.name, def.path)
	addLuaSprite(def.name)
	scaleObject(def.name, def.scale, def.scale)
	if staticOffsetY[def.name] then
		setProperty(def.name .. '.y', staticOffsetY[def.name])
	end
end

local function addAnimated(def, visible)
	makeAnimatedLuaSprite(def.name, def.path, def.x or 0, def.y or 0)
	addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps, true)
	scaleObject(def.name, def.scale, def.scale)
	if visible == false then setProperty(def.name .. '.visible', false) end
	if def.flipX then setProperty(def.name .. '.flipX', true) end
	if def.angle then setProperty(def.name .. '.angle', def.angle) end
	addLuaSprite(def.name)
end

function onCreatePost()
	triggerEvent('Tween Camera Zoom', '1.4, true', '0.001') triggerEvent('Tweening Camera', '90, -90', '0.001, linear')
	addStatic(staticSprites[1])

	if not lowQuality then
		addAnimated(animatedSprites[1])
	end

	addStatic(staticSprites[2])

	if not lowQuality then
		addAnimated(animatedSprites[2])
	end

	makeLuaSprite('bgf2', 'bg/bg-2')
	addLuaSprite('bgf2')
	scaleObject('bgf2', 2.5 / 3, 2.5 / 3)
	setProperty('bgf2.visible', false)

	if not lowQuality then
		for _, spr in ipairs(altAnimatedSprites) do
			addAnimated(spr, false)
		end
	end

	setProperty('gf.flipX', false)
	setScrollFactor('gf', 1, 1)
	setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup') + 1)

	makeLuaSprite('blackbg')
	makeGraphic('blackbg', 3500, 1800, '000000')
	setProperty('blackbg.alpha', 0)
	addLuaSprite('blackbg')

	addCharacterToList('requital', 'dad')
	addCharacterToList('requitalos', 'dad')
	addCharacterToList('bf-reqos', 'bf')
	addCharacterToList('pico-reqos', 'gf')
end

local _cbg = 'n'
local separation = 50
local function switchToAlt()
	_cbg = 'o'
	setProperty('bgf.visible', false)
	setProperty('bgf2.visible', true)
	setProperty('antoos.visible', true)
	setProperty('anto2os.visible', true)
	cameraFlash('game', 'FFFFFF', 1, true)
	setProperty('BlackGraphicGame.alpha', 1)
	setProperty('BlackGraphicOther.alpha', 1)
	runTimer('fadeBlackGraphic', crochet / (1000 / 4) / playbackRate)
	triggerEvent('Change Character', 'dad', 'requitalos')
	triggerEvent('Change Character', 'bf', 'bf-reqos')
	triggerEvent('Change Character', 'gf', 'pico-reqos')
	setProperty('gf.flipX', false)
	setScrollFactor('gf', 1, 1)
	callMethod('boyfriend.setPosition', {400, 1400})
	callMethod('dad.setPosition', {1540, 930})
	callMethod('gf.setPosition', {2200, 1350})

	if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then
		for i = 0,3 do
			setProperty('opponentStrums.members['..i..'].x', -1000)
			setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
		end
	end
end

local function switchToNormal()
	_cbg = 'n'
	setProperty('bgf.visible', true)
	setProperty('bgf2.visible', false)
	setProperty('antoos.visible', false)
	setProperty('anto2os.visible', false)
	cameraFlash('other', 'FFFFFF', 3, true)
	triggerEvent('Change Character', 'dad', 'requital')
	triggerEvent('Change Character', 'bf', 'bf-req')
	triggerEvent('Change Character', 'gf', 'pico-req')
	setProperty('gf.flipX', false)
	setScrollFactor('gf', 1, 1)

	callMethod('boyfriend.setPosition', {712, 800})
	callMethod('dad.setPosition', {1960, 386})
	callMethod('gf.setPosition', {1010, 895})

	doTweenX('boyfriendX', 'boyfriend', 612, 1, 'cubeOut')
	doTweenY('boyfriendY', 'boyfriend', 900, 1, 'cubeOut')
	doTweenX('dadX', 'dad', 2060, 1, 'cubeOut')
	doTweenY('dadY', 'dad', 286, 1, 'cubeOut')
	doTweenX('gfX', 'gf', 910, 1, 'cubeOut')
	doTweenY('gfY', 'gf', 995, 1, 'cubeOut')

	if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then
		for i = 0, 3 do
			setProperty('playerStrums.members['..i..'].x', _G['defaultOpponentStrumX'..i])
			setProperty('opponentStrums.members['..i..'].x', _G['defaultPlayerStrumX'..i])
		end
    end
end

local function startTransition()
	local dur = crochet / (1000 / 6) / playbackRate
	doTweenAlpha('blackbgFade', 'blackbg', 0.9, dur)
	doTweenAlpha('camHUDFade', 'camHUD', 0, dur)
	doTweenAlpha('gfFade', 'gf', 0, dur)
	doTweenAlpha('bfFade', 'boyfriend', 0, dur)
end

function onEvent(n, v1)
	if n ~= 'BGchange' then return end

	if v1 == 'blackout' then
		switchToAlt()
	elseif v1 == 'blackin' then
		switchToNormal()
	elseif v1 == 'starttrans' then
		startTransition()
	elseif v1 == 'camerablack' then
		setProperty('camGame.alpha', 0)
		setProperty('camOther.alpha', 0)
	end
end

function onTimerCompleted(t)
	if t == 'fadeBlackGraphic' then
		doTweenAlpha('BlackGraphicGame', 'BlackGraphicGame', 0, 3)
		doTweenAlpha('BlackGraphicOther', 'BlackGraphicOther', 0, 3)
	end
end

local oldMHS = false
function onSectionHit()
	if oldMHS ~= mustHitSection and _cbg == 'o' then
		setProperty('gameplayCam.settings.OverrideZoom', false)
		if mustHitSection then
			setProperty('gameplayCam.settings.MiddleZoom', 0.5)
		else
			setProperty('gameplayCam.settings.MiddleZoom', 1)
		end
	end
	oldMHS = mustHitSection
end

function onUpdatePost()
	if _cbg ~= 'o' then return end
	scaleObject('boyfriend', getProperty('camGame.zoom') + 1, getProperty('camGame.zoom') + 1, false)
	scaleObject('gf', getProperty('camGame.zoom') + 1, getProperty('camGame.zoom') + 1, false)
end