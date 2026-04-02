local SubstantialBG = {
	{name = 'sky', path = 'bg/sky', x = -700, y = -550, scaleX = 1.5, scaleY = 1.5, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'floorst', path = 'bg/floorst', x = -700, y = -600, scaleX = 1.5, scaleY = 1.5, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
}

function onCreate()
	for _, bg in ipairs(SubstantialBG) do
		makeLuaSprite(bg.name, bg.path, bg.x, bg.y)
		scaleObject(bg.name, bg.scaleX, bg.scaleY)
		setScrollFactor(bg.name, bg.scrollX, bg.scrollY)
		setProperty(bg.name ..'.antialiasing', bg.antialiasing)
		setProperty(bg.name ..'.alpha', bg.alpha)
		addLuaSprite(bg.name, bg.front)
	end
end
