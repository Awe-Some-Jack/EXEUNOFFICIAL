function onEvent(n,v1)
	if n == 'omwEvents' then
		if v1 == 'startintro' then
			setProperty('dad.alpha', 1) setProperty('omwhand.alpha', 1)
			playAnim('dad', 'intro', true)
			setProperty('dad.specialAnim', true)
			playAnim('omwhand', 'intro', true)
			setProperty('omwhand.specialAnim', true)
			doTweenAlpha('huddd', 'camHUD', 1, crochet / (1000 / 16))
		end
		if v1 == 'ending' then
			cancelTween('huddd')
			doTweenAlpha('huddd', 'camHUD', 0, crochet / 250)
			playAnim('dad', 'outro', true)
			setProperty('dad.specialAnim', true)
		end
	end
end

function onUpdatePost()
	if getProperty('dad.animation.curAnim.name') == 'outro' and getProperty('dad.animation.curAnim.finished') and not getProperty('dad.animation.paused') then
		playAnim('dad', 'outro-loop', true)
		setProperty('dad.specialAnim', true)
	end
end