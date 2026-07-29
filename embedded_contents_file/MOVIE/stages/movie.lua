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

local sprites = {
	{name = 'bg3', path = 'bg/3', x = -230, y = -300, scale = 1},
	{name = 'bg2', path = 'bg/2', x = -180, y = -150, scale = 1, front = true, scroll = 1.2},
	{name = 'bg1', path = 'bg/1', x = -230, y = -300, scale = 1, front = true},
}

local hs = {'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'iconBF', 'iconOpp', 'exeScoreTxt'}

local function addSprite(def)
	makeLuaSprite(def.name, def.path, def.x, def.y)
	scaleObject(def.name, def.scale or 1, def.scale or 1)
	setScrollFactor(def.name, def.scroll or 1, def.scroll or 1)
	setProperty(def.name .. '.antialiasing', not lowQuality)
	addLuaSprite(def.name, def.front or false)
end

local videoPlayed = false

function onCreate()
	for _, spr in ipairs(sprites) do
		addSprite(spr)
	end

	setProperty('boyfriend.idleSuffix', '-knux')
	callMethod('boyfriend.recalculateDanceIdle')
	if shadersEnabled and not lowQuality then
		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'saturation', 1)

		makeLuaSprite('ac')
		setSpriteShader('ac', 'colorAdjust')

		makeLuaSprite('wave')
		setSpriteShader('wave', 'wavyDistortion')

		for _,char in ipairs({'dad', 'boyfriend'}) do
			setProperty(char..'.useRenderTexture', true)
			setSpriteShader(char, 'DropShadowShader')
			setShaderFloat(char, 'hue', 0)
			setShaderFloat(char, 'saturation', 0)
			setShaderFloat(char, 'contrast', -35)
			setShaderFloat(char, 'str', 1)
			setShaderFloat(char, 'brightness', -62)
			setShaderFloat(char, 'dist', 15)
			setShaderFloatArray(char, 'dropColor', {255 / 255, 170 / 255, 43 / 255})
			runHaxeFunction('setShaderFrameInfo', {char})
		end
		setShaderFloat('dad', 'ang', math.rad(135))
		setShaderFloat('boyfriend', 'ang', math.rad(90))
		setShaderFloat('boyfriend', 'thr', 0.1)
		setShaderFloat('dad', 'thr', 0.1)

		runHaxeCode([[
			FlxG.camera.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('ac').shader), new ShaderFilter(game.getLuaObject('wave').shader)];
			game.camHUD.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('ac').shader), new ShaderFilter(game.getLuaObject('wave').shader)];
		]])
	end
end

local h = 0
function onUpdatePost(e)
	h = h + e * 2
	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))
	setShaderFloat('wave', 'amount', getProperty('wave.x'))
	setShaderFloat('wave', 'iTime', h)

	if _sex ~= true then for _, name in ipairs(hs) do setProperty(name .. '.alpha', 0) end end
end

function onSongStart()
	for _, name in ipairs(hs) do setProperty(name .. '.alpha', 1) end _sex = true
	doTweenAlpha('graphAlpha', 'BlackGraphicHUD', 0, crochet / (1000 / 32))
end

function onStartCountdown()
	if not videoPlayed and not seenCutscene then
		startVideo('SONIC FEO')
		videoPlayed = true
		return Function_Stop
	end
end

function onCountdownStarted()
	for i = 0, 7 do
		setProperty('strumLineNotes.members[' .. i .. '].x', _G['default' .. (i < 4 and 'Player' or 'Opponent') .. 'StrumX' .. (i % 4)])
	end
	triggerEvent('Flip Health Bar')
	setProperty('BlackGraphicHUD.alpha', 1)
end

function onEvent(n,v1,v2)
	if n == 'bright zoom' and flashingLights then
		local divide = v2 == '' and 4 or tonumber(v2)
		local amount = v1 == '' and 0.1 or tonumber(v1)
		cancelTween('bloom')
		setProperty('bloom.x', amount * 3)
		doTweenX('bloom', 'bloom', 0, crochet / (1000 / divide), 'cubeOut')
	end
	if n == 'saturation' then
		setShaderFloat('bloom', 'saturation', tonumber(v1))
	end
	if n == 'Dadbattle Spotlight' and v1 == 'xd' then
		setShaderFloat('ac', 'hue', -50)
		setShaderFloat('ac', 'saturation', 0)
		setShaderFloat('ac', 'brightness',-10)
		setShaderFloat('ac', 'contrast', -5)
	end
	if n == 'Dadbattle Spotlight' and v1 == 'aaa' then
		setShaderFloat('ac', 'hue', 0)
		setShaderFloat('ac', 'saturation', 0)
		setShaderFloat('ac', 'brightness', -20)
		setShaderFloat('ac', 'contrast', 20)
	end
	if n == 'Dadbattle Spotlight' and v1 == 'yaaa' then
		cancelTween('wavexd') setProperty('wave.x', 5) doTweenX('wavexd', 'wave', 0, crochet / (1000 / 6), 'expoOut')
		triggerEvent('bright zoom', '0.15', '6') triggerEvent('saturation', '1')
		setShaderFloat('ac', 'hue', 0)
		setShaderFloat('ac', 'saturation', 0)
		setShaderFloat('ac', 'brightness', 0)
		setShaderFloat('ac', 'contrast', 0)
	end
	if n == 'Dadbattle Spotlight' and v1 == 'ending' then
		doTweenZoom('cxasjd', 'camGame', 0.35, crochet / (1000 / 13), 'cubeIn')
		doTweenAlpha('BlackGraphicOther', 'BlackGraphicOther', 1, crochet / (1000 / 12))
	end
end

function goodNoteHitPre(id) setProperty('notes.members['..id..'].animSuffix', '-knux') end
function noteMiss(id,nt) playAnim('boyfriend', getProperty('singAnimations['..nt..']') .. 'miss-knux', true) end