local DigitalizedBG = {
	{name = 'sky', path = 'bg/sky', x = -700, y = -400, scaleX = 1.5, scaleY = 1.5, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'floor', path = 'bg/floor', x = -700, y = -1200, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'exit', path = 'bg/exit', x = -402, y = -690, animated = true, animName = 'idle', animPrefix = 'digitalized new exit frames', fps = 12, loop = true, scaleX = 1.5, scaleY = 1.5, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'portal_platform', path = 'bg/portal_platform', x = -360, y = -800, scaleX = 1.5, scaleY = 1.5, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'left_pillar', path = 'bg/left_pillar', x = -700, y = -1200, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'right_pillar', path = 'bg/right_pillar', x = -700, y = -1200, scaleX = 2, scaleY = 2, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
}

function onCreate()
	for _, bg in ipairs(DigitalizedBG) do
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
end
