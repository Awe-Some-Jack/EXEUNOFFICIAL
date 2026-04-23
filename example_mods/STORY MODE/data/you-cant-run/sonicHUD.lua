function onCreatePost()
	--hud objects
	makeHUDSprite('scoreText', 'pixelUI/score', 20, 0, 3.5)
	makeHUDSprite('timeText', 'pixelUI/time', 20, 0, 3.5)
	makeHUDSprite('missesText', 'pixelUI/misses', 20, 0, 3.5)
	makeHUDSprite('missesText-alt', 'pixelUI/misses-alt', 20, 0, 3.5)
	setProperty('missesText-alt.visible', false)

	makeHUDSprite('futureHealth', 'pixelUI/health', 20 + (16 * 3.5), 0, 3.5)
	setProperty('futureHealth.y', downscroll and (screenHeight - getProperty('futureHealth.height') - 20) or 20)

	makeHUDSprite('futureHealth2', 'pixelUI/health', 20 + (16 * 3.5), 0, 3.5)
	setProperty('futureHealth2.y', downscroll and (screenHeight - getProperty('futureHealth2.height') - 40 - getProperty('futureHealth2.height')) or (40 + getProperty('futureHealth2.height')))

	createInstance('iconBFP', 'objects.HealthIcon', {'bfp', false})
	setObjectCamera('iconBFP', 'hud')
	setProperty('iconBFP.antialiasing', false)
	scaleObject('iconBFP', 0.5, 0.5)
	callMethod('iconBFP.setPosition', {-34, getProperty('futureHealth.y') - 42})
	addInstance('iconBFP')

	createInstance('iconOppP', 'objects.HealthIcon', {'XENO-P2P', false})
	setObjectCamera('iconOppP', 'hud')
	setProperty('iconOppP.antialiasing', false)
	scaleObject('iconOppP', 0.5, 0.5)
	callMethod('iconOppP.setPosition', {-34, getProperty('futureHealth2.y') - 42})
	addInstance('iconOppP')

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

	setProperty('scoreText.alpha', 0)
	setProperty('timeText.alpha', 0)
	setProperty('missesText.alpha', 0)
	setProperty('missesText-alt.alpha', 0)

	setProperty('iconBFP.alpha', 0)
	setProperty('iconOppP.alpha', 0)
	setProperty('futureHealth.alpha', 0)
	setProperty('futureHealth2.alpha', 0)

	for i = 0,10 do
		if luaSpriteExists('scoreNum'..i) then setProperty('scoreNum'..i..'.alpha', 0) end
		if luaSpriteExists('missesNum'..i) then setProperty('missesNum'..i..'.alpha', 0) end
		if luaSpriteExists('timeNum'..i) then setProperty('timeNum'..i..'.alpha', 0) end
		if luaSpriteExists('healthNum'..i) then setProperty('healthNum'..i..'.alpha', 0) end if luaSpriteExists('health2Num'..i) then setProperty('health2Num'..i..'.alpha', 0) end
	end
end

local oldScore = {0, 0, 0, 0}
function onUpdateScore()
	if curBeat < 132 and curBeat >= 200 then return end
	--score
	local splittedScore = splitShit(score)
	for i = 1,math.max(#splittedScore, 1) do
		local tag = 'scoreNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedScore[i], 330 - ((i - 1) * 28), getProperty('scoreText.y'), 3.5, true) end
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedScore[i] == '-' and 11 or splittedScore[i])) setProperty(tag..'.y', getProperty('scoreText.y')) end
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
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedHealth[i] == '-' and 11 or (splittedHealth[i] == '%' and 12 or splittedHealth[i]))) setProperty(tag..'.y', getProperty('futureHealth.y') + 18) end
	end
	if #splittedHealth ~= oldScore[3] then for i = 1,oldScore[3] do if i > #splittedHealth and luaSpriteExists('healthNum'..i) then removeLuaSprite('healthNum'..i) end end end

	--health opp
	local splittedHealthOpp = splitShit(tostring(math.floor(bound((2 - getHealth()) * 50, 0, 100) + 0.5))..'%', false)
	for i = 1,math.max(#splittedHealthOpp, 1) do
		local tag = 'health2Num'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealthOpp[i], 110 + ((i - 1) * 28), getProperty('futureHealth2.y') + 18, 3.5, true) end
		if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedHealthOpp[i] == '-' and 11 or (splittedHealthOpp[i] == '%' and 12 or splittedHealthOpp[i]))) setProperty(tag..'.y', getProperty('futureHealth2.y') + 18) end
	end
	if #splittedHealthOpp ~= oldScore[4] then for i = 1,oldScore[4] do if i > #splittedHealthOpp and luaSpriteExists('health2Num'..i) then removeLuaSprite('health2Num'..i) end end end

	oldScore = {#splittedScore, #splittedMisses, #splittedHealth, #splittedHealthOpp}

	setProperty('iconSonic.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconFurn.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
end

function onUpdatePost()
	if curBeat >= 132 and curBeat < 200 and getProperty('scoreText.alpha') == 0 then
		setProperty('scoreText.alpha', 1)
		setProperty('timeText.alpha', 1)
		setProperty('missesText.alpha', 1)
		setProperty('missesText-alt.alpha', 1)
		setProperty('exeScoreTxt.alpha', 0)

		setProperty('iconBFP.alpha', 1)
		setProperty('iconOppP.alpha', 1)
		setProperty('futureHealth.alpha', 1)
		setProperty('futureHealth2.alpha', 1)

		setProperty('hbBG.alpha', 0)
		setProperty('hbHealth.alpha', 0)
		setProperty('hbHealth2.alpha', 0)
		setProperty('separatorHealth.alpha', 0)
		setProperty('iconBF.alpha', 0)
		setProperty('iconOpp.alpha', 0)

		for i = 0,10 do
			if i < 4 then setProperty('strumLineNotes.members['..i..'].x', -1000) end

			if luaSpriteExists('scoreNum'..i) then setProperty('scoreNum'..i..'.alpha', 1) end
			if luaSpriteExists('missesNum'..i) then setProperty('missesNum'..i..'.alpha', 1) end
			if luaSpriteExists('timeNum'..i) then setProperty('timeNum'..i..'.alpha', 1) end
			if luaSpriteExists('healthNum'..i) then setProperty('healthNum'..i..'.alpha', 1) end if luaSpriteExists('health2Num'..i) then setProperty('health2Num'..i..'.alpha', 1) end
		end
	end

	if curBeat >= 200 and getProperty('scoreText.alpha') == 1 then
		setProperty('scoreText.alpha', 0)
		setProperty('timeText.alpha', 0)
		setProperty('missesText.alpha', 0)
		setProperty('missesText-alt.alpha', 0)
		setProperty('exeScoreTxt.alpha', 1)

		setProperty('iconBFP.alpha', 0)
		setProperty('iconOppP.alpha', 0)
		setProperty('futureHealth.alpha', 0)
		setProperty('futureHealth2.alpha', 0)
		for i = 1,4 do
			removeLuaSprite('healthhealthNum'..i)
			removeLuaSprite('health2healthNum'..i)
		end

		setProperty('hbBG.alpha', 1)
		setProperty('hbHealth.alpha', 1)
		setProperty('hbHealth2.alpha', 1)
		setProperty('separatorHealth.alpha', 1)
		setProperty('iconBF.alpha', 1)
		setProperty('iconOpp.alpha', 1)

		for i = 0,10 do
			if i < 4 then setProperty('strumLineNotes.members['..i..'].x', _G['defaultOpponentStrumX'..i]) end

			if luaSpriteExists('scoreNum'..i) then setProperty('scoreNum'..i..'.alpha', 0) end
			if luaSpriteExists('missesNum'..i) then setProperty('missesNum'..i..'.alpha', 0) end
			if luaSpriteExists('timeNum'..i) then setProperty('timeNum'..i..'.alpha', 0) end
			if luaSpriteExists('healthNum'..i) then setProperty('healthNum'..i..'.alpha', 0) end if luaSpriteExists('health2Num'..i) then setProperty('health2Num'..i..'.alpha', 0) end
		end
	end

	if curBeat < 132 or curBeat >= 200 then return end
	if not inGameOver then
		--time
		local splittedTime = splitShit(formatTime(getSongPosition() - noteOffset), false)
		for i = 1,math.max(#splittedTime, 1) do
			local tag = 'timeNum'..i
			if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedTime[i], (splittedTime[i] == ':' and 170 or 162) + ((i - 1) * 28), getProperty('timeText.y'), 3.5, true) end
			if luaSpriteExists(tag) then setProperty(tag..'.animation.curAnim.curFrame', (splittedTime[i] == ':' and 10 or splittedTime[i])) setProperty(tag..'.y', getProperty('timeText.y')) end
		end

		for i = 0,10 do if luaSpriteExists('scoreNum'..i) and getProperty('scoreNum'..i..'.offset.x') ~= -8.75 and getProperty('scoreNum'..i..'.offset.y') ~= -13.75 then callMethod('scoreNum'..i..'.offset.set', {-8.75, -13.75}) end end
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000)
	return string.format('%01d:%02d', (s/60)%60, s%60)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end

function makeHUDSprite(tag, path, x, y, scale, num)
	makeLuaSprite(tag, (num and 'pixelUI/numbers' or path), x, y)
	if num then
		loadGraphic(tag, 'pixelUI/numbers', getProperty(tag..'.width') / 13, getProperty(tag..'.height'))
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', tonumber(path))
	end
	scaleObject(tag, scale, scale)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	if not hideHud then addLuaSprite(tag) end
end

function onBeatHit()
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