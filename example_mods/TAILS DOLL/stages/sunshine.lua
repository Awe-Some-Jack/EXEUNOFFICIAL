function onCreatePost()
	makeLuaSprite('floor', 'bg/floortile', -2800, -750)
	addLuaSprite('floor')
	scaleObject('floor', 2.5, 2)
	setPerspective('floor', 0.75)
	setVanishOffset('floor', 0, -100)

	makeLuaSprite('gradient2', 'bg/jejajas', -800, 400)
	setScrollFactor('gradient2', 0.3, 0.3)
	addLuaSprite('gradient2')
	scaleObject('gradient2', 3, 1)

	makeLuaSprite('gradient', 'bg/gradient', -800, -750)
	addLuaSprite('gradient')
	scaleObject('gradient', 3, 1.62)
	setProperty('gradient.alpha', 0.6)
	setBlendMode('gradient', 'screen')
	setPerspective('gradient', 0.7)
	setVanishOffset('gradient', 0, -100)

	setScrollFactor('boyfriend', 0.5, 0.5)
	setScrollFactor('dad', 0.7, 0.7)

	--setPerspective("ffth_scoreTxt", 0.4)
	--setVanishOffset('ffth_scoreTxt', 1020, 600 - (downscroll and 460 or 0))
end