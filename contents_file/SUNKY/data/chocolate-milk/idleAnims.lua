function onBeatHit()
	if stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'dance') then
		playAnim('boyfriend', 'dance'..(curBeat % 2 == 0 and 'Left' or 'Right'), true)
	end
	if stringStartsWith(getProperty('dad.animation.curAnim.name'), 'dance') then
		playAnim('dad', 'dance'..(curBeat % 2 == 0 and 'Left' or 'Right'), true)
	end
	if stringStartsWith(getProperty('gf.animation.curAnim.name'), 'dance') then
		playAnim('gf', 'dance'..(curBeat % 2 == 0 and 'Left' or 'Right'), true)
	end
end