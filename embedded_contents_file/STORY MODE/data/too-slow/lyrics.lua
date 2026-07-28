function onCreatePost()
	makeAnimatedLuaSprite('getcha', 'slow/imgonnagetcha')
	addAnimationByPrefix('getcha', 'im', 'im-intro', 12, false)
	addAnimationByPrefix('getcha', 'im-loop', 'im-loop', 12, true)
	addAnimationByPrefix('getcha', 'gonna', 'gonna-intro', 12, false)
	addAnimationByPrefix('getcha', 'gonna-loop', 'gonna-loop', 12, true)
	addAnimationByPrefix('getcha', 'getcha', 'getcha-intro', 12, false)
	addAnimationByPrefix('getcha', 'getcha-loop', 'getcha-loop', 12, true)
	addAnimationByPrefix('getcha', 'end-loop', 'ending', 12, false)
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

function onUpdatePost()
	if getProperty('getcha.animation.curAnim.finished') and not stringEndsWith(getProperty('getcha.animation.curAnim.name'), 'loop') then
		playAnim('getcha', getProperty('getcha.animation.curAnim.name')..'-loop', true)
	end
end

function onEvent(n,v1)
	if n == 'tooslowlyric' then
		if v1 == 'im' then
			setProperty('getcha.visible', true)
			playAnim('getcha', 'im', true)
		elseif v1 == 'gonna' then
			playAnim('getcha', 'gonna', true)
		elseif v1 == 'getcha' then
			playAnim('getcha', 'getcha', true)
		elseif v1 == 'end' then
			playAnim('getcha', 'end-loop', true)
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