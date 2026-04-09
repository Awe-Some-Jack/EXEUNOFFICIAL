function onCreatePost()
	makeLuaSprite('bg', 'bg/bg', -440, -310)
	scaleObject('bg', 0.7, 0.7)
	addLuaSprite('bg')

	makeAnimatedLuaSprite('papis', 'characters/mispapas', 1274, 252)
	addAnimationByPrefix('papis', 'idle', 'Símbolo 243', 24, false)
	addLuaSprite('papis')

	makeLuaSprite('esencia', 'bg/esencia')
	scaleObject('esencia', 0.7, 0.7)
	addLuaSprite('esencia', true)
	callMethod('esencia.setPosition', {-440 + getProperty('bg.width') - getProperty('esencia.width'), -310 + getProperty('bg.height') - getProperty('esencia.height')})

	--new bg

	makeLuaSprite('bg-tails', 'bg/maniapov', -900, -350)
	scaleObject('bg-tails', 1, 1)
	addLuaSprite('bg-tails')
	setProperty('bg-tails.alpha', 0.0001)

	makeLuaSprite('bg-bf', 'bg/sonicpov', -700, -250)
	scaleObject('bg-bf', 0.82, 0.82)
	addLuaSprite('bg-bf')
	setProperty('bg-bf.alpha', 0.0001)

	makeLuaSprite('bg-bf1', 'bg/estre', -730, 200)
	scaleObject('bg-bf1', 2.5, 2.5)
	addLuaSprite('bg-bf1')
	setProperty('bg-bf1.alpha', 0.0001)
	makeLuaSprite('bg-bf2', 'bg/estre2', -730, 200)
	scaleObject('bg-bf2', 2.5, 2.5)
	addLuaSprite('bg-bf2')
	setProperty('bg-bf2.alpha', 0.0001)
	makeLuaSprite('bg-bf3', 'bg/estre3', -730, 200)
	scaleObject('bg-bf3', 2.5, 2.5)
	addLuaSprite('bg-bf3')
	setProperty('bg-bf3.alpha', 0.0001)

	makeAnimatedLuaSprite('papis2', 'characters/mispapas2', 900, 350)
	addAnimationByPrefix('papis2', 'idle', 'sonamy2', 24, true)
	scaleObject('papis2', 0.8, 0.8)
	addLuaSprite('papis2')
	setProperty('papis2.alpha', 0.0001)

	--[[makeLuaSprite('never', 'bg/never', -400, -100)
	scaleObject('never', 3, 3)
	addLuaSprite('never')
	setProperty('never.alpha', 0.0001)]]

	makeFlxAnimateSprite('bestfriend', -220, -250, 'characters/itsme')
	addAnimationBySymbol('bestfriend', 'bestfriend', 'sonic', 24, false)
	scaleObject('bestfriend', 2.4, 2.4)
	addLuaSprite('bestfriend', true)
	setProperty('bestfriend.alpha', 0.0001)

	makeFlxAnimateSprite('final', -220, -550, 'characters/final2')
	addAnimationBySymbol('final', 'final', 'final', 24, false)
	scaleObject('final', 2.4, 2.4)
	addLuaSprite('final', true)
	setProperty('final.alpha', 0.0001)

	makeLuaSprite('overlay', 'bg/overlay-cinematico')
	scaleObject('overlay', 1.3, 1.3)
	setObjectCamera('overlay', 'other')
	screenCenter('overlay', 'y')
	addLuaSprite('overlay')
end

function onCountdownTick(c)
	if c % 2 == 0 then
		playAnim('papis', 'idle', true)
	end
end

local changedBG = false
function opponentNoteHitPre(id,nd,nt,isn)
	if not changedBG or nt == 'No Animation' then return end
	if nd == 0 then
		triggerEvent('Set Character Offset', 'dad', '250')
	elseif nd == 1 then
		triggerEvent('Set Character Offset', 'dad', '100')
	elseif nd == 2 then
		triggerEvent('Set Character Offset', 'dad', '150')
	elseif nd == 3 then
		triggerEvent('Set Character Offset', 'dad', '220')
	end
end

function onBeatHit()
	if curBeat % 2 == 0 and not changedBG then
		playAnim('papis', 'idle', true)
	end
end

local starSine = 0
function onUpdatePost(e)
	if not changedBG then return end
	starSine = starSine + e * 3
	setProperty('bg-bf1.alpha', 0.4 + (((math.sin(starSine) / 2) + 0.5) * 0.6))
	setProperty('bg-bf2.alpha', 0.4 + (((math.sin(starSine + 1) / 2) + 0.5) * 0.6))
	setProperty('bg-bf3.alpha', 0.4 + (((math.sin(starSine + 2) / 2) + 0.5) * 0.6))
end

local omhs = false
function onSectionHit()
	if not changedBG then return end
	if omhs ~= mustHitSection then
		if mustHitSection then
			setProperty('boyfriend.alpha', 1)
			setProperty('dad.alpha', 0)

			setProperty('bg-bf.alpha', 1)
			setProperty('bg-bf1.visible', true)
			setProperty('bg-bf2.visible', true)
			setProperty('bg-bf3.visible', true)
			setProperty('papis2.alpha', 1)
			setProperty('bg-tails.alpha', 0)
		else
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 1)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('papis2.alpha', 0)
			setProperty('bg-tails.alpha', 1)
		end

		runTimer('xdxd', 0.0001)
	end
	omhs = mustHitSection
end

function onTimerCompleted(t)
	if t == 'xdxd' then
		callMethod('camGame.snapToTarget')
	end
end

function onEvent(n,v1)
	if n == 'maniaevents' then
		if v1 == 'changebg' then
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 1)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('papis2.alpha', 0)
			setProperty('bg-tails.alpha', 1)

			callMethod('boyfriend.setPosition', {0, -70})
			callMethod('dad.setPosition', {600, -150})

			changedBG = true

			setProperty('bg.visible', false)
			setProperty('papis.visible', false)
			setProperty('esencia.visible', false)

			triggerEvent('cameracenter', 'true', '')
			callMethod('camGame.snapToTarget')
		end
		if v1 == 'bestfriend' then
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 0)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('papis2.alpha', 0)
			setProperty('bg-tails.alpha', 1)

			playAnim('bestfriend', 'bestfriend', true)
			setProperty('bestfriend.alpha', 1)

			setProperty('bg-tails.x', -200)
		end
		if v1 == 'endcine' then
			removeLuaSprite('bestfriend', true)
			removeLuaSprite('never', true)
			setProperty('boyfriend.alpha', 1)
			setProperty('bg-tails.x', -900)
		end
		if v1 == 'originalbg' then
			setProperty('boyfriend.alpha', 1)
			setProperty('dad.alpha', 1)

			callMethod('boyfriend.setPosition', {870, 40})
			callMethod('dad.setPosition', {30, 20})

			changedBG = false
			removeLuaSprite('bg-tails', true)
			removeLuaSprite('bg-bf', true)
			removeLuaSprite('bg-bf1', true)
			removeLuaSprite('bg-bf2', true)
			removeLuaSprite('bg-bf3', true)
			removeLuaSprite('papis2', true)

			setProperty('bg.visible', true)
			setProperty('papis.visible', true)
			setProperty('esencia.visible', true)

			triggerEvent('cameracenter', 'true', '')
			callMethod('camGame.snapToTarget')
			triggerEvent('Set Character Offset', 'dad', '25')
		end
		if v1 == 'finalanim' then
			playAnim('final', 'final', true)
			setProperty('final.alpha', 1)
		end
	end
end