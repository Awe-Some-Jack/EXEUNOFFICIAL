local firstTime = true

function onCreatePost()
	if seenCutscene then return end
end

function onStartCountdown()
	if seenCutscene then return end
	if firstTime then
		setProperty('camHUD.alpha', 0)

		callMethod('camGame.targetOffset.set', {260 - 500, 0})
		setProperty('camGame.zoom', 0.85)

		runTimer('startanim', 2)
		runTimer('cameratoog', 2)

		playAnim('dad', 'heylooping', true)
		setProperty('dad.specialAnim', true)

		

		firstTime = false
		return Function_Stop
	end

	return Function_Continue
end

local istweeening = false
function onUpdatePost()
	if seenCutscene then return end
	if getProperty('dad.animation.curAnim.finished') == true and getProperty('dad.animation.curAnim.name') == 'hey' then
		startCountdown()
		setProperty('bflooking.visible', false)
		setProperty('boyfriend.visible', true)
		doTweenAlpha('camdasdadsHUD', 'camHUD', 1, 1)

		playAnim('boyfriend', 'idle', true)
		playAnim('dad', 'idle', true)

		removeLuaSprite('bflooking', true)

		triggerEvent('Camera Follow Pos', '260', '100')
	end

	if istweeening then
		callMethod('camGame.snapToTarget')
	end
end

function onTimerCompleted(t)
	if t == 'startanim' then
		playAnim('dad', 'hey', true)
		setProperty('dad.specialAnim', true)
	end

	if t == 'cameratoog' then
		doTweenZoom('TweenZoomEvent', 'camGame', 0.55, 1.7, 'cubeInOut')
		doTweenX("coolCamX", "camGame.targetOffset", 0, 1.7, 'cubeInOut')
        doTweenY("coolCamY", "camGame.targetOffset", 0, 1.7, 'cubeInOut')
		istweeening = true
	end
end

function onTweenCompleted(t)
	if t =='TweenZoomEvent' then
		istweeening = false
	end
end