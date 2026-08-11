local shadows = {
	{name = 'bfShadow',  path = 'bg/shadow',  target = 'boyfriend', offsetX = 410,   offsetY = 550, alpha = 0.7},
	{name = 'dadShadow', path = 'bg/shadow2', target = 'dad',       offsetX = 460,  offsetY = 468, alpha = 0},
}

local foundYouAssets = {
	['BG'] = {
		{name =   'bg', path =         'bg/bg', x = -270, y = -230},
		{name =  'bg2', path =        'bg/bg2', x =  535, y =  320},
		{name = 'door', path = 'bg/doorbangin', x = -110, y = -525, animName = 'doorbangin', animPrefix = 'doorbangin', fps = 24, loop = false},
		{name =   'pc', path =         'bg/tv', x = 1400, y =  400, animName =       'idle', animPrefix = 'Símbolo 12', fps = 24, loop = true},
		{name = 'glow', path =       'bg/glow', x =   50, y =    0, blend = 'add', alpha = 0.75, front = true},
	},
	['Chars'] = {
		{name = 'char1', path = 'bg/char1', x = 610, y = 320, behind = 'bg2'},
		{name = 'char2', path = 'bg/char2', x = 780, y = 320, behind = 'bg2'}
	}
}

local function createSprite(e)
	if e.animName then
		makeAnimatedLuaSprite(e.name, e.path, e.x, e.y)
		addAnimationByPrefix(e.name, e.animName, e.animPrefix, e.fps, e.loop)
		playAnim(e.name, e.animName, true)
	else
		makeLuaSprite(e.name, e.path, e.x, e.y)
	end
	if e.behind then setObjectOrder(e.name, getObjectOrder(e.behind)) end
	if e.blend  then setBlendMode(e.name, e.blend) end
	if e.alpha  then setProperty(e.name..'.alpha', e.alpha) end
	addLuaSprite(e.name, e.front and true or false)
end

function onCreatePost()

	for _, bg    in ipairs(foundYouAssets['BG'])    do createSprite(bg) end
	for _, chars in ipairs(foundYouAssets['Chars']) do createSprite(chars) end

	for _, s in ipairs(shadows) do
		makeLuaSprite(s.name, s.path)
		callMethod(s.name .. '.setPosition', {getProperty(s.target .. '.x') + s.offsetX, getProperty(s.target .. '.y') + s.offsetY})
		setProperty(s.name .. '.alpha', s.alpha)
		addLuaSprite(s.name)
	end

	setProperty('dad.alpha', 0)

	for i = 0, 3 do
		callMethod('opponentStrums.members['..i..'].setPosition', {-120, downscroll and 670 or -50})
		callMethod(  'playerStrums.members['..i..'].setPosition', {1420, downscroll and 670 or -50})
	end
	for _, hudStuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hudStuff..'.alpha', 0) end
end

local thing = 0
function onUpdatePost(e)
	thing = thing + e * playbackRate
	for i = 1,2 do
		setProperty('char'..i..'.y', 320 + math.sin(thing + i) * 8)
	end

	for _,t in ipairs({'dad', 'boyfriend'}) do if getProperty(t..'.animation.curAnim.name') == 'outro' and getProperty(t..'.animation.curAnim.finished') then setProperty(t..'.visible', false) end end
end

local hudRevealed = false

function onBeatHit()
	if not hudRevealed and curBeat >= 36 then
		hudRevealed = true
		doTweenAlpha('camHudFade', 'camHUD', 1, crochet / 250)
	end
end

local vignetteMode = ''

local foundYouEvents = {
	['fadeBG'] = function(alpha, time, setLayerGF)
		cancelTween('BlackGraphicBehindAlpha') cancelTween('glowAlpha')
		doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', alpha, time)
		doTweenAlpha('glowAlpha', 'glow', alpha ~= '0' and alpha - 0.4 or 0.75, time)
		if setLayerGF then
			setObjectOrder('BlackGraphicBehind', getObjectOrder('gfGroup'))
		else
			setObjectOrder('BlackGraphicBehind', getObjectOrder('dadGroup') - 1)
		end
	end,
	['showNotes'] = function(who)
		if who == 'cd' then
			for i = 0, 3 do startTween('cdStrum'..i..'Tween',   'opponentStrums.members['..i..']', {x = _G['defaultOpponentStrumX'..i], y = _G['defaultOpponentStrumY'..i]}, 1, {ease = 'circOut'}) end
		elseif who == 'us' then
			for i = 0, 3 do startTween('playerStrum'..i..'Tween', 'playerStrums.members['..i..']', {x = _G['defaultPlayerStrumX'..i],   y = _G['defaultPlayerStrumY'..i]},   1, {ease = 'circOut'}) end
		end
	end,
	['fadeHUD'] = function(alpha, time)
		cancelTween('HUDAlpha')
		doTweenAlpha('HUDAlpha', 'camHUD', alpha, time)
	end,
	['fadeGame'] = function()
		doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 1, 5)
		doTweenAlpha('glowAlpha', 'glow', 0, 5)
	end,
	['fadeHealth'] = function(alpha, time)
		for _, health in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do
			cancelTween('Health'..health..'Alpha')
			doTweenAlpha('Health'..health..'Alpha', health, alpha, time)
		end
	end,
	['activateVignette'] = function(use, mode, color)
		if use == 'true' then
			if not luaSpriteExists('vg') then
				makeLuaSprite('vg', 'VG')
				screenCenter('vg')
				setObjectCamera('vg', 'other')
				addLuaSprite('vg')
			end
			vignetteMode = mode
			debugPrint(vignetteMode)
			if color ~= nil then setProperty('vg.color', getColorFromHex(color)) end
		else
			vignetteMode = ''
			doTweenAlpha('vgVanish', 'vg', 0, 0.5)
		end
	end,
}

function onEvent(n, v1, v2)
	if n == 'foundYouEvents' then
		local split = stringSplit(v2, ', ')
		foundYouEvents[v1](split[1], split[2], split[3])
	end
	if n == 'animation' then
		if v1 == 'intro' then
			playAnim('door', 'doorbangin', true)
			setProperty('door.animation.curAnim.curFrame', 5)
		elseif v1 == 'end' then
			playAnim('boyfriend', 'outro', true) setProperty('boyfriend.specialAnim', true)
			playAnim('dad', 'outro', true) setProperty('dad.specialAnim', true)
		end

	elseif n == 'Play Animation' then
		doTweenAlpha('dadShadowFade', 'dadShadow', 0.7, 4)
	end
end

function onBeatHit()
	if vignetteMode == 'beatHighBump' then
		cancelTween('vgAlphaHighBump') setProperty('vg.alpha', 0.8)
		doTweenAlpha('vgAlphaHighBump', 'vg', 0, 0.4)
	elseif vignetteMode == 'beatLowBump' then
		cancelTween('vgAlphaLowBump') setProperty('vg.alpha', 0.4)
		doTweenAlpha('vgAlphaLowBump', 'vg', 0, 0.4)
	end
end