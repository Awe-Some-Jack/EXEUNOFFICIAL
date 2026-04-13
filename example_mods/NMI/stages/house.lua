function onCreatePost()
	--precache video
	startVideo('fake baby intro hd', false, true, false, false)
	setProperty('inCutscene', false)

	setProperty('BlackGraphicOther.alpha', 1)
	setProperty('boyfriend.alpha', 0)
	setProperty('camHUD.alpha', 0)
	addCharacterToList('nmi2', 'dad')

	--bg 1

	makeLuaSprite('bgtv', 'bg/tv/3', -1700, -800)
	addLuaSprite('bgtv', true)

	makeLuaSprite('fgtv1', 'bg/tv/1', -1700, -800)
	addLuaSprite('fgtv1', true)

	makeLuaSprite('fgtv2', 'bg/tv/2', -1700, -800)
	addLuaSprite('fgtv2', true)

	--bg 2
end

function onSongStart() runTimer('startVideo', 0.3) end

function onTimerCompleted(t)
	if t == 'startVideo' then
		startVideo('fake baby intro hd', false, true)
		runTimer('lol', 0.2)
		setProperty('inCutscene', false)
		setProperty('videoCutscene.videoSprite.volumeAdjust', 0)
	end
end

function onEvent(n,v1)
	if n == 'innocenceEvents' then
		if v1 == 'postvideo' then
			setProperty('BlackGraphicOther.alpha', 0)
			setProperty('camHUD.alpha', 1)

			cancelTimer('startVideo')
			if getProperty('videoCutscene') == nil then return end
    		callMethod('remove', {instanceArg('videoCutscene')})
		end

		if v1 == 'startzoomin' then
			startTween('zoomIn', 'camGame', {zoom = 20}, crochet / 250, {ease = 'cubeIn'})
		end
		if v1 == 'changebg' then
			triggerEvent('Change Character', 'dad', 'nmi2')
			triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.9')
			setProperty('boyfriend.alpha', 1)
			removeLuaSprite('bgtv', true)
			removeLuaSprite('fgtv1', true)
			removeLuaSprite('fgtv2', true)
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