local ringKeybind = 'SPACE' --change this if you want to have a custom keybind
local botplayRingIgnore = false --if true and botplay is enabled it will ignore each ring


--dont really touch from here


local rings = 0
local resetAnim = 0
local hasBeenPressed = false --why is keyboardReleased so evil...
local ringEnabled = true
function onCreatePost()
	makeLuaSprite('ringCounter', 'Counter')
	setObjectCamera('ringCounter', 'hud')
	scaleObject('ringCounter', 0.67, 0.67)
	addLuaSprite('ringCounter', true)
	callMethod('ringCounter.setPosition', {screenWidth - getProperty('ringCounter.width') - 40, (downscroll and 10 or (screenHeight - getProperty('ringCounter.height') - 10))})

	makeLuaText('ringTxt', tostring(rings))
	setTextSize('ringTxt', 60)
	setTextColor('ringTxt', 'FDC93A')
	setTextBorder('ringTxt', 3, '862800')
	setTextFont('ringTxt', 'EurostileTBla.ttf')
	setProperty('ringTxt.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing'))
	setObjectCamera('ringTxt', 'hud')
	addLuaText('ringTxt')
	callMethod('ringTxt.setPosition', {getProperty('ringCounter.x') + 76, getProperty('ringCounter.y') - 6})

	setProperty('ringCounter.alpha', 0)
	setProperty('ringTxt.alpha', 0)
end

function onCountdownStarted()
	makeAnimatedLuaSprite('strumLineRing', 'noteSkins/ring', 0, defaultPlayerStrumY2)
	setObjectCamera('strumLineRing', 'hud')
	scaleObject('strumLineRing', 0.7, 0.7)
	addLuaSprite('strumLineRing', false)
	setProperty('strumLineRing.x', (screenWidth - getProperty('strumLineRing.width')) / 2)
	addToGroup('strumLineNotes', 'strumLineRing', 6)

	addAnimationByPrefix('strumLineRing', 'pressed', 'note circle', 24, false)
	addAnimationByPrefix('strumLineRing', 'confirm', 'ring confirm', 18, false)
	addAnimationByPrefix('strumLineRing', 'static', 'arrowRING', 24, false)
	ringAnim('static')

	setProperty('strumLineRing.alpha', 0)
end

local penaltyStart = false
local targetHealth = 0
function onUpdatePost(e)
	if inGameOver then return end
	if penaltyStart then
		setHealth(lerp(2, 0 + targetHealth, (getSongPosition() - 185142) / (239892 - 185142)))
	end

	if not ringEnabled then return end
	for i = 0, getProperty('notes.length')-1 do
		if getProperty('notes.members['..i..'].noteType') == 'Ring Note' then
			setProperty('notes.members['..i..'].x', getProperty('strumLineRing.x'))

			--RING HIT
			if getProperty('notes.members['..i..'].strumTime') - getPropertyFromClass('backend.Conductor', 'safeZoneOffset') * (getProperty('cpuControlled') and 0 or 0.7) <= getSongPosition()
			and getProperty('notes.members['..i..'].active') then
				if keyboardJustPressed(ringKeybind) or (getProperty('cpuControlled') and not botplayRingIgnore) then
					ringAnim('confirm', (getProperty('cpuControlled') == false and 0 or (stepCrochet * 1.25 / 1000 / playbackRate)))
					ringHit(i)
					hasBeenPressed = true
				end
			end

			--RING MISS
			local noteKillOffset = math.max(stepCrochet, 350 / getProperty('songSpeed') * playbackRate) - 5
			if (getSongPosition() - getProperty('notes.members['..i..'].strumTime')) > noteKillOffset then
				setProperty('notes.members['..i..'].active', false)
				removeFromGroup('notes', i, false)
				setProperty('notes.members['..i..'].tooLate', true)
			end
		end
	end

	if not getProperty('cpuControlled') then
		if keyboardJustPressed(ringKeybind) and getProperty('strumLineRing.animation.curAnim.name') ~= 'confirm' then
			ringAnim('pressed')
			hasBeenPressed = true
		end

		--[[if keyboardReleased(ringKeybind) then
			ringAnim('static')
			debugPrint('huh')
		end]]

		if not keyboardPressed(ringKeybind) and hasBeenPressed then
			ringAnim('static')
			hasBeenPressed = false
		end
	end

	if resetAnim > 0 then
		resetAnim = resetAnim - e
		if resetAnim <= 0 then
			ringAnim('static')
			resetAnim = 0
		end
	end
end

--Ring Functions

function ringHit(id)
	playSound('Ringer', 0.6)
	rings = math.min(rings + 1, 99)
	setTextString('ringTxt', tostring(rings))

	setProperty('notes.members['..id..'].wasGoodHit', true)
	setProperty('notes.members['..id..'].active', false)
	removeFromGroup('notes', id, false)
	setProperty('notes.members['..id..'].visible', false)

	callOnScripts('ringHit', {id})
end

function ringAnim(anim, time)
	time = time or 0
	playAnim('strumLineRing', anim, true)
	resetAnim = time

	--fix offset
	local strumRingOffset = {
		['pressed'] = {x = 2, y = 2},
		['confirm'] = {x = 20, y = 20},
		['static'] = {x = 0, y = 0}
	}

	callMethod('strumLineRing.offset.set', {22.5 + strumRingOffset[anim].x, 22.5 + strumRingOffset[anim].y})
end

function onPause()
	if ringEnabled then return end
	if not getProperty('cpuControlled') then
		if getProperty('strumLineRing.animation.curAnim') ~= nil and getProperty('strumLineRing.animation.curAnim.name') ~= 'static' then
			ringAnim('static')
		end
	end
end

function onEvent(n,v1)
	if n == 'omwEvents' then
		if v1 == 'penalty' then
			setProperty('healthGain', 0)
			setHealth(2)
			penaltyStart = true
			if rings < 10 then targetHealth = 0
			elseif rings < 15 then targetHealth = 0.5
			elseif rings < 20 then targetHealth = 1
			else targetHealth = 2 end
		end
		if v1 == 'startUniverse' then
			penaltyStart = false
			setProperty('healthGain', 1)
			removeLuaSprite('ringCounter', true)
			removeLuaSprite('strumLineRing', true)
			removeLuaText('ringTxt', true)
			removeFromGroup('strumLineNotes', 6, false)
			ringEnabled = false
		end
	end
end

function noteMiss(_,_,_,isn) if penaltyStart then targetHealth = targetHealth - (isn and 0.025 or 0.1) end end
function noteMissPress() if penaltyStart then  targetHealth = targetHealth - 0.05 end end

function round(number, min, max)
	return math.max(min, math.min(max, number))
end

function lerp(a, b, t)
	return a + t * (b - a)
end