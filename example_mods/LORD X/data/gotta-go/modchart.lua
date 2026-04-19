local separation = 50
local pauseEverything = false
local savedThings = {}

function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)
	setShaderFloat('bloom', 'brightness', 0.5)
	setShaderFloat('bloom', 'contrast', 2)

	makeLuaSprite('glih')
	setSpriteShader('glih', 'pseudo')
	setShaderFloat('glih', 'sort', 0.5)

	makeLuaSprite('illegal', 'gottago/illegalinstruction')
	setObjectCamera('illegal', 'other')
	setProperty('illegal.antialiasing', false)
	callMethod('illegal.setPosition', {getRandomFloat(0, screenWidth - getProperty('illegal.width')), getRandomFloat(0, screenHeight - getProperty('illegal.height'))})
	makeLuaSprite('illegalbox', nil, getProperty('illegal.x'), getProperty('illegal.y'))
	makeGraphic('illegalbox', getProperty('illegal.width'), getProperty('illegal.height'), '000000')
	setObjectCamera('illegalbox', 'other')
	addLuaSprite('illegalbox', true)
	addLuaSprite('illegal', true)
	setProperty('illegal.visible', false) setProperty('illegalbox.visible', false)
end

function onCountdownStarted()
	for i = 0,3 do
		setProperty('opponentStrums.members['..i..'].x', -1000)
		setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
	end
end

local pressednote = false
function goodNoteHit(id,nd,nt,isn)
	if isn or not pauseEverything then return end
	pressednote = true
end

function onEvent(n,v1)
	if n == 'gottaEvents' then
		if v1 == 'pauseshit' then
			pauseEverything = true
			savedThings = {getProperty('iconBF.scale.x'), getProperty('iconOpp.scale.x'), getProperty('exeScoreTxt.scale.x')}
			setProperty('camZoomingMult', 0)
			setProperty('cameraSpeed', 0)
			setProperty('bg.velocity.x', 0)

			setProperty('illegal.visible', true) setProperty('illegalbox.visible', true)
			if shadersEnabled then
				runHaxeCode([[
					game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('glih').shader)];
					game.camHUD.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('glih').shader)];
				]])
			end
		end
		if v1 == 'blackshit' then
			setProperty('camGame.visible', false)
			setProperty('camHUD.visible', false)
			setProperty('illegal.visible', false) setProperty('illegalbox.visible', false)
		end
		if v1 == 'resumeshit' then
			setProperty('camGame.visible', true)
			setProperty('camHUD.visible', true)

			pauseEverything = false
			setProperty('camZoomingMult', 1)
			setProperty('cameraSpeed', 1)
			setProperty('bg.velocity.x', -2500)

			setProperty('dad.animation.paused', false)
			for i = 0,7 do setProperty('strumLineNotes.members['..i..'].animation.paused', false) end
			for i = 0, getProperty('comboGroup.members.length') - 1 do if not pressednote then setProperty('comboGroup.members['..i..'].alpha', 0) end end

			if shadersEnabled then
				runHaxeCode([[
					game.camGame.filters = [];
					game.camHUD.filters = [];
				]])
			end
		end
	end
end

function onUpdatePost(e)
	if pauseEverything then
		scaleObject('iconBF', savedThings[1], savedThings[1], false)
		scaleObject('iconOpp', savedThings[2], savedThings[2], false)
		scaleObject('exeScoreTxt', savedThings[3], savedThings[3], false)

		for i = 0, getProperty('comboGroup.members.length') - 1 do
			scaleObject('comboGroup.members['..i..']', 0.6, 0.6, false)
			callMethodFromClass('flixel.tweens.FlxTween', 'cancelTweensOf', {instanceArg('comboGroup.members['..i..']')})
		end

		setProperty('dad.animation.paused', pauseEverything)
		for i = 0,7 do setProperty('strumLineNotes.members['..i..'].animation.paused', pauseEverything) end
	end
end

function getHealthColor(arg)
	return string.format("%02x%02x%02x", math.floor(getProperty(arg..'.healthColorArray[0]')), math.floor(getProperty(arg..'.healthColorArray[1]')), math.floor(getProperty(arg..'.healthColorArray[2]')))
end