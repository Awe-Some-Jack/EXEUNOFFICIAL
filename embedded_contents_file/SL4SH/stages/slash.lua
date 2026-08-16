local SCALE = 6
local OFFSET_X = -604

local stage1 = {
	{name = 'slashCracks', path = 'bg/slashCracks', x = -600, y = -353, animated = true, prefix = 'idle', fps = 12},
	{name = 'slashFloor',  path = 'bg/slashFloor',  x = -600, y = -234},
	{name = 'shaderRoom',  path = 'bg/Shader_Room',  x = -600, y = -318, front = true},
	{name = 'slashLava',   path = 'bg/slashLava',   x = -504, y = -372, animated = true, prefix = 'sl4sh background lava', fps = 24, front = true},
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

	setProperty('hbHealth.alpha', 0)
	setProperty('hbHealth2.alpha', 0)
	
	makeLuaSprite('leftBar',  'pixelUI/hud/bar1', 0, 0)
	makeLuaSprite('rightBar', 'pixelUI/hud/bar2', 0, 0)
	setObjectCamera('leftBar', 'camHUD') setObjectCamera('rightBar', 'camHUD')
	setObjectOrder('leftBar', getObjectOrder('separatorHealth')) setObjectOrder('rightBar', getObjectOrder('separatorHealth'))
	callMethod('leftBar.setPosition',  {getProperty('hbHealth.x')  - 5, getProperty('hbHealth.y') - 4.5})
	callMethod('rightBar.setPosition', {getProperty('hbHealth2.x') - 5, getProperty('hbHealth2.y') - 4.5})
	setProperty('leftBar.antialiasing', false)
	setProperty('rightBar.antialiasing', false)
	addLuaSprite('leftBar') addLuaSprite('rightBar')
	setObjectOrder('healthBG', getObjectOrder('leftBar'))
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


function onUpdatePost()
	scaleObject('rightBar', clamp(getHealth(), 0, 2) * 3.685, 4)
	scaleObject('leftBar',  clamp(2 - getHealth(), 0, 2) * 3.685, 4)
	setProperty('rightBar.x', getProperty('leftBar.x') + getProperty('leftBar.width') - 10pp)
end

function clamp(val, lower, upper)
    return math.min(math.max(val, lower), upper)
end