local offsetX = 668
function onUpdatePost(e)
	if boyfriendName == 'bf-fegrand' then
		callMethod('boyfriend.setPosition', {getProperty('dad.x') + offsetX, getProperty('dad.y') + 5})
		setProperty('boyfriend.danceEveryNumBeats', 4)
		setProperty('dad.danceEveryNumBeats', 4)
		if stringEndsWith(getProperty('boyfriend.animation.curAnim.name'), '-alt') then
			setProperty('boyfriend.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))
		end
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if getProperty('boyfriend.animation.curAnim.name') == 'idle' or stringEndsWith(getProperty('boyfriend.animation.curAnim.name'), '-alt') then
		playAnim('boyfriend', getProperty('singAnimations['..nd..']')..'-alt', true)
		setProperty('boyfriend.holdTimer', 0)
	end
end

function onEvent(n,v1,v2)
	if n == 'Change Character' and v1 == 'bf' and v2 == 'bf-water' then
		setProperty('boyfriend.alpha', 0)
	end
	if n == 'finalescapeEvent' then
		if v1 == 'laputamadre1' then offsetX = 608 end
		if v1 == 'laputamadre' then offsetX = 668 end
	end
end