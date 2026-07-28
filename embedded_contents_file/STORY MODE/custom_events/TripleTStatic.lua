function onCreate()
	makeAnimatedLuaSprite('staticttx', 'tt/Phase3Static')
	addAnimationByPrefix('staticttx', 'static', 'Phase3Static instance 1', 24, false)
	playAnim('staticttx', 'static', true)
	scaleObject('staticttx', 4, 4)
	setObjectCamera('staticttx', 'hud')
	setProperty('staticttx.alpha', 0.6)
	addLuaSprite('staticttx')
	setProperty('staticttx.visible', false)
end

function onEvent(n)
	if n == 'TripleTStatic' and flashingLights then
		setProperty('staticttx.animation.curAnim.frameRate', math.floor(24 * (curBpm / bpm)))
		playAnim('staticttx', 'static', true)
		setProperty('staticttx.visible', true)
	end
end

function onUpdatePost()
	if getProperty('staticttx.visible') == true and getProperty('staticttx.animation.curAnim.finished') then
		setProperty('staticttx.visible', false)
	end
end