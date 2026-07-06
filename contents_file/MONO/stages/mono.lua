local monoBG = {
	{name = 'cielo 7', x = -1150, y = -950, front = false, scroll = 0.3},
	{name = 'nubes 6', x = -1150, y = -850, backdrop = true, velocity = 100, front = false, scroll = 0.3},
	{name = 'mar', x = -1150, y = -950, animated = true, animPrefix = 'idle', front = false, scroll = 0.6},
	{name = 'montanas 4', x = -1150, y = -950, front = false, scroll = 0.6},
	{name = 'suelo 3', x = -1150, y = -950, front = false, scroll = 1},
	{name = 'torre fea con bocas bien feas 2', x = -1150, y = -950, front = true, scroll = 1.2},
	{name = 'roca 1', x = -1150, y = -950, front = true, scroll = 1.2}
}

function onCreatePost()
	for _,m in ipairs(monoBG) do
		if m.backdrop == true then
			createInstance(m.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
			loadGraphic(m.name, 'bg/'..m.name)
			callMethod(m.name..'.setPosition', {m.x, m.y})
			setProperty(m.name..'.velocity.x', m.velocity)
			addInstance(m.name, m.front)
		else
			if m.animated == true then
				makeAnimatedLuaSprite(m.name, 'bg/'..m.name, m.x, m.y)
				addAnimationByPrefix(m.name, 'idle', m.animPrefix, 6, true)
			else makeLuaSprite(m.name, 'bg/'..m.name, m.x, m.y) end
			addLuaSprite(m.name, m.front)
		end
		scaleObject(m.name, 0.8, 0.8)
		setScrollFactor(m.name, m.scroll, m.scroll)

		if m.backdrop == true then
			createInstance(m.name..'glitch', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
			loadGraphic(m.name..'glitch', 'bg/glitch/'..m.name)
			callMethod(m.name..'glitch.setPosition', {m.x, m.y})
			setProperty(m.name..'glitch.velocity.x', m.velocity)
			addInstance(m.name..'glitch', m.front)
		else
			if m.animated == true then
				makeAnimatedLuaSprite(m.name..'glitch', 'bg/glitch/'..m.name, m.x, m.y)
				addAnimationByPrefix(m.name..'glitch', 'idle', m.animPrefix, 6, true)
			else makeLuaSprite(m.name..'glitch', 'bg/glitch/'..m.name, m.x, m.y) end
			addLuaSprite(m.name..'glitch', m.front)
		end
		scaleObject(m.name..'glitch', 0.8, 0.8)
		setScrollFactor(m.name..'glitch', m.scroll, m.scroll)
		setProperty(m.name..'glitch.visible', false)
	end

	makeLuaSprite('blackbg', nil, -1150, -950)
	makeGraphic('blackbg', 3000, 2000, '000000')
	addLuaSprite('blackbg')
	setProperty('blackbg.alpha', 0)

	setProperty('separatorHealth.color', getColorFromHex('000000'))
end

function onEvent(n,v1)
	if n == 'blackbg' then
		if v1 == 'start' then
			doTweenAlpha('xddlo5', 'blackbg', 1, crochet / (1000 / 4), 'cubeIn')
			doTweenAlpha('xddlo6', 'BlackGraphicHUD', 1, crochet / (1000 / 4), 'cubeIn')
		else
			setProperty('torre fea con bocas bien feas 2.alpha', 0.25)
			setProperty('roca 1.alpha', 0.25)
			setProperty('BlackGraphicHUD.alpha', 1)
			setProperty('blackbg.alpha', 0.95)
			doTweenAlpha('xddlo1', 'roca 1', 1, crochet / (1000 / 32), 'cubeIn')
			doTweenAlpha('xddlo2', 'torre fea con bocas bien feas 2', 1, crochet / (1000 / 32), 'cubeIn')
			doTweenAlpha('xddlo3', 'blackbg', 0, crochet / (1000 / 32), 'cubeIn')
			doTweenAlpha('xddlo4', 'BlackGraphicHUD', 0, crochet / (1000 / 32), 'cubeIn')
		end
	end
end