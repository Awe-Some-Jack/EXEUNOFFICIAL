function onCreatePost()
	if shadersEnabled then
		
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
						
		makeLuaSprite('targetBloom')
		
		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'saturation', 1)
		
		makeLuaSprite('cab', nil, 0.2)
		setSpriteShader('cab', 'chromabber')
		setShaderFloat('cab', 'amount', 0.2)
		
		makeLuaSprite('hws')
		setSpriteShader('hws', 'HeatwaveShader')
		setShaderSampler2D('hws', 'distortTexture', 'heatwave')
		
	end
	if shadersEnabled and not lowQuality then
		for _,char in ipairs({'dad', 'boyfriend'}) do
			setSpriteShader(char, 'DropShadowShader')
			setShaderFloat(char, 'hue', 0)
			setShaderFloat(char, 'saturation', 0)
			setShaderFloat(char, 'contrast', 0)
			setShaderFloat(char, 'str', 1)
			setShaderFloat(char, 'brightness', 0)
			setShaderFloatArray(char, 'dropColor', {150 / 255, 65 / 255, 22 / 255})
			runHaxeFunction('setShaderFrameInfo', {char})
		end
		setShaderFloat('dad', 'ang', math.rad(80))
		setShaderFloat('boyfriend', 'ang', math.rad(135))
		setShaderFloat('dad', 'dist', 15)
		setShaderFloat('boyfriend', 'dist', 15)
		setShaderFloat('dad', 'thr', 0.1)
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

	if shadersEnabled then
		
		
		setShaderFloat('hws', 'iTime', thing)
		setShaderFloat('hws', 'intensity', getProperty('hws.x'))
		
		setShaderFloat('bloom', 'brightness', -0.06 + (getProperty('targetBloom.x') / 2) + getProperty('bloom.x') * 2)
		setShaderFloat('bloom', 'contrast', 0.94 + math.abs(getProperty('targetBloom.x')) + (getProperty('bloom.x') * 4))
		setShaderFloat('bloom', 'saturation', 0.94)
		
		if istwning then
			setShaderFloat('cab', 'amount', getProperty('cab.x'))
		end
		
		setShaderFloat('boyfriend', 'ang', math.rad(lerp(180, 90, (getProperty('camGame.scroll.x') + 90) / 1350)))
		setShaderFloat('dad', 'ang', math.rad(lerp(90, 0, (getProperty('camGame.scroll.x') + 90) / 1350)))
	end
end

function onEvent(n, v1)
	if shadersEnabled then
		
		if n == 'bright zoom' and flashingLights then
			cancelTween('bloom')
			setProperty('bloom.x', 0.2)
			doTweenX('bloom', 'bloom', 0, crochet / 250, 'cubeOut')
		end
		
		if n == 'godEvents' then
			if v1 == 'fireappear' then
				if shadersEnabled then
					doTweenX('targetBloom', 'targetBloom', -0.05, 4)
					doTweenX('hws', 'hws', 0.015, 4)
					runHaxeCode([[
						game.camGame.filters = [new ShaderFilter(game.getLuaObject('hws').shader), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader)];
					]])
				end
			end
		end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end