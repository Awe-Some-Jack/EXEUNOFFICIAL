runHaxeCode([[
	import flixel.math.FlxAngle;
	function setShaderFrameInfo(obj:String) {
		var char:FlxSprite;
		switch(obj) {
			case 'boyfriend':
				char = game.boyfriend;
			case 'dad':
				char = game.dad;
			case 'gf':
				char = game.gf;
		}

		char.animation.onFrameChange.add((name:String, frameNumber:Int, frameIndex:Int) ->
		{
			if (char.shader != null) {
				char.shader.setFloatArray('uFrameBounds', [char.frame.uv.x, char.frame.uv.y, char.frame.uv.width, char.frame.uv.height]);
				char.shader.setFloat('angOffset', char.frame.angle * FlxAngle.TO_RAD);
			}
		});
	}
]])

function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('cab', nil, 0.13)
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.13)

	if shadersEnabled and not lowQuality then
		for _,char in ipairs({'dad', 'gf', 'boyfriend'}) do
			setSpriteShader(char, 'DropShadowShader')
			setShaderFloat(char, 'hue', 0)
			setShaderFloat(char, 'saturation', 0)
			setShaderFloat(char, 'contrast', 0)
			setShaderFloat(char, 'str', 1)
			setShaderFloat(char, 'brightness', 0)
			setShaderBool(char, 'dontDoBlend', true)
			setShaderFloatArray(char, 'dropColor', {132 / 255, 84 / 255, 50 / 255})
			runHaxeFunction('setShaderFrameInfo', {char})
		end
		setShaderFloat('dad', 'ang', math.rad(80))
		setShaderFloat('gf', 'ang', math.rad(100))
		setShaderFloat('boyfriend', 'ang', math.rad(135))
		setShaderFloat('dad', 'dist', 10)
		setShaderFloat('gf', 'dist', 20)
		setShaderFloat('boyfriend', 'dist', 20)
		setShaderFloat('dad', 'thr', 0.1)
		setShaderFloat('gf', 'thr', 0.1)
		setShaderFloat('boyfriend', 'thr', 0.1)

		runHaxeCode([[
			game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader)];
			game.camHUD.filters = [new ShaderFilter(game.getLuaObject('bloom').shader)];
		]])
	end
end

local istwning = false
local thing = 0
function onUpdatePost(e)
	thing = thing + e * 3

	if shadersEnabled and not lowQuality then
		for _,char in ipairs({'dad', 'gf', 'boyfriend'}) do
			setShaderFloat(char, 'uSpriteAlpha', getProperty(char..'.alpha'))
			setShaderFloatArray(char, 'uSpriteColor', {(math.floor(getProperty(char..'.color') / 65536) % 256) / 255, (math.floor(getProperty(char..'.color') / 256) % 256) / 255, (getProperty(char..'.color') % 256) / 255})
		end
	end

	setShaderFloat('bloom', 'brightness', -0.06 + getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 0.94 + (getProperty('bloom.x') * 4))
	setShaderFloat('bloom', 'saturation', 0.94)

	if istwning then
		setShaderFloat('cab', 'amount', getProperty('cab.x'))
	end

	setShaderFloat('gf', 'ang', math.rad(lerp(100, 65, (getProperty('camGame.scroll.x') + 40) / 900)))
	setShaderFloat('boyfriend', 'ang', math.rad(lerp(160, 130, (getProperty('camGame.scroll.x') + 40) / 900)))
	setShaderFloat('dad', 'ang', math.rad(lerp(80, 40, (getProperty('camGame.scroll.x') + 40) / 900)))
end

function onEvent(n)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.2)
		doTweenX('bloom', 'bloom', 0, crochet / 250, 'cubeOut')
	end
	if n == 'transform' then
		istwning = true
		doTweenX('cab', 'cab', 4, 13 / playbackRate, 'cubeIn')
	end
end