addHaxeLibrary('FlxAngle', 'flixel.math')

runHaxeCode([[
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

        char.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
			if (char.shader != null) {
				char.shader.setFloatArray('uFrameBounds', [char.frame.uv.x, char.frame.uv.y, char.frame.uv.width, char.frame.uv.height]);
				char.shader.setFloat('angOffset', char.frame.angle * FlxAngle.TO_RAD);
			}
        }
	}
]])

function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('cab', nil, 0.06)
	setSpriteShader('cab', 'chromabber')
	setShaderFloat('cab', 'amount', 0.06)

	if shadersEnabled and not lowQuality then
		setProperty('dad.useRenderTexture', true)
		for _,char in ipairs({'dad', 'gf', 'boyfriend'}) do
			setSpriteShader(char, 'DropShadowShader')
			setShaderFloat(char, 'hue', 0)
			setShaderFloat(char, 'saturation', 0)
			setShaderFloat(char, 'contrast', 0)
			setShaderFloat(char, 'str', 1)
			setShaderFloat(char, 'brightness', 0)
			setShaderFloat(char, 'thr', 0.05)
			setShaderFloatArray(char, 'dropColor', {197 / 255, 112 / 255, 11 / 255})
			runHaxeFunction('setShaderFrameInfo', {char})
		end
		setShaderFloat('dad', 'ang', math.rad(80))
		setShaderFloat('gf', 'ang', math.rad(100))
		setShaderFloat('boyfriend', 'ang', math.rad(135))
		

		runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader)];")
	end
end

local defaultBright = 1

local istwning = false
local thing = 0
function onUpdatePost(e)
	thing = thing + e * 3

	setShaderFloat('bloom', 'brightness', 0.05 + (defaultBright - 1) + getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 0.15 + defaultBright + (getProperty('bloom.x') * 4))
	setShaderFloat('bloom', 'saturation', -0.1 + defaultBright)

	if istwning then
		setShaderFloat('cab', 'amount', getProperty('cab.x'))
	end
	
	defaultBright = 0.85 + 0.15 * ((songLength - getSongPosition()) / songLength)

	setShaderFloat('gf', 'ang', math.rad(lerp(100, 65, (getProperty('camGame.scroll.x') + 40) / 700)))
	setShaderFloat('boyfriend', 'ang', math.rad(lerp(160, 130, (getProperty('camGame.scroll.x') + 40) / 600)))
	setShaderFloat('dad', 'ang', math.rad(lerp(80, 40, (getProperty('camGame.scroll.x') + 40) / 600)))

	for _,char in ipairs({'dad', 'gf', 'boyfriend'}) do setShaderFloat(char, 'dist', 7 + 8 * ((songLength - getSongPosition()) / songLength)) end
end

function onEvent(n)
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.2)
		doTweenX('bloom', 'bloom', 0, crochet / 250, 'cubeOut')
	end
	if n == 'transform' then
		istwning = true
		doTweenX('cab', 'cab', 8, 13 / playbackRate, 'cubeIn')
	end
	if n == 'removeshader' then
		removeSpriteShader('dad')
	end
	if n == 'Change Character' then
		setSpriteShader('dad', 'DropShadowShader')
		runHaxeFunction('setShaderFrameInfo', {'dad'})
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end
