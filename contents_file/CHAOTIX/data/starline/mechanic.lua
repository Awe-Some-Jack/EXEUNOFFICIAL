local startMechanic = false
local startDrain = false
local targetHealth = 1
local startHealth = 2

function onCreatePost()
	makeAnimatedLuaSprite('dontmiss', 'dontmiss')
	addAnimationByPrefix('dontmiss', 'idle', 'idle', 16, false)
	scaleObject('dontmiss', 6, 6)
	setProperty('dontmiss.antialiasing', false)
	screenCenter('dontmiss')
	setObjectCamera('dontmiss', 'hud')
	addLuaSprite('dontmiss', true)
	setProperty('dontmiss.alpha', 0.0001)
end

local once = true
function onBeatHit()
	if curBeat >= 271 and curBeat < 544 and once then
		once = false
		startMechanic = true
		targetHealth = getHealth()
		setProperty('healthGain', 0)
		setProperty('healthLoss', 0)
		triggerEvent('Change Health Damage', '0')
	end

	if curBeat == 542 then setProperty('dontmiss.alpha', 1) playAnim('dontmiss', 'idle', true) end
	if curBeat >= 544 and curBeat < 608 and not startDrain then
		targetHealth = 0
		startMechanic = false
		startDrain = true

		startHealth = getRandomFloat(2, 1.15)
		cameraShake('game', 0.01, 0.1) cameraShake('hud', 0.01, 0.1)

		removeLuaSprite('dontmiss', true)
	end
	if curBeat >= 608 then
		startDrain = false
		setProperty('healthGain', 1)
		setProperty('healthLoss', 1)
	end
end

function onEvent(n)
	if n == 'Set Random Health' then
		targetHealth = getRandomFloat(1.85, 0.35)
		cameraShake('game', 0.01, 0.1) cameraShake('hud', 0.01, 0.1)
	end
end

function onSectionHit()
	if curSection % 8 == 4 and startMechanic then
		targetHealth = getRandomFloat(1.85, 0.35)
		cameraShake('game', 0.01, 0.1) cameraShake('hud', 0.01, 0.1)
	end
end

function onUpdatePost(e)
	if startMechanic then
		setHealth(lerp(getHealth(), targetHealth, 8 * e))
	end
	if startDrain then
		setHealth(lerp(startHealth, 0.05 + targetHealth, (getSongPosition() - 237820) / (260410 - 237820)))
	end
end

function noteMiss(_,_,_,isn) targetHealth = targetHealth - (isn and 0.025 or 0.1) end
function noteMissPress() targetHealth = targetHealth - 0.05 end
function lerp(a, b, t) return a + t * (b - a) end