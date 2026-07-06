local attacking = false
local dodging = false
local dodgehold = 0
local time = 0

function onCreatePost()
	makeAnimatedLuaSprite('warnin', 'slash warning sheet')
	addAnimationByPrefix('warnin', 'idle', 'slash warning', 24, false)
	setObjectCamera('warnin', 'hud')
	scaleObject('warnin', 2, 2)
	screenCenter('warnin')
	addLuaSprite('warnin')
	setProperty('warnin.antialiasing', false)
	setProperty('warnin.visible', false)
end

function onEvent(n)
	if n == 'slashattack' then
		attacking = true
		time = 0
		setProperty('warnin.visible', true)
		runTimer('fuckye', crochet / (1000 / 4) / playbackRate)
		playSound('slashwarning', 0.35)
	end
end

function onUpdatePost(e)
	if dodgehold > 0 then dodgehold = dodgehold - e
	else dodgehold = 0 end
	if keyboardJustPressed('SPACE') then
		dodgehold = 1
		setProperty('warnin.visible', false)
	end
	dodging = dodgehold > 0
end

function onBeatHit()
	if attacking == true then
		playAnim('warnin', 'idle', true)
		time = time + 1
		if time == 4 then
			playAnim('dad', 'attack', true)
			setProperty('dad.specialAnim', true)
		end
	end
end

function onTimerCompleted(t)
	if t == 'fuckye' then
		attacking = false
		playSound('slashslash', 1)
		setProperty('warnin.visible', false)

		if dodging == false and not getProperty('cpuControlled') then
			cameraShake('game', 0.01, 0.1)
			addHealth(-1.2)
			playSound('slashmiss', 0.5)
		end
		dodgehold = 0
		dodging = false
	end
end

function opponentNoteHitPre(id)
	if getProperty('dad.animation.curAnim.name') == 'attack' then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end