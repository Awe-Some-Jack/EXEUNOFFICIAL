local TrilogyBG = {
	{name = 'sky', path = 'bg/sky', x = 0, y = 0, scaleX = 1.3, scaleY = 1.3, scrollX = 1, scrollY = 1, alpha = 1, front = false},
	{name = 'clouds', path = 'bg/clouds', x = 0, y = 0, scaleX = 1.3, scaleY = 1.3, scrollX = 1, scrollY = 1, alpha = 1, front = false},
	{name = 'terrain', path = 'bg/terrain', x = 0, y = 0, scaleX = 1.3, scaleY = 1.3, scrollX = 1, scrollY = 1, alpha = 1, front = false},
}

local dadX, dadY = 0, 0
function onCreatePost()
	setScrollFactor('gf', 1, 1)

	for i = 0,3 do
		setPropertyFromGroup('opponentStrums', i, 'x', -1000)
	end
	dadX, dadY = getProperty('dad.x'), getProperty('dad.y')

	setProperty('camHUD.alpha', 0)
	playAnim('dad', 'intro', true)
	setProperty('dad.specialAnim', true)
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
		setProperty(bg.name ..'.alpha', bg.alpha)
		addLuaSprite(bg.name, bg.front)
	end
end

function onEvent(n,v1)
	if n == 'trilogyEvents' then
		if v1 == 'xd' then
			doTweenAlpha('xddasd', 'camHUD', 1, crochet / (1000 / 32), 'cubeInOut')
		end
	end
end

local floatTime = 0
function onUpdate(e)
	floatTime = floatTime + e
	callMethod('dad.setPosition', {
		dadX + math.cos(floatTime * 0.5) * (10 * 2),
		dadY + math.sin(floatTime) * 10
	})
end