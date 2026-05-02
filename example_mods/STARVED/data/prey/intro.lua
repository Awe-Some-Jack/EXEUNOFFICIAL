function onCreatePost()
	makeAnimatedLuaSprite('introsonic', 'characters/anim_inicio', getProperty('boyfriend.x') + 82, getProperty('boyfriend.y') + 31)
	addAnimationByPrefix('introsonic', 'intro', 'anim_Inicio', 24, false)
	scaleObject('introsonic', 6, 6, false)
	setProperty('introsonic.antialiasing', false)
	addLuaSprite('introsonic')
	setObjectOrder('introsonic', getObjectOrder('boyfriendGroup') + 1)
	setProperty('introsonic.alpha', 0)

	makeAnimatedLuaSprite('furnaceHit', 'characters/furnace-hit', getProperty('dad.x') - 20, getProperty('dad.y') + 51)
	addAnimationByPrefix('furnaceHit', 'hit', 'idle', 24, true)
	scaleObject('furnaceHit', 6, 6, false)
	setProperty('furnaceHit.antialiasing', false)
	addLuaSprite('furnaceHit', true)
	setProperty('furnaceHit.alpha', 0)

	makeAnimatedLuaSprite('sonicfinal', 'characters/sonicfinale', getProperty('boyfriend.x') + 355, getProperty('boyfriend.y') - 55)
	addAnimationByPrefix('sonicfinal', 'idle', 'idle', 12, false)
	scaleObject('sonicfinal', 6, 6, false)
	setProperty('sonicfinal.antialiasing', false)
	addLuaSprite('sonicfinal', true)
	setProperty('sonicfinal.alpha', 0)

	makeAnimatedLuaSprite('starvHit', 'characters/starvfinal', getProperty('dad.x') + 20, getProperty('dad.y') - 100)
	addAnimationByPrefix('starvHit', 'idle', 'idle', 12, false)
	scaleObject('starvHit', 6, 6, false)
	setProperty('starvHit.antialiasing', false)
	addLuaSprite('starvHit')
	setProperty('starvHit.alpha', 0)
end

function onUpdatePost(e)
	if getProperty('introsonic.animation.curAnim.name') == 'intro' and getProperty('introsonic.animation.curAnim.finished') then
		removeLuaSprite('introsonic', true)
		setProperty('boyfriend.alpha', 1)
	end

	if curBeat < 388 then
		setProperty('furnaceHit.x', getProperty('dad.x') - 20)
		setProperty('furnaceHit.y', getProperty('dad.y') + 51)
		setProperty('furnaceHit.angle', getProperty('dad.angle'))
	end

	if curBeat < 832 then
		setProperty('starvHit.x', getProperty('dad.x') - 424)
		setProperty('starvHit.y', getProperty('dad.y') - 78)
		setProperty('starvHit.angle', getProperty('dad.angle'))
	end
end