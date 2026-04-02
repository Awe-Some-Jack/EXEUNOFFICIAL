function onCreatePost()
	makeAnimatedLuaSprite('legsframeratebeast', 'characters/deception/pielnas')
	addAnimationByPrefix('legsframeratebeast', 'idle', 'Símbolo 4', 24, true)
	addLuaSprite('legsframeratebeast')
	setProperty('legsframeratebeast.visible', false)

	makeAnimatedLuaSprite('beastlegs', 'characters/deception/pielnas')
	setLegAnims()
	addLuaSprite('beastlegs', true)
	setObjectOrder('beastlegs', getObjectOrder('dadGroup'))
	setProperty('beastlegs.visible', dadName == 'beast-run')
	scaleObject('beastlegs', getProperty('dad.scale.x'), getProperty('dad.scale.y'), false)
end

function onEvent(n)
	if n == 'Change Character' then
		setProperty('beastlegs.visible', dadName == 'beast-run')
		scaleObject('beastlegs', getProperty('dad.scale.x'), getProperty('dad.scale.y'), false)
	end
end

function onUpdatePost(e)
	if dadName == 'beast-run' then
		callMethod('beastlegs.setPosition', {getProperty('dad.x') + 70, getProperty('dad.y') - 75})

		if getProperty('beastlegs.animation.curAnim.name') ~= getProperty('dad.animation.curAnim.name') then playAnim('beastlegs', getProperty('dad.animation.curAnim.name'), true) end

		setProperty('beastlegs.animation.curAnim.curFrame', getProperty('legsframeratebeast.animation.curAnim.curFrame'))
		setProperty('dad.animation.curAnim.curFrame', getProperty('legsframeratebeast.animation.curAnim.curFrame'))
	end
end

function setLegAnims()
	addAnimationByPrefix('beastlegs', 'idle', 'Símbolo 4', 24, true)
	addOffset('beastlegs', 'idle', 0, 0)

	addAnimationByPrefix('beastlegs', 'singLEFT', 'cleft', 24, true)
	addOffset('beastlegs', 'singLEFT', 3, 1)

	addAnimationByPrefix('beastlegs', 'singDOWN', 'cdown', 24, true)
	addOffset('beastlegs', 'singDOWN', 0, -10)

	addAnimationByPrefix('beastlegs', 'singUP', 'cup', 24, true)
	addOffset('beastlegs', 'singUP', 1, 22)

	addAnimationByPrefix('beastlegs', 'singRIGHT', 'cright', 24, true)
	addOffset('beastlegs', 'singRIGHT', 0, 1)

	playAnim('beastlegs', 'idle', true)
end