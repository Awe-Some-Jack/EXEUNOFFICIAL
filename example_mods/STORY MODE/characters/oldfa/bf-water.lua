function onCreatePost()
	makeAnimatedLuaSprite('bfbubbles', 'characters/bfbubsfe', getProperty('boyfriend.x') + 20, getProperty('boyfriend.y') + 70)
	addAnimationByPrefix('bfbubbles', 'idle', 'Símbolo 184', 24, true)
	addLuaSprite('bfbubbles', true)
	setProperty('bfbubbles.alpha', 0)
	setObjectOrder('bfbubbles', getObjectOrder('boyfriendGroup') + 1)
	setProperty('bfbubbles.visible', boyfriendName == 'bf-water')
end

function onEvent(n)
	if n == 'Change Character' then
		setProperty('bfbubbles.visible', boyfriendName == 'bf-water')
	end
end

function onUpdatePost(e)
	callMethod('bfbubbles.setPosition', {getProperty('boyfriend.x') - 90, getProperty('boyfriend.y') - 60})
end