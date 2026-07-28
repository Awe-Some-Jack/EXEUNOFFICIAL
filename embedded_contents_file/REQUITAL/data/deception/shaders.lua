local tweening = false
function onCreate()
	makeLuaSprite('hws')
	setSpriteShader('hws', 'HeatwaveShader')
	setShaderSampler2D('hws', 'distortTexture', 'bg/heatwave')

	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.05)

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	if shadersEnabled and not lowQuality then runHaxeCode([[game.camGame.filters = [
			new ShaderFilter(game.getLuaObject('hws').shader),
			new ShaderFilter(game.getLuaObject('bloom').shader),
			new ShaderFilter(game.getLuaObject('cab').shader)
		];]])
	end
end

local thing = 0
function onUpdatePost(e)
	thing = thing + e
	setShaderFloat('hws', 'iTime', thing)

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2.6)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 5))
	setShaderFloat('cab', 'amount', 0.05 + (getProperty('bloom.x') * 4) + getProperty('cab.x'))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onEvent(n)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.2)
		doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
	end
	if n == 'Add Camera Zoom' then
		cancelTween('cab.x')
		setProperty('cab.x', 0.2)
		doTweenX('cab', 'cab', 0, crochet / 250 / playbackRate, 'cubeOut')
		setProperty('camHUD.zoom', 1)
	end
end

function onSectionHit()
	if getProperty('camZoomingMult') > 0 then
		cancelTween('cab.x')
		setProperty('cab.x', 0.2)
		doTweenX('cab', 'cab', 0, crochet / 250 / playbackRate, 'cubeOut')
		setProperty('camHUD.zoom', 1)
	end
end