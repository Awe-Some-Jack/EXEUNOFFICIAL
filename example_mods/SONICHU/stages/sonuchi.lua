function onCreatePost()
	makeLuaSprite('sky', 'bg/4', -1200, -650)
	setScrollFactor('sky', 0.7, 0.7)
	addLuaSprite('sky')

	createInstance('clouds', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('clouds', 'bg/3')
	setScrollFactor('clouds', 0.7, 0.7)
	setProperty('clouds.y', -600)
	setProperty('clouds.velocity.x', 15)
	addInstance('clouds')

	makeLuaSprite('ground', 'bg/2', -1400, -750)
	addLuaSprite('ground')

	makeLuaSprite('fore', 'bg/1', -1550, -800)
	setScrollFactor('fore', 1.2, 1.2)
	addLuaSprite('fore')
end