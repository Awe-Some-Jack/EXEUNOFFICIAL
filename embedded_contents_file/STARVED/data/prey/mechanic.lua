local isJumping = false
local canJump = false

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
local cantMore = false
local jumpAmount = 2000
local gravity = 7000
local amountOfTime = 0
local holdTimer = 0
local triggerOnce = false
function onUpdatePost(e)
	callMethod('sonicHitboxFix.setPosition', {getProperty('boyfriend.x') + 10, getProperty('boyfriend.y') - 25})

	if getProperty('boyfriend.velocity.x') < 0 then
		setProperty('boyfriend.acceleration.x', 0)
		setProperty('boyfriend.velocity.x', 0)
	end

	setProperty('sonic-jump.x', getProperty('boyfriend.x') - 100)
	setProperty('sonic-jump.y', getProperty('boyfriend.y') - 100)

	if not getProperty('cpuControlled') then
		if keyboardJustPressed('SPACE') then holdTimer = 0 end
		if keyboardPressed('SPACE') then holdTimer = holdTimer + e end

		if keyboardPressed('SPACE') and not isJumping and canJump and holdTimer < 0.15 then
			cantMore = false
			isJumping = true
			setVar('isJumping', isJumping)
			amountOfTime = 0

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

	if getProperty('boyfriend.y') > getVar('floorY') and isJumping then
		isJumping = false
		setVar('isJumping', isJumping)

		setProperty('sonic-jump.visible', false)
		setProperty('boyfriend.alpha', 1)

		setProperty('boyfriend.y', getVar('floorY'))
		setProperty('boyfriend.velocity.y', 0)
		setProperty('boyfriend.acceleration.y', 0)
	end

	if stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'idle') and triggerOnce then
		triggerOnce = false
		for i = 0,getProperty('notes.length')-1 do
			setProperty('notes.members['..i..'].noAnimation', false)
			setProperty('notes.members['..i..'].noMissAnimation', false)
		end
	end

	for i,s in ipairs(spikeGroup) do
		local spr = s.sprite
		if overlaps('sonicHitboxFix', spr) and s.detect then
			for _,o in ipairs(spikeGroup) do if o.id == s.id then o.detect = false end end

			cameraShake('game', 0.01, 0.1)
			addHealth(-0.5 * (math.abs(getProperty('floor.velocity.x')) / 2000))
			callMethod('updateScore', {false, false})
			playSound('hit')
			playAnim('boyfriend', 'hit'..getProperty('boyfriend.idleSuffix'), true)
			setProperty('boyfriend.specialAnim', true)
			triggerOnce = true

			for i = 0,getProperty('notes.length')-1 do
				setProperty('notes.members['..i..'].noAnimation', true)
				setProperty('notes.members['..i..'].noMissAnimation', true)
			end
		end

		if getProperty(spr..'.x') < -1200 - getProperty(spr..'.width') then
			removeLuaSprite(spr, true)
			table.remove(spikeGroup, i)
		end
	end
end

function onBeatHit()
	canJump = false
	if (curBeat >= 96 and curBeat < 379) or (curBeat >= 448 and curBeat < 823) then canJump = true end
end

local mech = false
function onEvent(n,v1)
	if n == 'preyEvent' and v1 == 'mech' then
		mech = not mech
	end
end

local id = 0
function onSectionHit()
	if mech and canJump and getRandomBool(100) then
		local speed = math.abs(getProperty('floorGroup[0].velocity.x'))
		local delay = ((crochet * 3) / 1000) * 1.07
		local futureFloorY = callOnHScript('getRampFloorY', {delay, 1})

		local daOffset = futureFloorY - 420

		if daOffset ~= 0 and math.abs(daOffset) ~= 384 then
			debugPrint('yea it can, proof: '..daOffset)
			return
		end
		id = id + 1

		for i = 1,getRandomInt(1,3) do
			local spike = 'spike'..id..'_'..i

			makeLuaSprite(spike, 'prey/spikes', ((crochet * 3) / 1000) * math.abs(getProperty('floorGroup[0].velocity.x') * 1.07) + ((i - 1) * (32 * 6)), 392 + daOffset)
			scaleObject(spike, 6, 6)
			setProperty(spike..'.antialiasing', false)
			setProperty(spike..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
			setObjectOrder(spike, getObjectOrder('floorGroup[0]'))

			table.insert(spikeGroup, {id = id, sprite = spike, detect = true})
		end

		local warning = 'warning'..id
		makeAnimatedLuaSprite(warning, 'prey/warning', 500, 200)
		scaleObject(warning, 2, 2)
		addAnimationByPrefix(warning, '1', '1', 12, false)
		addAnimationByPrefix(warning, '2', '2', 12, false)
		playAnim(warning, '1', true)
		setProperty(warning..'.antialiasing', false)
		addLuaSprite(warning, true)

		playSound('warnin', 1)
		runTimer(warning, crochet / 1000)
	end
end

function onTimerCompleted(t)
	if stringStartsWith(t, 'warning') then
		playAnim(t, '2', true)
		playSound('warnin', 1)
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