function onCreatePost()
	makeLuaSprite('xeno2ring', 'characters/FINAL-ESCAPE-HD', getProperty('dad.x'), getProperty('dad.y'))
	addLuaSprite('xeno2ring')

	setProperty('xeno2ring.visible', dadName == 'xeno-fe2')
end

function onEvent(n)
	if n == 'Change Character' then
		setObjectOrder('xeno2ring', getObjectOrder('groundFirstSection') - 1)
		setProperty('xeno2ring.visible', dadName == 'xeno-fe2')
	end
end

function onUpdatePost(e)
	callMethod('xeno2ring.setPosition', {getProperty('dad.x') - 460, getProperty('dad.y') - 100})
end