local mazinbg = {
	{name = "sky", animated = true, animPrefix = 'idle', x = -150, y = 0, scroll = 0.6, scale = 3.5, lowQualityHide = true},
	{name = "city", x = -100, y = 200, scroll = 0.8, scale = 1.2},
	{name = "ground", x = 50, y = 200, scale = 1.2},
	{name = "commercial", animated = true, animPrefix = 'commercial idle', x = 1030, y = 480, scaleX = 0.85, scaleY = 1.2, alpha = 0.001, lowQualityHide = true},
	{name = "bg-2", x = 50, y = 200, scale = 1.2, alpha = 0.001}
}

function onCreatePost()
	for _,m in ipairs(mazinbg) do
		if not (lowQuality and m.lowQualityHide) then
			if m.animated == true then
				makeAnimatedLuaSprite(m.name, 'mazin/'..m.name, m.x, m.y)
				addAnimationByPrefix(m.name, 'idle', m.animPrefix, 24, true)
			else
				makeLuaSprite(m.name, 'mazin/'..m.name, m.x, m.y)
			end
			setProperty(m.name..'.alpha', m.alpha or 1)
			scaleObject(m.name, m.scale or (m.scaleX or 1), m.scale or (m.scaleY or 1))
			setScrollFactor(m.name, m.scroll or 1, m.scroll or 1)
			addLuaSprite(m.name, m.front or false)
		end

		if m.name == 'sky' and lowQuality then
			removeLuaSprite(m.name, true)
			makeLuaSprite(m.name, 'mazin/'..m.name..'-lq', m.x, m.y)
			setProperty(m.name..'.alpha', m.alpha or 1)
			scaleObject(m.name, m.scale or (m.scaleX or 1), m.scale or (m.scaleY or 1))
			setScrollFactor(m.name, m.scroll or 1, m.scroll or 1)
			addLuaSprite(m.name, m.front or false)
		end

		if m.name == 'commercial' and lowQuality then
			removeLuaSprite(m.name, true)
			makeLuaSprite(m.name, 'mazin/'..m.name..'-lq', m.x, m.y)
			setProperty(m.name..'.alpha', m.alpha or 1)
			scaleObject(m.name, m.scale or (m.scaleX or 1), m.scale or (m.scaleY or 1))
			setScrollFactor(m.name, m.scroll or 1, m.scroll or 1)
			addLuaSprite(m.name, m.front or false)
		end
	end
end