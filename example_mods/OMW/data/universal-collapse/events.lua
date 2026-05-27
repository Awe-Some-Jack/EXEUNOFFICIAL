addCharacterToList('omw', 'dad')
addCharacterToList('omw2', 'dad')

function onCreatePost()
	setProperty('iconBF.alpha', 0)
	setProperty('iconOpp.alpha', 0)
	setProperty('hbHealth.alpha', 0)
	setProperty('hbHealth2.alpha', 0)
	setProperty('hbBG.alpha', 0)
	setProperty('separatorHealth.alpha', 0)
	setProperty('exeScoreTxt.alpha', 0)
	setProperty('healthBG.alpha', 0)

	callMethod('comboGroup.setPosition', {-500, 0})

	makeAnimatedLuaSprite('iconOMW', 'icons/omw-final')
	addAnimationByPrefix('iconOMW', 'normal', 'normal', 24, true)
	addAnimationByPrefix('iconOMW', 'losing', 'losing', 24, true)
    setObjectCamera('iconOMW', 'hud')
	addLuaSprite('iconOMW')
	setProperty('iconOMW.alpha', 0)
end

local oldAnim = 'normal'
function onUpdatePost()
	setProperty('iconOMW.x', getProperty('iconOpp.x') - 20)
    setProperty('iconOMW.y', getProperty('iconOpp.y') - 20)
	setProperty('iconOMW.scale.x', getProperty('iconOpp.scale.x') * 0.8)
    setProperty('iconOMW.scale.y', getProperty('iconOpp.scale.y') * 0.8)

	if oldAnim == 'normal' and getHealth() > 1.6 then
		playAnim('iconOMW', 'losing', true)
		oldAnim = 'losing'
	end
	if oldAnim == 'losing' and getHealth() <= 1.6 then
		playAnim('iconOMW', 'normal', true)
		oldAnim = 'normal'
	end
end

function onEvent(n,v1)
	if n == 'omwEvents' then
		if v1 == 'hudAppear' then
			doTweenAlpha('camHUD', 'camHUD', 1, crochet / (1000 / 6))
		end
		if v1 == 'fadeIn' then doTweenAlpha('asdads', 'blackScreen', 0, crochet / 250) end
		if v1 == 'removevideoxd' then
			if getProperty('videoCutscene') == nil then return end
    		callMethod('remove', {instanceArg('videoCutscene')})

			setProperty('camGame.alpha', 1)
			setProperty('blackScreen.alpha', 1)
		end
		if v1 == 'startPro' then
			cancelTween('asdads') setProperty('blackScreen.alpha', 0) setProperty('blackScreen.color', getColorFromHex('000000'))
			cancelTween('camHUD') setProperty('camHUD.alpha', 1)
			cameraFlash('hud', 'FFFFFF', 2, true)

			setProperty('sky.visible', true)
			setProperty('clouds.visible', true)
			setProperty('mountains.visible', true)
			setProperty('waterfall.visible', true)
			setProperty('fog2.visible', true)
			setProperty('trees2.visible', true)
			setProperty('trees.visible', true)
			setProperty('gradient.visible', true)

			removeLuaSprite('omwograd', true)
			triggerEvent('Change Character', 'dad', 'omw')
			removeSpriteShader('boyfriend')

			setProperty('iconBF.alpha', 1)
			setProperty('iconOpp.alpha', 1)
			setProperty('hbHealth.alpha', 1)
			setProperty('hbHealth2.alpha', 1)
			setProperty('hbBG.alpha', 1)
			setProperty('separatorHealth.alpha', 1)
			setProperty('exeScoreTxt.alpha', 1)
			setProperty('healthBG.alpha', 1)
			setProperty('ringCounter.alpha', 1)
			setProperty('ringTxt.alpha', 1)
			setProperty('strumLineRing.alpha', 1)
		end
		if v1 == 'startUniverse' then
			triggerEvent('Change Health Damage', '0.02', '')
			setHealth(1)

			setProperty('iconOMW.alpha', 1)
			setProperty('iconOpp.alpha', 0)
			setProperty('blackScreen.alpha', 1)
			doTweenColor('blackScreen', 'blackScreen', '000000', 1 / playbackRate)

			removeLuaSprite('sky', true)
			removeLuaSprite('clouds', true)
			removeLuaSprite('mountains', true)
			removeLuaSprite('waterfall', true)
			removeLuaSprite('fog2', true)
			removeLuaSprite('trees2', true)
			removeLuaSprite('trees', true)
			removeLuaSprite('gradient', true)

			setProperty('universe.visible', true)
			for i = 1,4 do setProperty('planet'..i..'.visible', true) end
			setProperty('piedra.visible', true)

			triggerEvent('Change Character', 'dad', 'omw2')

			setShaderFloat('cab', 'amount', 0.2)
			setShaderFloat('ca2', 'amount', 0.3)
		end
		if v1 == 'xddd' then
			runTimer('dxas', 2 / playbackRate)
			setProperty('cpuAssist', true)
			cancelTween('blackScreen') removeLuaSprite('blackScreen', true)
			cameraFlash('hud', 'FFFFFF', 1, true)
		end
	end
end

function onTimerCompleted(t)
	if t == 'dxas' then
		setProperty('cpuAssist', false)
	end
end