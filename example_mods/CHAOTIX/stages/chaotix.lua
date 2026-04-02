local ChaotixBG = {
	{name = 'bg', path = 'bg/horizonbg', x = -1800, y = -1200, scaleX = 6, scaleY = 6, scrollX = 0.8, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'floor', path = 'bg/horizonFg', x = -1800, y = -1200, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'BG_amy', path = 'bg/characters/BG_amy', danceEveryBeats = 2, x = 700, y = -40, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false, animated = true, animName = 'idle', animPrefix = 'amy bobbing', fps = 24, loop = false},
	{name = 'BG_charmy', path = 'bg/characters/BG_charmy', danceEveryBeats = 1, x = 500, y = -60, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false, animated = true, animName = 'idle', animPrefix = 'charmy bobbing', fps = 24, loop = false},
	{name = 'BG_espio', path = 'bg/characters/BG_espio', danceEveryBeats = 1, x = 1080, y = -18.3, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false, animated = true, animName = 'idle', animPrefix = 'espio bobbing', fps = 24, loop = false},
	{name = 'BG_knuckles', path = 'bg/characters/BG_knuckles', danceEveryBeats = 2, x = -820, y = -35, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false, animated = true, animName = 'idle', animPrefix = 'knuckles bobbing', fps = 24, loop = false},
	{name = 'BG_mighty', path = 'bg/characters/BG_mighty', danceEveryBeats = 2, x = -75, y = -15, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false, animated = true, animName = 'idle', animPrefix = 'mighty bobbing', fps = 24, loop = false},
	{name = 'BG_vector', path = 'bg/characters/BG_vector', danceEveryBeats = 1, x = -1200, y = -70, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false, animated = true, animName = 'idle', animPrefix = 'vector bobbing', fps = 24, loop = false}
}

local GlitchedBG = {
	{name = 'bgglitch', path = 'bg/bgglitch', x = -1800, y = -1200, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'bgglitch idle', fps = 24, loop = true},
	{name = 'horizonFuckedUp', path = 'bg/horizonFuckedUp', x = -1800, y = -1200, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false},
	{name = 'BG_amy2', path = 'bg/characters/BG_amy', danceEveryBeats = 2, x = 700, y = -40, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'amy fear', fps = 24, loop = true},
	{name = 'BG_charmy2', path = 'bg/characters/BG_charmy', danceEveryBeats = 1, x = 500, y = -60, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'charmy fear', fps = 24, loop = true},
	{name = 'BG_espio2', path = 'bg/characters/BG_espio', danceEveryBeats = 1, x = 1080, y = -18.3, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'espio fear', fps = 24, loop = true},
	{name = 'BG_knuckles2', path = 'bg/characters/BG_knuckles', danceEveryBeats = 2, x = -820, y = -35, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'knuckles fear', fps = 24, loop = true},
	{name = 'BG_mighty2', path = 'bg/characters/BG_mighty', danceEveryBeats = 2, x = -75, y = -15, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'mighty fear', fps = 24, loop = true},
	{name = 'BG_vector2', path = 'bg/characters/BG_vector', danceEveryBeats = 1, x = -1200, y = -70, scaleX = 6, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 0, front = false, animated = true, animName = 'idle', animPrefix = 'vector fear', fps = 24, loop = true}
}

local glitchedActive = false
local transPlaying = false
local starCount = 0
local glitchCount = 0
local tailsBaseY = -1600

function onCreate()
	for _, bg in ipairs(ChaotixBG) do
		if bg.animated then
			makeAnimatedLuaSprite(bg.name, bg.path, bg.x, bg.y)
			addAnimationByPrefix(bg.name, bg.animName, bg.animPrefix, bg.fps, bg.loop)
		else
			makeLuaSprite(bg.name, bg.path, bg.x, bg.y)
		end
		scaleObject(bg.name, bg.scaleX, bg.scaleY)
		setScrollFactor(bg.name, bg.scrollX, bg.scrollY)
		setProperty(bg.name ..'.antialiasing', bg.antialiasing)
		setProperty(bg.name ..'.alpha', bg.alpha)
		addLuaSprite(bg.name, bg.front)
	end

	createInstance('tails', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('tails', 'bg/tails')
	setProperty('tails.velocity.x', -400)
	setProperty('tails.y', -1600)
	scaleObject('tails', 6, 6)
	setScrollFactor('tails', 1, 1)
	setProperty('tails.antialiasing', false)
	setProperty('tails.alpha', 0)
	addInstance('tails')

	for _, bg in ipairs(GlitchedBG) do
		if bg.animated then
			makeAnimatedLuaSprite(bg.name, bg.path, bg.x, bg.y)
			addAnimationByPrefix(bg.name, bg.animName, bg.animPrefix, bg.fps, bg.loop)
		else
			makeLuaSprite(bg.name, bg.path, bg.x, bg.y)
		end
		scaleObject(bg.name, bg.scaleX, bg.scaleY)
		setScrollFactor(bg.name, bg.scrollX, bg.scrollY)
		setProperty(bg.name ..'.antialiasing', bg.antialiasing)
		setProperty(bg.name ..'.alpha', bg.alpha)
		addLuaSprite(bg.name, bg.front)
	end

	makeLuaSprite('blackOverlay', nil, -3000, -3000)
	makeGraphic('blackOverlay', 8000, 8000, '000000')
	setScrollFactor('blackOverlay', 0, 0)
	setProperty('blackOverlay.alpha', 0)
	addLuaSprite('blackOverlay', false)
end

function onCreatePost()
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
	end
end

function onBeatHit()
	if curBeat == 228 then
		transPlaying = true
		setProperty('dad.specialAnim', true)
		playAnim('dad', 'trans', true)
	end

	if curBeat == 231 then
		doTweenAlpha('fadeToBlack', 'blackOverlay', 1, 2, 'sineIn')
	end

	if curBeat == 271 then
		glitchedActive = true
		for _, bg in ipairs(ChaotixBG) do
			setProperty(bg.name..'.alpha', 0)
		end
		setProperty('tails.alpha', 1)
		for _, bg in ipairs(GlitchedBG) do
			setProperty(bg.name..'.alpha', 1)
		end
		transPlaying = false
		triggerEvent('Change Character', '1', 'beast_chaotix')
		setProperty('dad.x', -376.9)
		setProperty('dad.y', 120.7)
		doTweenAlpha('fadeFromBlack', 'blackOverlay', 0, 1.5, 'sineOut')
	end

	for _, bg in ipairs(ChaotixBG) do
		if bg.animated and curBeat % bg.danceEveryBeats == 0 then
			playAnim(bg.name, bg.animName, true)
		end
	end

	if not glitchedActive then
		for i = 1,5 do
			spawnStar()
		end
	else
		for i = 1, 10 do
			spawnGlitch()
		end
	end
end

function onUpdatePost()
	if glitchedActive then
		setProperty('tails.y', tailsBaseY + getRandomInt(-8, 8))
	end
	if transPlaying then
		setProperty('dad.specialAnim', true)
	end
end