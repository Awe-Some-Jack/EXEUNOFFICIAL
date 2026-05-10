local okNowItsTime = false

function onCreatePost()
	--hud objects
	makeHUDSprite('scoreText', 'pixelUI/score', 20, 0, 3.5)
	makeHUDSprite('timeText', 'pixelUI/time', 20, 0, 3.5)
	makeHUDSprite('missesText', 'pixelUI/misses', 20, 0, 3.5)
	makeHUDSprite('missesText-alt', 'pixelUI/misses-alt', 20, 0, 3.5)
	setProperty('missesText-alt.visible', false)

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

	oldScore = {#splittedScore, #splittedMisses}
end

function onUpdatePost()
	if not inGameOver then
		--time
		local splittedTime = splitShit(formatTime(math.max(getSongPosition() - noteOffset, 0)), false)
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
		loadGraphic(tag, 'pixelUI/numbers', getProperty(tag..'.width') / 12, getProperty(tag..'.height'))
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11}, 0, false)
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