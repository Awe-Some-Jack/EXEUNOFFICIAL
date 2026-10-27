local currentScreamTag = 'JumpscareSound'

function onCreatePost()
	makeLuaSprite('jumpscare', 'tt/jump/Tails')
	setObjectCamera('jumpscare', 'other')
	addLuaSprite('jumpscare')
	scaleObject('jumpscare', 1.25, 1.25)
	screenCenter('jumpscare')
	setProperty('jumpscare.alpha', 0)
	setBlendMode('jumpscare', 'MULTIPLY')
end

function onEventPushed(name, value1, value2, strumTime)
    if name == 'Jumpscare' and flashingLights then
        local target = 'Tails'
        if value1 ~= '' and value1 ~= nil then 
            target = value1 
        end
        precacheSound(target..'Scream')
    end
end

function onEvent(n,v1)
	if n == 'Jumpscare' and flashingLights then
		local target = 'Tails'
		if v1 ~= '' then target = v1 end
		
		currentScreamTag = target..'ScreamTag'

		loadGraphic('jumpscare', 'tt/jump/'..target)
		playSound(target..'Scream', getRandomFloat(0.2, 0.25), currentScreamTag)
		scaleObject('jumpscare', 1.25, 1.25)
		screenCenter('jumpscare')
		cameraShake('game', 0.01, 0.30)
		setProperty('jumpscare.alpha', 1)
		doTweenAlpha('byebyeeee', 'jumpscare', 0, 0.5, 'cubeIn')
	end
end

function onPause() pauseSound(currentScreamTag) end

function onResume() resumeSound(currentScreamTag) end

function onDestroy() stopSound(currentScreamTag) end