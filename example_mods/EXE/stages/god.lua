local count = 1
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

function onCreatePost()
	makeLuaSprite('godOffsetX')
	
	makeAnimatedLuaSprite('sky', 'god/solazo', -1800, -1000)
	addAnimationByPrefix('sky', 'idle', 'idle', 24, true)
	scaleObject('sky', 2.5, 2.5)
	setScrollFactor('sky', 0.15, 0.15)
	addLuaSprite('sky')
	
	makeFire(-2000, -1300 + 1000, 0.3, false, 5)

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

	makeFire(-5000, -300 + 1000, 0.8)

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

	makeFire(-6000, 0 + 1000, 1)

	createInstance('totema', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 35000})
	loadGraphic('totema', 'god/totem1')
	scaleObject('totema', 0.8, 0.8)
	setScrollFactor('totema', 0.9, 0.9)
	setProperty('totema.velocity.x', -6000)
	addInstance('totema')
	setProperty('totema.color', getColorFromHex('AAAAAA'))
	setProperty('totema.x', -10000)

	createInstance('totem2a', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 35000})
	loadGraphic('totem2a', 'god/totem2')
	scaleObject('totem2a', 0.8, 0.8)
	setScrollFactor('totem2a', 0.9, 0.9)
	setProperty('totem2a.velocity.x', -6000)
	addInstance('totem2a')
	setProperty('totem2a.color', getColorFromHex('AAAAAA'))
	setProperty('totem2a.x', 8000)

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

			createInstance('totem', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 35000})
			loadGraphic('totem', 'god/totem1')
			setProperty('totem.velocity.x', -8000)
			addInstance('totem', true)
			setProperty('totem.y', 300)

			createInstance('totem2', 'flixel.addons.display.FlxBackdrop', {nil, 0x01, 35000})
			loadGraphic('totem2', 'god/totem2')
			setProperty('totem2.velocity.x', -8000)
			addInstance('totem2', true)
			setProperty('totem2.y', 300)
			setProperty('totem2.x', 20000)

		elseif i == 2 then
			makeFire(-7500, 340 + 1000, 1.2, true)
			setProperty('floor2.color', getColorFromHex('AAAAAA'))
		end
	end

	for i = 0,getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') and not getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') and not getPropertyFromGroup('unspawnNotes', i + 1, 'isSustainNote') then
			setPropertyFromGroup('unspawnNotes', i, 'multSpeed', getRandomFloat(1.2, 2))
		end
	end

	makeAnimatedLuaSprite('metal', 'characters/k')
	addAnimationByPrefix('metal', 'idle', 'Símbolo 100', 24, true)
	addLuaSprite('metal')
	setObjectOrder('metal', getObjectOrder('boyfriendGroup') - 1)
end

local sine = 0
function onUpdatePost(e)
	sine = sine + e * 2
	callMethod('dad.setPosition', {getProperty('godOffsetX.x') + lerp(600, 0, getHealth() / 2) + math.cos(sine / 2) * 80, 100 + math.sin(sine) * 150})
	callMethod('boyfriend.setPosition', {2200 + math.cos(0.5 + sine / 2) * 50, 0 + math.sin(0.5 + sine) * 75})
	callMethod('metal.setPosition', {2130 + math.cos(0.5 + sine / 2) * 50, 320 + math.sin(0.5 + sine) * 75})

	setProperty('camHUD.angle', math.sin(sine))
	setProperty('camHUD.x', math.cos(sine / 2) * 10)
	setProperty('camHUD.y', math.sin(sine) * 10)
end

function onBeatHit()
	if curBeat % 2 == 0 and getProperty('boyfriend.animation.curAnim.name') == 'idle' then
		playAnim('boyfriend', 'idle', true)
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n,v1)
	if n == 'godEvents' then
		if v1 == 'fireappear' then
			for i = 1,4 do
				doTweenY('fire'..i, 'fire'..i, getProperty('fire'..i..'.y') - 1000, 4, 'cubeOut')
			end
		end
		if v1 == 'godBye' then
			doTweenX('fjas', 'godOffsetX', -3000, 4, 'cubeIn')
		end
		if v1 == 'godAPPEAR' then
			doTweenX('fjas', 'godOffsetX', 0, 8, 'cubeOut')
		end
	end
end