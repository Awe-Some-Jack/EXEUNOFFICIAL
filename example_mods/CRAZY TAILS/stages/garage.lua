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

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnim('papis', 'idle', true)
	end
end