local sunkyCrazy = false

function onEvent(n,v1,v2)
	if n == 'sunkyEvent' then
		if v1 == 'graphShit' then
			doTweenAlpha('blackPutaAlpha', 'blackPuta', v2 == 'true' and 0.7 or 0, v2 == 'true' and 2 or 0.2)
		end
		if v1 == 'crazy' then
			sunkyCrazy = true
			setProperty('dad.angularVelocity', 1800 * playbackRate)
		end
		if v1 == 'stopcrazy' then
			sunkyCrazy = false
			doTweenX('dadX', 'dad', -140, 0.1)
			doTweenY('dadY', 'dad', 260, 0.1)
			doTweenAngle('dadA', 'dad', 0, 0.1)
			setProperty('dad.angularVelocity', 0)
		end
		if v1 == 'ahh' then
			callMethod('ahh.play')
		end
		if v1 == 'bestday' then
			if getProperty('ahh') == nil then return end
			callMethod('ahh.destroy')
    		callMethod('remove', {instanceArg('ahh')})

			callMethod('bestday.play')
		end
		if v1 == 'fadeday' then doTweenAlpha('sdasdfas', 'bestday', 0, crochet / 500) end
		if v1 == 'destroyday' then --NOOO its not longer the best day
			cancelTween('sdasdfas') 

			if getProperty('bestday') == nil then return end
			callMethod('bestday.destroy')
    		callMethod('remove', {instanceArg('bestday')})
		end
		if v1 == 'gato' then doTweenAlpha('gato', 'gato', 1, crochet / 1000) end
		if v1 == 'disk' then
			removeLuaSprite('gato', true)
			doTweenAlpha('disk', 'disk', 1, 1)
		end
		if v1 == 'diskbye' then
			cancelTween('disk')
			doTweenAlpha('disk', 'disk', 0, 1)
		end
		if v1 == 'diskdestroy' then
			cancelTween('disk')
			removeLuaSprite('disk', true)
		end
		if v1 == 'sans' then
			cancelTimer('sansxd')
			setProperty('sans.alpha', 1)
			runTimer('sansxd', crochet / 1000)

			setProperty('bg2.alpha', 1)
			setProperty('tvbg.color', getColorFromHex('FFFFFF'))
			if shadersEnabled and not lowQuality then runHaxeCode([[game.camGame.filters = [new ShaderFilter(game.getLuaObject('blackwhite').shader)];]]) end
		end
		if v1 == 'majin' then
			doTweenAlpha('majin', 'majin', 1, 1)

			cancelTimer('sansxd')
			removeLuaSprite('bg2', true)
			removeLuaSprite('blackwhite', true)
			removeLuaSprite('sans', true)
			setProperty('tvbg.color', getColorFromHex('000000'))
			if shadersEnabled and not lowQuality then runHaxeCode([[game.camGame.filters = [];]]) end
		end
		if v1 == 'byemajin' then doTweenAlpha('majin', 'majin', 0, 1) end
		if v1 == 'destroymajin' then removeLuaSprite('majin', true) end
		if v1 == 'zoomtotv' then
			startTween('tween_zoomIn1', 'camGame', {zoom = 30}, crochet / 500, {ease = 'expoIn'})
			startTween('tween_zoomIn2', 'camHUD', {zoom = 30}, crochet / 500, {ease = 'expoIn'})
			setProperty('camZoomingDecay', 0)
		end
		if v1 == 'arin' then
			callMethod('arin.play')
			setProperty('arin.alpha', 0)
			doTweenAlpha('arin', 'arin', 0.35, 3)
		end
		if v1 == 'arinbye' then
			doTweenAlpha('arin', 'arin', 0, 3)
		end
	end
end

function onTimerCompleted(t)
	if t == 'sansxd' then
		setProperty('sans.alpha', 0)
		setProperty('bg2.alpha', 0)
		setProperty('tvbg.color', getColorFromHex('000000'))
		if shadersEnabled and not lowQuality then runHaxeCode([[game.camGame.filters = [];]]) end
	end
end

function onTweenCompleted(t) if t == 'gato' then doTweenAlpha('gato2', 'gato', 0, crochet / 1000) end end

local sunkSine = 0
function onUpdatePost(e)
	if sunkyCrazy then
		sunkSine = sunkSine + e * 30 * playbackRate
		callMethod('dad.setPosition', {
			lerp(getProperty('dad.x'), -140 + (math.cos(sunkSine) * 300), e * 20 * playbackRate),
			lerp(getProperty('dad.y'), 260 - 500 + (math.sin(sunkSine * 2) * 150), e * 20 * playbackRate),
		})
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end