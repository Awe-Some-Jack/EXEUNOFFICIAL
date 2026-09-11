local offsetX, offsetY = -160, 110
local offsetBFX, offsetBFY = 160, 18
local camZoomOffset = 0

function onCreatePost()
	createInstance('camLeft', 'flixel.FlxCamera', {})
	setVar('camLeft', instanceArg('camLeft'))
	setProperty('camLeft.width', screenWidth / 2)

	createInstance('camRight', 'flixel.FlxCamera', {})
	setVar('camRight', instanceArg('camRight'))
	setProperty('camRight.width', screenWidth / 2)
	setProperty('camRight.x', screenWidth / 2)

	callMethodFromClass('flixel.FlxG', 'cameras.remove', {instanceArg('camHUD'), false})
	callMethodFromClass('flixel.FlxG', 'cameras.remove', {instanceArg('camOther'), false})
	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camLeft')})
	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camRight')})
	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camHUD'), false})
	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camOther'), false})

	createInstance('camFollowYour', 'flixel.FlxObject')
	callMethod('camLeft.follow', {instanceArg('camFollowYour')})
	setProperty('camLeft.alpha', 0)

	createInstance('camFollowBF', 'flixel.FlxObject')
	callMethod('camRight.follow', {instanceArg('camFollowBF')})
	setProperty('camRight.alpha', 0)

	makeLuaSprite('zoomoffset')
	runHaxeCode([[
		getVar("camLeft").filters = game.camGame.filters;
		getVar("camRight").filters = game.camGame.filters;
	]])
end

local XD = false
local camLeftEnabled = true
local followX = true
function onUpdate()
	if camLeftEnabled then
		camZoomOffset = getProperty('zoomoffset.x')
		setProperty('camLeft.zoom',  getProperty('camGame.zoom') + camZoomOffset)
		setProperty('camRight.zoom', getProperty('camGame.zoom'))

		--callMethod('camFollowYour.setPosition', {getCharacterCameraPos('dad').x + offsetX, getCharacterCameraPos('dad').y + offsetY})
		if followX then
			callMethod('camFollowYour.setPosition', {(getProperty('camGame.scroll.x') * -1) + 1350 + (getCharacterCameraPos('dad').x + offsetX), getProperty('camGame.scroll.y') - 790 + (getCharacterCameraPos('dad').y + offsetY)})
			callMethod('camFollowYour.snapToTarget')

			callMethod('camFollowBF.setPosition', {(getProperty('camGame.scroll.x') * -1) + 1350 + (getCharacterCameraPos('boyfriend').x + offsetBFX), getProperty('camGame.scroll.y') - 790 + (getCharacterCameraPos('boyfriend').y + offsetBFY)})
			callMethod('camFollowBF.snapToTarget')
		else
			callMethod('camFollowYour.setPosition', {getCharacterCameraPos('dad').x + offsetX, getCharacterCameraPos('dad').y + offsetY})
			callMethod('camFollowYour.snapToTarget')

			callMethod('camFollowBF.setPosition', {getCharacterCameraPos('boyfriend').x + offsetBFX, getCharacterCameraPos('boyfriend').y + offsetBFY})
			callMethod('camFollowBF.snapToTarget')
		end
	end
end

function onEvent(n,v1,v2)
	if n == 'Yourself SplitScreen' then
		if v1 == 'desactivatefirst' then
			doTweenX('fuckyuh', 'zoomoffset', 0.3, crochet / (1000 / 16) / playbackRate, 'cubeIn')
		end
		if v1 == 'yourselfmirror' then
			startTween('LMAO', 'camLeft', {width = screenWidth}, crochet / (1000 / 8), {ease = 'cubeOut'})
			startTween('LMAOFollow', 'camFollowYour', {x = getProperty('camFollowYour.x') + 50, y = getProperty('camFollowYour.x') - 50}, crochet / (1000 / 8), {ease = 'cubeOut'})
			doTweenX('fuckyuh', 'zoomoffset', 0, crochet / (1000 / 10) / playbackRate, 'smoothStepInOut')
			doTweenX('camRightlol', 'camRight', screenWidth, crochet / (1000 / 8) / playbackRate, 'cubeOut')
			setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.3)
			doTweenZoom('camgame', 'camGame', getProperty('camGame.zoom') - 0.3, crochet / (1000 / 4) / playbackRate, 'cubeOut')
			offsetX = -100
			offsetY = 150
			followX = false
		end
		if v1 == 'lolxd' then
			setProperty('camLeft.visible', false)
			setProperty('camRight.visible', false)
		end
		if v1 == 'yourselfagain' then
			offsetX = -50
			setProperty('camLeft.x', -(screenWidth / 2))
			setProperty('camLeft.visible', true)
			setProperty('camLeft.width', screenWidth / 2)
			doTweenX('camLeftlol', 'camLeft', 0, crochet / (1000 / 4) / playbackRate, 'cubeOut')
		end
		if v1 == 'fuckingyeah' then
			startTween('LMAO', 'camLeft', {width = screenWidth}, crochet / (1000 / 6), 'smoothStepInOut')
			doTweenX('fuckyuh', 'zoomoffset', 0.3, crochet / (1000 / 6) / playbackRate, 'cubeIn')
		end
		if v1 == 'byecamera' then
			setProperty('camLeft.visible', false)
			camLeftEnabled = false
		end
	end
end

function getCharacterCameraPos(char)
	local um = (char == 'dad' and 'opponent' or (char == 'gf' and 'girlfriend' or char))
	local offsetX = (char == 'dad' and 150 or (char == 'boyfriend' and -100 or 0))
	local offsetY = (char ~= 'gf' and 100 or 0)
	
	local charX = (getMidpointX(char) + offsetX) + (getProperty(char..'.cameraPosition[0]') + (getProperty(um..'CameraOffset[0]') * (char == 'boyfriend' and -1 or 1))) * (char == 'boyfriend' and -1 or 1)
	local charY = (getMidpointY(char) - offsetY) + (getProperty(char..'.cameraPosition[1]') + getProperty(um..'CameraOffset[1]'))

	return {x = charX, y = charY}
end

function onGameOverStart()
	callMethodFromClass('flixel.FlxG', 'cameras.remove', {instanceArg('camLeft'), true})
	callMethodFromClass('flixel.FlxG', 'cameras.remove', {instanceArg('camRight'), true})
end