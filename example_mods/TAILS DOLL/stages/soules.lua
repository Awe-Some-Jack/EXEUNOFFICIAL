function onCreatePost()
	setProperty('boyfriend.alpha', 0)

	makeLuaSprite('bg', 'soullessbg/bg', -800, -500)
	addLuaSprite('bg')

	makeLuaSprite('sombra2', 'soullessbg/sombra2', -550)
	scaleObject('sombra2', 1.643, 1.643)
	setProperty('sombra2.alpha', 0.8)
	addLuaSprite('sombra2', true)

	makeLuaSprite('sombra', 'soullessbg/sombra', -550)
	scaleObject('sombra', 1.643, 1.643)
	addLuaSprite('sombra', true)
	setBlendMode('sombra', 'multiply')
end