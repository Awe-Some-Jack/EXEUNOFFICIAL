function onUpdatePost()
	if curBeat < 191 then
		playAnim('dad', getProperty('boyfriend.animation.curAnim.name'), true)
		setProperty('dad.animation.curAnim.curFrame', getProperty('boyfriend.animation.curAnim.curFrame'))
		setProperty('dad.holdTimer', 0)
	end
end