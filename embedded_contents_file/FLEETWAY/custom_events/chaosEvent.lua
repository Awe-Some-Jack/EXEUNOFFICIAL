local canFloat = false
local canBFFloat = false

local attacking = false
local dodging = false
local dodgehold = 0
local time = 0

local dadX, dadY = 0, 0
local bfX, bfY = 0, 0

local firstattack = false

function onCreatePost()
	makeAnimatedLuaSprite('xxdd', 'bg/eat')
	addAnimationByPrefix('xxdd', 'idle', 'eat this', 24, false)
	setObjectCamera('xxdd', 'hud')
	scaleObject('xxdd', 1.3, 1.3)
	screenCenter('xxdd')
	setProperty('xxdd.visible', false)
	addLuaSprite('xxdd', true)

	makeAnimatedLuaSprite('spacebar', 'spacebar', 0, screenHeight * (downscroll and 0.6 or 0.2))
	addAnimationByPrefix('spacebar', 'idle', 'Símbolo 8', 48, false)
	playAnim('spacebar', 'idle', true)
	scaleObject('spacebar', 0.6, 0.6)
	setObjectCamera('spacebar', 'hud')
	screenCenter('spacebar', 'x')
	addLuaSprite('spacebar', true)
	setProperty('spacebar.visible', false)

	setProperty('dad.alpha', 0)
	dadX, dadY = getProperty('dad.x'), getProperty('dad.y')
	bfX, bfY = getProperty('boyfriend.x'), getProperty('boyfriend.y')
	callMethod('dadGroup.setPosition', {dadX + 200, dadY - 162})
end

function onEvent(n,v1)
	if n == 'chaosEvent' then
		if v1 == 'tweendad' then
			doTweenX('dadX', 'dad', dadX, 1 / playbackRate, 'smoothStepInOut')
			doTweenY('dadY', 'dad', dadY, 1 / playbackRate, 'cubeInOut')
		end

		if v1 == 'eatthis' then
			attacking = true
			time = 0
			setProperty('spacebar.visible', true)
			runTimer('fuckye', crochet / (1000 / 3) / playbackRate)
		end
		
		if v1 == 'bftransform' then
			doTweenX('bfX', 'boyfriendGroup', 2910, 1, 'cubeOut')
			doTweenY('bfY', 'boyfriendGroup', 1100, 1, 'cubeOut')
			playSound('SUPERBF', 0.8)
			cameraFlash('game', 'FFFF00', 1, true)
		end
		if v1 == 'getblacklmao' then
			setProperty('camGame.alpha', 0)
			runTimer('fuckYOU', 3)
		end
	end
end

function onTweenCompleted(t) if t == 'dadX' then canFloat = true end if t == 'bfX' then canBFFloat = true end end
local xdx = 0
local dxd = 0
function onUpdatePost(e)
	if dodgehold > 0 then dodgehold = dodgehold - e
	else dodgehold = 0 end
	if keyboardJustPressed('SPACE') then
		dodgehold = 1
		setProperty('spacebar.visible', false)
	end
	dodging = dodgehold > 0

	if getProperty('xxdd.animation.curAnim.finished') == true and getProperty('xxdd.visible') == true then
		setProperty('xxdd.visible', false)
	end

	if canFloat then
		xdx = xdx + e
		callMethod('dad.setPosition', {
			dadX + math.cos(xdx * (1 / 2)) * (50 * 2),
			dadY + math.sin(xdx * 1) * 50
		})
	end

	if canBFFloat then
		dxd = dxd + e
		callMethod('boyfriend.setPosition', {
			2910 + math.cos(dxd * (1 / 2) + 0.5) * (50 * 2),
			1100 + math.sin(dxd * 1 + 0.5) * 50
		})
	end
end

function onBeatHit()
	if attacking == true then
		playAnim('spacebar', 'idle', true)
		time = time + 1
		if time == 3 and firstattack == true then
			playAnim('dad', 'eat', true)
			setProperty('dad.specialAnim', true)
		end
		if time == 2 and firstattack == false and flashingLights then
			firstattack = true
			setProperty('xxdd.visible', true)
			playAnim('xxdd', 'idle', true) 
		end
	end
end

function onTimerCompleted(t)
	if t == 'fuckye' then
		attacking = false
		setProperty('spacebar.visible', false)

		if dodging == false and not getProperty('cpuControlled') then
			cameraShake('game', 0.01, 0.1)
			addHealth(-10)
			yourdeadnow = true
		end

		if not yourdeadnow then playSound('laser_moment', 1) end

		playAnim('boyfriend', 'dodge', true)
		setProperty('boyfriend.specialAnim', true)

		time = 0
		dodgehold = 0
		dodging = false
	end

	if t == 'fuckYOU' then doTweenAlpha('camHUDAlpha', 'camHUD', 0, 2) end
end

function opponentNoteHitPre(id)
	if getProperty('dad.animation.curAnim.name') == 'eat' then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end

function goodNoteHitPre(id)
	if getProperty('boyfriend.animation.curAnim.name') == 'dodge' then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end