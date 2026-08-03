function onBeatHit()
	if curBeat % 2 == 0 and getProperty('dad.animation.curAnim.name') == 'idle' and dadName == 'bratwurst' then
		setProperty('dad.animation.curAnim.frameRate', math.floor(22 * (curBpm / bpm)))
		playAnim('dad', 'idle', true)
	end
end