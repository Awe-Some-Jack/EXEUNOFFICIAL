for i = 1,4 do precacheImage('final/flashbacks/flashback'..i) end
function onCreatePost()
	makeAnimatedLuaSprite('herewego', 'characters/herewego')
	addAnimationByPrefix('herewego', 'idle', 'herewego', 24, false)
	addLuaSprite('herewego', true)
	setProperty('herewego.visible', false)

	makeAnimatedLuaSprite('yuhbf', 'characters/bfyeahfe', screenWidth)
	addAnimationByPrefix('yuhbf', 'idle', 'yeah', 24, false)
	setObjectCamera('yuhbf', 'hud')
	screenCenter('yuhbf', 'y')
	addLuaSprite('yuhbf', true)
	setProperty('yuhbf.visible', false)

	makeAnimatedLuaSprite('uwga', 'characters/xenouwontgetfe')
	addAnimationByPrefix('uwga', 'idle', 'youwontgetaway', 25, false)
	setObjectCamera('uwga', 'video')
	scaleObject('uwga', 0.8, 0.8)
	screenCenter('uwga')
	addLuaSprite('uwga', true)
	setProperty('uwga.visible', false)

	makeAnimatedLuaSprite('comeherebitch', 'characters/xenowaterhellofe', 800, 450)
	addAnimationByPrefix('comeherebitch', 'idle', 'animationssssdasdads', 24, false)
	addLuaSprite('comeherebitch')
	setProperty('comeherebitch.visible', false)

	makeLuaSprite('water', nil, -500, 1200)
	makeGraphic('water', 3000, 1000, 'FF0000')
	addLuaSprite('water', true)
	setProperty('water.visible', false)

	makeLuaSprite('amecai', 'characters/bffallingfe')
	setProperty('amecai.visible', false)
	scaleObject('amecai', 0.6, 0.6)
	addLuaSprite('amecai', true)

	makeAnimatedLuaSprite('bfLol', 'characters/bf lol', 2000, 0)
	addAnimationByPrefix('bfLol', 'idle', 'Símbolo 23 instancia 1', 24, true)
	scaleObject('bfLol', 0.9, 0.9)
	setObjectCamera('bfLol', 'video')
	screenCenter('bfLol', 'y')
	setProperty('bfLol.visible', false)
	setProperty('bfLol.alpha', 0.7)
	addLuaSprite('bfLol')

	addCharacterToList('xeno-fe2', 'dad')
	addCharacterToList('bf-fe2', 'bf')
	addCharacterToList('xeno-fe3', 'dad')
	addCharacterToList('bf-fe3', 'bf')
	addCharacterToList('xeno-handfe', 'dad')
	addCharacterToList('bf-fe4', 'bf')
	addCharacterToList('bf-ferunning', 'bf')
	addCharacterToList('xeno-fegrand', 'dad')
	addCharacterToList('bf-fegrand', 'bf')
	addCharacterToList('bf-marionette', 'bf')
	addCharacterToList('xeno-fegrand-laugh', 'dad')


	makeLuaSprite('blackBehind', nil, -500, -100)
	makeGraphic('blackBehind', screenWidth * 2, screenHeight * 2, '000000')
	setObjectOrder('blackBehind', getObjectOrder('dadGroup'))
	addLuaSprite('blackBehind')

	setProperty('boyfriend.alpha', 0)
	setProperty('dad.alpha', 0)
	setProperty('dad.y', getProperty('dad.y') - 600)

	for _, hideShit in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hideShit..'.alpha', 0) end
	for i = 0, 3 do setProperty('opponentStrums.members['..i..'].x', -200)	setProperty('playerStrums.members['..i..'].alpha', 0) setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] + (downscroll and 50 or -50)) end
end

local lockZoom = false
local lockedZoomVal = 0.8
local waterSplashed = false
local floatBF = false
local floatBFTime = 0
local floatBFBaseY = 0

local separation = 50
local flashbackCounter = 0

function onEvent(n,v1,v2)
	if n == 'Change Character' and v1 == 'bf' and v2 == 'bf-water' then
		setProperty('boyfriend.alpha', 0)
	end
	if n == 'finalescapeEvent' then
		if v1 == "tweenObject" then
			local split = stringSplit(v2, ', ')
			doTweenAlpha(split[1]..'OP', split[1], split[2] / playbackRate, split[3])
		end
		if v1 == 'sexo' then
			for _, hideShit in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hideShit..'.alpha', 0) end
			for i = 0,3 do
				setProperty('playerStrums.members['..i..'].alpha', 0) setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] + (downscroll and 50 or -50))
				startTween('asexo'..i, 'playerStrums.members['..i..']', {y = _G['defaultPlayerStrumY'..i], alpha = 1}, crochet / (1000 / 8), {startDelay = (i / 2), ease = 'cubeOut'})
			end
		end
		if v1 == 'fuckYouVideo' then
			if getProperty('videoCutscene') == nil then return end
			callMethod('videoCutscene.destroy')
			callMethod('remove', {instanceArg('videoCutscene')})
			cameraFlash('other', 'FFFFFF', 1)
		end
		if v1 == 'tweenDad' then
			if v2 == '1' then doTweenY('dadYEUEHUTHETUI', 'dad', getProperty('dad.y') + 500, 1.4, 'smootherStepOut') end
			if v2 == '2' then doTweenY('dadYEUEHUTHETUI', 'dad', getProperty('dad.y') + 100, 3, 'smootherStepInOut') end
		end
		if v1 == 'startIntro' then
			for i = 0,3 do
				setProperty('opponentStrums.members['..i..'].x', -1000)
				setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
			end
			doTweenAlpha('asdadad', 'blackBehind', 0, crochet / (1000 / 8))
			doTweenAlpha('hehehehhe', 'boyfriend', 1, crochet / (1000 / 8))
			for _, hideShit in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hideShit..'.alpha', 0) end
		end
		if v1 == 'fadeNotes' then
			for i = 0,3 do
				setProperty('playerStrums.members['..i..'].alpha', 0) setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] + (downscroll and 50 or -50))
				startTween('asexo'..i, 'playerStrums.members['..i..']', {y = _G['defaultPlayerStrumY'..i], alpha = 1}, crochet / (1000 / 12), {startDelay = (i / 2), ease = 'cubeOut'})
			end
		end
		if v1 == 'hidewater' then
			doTweenAlpha('waterFade', 'water', 0, 1)
		end
		if v1 == 'middleNote' then
			for i = 0,3 do
				setProperty('opponentStrums.members['..i..'].alpha', 0)
				setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
			end
		end
		if v1 == 'bfwaterfadein' then
			for _, camZoomingShit in ipairs({'camZoomingMult', 'camZoomingDecay'}) do setProperty(camZoomingShit, 0) end
			doTweenAlpha('bfWaterFade', 'boyfriend', 1, 1.5 / playbackRate, 'sineOut')
			doTweenAlpha('bfWatedasrFade', 'bfbubbles', 1, 1.5 / playbackRate, 'sineOut')
			floatBFBaseY = getProperty('boyfriend.y')
			floatBF = true
			--doTweenZoom('bfWaterZoom', 'camGame', 0.9, 1.5 / playbackRate, 'sineOut')
			triggerEvent('Tweening Camera', '450,750', '1.5,sineOut')
			setProperty('defaultCamZoom', 0.9)
			lockZoom = true

			removeLuaSprite('amecai', true) removeLuaSprite('water', true)
			removeLuaSprite('groundFourthSection', true)
			cancelTimer('AJAJAJ') cancelTimer('AJAJAJ2') cancelTimer('xdasdddd')
		end
		if v1 == 'evillaugh' then
			playAnim('comeherebitch', 'idle', true)
			setProperty('comeherebitch.visible', true)
			setProperty('comeherebitch.alpha', 0)
			doTweenAlpha('comeherebitch', 'comeherebitch', 1, 3, 'expoIn')
		end
		if v1 == 'showbflol' then
			setProperty('bfLol.visible', true)
			doTweenX('bfLolSlide', 'bfLol', 700, 2 / playbackRate, 'cubeOut')
		end
		if v1 == 'endwatersection' then
			cancelTween('bfLolSlide')
			doTweenX('bfLolSlide', 'bfLol', 2000, 6 / playbackRate, 'cubeIn')
			doTweenColor('bfbubdasdadsdbles', 'bfbubbles', 'FF7777', (crochet / (1000 / 17)) / playbackRate, 'sineIn')
			doTweenColor('boyfriedasdafdnd', 'boyfriend', 'FF7777', (crochet / (1000 / 17)) / playbackRate, 'sineIn')
			doTweenColor('boyfrienddasdasd', 'bfLol', 'FF7777', (crochet / (1000 / 17)) / playbackRate, 'sineIn')
		end
		if v1 == 'flackback' then
			flashbackCounter = flashbackCounter + 1

			makeLuaSprite('flashback'..flashbackCounter, 'final/flashbacks/'..flashbackCounter)
			setObjectCamera('flashback'..flashbackCounter, 'video')
			scaleObject('flashback'..flashbackCounter, 0.7, 0.7)
			screenCenter('flashback'..flashbackCounter, 'y')
			addLuaSprite('flashback'..flashbackCounter)
			setProperty('flashback'..flashbackCounter..'.alpha', 0)
			doTweenX('flashbackx'..flashbackCounter, 'flashback'..flashbackCounter, 50, 1, 'cubeOut')
			doTweenAlpha('flashbacka'..flashbackCounter, 'flashback'..flashbackCounter, 0.7, 1, 'cubeOut')
		end
		if v1 == 'hideintro' then
			for _, e in ipairs({'sky', 'lightning', 'cloudsbg', 'clouds2', 'clouds1', 'objects3', 'objects2', 'objects1', 'lake', 'ground', 'yuhbf'}) do
				removeLuaSprite(e, true)
			end
		end
		if v1 == 'herewego' then
			playAnim('herewego', 'idle', true)
			setProperty('herewego.visible', true)
			setProperty('herewego.x', getProperty('dad.x')) setProperty('herewego.y', getProperty('dad.y') - 70)
		end
		if v1 == 'yeahbf' then
			doTweenX('yuhbfxd', 'yuhbf', (screenWidth - getProperty('yuhbf.width')) / 2, 0.2 / playbackRate, 'cubeOut')
			playAnim('yuhbf', 'idle', true)
			setProperty('yuhbf.visible', true)
		end
		if v1 == 'startsecondsection' then
			cancelTween('asdadad')
			cancelTween('dadOP')
			cancelTween('hehehehhe')
			setProperty('boyfriend.alpha', 1)
			setProperty('blackBehind.alpha', 0)
			setProperty('dad.alpha', 1)
			for _, showShit in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do doTweenAlpha(showShit..'Alpha', showShit, 1, 1) end

			for i = 0,7 do noteTweenX('notesX'..i, i, _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)], 1.6 + ((i + 1) / 4), 'backOut') end
			setProperty('cameraSpeed', 9999) runTimer('xddasdas', 0.1 / playbackRate)
			cameraFlash('game', 'FFFFFF', 1.2 / playbackRate, true)
			removeLuaSprite('herewego', true)
			removeLuaSprite('yuhbf', true)

			for _, e in ipairs({'bgFirstSection', 'groundFirstSection', 'dirt', 's', 'o', 'n', 'i', 'c', 'sega666', 'sega', 'farol', 'eggshit', 'vida', 'rock'}) do
				setProperty(e..'.alpha', 1)
			end

			setProperty('groundSecondSection.alpha', 0)

			triggerEvent('Change Character', 'dad', 'xeno-fe2')
			triggerEvent('Change Character', 'bf', 'bf-fe2')

			callMethod('dad.setPosition', {getProperty('dad.x') - 500, getProperty('dad.y') - 160})
			callMethod('boyfriend.setPosition', {getProperty('boyfriend.x'), getProperty('boyfriend.y') - 210})
		end
		if v1 == 'startthirdsection' then
			setProperty('cameraSpeed', 9999) runTimer('xddasdas', 0.1 / playbackRate)
			cameraFlash('game', 'FFFFFF', 1.2 / playbackRate, true)
			for _, e in ipairs({ 'groundFirstSection', 'dirt', 's', 'o', 'n', 'i', 'c', 'sega666', 'sega', 'farol', 'eggshit', 'vida', 'rock'}) do
				setProperty(e..'.visible', false)
			end
			setProperty('groundSecondSection.alpha', 1)

			triggerEvent('Change Character', 'dad', 'xeno-fe3')
			triggerEvent('Change Character', 'bf', 'bf-fe3')

			callMethod('dad.setPosition', {getProperty('dad.x') - 20, getProperty('dad.y') - 150})
			callMethod('boyfriend.setPosition', {getProperty('boyfriend.x') + 280, getProperty('boyfriend.y') - 190})
		end
		if v1 == 'backsecondsection' then
			setProperty('cameraSpeed', 9999) runTimer('xddasdas', 0.1 / playbackRate)
			removeLuaSprite('herewego', true)
			removeLuaSprite('yuhbf', true)

			for _, e in ipairs({'bgFirstSection', 'groundFirstSection', 'dirt', 's', 'o', 'n', 'i', 'c', 'sega666', 'sega', 'farol', 'eggshit', 'vida', 'rock'}) do
				setProperty(e..'.visible', true)
			end

			setProperty('groundSecondSection.alpha', 0)

			triggerEvent('Change Character', 'dad', 'xeno-fe2')
			triggerEvent('Change Character', 'bf', 'bf-fe2')

			--callMethod('dad.setPosition', {getProperty('dad.x'), getProperty('dad.y') + 350})
			--callMethod('boyfriend.setPosition', {getProperty('boyfriend.x') - 220, getProperty('boyfriend.y') + 190})
		end
		if v1 == 'startfourthsection' then
			setProperty('cameraSpeed', 9999) runTimer('xddasdas', 0.1 / playbackRate)
			cameraFlash('game', 'FFFFFF', 1.2 / playbackRate, true)

			setProperty('groundThirdSection.alpha', 1)

			triggerEvent('Change Character', 'dad', 'xeno-handfe')
			triggerEvent('Change Character', 'bf', 'bf-fe4')

			callMethod('dad.setPosition', {getProperty('dad.x') - 950, getProperty('dad.y') - 350})
			callMethod('boyfriend.setPosition', {getProperty('boyfriend.x'), getProperty('boyfriend.y') - 190})

			setProperty('bgFirstSection.x', getProperty('bgFirstSection.x') - 1000)
			setProperty('bgFirstSection.y', getProperty('bgFirstSection.y') + 200)

			doTweenX('XenoXComingSlowly', 'dad', getProperty('dad.x') + 650, 20 / playbackRate)
			doTweenY('XenoYComingSlowly', 'dad', getProperty('dad.y') + 350, 20 / playbackRate)
		end
		if v1 == 'startingrun' then
			doTweenAlpha('BlackGraphicGame', 'BlackGraphicGame', 1, 2)
		end
		if v1 == 'startfifthsection' then
			for i = 0,3 do setProperty('opponentStrums.members['..i..'].alpha', 0) end
			for _, hideShit in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hideShit..'.alpha', 0) end
			for _, e in ipairs({'s', 'o', 'n', 'i', 'c', 'bgFirstSection', 'groundFirstSection', 'groundThirdSection', 'vida', 'eggshit', 'sega', 'farol', 'rock', 'sega666', 'dirt'}) do setProperty(e..'.visible', false) end
			cancelTween('BlackGraphicGame')
			setProperty('BlackGraphicGame.alpha', 0)

			setProperty('dad.alpha', 0)
			setProperty('groundFourthSection.alpha', 1)
			setProperty('bgLoop.alpha', 1)

			triggerEvent('Change Character', 'bf', 'bf-ferunning')
			playAnim('boyfriend', 'RUN', true)

			callMethod('bgFirstSection.setPostiion', {getProperty('bgFirstSection.x') + 1000, getProperty('bgFirstSection.y') - 200})
			callMethod('boyfriend.setPosition', {getProperty('boyfriend.x') - 600, getProperty('boyfriend.y') - 900})
		end

		if v1 == 'wontgetaway' then
			setProperty('bgFirstSection.visible', true)
			setProperty('camHUD.visible', false)
			setProperty('boyfriend.visible', false)
			setProperty('groundFourthSection.alpha', 0)
			setProperty('bgLoop.alpha', 0)
			setProperty('uwga.visible', true)
			playAnim('uwga', 'idle', true)
		end
		if v1 == 'wontgetaway2' then
			setProperty('camHUD.visible', true)
			setProperty('bgFirstSection.visible', false)
			setProperty('boyfriend.visible', true)
			cameraFlash('game', 'FFFFFF', 1.2 / playbackRate, true)
			setProperty('groundFourthSection.alpha', 1)
			setProperty('bgLoop.alpha', 1)
			removeLuaSprite('uwga', true)
		end
		if v1 == 'waterxd' then
			runTimer('AJAJAJ', crochet / 500)
			runTimer('AJAJAJ2', crochet / (1000 / 6))
			runTimer('xdasdddd', crochet / (1000 / 12))
		end

		if v1 == 'grandxenopart' then
			lockZoom = false
			floatBF = false
			setProperty('boyfriend.alpha', 1)
			setProperty('cameraSpeed', 9999) runTimer('xddasdas', 0.1 / playbackRate)
			for _, camZoomingShit in ipairs({'camZoomingMult', 'camZoomingDecay'}) do setProperty(camZoomingShit, 1) end
			cameraFlash('game', 'FFFFFF', 1.2 / playbackRate, true)
			removeLuaSprite('comeherebitch', true)
			setProperty('dad.alpha', 1)
			cancelTween('boyfriedasdafdnd')
			triggerEvent('Change Character', 'dad', 'xeno-fegrand')
			triggerEvent('Change Character', 'bf', 'bf-fegrand')

			removeLuaSprite('bfLol', true)

			for i = 1,4 do removeLuaSprite('flashback'..i, true) end

			for i = 0,3 do setProperty('opponentStrums.members['..i..'].alpha', 1) end
			for i = 0,7 do noteTweenX('notesX'..i, i, _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)], 0.5 + ((i + 1) / 12), 'backOut') end
		end

		if v1 == 'startsixthsection' then
			cancelTween('camHUDOP')
			setProperty('camHUD.alpha', 1)
			setProperty('cameraSpeed', 9999) runTimer('xddasdas', 0.1 / playbackRate)
			for _, showThisidk in ipairs({'idkLoop', 'spikeDownLoop', 'spikeUpLoop'}) do setProperty(showThisidk..'.alpha', 1) end

			triggerEvent('Change Character', 'bf', 'bf-marionette')
			setProperty('boyfriend.alpha', 1)
			setProperty('boyfriend.y', getProperty('boyfriend.y') - 120)
			setProperty('dad.visible', false)
		end

		if v1 == 'this is so much fun yo' then
			for _, loopShit in ipairs({'idkLoop', 'spikeDownLoop', 'spikeUpLoop'}) do setProperty(loopShit..'.alpha', 0) end
			triggerEvent('Change Character', 'dad', 'xeno-fegrand-laugh')
			triggerEvent('Change Character', 'bf', 'bf-fegrand')
			playAnim('dad', 'idle', true)
			setProperty('dad.visible', true)

			callMethod('dad.setPosition', {getProperty('dad.x') + 200, getProperty('dad.y') + 300})
			setProperty('dad.y', getProperty('dad.y') + 600)
		end
	end
end

luaDebugMode = true
function onTweenCompleted(t)
	if stringStartsWith(t, 'flashbackx') then
		local daflash = t:gsub('flashbackx', '')
		doTweenY('flashbacky'..daflash, 'flashback'..daflash, getProperty('flashback'..daflash..'.y') - 50, 1, 'cubeIn')
		doTweenAlpha('flashbacka'..daflash, 'flashback'..daflash, 0, 1, 'cubeIn')
	end
end

function onTimerCompleted(t, loops, left)
	if t == 'AJAJAJ' then
		setProperty('amecai.visible', true)
		setProperty('water.visible', true)
		setProperty('amecai.color', getColorFromHex('000000'))
		setProperty('amecai.y', -800)
		setProperty('amecai.x', 1000)
		setProperty('amecai.angle', -120)
		setProperty('amecai.angularVelocity', 100)
		setProperty('amecai.velocity.y', 1500)
		doTweenY('camHUD', 'camHUD', -770, 1, 'cubeInOut')
		triggerEvent('Tweening Camera', '400,1100', '0.3,cubeOut')
		doTweenZoom('waterZoom', 'camGame', 0.5, 3, 'cubeOut')
		setProperty('defaultCamZoom', 0.5)

		setProperty('whiteout.alpha', 1)
		doTweenY('whiteoutFade', 'whiteout', 200, 1.5 / playbackRate, 'expoOut')
		setProperty('bgLoop.velocity.x', 0)
	end
	if t == 'AJAJAJ2' then
		removeLuaSprite('groundFourthSection', true)
		setProperty('amecai.color', getColorFromHex('00FFFF'))
		setProperty('amecai.velocity.y', 100)
		setProperty('amecai.acceleration.y', 1000)
	end
	if t == 'xdasdddd' then
		for i = 0,7 do cancelTween('notesX'..i) end
		for i = 0,3 do
			setProperty('opponentStrums.members['..i..'].x', -1000)
			setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
		end

		removeLuaSprite('whiteout', true)
		setProperty('camHUD.y', 0) setProperty('camHUD.alpha', 0)
	end
	if t == 'xddasdas' then setProperty('cameraSpeed', 1) end
end

function onUpdatePost(elapsed)
	if boyfriendName == 'bf-ferunning' and getProperty('boyfriend.animation.curAnim.curFrame') == 13 then
		doTweenX('boyfriendRUNX', 'boyfriend', getProperty('bf.x') - 450, 0.4)
	end

	if boyfriendName == 'bf-ferunning' and getProperty('boyfriend.animation.curAnim.curFrame') == 19 then
		doTweenX('boyfriendRUNX', 'boyfriend', getProperty('bf.x') + 450, 0.9, 'circOut')
	end
end

function onUpdate()
	if lockZoom then
		setProperty('defaultCamZoom', lockedZoomVal)
	end
end

function onUpdatePost(elapsed)
	if floatBF then
		floatBFTime = floatBFTime + elapsed
		setProperty('boyfriend.y', floatBFBaseY + math.sin(floatBFTime * 1.2) * 18)
	end
	if not waterSplashed and getProperty('water.visible') then
		local amecaiBottom = getProperty('amecai.y') + getProperty('amecai.height')
		local waterTop = getProperty('water.y')
		if amecaiBottom >= waterTop then
			waterSplashed = true
			local newY = getProperty('water.y') - 900
			doTweenY('waterRise', 'water', newY, 1.5, 'sineOut')
			doTweenY('waterScaleY', 'water.scale', 2.5, 1.5, 'sineOut')
		end
	end
end

function doTweenScale(tag, obj, target, time, ease)
	doTweenX(tag..'scaleX', obj..'.scale', target, time, ease)
	doTweenY(tag..'scaleY', obj..'.scale', target, time, ease)
end

