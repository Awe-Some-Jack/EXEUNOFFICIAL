function onCreate()
	if getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') and (getPropertyFromClass('backend.ClientPrefs', 'data.middlescrollType') == 'mobile' or getPropertyFromClass('backend.ClientPrefs', 'data.mobileOpponentNotes')) then
		setProperty('opponentStrumOffsetY', -90);
	end
end

function onCreatePost()
	makeLuaSprite('bg2', 'bg/deception/bg-f 2', 0, -350)
	scaleObject('bg2', 2.5, 2.5)
	addLuaSprite('bg2')

	makeLuaSprite('bg', 'bg/deception/bg-g 2', 0, -350)
	scaleObject('bg', 2.5, 2.5)
	addLuaSprite('bg')

	makeLuaSprite('overly', 'bg/deception/deseption')
	scaleObject('overly', 2.5, 2.5)
	addLuaSprite('overly', true)

	makeAnimatedLuaSprite('lava', 'bg/lava')
	addAnimationByPrefix('lava', 'idle', 'Símbolo 17', 24, true)
	scaleObject('lava', 2.5, 2.5)
	addLuaSprite('lava', true)

	--RUNNING BG

	makeAnimatedLuaSprite('bgrun', 'bg/deception/laD1', 130, 330)
	addAnimationByPrefix('bgrun', 'idle', 'Símbolo 71', 24, false)
	scaleObject('bgrun', 1.1, 1.1)
	setProperty('bgrun.alpha', 0.0001)
	addLuaSprite('bgrun')

	makeAnimatedLuaSprite('bgrun2', 'bg/deception/laD22', 130, 330)
	addAnimationByPrefix('bgrun2', 'idle', 'Símbolo 71', 24, false)
	scaleObject('bgrun2', 1.1, 1.1)
	setProperty('bgrun2.alpha', 0.0001)
	addLuaSprite('bgrun2')

	--PIXEL BG

	createInstance('bgp', 'flixel.addons.display.FlxBackdrop', {nil, 0x11})
	loadGraphic('bgp', 'bg/deception/pixel/bg')
	callMethod('bgp.setPosition', {-30, -130})
	setScrollFactor('bgp', 0.6, 0.6)
	scaleObject('bgp', 3, 3)
	setProperty('bgp.antialiasing', false)
	setProperty('bgp.alpha', 0.0001)
	addInstance('bgp')

	createInstance('decop', 'flixel.addons.display.FlxBackdrop', {nil, 0x10, 0, 24})
	loadGraphic('decop', 'bg/deception/pixel/deco')
	callMethod('decop.setPosition', {-30, -200})
	setScrollFactor('decop', 0.6, 0.6)
	scaleObject('decop', 3, 3)
	setProperty('decop.antialiasing', false)
	setProperty('decop.alpha', 0.0001)
	addInstance('decop')

	createInstance('torches', 'flixel.addons.display.FlxBackdrop', {nil, 0x10})
	loadGraphic('torches', 'bg/deception/pixel/torches1')
	callMethod('torches.setPosition', {-30, -130})
	setScrollFactor('torches', 0.6, 0.6)
	scaleObject('torches', 3, 3)
	setProperty('torches.antialiasing', false)
	setProperty('torches.alpha', 0.0001)
	addInstance('torches')

	makeAnimatedLuaSprite('picobf', 'bg/deception/pixel/picobf', 2300 + 400, 685)
	addAnimationByPrefix('picobf', 'idle', 'idle', 18, true)
	scaleObject('picobf', 3, 3)
	setProperty('picobf.antialiasing', false)
	setProperty('picobf.alpha', 0.0001)
	setProperty('picobf.angle', 8)
	addLuaSprite('picobf')

	makeAnimatedLuaSprite('reqbeast', 'bg/deception/pixel/reqbeast', 2300, 660)
	addAnimationByPrefix('reqbeast', 'idle', 'idle', 18, true)
	scaleObject('reqbeast', 3, 3)
	setProperty('reqbeast.antialiasing', false)
	setProperty('reqbeast.alpha', 0.0001)
	setProperty('reqbeast.angle', 8)
	addLuaSprite('reqbeast')

	createInstance('floorp', 'flixel.addons.display.FlxBackdrop', {nil, 0x10})
	loadGraphic('floorp', 'bg/deception/pixel/floor')
	callMethod('floorp.setPosition', {-30, -130})
	scaleObject('floorp', 3, 3)
	setProperty('floorp.antialiasing', false)
	setProperty('floorp.alpha', 0.0001)
	addInstance('floorp')

	makeAnimatedLuaSprite('lavapixel', 'bg/deception/pixel/lavapixel', -30, 600)
	addAnimationByPrefix('lavapixel', 'idle', 'idle', 4, true)
	scaleObject('lavapixel', 3, 3)
	setScrollFactor('lavapixel', 1, 0)
	setProperty('lavapixel.antialiasing', false)
	setProperty('lavapixel.alpha', 0.0001)
	addLuaSprite('lavapixel')

	--OTHER

	setProperty('gf.flipX', false)
	setScrollFactor('gf', 1, 1)
	setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup') + 1)

	addCharacterToList('requital-beast-dark', 'dad')
	addCharacterToList('beast-runhead', 'dad')
	addCharacterToList('picod-run', 'gf')
	addCharacterToList('bfd-run', 'bf')

	setProperty('BlackGraphicOther.alpha', 1)

	makeAnimatedLuaSprite('spacebar', 'spacebar', 0, screenHeight * (downscroll and 0.6 or 0.2))
	addAnimationByPrefix('spacebar', 'xd', 'Símbolo 8', 48, false)
	playAnim('spacebar', 'xd', true)
	scaleObject('spacebar', 0.6, 0.6)
	setObjectCamera('spacebar', 'other')
	screenCenter('spacebar', 'x')
	setObjectOrder('spacebar', getObjectOrder('BlackGraphicOther') + 1)
	setProperty('spacebar.alpha', 0)

	setProperty('inCutscene', false)

	runHaxeCode([[
		import shaders.AdjustColorShader;
		var playersColor = new AdjustColorShader();
        playersColor.brightness = -18;
        playersColor.contrast = 18;
        playersColor.hue = -34;
        playersColor.saturation = -23;    
		
		var reqColor = new AdjustColorShader();
        reqColor.brightness = -19;
        reqColor.contrast = -2;
        reqColor.hue = -16;
        reqColor.saturation = -41;    
		
        game.boyfriend.shader = playersColor; 
        game.gf.shader = playersColor; 
		game.dad.shader = reqColor;
	]])
end

function onSongStart()
	doTweenAlpha('abexsda', 'BlackGraphicOther', 0.65, crochet / (1000 / 32), 'expoIn')
end

local running = false
local inPixel = false
local current = 'bgrun'
local repeatbg = false
function onEvent(n,v1)
	if n == 'BGchange' then
		if v1 == 'intro' then
			cancelTween('abexsda')
			setProperty('BlackGraphicOther.alpha', 0)
		end
		if v1 == 'jajaja' then
			running = true
			setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup') - 1)
			triggerEvent('Change Character', 'dad', 'beast-runhead')
			triggerEvent('Change Character', 'gf', 'picod-run')
			triggerEvent('Change Character', 'bf', 'bfd-run')

			removeLuaSprite('bg2', true)
			removeLuaSprite('bg', true)
			removeLuaSprite('overly', true)
			removeLuaSprite('lava', true)

			setProperty('bgrun.alpha', 1)
			playAnim('bgrun', 'idle', true)

			callMethod('gf.setPosition', {getProperty('gf.x') - 350, getProperty('gf.y') - 80})

			setProperty('cameraSpeed', 2)
			setProperty('gameplayCam.settings.BFx', 1150)
			setProperty('gameplayCam.settings.BFy', 1150)

			setProperty('gameplayCam.settings.DADx', 1600)
			setProperty('gameplayCam.settings.DADy', 1100)
		end
		if v1 == 'pixel' then
			setProperty('gameplayCam.settings.MiddleY', 800)
			inPixel = true
			cameraFlash('FFFFFF', 'game', 1, true)
			setProperty('cameraSpeed', 9999)
			setProperty('gf.alpha', 0) setProperty('picolegs.alpha', 0)
			setProperty('gameplayCam.settings.MiddleZoom', 0.7)
			triggerEvent('cameracenter', 'true')
			setProperty('gameplayCam.settings.OffsetsBF', 0)
			setProperty('gameplayCam.settings.OffsetsDAD', 0)
			setProperty('gameplayCam.settings.OffsetsGF', 0)
			running = false

			setProperty('bgrun.alpha', 0) setProperty('bgrun2.alpha', 0)

			setProperty('bgp.alpha', 1) setProperty('floorp.alpha', 1) setProperty('torches.alpha', 1) setProperty('decop.alpha', 1) setProperty('lavapixel.alpha', 1)
			setProperty('reqbeast.alpha', 1) setProperty('picobf.alpha', 1)
			runTimer('torch', 0.25, 0)

			setProperty('picobf.velocity.x', -2500 * playbackRate) setProperty('reqbeast.velocity.x', -2500 * playbackRate)
			setProperty('picobf.velocity.y', -380 * playbackRate) setProperty('reqbeast.velocity.y', -380 * playbackRate)

			doTweenX('camHUDx', 'camHUD', 0, crochet / 500, 'cubeOut')
			doTweenY('camHUDy', 'camHUD', 0, crochet / 500, 'cubeOut')
			doTweenAngle('camHUDa', 'camHUD', 0, crochet / 500, 'cubeOut')
		end
		if v1 == 'back' then
			inPixel = false
			cameraFlash('FFFFFF', 'game', 1, true)
			setProperty('gf.alpha', 1) setProperty('picolegs.alpha', 1)
			triggerEvent('cameracenter', 'false')
			setProperty('gameplayCam.settings.OffsetsBF', 25)
			setProperty('gameplayCam.settings.OffsetsDAD', 25)
			setProperty('gameplayCam.settings.OffsetsGF', 25)
			running = true
			repeatbg = false
			current = 'bgrun'
			setProperty('camGame.zoom', 1.5)
			setProperty('BlackGraphicOther.alpha', 0)

			setProperty('bgrun.alpha', 1)
			setProperty('gameplayCam.settings.BFx', 1150)
			setProperty('gameplayCam.settings.BFy', 1150)

			setProperty('gameplayCam.settings.DADx', 1600)
			setProperty('gameplayCam.settings.DADy', 1100)

			removeLuaSprite('bgp', true) removeLuaSprite('floorp', true) removeLuaSprite('torches', true) removeLuaSprite('decop', true) removeLuaSprite('lavapixel', true)
			removeLuaSprite('reqbeast', true) removeLuaSprite('picobf', true)
		end
		if v1 == 'anim' then
			startVideo('anim', false, true)
			setProperty('inCutscene', false)
		end
		if v1 == 'endcine' then
			cameraFlash('FFFFFF', 'game', 1, true)
			callMethod('remove', {instanceArg('videoCutscene')})
		end
		if v1 == 'dark' then
			running = false
			setProperty('gameplayCam.settings.OffsetsBF', 0)
			setProperty('gameplayCam.settings.OffsetsDAD', 25)
			setProperty('gameplayCam.settings.OffsetsGF', 0)
			cameraFlash('FFFFFF', 'game', 1, true)
			setProperty('cameraSpeed', 9999)
			setProperty('bgrun.alpha', 0) setProperty('bgrun2.alpha', 0)
			triggerEvent('cameracenter', 'true')
			setProperty('gf.alpha', 0) setProperty('picolegs.alpha', 0)
			setProperty('beastlegs.alpha', 0)
			triggerEvent('Change Character', 'dad', 'requital-beast-dark')
			callMethod('dad.setPosition', {565, 200})
			setProperty('dad.alpha', 1)
			setProperty('gameplayCam.settings.MiddleY', 530)

			doTweenX('camHUDx', 'camHUD', 0, crochet / 500, 'cubeOut')
			doTweenY('camHUDy', 'camHUD', 0, crochet / 500, 'cubeOut')
			doTweenAngle('camHUDa', 'camHUD', 0, crochet / 500, 'cubeOut')
		end
		if v1 == 'running' then
			setProperty('gameplayCam.settings.OffsetsBF', 25)
			setProperty('gameplayCam.settings.OffsetsDAD', 25)
			setProperty('gameplayCam.settings.OffsetsGF', 25)
			cameraFlash('FFFFFF', 'game', 1, true)
			running = true
			setProperty('cameraSpeed', 9999)
			setProperty('bgrun.alpha', 1) setProperty('bgrun2.alpha', 1)
			triggerEvent('cameracenter', 'false')
			setProperty('gf.alpha', 1) setProperty('picolegs.alpha', 1)
			setProperty('dad.alpha', 0)
			setProperty('camGame.zoom', 1.5)
			triggerEvent('Change Character', 'dad', 'beast-runhead')
		end
		if v1 == 'fadefinal' then
			doTweenAlpha('BlackGraphicHUDBehind', 'BlackGraphicHUDBehind', 1, crochet / 500, 'expoIn')
		end
		if v1 == 'finale' then
			setProperty('camGame.visible', false)
			setProperty('BlackGraphicHUDBehind.alpha', 0)
			setProperty('cpuAssist', true)
			makeLuaSprite('finale', 'finale')
			setObjectCamera('finale', 'video')
			setGraphicSize('finale', screenWidth, screenHeight)
			updateHitbox('finale')
			screenCenter('finale')
			addLuaSprite('finale')
			setProperty('finale.alpha')
			scaleObject('finale', getProperty('finale.scale.x') * 2.5, getProperty('finale.scale.y') * 2.5, false)
			setProperty('finale.x', getProperty('finale.x') + 700)
			setProperty('finale.y', getProperty('finale.y') + 450)
			setProperty('finale.angle', 25)
			doTweenX('fianas', 'finale', getProperty('finale.x') - 700, crochet / (1000 / 8), 'expoIn')
			doTweenY('fian3241as', 'finale', getProperty('finale.y') - 450, crochet / (1000 / 8), 'expoIn')
			doTweenAngle('fian2313241as', 'finale', 0, crochet / (1000 / 8), 'expoIn')
			startTween('finaasle', 'finale.scale', {x = (getProperty('finale.scale.x') / 2.5), y = (getProperty('finale.scale.y') / 2.5)}, crochet / (1000 / 8), {ease = 'expoIn'})
			doTweenAlpha('finale', 'finale', 1, crochet / 1000, 'cubeOut')
			doTweenAlpha('camHUD', 'camHUD', 0, crochet / 250, 'cubeOut')
		end
		if v1 == 'termino' then
			setProperty('camGame.visible', false) setProperty('camVideo.visible', false) setProperty('camHUD.visible', false)
		end
	end
end

local which = 1
function onTimerCompleted(t)
	if t == 'torch' then
		which = which == 1 and 2 or 1
		loadGraphic('torches', 'bg/deception/pixel/torches'..which)
	end
end

local _graphicLerp = 0
local canPress = false
local thing = 0
local holdTimer = 0
function onUpdatePost(e)
	thing = thing + e * 2
	if inPixel then
		setProperty('gameplayCam.settings.MiddleY', getProperty('gameplayCam.settings.MiddleY') - (e * playbackRate * 360))
		callMethod('camGame.snapToTarget')
		setProperty('lavapixel.y', 700 + math.sin(thing) * 50)

		if keyboardPressed('SPACE') then holdTimer = holdTimer + e else holdTimer = 0 end
		if canPress and keyboardPressed('SPACE') and holdTimer < 0.1 then
			_graphicLerp = 0
			canPress = false

			if getProperty('spacebar.alpha') > 0 then
				cancelTween('spacebar')
				doTweenAlpha('spacebarx', 'spacebar', 0, crochet / 250, 'cubeOut')
			end
		end

		if _graphicLerp < 1 then _graphicLerp = _graphicLerp + 0.001 end

		setProperty('BlackGraphicOther.alpha', lerp(getProperty('BlackGraphicOther.alpha'), _graphicLerp, e * 35))
	end
	if not running then return end
	setProperty('camHUD.angle', math.sin(thing) * 0.75)
	setProperty('camHUD.x', math.cos(thing) * 10)
	setProperty('camHUD.y', math.sin(thing) * 2)
    if getProperty(current..'.animation.curAnim.finished') then
        if repeatbg then current = 'bgrun' repeatbg = false else if getRandomBool(20) then current = 'bgrun2' repeatbg = true else current = 'bgrun' end end
        setProperty('bgrun.alpha', current == 'bgrun' and 1 or 0)
        setProperty('bgrun2.alpha', current == 'bgrun2' and 1 or 0)
        playAnim(current, 'idle', true)
    end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

local once = false
function onBeatHit()
	if not inPixel then return end

	playAnim('spacebar', 'xd', true)

	if curBeat % 4 == 2 then
		canPress = true
		_graphicLerp = 1
		if not once then
			doTweenAlpha('spacebar', 'spacebar', 1, crochet / 1000, 'cubeOut')
			once = true
		end
	end
end

function onSectionHit()
	if not inPixel then return end

	local amount = (curSection % 2 == 0 and -1 or 1)
	setProperty('picobf.velocity.x', 2500 * amount)
	setProperty('reqbeast.velocity.x', 2500 * amount)
	setProperty('picobf.y', getProperty('picobf.y') + (curSection % 2 == 1 and 12 or 37))
	setProperty('reqbeast.y', getProperty('reqbeast.y') + (curSection % 2 == 1 and 12 or 37))
	setProperty('picobf.x', getProperty('picobf.x') + (amount * 400))
	setProperty('reqbeast.x', getProperty('reqbeast.x') - (amount * 400))
	setProperty('picobf.offset.y', -37 + (curSection % 2 == 1 and -16 or -10))
	setProperty('reqbeast.offset.y', -68 + (curSection % 2 == 1 and 7 or 0))
	setProperty('picobf.angle', amount * -8)
	setProperty('reqbeast.angle', amount * -8)
	setProperty('picobf.flipX', curSection % 2 == 1)
	setProperty('reqbeast.flipX', curSection % 2 == 1)
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