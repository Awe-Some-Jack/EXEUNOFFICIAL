function onSectionHit()
	if getProperty('dad.animation.curAnim.name') == 'idle' and dadName == 'hellbemnt 2' then
		setProperty('dad.animation.curAnim.frameRate', math.floor(26 * (curBpm / bpm)))
		playAnim('dad', 'idle', true)
	end
end