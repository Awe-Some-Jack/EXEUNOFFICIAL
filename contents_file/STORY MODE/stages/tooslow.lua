-- TABLES (CONTAINS SPRITES PROPERTIES) --
local sprites = {
	{name = 'fondo',      path = 'slow/fondo',       x = -950, y = -400, scale = 1.4, alpha = 1,},
	{name = 'bg3',        path = 'slow/bg3',         x = -950, y = -150, scale = 1.4, alpha = 1,},
	{name = 'montains',   path = 'slow/montains',    x = -820, y = -95,  scale = 1.4, scaleY = 1.39, animated = true, prefix = 'rio', fps = 12, alpha = 1, lqPause = true},
	{name = 'bg2',        path = 'slow/bg2',         x = -950, y = -700, scale = 1.4, alpha = 1,},
	{name = 'bg1',        path = 'slow/bg1',         x = -950, y = -700, scale = 1.4, alpha = 1,},
	{name = 'b1_front',   path = 'slow/b1 front',    x = -950, y = -700, scale = 1.4, alpha = 1, front = true},
	{name = 'ojos_tails', path = 'slow/ojos_tails',  x = 350,  y = 1000, scale = 1.5, animated = true, prefix = 'Símbolo 10 instancia', fps = 24, alpha = 1, front = true},
	{name = 'eggman',     path = 'slow/eggman',      x = 1800, y = 1500, scale = 1.4, alpha = 1, front = true},
}

local flashBackBG = {
	{name = 'static', path = 'slow/flashback/daSTAT', x = -950, y =  200, animated =  true, animName = 'idle', animPrefix = 'staticFLASH', fps = 24, loop = true, scaleX = 12, scaleY = 6, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false, lowQualityHide = false},
	{name = 'mount',  path =    'slow/flashback/idk', x = -950, y = -300, animated = false, scaleX = 0.5, scaleY = 0.5, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false, lowQualityHide = false},
	{name = 'plant',  path = 'slow/flashback/plants', x = -950, y = -100, animated = false, scaleX = 0.5, scaleY = 0.5, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false, lowQualityHide = false},
	{name = 'floor',  path = 'slow/flashback/ground', x = -950, y = -100, animated = false, scaleX = 0.5, scaleY = 0.5, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false, lowQualityHide = false},
}

local spritesLowQuality = {
	{name =  'fondoLQ', path = 'potatomode/slow/1', x = -850, y = -500, scale = 2.8, alpha = 1, front = false},
	{name = 'fondoLQ2', path = 'potatomode/slow/2', x = -850, y =  800, scale = 2.8, alpha = 1, front =  true},
}

-- FUNCTION TO ADD THE SPRITES --
local function addSprite(def)
	if def.animated then
		makeAnimatedLuaSprite(def.name, def.path, def.x, def.y)
		addAnimationByPrefix(def.name, 'idle', def.prefix, def.fps, true)
	else
		makeLuaSprite(def.name, def.path, def.x, def.y)
	end
	local sx = def.scaleX or def.scale or 1
	local sy = def.scaleY or def.scale or 1
	scaleObject(def.name, sx, sy)
	if lowQuality then setProperty(def.name..'.antialiasing', false) end
	setProperty(def.name..'.alpha', def.alpha)
	addLuaSprite(def.name, def.front)
end

-- USE THE FUNCTION HERE --
function onCreate()
	if not lowQuality then for _, chad in ipairs({'wavyDistortion', 'blackwhite'}) do initLuaShader(chad) end end
	if not lowQuality then
		for _, spr in ipairs(sprites) do addSprite(spr) end
	else
		for _, spr in ipairs(spritesLowQuality) do addSprite(spr) end
		for _, fl in ipairs(flashBackBG) do	addSprite(fl) end
	end
	setScrollFactor('gfGroup', 1, 1)
end

function onCreatePost() if lowQuality then triggerEvent("Change Character",'gf', 'gfLQ') triggerEvent("Change Character", 'dad', 'sonic.exeLQ') end end

-- STAGE EVENTS --
luaDebugMode = true
local startWave = false
local tweenBack = false
local tweenStart = false
function onEvent(e, v1, v2)
    if e == 'tooSlowEvents' then
        if v1 == 'flashBack' then
			if not lowQuality then
				if v2 == '' then
					for _, yes in ipairs(flashBackBG) do
						doTweenAlpha(yes.name..'Alpha', yes.name, 1, 2)
					end

					for _, yes in ipairs(sprites) do
						doTweenAlpha(yes.name..'Alpha', yes.name, 0, 2)
					end

					if shadersEnabled and not lowQuality then
						makeLuaSprite('wave', nil, 0)
					makeLuaSprite('bw', nil, 0)
					setSpriteShader('wave', 'wavyDistortion')
					setSpriteShader('bw', 'blackwhite')

					setShaderFloat('wave', 'amount', getProperty('wave.x'))
					setShaderFloat('bw', 'grayness', getProperty('bw.x'))
					if shadersEnabled then runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('wave').shader), new ShaderFilter(game.getLuaObject('bw').shader)]; return;") end

					for _, shit in ipairs({'wave', 'bw'}) do
						doTweenX(shit..'TweenStart', shit, 0.5, 2)
					end
					startWave = true
					tweenStart = true
				end
			elseif v2 == 'fade' then
				if shadersEnabled then
					tweenBack = true
					for _, shit in ipairs({'wave', 'bw'}) do
						doTweenX(shit..'Tween', shit, 0, 4)
					end
					for _, yes in ipairs(flashBackBG) do
						doTweenAlpha(yes.name..'Alpha', yes.name, 0, 4)
					end
					for _, yes in ipairs(sprites) do
						doTweenAlpha(yes.name..'Alpha', yes.name, 1, 4)
					end
				end
            end
        end
    end
end end

local yes = 0
function onUpdatePost(elapsed)
	yes = yes + elapsed / playbackRate
	if shadersEnabled and not lowQuality then
		if startWave then
			setShaderFloat('wave', 'iTime', yes)
		end
		if tweenBack then
			setShaderFloat('wave', 'amount', getProperty('wave.x'))
			setShaderFloat('bw', 'grayness', getProperty('bw.x'))
		end
		if tweenStart then
			setShaderFloat('wave', 'amount', getProperty('wave.x'))
			setShaderFloat('bw', 'grayness', getProperty('bw.x'))
		end
	end
end

function onTweenCompleted(tag)
	if shadersEnabled and not lowQuality then
		if tag == 'waveTween' then
			startWave = false
			tweenBack = false
			runHaxeCode("game.camGame.filters = [];")
		end
		if tag == 'waveTweenStart' then
			tweenStart = false
		end
	end
end