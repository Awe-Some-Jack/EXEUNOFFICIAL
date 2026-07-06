function onBeatHit()
	if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
		playAnim('boyfriend', 'idle', true)
	end
end