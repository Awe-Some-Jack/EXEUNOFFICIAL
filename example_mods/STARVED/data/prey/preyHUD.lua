local okNowItsTime = false

function onCreatePost()
	for i = 0,3 do setProperty('opponentStrums.members['..i..'].x', -3000) end
	for i = 0, getProperty('unspawnNotes.length')-1 do end

	--hud objects
	makeHUDSprite('scoreText', 'ui/score', 20, 0, 3.5)
	makeHUDSprite('timeText', 'ui/time', 20, 0, 3.5)
	makeHUDSprite('missesText', 'ui/misses-normal', 20, 0, 3.5)
	makeHUDSprite('missesText-alt', 'ui/misses-alt', 20, 0, 3.5)
	setProperty('missesText-alt.visible', false)

	makeHUDSprite('futureHealth', 'ui/healthFuture', 20 + (16 * 3.5), 0, 3.5)
	setProperty('futureHealth.y', downscroll and (screenHeight - getProperty('futureHealth.height') - 20) or 20)

	makeHUDSprite('futureHealth2', 'ui/healthFuture', 20 + (16 * 3.5), 0, 3.5)
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
	makeHUDSprite('cardBar', 'ui/card/cardBar', 0, 0, 3)
	screenCenter('cardBar', 'x')
	setObjectCamera('cardBar', 'other')
	makeHUDSprite('cardText', 'ui/card/cardText', 0, 0, 3)
	setObjectCamera('cardText', 'other')
	setProperty('cardText.y', 72*3)

	setProperty('cardBar.y', -getProperty('cardBar.height'))
	setProperty('cardText.x', screenWidth)

	--setting some stuff
	setProperty('scoreTxt.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('timeBar.visible', false)

	setProperty('healthBar.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
end

local oldScore = {0, 0, 0, 0}
function onUpdateScore()
	--score
	local splittedScore = splitShit(score)
	for i = 1,math.max(#splittedScore, 1) do
		local tag = 'scoreNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedScore[i], 330 - ((i - 1) * 28), getProperty('scoreText.y'), 3.5, true) end
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedScore[i] == '-' and 12 or splittedScore[i])) setProperty(tag..'.y', getProperty('scoreText.y')) end
	end
	if #splittedScore ~= oldScore[1] then for i = 1,oldScore[1] do if i > #splittedScore and luaSpriteExists('scoreNum'..i) then removeLuaSprite('scoreNum'..i) end end end

	--misses
	local splittedMisses = splitShit(misses)
	for i = 1,math.max(#splittedMisses, 1) do
		local tag = 'missesNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedMisses[i], 302 - ((i - 1) * 28), getProperty('missesText.y'), 3.5, true) end
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', splittedMisses[i]) setProperty(tag..'.y', getProperty('missesText.y')) end
	end
	if #splittedMisses ~= oldScore[2] then for i = 1,oldScore[2] do if i > #splittedMisses and luaSpriteExists('missesNum'..i) then removeLuaSprite('missesNum'..i) end end end

	--health player
	local splittedHealth = splitShit(tostring(math.floor(bound(getHealth() * 50, 0, 100)))..'%', false)
	for i = 1,math.max(#splittedHealth, 1) do
		local tag = 'healthNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealth[i], 110 + ((i - 1) * 28), getProperty('futureHealth.y') + 18, 3.5, true) end
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedHealth[i] == '-' and 12 or (splittedHealth[i] == '%' and 13 or splittedHealth[i]))) setProperty(tag..'.y', getProperty('futureHealth.y') + 18) end
	end
	if #splittedHealth ~= oldScore[3] then for i = 1,oldScore[3] do if i > #splittedHealth and luaSpriteExists('healthNum'..i) then removeLuaSprite('healthNum'..i) end end end

	--health opp
	local splittedHealthOpp = splitShit(tostring(math.floor(bound((2 - getHealth()) * 50, 0, 100) + 0.5))..'%', false)
	for i = 1,math.max(#splittedHealthOpp, 1) do
		local tag = 'health2Num'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealthOpp[i], 110 + ((i - 1) * 28), getProperty('futureHealth2.y') + 18, 3.5, true) end
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedHealthOpp[i] == '-' and 12 or (splittedHealthOpp[i] == '%' and 13 or splittedHealthOpp[i]))) setProperty(tag..'.y', getProperty('futureHealth2.y') + 18) end
	end
	if #splittedHealthOpp ~= oldScore[4] then for i = 1,oldScore[4] do if i > #splittedHealthOpp and luaSpriteExists('health2Num'..i) then removeLuaSprite('health2Num'..i) end end end

	oldScore = {#splittedScore, #splittedMisses, #splittedHealth, #splittedHealthOpp}

	setProperty('iconSonic.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconFurn.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
end

function onUpdatePost()
	if not inGameOver then
		--time
		local splittedTime = splitShit(formatTime(getSongPosition() - noteOffset), false)
		for i = 1,math.max(#splittedTime, 1) do
			local tag = 'timeNum'..i
			if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedTime[i], (splittedTime[i] == ':' and 170 or 162) + ((i - 1) * 28), getProperty('timeText.y'), 3.5, true) end
			if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedTime[i] == ':' and 10 or (splittedTime[i] == ';' and 11 or splittedTime[i]))) setProperty(tag..'.y', getProperty('timeText.y')) end
		end
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000)
	return string.format('%01d:%02d;%02d', (s/60)%60, s%60, (math.floor(ms/10))%100)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end

function makeHUDSprite(tag, path, x, y, scale, num)
	makeLuaSprite(tag, (num and 'ui/numbers' or path), x, y)
	if num then
		loadGraphic(tag, 'ui/numbers', getProperty(tag..'.width') / 14, getProperty(tag..'.height'))
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', tonumber(path))
	end
	scaleObject(tag, scale, scale)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	if not hideHud then addLuaSprite(tag) end
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

function rgbToHex(rgb) -- https://www.codegrepper.com/code-examples/lua/rgb+to+hex+lua
    return string.format('%02x%02x%02x', math.floor(rgb[1]), math.floor(rgb[2]), math.floor(rgb[3]))
end

function splitShit(s, f)
	f = f == nil and true or f
	local splitted,temp = {}, {}
	for l in tostring(s):gmatch(".") do table.insert(temp, l) end
	if f then for i = #temp,1,-1 do splitted[#splitted + 1] = temp[i] end else for i = 1,#temp do splitted[#splitted + 1] = temp[i] end end
	return splitted
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