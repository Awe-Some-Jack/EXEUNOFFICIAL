function onCreatePost()
	createInstance('sarah', 'objects.Character', {getProperty('dad.x'), getProperty('dad.y'), 'sarah'})
	setObjectOrder('sarah', getObjectOrder('dadGroup') - 1)
	addInstance('sarah')
	setProperty('sarah.alpha', 0)
end

local sarahAppear = false
local sarahSine = 0
function onUpdatePost(e)
	playAnim('sarah', getProperty('dad.animation.curAnim.name'), true)
	setProperty('sarah.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))

	if sarahAppear then
		sarahSine = sarahSine + (e / 2)
		setProperty('sarah.alpha', (((math.sin(sarahSine) / 2) + 0.75) / 2) + 0.25)
	end
end

function onEvent(n,v1)
	if n == 'sarahevent' then
		if v1 == 'sarahappears' then
			doTweenAlpha('sarah', 'sarah', 0.5, crochet / 250, 'cubeOut')
		end
	end
end

function onTweenCompleted(t) if t == 'sarah' then sarahAppear = true end end