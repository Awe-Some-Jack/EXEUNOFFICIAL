local starlineBG = {
	['BGAssets'] = {
		{name = 'cieeelo',     path = 'bg/horizonsky', x = -1900, y = -1300,                                                  scaleX = 6, scaleY = 6, scrollX = 0.8, scrollY = 1, antialiasing = false, alpha = 1, front = false},
		{name = 'cieloFucked', path =   'bg/bgglitch', x = -1600, y = -1000, animName = 'idle', animPrefix = 'bgglitch idle', scaleX = 6, scaleY = 6, scrollX =   1, scrollY = 1, antialiasing = false, alpha = 0, front = false},
		{name = 'bg1',         path =       'bg/piso', x = -1600, y = -1000,                                                  scaleX = 6, scaleY = 6, scrollX =   1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
		{name = 'bg2',         path =      'bg/piso2', x = -1600, y = -1000,                                                  scaleX = 6, scaleY = 6, scrollX =   1, scrollY = 1, antialiasing = false, alpha = 0, front = false},
	},
	['characters'] = {
		{name = 'espio',    character = 'espio',      x =   930, y = 130,                    beatIntervals = 1, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'amy',      character =    'amy',     x =   730, y =  85,                                       scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'mighty',   character = 'mighty',     x =  -100, y =  65,                    beatIntervals = 1, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'knux',     character =   'knux',     x =  -640, y =  85,                    beatIntervals = 2, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'vector',   character = 'vector',     x =  -880, y =  65,                    beatIntervals = 1, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'charmy',   character = 'charmy',     x =   480, y = -95,  canFloat = true,  beatIntervals = 2, scaleX = 6, scaleY = 6, alpha = 1, front = false},
	},
	['cutsceneChars'] = {
		{name = 'wech',  char =   'anim',  x = 500, y = 300, scaleX =  4.6, scaleY = 4.6, antialiasing = false, alpha = 0, front = false},
		{name = 'bf-gf', char =  'anim2',  x = 430, y = 180, scaleX =  3.8, scaleY = 3.8, antialiasing = false, alpha = 0, front = false},
	}
}


-- [[VARIABLES]]
local glitchedActive = false
local transPlaying = false
local starCount = 0
local glitchCount = 0
local tailsBaseY = -1600
local canFly = true
local changeIdles = false


local function createSprite(sexo)
	if sexo.animName then
		makeAnimatedLuaSprite(sexo.name, sexo.path, sexo.x, sexo.y)
		addAnimationByPrefix(sexo.name, sexo.animName, sexo.animPrefix, 10, true)
	else
		makeLuaSprite(sexo.name, sexo.path, sexo.x, sexo.y)
	end
	scaleObject(sexo.name, sexo.scaleX, sexo.scaleY)
	setScrollFactor(sexo.name, sexo.scrollX, sexo.scrollY)
	setProperty(sexo.name..'.antialiasing', sexo.antialiasing)
	setProperty(sexo.name..'.alpha', sexo.alpha)
	addLuaSprite(sexo.name, sexo.front)
end

local function createCharacter(char)
	createInstance(char.name, 'objects.Character', {char.x, char.y, char.character, 'false'})
	setProperty(char.name..'.alpha', char.alpha)
	addInstance(char.name, char.front)
end

local function createCutsceneCharacters(yea)
	createInstance(yea.name, 'objects.Character', {yea.x, yea.y, yea.char, 'false'})
	scaleObject(yea.name, yea.scaleX, yea.scaleY)
	setProperty(yea.name..'.alpha', yea.alpha)
	addInstance(yea.name, yea.front)
	setProperty(yea.name..'.alpha', 0)
	setObjectCamera(yea.name, 'camOther')
	addLuaSprite(yea.name, yea.front)
end

local function createTails()
	createInstance('tails', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('tails', 'bg/tails')
	setProperty('tails.velocity.x', -400)
	setProperty('tails.y', -1600)
	scaleObject('tails', 6, 6)
	setScrollFactor('tails', 1, 1)
	setProperty('tails.antialiasing', false)
	setProperty('tails.alpha', 0)
	setObjectOrder('tails', getObjectOrder('cieloFucked'))
	addInstance('tails')
end

function onCreatePost()
	for _, bgs   in ipairs(starlineBG['BGAssets'])      do	              createSprite(bgs) end
	for _, chars in ipairs(starlineBG['characters'])    do	         createCharacter(chars) end
	for _, chars in ipairs(starlineBG['cutsceneChars']) do	createCutsceneCharacters(chars) end
	createTails()


	makeLuaSprite('blackOverlay', nil, getProperty('dad.x') - 120, -320)
	makeGraphic('blackOverlay', screenWidth * 1.8, screenHeight * 1.8, '000000')
	setScrollFactor('blackOverlay', 0, 0)
	setProperty('blackOverlay.alpha', 0)
	addLuaSprite('blackOverlay', false)

	setScrollFactor('gf', 1, 1)
	setObjectOrder('blackOverlay', getObjectOrder('gfGroup'))
end

function spawnStar()
	starCount = starCount + 1
	local tag = 'star'..starCount
	local size = getRandomInt(4, 10)
	local colors = {'FFFFFF', 'FFFFCC', 'CCFFFF', 'FFCCFF', 'FFFFAA'}

	makeLuaSprite(tag, nil, getRandomInt(-1600, 2100), -800)
	makeGraphic(tag, size, size, colors[getRandomInt(1, #colors)])
	setProperty(tag..'.alpha', 1)
	setBlendMode(tag, 'add')
	addLuaSprite(tag)

	local fallTime = getRandomFloat(3, 6)
	doTweenY('starY'..starCount, tag, getRandomInt(800, 1500), fallTime)
	doTweenAlpha('starA'..tag, tag, 0, fallTime, 'sineInOut')
end

function spawnGlitch()
	glitchCount = glitchCount + 1
	local tag = 'glitch'..glitchCount
	local colors = {'FF0000', '00FF00', 'FF00FF', '00FFFF', 'FFFF00', 'FF3300', '3300FF'}

	makeLuaSprite(tag, nil, getRandomInt(-1600, 2100), getRandomInt(-500, 800))
	makeGraphic(tag, getRandomInt(10, 80), getRandomInt(4, 15), colors[getRandomInt(1, #colors)])
	setProperty(tag..'.alpha', getRandomFloat(0.6, 1.1))
	setBlendMode(tag, 'add')
	addLuaSprite(tag, true)

	local lifeTime = getRandomFloat(0.1, 0.5)
	doTweenAlpha('glitchA'..tag, tag, 0, lifeTime)
	setProperty(tag..'.velocity.x', getRandomInt(-300, 300))
end

function onTweenCompleted(tag)
	local name = tag:gsub('starA', ''):gsub('glitchA', '')
	if tag:find('starA') or tag:find('glitchA') then
		removeLuaSprite(name, true)
		--if not luaSpriteExists(name) then debugPrint(name.. 'is removed!') end
	end
end

luaDebugMode = true

local starlineEvents = {
	['startAnim'] = function(number)
		if number == '1' then
			transPlaying = true
			setProperty('dad.specialAnim', true)
			playAnim('dad', 'trans1', true)
			for _, chars in ipairs({'boyfriend', 'dad', 'gf'}) do setProperty(chars..'.alpha', 0) end
			for _, bgChars in ipairs(starlineBG['characters']) do setProperty(bgChars.name..'.alpha', 0) end

			setProperty('wech.alpha', 1)
			setProperty('bg1.alpha', 0)
			setProperty('camHUD.alpha', 0)
			playAnim('wech', 'idle', true)

			doTweenY('wechTween', 'wech', getProperty('wech.y') - 160, 1.2, 'cubeOut')
		elseif number == '2' then
			setProperty('wech.alpha', 0)
			setProperty('bf-gf.alpha', 1)
			playAnim('bf-gf', 'idle', true)

			doTweenX('bfGfTween', 'bf-gf', getProperty('bf-gf.x') + 70, 1.4, 'sineInOut')
		elseif number == '3' then
			playAnim('bf-gf', 'idle-alt', true)
			doTweenX('bfGfTween', 'bf-gf', getProperty('bf-gf.x') - 70, 0.8, 'quadOut')
		end
	end,
	['fadeStage'] = function() doTweenAlpha('fadeToBlack', 'blackOverlay', 1, 2, 'sineIn') end,
	['hideAnim'] = function()
		setProperty('bf-gf.alpha', 0)
		for _, putas in ipairs({'boyfriend', 'dad', 'gf'}) do setProperty(putas..'.alpha', 1) end
		setProperty('dad.specialAnim', true)
		playAnim('dad', 'trans2', true)
	end,
	['chaotixTime'] = function()
		glitchedActive = true
		transPlaying = false
		canFly = false
		changeIdles = true
		triggerEvent('Change Character', '1', 'beast_chaotix')
		callMethod('dad.setPosition', {-376.9, 120.7})
		cancelTween('fadeToBlack')
		doTweenAlpha('fadeFromBlack',  'blackOverlay', 0, 1.5, 'sineOut')
		doTweenAlpha('fadeFromBlackHUD',     'camHUD', 1, 1.5, 'sineOut')

		for _, chars in ipairs(starlineBG['characters']) do setProperty(chars.name..'.idleSuffix', '-alt') setProperty(chars.name..'.alpha', 1) playAnim(chars.name, 'idle-alt', true) end
		callMethod('charmy.setPosition', {getProperty('charmy.x') + 110, getProperty('charmy.y') + 280})
		setProperty('bg1.alpha', 0)
		setProperty('cieeelo.alpha', 0)
		setProperty('bg2.alpha', 1)
		setProperty('tails.alpha', 1)
		setProperty('cieloFucked.alpha', 1)
	end,
	['fadeSong'] = function() doTweenAlpha('fadeSongTween', 'BlackGraphicOther', 1, 4) end
}

function onEvent(n, v1, v2)
	if n == 'chaotixEvents' then starlineEvents[v1](v2) end
end
function onBeatHit()
	for _, beatGuys in ipairs(starlineBG['characters']) do
		if beatGuys.beatIntervals then
			if curBeat %beatGuys.beatIntervals == 0 and not changeIdles then playAnim(beatGuys.name, 'idle', true) end
		end
	end

	if not glitchedActive then spawnStar() else spawnGlitch() end
end

local flyHold = 0
function onUpdatePost(e)
	flyHold = flyHold + e
	if glitchedActive then setProperty('tails.y', tailsBaseY + getRandomInt(-8, 8))	end
	if transPlaying then setProperty('dad.specialAnim', true) end
	if getProperty('dad.animation.curAnim.name') == 'trans2' and getProperty('dad.animation.curAnim.finished') and transPlaying then playAnim('dad', 'trans3', true) end
	for _, beatGuys in ipairs(starlineBG['characters']) do
		if beatGuys.canFloat and canFly then
			callMethod(beatGuys.name..'.setPosition', {
				getProperty(beatGuys.name..'.x') + math.cos(flyHold + 0.1) * 0.1,
				getProperty(beatGuys.name..'.y') + math.sin(flyHold + 0.05) * 0.15
			})
		end
	end
end

function opponentNoteHitPre(i)
	if getProperty('dad.animation.curAnim.name') == 'trans1' and not getPropertyFromGroup('notes', i, 'mustPress') then setPropertyFromGroup('notes', i, 'noAnimation', true) end
end