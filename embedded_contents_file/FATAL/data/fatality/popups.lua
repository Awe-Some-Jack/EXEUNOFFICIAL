local config = {
	maxPopups = 16,
	minScale = 1,
	maxScale = 1.5,
	enabledPopups = {1}
}

local popupSettings = {
	{
		buttonType = 'close',
		width = 200,
		height = 100,
		offsetX = 38,
		offsetY = 46,
		buttonOffset = 10
	},
	{
		buttonType = 'close',
		width = 150,
		height = 100,
		offsetX = 16,
		offsetY = 14,
		buttonOffset = 10
	},
	{
		buttonType = 'close',
		width = 200,
		height = 100,
		offsetX = 50,
		offsetY = 50,
		buttonOffset = 10,
		separation = 15
	},
	{
		buttonType = 'ok',
		width = 100,
		height = 100,
		offsetX = 27,
		offsetY = 9,
		buttonOffset = 10
	},
	{
		buttonType = 'leaveme',
		width = 200,
		height = 100,
		offsetX = 23,
		offsetY = 33,
		buttonOffset = 10
	},
	{
		buttonType = 'yes',
		buttonTypeSecond = 'no',
		width = 200,
		height = 100,
		offsetX = 43,
		offsetY = 16,
		buttonOffset = 10,
		separation = 30
	},
	{
		buttonType = 'ok',
		width = 150,
		height = 100,
		offsetX = 28,
		offsetY = 32,
		buttonOffset = 10
	},
	{
		buttonType = 'close',
		width = 150,
		height = 150,
		offsetX = 38,
		offsetY = 33,
		buttonOffset = 10,
		time = 2.5
	},
	{
		buttonType = 'ok',
		width = 100,
		height = 100,
		offsetX = 33,
		offsetY = 24,
		buttonOffset = 4
	}
}

local popups = {}
local daPopup = 0
local destroyPopups = {}
local waitTimers = {}
local playerClosedPopup = false
local pendingHitbox = {}
local hitboxReady = {}

local mobileOnly = (buildTarget == 'ios' or buildTarget == 'android')
local popupScale = 0.85

local corruptionBarImage = 'fatality/healthbar/corruption_bar'
local corruptionFillImage = 'fatality/healthbar/corruption_fill'
local corruptionBarWidth = 824
local corruptionBarHeight = 58
local corruptionFillX = 18
local corruptionFillY = 14
local corruptionFillWidth = 788
local corruptionFillHeight = 30
local corruptionSquares = 22
local corruptionDanger = 15
local corruptionMargin = 22
local corruptionScale = 0.6
local corruptionLastSquares = -1
local corruptionFlashTime = 0
local corruptionActive = false
local corruptionBuilt = false
local commonPopup = 1
local otherPopupWeight = 3

local function pickPopupVariant()
	local total = 0
	for i = 1, #config.enabledPopups do
		total = total + (config.enabledPopups[i] == commonPopup and 1 or otherPopupWeight)
	end
	local roll = getRandomFloat(0, total)
	for i = 1, #config.enabledPopups do
		roll = roll - (config.enabledPopups[i] == commonPopup and 1 or otherPopupWeight)
		if roll <= 0 then return config.enabledPopups[i] end
	end
	return config.enabledPopups[#config.enabledPopups]
end

local function setCorruptionSquares(squares)
	local clipWidth = math.floor(squares * corruptionFillWidth / corruptionSquares + 0.5)
	runHaxeCode([[
		import flixel.math.FlxRect;
		var fill = game.getLuaObject('fatalCorruptionFill');
		if (fill != null) fill.clipRect = new FlxRect(0, 0, ]]..clipWidth..[[, ]]..corruptionFillHeight..[[);
	]])
end

local function buildCorruptionBar()
	local barX = (screenWidth - corruptionBarWidth * corruptionScale) / 2
	local barY = screenHeight - corruptionBarHeight * corruptionScale - corruptionMargin

	makeLuaSprite('fatalCorruptionBar', corruptionBarImage, barX, barY)
	setObjectCamera('fatalCorruptionBar', 'barCam')
	setProperty('fatalCorruptionBar.antialiasing', false)
	scaleObject('fatalCorruptionBar', corruptionScale, corruptionScale)
	setProperty('fatalCorruptionBar.x', barX)
	setProperty('fatalCorruptionBar.y', screenHeight)
	doTweenY('fatalCorruptionBarSlide', 'fatalCorruptionBar', barY, 0.6, 'quadOut')
	addLuaSprite('fatalCorruptionBar', true)

	makeLuaSprite('fatalCorruptionFill', corruptionFillImage, barX + corruptionFillX * corruptionScale, barY + corruptionFillY * corruptionScale)
	setObjectCamera('fatalCorruptionFill', 'barCam')
	setProperty('fatalCorruptionFill.antialiasing', false)
	scaleObject('fatalCorruptionFill', corruptionScale, corruptionScale)
	setProperty('fatalCorruptionFill.x', barX + corruptionFillX * corruptionScale)
	setProperty('fatalCorruptionFill.y', screenHeight + corruptionFillY * corruptionScale)
	doTweenY('fatalCorruptionFillSlide', 'fatalCorruptionFill', barY + corruptionFillY * corruptionScale, 0.6, 'quadOut')
	addLuaSprite('fatalCorruptionFill', true)

	corruptionActive = true
	corruptionBuilt = true
	corruptionLastSquares = -1
	setCorruptionSquares(0)
end

local function hideCorruptionBar()
	corruptionActive = false
	setProperty('fatalCorruptionBar.visible', false)
	setProperty('fatalCorruptionFill.visible', false)
end

local function updateCorruptionBar(elapsed)
	if not corruptionActive then return end
	local count = #popups
	local squares = math.min(math.floor(count * corruptionSquares / corruptionDanger), corruptionSquares)
	if squares ~= corruptionLastSquares then
		corruptionLastSquares = squares
		setCorruptionSquares(squares)
	end

	if count >= corruptionDanger then
		corruptionFlashTime = corruptionFlashTime + elapsed
		setProperty('fatalCorruptionFill.visible', math.floor(corruptionFlashTime / 0.2) % 2 == 0)
	else
		corruptionFlashTime = 0
		setProperty('fatalCorruptionFill.visible', true)
	end
end

function onCreatePost()
	if not mobileOnly then return end
	makeLuaSprite('cursor', 'fatality/newPopups/fatal_mouse_cursor')
	callMethodFromClass('flixel.FlxG', 'mouse.load', {instanceArg('cursor.pixels'), 1.2})
end

function onDestroy()
	if not mobileOnly then return end
	callMethodFromClass('flixel.FlxG', 'mouse.unload')
end

function onEvent(n,v1)
	if not mobileOnly then return end
	if n == 'PopProgram' then n = 'Fatal Popup' end
	if n == 'FatalityFlashin' and v1 == 'flash' and not corruptionActive and not corruptionBuilt then buildCorruptionBar() end
	if n == 'Fatal Window Roam' and stringTrim(string.lower(v1 or '')) == '' then hideCorruptionBar() end
	if n == 'Clear Fatal Popups' then
		for i = #popups, 1, -1 do
			if luaSpriteExists('button'..popups[i]) then removeLuaSprite('button'..popups[i], true) end
			if luaSpriteExists('button'..popups[i]..'second') then removeLuaSprite('button'..popups[i]..'second', true) end
			if luaSpriteExists('button'..popups[i]..'blocked1') then removeLuaSprite('button'..popups[i]..'blocked1', true) end
			if luaSpriteExists('button'..popups[i]..'blocked2') then removeLuaSprite('button'..popups[i]..'blocked2', true) end
			if luaSpriteExists('button'..popups[i]..'blocked3') then removeLuaSprite('button'..popups[i]..'blocked3', true) end
			if luaSpriteExists('button-alt'..popups[i]) then removeLuaSprite('button-alt'..popups[i], true) end
			if luaSpriteExists('buttonwait'..popups[i]) then removeLuaSprite('buttonwait'..popups[i], true) end
			if luaSpriteExists('waitBar'..popups[i]) then removeLuaSprite('waitBar'..popups[i], true) end
			destroyPopup(popups[i])
		end
		popups = {}
	end

	if n == 'Set Fatal Popups' then
		local daPopups = stringSplit(v1, ',')
		config.enabledPopups = {} 
		for i = 1, #daPopups do table.insert(config.enabledPopups, tonumber(daPopups[i])) end
	end

	if n == 'Fatal Popup' then
		if #popups >= config.maxPopups and v1 ~= 'flood' then
			local oldestPopup = table.remove(popups, 1)
			if luaSpriteExists('button'..oldestPopup) then removeLuaSprite('button'..oldestPopup, true) end
			if luaSpriteExists('button'..oldestPopup..'second') then removeLuaSprite('button'..oldestPopup..'second', true) end
			if luaSpriteExists('button'..oldestPopup..'blocked1') then removeLuaSprite('button'..oldestPopup..'blocked1', true) end
			if luaSpriteExists('button'..oldestPopup..'blocked2') then removeLuaSprite('button'..oldestPopup..'blocked2', true) end
			if luaSpriteExists('button'..oldestPopup..'blocked3') then removeLuaSprite('button'..oldestPopup..'blocked3', true) end
			if luaSpriteExists('button-alt'..oldestPopup) then removeLuaSprite('button-alt'..oldestPopup, true) end
			if luaSpriteExists('buttonwait'..oldestPopup) then removeLuaSprite('buttonwait'..oldestPopup, true) end
			if luaSpriteExists('waitBar'..oldestPopup) then removeLuaSprite('waitBar'..oldestPopup, true) end
			destroyPopup(oldestPopup)
		end

		local tumbalacasa = getRandomBool(0.4)
		daPopup = daPopup + 1
		local popupIndex = (tumbalacasa and 9 or pickPopupVariant())
		local randomScale = getRandomFloat(config.minScale, config.maxScale) * popupScale

		makeAnimatedLuaSprite('popup'..daPopup, 'fatality/newPopups/popup-variant-'..popupIndex)
		addAnimationByPrefix('popup'..daPopup, 'intro', 'intro', 12, false)
		addAnimationByPrefix('popup'..daPopup, 'end', 'end', 12, false)
		playAnim('popup'..daPopup, 'intro', true)
		setObjectCamera('popup'..daPopup, 'popupCam')
		setProperty('popup'..daPopup..'.antialiasing', false)
		scaleObject('popup'..daPopup, randomScale, randomScale)
		callMethod('popup'..daPopup..'.setPosition', {
			getRandomInt(0, screenWidth - getProperty('popup'..daPopup..'.width')),
			getRandomInt(0, screenHeight - getProperty('popup'..daPopup..'.height'))
		})
		addLuaSprite('popup'..daPopup, true)

		stopSound('tumbalacasamami')
		if popupIndex == 9 then playSound('tumbalacasamami', 0.5, 'tumbalacasamami') end

		--update hitbox
		setProperty('popup'..daPopup..'.width', math.floor(popupSettings[popupIndex].width * randomScale))
		setProperty('popup'..daPopup..'.height', math.floor(popupSettings[popupIndex].height * randomScale))
		setProperty('popup'..daPopup..'.offset.x', getProperty('popup'..daPopup..'.offset.x') + math.floor(popupSettings[popupIndex].offsetX * randomScale))
		setProperty('popup'..daPopup..'.offset.y', getProperty('popup'..daPopup..'.offset.y') + math.floor(popupSettings[popupIndex].offsetY * randomScale))

		--making button
		if popupIndex == 3 then
			local randomUnblocked = getRandomInt(1,3)
			for i = 1,3 do
				local t = (i == randomUnblocked and '' or ('blocked'..i))

				makeAnimatedLuaSprite('button'..daPopup..t, 'fatality/newPopups/buttons/'..popupSettings[popupIndex].buttonType..(stringStartsWith(t, 'blocked') and 'Disabled' or '')..'Button')
				addAnimationByPrefix('button'..daPopup..t, 'idle', popupSettings[popupIndex].buttonType..(stringStartsWith(t, 'blocked') and 'Disabled' or '')..'Button idle', 0, false)
				setObjectCamera('button'..daPopup..t, 'popupCam')
				setProperty('button'..daPopup..t..'.antialiasing', false)
				scaleObject('button'..daPopup..t, randomScale, randomScale)
				callMethod('button'..daPopup..t..'.setPosition', {
					getProperty('popup'..daPopup..'.x') + (getProperty('popup'..daPopup..'.width') / 2) - ((getProperty('button'..daPopup..t..'.width') * 3 + popupSettings[popupIndex].separation) / 2) + ((getProperty('button'..daPopup..t..'.width') + popupSettings[popupIndex].separation) * (i - 1)),
					getProperty('popup'..daPopup..'.y') + getProperty('popup'..daPopup..'.height') - getProperty('button'..daPopup..t..'.height') - (10 * randomScale)
				})
				addLuaSprite('button'..daPopup..t, true)
			end
		elseif popupIndex == 6 then
			for i = 1,2 do
				local t = (i == 1 and '' or 'second')
				makeAnimatedLuaSprite('button'..daPopup..t, 'fatality/newPopups/buttons/'..(i == 1 and popupSettings[popupIndex].buttonType or popupSettings[popupIndex].buttonTypeSecond)..'Button')
				addAnimationByPrefix('button'..daPopup..t, 'idle', (i == 1 and popupSettings[popupIndex].buttonType or popupSettings[popupIndex].buttonTypeSecond)..'Button idle', 0, false)
				setObjectCamera('button'..daPopup..t, 'popupCam')
				setProperty('button'..daPopup..t..'.antialiasing', false)
				scaleObject('button'..daPopup..t, randomScale, randomScale)
				callMethod('button'..daPopup..t..'.setPosition', {
					getProperty('popup'..daPopup..'.x') + (getProperty('popup'..daPopup..'.width') / 2) - ((getProperty('button'..daPopup..t..'.width') * 2 + popupSettings[popupIndex].separation) / 2) + ((getProperty('button'..daPopup..t..'.width') + popupSettings[popupIndex].separation) * (i - 1)),
					getProperty('popup'..daPopup..'.y') + getProperty('popup'..daPopup..'.height') - getProperty('button'..daPopup..t..'.height') - (10 * randomScale)
				})
				addLuaSprite('button'..daPopup..t, true)
			end
		elseif popupIndex == 8 then
			makeAnimatedLuaSprite('buttonwait'..daPopup, 'fatality/newPopups/buttons/'..popupSettings[popupIndex].buttonType..'DisabledButton')
			addAnimationByPrefix('buttonwait'..daPopup, 'idle', popupSettings[popupIndex].buttonType..'DisabledButton idle', 0, false)
			setObjectCamera('buttonwait'..daPopup, 'popupCam')
			setProperty('buttonwait'..daPopup..'.antialiasing', false)
			scaleObject('buttonwait'..daPopup, randomScale, randomScale)
			callMethod('buttonwait'..daPopup..'.setPosition', {
				getProperty('popup'..daPopup..'.x') + (getProperty('popup'..daPopup..'.width') - getProperty('buttonwait'..daPopup..'.width')) / 2,
				getProperty('popup'..daPopup..'.y') + getProperty('popup'..daPopup..'.height') - getProperty('buttonwait'..daPopup..'.height') - (10 * randomScale)
			})
			addLuaSprite('buttonwait'..daPopup, true)

			makeLuaSprite('waitBar'..daPopup)
			makeGraphic('waitBar'..daPopup, 108 * randomScale, 13 * randomScale, '000099')
			setObjectCamera('waitBar'..daPopup, 'popupCam')
			callMethod('waitBar'..daPopup..'.setPosition', {
				getProperty('popup'..daPopup..'.x') + (22 * randomScale),
				getProperty('popup'..daPopup..'.y') + (89 * randomScale)
			})
			addLuaSprite('waitBar'..daPopup, true)

			waitTimers[daPopup] = {
				time = 0,
				done = false,
				scale = randomScale
			}
		else
			makeAnimatedLuaSprite('button'..daPopup, 'fatality/newPopups/buttons/'..popupSettings[popupIndex].buttonType..'Button')
			addAnimationByPrefix('button'..daPopup, 'idle', popupSettings[popupIndex].buttonType..'Button idle', 0, false)
			setObjectCamera('button'..daPopup, 'popupCam')
			setProperty('button'..daPopup..'.antialiasing', false)
			scaleObject('button'..daPopup, randomScale, randomScale)
			callMethod('button'..daPopup..'.setPosition', {
				getProperty('popup'..daPopup..'.x') + (getProperty('popup'..daPopup..'.width') - getProperty('button'..daPopup..'.width')) / 2,
				getProperty('popup'..daPopup..'.y') + getProperty('popup'..daPopup..'.height') - getProperty('button'..daPopup..'.height') - (popupSettings[popupIndex].buttonOffset * randomScale)
			})
			addLuaSprite('button'..daPopup, true)
		end

		if not (popupIndex == 3 or popupIndex == 8) then
			makeAnimatedLuaSprite('button-alt'..daPopup, 'fatality/newPopups/buttons/XButton')
			addAnimationByPrefix('button-alt'..daPopup, 'idle', 'XButton idle', 0, false)
			setObjectCamera('button-alt'..daPopup, 'popupCam')
			setProperty('button-alt'..daPopup..'.antialiasing', false)
			scaleObject('button-alt'..daPopup, randomScale, randomScale)
			callMethod('button-alt'..daPopup..'.setPosition', {
				getProperty('popup'..daPopup..'.x') + getProperty('popup'..daPopup..'.width') - getProperty('button-alt'..daPopup..'.width') - (4 * randomScale),
				getProperty('popup'..daPopup..'.y') + (6 * randomScale)
			})
			addLuaSprite('button-alt'..daPopup, true)
		end

		pendingHitbox[daPopup] = true
		table.insert(popups, daPopup)
	end
end

function destroyPopup(popup)
	playAnim('popup'..popup, 'end', true)
	table.insert(destroyPopups, popup)
end

local function mouseOverlaps(obj)
	return callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(obj), instanceArg('popupCam')})
end

local savedPopup = false
local activePopup = nil
local function fitHitboxToPopup(popup)
	local tag = 'popup'..popup
	local scale = getProperty(tag..'.scale.x')
	local frameW = getProperty(tag..'.frameWidth')
	local frameH = getProperty(tag..'.frameHeight')
	local centerX = getProperty(tag..'.x') - getProperty(tag..'.offset.x') + getProperty(tag..'.origin.x')
	local centerY = getProperty(tag..'.y') - getProperty(tag..'.offset.y') + getProperty(tag..'.origin.y')
	setProperty(tag..'.x', centerX - frameW * scale / 2)
	setProperty(tag..'.y', centerY - frameH * scale / 2)
	callMethod(tag..'.updateHitbox')
end

function onUpdatePost(e)
	if not mobileOnly then return end
	setVar('luaPopupCount', #popups)
	updateCorruptionBar(e)
	for popup, _ in pairs(pendingHitbox) do
		if not luaSpriteExists('popup'..popup) then
			pendingHitbox[popup] = nil
		elseif getProperty('popup'..popup..'.animation.curAnim.name') == 'intro' and getProperty('popup'..popup..'.animation.curAnim.finished') then
			fitHitboxToPopup(popup)
			pendingHitbox[popup] = nil
			hitboxReady[popup] = true
		end
	end

	setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)

	for popup, data in pairs(waitTimers) do
		if not data.done then
			data.time = data.time + e
			local progress = math.min(data.time / popupSettings[8].time, 1)

			setGraphicSize('waitBar'..popup, lerp(1, 108 * data.scale, progress), 13 * data.scale)

			if progress >= 1 then
				data.done = true
				makeAnimatedLuaSprite('button'..popup, 'fatality/newPopups/buttons/closeButton')
				addAnimationByPrefix('button'..popup, 'idle', 'closeButton idle', 0, false)
				setObjectCamera('button'..popup, 'popupCam')
				setProperty('button'..popup..'.antialiasing', false)
				scaleObject('button'..popup, data.scale, data.scale)
				callMethod('button'..popup..'.setPosition', {
					getProperty('popup'..popup..'.x') + (getProperty('popup'..popup..'.width') - getProperty('button'..popup..'.width')) / 2,
					getProperty('popup'..popup..'.y') + getProperty('popup'..popup..'.height') - getProperty('button'..popup..'.height') - (10 * data.scale)
				})
				addLuaSprite('button'..popup, true)
				setObjectOrder('button'..popup, getObjectOrder('buttonwait'..popup))
				if luaSpriteExists('buttonwait'..popup) then removeLuaSprite('buttonwait'..popup, true) end
			end
		end
	end

	for i = #destroyPopups, 1, -1 do
		local popup = destroyPopups[i]
		if getProperty('popup'..popup..'.animation.curAnim.name') == 'end' and getProperty('popup'..popup..'.animation.curAnim.finished') then
			removeLuaSprite('popup'..popup, true)
			table.remove(destroyPopups, i)
		end
	end

	for i = #popups, 1, -1 do
		local popup = popups[i]
		if hitboxReady[popup] and mouseOverlaps('popup'..popup) then
			local waiting = waitTimers[popup] ~= nil and not waitTimers[popup].done
			if not waiting then
				local overNormal = false
				local overSecond = false
				local overAlt = false
				if mousePressed() then
					overNormal = mouseOverlaps('button'..popup)
					if luaSpriteExists('button-alt'..popup) then overAlt = mouseOverlaps('button-alt'..popup) end
					if luaSpriteExists('button'..popup..'second') then overSecond = mouseOverlaps('button'..popup..'second') end
					activePopup = popup
					canRemove = true
				end
				if luaSpriteExists('button'..popup) then setProperty('button'..popup..'.animation.curAnim.curFrame', overNormal and 1 or 0) end
				if luaSpriteExists('button-alt'..popup) then setProperty('button-alt'..popup..'.animation.curAnim.curFrame', overAlt and 1 or 0) end
				if luaSpriteExists('button'..popup..'second') then setProperty('button'..popup..'second.animation.curAnim.curFrame', overSecond and 1 or 0) end

				if mouseReleased() then
					if luaSpriteExists('button'..popup) then removeLuaSprite('button'..popup, true) end
					if luaSpriteExists('button'..popup..'second') then removeLuaSprite('button'..popup..'second', true) end
					if luaSpriteExists('button'..popup..'blocked1') then removeLuaSprite('button'..popup..'blocked1', true) end
					if luaSpriteExists('button'..popup..'blocked2') then removeLuaSprite('button'..popup..'blocked2', true) end
					if luaSpriteExists('button'..popup..'blocked3') then removeLuaSprite('button'..popup..'blocked3', true) end
					if luaSpriteExists('button-alt'..popup) then removeLuaSprite('button-alt'..popup, true) end
					if luaSpriteExists('buttonwait'..popup) then removeLuaSprite('buttonwait'..popup, true) end
					if luaSpriteExists('waitBar'..popup) then removeLuaSprite('waitBar'..popup, true) end
					destroyPopup(popup)
					table.remove(popups, i)
					waitTimers[popup] = nil
					activePopup = nil
					canRemove = false
					playerClosedPopup = true

					break
				end
			end
			break
		end

		if mouseReleased() and canRemove then
			if luaSpriteExists('button'..activePopup) then removeLuaSprite('button'..activePopup, true) end
			if luaSpriteExists('button'..activePopup..'second') then removeLuaSprite('button'..activePopup..'second', true) end
			if luaSpriteExists('button'..activePopup..'blocked1') then removeLuaSprite('button'..activePopup..'blocked1', true) end
			if luaSpriteExists('button'..activePopup..'blocked2') then removeLuaSprite('button'..activePopup..'blocked2', true) end
			if luaSpriteExists('button'..activePopup..'blocked3') then removeLuaSprite('button'..activePopup..'blocked3', true) end
			if luaSpriteExists('button-alt'..activePopup) then removeLuaSprite('button-alt'..activePopup, true) end
			if luaSpriteExists('buttonwait'..activePopup) then removeLuaSprite('buttonwait'..activePopup, true) end
			if luaSpriteExists('waitBar'..activePopup) then removeLuaSprite('waitBar'..activePopup, true) end
			destroyPopup(activePopup)
			for i = #popups, 1, -1 do
				if popups[i] == activePopup then
					table.remove(popups, i)
					break
				end
			end
			waitTimers[activePopup] = nil
			canRemove = false
			activePopup = nil
			playerClosedPopup = true
		end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function round(number, min, max)
	return math.max(min, math.min(max, number))
end