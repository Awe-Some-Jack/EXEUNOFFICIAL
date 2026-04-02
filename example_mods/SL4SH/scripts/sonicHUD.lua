--text to image by unholywanderer04 (sm64hud)

local var = true

function onCreatePost()
	--hud objects
	makeHUDSprite('scoreText', 'pixelUI/score', 20, 0, {3.5, 3.5})
	makeHUDSprite('timeText', 'pixelUI/time', 20, 0, {3.5, 3.5})
	makeHUDSprite('missesText', 'pixelUI/misses', 20, 0, {3.5, 3.5})
	makeHUDSprite('missesText-alt', 'pixelUI/misses-alt', 20, 0, {3.5, 3.5})
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

	setProperty('showRating', false)
	setProperty('showComboNum', false)

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
	end

	scoreThing = tostring(score)
	splitScore = breakItDown(scoreThing)

	numCountS = (#splitScore > 1 and #splitScore or 1)
	for i = 1,numCountS do
		local numSpawn = 'scoreNum'..i
		makeHUDSprite('score'..numSpawn, splitScore[i], 330 - ((i-1)*28), getProperty('scoreText.y'), {3.5, 3.5}, true)
		if splitScore[i] == '-' then setProperty('score'..numSpawn..'.animation.curAnim.curFrame', 11) end
	end
end

function onUpdatePost()
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
		loadGraphic(tag, 'pixelUI/numbers', getProperty(tag..'.width') / 11, getProperty(tag..'.height'))
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11}, 0, false)
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