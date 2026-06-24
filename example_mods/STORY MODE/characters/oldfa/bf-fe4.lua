function onCreatePost()
	makeAnimatedLuaSprite('frontlegs4', 'characters/bffourthfe-legs', getProperty('boyfriend.x') + 20, getProperty('boyfriend.y') + 70)
	addAnimationByPrefix('frontlegs4', 'idle', 'Símbolo 90', 24, true)
	addLuaSprite('frontlegs4', true)
	setObjectOrder('frontlegs4', getObjectOrder('boyfriendGroup'))
	setProperty('frontlegs4.visible', boyfriendName == 'bf-fe4')
end

function onEvent(n)
	if n == 'Change Character' then
		setProperty('frontlegs4.visible', boyfriendName == 'bf-fe4')
	end
end

function onUpdatePost(e)
	callMethod('frontlegs4.setPosition', {getProperty('boyfriend.x') - 5, getProperty('boyfriend.y') + 5})
	callMethod('frontlegs4.scale.set', {getProperty('boyfriend.scale.x') - 0.05, getProperty('boyfriend.scale.y') - 0.05})

	if getProperty('boyfriend.animation.curAnim.name') == 'idle' and boyfriendName == 'bf-fe4' then
		setProperty('boyfriend.animation.curAnim.curFrame', getProperty('frontlegs4.animation.curAnim.curFrame'))
	end
end