local animationStarted = false

function onCreatePost()
	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'x', -1000)
		setPropertyFromGroup('playerStrums', i, 'y', (downscroll and (screenHeight + 500) or -500))
	end
end

function onStepHit()
	if curStep >= 60 and not animationStarted then
		animationStarted = true
		for i = 0, 3 do
			noteTweenY('noteMove'..i, i + 4, _G['defaultPlayerStrumY'..i], 1.5, 'cubeOut')
		end
	end
end