local firstTime = true

function onCreatePost()
	if seenCutscene then return end
	playAnim('boyfriend', 'ttintro', true)
	setProperty('boyfriend.animation.paused', true)
	setProperty('boyfriend.specialAnim', true)
end

function onStartCountdown()
	if seenCutscene then return end
	if firstTime then
		setProperty('camHUD.alpha', 0)

		callMethod('camGame.targetOffset.set', {890 - 300, 100})
		setProperty('camGame.zoom', 1)

		runTimer('startanim', 2)
		runTimer('cameratoog', 2)

		firstTime = false
		return Function_Stop
	end

	return Function_Continue
end

local istweeening = false
function onUpdatePost()
	if seenCutscene then return end
	if getProperty('boyfriend.animation.curAnim.finished') == true and getProperty('boyfriend.animation.curAnim.name') == 'ttintro' then
		startCountdown()
		doTweenAlpha('camdasdadsHUD', 'camHUD', 1, 1)

		playAnim('boyfriend', 'idle', true)
		playAnim('dad', 'idle', true)

		triggerEvent('Camera Follow Pos', '890', '900')
	end

	if istweeening then
		callMethod('camGame.snapToTarget')
	end
end

function onTimerCompleted(t)
	if t == 'startanim' then
		playAnim('boyfriend', 'ttintro', true)
	end

	if t == 'cameratoog' then
		doTweenZoom('TweenZoomEvent', 'camGame', 0.6, 1.7, 'cubeInOut')
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