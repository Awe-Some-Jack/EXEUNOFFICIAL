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

	makeLuaSprite('bg-tails', 'bg/maniapov', -440, -310)
	scaleObject('bg-tails', 3, 3)
	addLuaSprite('bg-tails')
	setProperty('bg-tails.alpha', 0.0001)

	makeLuaSprite('bg-bf', 'bg/sonicpov', -440, -310)
	scaleObject('bg-bf', 3, 3)
	addLuaSprite('bg-bf')
	setProperty('bg-bf.alpha', 0.0001)

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
function onBeatHit()
	if curBeat % 2 == 0 and not changedBG then
		playAnim('papis', 'idle', true)
	end
end

function onSectionHit()
	if not changedBG then return end
	if mustHitSection then
		setProperty('boyfriend.alpha', 1)
		setProperty('dad.alpha', 0)

		setProperty('bg-bf.alpha', 1)
		setProperty('bg-tails.alpha', 0)
	else
		setProperty('boyfriend.alpha', 0)
		setProperty('dad.alpha', 1)

		setProperty('bg-bf.alpha', 0)
		setProperty('bg-tails.alpha', 1)
	end
end

function onEvent(n,v1)
	if n == 'maniaevents' then
		if v1 == 'changebg' then
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 1)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-tails.alpha', 1)

			changedBG = true
			removeLuaSprite('bg', true)
			removeLuaSprite('papis', true)
			removeLuaSprite('esencia', true)

			triggerEvent('cameracenter', 'true', '')
			callMethod('camGame.snapToTarget')
		end
	end
end