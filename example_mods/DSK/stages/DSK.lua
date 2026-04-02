local BG = {
	{name = 'sky',	path = 'Miasma/sky', x = -800, y = -600, scaleX = 1.5, scaleY = 1.5, scrollX = 0.5, scrollY = 0.5, front = false},
	{name = 'rock4', path = 'Miasma/rock4', x = -1050, y = -680, scaleX = 1, scaleY = 1, scrollX = 0.6, scrollY = 0.6, front = false},
	{name = 'rock3', path = 'Miasma/rock3', x = -1050, y = -680, scaleX = 1, scaleY = 1, scrollX = 0.7, scrollY = 0.7, front = false},
	{name = 'rock2', path = 'Miasma/rock2', x = -1050, y = -680, scaleX = 1, scaleY = 1, scrollX = 0.8, scrollY = 0.8, front = false},
	{name = 'rock1', path = 'Miasma/rock1', x = -1050, y = -680, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, front = false},
	{name = 'tree1', path = 'Miasma/tree', x = -1050, y = -180, scaleX = 0.2, scaleY = 0.2, scrollX = 1, scrollY = 1, flipX = true, front = false},
	{name = 'tree2', path = 'Miasma/tree', x = 650, y = -180, scaleX = 0.2, scaleY = 0.2, scrollX = 1, scrollY = 1, front = false},
	{name = 'floor', path = 'Miasma/floor', x = -1050, y = -680, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, front = false},
	{name = 'FG1', path = 'Miasma/FG1', x = -1050, y = -680, scaleX = 1, scaleY = 1, scrollX = 1.2, scrollY = 1.2, front = true},
}

local function addSprite(def)
	makeLuaSprite(def.name, def.path, def.x, def.y)
	scaleObject(def.name, def.scaleX, def.scaleY)
	setScrollFactor(def.name, def.scrollX, def.scrollY)
	if def.flipX then
		setProperty(def.name..'.flipX', def.flipX)
	end
	addLuaSprite(def.name, def.front)
end

function onCreatePost()
	for _, bg1 in ipairs(BG) do
		addSprite(bg1)
	end
end