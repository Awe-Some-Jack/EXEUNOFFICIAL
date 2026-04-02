local TrilogyBG = {
	{name = 'sky', path = 'bg/sky', x = 0, y = 0, scaleX = 1.3, scaleY = 1.3, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'clouds', path = 'bg/clouds', x = 0, y = 0, scaleX = 1.3, scaleY = 1.3, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
	{name = 'terrain', path = 'bg/terrain', x = 0, y = 0, scaleX = 1.3, scaleY = 1.3, scrollX = 1, scrollY = 1, antialiasing = false, alpha = 1, front = false},
}

function onCreatePost()
	setScrollFactor('gf', 1, 1)

	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'visible', false)
	end
end

function onCreate()
	for _, bg in ipairs(TrilogyBG) do
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
