--[[holdTimer = -1.0
singDuration = 4
specialAnim = false

extraOPP = 'Sarah'

directions = {
	'left',
	'down',
	'up',
	'right'
}

characterAnimationsList = {
	[0] = 'idle',
	[1] = 'singLEFT',
	[2] = 'singDOWN',
	[3] = 'singUP',
	[4] = 'singRIGHT'
}

function onCreate()
	makeAnimatedLuaSprite(extraOPP, 'characters/Sarah', 0, 0)

	addAnimationByPrefix(extraOPP, 'idle', 'Sarah_IDLE', 24, false)
	addOffset(extraOPP, 'idle', -190, -140)

	addAnimationByPrefix(extraOPP, 'singLEFT', 'Sarah_LEFT', 24, false)
	addOffset(extraOPP, 'singLEFT', 0, -195)

	addAnimationByPrefix(extraOPP, 'singDOWN', 'Sarah_DOWN', 24, false)
	addOffset(extraOPP, 'singDOWN', -40, -118)

	addAnimationByPrefix(extraOPP, 'singUP', 'Sarah_UP', 24, false)
	addOffset(extraOPP, 'singUP', -260, -70)

	addAnimationByPrefix(extraOPP, 'singRIGHT', 'Sarah_RIGHT', 24, false)
	addOffset(extraOPP, 'singRIGHT', -70, -230)

	scaleObject(extraOPP, 1.2, 1.2)
	updateHitbox(extraOPP)
end

function onCreatePost()
	setProperty(extraOPP..'.x', (getProperty('dad.x') - getProperty('dad.width') / 4) + 20)
	setProperty(extraOPP..'.y', (getProperty('dad.y') + getProperty('dad.height') / 4) - 380)

	doTweenY('sYUP', extraOPP, getProperty(extraOPP..'.y') - 20, 4, 'quadInOut')

	addLuaSprite(extraOPP, true)
	setObjectOrder(extraOPP, getObjectOrder('dadGroup') - 1)
	setProperty(extraOPP..'.alpha', 0)
end

function onBeatHit()
	if curBeat % 2 == 0 and holdTimer < 0 then
		if not (getProperty(extraOPP..'.animation.curAnim.name'):sub(1, 4) == 'sing') then
			characterPlayAnimation(0, false)
		end
	end
end

function characterPlayAnimation(animId, forced)
	specialAnim = false

	local animName = characterAnimationsList[animId]
	playAnim(extraOPP, animName, forced)

	if animId > 0 then
		specialAnim = true
		holdTimer = 0
	end
end

function onUpdate(elapsed)
	local holdCap = stepCrochet * 0.0011 * singDuration

	if holdTimer >= 0 then
		holdTimer = holdTimer + elapsed

		if holdTimer >= holdCap then
			if getProperty(extraOPP..'.animation.curAnim.name'):sub(1, 4) == 'sing' then
				characterPlayAnimation(0, false)
				holdTimer = -1
			end
		end
	end

	if getProperty(extraOPP..'.animation.curAnim.finished') and specialAnim then
		specialAnim = false
	end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	characterPlayAnimation(direction + 1, true)
end

function onStepHit()
	if curStep == 742 then
		doTweenAlpha('sarahAppear', extraOPP, 1, stepCrochet / 1000 * 4, 'quadInOut')
	end

	if curStep == 976 then
		doTweenAlpha('sarahBye', extraOPP, 0, stepCrochet / 1000 * 4, 'quadInOut')
	end
end]]