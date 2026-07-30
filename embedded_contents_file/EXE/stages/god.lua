local count = 1

local exespk = stringSplit(getTextFromFile('data/godspeed/exeSpeak.txt'), '\n')
local daLines, usedLines = {}, {}
for i = 1, #exespk do table.insert(daLines, exespk[i]) end

local function getExeSpeak()
	if #daLines == 0 then for i = 1, #usedLines do table.insert(daLines, usedLines[i]) end usedLines = {} end
	local index = getRandomInt(1, #daLines)
	local line = daLines[index]
	table.remove(daLines, index)
	table.insert(usedLines, line)
	return stringTrim(line:gsub('%$', '\n'))
end

local function makeFire(speed, y, scroll, front, scale)
	createInstance('fire'..count, 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 0})
	loadFrames('fire'..count, 'god/FIRE 2')
	addAnimationByPrefix('fire'..count, 'idle', 'fire', 24, true)
	scaleObject('fire'..count, scale or 1.5, scale or 3)
	setProperty('fire'..count..'.y', y)
	setScrollFactor('fire'..count, scroll, scroll)
	setProperty('fire'..count..'.velocity.x', speed)
	addInstance('fire'..count, front or false)
	count = count + 1
end

local function setMaxVelocities()
	setProperty('mount00.maxVelocity.x', 2000)
	setProperty('mount0.maxVelocity.x', 3000)
	setProperty('mount1.maxVelocity.x', 4000)
	setProperty('mount2.maxVelocity.x', 5000)
	setProperty('totema.maxVelocity.x', 6000)
	setProperty('totem2a.maxVelocity.x', 6000)
	for i = 1,3 do
		setProperty('floor'..i..'.maxVelocity.x', 6000 + (1500 * (i - 1)))
		setProperty('trees'..i..'.maxVelocity.x', 6000 + (1500 * (i - 1)))
	end
	setProperty('totem.maxVelocity.x', 8000)
	setProperty('totem2.maxVelocity.x', 8000)
end

function onCreatePost()
	startVideo('good speed', false, true, false, false) setProperty('inCutscene', false)
	callMethod('videoCutscene.destroy')
    callMethod('remove', {instanceArg('videoCutscene')})

	makeLuaSprite('godOffsetX')
	
	makeLuaSprite('sky', 'god/son', -2950, -1200)
	scaleObject('sky', 3.5, 3.5)
	setScrollFactor('sky', 0.05, 0.05)
	addLuaSprite('sky')

	createInstance('mount00', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -500})
	loadGraphic('mount00', 'god/mount1')
	scaleObject('mount00', 2, 2)
	setProperty('mount00.y', -300)
	setProperty('mount00.color', getColorFromHex('555555'))
	setScrollFactor('mount00', 0.2, 0.2)
	setProperty('mount00.velocity.x', -2000)
	addInstance('mount00')
	
	makeFire(-2000, -1300 + 1200, 0.3, false, 5)

	createInstance('mount0', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -500})
	loadGraphic('mount0', 'god/mount1')
	scaleObject('mount0', 1.5, 1.5)
	setProperty('mount0.y', -100)
	setProperty('mount0.color', getColorFromHex('AAAAAA'))
	setScrollFactor('mount0', 0.5, 0.5)
	setProperty('mount0.velocity.x', -3000)
	addInstance('mount0')

	createInstance('mount1', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -200})
	loadGraphic('mount1', 'god/mount1')
	scaleObject('mount1', 1.5, 1.5)
	setScrollFactor('mount1', 0.6, 0.6)
	setProperty('mount1.y', -300)
	setProperty('mount1.velocity.x', -4000)
	addInstance('mount1')

	makeFire(-5000, -300 + 1200, 0.8)

	createInstance('mount2', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -200})
	loadGraphic('mount2', 'god/mount2')
	scaleObject('mount2', 1, 1)
	setScrollFactor('mount2', 0.8, 0.8)
	setProperty('mount2.y', 200)
	setProperty('mount2.velocity.x', -5000)
	addInstance('mount2')

	makeLuaSprite('grad', 'god/grad', -1500, -500)
	scaleObject('grad', 5500, 2)
	addLuaSprite('grad')

	makeFire(-6000, 0 + 1200, 1)

	createInstance('totema', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 12000})
	loadGraphic('totema', 'god/totems/totem1-2')
	scaleObject('totema', 1.25, 1.25)
	setScrollFactor('totema', 0.9, 0.9)
	setProperty('totema.velocity.x', -6000)
	addInstance('totema')
	setProperty('totema.color', getColorFromHex('888888'))
	setProperty('totema.x', -10000) setProperty('totema.y', -1000)

	createInstance('totem2a', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 12000})
	loadGraphic('totem2a', 'god/totems/totem2-2')
	setScrollFactor('totem2a', 0.9, 0.9)
	scaleObject('totem2a', 1.25, 1.25)
	setProperty('totem2a.velocity.x', -6000)
	addInstance('totem2a')
	setProperty('totem2a.color', getColorFromHex('888888'))
	setProperty('totem2a.x', -2000) setProperty('totem2a.y', -1000)

	for i = 1,3 do
		createInstance('trees'..i, 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 12000})
		loadGraphic('trees'..i, 'god/1')
		scaleObject('trees'..i, 1.3 + (0.2 * (i - 1)), 1.3 + (0.2 * (i - 1)))
		setScrollFactor('trees'..i, 1 + (0.2 * (i - 1)), 1 + (0.2 * (i - 1)))
		setProperty('trees'..i..'.velocity.x', -6000 - (1500 * (i - 1)))
		addInstance('trees'..i, i > 1)
		setProperty('trees'..i..'.y', 200 + 80 * (i - 1))
		setProperty('trees'..i..'.x', 5000 * i)

		createInstance('floor'..i, 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -100})
		loadGraphic('floor'..i, 'god/floor')
		scaleObject('floor'..i, 0.9 + (0.2 * (i - 1)), 0.9 + (0.2 * (i - 1)))
		setScrollFactor('floor'..i, 1 + (0.2 * (i - 1)), 1 + (0.2 * (i - 1)))
		setProperty('floor'..i..'.velocity.x', -6000 - (1500 * (i - 1)))
		addInstance('floor'..i, i > 1)
		setProperty('floor'..i..'.y', 100 + 80 * (i - 1))
		
		if i == 1 then
			setProperty('floor1.color', getColorFromHex('555555'))

			createInstance('totem', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 10000})
			loadGraphic('totem', 'god/totems/totem1-2')
			setProperty('totem.velocity.x', -8000)
			scaleObject('totem', 3.5, 3.5)
			addInstance('totem', true)
			setProperty('totem.y', -3500)

			createInstance('totem2', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 10000})
			loadGraphic('totem2', 'god/totems/totem2-2')
			scaleObject('totem2', 3.5, 3.5)
			setProperty('totem2.velocity.x', -8000)
			addInstance('totem2', true)
			setProperty('totem2.y', -3500)
			setProperty('totem2.x', 20000)

		elseif i == 2 then
			makeFire(-7500, 340 + 1200, 1.2, true)
			setProperty('floor2.color', getColorFromHex('AAAAAA'))
		end
	end

	setMaxVelocities()

	for i = 0,getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') and not getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') and not getPropertyFromGroup('unspawnNotes', i + 1, 'isSustainNote') then
			setPropertyFromGroup('unspawnNotes', i, 'multSpeed', getRandomFloat(1.2, 2))
		end
	end

	makeAnimatedLuaSprite('metal', 'characters/k')
	addAnimationByPrefix('metal', 'idle', 'Símbolo 100', 24, true)
	addLuaSprite('metal')
	setObjectOrder('metal', getObjectOrder('boyfriendGroup') - 1)

	makeLuaText('exeSpeak', 'null', screenWidth)
	setTextFont('exeSpeak', 'voidspeak.ttf')
	setTextSize('exeSpeak', 80)
	setTextColor('exeSpeak', 'FF0000')
	setObjectCamera('exeSpeak', 'other')
	setTextBorder('exeSpeak', 0)
	screenCenter('exeSpeak')
	addLuaText('exeSpeak')
	setProperty('exeSpeak.visible', false)
end

local inCinematic = false
local isEndingCine = false
local sine = 0
function onUpdatePost(e)
	sine = sine + e * 2
	if not inCinematic then
		callMethod('dad.setPosition', {100 + getProperty('godOffsetX.x') + lerp(500, 0, getHealth() / 2) + math.cos(sine / 2) * 80, 150 + math.sin(sine) * 150})
		callMethod('boyfriend.setPosition', {2200 + math.cos(0.5 + sine / 2) * 50, 20 + math.sin(0.5 + sine) * 75})
		callMethod('metal.setPosition', {2130 + math.cos(0.5 + sine / 2) * 50, 350 + math.sin(0.5 + sine) * 75})
	end

	setProperty('camHUD.angle', math.sin(sine))
	setProperty('camHUD.x', math.cos(sine / 2) * 10)
	setProperty('camHUD.y', math.sin(sine) * 10)

	if isEndingCine and getProperty('dad.velocity.x') < 0 then
		inCinematic = false
		isEndingCine = false
		getProperty('dad.velocity.x', 0)
		getProperty('boyfriend.velocity.x', 0)
		getProperty('metal.velocity.x', 0)

		setProperty('dad.acceleration.x', 0)
		setProperty('boyfriend.acceleration.x', 0)
		setProperty('metal.acceleration.x', 0)
	end
end

function onBeatHit()
	if curBeat % 2 == 0 and getProperty('boyfriend.animation.curAnim.name') == 'idle' then
		playAnim('boyfriend', 'idle', true)
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n,v1, v2)
	if n == 'godEvents' then
		if v1 == 'fireappear' then
			doTweenAlpha('xddasd', 'camHUD', 1, 1.3)
			for i = 1,4 do
				doTweenY('fire'..i, 'fire'..i, getProperty('fire'..i..'.y') - 1200, 4, 'cubeOut')
			end
		end
		if v1 == 'godBye' then
			doTweenAlpha('xddasd', 'camHUD', 0, 3)
			doTweenX('fjas', 'godOffsetX', -3000, 4, 'cubeIn')
		end
		if v1 == 'godAPPEAR' then
			doTweenX('fjas', 'godOffsetX', 0, 8, 'cubeOut')
		end
		if v1 == 'cinematic' then
			inCinematic = true

			setProperty('dad.velocity.x', 8000)
			setProperty('boyfriend.velocity.x', 8000)
			setProperty('metal.velocity.x', 8000)

			setProperty('dad.x', getProperty('godOffsetX.x') - 5000)
			setProperty('boyfriend.x', 2200 - 5000)
			setProperty('metal.x', 2130 - 5000)

			setProperty('mount00.velocity.x', 0)
			setProperty('mount0.velocity.x', 0)
			setProperty('mount1.velocity.x', 0)
			setProperty('mount2.velocity.x', 0)
			setProperty('totema.velocity.x', 0)
			setProperty('totem2a.velocity.x', 0)
			for i = 1,3 do
				setProperty('floor'..i..'.velocity.x', 0)
				setProperty('trees'..i..'.velocity.x', 0)
			end
			setProperty('totem.velocity.x', 0)
			setProperty('totem2.velocity.x', 0)

			setProperty('mount00.x', getProperty('mount00.x') + 5000)
			setProperty('mount0.x', getProperty('mount0.x') + 5000)
			setProperty('mount1.x', getProperty('mount1.x') + 5000)
			setProperty('mount2.x', getProperty('mount2.x') + 5000)
			setProperty('totema.x', getProperty('totema.x') + 5000)
			setProperty('totem2a.x', getProperty('totem2a.x') + 5000)
			for i = 1,3 do
				setProperty('floor'..i..'.x', getProperty('floor'..i..'.x') + 5000)
				setProperty('trees'..i..'.x', getProperty('trees'..i..'.x') + 5000)
			end
			setProperty('totem.x', getProperty('totem.x') + 5000)
			setProperty('totem2.x', getProperty('totem2.x') + 5000)
		end
		if v1 == 'goacceleration' then
			setProperty('dad.acceleration.x', -8000 / (crochet / 500))
			setProperty('boyfriend.acceleration.x', -8000 / (crochet / 500))
			setProperty('metal.acceleration.x', -8000 / (crochet / 500))
		end
		if v1 == 'cinematicend' then
			isEndingCine = true
			setProperty('mount00.acceleration.x', -2000)
			setProperty('mount0.acceleration.x', -3000)
			setProperty('mount1.acceleration.x', -4000)
			setProperty('mount2.acceleration.x', -5000)
			setProperty('totema.acceleration.x', -6000)
			setProperty('totem2a.acceleration.x', -6000)
			for i = 1,3 do
				setProperty('floor'..i..'.acceleration.x', -6000 - (1500 * (i - 1)))
				setProperty('trees'..i..'.acceleration.x', -6000 - (1500 * (i - 1)))
			end
			setProperty('totem.acceleration.x', -8000)
			setProperty('totem2.acceleration.x', -8000)
		end
		if v1 == 'cinematica' then
			startVideo('good speed', false, true)
			setProperty('inCutscene', false)
			setProperty('videoCutscene.videoSprite.volumeAdjust', 0)
		end
		if v1 == 'exeSpeak' then
			setProperty('cpuAssist', true)
			cancelTimer('daspeak') cancelTimer('daassist')
			runTimer('daspeak', crochet / 250)
			runTimer('daassist', crochet / 250 + 0.2)
			setProperty('cameraSpeed', 9999)

			setProperty('camGame.alpha', 0) setProperty('camHUD.alpha', 0)
			setProperty('exeSpeak.visible', true)

			setTextString('exeSpeak', getExeSpeak())
			screenCenter('exeSpeak')
		end
		if v1 == 'exeSpeakShort' then
			setProperty('cpuAssist', true)
			cancelTimer('daspeak') cancelTimer('daassist')
			runTimer('daspeak', crochet / 500)
			runTimer('daassist', crochet / 500 + 0.2)
			setProperty('cameraSpeed', 9999)

			setProperty('camGame.alpha', 0) setProperty('camHUD.alpha', 0)
			setProperty('exeSpeak.visible', true)
			
			setTextString('exeSpeak', getExeSpeak())
			screenCenter('exeSpeak')
		end
	end
end

function onTimerCompleted(t)
	if t == 'daspeak' then
		setProperty('cameraSpeed', 1)
		setProperty('camGame.alpha', 1) setProperty('camHUD.alpha', 1)
		setProperty('exeSpeak.visible', false)
	end
	if t == 'daassist' then setProperty('cpuAssist', false) end
end

--video functions, ignore

function onGameOver()
	if getProperty('videoCutscene') == nil then return end
    callMethod('videoCutscene.destroy')
    callMethod('remove', {instanceArg('videoCutscene')})
end

function onDestroy()
	if getProperty('videoCutscene') == nil then return end
    callMethod('remove', {instanceArg('videoCutscene')})
end

function onPause()
    if getProperty('videoCutscene') == nil then return end
    callMethod('videoCutscene.pause')
    if callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('videoCutscene.videoSprite.pause')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusLost.remove', {instanceArg('videoCutscene.videoSprite.pause')})
    end
    if callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('videoCutscene.videoSprite.resume')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusGained.remove', {instanceArg('videoCutscene.videoSprite.resume')})
    end
end

function onResume()
    if getProperty('videoCutscene') == nil then return end
    callMethod('videoCutscene.resume')
    if not callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('videoCutscene.videoSprite.pause')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusLost.add', {instanceArg('videoCutscene.videoSprite.pause')})
    end
    if not callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('videoCutscene.videoSprite.resume')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusGained.add', {instanceArg('videoCutscene.videoSprite.resume')})
    end
end