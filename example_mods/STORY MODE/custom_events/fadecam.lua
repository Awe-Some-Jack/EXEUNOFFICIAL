function onCreatePost()
	makeLuaSprite('blackscreeen')
	makeGraphic('blackscreeen', 2500, 2500, '000000')
	screenCenter('blackscreeen')
	setProperty('blackscreeen.alpha', 0)
	addLuaSprite('blackscreeen', true)
end

function onEvent(n, v1, v2)
	if n == 'fadecam' then
		doTweenAlpha('dasdasd', 'camHUD', 0, crochet / (1000 / tonumber(v2)) / playbackRate)
		doTweenAlpha('dasdasdaasd', 'camOther', 0, crochet / (1000 / tonumber(v2)) / playbackRate)
		doTweenAlpha('blackscreeen', 'blackscreeen', 1, crochet / (1000 / tonumber(v2)) / playbackRate)
	end
end