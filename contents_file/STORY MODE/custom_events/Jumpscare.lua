function onCreatePost()
	makeLuaSprite('jumpscare', 'tt/jump/Tails')
	setObjectCamera('jumpscare', 'other')
	addLuaSprite('jumpscare')
	scaleObject('jumpscare', 1.25, 1.25)
	screenCenter('jumpscare')
	setProperty('jumpscare.alpha', 0)
	setBlendMode('jumpscare', 'MULTIPLY')
end

function onEvent(n,v1)
	if n == 'Jumpscare' and flashingLights then
		target = 'Tails'
		if v1 ~= '' then target = v1 end
		loadGraphic('jumpscare', 'tt/jump/'..target)
		playSound(target..'Scream', getRandomFloat(0.2, 0.25))
		scaleObject('jumpscare', 1.25, 1.25)
		screenCenter('jumpscare')
		cameraShake('game', 0.01, 0.30)
		setProperty('jumpscare.alpha', 1)
		doTweenAlpha('byebyeeee', 'jumpscare', 0, 0.5, 'cubeIn')
	end
end