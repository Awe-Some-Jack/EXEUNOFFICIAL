local starlineAssets = {
	['BGAssets'] = {
		{name = 'cieeelo',     path = 'bg/horizonsky', x = -1900, y = -1300,                                                                scaleX = 6, scaleY = 6, scrollX = 0.8, scrollY = 1, antialiasing = false, alpha = 1, front = false},
		{name = 'cieloFucked', path =   'bg/bgglitch', x = -1600, y = -1000, animName = 'idle', animPrefix = 'bgglitch idle', loop = true,  scaleX = 6, scaleY = 6, scrollX =   1, scrollY = 1, antialiasing = false, alpha = 0, front = false},
		{name = 'bg1',         path =       'bg/piso', x = -1600, y = -1000,                                                                scaleX = 6, scaleY = 6, scrollX =   1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
		{name = 'bg2',         path =      'bg/piso2', x = -1600, y = -1000,                                                                scaleX = 6, scaleY = 6, scrollX =   1, scrollY = 1, antialiasing = false, alpha = 0, front = false},
	},
	['characters'] = {
		{name = 'espio',    character = 'espio',      x =   972, y = 121.5,                    beatIntervals = 1, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'amy',      character =    'amy',     x =   761, y =  85,                                       scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'mighty',   character = 'mighty',     x =  -110, y =  66.5,                    beatIntervals = 1, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'knux',     character =   'knux',     x =  -666.5, y =  91.5,                    beatIntervals = 2, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'vector',   character = 'vector',     x =  -920, y =  57.5,                    beatIntervals = 1, scaleX = 6, scaleY = 6, alpha = 1, front = false},
		{name = 'charmy',   character = 'charmy',     x =   480, y = -95,  canFloat = true,  beatIntervals = 2, scaleX = 6, scaleY = 6, alpha = 1, front = false},
	},
	['cutsceneChars'] = {
		{name = 'wech',  char =   'anim',  x = 500, y = 300, scaleX =  4.6, scaleY = 4.6, antialiasing = false, alpha = 0, front = false},
		{name = 'bf-gf', char =  'anim2',  x = 430, y = 180, scaleX =  3.8, scaleY = 3.8, antialiasing = false, alpha = 0, front = false},
	},
	['dontMiss'] = {
		{name = 'chaotixStance', path = 'bg/characters/big-chaotix', x = -400, y = -50, animName = 'stance', animPrefix = 'big-chaotix stance', scaleX = 4, scaleY = 4, loop = false, scrollX = 1, scrollY = 1, camera = 'camHUD', antialiasing = false, alpha = 0, front = false},
		{name =      'bfStance', path =      'bg/characters/big-bf', x =    0, y =   0, animName = 'stance', animPrefix =          'big-bf UP', scaleX = 4, scaleY = 4, loop = false, scrollX = 1, scrollY = 1, camera = 'camHUD', antialiasing = false, alpha = 0, front = false},
	},
	['icons'] = {
		{name = 'bfStarlineIcon',            path =    'icons/icon-bfstarline', xIcon = 1110, yIcon = {25, 535}, prefixThing =    'icon-bfstarline', positionFrom = 'iconBF',  alpha = 1},
		{name = 'chaotixBeastStarlineIcon',  path =  'icons/icon-chaotixbeast', xIcon =  500, yIcon = {25, 560}, prefixThing =  'icon-chaotixbeast', positionFrom = 'iconOpp', alpha = 0},
		{name = 'chaotixNormalStarlineIcon', path = 'icons/icon-chaotixnormal', xIcon =  500, yIcon = {5,  560}, prefixThing = 'icon-chaotixnormal', positionFrom = 'iconOpp', alpha = 1}
	}
}

-- [[VARIABLES]]
local glitchedActive = false
local transPlaying   = false

local starCount      = 0
local starOtherCount = 0
local glitchCount    = 0
local tailsCount     = 0

local tailsBaseY = -1600

local canFly      =  true
local changeIdles = false


local function createSprite(sexo)
	if sexo.animName then
		makeAnimatedLuaSprite(sexo.name, sexo.path, sexo.x, sexo.y)
		addAnimationByPrefix(sexo.name, sexo.animName, sexo.animPrefix, 10, sexo.loop)
	else
		makeLuaSprite(sexo.name, sexo.path, sexo.x, sexo.y)
	end
	scaleObject(sexo.name, sexo.scaleX, sexo.scaleY)
	setScrollFactor(sexo.name, sexo.scrollX, sexo.scrollY)
	setProperty(sexo.name..'.antialiasing', sexo.antialiasing)
	if sexo.camera then setObjectCamera(sexo.name, sexo.camera) end
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

local function createIcon(icon)
	makeAnimatedLuaSprite(icon.name, icon.path, icon.xIcon, downscroll and icon.yIcon[1] or icon.yIcon[2]) -- Positions kinda doesnt matter here cause the xml is fucked up dude
	addAnimationByPrefix(icon.name, 'normal', icon.prefixThing..' normal', 8, true)
	addAnimationByPrefix(icon.name, 'losing', icon.prefixThing..' losing', 8, true)
	setProperty(icon.name..'.alpha', icon.alpha)
	setProperty(icon.name..'.antialiasing', false)
	setObjectCamera(icon.name, 'camHUD')
	scaleObject(icon.name, 3.2, 3.2)
	playAnim(icon.name, 'normal', true)
	setObjectOrder(icon.name, getObjectOrder('healthBG'))
	addLuaSprite(icon.name)
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
	for _, bgs   in ipairs(starlineAssets['BGAssets'])      do	              createSprite(bgs) end
	for _, chrs  in ipairs(starlineAssets['dontMiss'])      do	             createSprite(chrs) end
	for _, chars in ipairs(starlineAssets['characters'])    do	         createCharacter(chars) end
	for _, chars in ipairs(starlineAssets['cutsceneChars']) do	createCutsceneCharacters(chars) end

	for _, icon in ipairs(starlineAssets['icons']) do createIcon(icon) end

	for _, icons in ipairs({'iconBF', 'iconOpp'}) do setProperty(icons..'.visible', false) end

	createTails()

	initLuaShader('NewGlitch2')

	makeLuaSprite('blackOverlay', nil, getProperty('dad.x') - 120, -320)
	makeGraphic('blackOverlay', screenWidth * 1.8, screenHeight * 1.8, '000000')
	setScrollFactor('blackOverlay', 0, 0)
	setProperty('blackOverlay.alpha', 0)
	addLuaSprite('blackOverlay', false)

	makeLuaSprite('starSky', nil, getProperty('dad.x') - 120, -320)
	makeGraphic('starSky', screenWidth * 1.8, screenHeight * 1.8, '000321')
	setScrollFactor('starSky', 0, 0)
	setProperty('starSky.alpha', 0)
	addLuaSprite('starSky', false)

	setScrollFactor('gf', 1, 1)
	setObjectOrder('blackOverlay', getObjectOrder('gfGroup') - 1) setObjectOrder('starSky', getObjectOrder('gfGroup'))

	for _, chrs  in ipairs(starlineAssets['dontMiss']) do setObjectOrder(chrs.name, getObjectOrder('scoreText') - 1) end

	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'x', -1000)
		setPropertyFromGroup('playerStrums', i, 'x', 1050)
		setPropertyFromGroup('playerStrums', i, 'y', (downscroll and (screenHeight + 500) or -500))
	end
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

function createPeaceStars()
	starOtherCount = starOtherCount + 1
	local tag = 'chillStar'..starOtherCount
	local starSize = getRandomInt(2, 6)

	makeAnimatedLuaSprite(tag, "bg/star", getRandomFloat(-700, 700), getRandomFloat(-600, 200))
	addAnimationByPrefix(tag, 'idle', 'star star', 8, true)
	playAnim(tag, 'idle', true) -- Just in case.
	scaleObject(tag, 1, 1)
	setProperty(tag..'.antialiasing', false)
	setObjectOrder(tag, getObjectOrder('starSky') + 1)
	addLuaSprite(tag)

	doTweenX('ScaleStartX'..tag, tag..'.scale', starSize, math.random(1, 4))
	doTweenY('ScaleStartY'..tag, tag..'.scale', starSize, math.random(1, 4))
end

function spawnTailsText()
	tailsCount = tailsCount + 1
	local tag = 'tailsText'..tailsCount
	local tailsSize = getRandomInt(2, 6)

	makeLuaSprite(tag, "bg/tailsText", getRandomFloat(100, 1100), getRandomFloat(50, 550))
	scaleObject(tag, 0, 0)
	setProperty(tag..'.antialiasing', false)
	setObjectCamera(tag, 'camHUD')
	addLuaSprite(tag, true)

	doTweenX('ScaleStartX'..tag, tag..'.scale', tailsSize, 0.5, 'bounceOut')
	doTweenY('ScaleStartY'..tag, tag..'.scale', tailsSize, 0.5, 'bounceOut')
	callMethodFromClass("FlxTween", "shake", {tag..'.sprite', 0.1, 5})
end

function onTweenCompleted(tag)
	if tag == 'bfBumpAlpha' then removeLuaSprite('bfBump') end

	local starName = tag:gsub('starA', ''):gsub('glitchA', '')
	if tag:find('starA') or tag:find('glitchA') then
		removeLuaSprite(starName, true)
		--if not luaSpriteExists(name) then debugPrint(name.. 'is removed!') end
	end

	local starPeaceName = tag:gsub('ScaleStartX', ''):gsub('ScaleEndX', '')
	if tag:find('ScaleStartX') then
		doTweenX('ScaleEndX'..starPeaceName, starPeaceName..'.scale', 0, 2)
		doTweenY('ScaleEndY'..starPeaceName, starPeaceName..'.scale', 0, 2)
	elseif tag:find('ScaleEndX') then
		removeLuaSprite(starPeaceName, true)
	end

	local tailsTextName = tag:gsub("ScaleStartX", ''):gsub('ScaleEndX', '')
	if tag:find("ScaleStartX") then
		doTweenX('ScaleEndX'..tailsTextName, tailsTextName..'.scale', 0, 0.6, 'circIn')
		doTweenY('ScaleEndY'..starPeaceName, tailsTextName..'.scale', 0, 0.6, 'circIn')
	elseif tag:find('ScaleEndX') then
		removeLuaSprite(tailsTextName, true)
	end
end

luaDebugMode = true

local bgShaderTime = false
local crazyTime    = false
local tailsTimer = 0.4
local starlineEvents = {
	['theSky'] = function(mode)
		if mode == 'true' then
			runTimer('waitToSpawn', 2)
			doTweenAlpha('starSkyAlpha', 'starSky', 1, 3)
			for _, healthShit in ipairs({'hbHealth', 'hbHealth2', 'healthBG', 'hbBG', 'separatorHealth', 'bfStarlineIcon', 'chaotixNormalStarlineIcon'}) do doTweenAlpha(healthShit..'Alpha', healthShit, 0, 1.5) end
			for _, chars in ipairs({'boyfriend', 'dad'}) do doTweenColor(chars..'Color', chars, '1f2cb5', 3) end
		elseif mode == '' or mode == 'false' then
			for i = 1, starOtherCount do
				local starChill = 'chillStar'..i
				if luaSpriteExists(starChill) then
					doTweenAlpha('fade'..starChill, starChill, 0, 2)
				end
			end
			doTweenAlpha('starSkyAlpha', 'starSky', 0, 2)
				for _, healthShit in ipairs({'hbHealth', 'hbHealth2', 'healthBG', 'hbBG', 'separatorHealth', 'bfStarlineIcon', 'chaotixNormalStarlineIcon'}) do doTweenAlpha(healthShit..'Alpha', healthShit, 1, 2) end
			for _, chars in ipairs({'boyfriend', 'dad'}) do doTweenColor(chars..'Color', chars, 'FFFFFF', 2) end
			cancelTimer("spawnPeaceStars")
		end
	end,
	['darkenBG'] = function(darken)
		if darken == 'true' then
			doTweenAlpha('darkenBG', 'blackOverlay', 0.5, 0.5, 'sineIn')
		elseif darken == '' or darken == 'false' then
			doTweenAlpha('darkenBG', 'blackOverlay', 0, 0.5)
		end
	end,
	['bumpBF'] = function ()
		createInstance('bfBump', 'objects.Character', {getProperty('boyfriend.x'), getProperty('boyfriend.y'), getProperty('boyfriend.curCharacter'), true})
		setBlendMode('bfBump', 'ADD')
		addInstance('bfBump', true)

		playAnim('bfBump', getProperty('boyfriend.animation.curAnim.name'))
		setProperty('bfBump.animation.curAnim.curFrame', getProperty('boyfriend.animation.curAnim.curFrame'))

		doTweenX('bfBumpScaleX', 'bfBump.scale', getProperty('boyfriend.scale.x') + 1, 1 / playbackRate, 'cubeOut') doTweenY('bfBumpScaleY', 'bfBump.scale', getProperty('boyfriend.scale.y') + 1, 1 / playbackRate, 'cubeOut')
		doTweenAlpha('bfBumpAlpha', 'bfBump', 0, 1 / playbackRate, 'cubeOut')
	end,
	['startAnim'] = function(number)
		if number == '1' then
			setProperty('gf.skipDance', true)
			transPlaying = true
			setProperty('dad.specialAnim', true)
			playAnim('dad', 'trans1', true)
			for _, chars in ipairs({'boyfriend', 'dad', 'gf'}) do setProperty(chars..'.alpha', 0) end
			for _, bgChars in ipairs(starlineAssets['characters']) do setProperty(bgChars.name..'.alpha', 0) end

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
		for _, putas in ipairs({'boyfriend', 'dad', 'gf'}) do setProperty(putas..'.alpha', 1) end
		setProperty('bf-gf.alpha', 0)
		setProperty('dad.specialAnim', true)
		playAnim('dad', 'trans2', true)
	end,
	['chaotixTime'] = function()
		glitchedActive = true
		transPlaying = false
		canFly = false
		changeIdles = true

		runTimer('gfReaction3', 1)
		triggerEvent('Change Character', '1', 'beast_chaotix')
		callMethod('dad.setPosition', {-376.9, 120.7})
		cancelTween('fadeToBlack')
		doTweenAlpha('fadeFromBlack',  'blackOverlay', 0, 1.5, 'sineOut')
		doTweenAlpha('fadeFromBlackHUD',     'camHUD', 1, 1.5, 'sineOut')

		loadGraphic('healthBG', 'hud/hud_chaotix_beast')
		setProperty('chaotixNormalStarlineIcon.alpha', 0) setProperty('chaotixBeastStarlineIcon.alpha', 1) setProperty('chaotixNormalStarlineIcon.visible', false)
		--callMethod('chaotixBeastStarlineIcon.setPosition', {400, 520})

		for _, chars in ipairs(starlineAssets['characters']) do setProperty(chars.name..'.idleSuffix', '-alt') setProperty(chars.name..'.alpha', 1) playAnim(chars.name, 'idle-alt', true) end
		callMethod('charmy.setPosition', {getProperty('charmy.x') + 110, getProperty('charmy.y') + 280})
		setObjectOrder('charmy', getObjectOrder('boyfriendGroup') + 1)
		setProperty('bg1.alpha', 0)
		setProperty('cieeelo.alpha', 0)
		setProperty('bg2.alpha', 1)
		setProperty('tails.alpha', 1)
		setProperty('cieloFucked.alpha', 1)
	end,
	['dontMiss'] = function(mode)
		if mode == 'chaotix' then
			for _, chars in ipairs({'boyfriend', 'dad', 'gf'}) do setProperty(chars..'.visible', false) end
			for _, chars in ipairs(starlineAssets["characters"]) do setProperty(chars.name..'.visible', false) end

			setProperty('chaotixStance.alpha', 1) playAnim('chaotixStance', 'stance', true)
			doTweenX('chaotixStanceX', 'chaotixStance', getProperty('chaotixStance.x') - 200, 0.5, 'circOut')
			setProperty('bg2.alpha', 0)
		end
		if mode == 'bf' then
			setProperty('chaotixStance.alpha', 0) setProperty('bfStance.alpha', 1) playAnim('bfStance', 'stance', true)
			doTweenX('bfStanceX', 'bfStance', getProperty('bfStance.x') + 200, 0.5, 'circOut')
		end
		if mode == 'back' then
			for _, chars in ipairs({'boyfriend', 'dad', 'gf'}) do setProperty(chars..'.visible', true) end
			for _, chars in ipairs(starlineAssets["characters"]) do setProperty(chars.name..'.visible', true) end

			removeLuaSprite('chaotixStance', true) removeLuaSprite('bfStance', true)
			setProperty('bg2.alpha', 1)
		end
	end,
	['fadeSong'] = function() doTweenAlpha('fadeSongTween', 'BlackGraphicOther', 1, 5) end,
	['glitchBG'] = function(intensity)
		for _, bg in ipairs(starlineAssets['BGAssets']) do
			for _, healthShit in ipairs({'hbHealth', 'hbHealth2', 'healthBG', 'hbBG', 'separatorHealth', 'bfStarlineIcon', 'chaotixBeastStarlineIcon'}) do doTweenAlpha(healthShit..'Alpha', healthShit, 0, 0.5) end
			if shadersEnabled then
				if getProperty(bg.name..'.shader') == nil then setSpriteShader(bg.name, 'glitchChromatic') end
				if getProperty('tails.shader') == nil then setSpriteShader('tails', 'glitchChromatic') end setShaderFloat('tails', 'GLITCH', intensity)
				bgShaderTime = true
				setShaderFloat(bg.name, 'GLITCH', intensity)
				crazyTime = true
			end
			runTimer('tailsTime', tailsTimer, 0)
		end
		if shadersEnabled then setProperty('bg2.y', getProperty('bg2.y') - 30) end
	end,
	['setTailsTimer'] = function(timer)	tailsTimer = timer end,
	['stopTails'] = function()
		if shadersEnabled then crazyTime = false end
		removeSpriteShader('dad')
		cancelTimer('returnChaotixGlitch')
		tailsTimer = 40
		cancelTimer('tailsTime')
		if shadersEnabled then setProperty('bg2.y', getProperty('bg2.y') - 20) end
		for i = 1, tailsCount do
			local tailsCount = 'tailsText'..i
			if luaSpriteExists(tailsCount) then
				cancelTween("ScaleStartX"..tailsCount) cancelTween("ScaleEndX"..tailsCount)
				doTweenX('ScaleEndX'..tailsCount, tailsCount..'.scale', 0, 0.2, 'circIn')
				doTweenY('ScaleEndY'..tailsCount, tailsCount..'.scale', 0, 0.2, 'circIn')
			end
		end
	end,
}

local waveNotes = false
local chaotixModchart = {
    ["startBF"] = function()
        for i = 0, 3 do
			noteTweenX('noteMoveX'..i, i + 4, _G['defaultPlayerStrumX'..i], 1.5, 'cubeOut')
			noteTweenY('noteMoveY'..i, i + 4, _G['defaultPlayerStrumY'..i], 1.5, 'cubeOut')
		end
    end,
	["bumpNotes"] = function()
		for i = 0, 3 do
			callMethod("playerStrums.members["..i.."].setPosition", {
				getProperty("playerStrums.members["..i.."].x") + getRandomFloat(-30, 30),
				getProperty("playerStrums.members["..i.."].y") + getRandomFloat(-30, 30)
			})
			setProperty("playerStrums.members["..i.."].angle", getRandomFloat(-5, 5))
			callMethod("playerStrums.members["..i.."].scale.set", {
				getProperty("playerStrums.members["..i.."].scale.x") + getRandomFloat(0.6, 1.4),
				getProperty("playerStrums.members["..i.."].scale.y") + getRandomFloat(0.6, 1.4)
			})
			--[[ This fucks up the sustains. Better let this be LOL.
			callMethod("notes.members["..(i + 4).."].scale.set", {
				getProperty("playerStrums.members["..i.."].scale.x"),
				getProperty("playerStrums.members["..i.."].scale.y")
			})
			]]
			doTweenX(i..'noteScaleX', "playerStrums.members["..i.."].scale", 6, 0.9, 'circOut')
			doTweenY(i..'noteScaleY', "playerStrums.members["..i.."].scale", 6, 0.9, 'circOut')
			--doTweenX(i..'noteNoteScaleX', "notes.members["..(i + 4).."].scale", 6, 0.9, 'circOut')
			--doTweenY(i..'noteNoteScaleY', "notes.members["..(i + 4).."].scale", 6, 0.9, 'circOut')
			noteTweenX('noteMoveX'..i, i + 4, _G['defaultPlayerStrumX'..i], 0.9, 'circOut')
			noteTweenY('noteMoveY'..i, i + 4, _G['defaultPlayerStrumY'..i], 0.9, 'circOut')
			noteTweenAngle('noteMoveAngle'..i, i + 4, 0, 0.9, 'circOut')
		end
	end,
	["spinBumpNotes"] = function()
		for i = 0, 3 do
			callMethod("playerStrums.members["..i.."].setPosition", {
				getProperty("playerStrums.members["..i.."].x") + getRandomFloat(-30, 30),
				getProperty("playerStrums.members["..i.."].y") + getRandomFloat(-30, 30)
			})
			callMethod("playerStrums.members["..i.."].scale.set", {
				getProperty("playerStrums.members["..i.."].scale.x") + getRandomFloat(0.6, 1.4),
				getProperty("playerStrums.members["..i.."].scale.y") + getRandomFloat(0.6, 1.4)
			})
			doTweenX(i..'noteScaleX', "playerStrums.members["..i.."].scale", 6, 0.9, 'circOut')
			doTweenY(i..'noteScaleY', "playerStrums.members["..i.."].scale", 6, 0.9, 'circOut')
			noteTweenX('noteMoveX'..i, i + 4, _G['defaultPlayerStrumX'..i], 0.9, 'circOut')
			noteTweenY('noteMoveY'..i, i + 4, _G['defaultPlayerStrumY'..i], 0.9, 'circOut')
			noteTweenAngle('noteMoveAngle'..i, i + 4, 360, 0.45, 'circOut')
		end
	end,
	["bumpSideNotes"] = function()
		for i = 0, 3 do
			setPropertyFromGroup('playerStrums', 0, 'x', getPropertyFromGroup('playerStrums', 0, 'x') - 15)
			setPropertyFromGroup('playerStrums', 3, 'x', getPropertyFromGroup('playerStrums', 3, 'x') + 15)
			noteTweenX('noteMoveX'..i, i + 4, _G['defaultPlayerStrumX'..i], 0.4, 'circOut')
		end
	end,
	["bumpVertNotes"] = function()
		for i = 0, 3 do
			setPropertyFromGroup('playerStrums', 1, 'y', getPropertyFromGroup('playerStrums', 1, 'y') - 15)
			setPropertyFromGroup('playerStrums', 2, 'y', getPropertyFromGroup('playerStrums', 2, 'y') + 15)
			noteTweenY('noteMoveY'..i, i + 4, _G['defaultPlayerStrumY'..i], 0.4, 'circOut')
		end
	end,
	["waveNotes"]   = function() waveNotes =  true end,
	["noWaveNotes"] = function() waveNotes = false end,

	-- This is where notes get CRAZY
	['lilRandomizeNotes'] = function()
		for i = 0, 3 do
			callMethod("playerStrums.members["..i.."].scale.set", {
				getProperty("playerStrums.members["..i.."].scale.x") + getRandomFloat(-0.2, 0.4),
				getProperty("playerStrums.members["..i.."].scale.y") + getRandomFloat(-0.6, -0.6)
			})
			callMethod("playerStrums.members["..i.."].setPosition", {
				getProperty("playerStrums.members["..i.."].x") + getRandomFloat(-12, 12),
				getProperty("playerStrums.members["..i.."].y") + getRandomFloat(-15, 15)
			})
		end
	end,
	['tweenToCrazy'] = function()
		for i =  0, 3 do
			startTween(i.."StrumTween", "playerStrums.members["..i.."]", {x = screenWidth / 2, y = screenHeight + 150}, 0.4, {ease = "circIn"})
			startTween(i.."ScaleStrumTween", "playerStrums.members["..i.."].scale", {x = 15, y = 15}, 0.4, {ease = "circIn"})
		end
	end,

	['randomizeNotes'] = function()
		for i = 0, 3 do
			callMethod("playerStrums.members["..i.."].scale.set", {getRandomFloat(5, 7), getRandomFloat(5, 7)})
			callMethod("playerStrums.members["..i.."].setPosition", {getRandomFloat(52, 902), getRandomFloat(50, 470)})
		end
	end,

	["tweenToUpscroll"] = function()
		setUpscroll()

		for i = 0, 3 do
			local noteWidth = getPropertyFromGroup('playerStrums', i, 'width')
			local middlePos = (screenWidth / 2) - (((noteWidth + 50 * 2.33) * 4) / 2)
			startTween(i..'UpscrollTween', "playerStrums.members["..i.."]", {x = middlePos + (noteWidth + 50 * 2.33) * i, y = 50}, 1.2, {ease = "circInOut"})
			startTween(i..'UpscrollScaleTween', "playerStrums.members["..i.."].scale", {x = 6, y = 6}, 1.2, {ease = "circInOut"})
		end
	end,

	["tweenToDownscroll"] = function()
		setDownscroll()

		for i = 0, 3 do
			local noteWidth = getPropertyFromGroup('playerStrums', i, 'width')
			local middlePos = (screenWidth / 2) - (((noteWidth + 50 * 2.33) * 4) / 2)
			startTween(i..'UpscrollTween', "playerStrums.members["..i.."]", {x = middlePos + (noteWidth + 50 * 2.33) * i, y = 520}, 1.2, {ease = "circInOut"})
			startTween(i..'UpscrollScaleTween', "playerStrums.members["..i.."].scale", {x = 6, y = 6}, 1.2, {ease = "circInOut"})
		end
	end,

	["bfUpscrollRandomize"] = function()
		for i = 0, 3 do
			local noteWidth = getPropertyFromGroup('playerStrums', i, 'width')
			local middlePos = (screenWidth / 2) - (((noteWidth + 50 * 2.33) * 4) / 2)
			callMethod("playerStrums.members["..i.."].setPosition", {
				middlePos + (noteWidth + 50 * 2.33) * i + getRandomFloat(-12, 12),
				90 + getRandomFloat(-15, 15)
			})
		end
	end,

	["bfDownscrollRandomize"] = function()
		for i = 0, 3 do
			local noteWidth = getPropertyFromGroup('playerStrums', i, 'width')
			local middlePos = (screenWidth / 2) - (((noteWidth + 50 * 2.33) * 4) / 2)
			callMethod("playerStrums.members["..i.."].setPosition", {
				middlePos + (noteWidth + 50 * 2.33) * i + getRandomFloat(-32, 32),
				520 + getRandomFloat(-35, 35)
			})
		end
	end,
	["bfDownscrollBIGRandomize"] = function()
		for i = 0, 3 do
			local noteWidth = getPropertyFromGroup('playerStrums', i, 'width')
			local middlePos = (screenWidth / 2) - (((noteWidth + 50 * 2.33) * 4) / 2)
			callMethod("playerStrums.members["..i.."].setPosition", {
				middlePos + (noteWidth + 50 * 2.33) * i + getRandomFloat(-52, 52),
				520 + getRandomFloat(-75, 75)
			})
		end
	end,
	['finalNote'] = function()
		setUpscroll()

		for i = 0, 3 do
			local noteWidth = getPropertyFromGroup('playerStrums', i, 'width')
			local middlePos = (screenWidth / 2) - (((noteWidth + 50 * 2.33) * 4) / 2)
			callMethod("playerStrums.members["..i.."].setPosition", {
				middlePos + (noteWidth + 50 * 2.33) * i + getRandomFloat(-12, 12),
				90 + getRandomFloat(-15, 15)
			})
			startTween(i..'FallTween', "playerStrums.members["..i.."]", {x = getProperty("playerStrums.members["..i.."].x") + getRandomFloat(-112, 112), y = 920}, 3.2, {ease = "backIn"})
			startTween(i..'FallAngleTween', "playerStrums.members["..i.."]", {angle = getRandomFloat(-62, 62)}, 3.2, {ease = "circIn"})
		end
	end
}

-- Most of this is taken from Dudu's Endless JP modchart. Sorry dude
function setUpscroll()
	for i = 0, 3 do setPropertyFromGroup('playerStrums', i, 'downScroll', false) end
	for i = 0, getProperty('notes.length')-1 do
		if getPropertyFromGroup('notes',i,'mustPress') then
			if getPropertyFromGroup('notes',i,'isSustainNote') then
				setPropertyFromGroup('notes', i, 'flipY', false)
				setPropertyFromGroup('notes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
			end
			updateHitbox('notes.members['..i..']')
		end
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
				setPropertyFromGroup('unspawnNotes',i,'flipY', false)
				setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
			end
			updateHitbox('unspawnNotes['..i..']')
		end
	end
end

function setDownscroll()
	for i = 0, 3 do setPropertyFromGroup('playerStrums', i, 'downScroll', true) end
	for i = 0, getProperty('notes.length')-1 do
		if getPropertyFromGroup('notes',i,'mustPress') then
			if getPropertyFromGroup('notes',i,'isSustainNote') then
				setPropertyFromGroup('notes', i, 'flipY', true)
				setPropertyFromGroup('notes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
			end
			updateHitbox('notes.members['..i..']')
		end
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
				setPropertyFromGroup('unspawnNotes',i,'flipY', true)
				setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
			end
			updateHitbox('unspawnNotes['..i..']')
		end
	end
end

function onEvent(n, v1, v2)
	if n == 'chaotixEvents' then
		if v1 == "modchart" then
			chaotixModchart[v2]()
		else
			starlineEvents[v1](v2)
		end
	end
end

function onBeatHit()
	for _, beatGuys in ipairs(starlineAssets['characters']) do
		if beatGuys.beatIntervals then
			if curBeat %beatGuys.beatIntervals == 0 and not changeIdles then playAnim(beatGuys.name, 'idle', true) end
		end
	end

	if not glitchedActive then spawnStar() else spawnGlitch() end

	if crazyTime and shadersEnabled then
		triggerEvent("glitchFlash", "0.1, 0.001", "0.5")
		triggerEvent("chromFlash", "0.5, 0.1", "0.5")
	end
end

local previousAnimOpp = 'normal'
local previousAnim = 'normal'
local function setIconsAnims()
	if previousAnimOpp == 'normal' and getHealth() > 1.6 then
		playAnim('chaotixBeastStarlineIcon',  'losing', true)
		playAnim('chaotixNormalStarlineIcon', 'losing', true)
		callMethod('chaotixBeastStarlineIcon.setPosition', {500, downscroll and -10 or 560})
		previousAnimOpp = 'losing'
	end

	if previousAnimOpp == 'losing' and getHealth() <= 1.6 then
		playAnim('chaotixBeastStarlineIcon',  'normal', true)
		playAnim('chaotixNormalStarlineIcon', 'normal', true)
		callMethod('chaotixBeastStarlineIcon.setPosition', {400, downscroll and -40 or 520})
		previousAnimOpp = 'normal'
	end

	if previousAnim == 'normal' and getHealth() > 0.4 then
		playAnim('bfStarlineIcon', 'normal', true)
		callMethod('bfStarlineIcon.setPosition', {1110, downscroll and -15 or 545})
		previousAnim = 'losing'
	end

	if previousAnim == 'losing' and getHealth() <= 0.4 then
		playAnim('bfStarlineIcon', 'losing', true)
		callMethod('bfStarlineIcon.setPosition', {1105, downscroll and -15 or 550})
		previousAnim = 'normal'
	end
end

local flyHold = 0
local shaderHold = 0
function onUpdatePost(e)
	flyHold = flyHold + e
	shaderHold = shaderHold + e

	if glitchedActive then setProperty('tails.y', tailsBaseY + getRandomInt(-8, 8))	end

	if transPlaying then setProperty('dad.specialAnim', true) end

	if getProperty('dad.animation.curAnim.name') == 'trans2'    and getProperty('dad.animation.curAnim.finished') and transPlaying then playAnim('dad', 'trans3', true) end

	if getProperty('gf.animation.curAnim.name')  == 'reaction1' and getProperty('gf.animation.curAnim.finished')  and transPlaying then playAnim('gf', 'reaction2', true) end
	if getProperty('gf.animation.curAnim.name')  == 'reaction3' and getProperty('gf.animation.curAnim.finished') then setProperty('gf.skipDance', false) end

	for _, beatGuys in ipairs(starlineAssets['characters']) do
		if beatGuys.canFloat and canFly then
			callMethod(beatGuys.name..'.setPosition', {
				getProperty(beatGuys.name..'.x') + math.cos(flyHold + 0.1) * 0.1,
				getProperty(beatGuys.name..'.y') + math.sin(flyHold + 0.05) * 0.15
			})
		end
	end

	if waveNotes then
		for i = 0, 3  do
			callMethod("playerStrums.members["..i.."].setPosition", {
				getProperty("playerStrums.members["..i.."].x") + math.cos(flyHold + 0.5 + (i * 0.2)) * 0.1,
				getProperty("playerStrums.members["..i.."].y") + math.cos(flyHold + 0.5 + (i * 0.2)) * 0.1
			})
		end
	end

	for _, bg in ipairs(starlineAssets['BGAssets']) do if bgShaderTime and shadersEnabled then setShaderFloat(bg.name, 'iTime', shaderHold) end end

	setIconsAnims()
end

function opponentNoteHitPre(i)
	if getProperty('dad.animation.curAnim.name') == 'trans1' and not getPropertyFromGroup('notes', i, 'mustPress') then setPropertyFromGroup('notes', i, 'noAnimation', true) end

	if glitchedActive then
		if crazyTime then
			cameraShake('camGame', 0.005, 0.1) cameraShake('camHUD', 0.005, 0.1)
		else
			cameraShake('camGame', 0.001, 0.1) cameraShake('camHUD', 0.001, 0.1)
		end
	end

	if crazyTime then
		if getProperty('dad.shader') == nil and shadersEnabled then setSpriteShader('dad', 'NewGlitch2') end

		if shadersEnabled and getRandomInt(0, 1) == 1 then
			setShaderFloat('dad', 'binaryIntensity', getRandomFloat(0.2, 0.8))
			setShaderFloat('dad', 'negativity', getRandomInt(0, 1))
			runTimer('returnChaotixGlitch', 0.5)
		end
	end
end

function onTimerCompleted(t)
	if t ==     'gfReaction3' then playAnim('gf', 'reaction3', true) end
	if t ==     'waitToSpawn' then runTimer('spawnPeaceStars', 0.3, 0) end
	if t == 'spawnPeaceStars' then createPeaceStars() end
	if t ==       'tailsTime' then   spawnTailsText() end

	if t == 'returnChaotixGlitch' and shadersEnabled then setShaderFloat('dad', 'binaryIntensity', 0.001) setShaderFloat('dad', 'negativity', 0) end
end