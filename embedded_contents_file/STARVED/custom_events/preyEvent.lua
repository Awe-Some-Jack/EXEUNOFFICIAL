local oppFloatX, oppFloatY = false, false
local dadX, dadY = -666, 104
local floatTimeX, floatTimeY = 0, 0
local oldGT = false
function onCreatePost()
	setProperty('boyfriend.alpha', 0)
	setProperty('camHUD.alpha', 0)
	for i = 0,3 do setProperty('playerStrums.members['..i..'].y', downscroll and screenHeight or (-getProperty('playerStrums.members['..i..'].height'))) end

	setProperty('gf.flipX', true)
	scaleObject('gf', 1.6, 1.6, false)
	callMethod('gf.setPosition', {1500, -34})
	setObjectOrder('gfGroup', getObjectOrder('bgGroup[0]') + 1)

	makeLuaSprite('redbg', nil, -1180, -900)
	setProperty('redbg.alpha', 0)
	makeGraphic('redbg', screenWidth * 2, screenHeight * 4, 'FF0000')
	addLuaSprite('redbg')

	oldGT = getPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping')
	setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', true)
	setVar('ending', false)
end

local altTime = false
local starv = false
local furn = false
local furnaceKilling = false
function onEvent(n, v1)
	if n == 'preyEvent' and songPath == 'prey' then
		if v1 == 'gt' then
			setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', oldGT)
		end

		if v1 == 'startanim' then
			playAnim('boyfriend', 'intro', true)
			setProperty('boyfriend.specialAnim', true)
			setProperty('boyfriend.animation.curAnim.curFrame', 8)
		end

		if v1 == 'secondcamera' then screenCenter('sonicintro') end
		if v1 == 'thirdcamera' then scaleObject('sonicintro', 3, 3, false) end
		if v1 == 'fourthcamera' then doTweenAlpha('sonicintro', 'sonicintro', 0, crochet / (1000 / 8)) end

		if v1 == 'addbg' then
			setProperty('boyfriend.alpha', 1)
			removeLuaSprite('sonicintro', true)
			if not lowQuality then
				for i = 1,15 do
					setProperty('bgGroup['..i..'].color', getColorFromHex('FFFFFF'))
				end

				for i = 1,3 do setProperty('floorGroup['..(i - 1)..'].color', getColorFromHex('FFFFFF')) end
				for i = 1,3 do setProperty('floorBGGroup['..(i - 1)..'].color', getColorFromHex('FFFFFF')) end

				setProperty('fg.color', getColorFromHex('FFFFFF'))
			else
				setProperty('bg-lq.color', getColorFromHex('FFFFFF'))
				setProperty('floor-lq.color', getColorFromHex('FFFFFF'))
			end
		end

		if v1 == 'startsong' then
			doTweenX('furnaceX', 'dad', -666, getTime(8), 'cubeOut')
			runTimer('startFloating', getTime(8))
			oppFloatY = true

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
			setProperty('gf.color', getColorFromHex('C48383'))
			setScrollFactor('gf', 1, 0.6)
		end

		if v1 == 'sonicattack' then
			setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', true)
			playAnim('boyfriend', 'attack', true)
			setProperty('boyfriend.specialAnim', true)
			for i = 0,getProperty('notes.length')-1 do
				setProperty('notes.members['..i..'].noAnimation', true)
				setProperty('notes.members['..i..'].noMissAnimation', true)
			end
			runTimer('impact', getTime(2))
		end

		if v1 == 'starvedappears' then
			dadX, dadY = 552, 54
			floatTimeX = 0
			floatTimeY = 0
			cancelTween('furnaceX')
			cancelTween('furnaceY')
			cancelTween('furnaceA')
			setProperty('dad.angle', 0)
			setObjectOrder('dadGroup', getObjectOrder('floorBGGroup[0]') - 1)
			scaleObject('dad', 4, 4, false)
			setProperty('dad.y', -200)
			doTweenX('starvedX', 'dad', 552, getTime(14), 'backOut')
			doTweenY('starvedY', 'dad', 54, getTime(14), 'backOut')
			runTimer('startFloating', getTime(14))
			oppFloatY = true
			runTimer('backtonormalsize', getTime(8))
			setProperty('dad.alpha', 1)
			altTime = true

			for i = 0,getProperty('notes.length')-1 do
				setProperty('notes.members['..i..'].noAnimation', false)
				setProperty('notes.members['..i..'].noMissAnimation', false)
			end
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
			setScrollFactor('gf', 1, 1)
			setProperty('gf.x', -1400)
			setProperty('gf.flipX', false)
			setObjectOrder('gfGroup', getObjectOrder('floorBGGroup[0]') + 1)
			callMethod('gf.changeCharacter', {'furnace'})
			runTimer('xdjiasfaishjf', 2)
			setProperty('gf.velocity.x', 200)
			setProperty('gf.y', 1200)
			furn = true
			scaleObject('gf', 4, 4, false)
		end

		if v1 == 'byestarvlol' then
			oppFloatY = false
			cancelTween('starvedX') cancelTween('starvedY')
			doTweenX('starvedX', 'dad', -1500, getTime(8), 'cubeIn')
			doTweenY('starvedY', 'dad', 0, getTime(8), 'smoothStepIn')
		end

		if v1 == 'byehud' then
			cancelTween('camHUD')
			setProperty('camHUD.alpha', 1)
			doTweenAlpha('camHUD', 'camHUD', 0, getTime(4))
			for i = 0,3 do
				cancelTween('noteY'..i)
				noteTweenY('noteY'..i, i + 4, downscroll and screenHeight or (-getProperty('playerStrums.members['..i..'].height')), getTime(6), 'cubeOut')
			end

			starv = false
			furn = false
			furnaceKilling = true
			callMethod('gf.setPosition', {14900, 350})
			setProperty('gf.maxVelocity.x', 0)
			setProperty('gf.velocity.x', -5000)
			setProperty('gf.flipX', true)
		end

		if v1 == 'sonicAttackFinal' then
			setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', true)
			setProperty('dad.angle', 0)
			playAnim('boyfriend', 'attack2', true)
			setProperty('boyfriend.specialAnim', true)
			for i = 0,getProperty('notes.length')-1 do
				setProperty('notes.members['..i..'].noAnimation', true)
				setProperty('notes.members['..i..'].noMissAnimation', true)
			end
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
		oppFloatX = true
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
		oppFloatY = false
		oppFloatX = false

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

		oppFloatY = false
		oppFloatX = false

		doTweenX('dieStarvX', 'starvHit', -5000, getTime(6), 'cubeIn')
		doTweenY('dieStarvY', 'starvHit', 1300, getTime(6), 'cubeIn')
	end
	if t == 'xdjiasfaishjf' then
		setProperty('gf.acceleration.x', -300)
		playAnim('gf', 'fly', true)
		setProperty('gf.specialAnim', true)
	end
end

local lerpY = 420
local playEndOnce = true
local xd = 0
function onUpdatePost(e)
	lerpY = lerp(lerpY, getVar('floorY'), e * 3)
	if oppFloatX then
		floatTimeX = floatTimeX + e * playbackRate
		setProperty('dad.x', dadX + math.sin(floatTimeX) * 72)
	end
	if oppFloatY then
		floatTimeY = floatTimeY + e * playbackRate
		setProperty('dad.y', dadY + (lerpY - 420) + math.cos(floatTimeY * 0.8 + (math.pi / 2)) * 24)
	end

	if getProperty('gf.animation.curAnim.name') == 'fly' and getProperty('gf.animation.curAnim.finished') then
		playAnim('gf', 'flyloop', true)
		setProperty('gf.specialAnim', true)
		setProperty('gf.acceleration.x', 300)
		setProperty('gf.maxVelocity.x', 350)
	end

	if starv then
		xd = xd + e * 5 * playbackRate
		setProperty('gf.y', 66 + math.sin(xd + (math.pi / 2)) * 5)

		if getProperty('gf.x') <= -1500 then
			starv = false
			setProperty('gf.velocity.x', 0)
		end
	end

	if furn then
		xd = xd + e * 3 * playbackRate
		setProperty('gf.y', 850 + math.sin(xd + (math.pi / 2)) * 10)

		if getProperty('gf.x') >= 1900 then
			scaleObject('gf', 6, 6, false)
			setProperty('gf.color', getColorFromHex('FFFFFF'))
			furn = false
			setProperty('gf.acceleration.x', 0)
			setProperty('gf.velocity.x', 0)
		end
	end

	if furnaceKilling then
		setProperty('gf.y', getVar('floorY') - 50)
	end

	if getProperty('boyfriend.animation.curAnim.name') == 'ending' and getProperty('boyfriend.animation.curAnim.finished') and playEndOnce then
		setProperty('redbg.alpha', 1) doTweenAlpha('redbgxddfd', 'redbg', 0, 3)
		setProperty('boyfriend.color', getColorFromHex('000000')) doTweenColor('boyfriendcolor', 'boyfriend', 'FF0000', 2, 'expoOut') doTweenAlpha('bffdsasda', 'boyfriend', 0, 4)
		setProperty('gf.color', getColorFromHex('000000')) doTweenColor('gfcolor', 'gf', 'FF0000', 2, 'expoOut') doTweenAlpha('gfxadasd', 'gf', 0, 4)
		playAnim('boyfriend', 'ending-death', true)
		setProperty('boyfriend.specialAnim', true)
		setProperty('gf.velocity.x', 0)
		setProperty('camOther.visible', false)
		cameraShake('game', 0.02, 0.1)
		setProperty('dad.visible', false)
		setProperty('gf.animation.paused', true)
		doTweenX('boyfrienxd', 'boyfriend', getProperty('boyfriend.x') - 300, 3, 'expoOut')
		doTweenX('gfxdxd', 'gf', getProperty('gf.x') - 50, 3, 'expoOut')
		playEndOnce = false
		furnaceKilling = false
		setVar('ending', true)

		if not lowQuality then
			for i = 1,15 do setProperty('bgGroup['..(i - 1)..'].visible', false) end
			setProperty('sky15flash.visible', false)

			for i = 1,3 do setProperty('floorGroup['..(i - 1)..'].visible', false) end
			for i = 1,3 do setProperty('floorBGGroup['..(i - 1)..'].visible', false) end

			setProperty('fg.visible', false)
		else
			setProperty('bg-lq.visible', false)
			setProperty('floor-lq.visible', false)
		end
	end
end

function noteMissPress(nt) if not altTime then return end playAnim('boyfriend', getProperty('singAnimations['..nt..']') .. 'miss-alt', true) end

function onDestroy() setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', oldGT) end

function lerp(a, b, t)
	return a + t * (b - a)
end