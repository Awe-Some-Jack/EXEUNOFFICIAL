function onCreatePost()
	setProperty('camHUD.alpha', 0)
	setProperty('BlackGraphicOther.alpha', 1)
end

function onEvent(n,v1)
	if n == 'soullesEvents' then
		if v1 == 'shitcam' then
			doTweenZoom('dhdaffg9jg', 'camGame', 1.4, crochet / (1000 / 48) / playbackRate, 'cubeInOut')
			doTweenAlpha('dhjidhj', 'BlackGraphicOther', 0, crochet / (1000 / 28) / playbackRate, 'cubeInOut')
		end
		if v1 == 'hudappear' then
			doTweenAlpha('camhudappearlol', 'camHUD', 1, crochet / (1000 / 16) / playbackRate, 'cubeInOut')
		end
		if v1 == 'endinglol' then
   		    doTweenY("dsadasdsa", "camGame.targetOffset", -220, crochet / (1000 / 4) / playbackRate, 'cubeIn')
			doTweenZoom('dhdaffg9jg', 'camGame', 2.5, crochet / (1000 / 4) / playbackRate, 'cubeIn')
			doTweenAlpha('camHUD', 'camHUD', 0, crochet / (1000 / 3) / playbackRate, 'cubeInOut')
		end
		if v1 == 'blackout' then
			setProperty('BlackGraphicOther.alpha', 1)
			setProperty('camGame.alpha', 0)
			setProperty('camHUD.alpha', 0)
			setProperty('camOther.alpha', 0)
		end
	end
end