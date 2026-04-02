
local NeedleBG = {
	{name = 'sky', path = 'exe/needlemouse/sky', x = 450, y = -100, scaleX = 1, scaleY = 1, scrollX = 0.7, scrollY = 0.7, antialiasing = false, alpha = 1, front = false},
	{name = 'mountain', path = 'exe/needlemouse/mountains', x = 700, y = 120, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, antialiasing = false, alpha = 1, front = false},
	{name = 'ruins', path = 'exe/needlemouse/ruins', x = 740, y = 120, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'build', path = 'exe/needlemouse/buildings', x = 740, y = 120, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'floor', path = 'exe/needlemouse/CONK_CREET', x = 740, y = 120, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false}
}

local NeedleFG = {
	{name = 'FG', path = 'exe/needlemouse/fg', x = 1000, y = 200, scaleX = 1, scaleY = 1, scrollX = 1.1, scrollY = 1.1, antialiasing = false, alpha = 1, front = true}
}

function onCreate()

	for _, bg in ipairs(NeedleBG) do
		makeLuaSprite(bg.name, bg.path, bg.x, bg.y)
		scaleObject(bg.name, bg.scaleX, bg.scaleY)
		setScrollFactor(bg.name, bg.scrollX, bg.scrollY)
		setProperty(bg.name ..'.antialiasing', bg.antialiasing)
		setProperty(bg.name ..'.alpha', bg.alpha)
		addLuaSprite(bg.name, bg.front)
	end

	for _, fg in ipairs(NeedleFG) do
		makeLuaSprite(fg.name, fg.path, fg.x, fg.y)
		scaleObject(fg.name, fg.scaleX, fg.scaleY)
		setScrollFactor(fg.name, fg.scrollX, fg.scrollY)
		setProperty(fg.name ..'.antialiasing', fg.antialiasing)
		setProperty(fg.name ..'.alpha', fg.alpha)
		addLuaSprite(fg.name, fg.front)
	end
end
