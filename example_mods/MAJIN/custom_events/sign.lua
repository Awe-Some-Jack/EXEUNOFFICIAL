function onEvent(n,v1)
	if n == 'sign' then
		local trg = 'sign'..v1..math.floor(getSongPosition())
		makeLuaSprite(trg, 'mazin/'..v1..'Sign')
		setObjectCamera(trg, 'hud')
		scaleObject(trg, 0.75, 0.75, false)
		screenCenter(trg)
		setProperty(trg..'.angle', 10)
		setProperty(trg..'.y', screenHeight)
		doTweenY(trg, trg, (screenHeight - getProperty(trg..'.height')) / 2, crochet / (1000 / 2) / playbackRate, 'cubeOut')
		doTweenAngle(trg..'a', trg, 0, crochet / (1000 / 2) / playbackRate, 'cubeOut')
		doTweenX(trg..'x', trg..'.scale', 0.5, crochet / (1000 / 2) / playbackRate, 'cubeOut')
		doTweenY(trg..'y', trg..'.scale', 0.5, crochet / (1000 / 2) / playbackRate, 'cubeOut')
		addLuaSprite(trg, true)
	end
end
function onTweenCompleted(t)
	if stringStartsWith(t, 'sign') then
		doTweenY(t..'2', t, -getProperty(t..'.height'), crochet / (1000 / 2) / playbackRate, 'expoIn')
		doTweenAngle(t..'a2', t, -10, crochet / (1000 / 2) / playbackRate, 'expoIn')
		doTweenX(t..'x2', t..'.scale', 0.75, crochet / (1000 / 2) / playbackRate, 'expoIn')
		doTweenY(t..'y2', t..'.scale', 0.75, crochet / (1000 / 2) / playbackRate, 'expoIn')
	end
end