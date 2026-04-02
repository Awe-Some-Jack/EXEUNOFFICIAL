local MONITOR_ANIMS = {'fatal', 'nmi', 'needle', 'starv'}
local canGlitch = false
local scorchedSinging = false
local dadOriginalOrder = 0
local greenHillVisible = false

local baseSprites = {
	{name = 'sky',       path = 'hedge/bg',         x = -1180, y = -450, scrollX = 0.45, scrollY = 0.45},
	{name = 'mountains', path = 'hedge/motains',     x = -580,  y = -150, scale = 1.2, scrollX = 0.45, scrollY = 0.45, hq = true},
	{name = 'waterfall', path = 'hedge/Waterfalls',  x = -900,  y = 50,  animated = true, prefix = 'British', fps = 15, scrollX = 0.6, scrollY = 0.6},
	{name = 'bushes',    path = 'hedge/cosa',        x = -990,  y = -50, animated = true, prefix = 'DumbassMF', fps = 15, scale = 1.5, scrollX = 0.8, scrollY = 0.8},
	{name = 'trees',     path = 'hedge/trees',       x = -520,  y = -300, scale = 1.1, hq = true},
	{name = 'floor',     path = 'hedge/floor',       x = -1050, y = 610, scale = 1.4},
	{name = 'rocks',     path = 'hedge/rocks',       x = -1050, y = 560, scale = 1.4, scrollX = 1.2, scrollY = 1.2, front = true, hq = true},
	{name = 'overlay',   path = 'hedge/overlay',     x = -1250, y = -400, scaleX = 1.3, scaleY = 1, alpha = 0.5, front = true, hq = true},
}

local evilSprites = {
	{name = 'skyEvil',       path = 'manual-blast/Sunset',     x = -1180, y = -900, scrollX = 0.45, scrollY = 0.45},
	{name = 'mountainsEvil', path = 'manual-blast/Mountains',  x = -580,  y = -100, scale = 1.04, scrollX = 0.45, scrollY = 0.45, hq = true},
	{name = 'waterfallEvil', path = 'manual-blast/Waterfalls', x = -900,  y = 100,  animated = true, prefix = 'British', fps = 15, scrollX = 0.6, scrollY = 0.6},
	{name = 'bushesEvil',    path = 'manual-blast/Hills',      x = -990,  y = -30,  scale = 1.63, scrollX = 0.8, scrollY = 0.8},
	{name = 'treesEvil',     path = 'manual-blast/Plants',     x = -300,  y = -150, scale = 1.1, hq = true},
	{name = 'floorEvil',     path = 'manual-blast/Floor',      x = -800,  y = 650,  scale = 1.4},
	{name = 'rocksEvil',     path = 'manual-blast/Rocks',      x = -1050, y = 560,  scale = 1.4, scrollX = 1.2, scrollY = 1.2, front = true, hq = true},
}

local glitchSprites = {
	{name = 'skyevil2',       path = 'manual-blast/glitch/sky-glitch',       x = -1280, y = -900, animated = true, prefix = 'idle', fps = 24, scrollX = 0.45, scrollY = 0.45},
	{name = 'motainsevil2',	  path = 'manual-blast/glitch/mountains-glitch', x = -880,  y = -100, animated = true, prefix = 'idle', fps = 12, scaleX = 1.24, scaleY = 1.04, scrollX = 0.45, scrollY = 0.45, hq = true},
	{name = 'waterfallevil2', path = 'manual-blast/glitch/waterfall-glitch', x = -900,  y = 100,  animated = true, prefix = 'idle', fps = 12, scale = 2, scrollX = 0.6, scrollY = 0.6},
	{name = 'thingsevil2',    path = 'manual-blast/glitch/thing-glitch',     x = -990,  y = -30,  animated = true, prefix = 'idle', fps = 12, scale = 1.63, scrollX = 0.9, scrollY = 0.9},
	{name = 'treesevil2',     path = 'manual-blast/glitch/trees-glitch',     x = -400,  y = -150, animated = true, prefix = 'trees-glitch idle', fps = 12, scale = 1.1, hq = true},
	{name = 'floorevil2',     path = 'manual-blast/glitch/floor-glitch',     x = -800,  y = 650,  animated = true, prefix = 'floor-glitch idle', fps = 24, scale = 1.4},
	{name = 'rocksevil2',     path = 'manual-blast/glitch/rocks-glitch',     x = -1050, y = 560,  animated = true, prefix = 'rocks-glitch idle', fps = 12, scale = 1.4, scrollX = 1.2, scrollY = 1.2, front = true, hq = true},
	{name = 'luz2',			  path = 'manual-blast/glitch/overlay',			 x = -1250, y = -450, scaleX = 1.3, scaleY = 1.2, alpha = 0.0001, front = true, blend = 'screen'},
}

local greenHillSprites = {
	{name = 'skyGH',    path = 'green-hill/bg',         x = -500,  y = -400, scale = 1.6, scrollX = 0.3, scrollY = 0.3},
	{name = 'bushesGH', path = 'green-hill/Prankemjohn', x = -670,  y = -165, animated = true, prefix = 'DumbassMF', fps = 15, scale = 1.5, scrollX = 0.8, scrollY = 0.8},
	{name = 'treesGH',  path = 'green-hill/trees',       x = -1000, y = -550, scale = 0.9, hq = true},
	{name = 'totem',    path = 'green-hill/pole',        x = -520,  y = -20,  scale = 2, hq = true},
	{name = 'floorGH',  path = 'green-hill/floor',       x = -1650, y = 510,  scaleX = 1, scaleY = 1.8},
}

local baseNames = {}
local evilNames = {}
local glitchNames = {}
local greenHillNames = {}

local function addSprite(def, hidden)
	if not (lowQuality and def.hq) then
		if def.animated then
			makeAnimatedLuaSprite(def.name, def.path, def.x, def.y)
			addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps or 24, true)
		else
			makeLuaSprite(def.name, def.path, def.x, def.y)
		end
		local sx = def.scaleX or def.scale or 1
		local sy = def.scaleY or def.scale or 1
		if sx ~= 1 or sy ~= 1 then scaleObject(def.name, sx, sy) end
		if def.scrollX then setScrollFactor(def.name, def.scrollX, def.scrollY or def.scrollX) end
		if def.alpha then setProperty(def.name .. '.alpha', def.alpha) end
		if def.blend then setBlendMode(def.name, def.blend) end
		addLuaSprite(def.name, def.front or false)
		if hidden then setProperty(def.name .. '.alpha', 0.0001) end
	end
end

local function showGroup(names)
	for _, name in ipairs(names) do setProperty(name .. '.alpha', 1) end
end

local function removeGroup(names)
	for _, name in ipairs(names) do removeLuaSprite(name, true) end
end

local function collectNames(group)
	local names = {}
	for _, spr in ipairs(group) do names[#names + 1] = spr.name end
	return names
end

function onCreate()
	makeLuaSprite('whitebg')
	makeGraphic('whitebg', 1280, 720, 'FFFFFF')
	screenCenter('whitebg')
	setScrollFactor('whitebg', 0, 0)
	setProperty('whitebg.alpha', 0.0001)
	addLuaSprite('whitebg')

	for _, spr in ipairs(baseSprites) do addSprite(spr) end
	baseNames = collectNames(baseSprites)

	if songPath == 'manual-blast' then
		for _, spr in ipairs(evilSprites) do addSprite(spr, true) end
		evilNames = collectNames(evilSprites)

		if not lowQuality then
			makeAnimatedLuaSprite('monitor', 'manual-blast/Monitor', 1050, 35)
			addAnimationByPrefix('monitor', 'starv', 'Storved', 15, false)
			addAnimationByPrefix('monitor', 'needle', 'Needlemouse', 15, false)
			addAnimationByPrefix('monitor', 'nmi', 'NMI', 15, false)
			addAnimationByPrefix('monitor', 'fatal', 'Fatalerror', 15, false)
			addAnimationByPrefix('monitor', 'idle', 'Monitor', 15, true)
			playAnim('monitor', 'idle', true)
			scaleObject('monitor', 1.4, 1.4)
			setScrollFactor('monitor', 0.8, 0.8)
			setProperty('monitor.alpha', 0.0001)
			addLuaSprite('monitor')
			setObjectOrder('monitor', getObjectOrder('bushesEvil') + 1)
		end

		for _, spr in ipairs(glitchSprites) do addSprite(spr, true) end
		glitchNames = collectNames(glitchSprites)

		if not lowQuality then

			makeAnimatedLuaSprite('cameos1', 'characters/cameos-1', -650, 150)
			addAnimationByPrefix('cameos1', 'idle', 'idle', 24, false)
			scaleObject('cameos1', 0.9, 0.9)
			setProperty('cameos1.visible', false)
			addLuaSprite('cameos1')

			makeAnimatedLuaSprite('cameos2', 'characters/cameos-2', -850, 100)
			addAnimationByPrefix('cameos2', 'idle', 'idle', 24, false)
			scaleObject('cameos2', 0.8, 0.8)
			setProperty('cameos2.visible', false)
			addLuaSprite('cameos2')
		end

		addCharacterToList('scorched-g', 'dad')
		addCharacterToList('scorched-g2', 'dad')
	end

	if not lowQuality then
		makeAnimatedLuaSprite('t', 'characters/t')
		addAnimationByPrefix('t', 'idle', 'Símbolo 128 instancia 1', 24, false)
		addAnimationByIndices('t', 'idle-loop', 'Símbolo 128 instancia 1', {11, 12, 13}, 24, true)
		addAnimationByPrefix('t', 'idle1', 'idle1 instancia 1', 24, false)
		addAnimationByIndices('t', 'idle1-loop', 'idle1 instancia 1', {11, 12, 13}, 24, true)
		addAnimationByPrefix('t', 'idle2', 'idle2 instancia 1', 24, false)
		addAnimationByIndices('t', 'idle2-loop', 'idle2 instancia 1', {11, 12, 13}, 24, true)
		addAnimationByPrefix('t', 'idle3', 'idle3 instancia 1', 24, false)
		addAnimationByIndices('t', 'idle3-loop', 'idle3 instancia 1', {11, 12, 13}, 24, true)
		addAnimationByPrefix('t', 'idle4', 'idle3 instancia 2', 24, false)
		addAnimationByIndices('t', 'idle4-loop', 'idle3 instancia 2', {11, 12, 13}, 24, true)
		scaleObject('t', 0.9, 0.9, false)
		addLuaSprite('t')

		makeAnimatedLuaSprite('k', 'characters/k', 1350, 450)
		addAnimationByPrefix('k', 'idle', 'j instancia 1', 24, false)
		scaleObject('k', 0.9, 0.9, false)
		addLuaSprite('k', true)
		setObjectOrder('k', getObjectOrder('boyfriendGroup') + 1)
	end

	if songPath == 'hedge' then
		for _, spr in ipairs(greenHillSprites) do addSprite(spr, true) end
		greenHillNames = collectNames(greenHillSprites)
	end

	makeLuaSprite('blackBg', nil, -650, -750)
	makeGraphic('blackBg', 2750, 1850, '000000')
	setProperty('blackBg.alpha', 0.0001)
	addLuaSprite('blackBg')

	dadOriginalOrder = getObjectOrder('dadGroup')

	makeLuaSprite('blackBgFront', nil, -650, -750)
	makeGraphic('blackBgFront', 2750, 1850, '000000')
	setProperty('blackBgFront.alpha', 0.0001)
	addLuaSprite('blackBgFront', true)

	precacheImage('characters/texe')
	precacheImage('characters/kexe')
end

function onCreatePost()
	setScrollFactor('gf', 1, 1)
end

local floatTime = 0

function onUpdatePost(elapsed)
	if not lowQuality then
		if getProperty('t.animation.curAnim.finished') and not stringEndsWith(getProperty('t.animation.curAnim.name'), 'loop') then playAnim('t', getProperty('t.animation.curAnim.name')..'-loop', true) end

		floatTime = floatTime + elapsed * 2 * playbackRate
		callMethod('t.setPosition', {200 + math.cos(floatTime / 2) * 5, math.sin(floatTime) * 10})
	end

	if canGlitch then
		if not lowQuality then
			setProperty('cameos1.alpha', getRandomFloat(0.5, 0.9))
			setProperty('cameos2.alpha', getRandomFloat(0.5, 0.9))
		end
		setProperty('gf.alpha', getRandomFloat(0.3, 0.7))
		if not lowQuality then
			setProperty('t.alpha', getRandomFloat(0.5, 0.9))
			setProperty('k.alpha', getRandomFloat(0.3, 0.7))
		end

		scaleObject('whitebg', 1 / getProperty('camGame.zoom'), 1 / getProperty('camGame.zoom'), false)
	end
end

function onBeatHit()
	if curBeat % 2 ~= 0 then return end

	if canGlitch and getRandomBool(30) and stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'idle') then
		playAnim('boyfriend', 'idle-g', true)
	end

	if not lowQuality then
		if canGlitch then
			playAnim('cameos2', 'idle', true)
			playAnim('cameos1', 'idle', true)
		end

		playAnim('t', 'idle', true)
		playAnim('k', 'idle', true)

		if canGlitch and scorchedSinging then
			local variant = getRandomInt(1, 3)
			playAnim('t', 'idle-'..variant, true)
			playAnim('k', 'idle-'..variant, true)
		end

		if songPath == 'manual-blast' then
			if curBeat == 128 then playAnim('t', 'idle1', true) end
			if curBeat >= 129 and curBeat < 175 then playAnim('t', 'idle2', true) end
			if curBeat >= 175 and curBeat < 191 then playAnim('t', 'idle4', true) end
			if curBeat >= 191 and curBeat < 207 then playAnim('t', 'idle3', true) end
		end
	end
end

function onSectionHit()
	if curSection >= 178 and curSection % 2 == 0 then
		if not lowQuality then playAnim('monitor', MONITOR_ANIMS[getRandomInt(1, 4)], true) end
	end
end

local function setBlackBgs(alpha, duration)
	if duration then
		doTweenAlpha('blackBgFade', 'blackBg', alpha, duration)
		doTweenAlpha('blackBgFrontFade', 'blackBgFront', alpha, duration)
	else
		cancelTween('blackBgFade')
		cancelTween('blackBgFrontFade')
		setProperty('blackBg.alpha', alpha)
		setProperty('blackBgFront.alpha', alpha)
	end
end

function onEvent(n, v1, v2)
	if n == 'ghhcselol' then
		greenHillVisible = not greenHillVisible
		if greenHillVisible then
			for _, name in ipairs(greenHillNames) do
				setProperty(name .. '.alpha', getRandomFloat(0.85, 1))
			end
			setProperty('rocks.alpha', getRandomFloat(0, 0.1))
			setProperty('overlay.alpha', getRandomFloat(0.1, 0.5))
			doTweenAlpha('blackBgFade', 'blackBg', 0.6, 0.2, 'cubeOut')
		else
			for _, name in ipairs(greenHillNames) do
				setProperty(name .. '.alpha', 0)
			end
			setProperty('rocks.alpha', 1)
			setProperty('overlay.alpha', 0.5)
			doTweenAlpha('blackBgFade', 'blackBg', 0, 0.2, 'cubeOut')
		end

	elseif n == 'damnfuckingcolorscorched' then
		cancelTween('dadColor')
		setProperty('dad.color', getColorFromHex('FFFFFF'))

	elseif n == 'sexxxxxx' then
		if v1 == 'anglecam' and songPath == 'hedge' then
			doTweenAngle('camAngle', 'camGame', 25, 3, 'cubeOut')

		elseif v1 == 'backangle' and songPath == 'hedge' then
			doTweenAngle('camAngle', 'camGame', 0, stepCrochet / (1000 / 2), 'cubeIn')

		elseif v1 == 'hidehud' then
			setObjectOrder('dadGroup', getObjectOrder('blackBgFront') + 1)
			doTweenAlpha('camHudFade', 'camHUD', 0, crochet / 250)
			setBlackBgs(0.6, crochet / 250)

		elseif v1 == 'blackbg' then
			doTweenColor('dadColor', 'dad', '000000', crochet / 500)
			setBlackBgs(1, crochet / 500)

		elseif v1 == 'beat' then
			cancelTween('dadColor')
			setProperty('dad.color', getColorFromHex('FFFFFF'))
			doTweenColor('dadColor', 'dad', '000000', crochet / 1000)
			setBlackBgs(0.6)
			setBlackBgs(1, crochet / 1000)

		elseif v1 == 'appear' then
			setObjectOrder('dadGroup', dadOriginalOrder)
			cancelTween('dadColor')
			doTweenColor('dadColor', 'dad', 'FFFFFF', crochet / 500)
			doTweenAlpha('camHudFade', 'camHUD', 1, crochet / 250)
			setBlackBgs(0, crochet / 500)

		elseif v1 == 'newbg' then
			removeGroup(baseNames)

			showGroup(evilNames)
			if not lowQuality then setProperty('monitor.alpha', 1) end

			if not lowQuality then
				loadFrames('k', 'characters/kexe')
				addAnimationByPrefix('k', 'idle', 'gkx instancia 1', 24, false)
				addOffset('k', 'idle', 0, 0)
				addAnimationByPrefix('k', 'idle-1', 'gkx g1', 24, false)
				addOffset('k', 'idle-1', 0, 0)
				addAnimationByPrefix('k', 'idle-2', 'gkx g2', 24, false)
				addOffset('k', 'idle-2', 150, 0)
				addAnimationByPrefix('k', 'idle-3', 'gkx g3', 24, false)
				addOffset('k', 'idle-3', 0, 0)

				callMethod('k.setPosition', {1600, 210})
				setObjectOrder('k', getObjectOrder('gfGroup') + 1)
			end
		elseif v1 == 'tailsexe' then
			if not lowQuality then
				loadFrames('t', 'characters/texe')
				addAnimationByPrefix('t', 'idle', 'idle', 24, false)
				addAnimationByIndices('t', 'idle-loop', 'idle instancia 1', {10, 11, 12, 13}, 24, true)
				addAnimationByPrefix('t', 'idle-1', 'g1', 24, false)
				addAnimationByPrefix('t', 'idle-2', 'g2', 24, false)
				addAnimationByPrefix('t', 'idle-3', 'g3', 24, false)
			end
		elseif v1 == 'glitchbg' then
			canGlitch = true

			removeGroup(evilNames)
			if not lowQuality then removeLuaSprite('monitor', true) end
			showGroup(glitchNames)
			setProperty('luz2.alpha', 0.0001)

			for i = 1, 2 do
				local name = 'illegalTxt' .. i
				createInstance(name, 'flixel.addons.display.FlxBackdrop', {nil, 0x11, 36})
				loadGraphic(name, 'manual-blast/glitch/illegalinstruction')
				addInstance(name)
				setScrollFactor(name, 0, 0)
				scaleObject(name, 2.5, 2.5)
				setProperty(name .. '.color', getColorFromHex('000000'))
				setProperty(name .. '.alpha', 0)
			end
			setProperty('illegalTxt1.velocity.x', 250)
			setProperty('illegalTxt1.velocity.y', 30)
			setProperty('illegalTxt2.velocity.x', 100)
			setProperty('illegalTxt2.velocity.y', 10)
			setProperty('illegalTxt2.y', 50)
			setProperty('illegalTxt2.x', 70)

			setProperty('whitebg.alpha', 1)
		elseif v1 == 'illegali' then
			doTweenAlpha('illegalFade1', 'illegalTxt1', 1, 20)
			doTweenAlpha('illegalFade2', 'illegalTxt2', 1, 20)

		elseif v1 == 'byebyemanual' then
			doTweenAlpha('camHudFade', 'camHUD', 0, 3)
			doTweenAlpha('dadFade', 'dad', 0, 3)
			doTweenAlpha('bfFade', 'boyfriend', 0, 3)
			doTweenAlpha('glitchOverlayFade', 'luz2', 0, 2)
			doTweenZoom('endZoom', 'game', 0.3, 3.1, 'cubeIn')
		elseif v1 == 'changeIcon' then
			setProperty('hbHealth2.color', getColorFromHex('171E4A'))
			callMethod('iconOpp.changeIcon', {'scorched'})
		end
	end
end

function opponentNoteHit()
	if canGlitch then
		cancelTimer('scorchedTimer')
		scorchedSinging = true
		runTimer('scorchedTimer', 0.35)
	end
end

function onTweenCompleted(tag)
	if tag == 'endZoom' then setProperty('defaultCamZoom', 0.3) end
end

function onTimerCompleted(tag)
	if tag == 'scorchedTimer' then scorchedSinging = false end
end