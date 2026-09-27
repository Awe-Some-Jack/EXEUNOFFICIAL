local isJumping = false
local canJump = false

function onCreatePost()
	makeAnimatedLuaSprite('sonic-jump', 'sonic-jump')
	addAnimationByPrefix('sonic-jump', 'jump', 'jump', 24, true)
	scaleObject('sonic-jump', 6, 6)
	setProperty('sonic-jump.antialiasing', false)
	addLuaSprite('sonic-jump', true)
	setObjectOrder('sonic-jump', getObjectOrder('boyfriendGroup') + 1)
	
	setProperty('sonic-jump.visible', false)
end

local spikeGroup = {}
local cantMore = false
local jumpAmount = 2000
local gravity = 7000
local time = 0
local amountOfTime = 0
local lerpAmount = 0
local holdTimer = 0
function onUpdatePost(e)
	if getProperty('boyfriend.velocity.x') < 0 then
		setProperty('boyfriend.acceleration.x', 0)
		setProperty('boyfriend.velocity.x', 0)
	end

	setProperty('sonic-jump.x', getProperty('boyfriend.x') - 100)
	setProperty('sonic-jump.y', getProperty('boyfriend.y') - 100)

	if keyboardJustPressed('SPACE') then holdTimer = 0 end
	if keyboardPressed('SPACE') then holdTimer = holdTimer + e end

	if keyboardPressed('SPACE') and not isJumping and canJump and holdTimer < 0.15 then
		cantMore = false
		isJumping = true
		amountOfTime = 0
		time = 0

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

	if isJumping then time = time + e end
	if getProperty('boyfriend.y') > 420 and isJumping then
		isJumping = false

		setProperty('sonic-jump.visible', false)
		setProperty('boyfriend.alpha', 1)

		setProperty('boyfriend.y', 420)
		setProperty('boyfriend.velocity.y', 0)
		setProperty('boyfriend.acceleration.y', 0)
	end

	for i,s in ipairs(spikeGroup) do
		local spr = 'spike'..s.id
		if overlaps('boyfriend', spr) and s.detect then
			s.detect = false
			cameraShake('game', 0.01, 0.1)
			addHealth(-0.2)
			--callMethodFromClass('states.PlayState', 'updateScore', {false, false})
			callMethod('updateScore', {false, false})
		end

		if getProperty(spr..'.x') < -1200 - getProperty(spr..'.width') then
			removeLuaSprite(spr, true)
			table.remove(spikeGroup, i)
		end
	end
end

function onBeatHit()
	--cinematic 1 (furnace appears)
	if curBeat >= 64 and curBeat < 384 then canJump = true end
	--cinematic 2 (starved appears)
	if curBeat >= 384 and curBeat < 448 then canJump = false
	elseif curBeat >= 448 and curBeat < 832 then canJump = true end
	--final cinematic to end song (super sonic)
	if curBeat >= 832 then canJump = false end
end

local mech = false
function onEvent(n,v1)
	if n == 'preyEvent' and v1 == 'mech' then
		mech = not mech
	end
end

local id = 0
function onSectionHit()
	if mech and canJump and getRandomBool(35) then
		id = id + 1
		local spike = 'spike'..id
		local warning = 'warning'..id

		makeLuaSprite(spike, 'prey/spikes'..getRandomInt(1,3), 200 + ((crochet * 3) / 1000) * math.abs(getProperty('floor1.velocity.x')), 423)
		scaleObject(spike, 5, 5)
		setProperty(spike..'.offset.x', 200)
		setProperty(spike..'.antialiasing', false)
		setProperty(spike..'.velocity.x', getProperty('floor1.velocity.x'))
		setObjectOrder(spike, getObjectOrder('floor1'))
		playSound('warnin', 1)
		runTimer(warning, crochet / 1000)
		table.insert(spikeGroup, {id = id, detect = true})

		makeAnimatedLuaSprite(warning, 'warning', 500, 200)
		scaleObject(warning, 2, 2)
		addAnimationByPrefix(warning, '1', '1', 12, false)
		addAnimationByPrefix(warning, '2', '2', 12, false)
		playAnim(warning, '1', true)
		setProperty(warning..'.antialiasing', false)
		addLuaSprite(warning, true)
	end
end

function onTimerCompleted(t)
	if stringStartsWith(t, 'warning') then
		playAnim(t, '2', true)
		playSound('warnin', 1)
		runTimer('2'..t, crochet / 1000)
	end
	if stringStartsWith(t, '2warning') then
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