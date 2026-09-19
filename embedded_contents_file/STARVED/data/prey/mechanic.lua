local isJumping = false
local canJump = true

function onCreatePost()
	makeAnimatedLuaSprite('sonic-jump', 'sonic-jump')
	addAnimationByPrefix('sonic-jump', 'jump', 'jump', 24, true)
	scaleObject('sonic-jump', 6, 6)
	setProperty('sonic-jump.antialiasing', false)
	addLuaSprite('sonic-jump', true)
	setObjectOrder('sonic-jump', getObjectOrder('boyfriendGroup') + 1)
	
	setProperty('sonic-jump.visible', false)
end

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
end

--[[function onBeatHit()
	--cinematic 1 (furnace appears)
	if curBeat >= 64 and curBeat < 384 then canJump = true end
	--cinematic 2 (starved appears)
	if curBeat >= 384 and curBeat < 448 then canJump = false
	elseif curBeat >= 448 and curBeat < 832 then canJump = true end
	--final cinematic to end song (super sonic)
	if curBeat >= 832 then canJump = false end
end]]

function lerp(a, b, t)
	return a + t * (b - a)
end

function overlaps(obj1, obj2)
    return getProperty(obj1..'.x') < getProperty(obj2..'.x') + getProperty(obj2..'.width')
       and getProperty(obj1..'.x') + getProperty(obj1..'.width') > getProperty(obj2..'.x')
       and getProperty(obj1..'.y') < getProperty(obj2..'.y') + getProperty(obj2..'.height')
       and getProperty(obj1..'.y') + getProperty(obj1..'.height') > getProperty(obj2..'.y')
end