--text to image by unholywanderer04 (sm64hud)

local var = true

function onCreatePost()
	--hud objects
	makeHUDSprite('scoreText', 'pixelUI/score', 20, 0, {3.5, 3.5})
	makeHUDSprite('timeText', 'pixelUI/time', 20, 0, {3.5, 3.5})
	makeHUDSprite('missesText', 'pixelUI/misses', 20, 0, {3.5, 3.5})
	makeHUDSprite('missesText-alt', 'pixelUI/misses-alt', 20, 0, {3.5, 3.5})
	setProperty('missesText-alt.visible', false)

	makeHUDSprite('futureHealth', 'pixelUI/health', 20 + (16 * 3.5), 0, {3.5, 3.5})
	setProperty('futureHealth.y', downscroll and (screenHeight - getProperty('futureHealth.height') - 20) or 20)

	makeHUDSprite('futureHealth2', 'pixelUI/health', 20 + (16 * 3.5), 0, {3.5, 3.5})
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

	--setting some stuff
	setProperty('scoreTxt.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('timeBar.visible', false)

	setProperty('showRating', false)
	setProperty('showComboNum', false)

	--save fps visibility and hide fps
	var = getPropertyFromClass('Main', 'fpsVar.visible')
	setPropertyFromClass('Main', 'fpsVar.visible', false)

	setProperty('scoreText.alpha', 0)
	setProperty('timeText.alpha', 0)
	setProperty('missesText.alpha', 0)
	setProperty('missesText-alt.alpha', 0)

	setProperty('iconBFP.alpha', 0)
	setProperty('iconOppP.alpha', 0)
	setProperty('futureHealth.alpha', 0)
	setProperty('futureHealth2.alpha', 0)

	for i = 0,10 do
		if luaSpriteExists('scorescoreNum'..i) then setProperty('scorescoreNum'..i..'.alpha', 0) end
		if luaSpriteExists('missesmissesNum'..i) then setProperty('missesmissesNum'..i..'.alpha', 0) end
		if luaSpriteExists('timeNum'..i) then setProperty('timeNum'..i..'.alpha', 0) end
		if luaSpriteExists('timeSeper'..i) then setProperty('timeSeper'..i..'.alpha', 0) end
	end
end

function onDestroy()
	setPropertyFromClass('Main', 'fpsVar.visible', var)
end

function onUpdateScore()
	if curBeat >= 132 and curBeat < 200 then
		missesThing = tostring(misses)
		splitMisses = breakItDown(missesThing)

		numCount = (#splitMisses > 1 and #splitMisses or 1)
		for i = 1,numCount do
			local numSpawn = 'missesNum'..i
			makeHUDSprite('misses'..numSpawn, splitMisses[i], 302 - ((i-1)*28), getProperty('missesText.y'), {3.5, 3.5}, true)
		end

		scoreThing = tostring(score)
		splitScore = breakItDown(scoreThing)

		numCountS = (#splitScore > 1 and #splitScore or 1)
		for i = 1,numCountS do
			local numSpawn = 'scoreNum'..i
			makeHUDSprite('score'..numSpawn, splitScore[i], 330 - ((i-1)*28), getProperty('scoreText.y'), {3.5, 3.5}, true)
			if splitScore[i] == '-' then setProperty('score'..numSpawn..'.animation.curAnim.curFrame', 11) end
		end

		removeLuaSprite('healthhealthNum4')

		healthThing = tostring(math.floor(math.range(getHealth() * 50, 0, 100)))..'%'
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
				setProperty('health'..numSpawn..'.animation.curAnim.curFrame', 12)
			elseif newHealthSplit[i] == '-' then
				setProperty('health'..numSpawn..'.animation.curAnim.curFrame', 11)
			end
		end

		healthThing2 = tostring(math.floor(math.range((2 - getHealth()) * 50, 0, 100)))..'%'
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
				setProperty('health2'..numSpawn..'.animation.curAnim.curFrame', 12)
			elseif newHealthSplit2[i] == '-' then
				setProperty('health2'..numSpawn..'.animation.curAnim.curFrame', 11)
			end
		end

		setProperty('iconBFP.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
		setProperty('iconOppP.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
	end
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

			if luaSpriteExists('scorescoreNum'..i) then setProperty('scorescoreNum'..i..'.alpha', 1) end
			if luaSpriteExists('missesmissesNum'..i) then setProperty('missesmissesNum'..i..'.alpha', 1) end
			if luaSpriteExists('timeNum'..i) then setProperty('timeNum'..i..'.alpha', 1) end
			if luaSpriteExists('timeSeper'..i) then setProperty('timeSeper'..i..'.alpha', 1) end
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

			if luaSpriteExists('scorescoreNum'..i) then setProperty('scorescoreNum'..i..'.alpha', 0) end
			if luaSpriteExists('missesmissesNum'..i) then setProperty('missesmissesNum'..i..'.alpha', 0) end
			if luaSpriteExists('timeNum'..i) then setProperty('timeNum'..i..'.alpha', 0) end
			if luaSpriteExists('timeSeper'..i) then setProperty('timeSeper'..i..'.alpha', 0) end
		end
	end

	if curBeat >= 132 and curBeat < 200 then
		local lastHeld = {'', '', '', ''} -- for time
		local hold = {}
		local guh = formatTime(math.max(0, getSongPosition() - noteOffset))
		for letter in guh:gmatch(".") do table.insert(hold, letter) end

		if not inGameOver then
			for i = 1, #hold do
				if lastHeld[i] ~= hold[i] then -- dont fucking make the same image each frame
					lastHeld[i] = hold[i]
					if hold[i] ~= ':' then
						makeHUDSprite('timeNum'..i, hold[i], 162 + ((i-1) * 28), getProperty('timeText.y'), {3.5, 3.5}, true)
					else
						makeHUDSprite('timeSeper'..i, 'pixelUI/numbers', 170 + ((i-1) * 28), getProperty('timeText.y'), {3.5, 3.5}, true)
						setProperty('timeSeper'..i..'.animation.curAnim.curFrame', 10)
					end
				end
			end
		end
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000)
	return string.format('%01d:%02d', (s/60)%60, s%60)
end

function math.range(number, min, max)
	return math.max(min, math.min(max, number))
end

function makeHUDSprite(tag, path, x, y, scale, num)
	num = num or false

	makeLuaSprite(tag, (num == true and 'pixelUI/numbers' or path), x, y)
	if num == true then
		loadGraphic(tag, 'pixelUI/numbers', getProperty(tag..'.width') / 12, getProperty(tag..'.height'))
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12}, 0, false)
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
	if curBeat == 132 then
		onUpdateScore()
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