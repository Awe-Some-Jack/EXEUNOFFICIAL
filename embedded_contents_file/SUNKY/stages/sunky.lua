local colors = {'ff2323', '4dff23', '2332ff', 'ff2483', 'ffbd24', '24ffc1'}
local videos = {'ahh', 'bestday', 'arin'}

local function applyColorTheme()
	local c = colors[(curSection % 6) + 1]
	setProperty('hbBG.color', getColorFromHex(c))
	setProperty('separatorHealth.color', getColorFromHex(c))
	setTextBorder('exeScoreTxt', 1, c)
	setTextBorder('hitCounterText', 2, c)
end

local function addShitToTV()
	createInstance('ahh', 'hxvlc.flixel.FlxVideoSprite')
	callMethod('ahh.load', {'contents/SUNKY/images/vanilla/tv/ahhhh.mp4'})
	scaleObject('ahh', 0.5, 0.5)
	callMethod('ahh.setPosition', {480, 100})
	addInstance('ahh')

	createInstance('bestday', 'hxvlc.flixel.FlxVideoSprite')
	callMethod('bestday.load', {'contents/SUNKY/images/vanilla/tv/bestdayever.mp4'})
	scaleObject('bestday', 0.8, 0.8)
	callMethod('bestday.setPosition', {670, 160})
	addInstance('bestday')
	runHaxeCode([[
		game.getLuaObject('bestday').bitmap.onEndReached.add(() ->
		{
			final path = 'contents/SUNKY/images/vanilla/tv/bestdayever.mp4';
			if (game.getLuaObject('bestday').load(path)) {
				new FlxTimer().start(0.001, (_) -> { 
					game.getLuaObject('bestday').play(); 
					game.getLuaObject('bestday').bitmap.rate = 1.0; 
				});
			}
		});
	]])

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
	callMethod('arin.load', {"contents/SUNKY/videos/Arin's Dance - GrumpOut.mp4"})
	setProperty('arin.alpha', 0)
	scaleObject('arin', 3, 3)
	setObjectCamera('arin', 'other')
	screenCenter('arin')
	addInstance('arin')
	runHaxeCode([[
		game.getLuaObject('arin').bitmap.onFormatSetup.add(() -> {
			game.getLuaObject('arin').setGraphicSize(FlxG.width, FlxG.height);
			game.getLuaObject('arin').updateHitbox();
			game.getLuaObject('arin').screenCenter();
		});
	]])
end

function onCreate()
	if getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') and (getPropertyFromClass('backend.ClientPrefs', 'data.middlescrollType') == 'mobile' or getPropertyFromClass('backend.ClientPrefs', 'data.mobileOpponentNotes')) then
		setProperty('opponentStrumOffsetY', -60);
	end
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

	runHaxeCode([[
		for (strum in game.strumLineNotes)
		{
			strum.animOffsets.clear();
			strum.playAnim('static', true);
		}
	]])

	if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then
		local strumW = 0
		for i = 0, 3 do
			strumW = math.max(strumW, getProperty('opponentStrums.members[' .. i .. '].frameWidth') * getProperty('opponentStrums.members[' .. i .. '].scale.x'))
		end
		strumW = math.min(strumW, (screenWidth - 20 - 60) / 8)
		for i = 0, 3 do
			local pad = (strumW - getProperty('opponentStrums.members[' .. i .. '].width')) / 2
			setProperty('opponentStrums.members[' .. i .. '].x', 10 + (strumW * i) + pad)
			setProperty('playerStrums.members[' .. i .. '].x', (screenWidth - 10 - (strumW * 4)) + (strumW * i) + pad)
		end
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
	for _, video in ipairs(videos) do
		if getProperty(video) ~= nil then
			callMethod(video .. '.destroy')
			callMethod('remove', {instanceArg(video)})
		end
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

function onDestroy()
	for _, video in ipairs(videos) do
		if getProperty(video) ~= nil then
			callMethod('remove', {instanceArg(video)})
		end
	end
end

function onPause()
	runHaxeCode([[
		var paused = [];
		for (name in ['ahh', 'bestday', 'arin'])
		{
			var video = game.getLuaObject(name);
			if (video != null && video.bitmap != null && video.bitmap.isPlaying)
			{
				video.pause();
				paused.push(name);
			}
		}
		setVar('sunkyPausedVideos', paused);
	]])
end

function onResume()
	runHaxeCode([[
		var paused = getVar('sunkyPausedVideos');
		if (paused != null)
			for (name in paused)
				game.getLuaObject(name)?.resume();
		setVar('sunkyPausedVideos', null);
	]])

	for _, video in ipairs(videos) do
		if getProperty(video) ~= nil then
			if not callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg(video .. '.videoSprite.pause')}) then
				callMethodFromClass('flixel.FlxG', 'signals.focusLost.add', {instanceArg(video .. '.videoSprite.pause')})
			end

			if not callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg(video .. '.videoSprite.resume')}) then
				callMethodFromClass('flixel.FlxG', 'signals.focusGained.add', {instanceArg(video .. '.videoSprite.resume')})
			end
		end
	end
end