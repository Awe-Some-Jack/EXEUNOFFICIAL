local canGlitch = false
local scorchedSinging = false

local winIsFull = nil
local moveWindow = false

local iconsGlitch = {
	['scorched-g'] = {['idle'] = 'lordx', ['singLEFT'] = 'XENO-P3', ['singDOWN'] = 'xterion', ['singUP'] = 'grimeware', ['singRIGHT'] = 'rerun'},
	['scorched-g2'] = {['idle'] = 'mighty', ['singLEFT'] = 'cyclops', ['singDOWN'] = 'eyx', ['singUP'] = 'griatos', ['singRIGHT'] = 'sallyAlt'}
}

local savedWidth = 0
local savedHeight = 0

function onCreatePost()
	savedWidth = getPropertyFromClass('flixel.FlxG', 'stage.window.width')
	savedHeight = getPropertyFromClass('flixel.FlxG', 'stage.window.height')

	createInstance('iconGlitch', 'objects.HealthIcon', {iconsGlitch['scorched-g']['idle'], false})
	addToGroup('uiGroup', 'iconGlitch', getObjectOrder('iconOpp', 'uiGroup') + 1)
	setProperty('iconGlitch.visible', false)

	makeLuaSprite('scorch', 'manual-blast/glitch/scorchedface')
	setProperty('scorch.color', getColorFromHex('000000'))
	setProperty('scorch.alpha', 0)
	scaleObject('scorch', 0.7, 0.7)
	screenCenter('scorch')
	setObjectCamera('scorch', 'other')
	addLuaSprite('scorch')

	makeLuaSprite('shake') makeLuaSprite('winpos')

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromatic')
	
	makeLuaSprite('glitch')
	setSpriteShader('glitch', 'glitchChromatic')

	makeLuaSprite('glitch2', nil, 0)
	setSpriteShader('glitch2', 'glitchb')
	setShaderFloatArray('glitch2', 'iResolution', {1280, 720})
	setShaderFloat('glitch2', 'Amount', 0)
	if shadersEnabled and not lowQuality then
		runHaxeCode([[
			game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader)];
		]])
	end
end

local oldAnimDad = ''
local noteShake = 0
local targetCAB = 0
local targetGlitch = 0
local targetGlitch2 = 0
local sex = 0
local fucker = false

local winShake = 0
function onUpdatePost(e)
	callMethod('iconGlitch.setPosition', {getProperty('iconOpp.x'), getProperty('iconOpp.y')})
	setProperty('iconGlitch.alpha', getProperty('iconOpp.alpha') - 0.4)
	scaleObject('iconGlitch', getProperty('iconOpp.scale.x'), getProperty('iconOpp.scale.y'))

	sex = sex + e * playbackRate
	setShaderFloat('glitch', 'iTime', sex)
	setShaderFloat('glitch2', 'iTime', sex)

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

	setProperty('glitch2.x', lerp(getProperty('glitch2.x'), targetGlitch, 5 * e))
	setShaderFloat('glitch2', 'Amount', getProperty('glitch2.x'))

	setProperty('cab.x', lerp(getProperty('cab.x'), targetCAB, 5 * e))
	setShaderFloatArray('cab', 'rOffset', {-getProperty('cab.x'), 0})
	setShaderFloatArray('cab', 'gOffset', {getProperty('cab.x'), 0})
	setShaderFloatArray('cab', 'bOffset', {getProperty('cab.x') * 2, 0})

	if canGlitch and curBeat < 1250 then
		setProperty('glitch.x', lerp(getProperty('glitch.x'), targetGlitch2, 5 * e))
		cameraShake('game', 0.005, 0.1)
		cameraShake('hud', 0.002, 0.1)
		setHealth(getRandomFloat(0.75,0.6))

		callMethod('winpos.setPosition', {
			((getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.width') - getPropertyFromClass('flixel.FlxG', 'stage.window.width')) / 2) + math.sin(sex / 2) * 30,
			((getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.height') - getPropertyFromClass('flixel.FlxG', 'stage.window.height')) / 2) + math.cos(sex + (math.pi / 2)) * 30
		})

		setShaderFloat('iconBF', 'binaryIntensity', getRandomFloat(2,5))
		setShaderFloat('iconOpp', 'binaryIntensity', getRandomFloat(5,15))
		setShaderFloat('iconGlitch', 'binaryIntensity', getRandomFloat(5,15))

		for i = 0,7 do
			setShaderFloat('strumLineNotes.members['..i..']', 'binaryIntensity', getRandomFloat(2,5))
		end
	end

	if moveWindow then
		winShake = getProperty('shake.x')

		setPropertyFromClass('flixel.FlxG', 'stage.window.x', getProperty('winpos.x') + getRandomFloat(-3, 3) * winShake)
		setPropertyFromClass('flixel.FlxG', 'stage.window.y', getProperty('winpos.y') + getRandomFloat(-3, 3) * winShake)

		setShaderFloat('glitch', 'GLITCH', getProperty('glitch.x'))
	end

	if noteShake > 0 then
		noteShake = lerp(noteShake, -0.01, e * 3.15 * playbackRate)
		if noteShake <= 0 then noteShake = 0 end

		for i = 0,getProperty('notes.length')-1 do
			setProperty('notes.members['..i..'].angle', getRandomFloat(-1,1) * (noteShake * 2000))
			setShaderFloat('notes.members['..i..']', 'binaryIntensity', getRandomFloat(2,5))
		end
	end

	if fucker then
		--setShaderFloat('xd', 'intensity', getProperty('xd.x'))
		--setShaderFloat('xd', 'scale', 0.7 / (1.3 - getProperty('camGame.zoom')))
		scaleObject('scorch', 0.7 / (1.3 - getProperty('camGame.zoom')), 0.7 / (1.3 - getProperty('camGame.zoom')), false)
	end

	if getProperty('dad.animation.curAnim.name') ~= oldAnimDad and dadName == 'scorched-g' or dadName == 'scorched-g2' then
		oldAnimDad = getProperty('dad.animation.curAnim.name')
		callMethod('iconGlitch.changeIcon', {iconsGlitch[dadName][oldAnimDad]})
	end
end

function opponentNoteHit()
	if canGlitch then
		cancelTimer('lolero')
		scorchedSinging = true
		runTimer('lolero', 0.35)
		setProperty('cab.x', 0.001)
		setProperty('glitch2.x', 0.25)
		noteShake = 0.0095
	end
end

function onBeatHit()
	if curBeat >= 1250 and canGlitch then
		removeLuaSprite('luz2', true)

		moveWindow = false
		canGlitch = false
		runHaxeCode([[
			//game.camGame.filters = [new ShaderFilter(game.getLuaObject('xd').shader)];
			game.camHUD.filters = [];
		]])
	end

	if canGlitch and scorchedSinging and curBeat % 2 == 0 then
		playAnim('t', 'idle-'..getRandomInt(1,3), true)
	end
end

function onSectionHit()
	if canGlitch then
		if scorchedSinging then
			playAnim('gf', 'idle-alt'..getRandomInt(1,9), true)
			setProperty('gf.specialAnim', true)
		end
		setProperty('glitch2.x', 0.4)
		setProperty('cab.x', 0.0025)

		if curSection <= 308 then
			if curSection % 4 == 0 and curSection ~= 296 then
				triggerEvent('Change Character', 'dad', 'scorched-g')
			elseif curSection % 4 == 2 and curSection ~= 298 then
				triggerEvent('Change Character', 'dad', 'scorched-g2')
			end
		end
	end
end

local appear = false
function onEvent(n, v1) 
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.25)
		doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
	end
	if n == 'sexxxxxx' then
		if v1 == 'startingglitch' then
			doTweenX('glitch', 'glitch', 1, crochet / (1000 / 8), 'cubeIn')

			winIsFull = getPropertyFromClass('flixel.FlxG', 'fullscreen')
			doTweenX('shake', 'shake', 1, crochet / (1000 / 8), 'cubeIn')

			if getPropertyFromClass('flixel.FlxG', 'fullscreen') then setPropertyFromClass('flixel.FlxG', 'fullscreen', false) end
			savedWidth = getPropertyFromClass('flixel.FlxG', 'stage.window.width')
			savedHeight = getPropertyFromClass('flixel.FlxG', 'stage.window.height')
			setPropertyFromClass('flixel.FlxG', 'stage.window.resizable', false)
			setPropertyFromClass('flixel.FlxG', 'stage.window.width', savedWidth * 1.1)
			setPropertyFromClass('flixel.FlxG', 'stage.window.height', savedHeight * 1.1)

			moveWindow = true
			callMethod('winpos.setPosition', {getPropertyFromClass('flixel.FlxG', 'stage.window.x'), getPropertyFromClass('flixel.FlxG', 'stage.window.y')})
			doTweenX('winposx', 'winpos', (getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.width') - getPropertyFromClass('flixel.FlxG', 'stage.window.width')) / 2, crochet / (1000 / 8), 'cubeInOut')
			doTweenY('winposy', 'winpos', (getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.height') - getPropertyFromClass('flixel.FlxG', 'stage.window.height')) / 2, crochet / (1000 / 8), 'cubeInOut')

			if shadersEnabled and not lowQuality then
				runHaxeCode([[
					game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('glitch').shader), new ShaderFilter(game.getLuaObject('glitch2').shader)];
					game.camHUD.filters = [new ShaderFilter(game.getLuaObject('glitch').shader), new ShaderFilter(game.getLuaObject('glitch2').shader)];
				]])
			end
		end
		if v1 == 'glitchbg' then
			setSpriteShader('iconBF', 'NewGlitch2')
			setSpriteShader('iconOpp', 'NewGlitch2')
			setSpriteShader('iconGlitch', 'NewGlitch2')
			setProperty('iconGlitch.visible', true)
			cancelTween('glitch')
			borderFlick = false
			if not getPropertyFromClass('flixel.FlxG', 'fullscreen') then setPropertyFromClass('flixel.FlxG', 'stage.window.borderless', true) end
			canGlitch = true
			targetCAB = 0.0005
			targetGlitch = 0.1
			targetGlitch2 = 0.055
			sex = 0
			for i = 0,7 do
				setSpriteShader('strumLineNotes.members['..i..']', 'NewGlitch2')
			end
			for i = 0,getProperty('notes.length')-1 do
				setSpriteShader('notes.members['..i..']', 'NewGlitch2')
			end
		end
		if v1 == 'byebyemanual' then
			--doTweenX('xdxddasda', 'xd', 1, 3.1, 'cubeIn')
			doTweenAlpha('xdxddsasasda', 'scorch', 0.3, 3.1, 'cubeIn')
			fucker = true
		end
	end
end

function onDestroy()
	setPropertyFromClass('flixel.FlxG', 'stage.window.borderless', false)
	setPropertyFromClass('flixel.FlxG', 'stage.window.resizable', true)
	setPropertyFromClass('flixel.FlxG', 'stage.window.width', savedWidth)
	setPropertyFromClass('flixel.FlxG', 'stage.window.height', savedHeight)
	if winIsFull then setPropertyFromClass('flixel.FlxG', 'fullscreen', winIsFull) end
end

function onTimerCompleted(t) if t == 'lolero' then scorchedSinging = false end end

function lerp(a, b, t)
	return a + t * (b - a)
end