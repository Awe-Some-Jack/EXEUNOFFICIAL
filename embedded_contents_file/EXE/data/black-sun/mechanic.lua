function onCreatePost()
	makeAnimatedLuaSprite('tentacles_black', 'black sun/tentacles')
	addAnimationByPrefix('tentacles_black', 'idle', 'Símbolo', 24, true)
	setObjectCamera('tentacles_black', 'hud')
	scaleObject('tentacles_black', 0.7, 0.7)
	screenCenter('tentacles_black')
	addLuaSprite('tentacles_black', true)

	makeLuaSprite('BlackVG', 'VG')
	setProperty('BlackVG.color', getColorFromHex('000000'))
	setObjectCamera('BlackVG', 'hud')
	addLuaSprite('BlackVG', true)

	setProperty('healthGain', 0)
	setHealth(2)
end

function onUpdatePost(e)
	setProperty('BlackVG.alpha', 0.9 - getHealth() / 2)
	setProperty('tentacles_black.alpha', 0.9 - getHealth() / 2)

	addHealth(-0.007 * e)
end