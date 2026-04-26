local faker = {
	{name = 'sky', path = 'sky', x = -900, y = -800, scroll = 0.2, scale = 1.5},
	{name = 'sun', path = 'sun', x = -1050, y = -450, scroll = 0.2},
	{name = 'sunshine', path = 'sunshine', x = -1050, y = -450, scroll = 0.2, lowQualityHide = true},
	{name = 'moon', path = 'moon', x = -1008, y = -450, scroll = 0.2},
	{name = 'cloudsloop', path = 'cloudsloop', x = 0, y = -900, scroll = 0.2, backdrop = true, velocityX = -30, alpha = 0.3, lowQualityHide = true},
	{name = 'back-spikes', path = 'back-spikes', x = -900, y = -750, scroll = 0.4},
	{name = 'front-spikes', path = 'front-spikes', x = -800, y = -250, scroll = 0.6, lowQualityHide = true},
	{name = 'totems', path = 'totems', x = -700, y = -900, scroll = 0.9},
	{name = 'ground', path = 'ground', x = -1850, y = -750, scroll = 1},
	{name = 'rocks', path = 'rocks', x = -800, y = 500, scroll = 1.2, front = true, lowQualityHide = true},
	{name = 'glow', path = 'glow', x = -900, y = -200, scroll = 1, scaleX = 2.8, scaleY = 1.3, front = true, color = 'A81000', blend = 'add', alpha = 0.2, lowQualityHide = true}
}

function onCreatePost()
	for _,f in ipairs(faker) do
		if not (lowQuality and f.lowQualityHide) then
			if f.alpha == nil then f.alpha = 1 end
			if f.front == nil then f.front = false end
			if f.scale == nil then f.scale = 1.2 end
			if f.backdrop == true then
				createInstance(f.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
				loadGraphic(f.name, 'faker/'..f.path)
				callMethod(f.name..'.setPosition', {f.x, f.y})
			else makeLuaSprite(f.name, 'faker/'..f.path, f.x, f.y) end
			setScrollFactor(f.name, f.scroll, f.scroll)
			scaleObject(f.name, ((f.scaleX == nil) and f.scale or f.scaleX), ((f.scaleY == nil) and f.scale or f.scaleY))
			setProperty(f.name..'.alpha', f.alpha)
			if f.color ~= nil then setProperty(f.name..'.color', getColorFromHex(f.color)) end
			if f.blend ~= nil then setBlendMode(f.name, f.blend) end
			if f.backdrop == true then
				addInstance(f.name, f.front)
				setProperty(f.name..'.velocity.x', f.velocityX)
			else addLuaSprite(f.name, f.front) end
		end

		if lowQuality then setProperty(f.name..'.antialiasing', false) end
	end

	makeLuaSprite('blackbgxd',nil, -1000, -600)
	makeGraphic('blackbgxd', 3500, 1500, '000000')
	addLuaSprite('blackbgxd')
	setProperty('blackbgxd.alpha', 0)

	makeLuaSprite('healthBGFaker', 'faker/hud_faker', getProperty('healthBar.x') - 190, getProperty('healthBar.y') - 80)
	setObjectCamera('healthBGFaker', 'camHUD')
	setObjectOrder('healthBGFaker', getObjectOrder('exeScoreTxt'))
	scaleObject('healthBGFaker', 0.32, 0.3)
	addLuaSprite('healthBGFaker', false)
end

function onUpdatePost(e)
	setProperty('moon.x', math.min(lerp(-1300, -1008, getSongPosition() / ((109.71 * 1000))), -1008))
	setProperty('moon.y', lerp(-300, -450, math.sin(math.min(getSongPosition() / ((109.71 * 1000)), 1) * math.pi * 0.5)))

	setProperty('sunshine.alpha', math.min(lerp(0.5, 1, getSongPosition() / ((109.71 * 1000))), 1))
	scaleObject('sunshine', math.min(lerp(1.2, 2, getSongPosition() / ((109.71 * 1000))), 2), math.min(lerp(1.2, 2, getSongPosition() / ((109.71 * 1000))), 2), false)
	setProperty('sunshine.y', math.min(lerp(-450, -65, getSongPosition() / ((109.71 * 1000))), -65))
end

function onEvent(n)
	if n == 'blackdbg' then
		doTweenAlpha('blackbgxd', 'blackbgxd', (getProperty('blackbgxd.alpha') ~= 0 and 0 or 0.5), 0.6)
		doTweenAlpha('rocks', 'rocks', (getProperty('rocks.alpha') ~= 1 and 1 or 0.5), 0.6)
		doTweenAlpha('glow', 'glow', (getProperty('glow.alpha') ~= 0.2 and 0.2 or 0.06), 0.6)
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end