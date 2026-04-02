local isAttacking = false

local sda = 0
function onCreatePost()
	makeAnimatedLuaSprite('spacebar', 'spacebar', 0, screenHeight * (downscroll and 0.6 or 0.2))
	addAnimationByPrefix('spacebar', 'xd', 'Símbolo 8', 48, false)
	playAnim('spacebar', 'xd', true)
	scaleObject('spacebar', 0.6, 0.6)
	setObjectCamera('spacebar', 'hud')
	screenCenter('spacebar', 'x')
	addLuaSprite('spacebar', true)
	setProperty('spacebar.alpha', 0)
	sda = getObjectOrder('dadGroup')
end

function onEvent(n)
	if n == 'attack' then
		local tag = 'target'..math.floor(getSongPosition())
		makeAnimatedLuaSprite(tag, 'TargetLock', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
		addAnimationByPrefix(tag, 'lol', 'TargetLock', 24, false)
		doTweenAngle(tag, tag, 180, crochet / 500 / playbackRate, 'cubeOut')
		playAnim(tag, 'lol', true)
		addLuaSprite(tag, true)
		runTimer(tag, crochet / 250 / playbackRate)
		runTimer('spaceappear'..math.floor(getSongPosition()), crochet / 750 / playbackRate)
		playAnim('dad', 'getfuckedlol', true)
		setProperty('dad.animation.curAnim.frameRate', 24 * (curBpm / 140))
		setProperty('dad.animation.curAnim.curFrame', 3)
		setProperty('dad.specialAnim', true)
		setObjectOrder('dadGroup', getObjectOrder('boyfriendGroup') + 1)
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnim('spacebar', 'xd', true)
	end
end

function onUpdatePost(e)
	if isAttacking then
		if keyboardJustPressed('SPACE') and getProperty('boyfriend.animation.curAnim.name') ~= 'ay' then
			setProperty('spacebar.alpha', 0)
			playAnim('boyfriend', 'ay', true)
			setProperty('boyfriend.specialAnim', true)
		end
	end

	if getProperty('dad.animation.curAnim.name') == 'getfuckedlol' and getProperty('dad.animation.curAnim.finished') then
		setObjectOrder('dadGroup', sda)
	end
end

function onTimerCompleted(t,l,ll)
	if stringStartsWith(t, 'target') then
		isAttacking = false
		if getProperty('boyfriend.animation.curAnim.name') ~= 'ay' and not getProperty('cpuControlled') then addHealth(-5) end
		if getProperty('cpuControlled') then
			playAnim('boyfriend', 'ay', true)
			setProperty('boyfriend.specialAnim', true)
		end
		if luaSpriteExists(t) then removeLuaSprite(t) end
		setProperty('spacebar.alpha', 0)
	end
	if stringStartsWith(t, 'datarget') then
		setProperty(t:sub(3)..'.colorTransform.color', getColorFromHex((ll % 2 == 0 and 'FF0000' or '00FF00')))
	end
	if stringStartsWith(t, 'spaceappear') then
		setProperty('spacebar.alpha', 1)
		isAttacking = true
	end
end

function goodNoteHitPre(id)
	if getProperty('boyfriend.animation.curAnim.name') == 'ay' and isAttacking then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end

function opponentNoteHitPre(id)
	if getProperty('dad.animation.curAnim.name') == 'getfuckedlol' then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end

function onTweenCompleted(t)
	if t:match('target') then
		setProperty(t..'.colorTransform.color', getColorFromHex('FF0000'))
		runTimer('da'..t, stepCrochet / 1500 / playbackRate, 10)
	end
end