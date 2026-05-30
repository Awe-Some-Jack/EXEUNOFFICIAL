local oppFloat = false
local dadX, dadY = -666, 104
local floatTime = 0

function onCreatePost()
	makeAnimatedLuaSprite('sonicattack', 'characters/sonic-attack', getProperty('boyfriend.x') - 71, getProperty('boyfriend.y') - 203)
	addAnimationByPrefix('sonicattack', 'idle', 'idle', 18, false)
	scaleObject('sonicattack', 6, 6, false)
	setProperty('sonicattack.visible', false)
	setProperty('sonicattack.antialiasing', false)
	setObjectOrder('sonicattack', getObjectOrder('boyfriendGroup') + 1)
	addLuaSprite('sonicattack')

	setProperty('boyfriend.alpha', 0)
	setProperty('camHUD.alpha', 0)
	for i = 0,3 do setProperty('playerStrums.members['..i..'].y', downscroll and screenHeight or (-getProperty('playerStrums.members['..i..'].height'))) end

	setProperty('gf.flipX', true)
	scaleObject('gf', 1.6, 1.6, false)
	callMethod('gf.setPosition', {1500, -34})
	setObjectOrder('gfGroup', getObjectOrder('floor2'))

	makeLuaSprite('redbg', nil, -1180, -370)
	setProperty('redbg.alpha', 0)
	makeGraphic('redbg', screenWidth / 0.5, screenHeight / 0.5, 'FF0000')
	addLuaSprite('redbg')
end

local starv = false
local furn = false
function onEvent(n, v1)
	if n == 'preyEvent' and songPath == 'prey' then
		if v1 == 'startanim' then
			playAnim('introsonic', 'intro', true)
			setProperty('introsonic.animation.curAnim.curFrame', 8)
		end

		if v1 == 'secondcamera' then screenCenter('sonicintro') end
		if v1 == 'thirdcamera' then scaleObject('sonicintro', 3, 3, false) end
		if v1 == 'fourthcamera' then removeLuaSprite('sonicintro', true) setProperty('introsonic.alpha', 1) end

		if v1 == 'addbg' then
			if not lowQuality then
				for i = 1,13 do
					setProperty('bg'..i..'.color', getColorFromHex('FFFFFF'))
				end
				for i = 1,15 do
					setProperty('sky'..i..'.color', getColorFromHex('FFFFFF'))
					if i == 15 then
						setProperty('sky'..i..'flash.color', getColorFromHex('FFFFFF'))
					end
				end

				setProperty('floor1.color', getColorFromHex('FFFFFF'))
				setProperty('floor2.color', getColorFromHex('FFFFFF'))

				setProperty('fg.color', getColorFromHex('FFFFFF'))
			else
				setProperty('bg-lq.color', getColorFromHex('FFFFFF'))
				setProperty('floor-lq.color', getColorFromHex('FFFFFF'))
			end
		end

		if v1 == 'startsong' then
			doTweenX('furnaceX', 'dad', -666, getTime(8), 'cubeOut')
			doTweenY('furnaceY', 'dad', 104, getTime(8), 'smoothStepOut')
			runTimer('startFloating', getTime(8))

			doTweenAlpha('camHUD', 'camHUD', 1, getTime(4))
			for i = 0,3 do noteTweenY('noteY'..i, i + 4, _G['defaultPlayerStrumY'..i], getTime(6), 'cubeOut') end
		end

		if v1 == 'starvedappearing' then
			cancelTween('bfalpha')
			setProperty('boyfriend.alpha', 1)
			cancelTween('camHUD')
			setProperty('camHUD.alpha', 1)
			for i = 0,3 do setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i]) end
			starv = true
			setProperty('gf.velocity.x', -500)
		end

		if v1 == 'sonicattack' then
			setProperty('sonicattack.visible', true)
			setProperty('boyfriend.visible', false)
			playAnim('sonicattack', 'idle', true)
			runTimer('impact', getTime(2))
		end

		if v1 == 'starvedappears' then
			dadX, dadY = 552, 54
			floatTime = 0
			cancelTween('furnaceX')
			cancelTween('furnaceY')
			cancelTween('furnaceA')
			setProperty('dad.angle', 0)
			setObjectOrder('dadGroup', getObjectOrder('floor2') - 1)
			scaleObject('dad', 4, 4, false)
			setProperty('dad.y', -200)
			doTweenX('starvedX', 'dad', 552, getTime(14), 'backOut')
			doTweenY('starvedY', 'dad', 54, getTime(14), 'backOut')
			runTimer('startFloating', getTime(14))
			runTimer('backtonormalsize', getTime(8))
			setProperty('dad.alpha', 1)
		end

		if v1 == 'backtostarved' then
			cancelTween('camHUD')
			setProperty('camHUD.alpha', 0)
			doTweenAlpha('camHUD', 'camHUD', 1, getTime(4))
			for i = 0,3 do
				cancelTween('noteY'..i)
				noteTweenY('noteY'..i, i + 4, _G['defaultPlayerStrumY'..i], getTime(6), 'cubeOut')
			end
		end

		if v1 == 'furnaceappearing' then
			setProperty('gf.x', -1500)
			setProperty('gf.flipX', false)
			scaleObject('gf', 6, 6, false)
			setObjectOrder('gfGroup', getObjectOrder('floor2') + 1)
			callMethod('gf.changeCharacter', {'furnace'})
			setProperty('gf.velocity.x', 300)
			setProperty('gf.y', 960)
			furn = true
		end

		if v1 == 'byestarvlol' then
			oppFloat = false
			cancelTween('starvedX') cancelTween('starvedY')
			doTweenX('starvedX', 'dad', -1500, getTime(8), 'cubeIn')
			doTweenY('starvedY', 'dad', 0, getTime(8), 'smoothStepIn')
		end

		if v1 == 'byehud' then
			setProperty('sonicfinal.alpha', 0)
			setProperty('boyfriend.visible', true)

			cancelTween('camHUD')
			setProperty('camHUD.alpha', 1)
			doTweenAlpha('camHUD', 'camHUD', 0, getTime(4))
			for i = 0,3 do
				cancelTween('noteY'..i)
				noteTweenY('noteY'..i, i + 4, downscroll and screenHeight or (-getProperty('playerStrums.members['..i..'].height')), getTime(6), 'cubeOut')
			end

			starv = false
			furn = false
			callMethod('gf.setPosition', {14400, 350})
			setProperty('gf.velocity.x', -5000)
			setProperty('gf.flipX', true)
		end

		if v1 == 'sonicAttackFinal' then
			setProperty('dad.angle', 0)
			setProperty('sonicfinal.alpha', 1)
			setProperty('boyfriend.visible', false)
			playAnim('sonicfinal', 'idle', true)
			setProperty('dad.alpha', 0)
			setProperty('starvHit.alpha', 1)
			playAnim('starvHit', 'idle', true)
			runTimer('impact2', getTime(1))
		end
	end
end

function getTime(beat)
	return crochet / (1000 / beat) / playbackRate
end

function onTimerCompleted(t)
	if t == 'startFloating' then
		oppFloat = true
	end
	if t == 'backtonormalsize' then
		doTweenX('starvedXX', 'dad.scale', 6, getTime(6), 'cubeInOut')
		doTweenY('starvedYY', 'dad.scale', 6, getTime(6), 'cubeInOut')
		setObjectOrder('dadGroup', getObjectOrder('boyfriendGroup') - 1)
	end

	if t == 'impact' then
		playAnim('dad', 'hit', true)
		setProperty('dad.specialAnim', true)
		cameraShake('game', 0.02, 0.1)

		cancelTimer('startFloating')
		cancelTween('furnaceX')
		cancelTween('furnaceY')
		oppFloat = false

		doTweenX('furnaceX', 'dad', -1600, getTime(4), 'cubeOut')
		doTweenY('furnaceY', 'dad', 250, getTime(4), 'cubeOut')
		doTweenAngle('furnaceA', 'dad', -65, getTime(3), 'cubeOut')

		doTweenAlpha('camHUD', 'camHUD', 0, getTime(2))
		for i = 0,3 do
			cancelTween('noteY'..i)
			noteTweenY('noteY'..i, i + 4, downscroll and screenHeight or (-getProperty('playerStrums.members['..i..'].height')), getTime(4), 'cubeOut')
		end
	end
	if t == 'impact2' then
		cameraShake('game', 0.02, 0.1)

		oppFloat = false

		doTweenX('dieStarvX', 'starvHit', -5000, getTime(6), 'cubeIn')
		doTweenY('dieStarvY', 'starvHit', 1300, getTime(6), 'cubeIn')
	end
end

local playEndOnce = true
local xd = 0
function onUpdatePost(e)
	if oppFloat == true then
		floatTime = floatTime + e * playbackRate
		setProperty('dad.x', dadX + math.sin(floatTime) * 72)
		setProperty('dad.y', dadY + math.cos(floatTime * 0.8 + (math.pi / 2)) * 24)
	end

	if getProperty('sonicattack.visible') == true and getProperty('sonicattack.animation.curAnim.finished') then
		setProperty('sonicattack.visible', false)
		setProperty('boyfriend.visible', true)
	end

	if starv then
		xd = xd + e * 5 * playbackRate
		setProperty('gf.y', -34 + math.sin(xd + (math.pi / 2)) * 5)

		if getProperty('gf.x') <= -1500 then
			starv = false
			setProperty('gf.velocity.x', 0)
		end
	end

	if furn then
		xd = xd + e * 3 * playbackRate
		setProperty('gf.y', 960 + math.sin(xd + (math.pi / 2)) * 5)

		if getProperty('gf.x') >= 1800 then
			furn = false
			setProperty('gf.velocity.x', 0)
		end
	end

	if getProperty('boyfriend.animation.curAnim.name') == 'dialogue' and getProperty('boyfriend.animation.curAnim.finished') and boyfriendName == 'sonic-peelout' and playEndOnce then
		setProperty('redbg.alpha', 1) doTweenAlpha('redbgxddfd', 'redbg', 0, 3)
		setProperty('boyfriend.color', getColorFromHex('000000')) doTweenColor('boyfriendcolor', 'boyfriend', 'FF0000', 2, 'expoOut') doTweenAlpha('bffdsasda', 'boyfriend', 0, 4)
		setProperty('gf.color', getColorFromHex('000000')) doTweenColor('gfcolor', 'gf', 'FF0000', 2, 'expoOut') doTweenAlpha('gfxadasd', 'gf', 0, 4)
		triggerEvent('Play Animation', 'dead_h', 'bf')
		setProperty('gf.velocity.x', 0)
		setProperty('camOther.visible', false)
		cameraShake('game', 0.02, 0.1)
		setProperty('dad.visible', false)
		setProperty('gf.animation.paused', true)
		doTweenX('boyfrienxd', 'boyfriend', getProperty('boyfriend.x') - 300, 3, 'expoOut')
		doTweenX('gfxdxd', 'gf', getProperty('gf.x') - 50, 3, 'expoOut')
		playEndOnce = false

		if not lowQuality then
			for i = 1,13 do
				setProperty('bg'..i..'.visible', false)
			end
			for i = 1,15 do
				setProperty('sky'..i..'.visible', false)
				if i == 15 then
					setProperty('sky'..i..'flash.visible', false)
				end
			end

			setProperty('floor1.visible', false)
			setProperty('floor2.visible', false)

			setProperty('fg.visible', false)
		else
			setProperty('bg-lq.visible', false)
			setProperty('floor-lq.visible', false)
		end
	end
end
