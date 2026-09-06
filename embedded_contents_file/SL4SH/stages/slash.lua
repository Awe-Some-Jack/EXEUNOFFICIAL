local SCALE = 6
local OFFSET_X = -604

local stage1 = {
	{name = 'slashCracks', path = 'bg/slashCracks', x = -600, y = -353, animated = true, prefix = 'idle', fps = 12},
	{name = 'slashFloor',  path = 'bg/slashFloor',  x = -600, y = -234},
	{name = 'shaderRoom',  path = 'bg/Shader_Room',  x = -600, y = -318, front = true},
	{name = 'slashLava',   path = 'bg/slashLava',   x = -640, y = -372, animated = true, prefix = 'sl4sh background lava', fps = 24, front = true},
	{name = 'slashLava2',   path = 'bg/slashLava',   x = 1226, y = -372, animated = true, prefix = 'sl4sh background lava', fps = 24, front = true},
}

local stage2 = {
	{name = 'povBg',       path = 'bg/povyoufuckingsuckatthegame', x = OFFSET_X, y = -313},
	{name = 'povLava',     path = 'bg/pov_lava',                  x = OFFSET_X, y = -372, animated = true, prefix = 'POV lava', fps = 24},
	{name = 'lavaGlow',    path = 'bg/lava_glow',                 x = OFFSET_X, y = -313},
	{name = 'povSlash',    path = 'bg/povslashisgonnagetcha',      x = OFFSET_X, y = -313 - (SCALE * 12)},
	{name = 'roomShader',  path = 'bg/Room_Shader',               x = -600, y = -318, front = true},
}

local function addSprite(def, visible)
	if def.animated then
		makeAnimatedLuaSprite(def.name, def.path, def.x, def.y)
		addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps, true)
	else
		makeLuaSprite(def.name, def.path, def.x, def.y)
	end
	addLuaSprite(def.name, def.front or false)
	setProperty(def.name .. '.antialiasing', false)
	scaleObject(def.name, SCALE, SCALE)
	if visible == false then
		setProperty(def.name .. '.visible', false)
	end
end

function onCreatePost()
	for _, spr in ipairs(stage1) do
		addSprite(spr)
	end

	for _, spr in ipairs(stage2) do
		addSprite(spr, false)
	end

	addCharacterToList('sl4shfront', 'dad')

	setProperty('hbBG.alpha', 0)
	setProperty('hbHealth.alpha', 0)
	setProperty('hbHealth2.alpha', 0)
	setProperty('healthBG.alpha', 0)
	
	makeLuaSprite('bghb',  'pixelUI/hud/hbBG', 0, 0)
	setObjectCamera('bghb', 'camHUD')
	scaleObject('bghb', 2.5, 2.5)
	makeLuaSprite('leftBar',  'pixelUI/hud/bar1', 0, 0)
	makeLuaSprite('rightBar', 'pixelUI/hud/bar2', 0, 0)
	setObjectCamera('leftBar', 'camHUD') setObjectCamera('rightBar', 'camHUD')
	setObjectOrder('leftBar', getObjectOrder('separatorHealth')) setObjectOrder('rightBar', getObjectOrder('separatorHealth'))
	callMethod('leftBar.setPosition',  {getProperty('hbHealth.x'), getProperty('hbHealth.y')})
	callMethod('bghb.setPosition',  {getProperty('hbHealth.x') - 4, getProperty('hbHealth.y') - 42.5})
	callMethod('rightBar.setPosition', {getProperty('hbHealth2.x'), getProperty('hbHealth2.y')})
	setProperty('leftBar.antialiasing', false)
	setProperty('bghb.antialiasing', false)
	setProperty('rightBar.antialiasing', false)
	addLuaSprite('leftBar') addLuaSprite('rightBar')
	setObjectOrder('bghb', getObjectOrder('leftBar') - 1)
end

function onEvent(n)
	if n ~= 'slashchangeBG' then return end

	setProperty('boyfriend.visible', false)
	setProperty('dad.y', getProperty('dad.y') - 150)
	triggerEvent('Change Character', 'dad', 'sl4shfront')

	removeLuaSprite('wall', true) removeLuaSprite('lines', true)
	for _, spr in ipairs(stage1) do
		removeLuaSprite(spr.name, true)
	end

	for _, spr in ipairs(stage2) do
		setProperty(spr.name .. '.visible', true)
	end
end


local lerpHealth = 1
function onUpdatePost(e)
	lerpHealth = lerp(getHealth(), lerpHealth, math.exp(-e * 12 * playbackRate))
	setGraphicSize('rightBar', bound(lerpHealth, 0, 2) * ((601 - 10) / 2), 25 - 10)
	setGraphicSize('leftBar',  bound(2 - lerpHealth, 0, 2) * ((601 - 10) / 2), 25 - 10)
	setProperty('rightBar.x', getProperty('leftBar.x') + getProperty('leftBar.width'))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end