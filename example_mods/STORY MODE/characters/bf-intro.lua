function onBeatHit()
	if curBeat % 2 == 0 and getProperty('boyfriend.animation.curAnim.name') == 'idle' and boyfriendName == 'bf-intro' then
		playAnim('boyfriend', 'idle', true)
	end
end