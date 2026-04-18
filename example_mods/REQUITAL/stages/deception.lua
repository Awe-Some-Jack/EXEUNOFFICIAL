function onCreatePost()
	makeLuaSprite('bg2', 'bg/deception/bg-f 2')
	scaleObject('bg2', 2.5, 2.5)
	addLuaSprite('bg2')

	makeLuaSprite('bg', 'bg/deception/bg-g 2')
	scaleObject('bg', 2.5, 2.5)
	addLuaSprite('bg')

	makeLuaSprite('anto', 'bg/deception/anto,nt', 100, 375)
	scaleObject('anto', 1.5, 1.5)
	addLuaSprite('anto')

	makeLuaSprite('anto2', 'bg/deception/anto,nt 2', 1700, 210)
	scaleObject('anto2', 1.35, 1.35)
	addLuaSprite('anto2')

	makeLuaSprite('overly', 'bg/deception/deseption')
	scaleObject('overly', 2.5, 2.5)
	addLuaSprite('overly', true)

	makeAnimatedLuaSprite('lava', 'bg/lava')
	addAnimationByPrefix('lava', 'idle', 'Símbolo 17', 24, true)
	scaleObject('lava', 2.5, 2.5)
	addLuaSprite('lava', true)

	--RUNNING BG

	makeAnimatedLuaSprite('bgrun', 'bg/deception/laD', 70, 380)
	addAnimationByPrefix('bgrun', 'idle', 'bg', 24, true)
	scaleObject('bgrun', 1.2, 1.2)
	setProperty('bgrun.alpha', 0.0001)
	addLuaSprite('bgrun')

	--OTHER

	setProperty('gf.flipX', false)
	setScrollFactor('gf', 1, 1)
	setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup') + 1)

	addCharacterToList('beast-run', 'dad')
	addCharacterToList('pico-run', 'gf')
	addCharacterToList('bf-run', 'bf')

	setProperty('BlackGraphicOther.alpha', 1)
end

function onSongStart()
	doTweenAlpha('abexsda', 'BlackGraphicOther', 0.65, crochet / (1000 / 32), 'expoIn')
end

function onEvent(n,v1)
	if n == 'BGchange' then
		if v1 == 'intro' then
			cancelTween('abexsda')
			setProperty('BlackGraphicOther.alpha', 0)
		end
		if v1 == 'jajaja' then
			setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup') - 1)
			triggerEvent('Change Character', 'dad', 'beast-run')
			triggerEvent('Change Character', 'gf', 'pico-run')
			triggerEvent('Change Character', 'bf', 'bf-run')

			removeLuaSprite('bg2', true)
			removeLuaSprite('bg', true)
			removeLuaSprite('anto', true)
			removeLuaSprite('anto2', true)
			removeLuaSprite('overly', true)
			removeLuaSprite('lava', true)

			setProperty('bgrun.alpha', 1)

			callMethod('gf.setPosition', {getProperty('gf.x') - 350, getProperty('gf.y') - 80})
			callMethod('dad.setPosition', {getProperty('dad.x') - 950, getProperty('dad.y') + 520})

			setProperty('cameraSpeed', 2)
		end
	end
end