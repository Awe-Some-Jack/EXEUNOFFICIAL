local modConfigs = {
	['SANIC'] = {
		type = 'slide',
		skipSongs = {'too-fest'},
		useSeenCutscene = false,
		useSongPosition = true,
		alwaysSkipCountdown = true,
		phase = 'post',
		snapDelay = 0.1,
	},
	['CURSE'] = {
		type = 'slide',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.05,
		forceSkipCountdown = false,
	},
	['EXE'] = {
		type = 'slide',
		skipSongs = {},
		dontShowSlide = {'black-sun', 'godspeed'},
		dontShowSlideStory = {'faker'},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.05,
		forceSkipCountdown = false,
	},
	['REQUITAL'] = {
		type = 'slide',
		skipSongs = {},
		dontShowSlide = {'deception'},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.025,
	},
	['SL4SH'] = {
		type = 'slide',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.025,
	},
	['STARVED'] = {
		type = 'slide',
		skipSongs = {'prey'},
		useSeenCutscene = true,
		phase = 'both',
		snapDelay = 0.025,
	},
	['TAILS DOLL'] = {
		type = 'countdown',
		skipSongs = {'soulless'},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.1,
		forceSkipCountdown = false,
	},
	['MAJIN'] = {
		type = 'slide',
		skipSongs = {'soulless'},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.1,
		forceSkipCountdown = false,
	},
	['HOG'] = {
		type = 'slide',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.05,
		forceSkipCountdown = false,
	},
	['STORY MODE'] = {
		type = 'slide',
		skipSongs = {'final-escape', 'yourself'},
		useSeenCutscene = true,
		phase = 'both',
		postOnlySongs = {'triple-trouble'},
		snapDelay = 0.025,
	},
	['NEEDLEMOUSE'] = {
		type = 'slide',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'both',
		snapDelay = 0.05,
	},
	['GRIEVING'] = {
		type = 'slide',
		skipSongs = {'triple-trouble'},
		forceSkipCountdownFalseOnSongs = {'haze'},
		useSeenCutscene = true,
		phase = 'countdown',
		snapDelay = 0.025,
	},
	['TRILOGY'] = {
		type = 'slide',
		skipSongs = {'triple-trouble'},
		useSeenCutscene = true,
		phase = 'countdown',
		snapDelay = 0.025,
	},
	['LORD X'] = {
		type = 'lordX',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.05,
		forceSkipCountdown = false,
	},
	['MONO'] = {
		type = 'mono',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.1,
	},
	['EXETIOR'] = {
		useSeenCutscene = true,
		skipSongs = {},
		snapDelay = 0.0025,
		forceSkipCountdown = true,
	},
	['DEVOID'] = {
		type = 'card',
		skipSongs = {},
		useSeenCutscene = false,
		cardBeat = 8,
		cardDivisor = 8,
		cardTextPath = 'StartScreens/cardText-devoid',
		snapDelay = 0.1,
	},
	['NORMALCD'] = {
		type = 'card',
		skipSongs = {},
		useSeenCutscene = false,
		cardBeat = 40,
		cardDivisor = 8,
		cardTextPath = 'StartScreens/cardText-normalcd',
		snapDelay = 0.1,
	},
	['SUNKY'] = {
		type = 'bounce',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'countdown',
		snapDelay = 0.025,
		soundOnSnap = 'flatBONK',
	},
	['CHAOTIX'] = {
		type = 'chaotix',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.1,
	},
	['CRAZY TAILS'] = {
		type = 'slide',
		skipSongs = {},
		useSeenCutscene = true,
		phase = 'post',
		snapDelay = 0.05,
		forceSkipCountdown = false,
	}
}

local chaotixSprites = {
	{name = 'graphicA',     path = 'chaotix/block1',         x = -165, y = 546},
	{name = 'graphicB',     path = 'chaotix/block2',         x = 1140, y = 0},
	{name = 'graphicG',     path = 'chaotix/block7',         x = 690,  y = 264},
	{name = 'graphicC',     path = 'chaotix/block3',         x = 0,    y = 329, scaleX = 5.73, scaleY = 3},
	{name = 'graphicD',     path = 'chaotix/block4',         x = 0,    y = 0},
	{name = 'graphicE',     path = 'chaotix/block5',         x = 690,  y = 168},
	{name = 'graphicF',     path = 'chaotix/block6',         x = 1138, y = 384},
	{name = 'graphicH',     path = 'chaotix/block8',         x = 809,  y = 264},
	{name = 'mainBox',      path = 'chaotix/chaotix',        x = -25,  y = 384},
	{name = 'nameBar',      path = 'chaotix/name',           x = 930,  y = 384},
	{name = 'levelDisplay', path = 'chaotix/attLevel1',      x = 930,  y = 168},
	{name = 'levelHeader',  path = 'chaotix/attLevelTitle',  x = 930,  y = -2},
	{name = 'overlay',      path = 'chaotix/blackAsset',     x = 0,    y = 0},
}

local cfg = nil
local active = false
local cutsceneActive = false
local introCreated = false
local waitTriggered = false

local function shouldSkip()
	if cfg.useSongPosition and getSongPosition() > 1000 then return true end
	if cfg.useSeenCutscene and seenCutscene then return true end
	for _, s in ipairs(cfg.skipSongs) do
		if songPath == s then return true end
	end
	return false
end

local function createCountdownIntro()
	if introCreated then return end
	introCreated = true

	setProperty('skipCountdown', false)
end

local function slideHidden()
	if isStoryMode and cfg.dontShowSlideStory then
		for _, s in ipairs(cfg.dontShowSlideStory) do
			if songPath == s then return true end
		end
	end
	if type(cfg.dontShowSlide) ~= 'table' then return cfg.dontShowSlide end
	for _, s in ipairs(cfg.dontShowSlide) do
		if songPath == s then return true end
	end
	return false
end

local function createSlideIntro()
	if introCreated or slideHidden() then return end
	introCreated = true
	local song = string.lower(songName):gsub(' ', '-')
	local circlePath = cfg.circlePath or ('StartScreens/' .. song .. '/circle')
	local textPath   = cfg.textPath   or ('StartScreens/' .. song .. '/text')

	makeLuaSprite('black', nil, 0, 0)
	makeGraphic('black', screenWidth, screenHeight, '000000')
	makeLuaSprite('circle', circlePath, screenWidth, 0)
	makeLuaSprite('text', textPath, -screenWidth, 0)

	addLuaSprite('black', true)
	addLuaSprite('circle', true)
	addLuaSprite('text', true)

	setObjectCamera('black', 'camOther')
	setObjectCamera('circle', 'camOther')
	setObjectCamera('text', 'camOther')

	if cfg.forceSkipCountdown == false then
		setProperty('skipCountdown', false)
	end

	for _, s in ipairs(cfg.forceSkipCountdownFalseOnSongs or {}) do
		if songPath == s then setProperty('skipCountdown', false) end
	end

	doTweenX('circlemove', 'circle', 0, 1, 'quintOut')
	doTweenX('textmove', 'text', 0, 1, 'quintOut')
end

local function createMonoIntro()
	if introCreated then return end
	introCreated = true

	makeLuaSprite('black', 'black', 0, 0)
	makeGraphic('black', screenWidth, screenHeight, '000000')
	makeLuaSprite('down', 'StartScreens/introdown', 0, screenHeight)
	createInstance('left', 'flixel.addons.display.FlxBackdrop', {nil, 0x10})
	loadGraphic('left', 'StartScreens/introleft')
	callMethod('left.setPosition', {-screenWidth, 0})
	setProperty('left.velocity.y', 50)
	makeLuaSprite('text', 'StartScreens/introtxt', screenWidth, 0)

	addLuaSprite('black', true)
	addLuaSprite('down', true)
	addInstance('left', true)
	addLuaSprite('text', true)

	scaleObject('down', 4, 4)
	scaleObject('left', 4, 4)
	scaleObject('text', 4, 4)
	setProperty('down.antialiasing', false)
	setProperty('left.antialiasing', false)
	setProperty('text.antialiasing', false)

	setObjectCamera('black', 'camOther')
	setObjectCamera('down', 'camOther')
	setObjectCamera('left', 'camOther')
	setObjectCamera('text', 'camOther')

	setProperty('skipCountdown', false)

	doTweenY('downmove', 'down', 0, 0.7, 'linear')
	doTweenX('leftmove', 'left', 0, 0.7, 'linear')
	doTweenX('textmove', 'text', 0, 0.7, 'linear')
end

local function createBounceIntro()
	if introCreated then return end
	introCreated = true
	local song = stringSplit(string.lower(songName), ' ')

	makeLuaSprite('black', nil, 0, 0)
	makeGraphic('black', screenWidth, screenHeight, '000000')
	makeLuaSprite('text', 'intro-' .. song[1])
	scaleObject('text', 0.6, 1.05, false)
	setProperty('text.x', (960 - getProperty('text.width')) / 2)

	addLuaSprite('black', true)
	addLuaSprite('text', true)

	setObjectCamera('black', 'camOther')
	setObjectCamera('text', 'camOther')

	doTweenX('textmove', 'text.scale', 1, 0.3, 'bounceOut')
	doTweenY('textmovye', 'text.scale', 1, 0.3, 'bounceOut')
end

local function createChaotixIntro()
	if introCreated then return end
	introCreated = true
	cutsceneActive = true

	for _, spr in ipairs(chaotixSprites) do
		makeLuaSprite(spr.name, spr.path, spr.x, spr.y)
		scaleObject(spr.name, spr.scaleX or 3, spr.scaleY or 3)
		setProperty(spr.name .. '.antialiasing', false)
		setObjectCamera(spr.name, 'camOther')
		addLuaSprite(spr.name, true)
	end

	runTimer('startAnims', 2.0)
end

local time = 1
local function createlordXIntro()
	if introCreated then return end
	if songName ~= "gotta-go" then createSlideIntro() return end
	introCreated = true
	cutsceneActive = true

	local fromSoundTest = getPropertyFromClass('states.SoundTest', "fromSoundTest")

	if songName == "gotta-go" and fromSoundTest then
		makeLuaSprite('bluescreen', 'fate/bluescreen')
		updateHitbox("bluescreen")
		screenCenter("bluescreen")
		setGraphicSize("bluescreen", screenWidth, screenHeight)
		setObjectCamera("bluescreen", 'camOther')
		addLuaSprite("bluescreen")

		setSpriteShader("bluescreen", "glitchChromatic")
		runTimer('fadeBlueScreen', time)
	end
end

local function createCardIntro()
	if introCreated then return end
	introCreated = true

	makeLuaSprite('cardBar', 'StartScreens/cardBar', 0, 0)
	scaleObject('cardBar', 3, 3)
	setObjectCamera('cardBar', 'hud')
	setProperty('cardBar.antialiasing', false)
	addLuaSprite('cardBar')
	screenCenter('cardBar', 'x')
	setObjectCamera('cardBar', 'other')

	makeLuaSprite('cardText', cfg.cardTextPath or 'StartScreens/cardText', 0, 0)
	scaleObject('cardText', 3, 3)
	setObjectCamera('cardText', 'hud')
	setProperty('cardText.antialiasing', false)
	addLuaSprite('cardText')
	setObjectCamera('cardText', 'other')
	setProperty('cardText.y', 72 * 3)

	setProperty('cardBar.y', -getProperty('cardBar.height'))
	setProperty('cardText.x', screenWidth)
end

local function createIntro()
	if cfg.type == 'slide' then
		createSlideIntro()
	elseif cfg.type == 'lordX' then
		createlordXIntro()
	elseif cfg.type == 'countdown' then
		createCountdownIntro()
	elseif cfg.type == 'mono' then
		createMonoIntro()
	elseif cfg.type == 'bounce' then
		createBounceIntro()
	elseif cfg.type == 'chaotix' then
		createChaotixIntro()
	elseif cfg.type == 'card' then
		createCardIntro()
	end
end

function onCreate()
	cfg = modConfigs[currentModDirectory]
	if not cfg then close() return end

	if cfg.alwaysSkipCountdown or cfg.type == 'card' then
		setProperty('skipCountdown', true)
	elseif shouldSkip() then
		setProperty('skipCountdown', true)
	end

	for _, s in ipairs(cfg.forceSkipCountdownFalseOnSongs or {}) do
		if songPath == s then setProperty('skipCountdown', false) end
	end

	if cfg.type == 'bounce' then
		setPropertyFromClass('flixel.addons.transition.FlxTransitionableState', 'skipNextTransIn', true)
		setPropertyFromClass('flixel.addons.transition.FlxTransitionableState', 'skipNextTransOut', true)
	end

	active = true
end

function onCreatePost()
	if not active then return end
	if cfg.useSongPosition and getSongPosition() > 1000 then close() return end

	if cfg.type == 'card' then
		createCardIntro()
		runTimer('blauh', cfg.snapDelay)
		return
	end

	local shouldCreateHere = false
	if cfg.phase == 'post' then
		shouldCreateHere = true
	elseif cfg.phase == 'both' then
		for _, s in ipairs(cfg.postOnlySongs or {}) do
			if songPath == s then shouldCreateHere = true break end
		end
	end

	if shouldCreateHere then
		runTimer('blauh', cfg.snapDelay)
		if not shouldSkip() then
			createIntro()
		end
	end
end

function onCountdownStarted()
	if not active then return end
	if cfg.type == 'card' then return end

	local shouldCreateHere = false
	if cfg.phase == 'countdown' then
		shouldCreateHere = true
	elseif cfg.phase == 'both' then
		shouldCreateHere = true
		for _, s in ipairs(cfg.postOnlySongs or {}) do
			if songPath == s then shouldCreateHere = false break end
		end
	end

	if shouldCreateHere then
		runTimer('blauh', cfg.snapDelay)
		if not shouldSkip() then
			createIntro()
		end
	end
end

local sunshineCountdownSprite = nil

function onCountdownTick(counter)
	if not active or not introCreated then return end
	if cfg.type == 'card' then return end
	if cfg.type == 'chaotix' and not cutsceneActive then return end

	if currentModDirectory == 'TAILS DOLL' and songPath == 'sunshine' then
		if sunshineCountdownSprite ~= nil then
			removeLuaSprite(sunshineCountdownSprite, true)
			sunshineCountdownSprite = nil
		end

		local imgName = nil
		local sndName = nil

		if counter == 1 then
			imgName = 'countdown/READY'
			sndName = 'ready'
		elseif counter == 2 then
			imgName = 'countdown/SET'
			sndName = 'set'
		elseif counter == 3 then
			imgName = 'countdown/GO'
			sndName = 'go'
		end

		if sndName ~= nil then
			playSound(sndName)
		end

		if imgName ~= nil then
			sunshineCountdownSprite = 'sunshineCD_' .. counter
			makeLuaSprite(sunshineCountdownSprite, imgName)
			setObjectCamera(sunshineCountdownSprite, 'other')
			scaleObject(sunshineCountdownSprite, 0.6, 0.6)
			screenCenter(sunshineCountdownSprite, 'xy')
			addLuaSprite(sunshineCountdownSprite, true)
			doTweenX('sunshineCD_scaleX' .. counter, sunshineCountdownSprite .. '.scale', 1, crochet / 1000)
			doTweenY('sunshineCD_scaleY' .. counter, sunshineCountdownSprite .. '.scale', 1, crochet / 1000)
		end
	end
end

function onBeatHit()
	if not active then return end
	if cfg.type ~= 'card' then return end

	if curBeat == cfg.cardBeat then
		doTweenY('hibar', 'cardBar', 0, 0.4)
		doTweenX('hitext', 'cardText', getProperty('cardBar.x') + (8 * 3), 0.5)
		runTimer('ohnotheyreleaving', crochet / (1000 / cfg.cardDivisor) / playbackRate)
	end
end

function onTweenCompleted(tag)
	if not active then return end

	if cfg.type == 'slide' then
		if tag == 'circlemove' then
			runTimer('wait', 0.5, 1)
		end

	elseif cfg.type == 'lordX' and songName ~= "gotta-go" then
		if tag == 'circlemove' then
			runTimer('wait', 0.5, 1)
		end

	elseif cfg.type == 'mono' then
		if tag == 'textmove' and not waitTriggered then
			waitTriggered = true
			runTimer('wait', 1, 1)
		end

	elseif cfg.type == 'bounce' then
		if tag == 'textmove' then
			runTimer('wait', 0.5, 1)
		end
	end
end

function onTimerCompleted(tag)
	if not active then return end

	if tag == 'blauh' then
		callMethod('camGame.snapToTarget')
		if cfg.soundOnSnap then playSound(cfg.soundOnSnap) end
		return
	end

	if cfg.type == 'slide' or cfg.type == "lordX" then
		if tag == 'wait' then
			doTweenAlpha('circlealpha', 'circle', 0, 1, 'linear')
			doTweenAlpha('textalpha', 'text', 0, 1, 'linear')
			doTweenAlpha('blackalpha', 'black', 0, 1, 'linear')
			runTimer('chau', 1, 1)
		elseif tag == 'chau' then
			removeLuaSprite('circle', true)
			removeLuaSprite('text', true)
			removeLuaSprite('black', true)
		end

	elseif cfg.type == "lordX" then
		if tag == "fadeBlueScreen" then
			doTweenAlpha('BlueScreenalpha', 'bluescreen', 0, 1)
		end
	elseif cfg.type == 'mono' then
		if tag == 'wait' then
			doTweenY('downmove', 'down', screenHeight, 0.7, 'linear')
			doTweenX('leftmove', 'left', -screenWidth, 0.7, 'linear')
			doTweenX('textmove', 'text', screenWidth, 0.7, 'linear')
			doTweenAlpha('blackalpha', 'black', 0, 1, 'linear')
			runTimer('chau', 1, 1)
		elseif tag == 'chau' then
			removeLuaSprite('down', true)
			removeLuaSprite('left', true)
			removeLuaSprite('text', true)
			removeLuaSprite('black', true)
		end

	elseif cfg.type == 'bounce' then
		if tag == 'wait' then
			doTweenY('textmovyye', 'text', -1000, 0.3, 'backIn')
			doTweenX('textmovxe', 'text.scale', 0.5, 0.2, 'backIn')
			doTweenY('textmovye', 'text.scale', 1.3, 0.2, 'backIn')
			doTweenAlpha('blackalpha', 'black', 0, 1, 'linear')
			runTimer('chau', 1, 1)
		elseif tag == 'chau' then
			removeLuaSprite('text', true)
			removeLuaSprite('black', true)
		end

	elseif cfg.type == 'card' then
		if tag == 'ohnotheyreleaving' then
			doTweenY('hibar', 'cardBar', -getProperty('cardBar.height'), 0.2)
			doTweenX('hitext', 'cardText', screenWidth, 0.3)
		end

	elseif cfg.type == 'chaotix' then
		if tag == 'startAnims' then
			doTweenY('animA_y', 'graphicA', 1000, 0.5, 'linear')
			doTweenY('animB_y', 'graphicB', 1000, 1.0, 'linear')
			setProperty('graphicB.angle', -168)
			doTweenY('animD_y', 'graphicD', -500, 0.6, 'linear')
			doTweenY('animE_y', 'graphicE', 1000, 0.5, 'linear')
			doTweenX('animF_x', 'graphicF', 2000, 1.0, 'linear')
			doTweenX('animG_x', 'graphicG', 820, 0.2, 'linear')
			doTweenX('animH_x', 'graphicH', 935, 0.2, 'linear')
			doTweenY('animOverlay_y', 'overlay', -500, 0.15, 'linear')
			doTweenAngle('animOverlay_a', 'overlay', -1000, 1.0, 'linear')
			runTimer('animNameBar', 0.05)
			runTimer('animGraphicC', 0.12)
			runTimer('animGraphicG', 0.15)
			runTimer('flipGraphicB', 0.3)
			runTimer('animHeaders', 0.35)
			runTimer('endPhase', 1.25)
		elseif tag == 'animNameBar' then
			doTweenY('nameBar_y', 'nameBar', 1000, 1.0, 'linear')
		elseif tag == 'animGraphicC' then
			doTweenX('graphicC_x', 'graphicC', -2000, 1.5, 'linear')
		elseif tag == 'animGraphicG' then
			doTweenY('graphicG_y', 'graphicG', 1000, 0.6, 'linear')
			doTweenAngle('graphicG_a', 'graphicG', -1000, 0.6, 'linear')
		elseif tag == 'flipGraphicB' then
			setProperty('graphicB.angle', 168)
		elseif tag == 'animHeaders' then
			doTweenY('levelHeader_y', 'levelHeader', -500, 0.6, 'linear')
			doTweenX('levelDisplay_x', 'levelDisplay', 2000, 1.0, 'linear')
			doTweenX('graphicH_x2', 'graphicH', 2000, 1.0, 'linear')
		elseif tag == 'endPhase' then
			doTweenX('mainBox_x', 'mainBox', -2000, 0.75, 'linear')
			runTimer('cleanup', 1.0)
		elseif tag == 'cleanup' then
			cutsceneActive = false
			for _, spr in ipairs(chaotixSprites) do
				removeLuaSprite(spr.name, true)
			end
		end
	end
end

local holdTime = 0
function onUpdate(elapsed)
	holdTime = holdTime + elapsed
	if getProperty("bluescreen.shader") == not nil then setShaderFloat("bluescreen", 'iTime', holdTime) end
	if getProperty("bluescreen.shader") == not nil then setShaderFloat("bluescreen", 'GLITCH', lerp(0, 1, time)) end

end

function lerp(s, e, t)
	return s + (e - s) * math.min(t, 1)
end