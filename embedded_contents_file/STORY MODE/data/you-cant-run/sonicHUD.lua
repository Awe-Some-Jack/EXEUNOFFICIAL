local postCreate = false
local isShown = false

function onCreatePost()
	postCreate = true

	--sonic hud
	makeHUDSprite('scoreText', 'score', 20)
	makeHUDSprite('timeText', 'time', 20)
	makeHUDSprite('missesText', 'misses', 20) makeHUDSprite('missesText-alt', 'misses-alt', 20) setProperty('missesText-alt.visible', false)

	initialY = 6 * 3
	setProperty('scoreText.y', downscroll and initialY or (screenHeight - getProperty('scoreText.height') - initialY - ((getProperty('scoreText.height') * 2) + initialY)))
	setProperty('timeText.y', downscroll and (initialY + (getProperty('timeText.height') + (initialY / 2))) or (screenHeight - getProperty('timeText.height') - initialY - (getProperty('timeText.height') + (initialY / 2))))
	setProperty('missesText.y', downscroll and (initialY + ((getProperty('missesText.height') * 2) + initialY)) or (screenHeight - getProperty('missesText.height') - initialY))
	setProperty('missesText-alt.y', getProperty('missesText.y'))

	local iconOffset = 75 * 0.5
	createInstance('iconBFP', 'objects.HealthIcon', {'bfp', false})
	setObjectCamera('iconBFP', 'hud')
	setProperty('iconBFP.antialiasing', false)
	scaleObject('iconBFP', 0.5, 0.5)
	callMethod('iconBFP.setPosition', {-iconOffset + initialY, -iconOffset + (downscroll and (-initialY + (screenHeight - 75)) or initialY)})
	addInstance('iconBFP')
	makeHUDSprite('futureHealthBF', 'health', getProperty('iconBFP.x') + iconOffset + 72 + 12, getProperty('iconBFP.y') + iconOffset + 6)

	createInstance('iconOppP', 'objects.HealthIcon', {'XENO-P2P', false})
	setObjectCamera('iconOppP', 'hud')
	setProperty('iconOppP.antialiasing', false)
	scaleObject('iconOppP', 0.5, 0.5)
	callMethod('iconOppP.setPosition', {-iconOffset + initialY, -iconOffset + (downscroll and (-(initialY / 2) + (screenHeight - 75) - (75 + (initialY / 2))) or (initialY + 75))})
	addInstance('iconOppP')
	makeHUDSprite('futureHealthOpp', 'health', getProperty('iconOppP.x') + iconOffset + 72 + 12, getProperty('iconOppP.y') + iconOffset + 6)

	setProperty('scoreText.alpha', 0)
	setProperty('timeText.alpha', 0)
	setProperty('missesText.alpha', 0)
	setProperty('missesText-alt.alpha', 0)

	setProperty('iconBFP.alpha', 0)
	setProperty('iconOppP.alpha', 0)
	setProperty('futureHealthBF.alpha', 0)
	setProperty('futureHealthOpp.alpha', 0)

	updateHUD()
end

function onUpdateScore() if postCreate then updateHUD() end end

local oldScore = {0, 0, 0, 0}
function updateHUD()
	local a = isShown and 1 or 0

	--score
	local splittedScore = splitShit(score)
	for i = 1,math.max(#splittedScore, 1) do
		local tag = 'scoreNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedScore[i], 308 - ((i - 1) * 24), getProperty('scoreText.y'), true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedScore[i] == '-' and 11 or splittedScore[i]))
		setProperty(tag..'.alpha', a)
	end
	if #splittedScore ~= oldScore[1] then for i = 1,oldScore[1] do if i > #splittedScore and luaSpriteExists('scoreNum'..i) then removeLuaSprite('scoreNum'..i) end end end
	oldScore[1] = #splittedScore

	--misses
	local splittedMisses = splitShit(misses)
	for i = 1,math.max(#splittedMisses, 1) do
		local tag = 'missesNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedMisses[i], 308 - ((i - 1) * 24), getProperty('missesText.y'), true) end
		setProperty(tag..'.animation.curAnim.curFrame', splittedMisses[i])
		setProperty(tag..'.alpha', a)
	end
	if #splittedMisses ~= oldScore[2] then for i = 1,oldScore[2] do if i > #splittedMisses and luaSpriteExists('missesNum'..i) then removeLuaSprite('missesNum'..i) end end end
	oldScore[2] = #splittedMisses

	--health player
	local splittedHealth = splitShit(tostring(math.floor(bound(getHealth() * 50, 0, 100)))..'%', false)
	for i = 1,math.max(#splittedHealth, 1) do
		local tag = 'healthNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealth[i], 117 + 12 + ((i - 1) * 24), getProperty('futureHealthBF.y') + 15, true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedHealth[i] == '-' and 11 or (splittedHealth[i] == '%' and 12 or splittedHealth[i])))
		setProperty(tag..'.alpha', a)
	end
	if #splittedHealth ~= oldScore[3] then for i = 1,oldScore[3] do if i > #splittedHealth and luaSpriteExists('healthNum'..i) then removeLuaSprite('healthNum'..i) end end end
	oldScore[3] = #splittedHealth

	--health opp
	local splittedHealthOpp = splitShit(tostring(math.floor(bound((2 - getHealth()) * 50, 0, 100) + 0.5))..'%', false)
	for i = 1,math.max(#splittedHealthOpp, 1) do
		local tag = 'health2Num'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealthOpp[i], 117 + 12 + ((i - 1) * 24), getProperty('futureHealthOpp.y') + 15, true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedHealthOpp[i] == '-' and 11 or (splittedHealthOpp[i] == '%' and 12 or splittedHealthOpp[i])))
		setProperty(tag..'.alpha', a)
	end
	if #splittedHealthOpp ~= oldScore[4] then for i = 1,oldScore[4] do if i > #splittedHealthOpp and luaSpriteExists('health2Num'..i) then removeLuaSprite('health2Num'..i) end end end
	oldScore[4] = #splittedHealthOpp

	setProperty('iconBFP.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconOppP.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
end

local oldTime = ''
function onUpdatePost()
	local shouldShow = curBeat >= 132 and curBeat < 200

	if shouldShow and not isShown then
		isShown = true
		setProperty('scoreText.alpha', 1)
		setProperty('timeText.alpha', 1)
		setProperty('missesText.alpha', 1)
		setProperty('missesText-alt.alpha', 1)
		setProperty('exeScoreTxt.alpha', 0)

		setProperty('iconBFP.alpha', 1)
		setProperty('iconOppP.alpha', 1)
		setProperty('futureHealthBF.alpha', 1)
		setProperty('futureHealthOpp.alpha', 1)

		setProperty('hbBG.alpha', 0)
		setProperty('hbHealth.alpha', 0)
		setProperty('hbHealth2.alpha', 0)
		setProperty('separatorHealth.alpha', 0)
		setProperty('iconBF.alpha', 0)
		setProperty('iconOpp.alpha', 0)

		for i = 0,3 do setProperty('strumLineNotes.members['..i..'].x', -1000) end

		updateHUD()
	elseif not shouldShow and isShown then
		isShown = false
		setProperty('scoreText.alpha', 0)
		setProperty('timeText.alpha', 0)
		setProperty('missesText.alpha', 0)
		setProperty('missesText-alt.alpha', 0)
		setProperty('exeScoreTxt.alpha', 1)

		setProperty('iconBFP.alpha', 0)
		setProperty('iconOppP.alpha', 0)
		setProperty('futureHealthBF.alpha', 0)
		setProperty('futureHealthOpp.alpha', 0)
		for i = 1,4 do
			removeLuaSprite('healthNum'..i)
			removeLuaSprite('health2Num'..i)
		end

		setProperty('hbBG.alpha', 1)
		setProperty('hbHealth.alpha', 1)
		setProperty('hbHealth2.alpha', 1)
		setProperty('separatorHealth.alpha', 1)
		setProperty('iconBF.alpha', 1)
		setProperty('iconOpp.alpha', 1)

		for i = 0,3 do setProperty('strumLineNotes.members['..i..'].x', _G['defaultOpponentStrumX'..i]) end

		updateHUD()
	end

	if not inGameOver then
		--time
		local daTime = formatTime(bound(getSongPosition() - noteOffset, 0, songLength))
		if oldTime ~= daTime then
			local splittedTime = splitShit(daTime, false)
			for i = 1,math.max(#splittedTime, 1) do
				local tag = 'timeNum'..i
				if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedTime[i], 164 + ((i - 1) * 24), getProperty('timeText.y'), true) end
				setProperty(tag..'.animation.curAnim.curFrame', (splittedTime[i] == ':' and 10 or (splittedTime[i] == ';' and 11 or splittedTime[i])))
				setProperty(tag..'.alpha', isShown and 1 or 0)
			end
			oldTime = daTime
		end
	end
end

function makeHUDSprite(tag, path, x, y, num)
	makeLuaSprite(tag, (num and 'pixelUI/numbers' or ('pixelUI/'..path)), x or 0, y or 0)
	if num then
		loadGraphic(tag, 'pixelUI/numbers', 130 / 13, 11)
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', tonumber(path))
	end
	scaleObject(tag, 3, 3)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	setProperty(tag..'.moves', false)
	addLuaSprite(tag)
end

function onBeatHit()
	if misses >= 1 then
		setProperty('missesText.visible', curBeat % 2 == 0)
		setProperty('missesText-alt.visible', curBeat % 2 == 1)
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000)
	return string.format('%01d:%02d', (s/60)%60, s%60)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end

function splitShit(s, f)
	f = f == nil and true or f
	local splitted,temp = {}, {}
	for l in tostring(s):gmatch(".") do table.insert(temp, l) end
	if f then for i = #temp,1,-1 do splitted[#splitted + 1] = temp[i] end else for i = 1,#temp do splitted[#splitted + 1] = temp[i] end end
	return splitted
end

function noteMissPress() callMethod('updateScore', {false, false}) end