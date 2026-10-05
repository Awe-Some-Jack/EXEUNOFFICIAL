local lerpFloorY = 420
function onCreatePost() makeLuaSprite('camPos', nil, 100, 350) end

function onUpdatePost(e)
	lerpFloorY = lerp(lerpFloorY, getVar('floorY'), e * 5)
	callMethod('camFollow.setPosition', {getProperty('camPos.x'), getProperty('camPos.y') + (lerpFloorY - 420)})
	callMethod('camGame.snapToTarget')
end

function onEvent(n,v1)
	if n == 'preyEvent' and songPath == 'prey' then
		if v1 == 'laughzoom' then
			setProperty('camZoomingMult', 0)
			setProperty('camGame.zoom', 0.5)
			doTweenZoom('camgame', 'game', 1, crochet / (1000 / 26), 'cubeInOut')
			setProperty('defaultCamZoom', 1)
			startTween('cammovement', 'camPos', {x = 600, y = 50}, crochet / (1000 / 26), {ease = 'cubeInOut'})
		end
		if v1 == 'backtostarved' then
			setProperty('camZoomingMult', 1)
			doTweenZoom('camgame', 'game', 0.5, crochet / (1000 / 6), 'cubeInOut')
			setProperty('defaultCamZoom', 0.5)
			startTween('cammovement', 'camPos', {x = 100, y = 350}, crochet / (1000 / 6), {ease = 'cubeInOut'})
		end
		if v1 == 'cinematic' then
			startTween('cammovement', 'camPos', {x = 300, y = 250}, crochet / (1000 / 3), {ease = 'cubeOut'})
			setProperty('defaultCamZoom', 0.6)

			doTweenY('topBar', 'topbar', -50, crochet / (1000 / 4), 'cubeOut')
			doTweenY('bottomBar', 'botbar', screenHeight - 100, crochet / (1000 / 4), 'cubeOut')
		end
		if v1 == 'cinematic2' then
			startTween('cammovement', 'camPos', {x = 100, y = 350}, crochet / (1000 / 3), {ease = 'cubeOut'})
			setProperty('defaultCamZoom', 0.5)
			
			doTweenY('topBar', 'topbar', -(100 + 50), crochet / (1000 / 4), 'cubeOut')
			doTweenY('bottomBar', 'botbar', screenHeight, crochet / (1000 / 4), 'cubeOut')
		end
		if v1 == 'furnaceappearing' then
			doTweenY('cammovement', 'camPos', 500, crochet / (1000 / 16), 'cubeInOut')
		end
		if v1 == 'backtocam' then
			doTweenY('cammovement', 'camPos', 350, crochet / (1000 / 16), 'cubeInOut')
		end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end