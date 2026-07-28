local camX, camY = 100, 350

function onUpdatePost()
	callMethod('camFollow.setPosition', {camX, camY})
	callMethod('camGame.snapToTarget')
end