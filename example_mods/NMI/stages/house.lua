local separation = 50

runHaxeCode([[
	import flixel.math.FlxAngle;
	function setShaderFrameInfo(obj:String) {
		var char:FlxSprite;
		switch(obj) {
			case 'boyfriend':
				char = game.boyfriend;
			case 'dad':
				char = game.dad;
			case 'gf':
				char = game.gf;
		}

        char.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
			if (char.shader != null) {
				char.shader.setFloatArray('uFrameBounds', [char.frame.uv.x, char.frame.uv.y, char.frame.uv.width, char.frame.uv.height]);
				char.shader.setFloat('angOffset', char.frame.angle * FlxAngle.TO_RAD);
			}
        }
	}
]])


for i = 1,4 do precacheImage('renders/render'..i) end

setProperty('skipArrowStartTween', true)
function onCreatePost()
	--precache video
	startVideo('fakebabyfinal', false, true, false, false)
	startVideo('fakebaby', false, true, false, false)
	if getProperty('videoCutscene') == nil then return end
    callMethod('remove', {instanceArg('videoCutscene')})
	setProperty('inCutscene', false)
	setProperty('boyfriend.alpha', 0)
	addCharacterToList('nmi2', 'dad')
	addCharacterToList('nmi3', 'dad')
	addCharacterToList('finaldd', 'boyfriend')
	setScrollFactor('boyfriend', 0.3, 0.3)

	for _,obj in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(obj..'.alpha') end
	for i = 0,3 do
		setProperty('opponentStrums.members['..i..'].x', -1000)
		setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
		setProperty('playerStrums.members['..i..'].alpha', 0) setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] + (downscroll and 25 or -25))
	end

	--bg 1

	makeAnimatedLuaSprite('daSTAT', 'daSTAT', -255, -135)
	scaleObject('daSTAT', 3, 3)
	addAnimationByPrefix('daSTAT', 'idle', 'staticFLASH', 24, true)
	addLuaSprite('daSTAT')
	setProperty('daSTAT.color', getColorFromHex('FF0000'))
	setProperty('daSTAT.alpha', 0)

	makeLuaSprite('bgtv', 'bg/tv/3', -1700, -800)
	addLuaSprite('bgtv', true)

	makeLuaSprite('tvglow', 'bg/tv/glow', -1700, -800)
	addLuaSprite('tvglow', true)
	setBlendMode('tvglow', 'screen')
	setProperty('tvglow.alpha', 0)

	makeLuaSprite('fgtv1', 'bg/tv/1', -1300, -1000)
	setScrollFactor('fgtv1', 0.5, 0.5)
	addLuaSprite('fgtv1', true)

	makeLuaSprite('fgtv2', 'bg/tv/2', -2100, -1000)
	setScrollFactor('fgtv2', 1.2, 1.2)
	addLuaSprite('fgtv2', true)

	--bg 2

	makeLuaSprite('sky', 'bg/pov/sky', -530, -300)
	addLuaSprite('sky')
	setScrollFactor('sky', 0.3, 0.3)
	setProperty('sky.alpha', 0.0001)

	createInstance('clouds', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('clouds', 'bg/pov/clouds')
	addInstance('clouds')
	setProperty('clouds.velocity.x', 10)
	setScrollFactor('clouds', 0.5, 0.5)
	setProperty('clouds.alpha', 0.0001)

	makeLuaSprite('trees3', 'bg/pov/bg3', -750, -50)
	addLuaSprite('trees3')
	scaleObject('trees3', 1.1, 1.1)
	setScrollFactor('trees3', 0.65, 0.65)
	setProperty('trees3.alpha', 0.0001)
	
	makeLuaSprite('trees2', 'bg/pov/bg2', -760, -760)
	addLuaSprite('trees2')
	scaleObject('trees2', 1.1, 1.1)
	setScrollFactor('trees2', 0.75, 0.75)
	setProperty('trees2.alpha', 0.0001)

	makeLuaSprite('trees1', 'bg/pov/bg1', -780, -760)
	addLuaSprite('trees1')
	scaleObject('trees1', 1.1, 1.1)
	setScrollFactor('trees1', 0.85, 0.85)
	setProperty('trees1.alpha', 0.0001)

	makeLuaSprite('floorpov', 'bg/pov/floor', -830, -510)
	addLuaSprite('floorpov')
	scaleObject('floorpov', 1.1, 1.1)
	setProperty('floorpov.alpha', 0.0001)

	makeLuaSprite('whiteBG')
	makeGraphic('whiteBG', screenWidth, screenHeight, 'FFFFFF')
	setObjectCamera('whiteBG', 'hud')
	setObjectOrder('whiteBG', getObjectOrder('hbBG') - 1)
	screenCenter('whiteBG')
	setProperty('whiteBG.alpha', 0)
end

local function makeThirdBG()
	makeLuaSprite('room', 'bg/room/4', -960, -660)
	addLuaSprite('room')
	scaleObject('room', 0.9, 0.9)
	setProperty('room.alpha', 0.0001)

	makeLuaSprite('roomfg1', 'bg/room/1', -1210, -360)
	addLuaSprite('roomfg1')
	scaleObject('roomfg1', 0.9, 0.9)
	setScrollFactor('roomfg1', 1.2, 1.2)
	setProperty('roomfg1.alpha', 0.0001)

	makeLuaSprite('roomfg2', 'bg/room/2', -960, -810)
	addLuaSprite('roomfg2')
	scaleObject('roomfg2', 0.9, 0.9)
	setScrollFactor('roomfg2', 1.2, 1.2)
	setProperty('roomfg2.alpha', 0.0001)

	makeLuaSprite('roomfg3', 'bg/room/3', -960, -810)
	addLuaSprite('roomfg3')
	scaleObject('roomfg3', 0.9, 0.9)
	setScrollFactor('roomfg3', 1.2, 1.2)
	setProperty('roomfg3.alpha', 0.0001)

	makeLuaSprite('overlay', 'bg/room/5')
	addLuaSprite('overlay')
	screenCenter('overlay')
	setObjectCamera('overlay', 'other')
	setProperty('overlay.alpha', 0.0001)
end

function onSongStart()
	runTimer('startVideo', 0.3)
end

function onTimerCompleted(t)
	if t == 'startVideo' then
		startVideo('fakebaby', false, true)
		runTimer('lol', 0.2)
		setProperty('inCutscene', false)
		setProperty('videoCutscene.videoSprite.volumeAdjust', 0)
	end
	if t == 'daSTAT' then
		setProperty('daSTAT.alpha', 0)
		setProperty('bgtv.color', getColorFromHex('FFFFFF'))
		setProperty('fgtv1.color', getColorFromHex('FFFFFF'))
		setProperty('fgtv2.color', getColorFromHex('FFFFFF'))
		setProperty('tvglow.alpha', 0)
	end
	if t == 'sexonomorexd' then setProperty('cameraSpeed', 1) end
	if stringStartsWith(t, 'render') then doTweenAlpha(t, t, 0, crochet / (1000 / 8), 'cubeInOut') end
end

local flashNum = 0
local canRandomStatic = false
local currentBG = 1
function onEvent(n,v1,v2)
	if n == 'innocenceEvents' then
		if v1 == 'hudappear' then
			for _,obj in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do doTweenAlpha(obj, obj, 1, crochet / 250) end
			for i = 0,7 do setProperty('strumLineNotes.members['..i..'].alpha', 0) end
		end
		if v1 == 'notesappear' then
			for i = 0,3 do
				startTween('sexo'..i, 'playerStrums.members['..i..']', {y = _G['defaultPlayerStrumY'..i], alpha = 1}, crochet / (1000 / 8), {startDelay = (i / 2), ease = 'cubeOut'})
			end
		end
		if v1 == 'appear' then
			cancelTimer('startVideo')
			if getProperty('videoCutscene') == nil then return end
    		callMethod('remove', {instanceArg('videoCutscene')})
		end

		if v1 == 'startzoomin' then
			if getSongPosition() < 62020 then
				startTween('tween_zoomIn', 'camGame', {zoom = 30}, crochet / (1000 / 35), {ease = 'expoIn'})
			end
		end
		if v1 == 'daprespeedup' then
			canRandomStatic = true
		end
		if v1 == 'speedupzoom' then
			if getSongPosition() < 62020 then
				cancelTween('zoomIn')
				callMethodFromClass('flixel.tweens.FlxTween', 'cancelTweensOf', {instanceArg('camGame')})
				startTween('tween_zoomIn', 'camGame', {zoom = 30}, crochet / (1000 / 2), {ease = 'expoIn'})
				doTweenAlpha('whiteBG', 'whiteBG', 1, crochet / (1000 / 1.5), 'expoIn')
			end
		end
		if v1 == 'changebg' then
			removeSpriteShader('dad')
			triggerEvent('Change Character', 'dad', 'nmi2')
			triggerEvent('cameracenter', 'false')
			triggerEvent('Set customCamera Angle', 'bf', '-5')
			triggerEvent('Set Character Offset', 'dad', '60')
			triggerEvent('Set Character Offset', 'bf', '150')
			triggerEvent('Set customCamera Zoom', 'OGZoom', '1')
			triggerEvent('Change Health Damage', '0.015')
			callMethod('dad.setPosition', {100, 150})
			setProperty('boyfriend.alpha', 0.5)

			cancelTween('whiteBG')
			setProperty('whiteBG.alpha', 0)

			removeLuaSprite('daSTAT', true)
			removeLuaSprite('tvglow', true)
			removeLuaSprite('bgtv', true)
			removeLuaSprite('fgtv1', true)
			removeLuaSprite('fgtv2', true)

			setProperty('sky.alpha', 1)
			setProperty('clouds.alpha', 1)
			setProperty('trees3.alpha', 1)
			setProperty('trees2.alpha', 1)
			setProperty('trees1.alpha', 1)
			setProperty('floorpov.alpha', 1)

			canRandomStatic = false
			currentBG = 2

			for i = 0,7 do setProperty('strumLineNotes.members['..i..'].texture', 'noteSkins/NOTERED_assets') end
			for i = 0,getProperty('notes.length')-1 do setProperty('notes.members['..i..'].texture', 'noteSkins/NOTERED_assets') end
			for i = 0,getProperty('unspawnNotes.length')-1 do setProperty('unspawnNotes['..i..'].texture', 'noteSkins/NOTERED_assets') end

			makeThirdBG()

			setProperty('cpuAssist', true)
		end
		if v1 == 'flashback' then
			flashNum = flashNum + 1
			cancelTween('render')
			makeLuaSprite('render', 'renders/render'..((flashNum % 4) + 1))
			scaleObject('render', 0.34, 0.34)
			addLuaSprite('render')
			setObjectCamera('render', 'other')
			screenCenter('render')
			doTweenAlpha('render', 'render', 0, crochet / (1000 / 2), 'cubeInOut')
		end
		if v1 == 'redfadein' then
			setProperty('whiteBG.color', getColorFromHex('FF0000'))
			doTweenAlpha('whiteBG', 'whiteBG', 1, crochet / (1000 / 4), 'cubeIn')
		end
		if v1 == 'changebgfinal' then
			cancelTween('whiteBG')
			doTweenAlpha('whiteBG', 'whiteBG', 0, crochet / (1000 / 4), 'cubeOut')

			cancelTween('dasdadsdafasdg54r')
			triggerEvent('Set customCamera Zoom', 'OGZoom', '0.6')
			setProperty('camGame.zoom', 0.6)
			setProperty('cameraSpeed', 9999)
			runTimer('sexonomorexd', 0.1)

			triggerEvent('Change Character', 'dad', 'nmi3')
			triggerEvent('Change Character', 'bf', 'finaldd')
			triggerEvent('Set customCamera Position', 'bf', '800, 250')
			triggerEvent('Set customCamera Angle', 'bf', '0')
			triggerEvent('Set Character Offset', 'dad', '25')
			triggerEvent('Set Character Offset', 'bf', '25')

			removeLuaSprite('sky', true)
			removeLuaSprite('clouds', true)
			removeLuaSprite('trees3', true)
			removeLuaSprite('trees2', true)
			removeLuaSprite('trees1', true)
			removeLuaSprite('floorpov', true)

			setProperty('room.alpha', 1)
			setProperty('roomfg1.alpha', 1)
			setProperty('roomfg2.alpha', 1)
			setProperty('roomfg3.alpha', 1)
			doTweenAlpha('overlay', 'overlay', 1, crochet / 500)

			setProperty('boyfriend.alpha', 1)
			setScrollFactor('boyfriend', 1, 1)
			callMethod('dad.setPosition', {-300, -50})
			callMethod('boyfriend.setPosition', {1000, 80})
			
			currentBG = 3

			for i = 0,7 do setProperty('strumLineNotes.members['..i..'].texture', 'noteSkins/NOTE_assets') end
			for i = 0,getProperty('notes.length')-1 do setProperty('notes.members['..i..'].texture', 'noteSkins/NOTE_assets') end
			for i = 0,getProperty('unspawnNotes.length')-1 do setProperty('unspawnNotes['..i..'].texture', 'noteSkins/NOTE_assets') end

			if shadersEnabled then
				for _,char in ipairs({'boyfriend'}) do
					setSpriteShader(char, 'DropShadowShader')
					setShaderFloat(char, 'hue', 0)
					setShaderFloat(char, 'saturation', 0)
					setShaderFloat(char, 'contrast', 0)
					setShaderFloat(char, 'str', 1)
					setShaderFloat(char, 'brightness', -30)
					setShaderFloat(char, 'thr', 0.1)
					setShaderFloatArray(char, 'dropColor', {255 / 255, 0 / 255, 0 / 255})
					runHaxeFunction('setShaderFrameInfo', {char})
				end
				setShaderFloat('boyfriend', 'ang', math.rad(180))
				setShaderFloat('boyfriend', 'dist', 20)
			end
		end
		if v1 == 'finale' then
			for _,obj in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do doTweenAlpha(obj, obj, 0, crochet / 250) end
			for i = 0,3 do
				startTween('sexo'..i, 'playerStrums.members['..i..']', {y = _G['defaultPlayerStrumY'..i] + (downscroll and 25 or -25), alpha = 0}, crochet / (1000 / 8), {startDelay = (i / 2), ease = 'cubeOut'})
			end

			startVideo('fakebabyfinal', false, true)
			setProperty('inCutscene', false)
			setProperty('videoCutscene.videoSprite.volumeAdjust', 0)

			setProperty('camZoomingMult', 0)
			setProperty('bloom2.x', -1) setProperty('bloom3.x', 0)
		end
	end
end

function onUpdatePost()
	if canRandomStatic and getProperty('daSTAT.alpha') == 0 and getRandomBool(5) then
		setProperty('daSTAT.alpha', 1)
		runTimer('daSTAT', getRandomFloat(0.02, 0.1))
		setProperty('bgtv.color', getColorFromHex('FF0000'))
		setProperty('fgtv1.color', getColorFromHex('FF0000'))
		setProperty('fgtv2.color', getColorFromHex('FF0000'))
		setProperty('tvglow.alpha', 0.5)
	end
end

local oldHitSection = false
function onSectionHit()
	if currentBG ~= 2 then return end
	if mustHitSection ~= oldHitSection then
		cancelTween('dasdadsdafasdg54r')
		triggerEvent('Set customCamera Zoom', 'OGZoom', (mustHitSection and '0.75' or '1'))
		doTweenAlpha('dasdadsdafasdg54r', 'boyfriend', mustHitSection and 1 or 0.5, crochet / 250, 'cubeOut')
	end
	oldHitSection = mustHitSection
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