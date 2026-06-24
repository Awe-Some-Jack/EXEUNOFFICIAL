function onCreatePost()
	makeAnimatedLuaSprite('frontlegs2', 'characters/bfthirdfe-legs', getProperty('boyfriend.x') + 20, getProperty('boyfriend.y') + 70)
	addAnimationByPrefix('frontlegs2', 'idle', 'Símbolo 134', 24, true)
	addLuaSprite('frontlegs2', true)

	setProperty('frontlegs2.visible', boyfriendName == 'bf-fe3')
end

function onEvent(n)
	if n == 'Change Character' then
		setProperty('frontlegs2.visible', boyfriendName == 'bf-fe3')
	end
end

function onUpdatePost(e)
	callMethod('frontlegs2.setPosition', {getProperty('boyfriend.x') + 1, getProperty('boyfriend.y') + 103})
	callMethod('frontlegs2.scale.set', {getProperty('boyfriend.scale.x') - 0.05, getProperty('boyfriend.scale.y') - 0.05})

	if getProperty('boyfriend.animation.curAnim.name') == 'idle' and boyfriendName == 'bf-fe3' then
		setProperty('boyfriend.animation.curAnim.curFrame', getProperty('frontlegs2.animation.curAnim.curFrame'))
	end
end