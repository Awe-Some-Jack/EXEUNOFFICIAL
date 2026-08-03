function onCreatePost()
	makeLuaSprite('rgbmierda')
	setSpriteShader('rgbmierda', 'Gay')

	makeLuaSprite('bruh')
	setSpriteShader('bruh', 'brightness')
	setShaderFloat('bruh', 'saturation', 1)

	makeLuaSprite('glasses', 'characters/glasses', getProperty('dad.x') + 295, getProperty('dad.y') + 105)
	scaleObject('glasses', 1.2, 1.2)
	setProperty('glasses.y', getProperty('glasses.y') - 1000)
	addLuaSprite('glasses', true)

	doSplash()
end
function onSongStart() if shadersEnabled and not lowQuality then runHaxeCode("game.camGame.filters = [new ShaderFilter(game.getLuaObject('bruh').shader)];") end end

local puta = 0
function onUpdatePost(e)
	puta = puta + e * 3
	setShaderFloat('rgbmierda', 'iTime', puta)

	setShaderFloat('bruh', 'brightness', getProperty('bruh.x'))
	setShaderFloat('bruh', 'contrast', 1 + (getProperty('bruh.x') * 3.12))
end

local inmierda = false
function onEvent(n, v1, v2)
	if n == 'mierdaactivador' then
		inmierda = not inmierda

		if not inmierda then
			doTweenY('glasses', 'glasses', getProperty('glasses.y') + 1000, 1)
		end

		if shadersEnabled and not lowQuality then 
			if inmierda then
				runHaxeCode([[
					game.camGame.filters = [new ShaderFilter(game.getLuaObject('rgbmierda').shader), new ShaderFilter(game.getLuaObject('bruh').shader)];
					game.camHUD.filters = [new ShaderFilter(game.getLuaObject('rgbmierda').shader)];
				]])
			else
				runHaxeCode([[
					game.camGame.filters = [new ShaderFilter(game.getLuaObject('bruh').shader)];
					game.camHUD.filters = [];
				]])
			end
		end
	end

	if n == 'bright zoom' and flashingLights then
		cancelTween('bruh')
		setProperty('bruh.x', 0.2)
		doTweenX('bruh', 'bruh', 0, crochet / 250, 'cubeOut')
	end

	if n == 'Change Character' then removeLuaSprite('glasses', true) end
end

function onSectionHit()
	if inmierda then
		for i = 0,7 do
			setProperty('strumLineNotes.members['..i..'].angle', 0)
			noteTweenAngle(i, i, 360, 1, 'cubeOut')
		end
	end
end

function goodNoteHit(id,nd,nt,isn)
	if not inmierda then return end
	if not isn and getProperty('notes.members['..id..'].noteSplashDisabled') == false then
		doSplash(nd, false)
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if not inmierda then return end
	if not isn and getProperty('notes.members['..id..'].noteSplashDisabled') == false then
		doSplash(nd, true)
	end
end

function doSplash(data, opponent)
	if data == nil then x, y = 0, 0
	else x, y = getProperty((opponent and 'opponentStrums' or 'playerStrums')..'.members['..data..'].x'), getProperty((opponent and 'opponentStrums' or 'playerStrums')..'.members['..data..'].y') end
	local tag = 'sanichit'..math.floor(getSongPosition())..data
	makeAnimatedLuaSprite(tag, 'hitmarker', x - 13, y - 13)
	addAnimationByPrefix(tag, 'splash', 'hit', 24, false)
	playAnim(tag, 'splash', true)
	playSound('hitmarker', 0.8)
	setObjectCamera(tag, 'hud')
	addToGroup('noteGroup', tag, getObjectOrder('strumLineNotes', 'noteGroup') + 1)
	runTimer(tag, 0.5 * playbackRate)
	if data == nil then setProperty(tag..'.alpha', 0.0001) end
end

function onTimerCompleted(tag)
	if tag:match('sanichit') then
		removeFromGroup('noteGroup', _, tag)
	end
end