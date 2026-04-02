local bgSprites = {
	{name = 'city',    path = 'starved/city',    x = -590, y = 190},
	{name = 'bg',      path = 'starved/bg',      x = -550, y = 190},
	{name = 'table',   path = 'starved/table',   x = -470, y = 160},
	{name = 'mrcrabs', path = 'starved/mrcrabs', x = -520, y = 140},
	{name = 'sonic',   path = 'starved/sonic',   x = -530, y = 140},
}

local fgSprites = {
	{name = 'fishF1', path = 'starved/fishF1', x = -430, y = 190, scale = 1.1},
	{name = 'light',  path = 'starved/light',  x = -558, y = 45,  scale = 1.1},
}

local allSpriteNames = {}

local function addSprite(def, inFront)
	local s = def.scale or 1.2
	makeLuaSprite(def.name, def.path, def.x, def.y)
	addLuaSprite(def.name, inFront or false)
	scaleObject(def.name, s, s)
	table.insert(allSpriteNames, def.name)
end

function onCreate()
	for _, spr in ipairs(bgSprites) do
		addSprite(spr)
	end

	makeAnimatedLuaSprite('tv', 'starved/tv', 158, 168)
	addAnimationByPrefix('tv', 'idle', 'idle', 15, true)
	addLuaSprite('tv', false)
	scaleObject('tv', 1.2, 1.2)
	table.insert(allSpriteNames, 'tv')

	for _, spr in ipairs(fgSprites) do
		addSprite(spr, true)
	end

	makeLuaSprite('vignette', 'starved/vinevrom', 0, 0)
	addLuaSprite('vignette', true)
	setObjectCamera('vignette', 'camHUD')
end

local function fadeAllSprites(targetAlpha, duration)
	for i, name in ipairs(allSpriteNames) do
		doTweenAlpha('fade_' .. name, name, targetAlpha, duration, 'linear')
	end
end

local function tintCharacters(color, duration)
	doTweenColor('boyfriendColor', 'boyfriend', color, duration, 'linear')
	doTweenColor('dadColor', 'dad', color, duration, 'linear')
	doTweenColor('sonicColor', 'StarvedSonicDead', color, duration, 'linear')
end

function onMoveCamera(focus)
	if focus == 'dad' then
		setProperty('defaultCamZoom', 1)
		doTweenAlpha('bfFade', 'boyfriend', 0.4, 0.2, 'linear')
	elseif focus == 'boyfriend' then
		setProperty('defaultCamZoom', 0.83)
		doTweenAlpha('bfFade', 'boyfriend', 1, 0.2, 'linear')
	end
end

function onStepHit()
	if curStep == 1184 or curStep == 2240 then
		fadeAllSprites(0, 1)
		doTweenAlpha('fade_light', 'light', 1, 1, 'linear')
		tintCharacters('FF0000', 1)
	elseif curStep == 1952 or curStep == 2688 then
		fadeAllSprites(1, 1)
		tintCharacters('FFFFFF', 1)
	end
end
