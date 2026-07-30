function onCreatePost()
    makeAnimatedLuaSprite('tentacles_black', 'black sun/tentacles')
	addAnimationByPrefix('tentacles_black', 'idle', 'Símbolo', 24, true)
	setObjectCamera('tentacles_black', 'other')
	scaleObject('tentacles_black', 0.7, 0.7)
	screenCenter('tentacles_black')
	addLuaSprite('tentacles_black', true)

	makeLuaSprite('BlackVG', 'VG')
    setProperty('BlackVG.color', getColorFromHex('000000'))
	setObjectCamera('BlackVG', 'other')
	addLuaSprite('BlackVG', true)
end

function onUpdatePost(e)
    setProperty('BlackVG.alpha', 1.2 - getHealth() / 2)
	setProperty('tentacles_black.alpha', 1.2 - getHealth() / 2)
end