function onCreatePost()
	makeAnimatedLuaSprite('legsframerate', 'characters/deception/picolegs')
	addAnimationByPrefix('legsframerate', 'idle', 'Símbolo 133', 24, true)
	addLuaSprite('legsframerate')
	setProperty('legsframerate.visible', false)

	makeAnimatedLuaSprite('picolegs', 'characters/deception/picolegs')
	setLegAnims()
	addLuaSprite('picolegs', true)
	setObjectOrder('picolegs', getObjectOrder('gfGroup'))
	setProperty('picolegs.visible', gfName == 'picod-run')
end

function onEvent(n)
	if n == 'Change Character' then
		setProperty('picolegs.visible', gfName == 'picod-run')
		setObjectOrder('picolegs', getObjectOrder('gfGroup'))
		scaleObject('picolegs', getProperty('gf.scale.x'), getProperty('gf.scale.y'), false)
	end
end

function onUpdatePost(e)
	if gfName == 'picod-run' then
		callMethod('picolegs.setPosition', {getProperty('gf.x') - 40, getProperty('gf.y') + 335})

		if getProperty('picolegs.animation.curAnim.name') ~= getProperty('gf.animation.curAnim.name') then playAnim('picolegs', getProperty('gf.animation.curAnim.name'), true) end

		if getProperty('gf.animation.curAnim.name') == 'idle' then setProperty('gf.animation.curAnim.curFrame', getProperty('legsframerate.animation.curAnim.curFrame')) end
		setProperty('picolegs.animation.curAnim.curFrame', getProperty('legsframerate.animation.curAnim.curFrame'))
	end
end

function setLegAnims()
	addAnimationByPrefix('picolegs', 'idle', 'Símbolo 133', 24, true)
	addOffset('picolegs', 'idle', 0, 0)

	addAnimationByPrefix('picolegs', 'singLEFT', 'cleft', 24, true)
	addOffset('picolegs', 'singLEFT', 48, 18)

	addAnimationByPrefix('picolegs', 'singDOWN', 'cdown', 24, true)
	addOffset('picolegs', 'singDOWN', -2, -22)

	addAnimationByPrefix('picolegs', 'singUP', 'cupp', 24, true)
	addOffset('picolegs', 'singUP', 12, 58)

	addAnimationByPrefix('picolegs', 'singRIGHT', 'cright', 24, true)
	addOffset('picolegs', 'singRIGHT', 8, 14)

	playAnim('picolegs', 'idle', true)
end