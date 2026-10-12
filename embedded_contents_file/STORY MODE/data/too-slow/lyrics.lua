function onCreatePost()
	makeAnimatedLuaSprite('getcha', 'slow/dialogue')
	addAnimationByPrefix('getcha', 'idle', 'idle', 25, false)
	setObjectCamera('getcha', 'other')
	scaleObject('getcha', 5, 5)
	screenCenter('getcha')
	setProperty('getcha.antialiasing', false)
	addLuaSprite('getcha', true)
	setProperty('getcha.visible', false)

	makeAnimatedLuaSprite('godlol', 'slow/lyricgod', 0, screenHeight * (downscroll and 0.6 or 0.2))
	addAnimationByPrefix('godlol', 'i', 'i', 0, false)
	addAnimationByPrefix('godlol', 'am', 'am', 0, false)
	addAnimationByPrefix('godlol', 'god', 'god', 0, false)
	playAnim('godlol', 'god', true)
	setObjectCamera('godlol', 'other')
	scaleObject('godlol', 1, 1)
	screenCenter('godlol', 'x')
	addLuaSprite('godlol', true)
	setProperty('godlol.visible', false)
end

function onEvent(n,v1)
	if n == 'tooslowlyric' then
		if v1 == 'xd' then
			setProperty('getcha.visible', true)
			playAnim('getcha', 'idle', true)
		elseif v1 == 'i' then
			removeLuaSprite('getcha', true)
			setProperty('godlol.visible', true)
			playAnim('godlol', 'i', true)
		elseif v1 == 'am' then
			playAnim('godlol', 'am', true)
		elseif v1 == 'god' then
			playAnim('godlol', 'god', true)
		elseif v1 == 'endlyrics' then
			doTweenAlpha('godlol', 'godlol', 0, crochet / 250 / playbackRate)
		end
	end
end

function onTweenCompleted(t) if t == 'godlol' then removeLuaSprite('godlol', true) end end