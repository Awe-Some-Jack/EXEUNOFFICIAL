function onCreatePost()
	makeAnimatedLuaSprite('backlegs', 'characters/bfsecondfe-backshoes', getProperty('boyfriend.x') + 5, getProperty('boyfriend.y') + 105)
	addAnimationByPrefix('backlegs', 'idle', 'Símbolo 103', 24, true)
	addLuaSprite('backlegs', true)
	setObjectOrder('backlegs', getObjectOrder('boyfriendGroup'))

	makeAnimatedLuaSprite('frontlegs', 'characters/bfsecondfe-frontshoes', getProperty('boyfriend.x') + 36, getProperty('boyfriend.y') + 118)
	addAnimationByPrefix('frontlegs', 'idle', 'Símbolo 102', 24, true)
	addLuaSprite('frontlegs', true)
	setObjectOrder('frontlegs', getObjectOrder('boyfriendGroup') + 1)

	setProperty('frontlegs.visible', boyfriendName == 'bf-fe2')
	setProperty('backlegs.visible', boyfriendName == 'bf-fe2')
end

function onEvent(n)
	if n == 'Change Character' then
		setProperty('frontlegs.visible', boyfriendName == 'bf-fe2')
		setProperty('backlegs.visible', boyfriendName == 'bf-fe2')
	end
end

function onUpdatePost(e)
	callMethod('backlegs.setPosition', {getProperty('boyfriend.x') + 5, getProperty('boyfriend.y') + 105})
	callMethod('frontlegs.setPosition', {getProperty('boyfriend.x') + 36, getProperty('boyfriend.y') + 118})

	if getProperty('boyfriend.animation.curAnim.name') == 'idle' and boyfriendName == 'bf-fe2' then
		setProperty('boyfriend.animation.curAnim.curFrame', getProperty('frontlegs.animation.curAnim.curFrame'))
	end
end