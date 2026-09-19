--[[function onBeatHit()
	if getProperty('boyfriend.animation.curAnim.name') == 'idle' and curBeat % 2 == 0 then
		playAnim('boyfriend', 'idle', true)
	end
end]]