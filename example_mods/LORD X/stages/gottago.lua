local bgSprites = {
	{name = 'ring', path = 'gottago/ring', x = -1090, y = -500, scale = 0.3},
}

local function addSprite(def)
	if def.animated then
		makeAnimatedLuaSprite(def.name, def.path, def.x, def.y)
		addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps or 24, true)
	else
		makeLuaSprite(def.name, def.path, def.x, def.y)
	end
	if def.scale then scaleObject(def.name, def.scale, def.scale) end
	if def.scrollX then setScrollFactor(def.name, def.scrollX, def.scrollY or def.scrollX) end
	addLuaSprite(def.name, def.front)
end

local BG_SCALE = 0.90
local BG_WIDTH = 2732 * BG_SCALE
local BG_COUNT = 4
local BG_SPEED = 2500
local BG_Y = -600
local bgStartX = -1350

function onCreate()
	for i = 0, BG_COUNT - 1 do
		local name = 'bg' .. i
		makeLuaSprite(name, 'gottago/bg', bgStartX + (BG_WIDTH * i), BG_Y)
		scaleObject(name, BG_SCALE, BG_SCALE)
		setProperty(name .. '.antialiasing', false)
		if i % 2 == 1 then setProperty(name .. '.flipX', true) end
		addLuaSprite(name)
	end

	for _, spr in ipairs(bgSprites) do addSprite(spr) end
end

function onCreatePost()
	setProperty('boyfriend.alpha', 0)
	setObjectOrder('dadGroup', getObjectOrder('boyfriendGroup') + 1)
	setObjectOrder('boyfriendGroup', getObjectOrder('dadGroup') + 1)
end

function onUpdatePost(elapsed)
	local totalWidth = BG_WIDTH * BG_COUNT
	for i = 0, BG_COUNT - 1 do
		local name = 'bg' .. i
		local x = getProperty(name .. '.x') - BG_SPEED * elapsed
		if x + BG_WIDTH < bgStartX then
			x = x + totalWidth
		end
		setProperty(name .. '.x', x)
	end
end
