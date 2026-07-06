function onCreatePost()
	createInstance('bg', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -200})
	loadGraphic('bg', 'gottago/bg')
	scaleObject('bg', 0.9, 0.9)
	setProperty('bg.y', -600)
	setProperty('bg.antialiasing', false)
	setProperty('bg.velocity.x', -2500)
	addInstance('bg')

	makeLuaSprite('ring', 'gottago/ring', -1090, -500)
	scaleObject('ring', 0.3, 0.3)
	addLuaSprite('ring')

	setProperty('boyfriend.alpha', 0)
	setObjectOrder('dadGroup', getObjectOrder('boyfriendGroup') + 1)
	setObjectOrder('boyfriendGroup', getObjectOrder('dadGroup') + 1)
end