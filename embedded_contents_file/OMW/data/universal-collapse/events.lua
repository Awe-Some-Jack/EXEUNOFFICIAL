addCharacterToList('omw', 'dad')
addCharacterToList('omw2', 'dad')

function onCreatePost()
	callMethod('comboGroup.setPosition', {500, 0})

	makeAnimatedLuaSprite('iconOMW', 'icons/omw-final')
	addAnimationByPrefix('iconOMW', 'normal', 'normal', 24, true)
	addAnimationByPrefix('iconOMW', 'losing', 'losing', 24, true)
    setObjectCamera('iconOMW', 'hud')
end


local oldAnim = 'normal'
function onUpdatePost()
	if getProperty('glassbreak.animation.curAnim.name') == 'idle2' and getProperty('glassbreak.animation.curAnim.finished') then removeLuaSprite('glassbreak', true) end

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
		if v1 == 'fadeIn' then doTweenAlpha('asdads', 'blackScreen', 0, crochet / 250) end
		if v1 == 'hudAppear' then
			doTweenAlpha('camHUD', 'camHUD', 1, crochet / (1000 / 6))
		end
		if v1 == 'removevideoxd' then
    		callMethod('remove', {instanceArg('videoCutscene')})
			cancelTween('asdads')
		end
		if v1 == 'glassbreaking' then
			playAnim('glassbreak', 'idle', true)
			setProperty('glassbreak.alpha', 1)
		end
		if v1 == 'startPro' then
			setProperty('camGame.alpha', 1)
			screenCenter('glassbreak')
			callMethod('glassbreak.setPosition', {getProperty('glassbreak.x') - 150, getProperty('glassbreak.y') - 30})
			playAnim('glassbreak', 'idle2', true)

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

			setProperty('iconBF.alpha', 1)
			setProperty('iconOpp.alpha', 1)
			setProperty('hbHealth.alpha', 1)
			setProperty('hbHealth2.alpha', 1)
			setProperty('separatorHealth.alpha', 1)
			setProperty('healthbaromw.alpha', 1)
			setProperty('ringCounter.alpha', 1)
			setProperty('ringTxt.alpha', 1)
			setProperty('strumLineRing.alpha', 1)
		end
		if v1 == 'startUniverse' then
			local separation = 50
			for i = 0,3 do
				setProperty('opponentStrums.members['..i..'].x', -1000)
				setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
			end
			callMethod('comboGroup.setPosition', {0, 0})

			triggerEvent('Change Health Damage', '0.02', '')

			addLuaSprite('iconOMW')
			setProperty('iconOpp.alpha', 0)
			setProperty('blackScreen.alpha', 1)
			doTweenColor('blackScreen', 'blackScreen', '000000', 1 / playbackRate)

			removeLuaSprite('sky', true) removeLuaSprite('skyN', true)
			removeLuaSprite('clouds', true) removeLuaSprite('cloudsN', true)
			removeLuaSprite('mountains', true) removeLuaSprite('mountainsN', true)
			removeLuaSprite('waterfall', true) removeLuaSprite('waterfallN', true)
			removeLuaSprite('fog2', true) removeLuaSprite('fog2N', true)
			removeLuaSprite('trees2', true) removeLuaSprite('trees2N', true)
			removeLuaSprite('trees', true) removeLuaSprite('treesN', true)
			removeLuaSprite('gradient', true)

			setProperty('universe.visible', true)
			for i = 1,4 do setProperty('planet'..i..'.visible', true) end
			setProperty('piedra.visible', true)
			setProperty('omwbody.visible', true)

			setProperty('cameraSpeed', 2)
			triggerEvent('Change Character', 'dad', 'omw2')
			setProperty('dad.x', getProperty('dad.x') - 10)
			triggerEvent('Change Character', 'bf', 'bfs')
			setProperty('gameplayCam.settings.BFy', 100)

			setShaderFloat('cab', 'amount', 0.2)
			setShaderFloat('ca2', 'amount', 0.3)
		end
		if v1 == 'xddd' then
			runTimer('dxas', 2 / playbackRate)
			setProperty('cpuAssist', true)
			cancelTween('blackScreen') removeLuaSprite('blackScreen', true)
			cameraFlash('hud', 'FFFFFF', 1, true)
		end
		if v1 == 'finalFlash' then
			setProperty('cpuAssist', true)
			setProperty('camGame.alpha', 0)
			setProperty('camHUD.alpha', 0)
			makeLuaSprite('renderfinale', 'universal-collapse/final')
			setGraphicSize('renderfinale', screenWidth, screenHeight)
			screenCenter('renderfinale')
			setObjectCamera('renderfinale', 'video')
			addLuaSprite('renderfinale')
			runTimer('XDDD', 0.05)
		end
	end
end

function onTimerCompleted(t)
	if t == 'dxas' then
		setProperty('cpuAssist', false)
	end
	if t == 'XDDD' then cameraFlash('other', 'FFFFFF', crochet / 250, true) removeLuaSprite('renderfinale', true) end
end