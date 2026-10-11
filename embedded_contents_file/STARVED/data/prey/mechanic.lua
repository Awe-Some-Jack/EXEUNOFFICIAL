local isJumping = false
local canJump = false
local airTime = 0

local isInvulnerable = false
local invulnerableTimer = 0
local INVULN_DURATION = 2.0

function onCreatePost()
	makeAnimatedLuaSprite('sonic-jump', 'prey/sonic-jump')
	addAnimationByPrefix('sonic-jump', 'jump', 'jump', 24, true)
	scaleObject('sonic-jump', 6, 6)
	setProperty('sonic-jump.antialiasing', false)
	addLuaSprite('sonic-jump', true)
	setObjectOrder('sonic-jump', getObjectOrder('boyfriendGroup') + 1)
	
	setProperty('sonic-jump.visible', false)

	makeLuaSprite('sonicHitboxFix', nil, 0, 0)
	makeGraphic('sonicHitboxFix', 160, 170, '0000FF')
	setProperty('sonicHitboxFix.alpha', 0)
	addLuaSprite('sonicHitboxFix', true)

	setVar('isJumping', false)
end

local spikeGroup = {}
local ringGroup = {}
local missedRings = {}
local cantMore = false
local jumpAmount = 1400
local gravity = 4000
local amountOfTime = 0
local holdTimer = 0
local triggerOnce = false
local _lF = 0
local leftFloor = 0
local floorPassed = false
local canceledJump = false

function onUpdatePost(e)
	if inGameOver then return end

	if isJumping then
		airTime = airTime + e
	end

	callMethod('sonicHitboxFix.setPosition', {getProperty('boyfriend.x') + 10, getProperty('boyfriend.y') - 25})

	if getProperty('boyfriend.velocity.x') < 0 then
		setProperty('boyfriend.acceleration.x', 0)
		setProperty('boyfriend.velocity.x', 0)
	end

	if canceledJump == true and not stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'hit') then 
		canceledJump = false 
	end

	setProperty('sonic-jump.x', getProperty('boyfriend.x') - 100)
	setProperty('sonic-jump.y', getProperty('boyfriend.y') - 100)

	if isInvulnerable then
		invulnerableTimer = invulnerableTimer - e
		local alphaVal = (math.floor(invulnerableTimer * 15) % 2 == 0) and 0.3 or 1.0
		if not getProperty('sonic-jump.visible') then
			setProperty('boyfriend.alpha', alphaVal)
		end
		
		if invulnerableTimer <= 0 then
			isInvulnerable = false
			if not isJumping then
				setProperty('boyfriend.alpha', 1.0)
			end
		end
	end

	if not getProperty('cpuControlled') or not stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'hit') then
		if not canceledJump then
			if keyboardJustPressed('SPACE') then holdTimer = 0 end
			if keyboardPressed('SPACE') then holdTimer = holdTimer + e end

			if keyboardPressed('SPACE') and not isJumping and canJump and holdTimer < 0.15 then
				cantMore = false
				isJumping = true
				setVar('isJumping', isJumping)
				amountOfTime = 0
				airTime = 0

				setProperty('sonic-jump.visible', true)
				setProperty('boyfriend.alpha', 0)
				playAnim('sonic-jump', 'jump', true)
				playSound('sonicJump')
			end
			if keyboardReleased('SPACE') then cantMore = true end
			if keyboardPressed('SPACE') and cantMore == false and amountOfTime < 0.1 and canJump then
				amountOfTime = amountOfTime + e
				
				setProperty('boyfriend.acceleration.y', gravity)
				setProperty('boyfriend.velocity.y', -jumpAmount * (1 + (amountOfTime * 3)))
			end
		end
	end

	if getProperty('boyfriend.y') >= getVar('floorY') and isJumping and airTime > 0.55 and getProperty('boyfriend.velocity.y') >= 0 then
		isJumping = false
		setVar('isJumping', isJumping)
		airTime = 0

		setProperty('sonic-jump.visible', false)
		if not isInvulnerable then
			setProperty('boyfriend.alpha', 1)
		end

		setProperty('boyfriend.y', getVar('floorY'))
		setProperty('boyfriend.velocity.y', 0)
		setProperty('boyfriend.acceleration.y', 0)
	end

	if stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'idle') and triggerOnce then
		triggerOnce = false
		for i = 0, getProperty('notes.length')-1 do
			setProperty('notes.members['..i..'].noAnimation', false)
			setProperty('notes.members['..i..'].noMissAnimation', false)
		end
	end

	for i, s in ipairs(spikeGroup) do
		local spr = s.sprite
		if overlaps('sonicHitboxFix', spr) and s.detect and not isInvulnerable and not isJumping then
			if getVar('rings') > 0 then
				isInvulnerable = true
				invulnerableTimer = INVULN_DURATION

				for _, o in ipairs(spikeGroup) do 
					if o.id == s.id then o.detect = false end 
				end

				for j = 1, getVar('rings') do
					local missedRing = 'missedRing'..j
					makeAnimatedLuaSprite(missedRing, 'prey/ring', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
					addAnimationByPrefix(missedRing, 'idle', 'ring', 8, true)
					scaleObject(missedRing, 6, 6)
					setProperty(missedRing..'.antialiasing', false)
					setProperty(missedRing..'.velocity.x', getRandomInt(-500, 500))
					setProperty(missedRing..'.acceleration.x', getProperty('floorGroup[0].velocity.x'))
					setProperty(missedRing..'.maxVelocity.x', math.abs(getProperty('floorGroup[0].velocity.x')))
					setProperty(missedRing..'.velocity.y', -getRandomInt(1500, 2000))
					setProperty(missedRing..'.acceleration.y', gravity)
					addLuaSprite(missedRing, true)
					table.insert(missedRings, missedRing)
				end
				runTimer('removeMissedRings', 1)

				cameraShake('game', 0.01, 0.1)
				setProperty('sonic-jump.visible', false)
				
				playSound('hit')
				playSound('loseRings')
				setVar('rings', 0)
				callOnScripts('updateRings')
				playAnim('boyfriend', 'hit'..getProperty('boyfriend.idleSuffix'), true)
				setProperty('boyfriend.specialAnim', true)
				triggerOnce = true
				canceledJump = true

				for j = 0, getProperty('notes.length')-1 do
					setProperty('notes.members['..j..'].noAnimation', true)
					setProperty('notes.members['..j..'].noMissAnimation', true)
				end
			else
				playSound('hit')
				setProperty('instakillOnMiss', true)
				callMethod('doDeathCheck', {true})
			end
		end

		if getProperty(spr..'.x') < -1200 - getProperty(spr..'.width') then
			removeLuaSprite(spr, true)
			table.remove(spikeGroup, i)
		end
	end

	for i, r in ipairs(ringGroup) do
		local ring = r.sprite
		if overlaps('sonicHitboxFix', ring) then
			setVar('rings', math.min(getVar('rings') + 1, 150))
			callOnScripts('updateRings')
			playSound('Ringer', 0.8)
			playAnim(ring, 'sparkle', true)
			runTimer(ring, 0.4)
			table.remove(ringGroup, i)
		end

		if getProperty(ring..'.x') < -1200 - getProperty(ring..'.width') then
			removeLuaSprite(ring, true)
			table.remove(ringGroup, i)
		end
	end

    local distance = ((crochet * 3) / 1000) * math.abs(getProperty('floorGroup[0].velocity.x') * 1.07)
	if not floorPassed and getProperty('floorGroup['.._lF..'].x') < distance then
		_lF = 1 - _lF
		floorPassed = true
	elseif floorPassed and getProperty('floorGroup['.._lF..'].x') > distance then
		floorPassed = false
	end
	leftFloor = 1 - _lF
end

function onBeatHit()
	canJump = false
	if (curBeat >= 96 and curBeat < 379) or (curBeat >= 448 and curBeat < 823) then canJump = true end
end

local mech = false
function onEvent(n, v1)
	if n == 'preyEvent' and v1 == 'mech' then
		mech = not mech
	end
end

local playSoundOnce = true
local id = 0
local ringId = 0
function onSectionHit()
	if mech and canJump and getRandomBool(65) then
		local amount = getRandomInt(1, 3)
		local distance = ((crochet * 3) / 1000) * math.abs(getProperty('floorGroup[0].velocity.x') * 1.07)
		local daOffset = 0
		local floorX = getProperty('floorGroup['..leftFloor..'].x') + distance - (math.abs(getProperty('floorGroup[0].velocity.x')) - 2000) * 2.14
		if getProperty('floorGroup['..leftFloor..'].ID') == 2 then
			if (floorX < (2429 + (amount * (32 * 6))) and floorX > 1503)
			or (floorX < (-3618 + (amount * (32 * 6))) and floorX > -4491)
			or (floorX < (-6716 + (amount * (32 * 6))) and floorX > -7542)
			or (floorX < -(17557 + (amount * (32 * 6))) and floorX > -18445) then
				return
			end

			if (floorX < 1503 and floorX > (-3618 + (amount * (32 * 6)))) then daOffset = 384 end
			if (floorX < -4491 and floorX > (-6716 + (amount * (32 * 6)))) then daOffset = 0 end
			if (floorX < -7542 and floorX > (-17557 + (amount * (32 * 6)))) then daOffset = -384 end
			if floorX < -18445 then daOffset = 0 end
		else
			if (floorX < (-532 + (amount * (32 * 6))) and floorX > -1430)
			or (floorX < (-6797 + (amount * (32 * 6))) and floorX > -7665) then
				return
			end

			if (floorX < -1430 and floorX > (-6797 + (amount * (32 * 6)))) then daOffset = -384 end
			if floorX < -7665 then daOffset = 0 end
		end

		if getRandomBool(50) then
			ringId = ringId + 1

			local ringOffset = getRandomBool(50) and 0 or 500
			for i = 1, getRandomInt(3, 5, 4) do
				local ring = 'ring'..ringId..'_'..i

				makeAnimatedLuaSprite(ring, 'prey/ring', distance + ((i - 1) * (32 * 6)) + (8 * 6), 392 + daOffset - ringOffset)
				addAnimationByPrefix(ring, 'idle', 'ring', 8, true)
				addAnimationByPrefix(ring, 'sparkle', 'sparkle', 8, true)
				playAnim(ring, 'idle', true)
				scaleObject(ring, 6, 6)
				setProperty(ring..'.antialiasing', false)
				setProperty(ring..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
				setObjectOrder(ring, getObjectOrder('floorGroup[0]'))

				table.insert(ringGroup, {id = ringId, sprite = ring})
			end
		else
			id = id + 1

			local startX = distance
			local endX = distance + (amount * (32 * 6))
			
			if callHScript and callHScript('isRampAt', {startX, endX}) then
				return
			end

			for i = 1, amount do
				local spike = 'spike'..id..'_'..i

				makeLuaSprite(spike, 'prey/spikes', distance + ((i - 1) * (32 * 6)), 392 + daOffset)
				scaleObject(spike, 6, 6)
				setProperty(spike..'.antialiasing', false)
				setProperty(spike..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
				setObjectOrder(spike, getObjectOrder('floorGroup[0]'))

				table.insert(spikeGroup, {id = id, sprite = spike, detect = true})
			end

			local warning = 'warning'..id
			makeAnimatedLuaSprite(warning, 'prey/warning', 500, (getVar('floorY') - 420))
			scaleObject(warning, 2, 2)
			addAnimationByPrefix(warning, '1', '1', 12, false)
			addAnimationByPrefix(warning, '2', '2', 12, false)
			playAnim(warning, '1', true)
			setProperty(warning..'.antialiasing', false)
			addLuaSprite(warning, true)

			if playSoundOnce then playSound('warnin', 0.8) end
			runTimer(warning, crochet / 1000)
		end
	end
end

local mrid = 0
function noteMiss(_, _, _, isn)
	if isn and isInvulnerable then return end
	if getVar('rings') > 0 then
		mrid = mrid + 1
		local missedRing = 'missedRing'..mrid
		makeAnimatedLuaSprite(missedRing, 'prey/ring', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
		addAnimationByPrefix(missedRing, 'idle', 'ring', 8, true)
		scaleObject(missedRing, 6, 6)
		setProperty(missedRing..'.antialiasing', false)
		setProperty(missedRing..'.velocity.x', getRandomInt(-500, 500))
		setProperty(missedRing..'.acceleration.x', getProperty('floorGroup[0].velocity.x'))
		setProperty(missedRing..'.maxVelocity.x', math.abs(getProperty('floorGroup[0].velocity.x')))
		setProperty(missedRing..'.velocity.y', -getRandomInt(1500, 2000))
		setProperty(missedRing..'.acceleration.y', gravity)
		addLuaSprite(missedRing, true)
		runTimer(missedRing, 1)

		playSound('loseRings', 0.45)
		setVar('rings', getVar('rings') - 1)
		callOnScripts('updateRings')
	else
		setProperty('instakillOnMiss', true)
		callMethod('doDeathCheck', {true})
	end
end

function onTimerCompleted(t)
	if stringStartsWith(t, 'warning') then
		playAnim(t, '2', true)
		if playSoundOnce then playSound('warnin', 0.8) end
		playSoundOnce = false
		runTimer('2'..t, crochet / 1000)
	end
	if stringStartsWith(t, '2warning') then
		if getProperty('cpuControlled') then
			isJumping = true
			setProperty('sonic-jump.visible', true)
			setProperty('boyfriend.alpha', 0)
			playAnim('sonic-jump', 'jump', true)
			playSound('sonicJump')
			setProperty('boyfriend.acceleration.y', gravity)
			setProperty('boyfriend.velocity.y', -jumpAmount * 1.5)
		end

		removeLuaSprite(t:sub(2), true)
	end

	if stringStartsWith(t, 'ring') then removeLuaSprite(t, true) end

	if t == 'removeMissedRings' then
		for _, r in ipairs(missedRings) do
			removeLuaSprite(r, true)
		end
		missedRings = {}
	end
	if stringStartsWith(t, 'missedRing') then removeLuaSprite(t, true) end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function overlaps(obj1, obj2)
    return getProperty(obj1..'.x') < getProperty(obj2..'.x') + getProperty(obj2..'.width')
       and getProperty(obj1..'.x') + getProperty(obj1..'.width') > getProperty(obj2..'.x')
       and getProperty(obj1..'.y') < getProperty(obj2..'.y') + getProperty(obj2..'.height')
       and getProperty(obj1..'.y') + getProperty(obj1..'.height') > getProperty(obj2..'.y')
end