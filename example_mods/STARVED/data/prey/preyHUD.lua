--text to image by unholywanderer04 (sm64hud)

local var = true
local okNowItsTime = false

function onCreatePost()
	for i = 0,3 do setProperty('opponentStrums.members['..i..'].x', -3000) end
	for i = 0, getProperty('unspawnNotes.length')-1 do end

	--hud objects
	makeHUDSprite('scoreText', 'ui/score', 20, 0, {3.5, 3.5})
	makeHUDSprite('timeText', 'ui/time', 20, 0, {3.5, 3.5})
	makeHUDSprite('missesText', 'ui/misses-normal', 20, 0, {3.5, 3.5})
	makeHUDSprite('missesText-alt', 'ui/misses-alt', 20, 0, {3.5, 3.5})
	setProperty('missesText-alt.visible', false)

	makeHUDSprite('futureHealth', 'ui/healthFuture', 20 + (16 * 3.5), 0, {3.5, 3.5})
	setProperty('futureHealth.y', downscroll and (screenHeight - getProperty('futureHealth.height') - 20) or 20)

	makeHUDSprite('futureHealth2', 'ui/healthFuture', 20 + (16 * 3.5), 0, {3.5, 3.5})
	setProperty('futureHealth2.y', downscroll and (screenHeight - getProperty('futureHealth2.height') - 40 - getProperty('futureHealth2.height')) or (40 + getProperty('futureHealth2.height')))

	createInstance('iconSonic', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), false})
	setObjectCamera('iconSonic', 'hud')
	setProperty('iconSonic.antialiasing', false)
	scaleObject('iconSonic', 0.5, 0.5)
	callMethod('iconSonic.setPosition', {-34, getProperty('futureHealth.y') - 42})
	addInstance('iconSonic')

	createInstance('iconFurn', 'objects.HealthIcon', {getProperty('dad.healthIcon'), false})
	setObjectCamera('iconFurn', 'hud')
	setProperty('iconFurn.antialiasing', false)
	scaleObject('iconFurn', 0.5, 0.5)
	callMethod('iconFurn.setPosition', {-34, getProperty('futureHealth2.y') - 42})
	addInstance('iconFurn')

	if downscroll then
		dsvalScore = 20
		dsvalTime = 20+(getProperty('scoreText.height')+10)
		dsvalMisses = 20+(getProperty('scoreText.height')*2+20)
	else
		dsvalScore = (screenHeight - getProperty('scoreText.height')) - (((getProperty('scoreText.height') * 2) + 20) + 20)
		dsvalTime = (screenHeight - getProperty('timeText.height')) - ((getProperty('scoreText.height') + 10) + 20)
		dsvalMisses = (screenHeight - getProperty('missesText.height')) - 20
	end
	setProperty('scoreText.y', dsvalScore)
	setProperty('timeText.y', dsvalTime)
	setProperty('missesText.y', dsvalMisses)
	setProperty('missesText-alt.y', getProperty('missesText.y'))
	onUpdateScore()

	--intro card
	makeHUDSprite('cardBar', 'ui/card/cardBar', 0, 0, {3, 3})
	screenCenter('cardBar', 'x')
	setObjectCamera('cardBar', 'other')
	makeHUDSprite('cardText', 'ui/card/cardText', 0, 0, {3, 3})
	setObjectCamera('cardText', 'other')
	setProperty('cardText.y', 72*3)

	setProperty('cardBar.y', -getProperty('cardBar.height'))
	setProperty('cardText.x', screenWidth)

	--setting some stuff
	setProperty('scoreTxt.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('timeBar.visible', false)

	setProperty('showRating', false)
	setProperty('showComboNum', false)

	setProperty('healthBar.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)

	--save fps visibility and hide fps
	var = getPropertyFromClass('Main', 'fpsVar.visible')
	setPropertyFromClass('Main', 'fpsVar.visible', false)
end

function onDestroy()
	setPropertyFromClass('Main', 'fpsVar.visible', var)
end

function onUpdateScore()
	missesThing = tostring(misses)
	splitMisses = breakItDown(missesThing)

	numCount = (#splitMisses > 1 and #splitMisses or 1)
	for i = 1,numCount do
		local numSpawn = 'missesNum'..i
		makeHUDSprite('misses'..numSpawn, splitMisses[i], 302 - ((i-1)*28), getProperty('missesText.y'), {3.5, 3.5}, true)
		if splitMisses[i] == '-' then setProperty('misses'..numSpawn..'.animation.curAnim.curFrame', 12) end
	end

	scoreThing = tostring(score)
	splitScore = breakItDown(scoreThing)

	numCountS = (#splitScore > 1 and #splitScore or 1)
	for i = 1,numCountS do
		local numSpawn = 'scoreNum'..i
		makeHUDSprite('score'..numSpawn, splitScore[i], 330 - ((i-1)*28), getProperty('scoreText.y'), {3.5, 3.5}, true)
		if splitScore[i] == '-' then setProperty('score'..numSpawn..'.animation.curAnim.curFrame', 12) end
	end

	removeLuaSprite('healthhealthNum4')

	healthThing = tostring(math.range(getHealth() * 50, 0, 100))..'%'
	splitHealth = breakItDown(healthThing)
	newHealthSplit = {}
	for i = #splitHealth, 1, -1 do
		table.insert(newHealthSplit, splitHealth[i])
	end

	numCountH = (#newHealthSplit > 1 and #newHealthSplit or 1)
	for i = 1,numCountH do
		local numSpawn = 'healthNum'..i
		removeLuaSprite('health'..numSpawn)
		makeHUDSprite('health'..numSpawn, newHealthSplit[i], 110 + ((i-1)*28), getProperty('futureHealth.y') + 18, {3.5, 3.5}, true)
		if newHealthSplit[i] == '%' then
			setProperty('health'..numSpawn..'.animation.curAnim.curFrame', 13)
		elseif newHealthSplit[i] == '-' then
			setProperty('health'..numSpawn..'.animation.curAnim.curFrame', 12)
		end
	end

	healthThing2 = tostring(math.range((2 - getHealth()) * 50, 0, 100))..'%'
	splitHealth2 = breakItDown(healthThing2)
	newHealthSplit2 = {}
	for i = #splitHealth2, 1, -1 do
		table.insert(newHealthSplit2, splitHealth2[i])
	end

	numCountH2 = (#newHealthSplit2 > 1 and #newHealthSplit2 or 1)
	for i = 1,numCountH2 do
		local numSpawn = 'healthNum'..i
		removeLuaSprite('health2healthNum3')
		makeHUDSprite('health2'..numSpawn, newHealthSplit2[i], 110 + ((i-1)*28), getProperty('futureHealth2.y') + 18, {3.5, 3.5}, true)
		if newHealthSplit2[i] == '%' then
			setProperty('health2'..numSpawn..'.animation.curAnim.curFrame', 13)
		elseif newHealthSplit2[i] == '-' then
			setProperty('health2'..numSpawn..'.animation.curAnim.curFrame', 12)
		end
	end

	setProperty('iconSonic.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconFurn.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
end

function onUpdatePost()
	local lastHeld = {'', '', '', ''} -- for time
	local hold = {}
	local guh = formatTime(getSongPosition() - noteOffset)
	for letter in guh:gmatch(".") do table.insert(hold, letter) end

	if not inGameOver then
		for i = 1, #hold do
			if lastHeld[i] ~= hold[i] then -- dont fucking make the same image each frame
				lastHeld[i] = hold[i]
				if hold[i] ~= ':' and hold[i] ~= ';' then
					makeHUDSprite('timeNum'..i, hold[i], 162 + ((i-1) * 28), getProperty('timeText.y'), {3.5, 3.5}, true)
				elseif hold[i] == ';' then
					makeHUDSprite('timeSeper2'..i, 'ui/numbers', 162 + ((i-1) * 28), getProperty('timeText.y'), {3.5, 3.5}, true)
					setProperty('timeSeper2'..i..'.animation.curAnim.curFrame', 11)
				else
					makeHUDSprite('timeSeper'..i, 'ui/numbers', 170 + ((i-1) * 28), getProperty('timeText.y'), {3.5, 3.5}, true)
					setProperty('timeSeper'..i..'.animation.curAnim.curFrame', 10)
				end
			end
		end
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000)
	return string.format('%01d:%02d;%02d', (s/60)%60, s%60, (math.floor(ms/10))%100)
end

function math.range(number, min, max)
	return math.max(min, math.min(max, number))
end

function makeHUDSprite(tag, path, x, y, scale, num)
	num = num or false

	makeLuaSprite(tag, (num == true and 'ui/numbers' or path), x, y)
	if num == true then
		loadGraphic(tag, 'ui/numbers', getProperty(tag..'.width') / 14, getProperty(tag..'.height'))
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', path)
	end
	scaleObject(tag, scale[1], scale[2])
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	if not hideHud then
		addLuaSprite(tag)
	end
end

function onBeatHit()
	if curBeat == 2 then
		doTweenY('hibar', 'cardBar', 0, 0.4)
		doTweenX('hitext', 'cardText', getProperty('cardBar.x') + (8*3), 0.5)
		runTimer('ohnotheyreleaving', crochet / (1000 / 6) / playbackRate)
	end

	if misses >= 1 then
		setProperty('missesText.visible', not getProperty('missesText.visible'))
		setProperty('missesText-alt.visible', not getProperty('missesText-alt.visible'))
	end
end

function breakItDown(breakin, flip)
	local daShit, tempTable = {}, {}

	for thing in breakin:gmatch(".") do table.insert(tempTable, thing) end -- split every "letter"
	for i = #tempTable, 1, -1 do daShit[#daShit + 1] = tempTable[i] end -- then flip the shit cuz I can't be bothered

	return daShit
end

function rgbToHex(rgb) -- https://www.codegrepper.com/code-examples/lua/rgb+to+hex+lua
    return string.format('%02x%02x%02x', math.floor(rgb[1]), math.floor(rgb[2]), math.floor(rgb[3]))
end

function onTimerCompleted(t)
	if t == 'ohnotheyreleaving' then
		doTweenY('hibar', 'cardBar', -getProperty('cardBar.height'), 0.2)
		doTweenX('hitext', 'cardText', screenWidth, 0.3)
	end
end

function onEvent(n)
	if n == 'Change Character' then
		callMethod('iconFurn.changeIcon', {'starver'})
	end
end