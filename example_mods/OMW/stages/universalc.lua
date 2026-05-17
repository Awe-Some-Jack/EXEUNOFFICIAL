local universe = false

local planetsPos = {
	{
		x = 800,
		y = 300
	},
	{
		x = 1000,
		y = -300
	},
	{
		x = -450,
		y = -250
	},
	{
		x = -450,
		y = 400
	}
}

function onCreatePost()
	makeLuaSprite('sky', 'universal-collapse/7', -600, -500)
	setScrollFactor('sky', 0.2, 0.2)
	addLuaSprite('sky')

	makeLuaSprite('clouds', 'universal-collapse/6', -600, -500)
	setScrollFactor('clouds', 0.2, 0.2)
	addLuaSprite('clouds')

	makeLuaSprite('mountains', 'universal-collapse/5', -750, -900)
	setScrollFactor('mountains', 0.5, 0.5)
	addLuaSprite('mountains')

	makeLuaSprite('waterfall', 'universal-collapse/3', -850, -250)
	setScrollFactor('waterfall', 0.65, 0.65)
	addLuaSprite('waterfall')

	makeLuaSprite('fog2', 'universal-collapse/4', -800, 50)
	setScrollFactor('fog2', 0.6, 0.6)
	addLuaSprite('fog2')

	makeLuaSprite('trees2', 'universal-collapse/2', -950, -200)
	setScrollFactor('trees2', 0.78, 0.78)
	addLuaSprite('trees2')

	makeLuaSprite('trees', 'universal-collapse/1', -970, -50)
	setScrollFactor('trees', 0.85, 0.85)
	addLuaSprite('trees')

	makeLuaSprite('omwograd', 'characters/omwograd', -600, -200)
	setObjectOrder('omwograd', getObjectOrder('dadGroup') + 1)
	scaleObject('omwograd', 1000, 1)
	addLuaSprite('omwograd')

	makeLuaSprite('gradient', 'universal-collapse/gradient', -600, -1000)
	scaleObject('gradient', 1, 2000)
	setBlendMode('gradient', 'add')
	setProperty('gradient.angle', 90)
	addLuaSprite('gradient', true)

	--universo

	makeLuaSprite('universe', 'universal-collapse/universe/universo', -650, -300)
	scaleObject('universe', 0.6, 0.6)
	setScrollFactor('universe', 0.2, 0.2)
	addLuaSprite('universe')
	setProperty('universe.visible', false)

	for i = 1,4 do
		makeLuaSprite('planet'..i, 'universal-collapse/universe/p'..i, -650, -300)
		scaleObject('planet'..i, 0.6, 0.6)
		setScrollFactor('planet'..i, 0.45, 0.45)
		addLuaSprite('planet'..i)
		setProperty('planet'..i..'.visible', false)
	end

	makeLuaSprite('piedra', 'universal-collapse/universe/piedra', -105, 380)
	scaleObject('piedra', 0.8, 0.8)
	setScrollFactor('piedra', 1, 1)
	setProperty('piedra.visible', false)
	setObjectOrder('piedra', getObjectOrder('boyfriendGroup'))

	makeLuaSprite('blackScreen')
	makeGraphic('blackScreen', screenWidth, screenHeight, 'FFFFFF')
	setProperty('blackScreen.color', getColorFromHex('000000'))
	setObjectCamera('blackScreen', 'other')
	addLuaSprite('blackScreen')
	setProperty('blackScreen.alpha', 0)

	setProperty('sky.visible', false)
	setProperty('clouds.visible', false)
	setProperty('mountains.visible', false)
	setProperty('waterfall.visible', false)
	setProperty('fog2.visible', false)
	setProperty('trees2.visible', false)
	setProperty('trees.visible', false)
	setProperty('gradient.visible', false)

	startVideo('omwintro', false, true, false, false)
	if getProperty('videoCutscene') == nil then return end
    callMethod('remove', {instanceArg('videoCutscene')})
	setProperty('inCutscene', false)

	setProperty('camGame.alpha', 0)
	setProperty('camHUD.alpha', 0)

	setSpriteShader('boyfriend', 'blackwhite')
end

function onSongStart()
	startVideo('omwintro', false, true)
	setProperty('inCutscene', false)
end

local planetSine = 0
function onUpdatePost(e)
	if universe then
		planetSine = planetSine + e
		for i = 1,4 do
			setProperty('planet'..i..'.x', planetsPos[i].x + math.sin(planetSine + i) * 20)
			setProperty('planet'..i..'.y', planetsPos[i].y + math.cos(planetSine + i) * 20)
			setProperty('planet'..i..'.angle', math.cos(planetSine + i) * 5)
		end

		setProperty('piedra.x', -175 + math.sin(planetSine) * 10)
		setProperty('piedra.y', 350 + math.cos(planetSine) * 10)
		setProperty('piedra.angle', math.cos(planetSine) * 5)

		setProperty('boyfriend.x', -120 + math.sin(planetSine) * 10)
		setProperty('boyfriend.y', 200 + math.cos(planetSine) * 10)
		setProperty('boyfriend.angle', math.cos(planetSine) * 5)

		--setProperty('camHUD.zoom', 0.7)
		setProperty('camHUD.x', math.sin(planetSine / 2) * 5)
		setProperty('camHUD.y', math.cos(planetSine / 2) * 5)
		setProperty('camHUD.angle', math.cos(planetSine / 2 + (math.pi / 2)) * 2)
	end
end

local colors = {'9EF600', '0603FB', 'FF01D6', 'FFFFFF', '01BBC8', 'F80A02', '393939', 'FF44B0'}
function onStepHit()
	if universe then
		setProperty('hbHealth2.color', getColorFromHex(colors[getRandomInt(1,8)]))
	end
end

function onEvent(n,v1) if n == 'omwEvents' then if v1 == 'startUniverse' then universe = true end end end

local separation = 30

function onCountdownStarted()
	for i = 0,3 do
		setProperty('opponentStrums.members['..i..'].x', -1000)
		setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
	end
end

function onSectionHit()
	if not getProperty('gameplayCam.settings.MiddleCamera') then
		if mustHitSection then
			setProperty('gameplayCam.settings.OGZoom', 1.35)
		else
			setProperty('gameplayCam.settings.OGZoom', 0.8)
		end
	end
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