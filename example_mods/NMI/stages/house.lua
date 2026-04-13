local separation = 50

setProperty('skipArrowStartTween', true)
function onCreatePost()
	--precache video
	startVideo('fake baby intro hd', false, true, false, false)
	setProperty('inCutscene', false)
	setProperty('boyfriend.alpha', 0)
	addCharacterToList('nmi2', 'dad')
	setScrollFactor('boyfriend', 0.3, 0.3)

	for _,obj in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(obj..'.alpha') end
	for i = 0,3 do
		setProperty('opponentStrums.members['..i..'].x', -1000)
		setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
		setProperty('playerStrums.members['..i..'].alpha', 0) setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] + (downscroll and 25 or -25))
	end

	--bg 1

	makeLuaSprite('bgtv', 'bg/tv/3', -1700, -800)
	addLuaSprite('bgtv', true)

	makeLuaSprite('fgtv1', 'bg/tv/1', -1700, -800)
	addLuaSprite('fgtv1', true)

	makeLuaSprite('fgtv2', 'bg/tv/2', -1700, -800)
	addLuaSprite('fgtv2', true)

	--bg 2

	makeLuaSprite('sky', 'bg/pov/sky', -730, -100)
	addLuaSprite('sky')
	setScrollFactor('sky', 0.65, 0.65)
	setProperty('sky.alpha', 0.0001)

	createInstance('clouds', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('clouds', 'bg/pov/clouds')
	addInstance('clouds')
	setProperty('clouds.velocity.x', 10)
	setScrollFactor('clouds', 0.5, 0.5)
	setProperty('clouds.alpha', 0.0001)

	makeLuaSprite('trees3', 'bg/pov/bg3', -750, -90)
	addLuaSprite('trees3')
	scaleObject('trees3', 1.1, 1.1)
	setScrollFactor('trees3', 0.65, 0.65)
	setProperty('trees3.alpha', 0.0001)
	
	makeLuaSprite('trees2', 'bg/pov/bg2', -760, -90)
	addLuaSprite('trees2')
	scaleObject('trees2', 1.1, 1.1)
	setScrollFactor('trees2', 0.75, 0.75)
	setProperty('trees2.alpha', 0.0001)

	makeLuaSprite('trees1', 'bg/pov/bg1', -780, -90)
	addLuaSprite('trees1')
	scaleObject('trees1', 1.1, 1.1)
	setScrollFactor('trees1', 0.85, 0.85)
	setProperty('trees1.alpha', 0.0001)

	makeLuaSprite('floorpov', 'bg/pov/floor', -830, -100)
	addLuaSprite('floorpov')
	scaleObject('floorpov', 1.1, 1.1)
	setProperty('floorpov.alpha', 0.0001)
end

function onCountdownTick(c) setProperty('countdownReady.x', -1000) setProperty('countdownSet.x', -1000) setProperty('countdownGo.x', -1000) end

function onSongStart()
	runTimer('startVideo', 0.3)
end

function onTimerCompleted(t)
	if t == 'startVideo' then
		startVideo('fake baby intro hd', false, true)
		runTimer('lol', 0.2)
		setObjectCamera('videoCutscene', 'hud')
		setObjectOrder('videoCutscene', 0)
		setProperty('inCutscene', false)
		setProperty('videoCutscene.videoSprite.volumeAdjust', 0)
	end
end

local currentBG = 1
function onEvent(n,v1)
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
			if getSongPosition() < 62020 then startTween('zoomIn', 'camGame', {zoom = 30}, crochet / (1000 / 8), {ease = 'cubeIn'}) end
		end
		if v1 == 'changebg' then
			triggerEvent('Change Character', 'dad', 'nmi2')
			triggerEvent('Set customCamera Angle', 'bf', '-3')
			triggerEvent('Set customCamera Zoom', 'MiddleZoom', '1')
			triggerEvent('Change Health Damage', '0.015')
			callMethod('dad.setPosition', {100, 150})
			setProperty('boyfriend.alpha', 0.5)

			removeLuaSprite('bgtv', true)
			removeLuaSprite('fgtv1', true)
			removeLuaSprite('fgtv2', true)

			setProperty('sky.alpha', 1)
			setProperty('clouds.alpha', 1)
			setProperty('trees3.alpha', 1)
			setProperty('trees2.alpha', 1)
			setProperty('trees1.alpha', 1)
			setProperty('floorpov.alpha', 1)

			currentBG = 2
		end
	end
end

function goodNoteHitPre(id,nd,nt,isn)
	if currentBG ~= 2 or nt == 'No Animation' then return end
	if nd == 0 then
		triggerEvent('Set Character Offset', 'bf', '150')
	elseif nd == 1 then
		triggerEvent('Set Character Offset', 'bf', '75')
	elseif nd == 2 then
		triggerEvent('Set Character Offset', 'bf', '25')
	elseif nd == 3 then
		triggerEvent('Set Character Offset', 'bf', '150')
	end
end

local oldHitSection = false
function onSectionHit()
	if currentBG ~= 2 then return end
	if mustHitSection ~= oldHitSection then
		triggerEvent('Set customCamera Zoom', 'OGZoom', (mustHitSection and '0.75' or '1.1'))
		triggerEvent('cameracenter', 'false')
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