local colors = {'ff2323', '4dff23', '2332ff', 'ff2483', 'ffbd24', '24ffc1'}

local function applyColorTheme()
	local c = colors[(curSection % 6) + 1]
	setProperty('hbBG.color', getColorFromHex(c))
	setProperty('separatorHealth.color', getColorFromHex(c))
	setTextBorder('exeScoreTxt', 1, c)
	setTextBorder('hitCounterText', 2, c)
end

local function addShitToTV()
	createInstance('ahh', 'hxvlc.flixel.FlxVideoSprite')
	callMethod('ahh.load', {'mods/SUNKY/images/vanilla/tv/ahhhh.mp4'})
	scaleObject('ahh', 0.5, 0.5)
	callMethod('ahh.setPosition', {480, 100})
	addInstance('ahh')

	createInstance('bestday', 'flxgif.FlxGifSprite')
	callMethod('bestday.loadGif', {'mods/SUNKY/images/vanilla/tv/bestdayever.gif'})
	callMethod('bestday.pauseGif')
	scaleObject('bestday', 0.8, 0.8)
	setProperty('bestday.alpha', 0)
	callMethod('bestday.setPosition', {715, 200})
	addInstance('bestday')

	makeLuaSprite('gato', 'vanilla/tv/Hahahaha', 820, 250)
	setProperty('gato.alpha', 0)
	addLuaSprite('gato')

	makeLuaSprite('disk', 'vanilla/tv/replay', 785, 220)
	setProperty('disk.angularVelocity', 90)
	setProperty('disk.alpha', 0)
	addLuaSprite('disk')

	makeLuaSprite('sans', 'vanilla/tv/sans', 775, 220)
	scaleObject('sans', 8, 8)
	setProperty('sans.alpha', 0)
	setProperty('sans.antialiasing', false)
	addLuaSprite('sans')

	createInstance('majin', 'objects.Character', {730, 200, 'majinsunky', false})
	addInstance('majin')
	setProperty('majin.alpha', 0)

	createInstance('arin', 'hxvlc.flixel.FlxVideoSprite')
	callMethod('arin.load', {"mods/SUNKY/videos/Arin's Dance - GrumpOut.mp4"})
	setProperty('arin.alpha', 0)
	scaleObject('arin', 3, 3)
	setObjectCamera('arin', 'other')
	screenCenter('arin')
	addInstance('arin')
end

function onCreatePost()
	makeLuaSprite('bg', 'bg/bg', -1200, -800)
	addLuaSprite('bg')

	makeLuaSprite('bg2', 'bg/bg', -1200, -800)
	makeGraphic('bg2', getProperty('bg.width'), getProperty('bg.height'), 'FFFFFF')
	addLuaSprite('bg2')
	setProperty('bg2.alpha', 0)

	makeLuaSprite('floor', 'bg/floor', -650, -650)
	scaleObject('floor', 0.9, 0.9)
	addLuaSprite('floor')

	local speakerData = {
		{name = 'speakerL', x = -150},
		{name = 'speakerR', x = 1300, flipX = true},
	}
	for _, sp in ipairs(speakerData) do
		makeAnimatedLuaSprite(sp.name, 'bg/speaker', sp.x, -260)
		addAnimationByPrefix(sp.name, 'idle', 'dance lol', 24, false)
		scaleObject(sp.name, 0.9, 0.9)
		if sp.flipX then setProperty(sp.name .. '.flipX', true) end
		addLuaSprite(sp.name)
	end

	makeLuaSprite('blackPuta', nil, -620, 120)
	makeGraphic('blackPuta', screenWidth * 2, screenHeight * 2, '000000')
	setProperty('blackPuta.alpha', 0)
	setObjectOrder('blackPuta', getObjectOrder('dadGroup'))
	addLuaSprite('blackPuta')

	makeAnimatedLuaSprite('disco', 'bg/disco-ball', 650, -800)
	addAnimationByPrefix('disco', 'idle', 'dance', 24, true)
	playAnim('disco', 'idle', true)
	addLuaSprite('disco')

	makeLuaSprite('tvbg', 'vanilla/tv/black_screen', 717, 208)
	addLuaSprite('tvbg')
	setProperty('tvbg.color', getColorFromHex('000000'))

	addShitToTV()

	makeLuaSprite('tv', 'vanilla/tv/tv', 650, 150)
	addLuaSprite('tv')

	for i = 0, 3 do
		local strumW = getProperty('opponentStrums.members[' .. i .. '].width')
		setProperty('opponentStrums.members[' .. i .. '].x', 10 + (strumW * i))
		setProperty('playerStrums.members[' .. i .. '].x', (screenWidth - 10 - (strumW * 4)) + (strumW * i))
	end

	applyColorTheme()

	makeLuaSprite('blackwhite')
	setSpriteShader('blackwhite', 'blackwhite')
end

function goodNoteHit(id,nd,nt,isn)
	playAnim('majin', getProperty('singAnimations['..nd..']'), true)
	setProperty('majin.holdTimer', 0)
end

function opponentNoteHit(id,nd,nt,isn)
	playAnim('majin', getProperty('singAnimations['..nd..']'), true)
	setProperty('majin.holdTimer', 0)
end

function onBeatHit()
	if curBeat % 2 == 0 then
		playAnim('speakerL', 'idle', true)
		playAnim('speakerR', 'idle', true)
	end
end

function onSectionHit()
	applyColorTheme()
end

--video functions, ignore

function onGameOver()
	if curBeat < 544 then
		if getProperty('ahh') == nil then return end
		callMethod('ahh.destroy')
		callMethod('remove', {instanceArg('ahh')})
	else
		if getProperty('arin') == nil then return end
		callMethod('arin.destroy')
		callMethod('remove', {instanceArg('arin')})
	end
end

function onDestroy()
	if curBeat < 544 then
		if getProperty('ahh') == nil then return end
		callMethod('remove', {instanceArg('ahh')})
	else
		if getProperty('arin') == nil then return end
		callMethod('remove', {instanceArg('arin')})
	end
end

function onPause()
    if curBeat < 544 then
		if getProperty('ahh') == nil then return end
		callMethod('ahh.pause')
		if callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('ahh.videoSprite.pause')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusLost.remove', {instanceArg('ahh.videoSprite.pause')})
		end
		if callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('ahh.videoSprite.resume')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusGained.remove', {instanceArg('ahh.videoSprite.resume')})
		end
	else
		if getProperty('arin') == nil then return end
		callMethod('arin.pause')
		if callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('arin.videoSprite.pause')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusLost.remove', {instanceArg('arin.videoSprite.pause')})
		end
		if callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('arin.videoSprite.resume')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusGained.remove', {instanceArg('arin.videoSprite.resume')})
		end
	end
end

function onResume()
	if curBeat < 544 then
		if getProperty('ahh') == nil then return end
		callMethod('ahh.resume')
		if not callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('ahh.videoSprite.pause')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusLost.add', {instanceArg('ahh.videoSprite.pause')})
		end
		if not callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('ahh.videoSprite.resume')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusGained.add', {instanceArg('ahh.videoSprite.resume')})
		end
	else
		if getProperty('arin') == nil then return end
		callMethod('arin.resume')
		if not callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('arin.videoSprite.pause')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusLost.add', {instanceArg('arin.videoSprite.pause')})
		end
		if not callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('arin.videoSprite.resume')}) then
			callMethodFromClass('flixel.FlxG', 'signals.focusGained.add', {instanceArg('arin.videoSprite.resume')})
		end
	end
end