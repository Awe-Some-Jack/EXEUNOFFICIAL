local function killMainHUD()
	callMethod('healthBar.kill')
	callMethod('iconP1.kill')
	callMethod('iconP2.kill')
	callMethod('scoreTxt.kill')

	callMethod('timeBar.kill')
	callMethod('timeTxt.kill')
end

local postCreate = false
function onCreatePost()
	postCreate = true
	for i = 0,3 do setProperty('opponentStrums.members['..i..'].x', -3000) end
	killMainHUD()

	--sonic hud

	makeHUDSprite('scoreText', 'score', 20)
	makeHUDSprite('timeText', 'time', 20)
	makeHUDSprite('missesText', 'misses', 20) makeHUDSprite('missesText-alt', 'misses-alt', 20) setProperty('missesText-alt.visible', false)

	initialY = 6 * 3
	setProperty('scoreText.y', downscroll and initialY or (screenHeight - getProperty('scoreText.height') - initialY - ((getProperty('scoreText.height') * 2) + initialY)))
	setProperty('timeText.y', downscroll and (initialY + (getProperty('timeText.height') + (initialY / 2))) or (screenHeight - getProperty('timeText.height') - initialY - (getProperty('timeText.height') + (initialY / 2))))
	setProperty('missesText.y', downscroll and (initialY + ((getProperty('missesText.height') * 2) + initialY)) or (screenHeight - getProperty('missesText.height') - initialY))
	setProperty('missesText-alt.y', getProperty('missesText.y'))

	updateHUD()
end

function onUpdateScore() if postCreate then updateHUD() end end

local oldScore = {0, 0}
function updateHUD()
	--score
	local splittedScore = splitShit(score)
	for i = 1,math.max(#splittedScore, 1) do
		local tag = 'scoreNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedScore[i], 308 - ((i - 1) * 24), getProperty('scoreText.y'), true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedScore[i] == '-' and 12 or splittedScore[i]))
	end
	if #splittedScore ~= oldScore[1] then for i = 1,oldScore[1] do if i > #splittedScore and luaSpriteExists('scoreNum'..i) then removeLuaSprite('scoreNum'..i) end end end
	oldScore[1] = #splittedScore

	--misses
	local splittedMisses = splitShit(misses)
	for i = 1,math.max(#splittedMisses, 1) do
		local tag = 'missesNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedMisses[i], 308 - ((i - 1) * 24), getProperty('missesText.y'), true) end
		setProperty(tag..'.animation.curAnim.curFrame', splittedMisses[i])
	end
	if #splittedMisses ~= oldScore[2] then for i = 1,oldScore[2] do if i > #splittedMisses and luaSpriteExists('missesNum'..i) then removeLuaSprite('missesNum'..i) end end end
	oldScore[2] = #splittedMisses
end

local oldTime = ''
function onUpdatePost()
	if not inGameOver then
		--time
		local daTime = formatTime(bound(getSongPosition() - noteOffset, 0, songLength))
		if oldTime ~= daTime then
			local splittedTime = splitShit(daTime, false)
			for i = 1,math.max(#splittedTime, 1) do
				local tag = 'timeNum'..i
				if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedTime[i], 164 + ((i - 1) * 24), getProperty('timeText.y'), true) end
				setProperty(tag..'.animation.curAnim.curFrame', (splittedTime[i] == ':' and 10 or (splittedTime[i] == ';' and 11 or splittedTime[i])))
			end
			oldTime = daTime
		end
	end
end

function makeHUDSprite(tag, path, x, y, num)
	makeLuaSprite(tag, (num and 'pixelUI/numbers' or ('pixelUI/'..path)), x or 0, y or 0)
	if num then
		loadGraphic(tag, 'pixelUI/numbers', 120 / 12, 11)
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', tonumber(path))
	end
	scaleObject(tag, 3, 3)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
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