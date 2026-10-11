local function killMainHUD()
	callMethod('healthBar.kill')
	callMethod('iconP1.kill')
	callMethod('iconP2.kill')
	callMethod('scoreTxt.kill')
end

local rings = 10
setVar('rings', rings)
local postCreate = false
function onCreatePost()
	postCreate = true
	for i = 0,3 do setProperty('opponentStrums.members['..i..'].x', -3000) end
	killMainHUD()

	--sonic hud

	makeHUDSprite('scoreText', 'score', 20)
	makeHUDSprite('timeText', 'time', 20)
	makeHUDSprite('ringsText', 'rings-normal', 20) makeHUDSprite('ringsText-alt', 'rings-alt', 20) setProperty('ringsText-alt.visible', false)

	initialY = 6 * 3
	setProperty('scoreText.y', downscroll and initialY or (screenHeight - getProperty('scoreText.height') - initialY - ((getProperty('scoreText.height') * 2) + initialY)))
	setProperty('timeText.y', downscroll and (initialY + (getProperty('timeText.height') + (initialY / 2))) or (screenHeight - getProperty('timeText.height') - initialY - (getProperty('timeText.height') + (initialY / 2))))
	setProperty('ringsText.y', downscroll and (initialY + ((getProperty('ringsText.height') * 2) + initialY)) or (screenHeight - getProperty('ringsText.height') - initialY))
	setProperty('ringsText-alt.y', getProperty('ringsText.y'))

	updateHUD()
	updateRings()

	--lives from the minigame

	local lives = getVar('preyLives') or 0
	if lives > 0 then
		local livesY = downscroll and (screenHeight - 72) or 18
		makeLuaSprite('livesIcon', 'minigame/preymini/hud/life/lifecounter', 48, livesY)
		scaleObject('livesIcon', 3, 3)
		setObjectCamera('livesIcon', 'hud')
		setProperty('livesIcon.antialiasing', false)
		setProperty('livesIcon.moves', false)
		addLuaSprite('livesIcon')

		local digits = splitShit(math.min(lives, 99), false)
		for i = 1,#digits do makeHUDSprite('livesNum'..i, digits[i], 123 + ((i - 1) * 24), livesY + 15, true) end
	end

	--intro card

	makeHUDSprite('cardBar', 'card/cardBar')
	setProperty('cardBar.y', -getProperty('cardBar.height'))
	screenCenter('cardBar', 'x')
	setObjectCamera('cardBar', 'other')

	makeHUDSprite('cardText', 'card/cardText', screenWidth, 72 * 3)
	setObjectCamera('cardText', 'other')
end

function onUpdateScore() if postCreate then updateHUD() end end

local oldScore = {0, 0, 0, 0}
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
end

function updateRings()
	local splittedRings = splitShit(getVar('rings'))
	for i = 1,math.max(#splittedRings, 1) do
		local tag = 'ringsNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedRings[i], 308 - ((i - 1) * 24), getProperty('ringsText.y'), true) end
		setProperty(tag..'.animation.curAnim.curFrame', splittedRings[i])
	end
	if #splittedRings ~= oldScore[2] then for i = 1,oldScore[2] do if i > #splittedRings and luaSpriteExists('ringsNum'..i) then removeLuaSprite('ringsNum'..i) end end end
	oldScore[2] = #splittedRings

	setProperty('ringsText-alt.visible', (getVar('rings') == 0 and true or false))
	setProperty('ringsText.visible', (getVar('rings') == 0 and false or true))
end

local oldTime = ''
function onUpdatePost()
	if not inGameOver then
		setHealth(2)
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
	makeLuaSprite(tag, (num and 'ui/numbers' or ('ui/'..path)), x or 0, y or 0)
	if num then
		loadGraphic(tag, 'ui/numbers', 98 / 14, 11)
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', tonumber(path))
	end
	scaleObject(tag, 3, 3)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	setProperty(tag..'.moves', false)
	addLuaSprite(tag)
end

function onBeatHit()
	if curBeat == 64 then
		doTweenY('cardBar', 'cardBar', 0, (crochet / 1000) * playbackRate)
		doTweenX('cardText', 'cardText', getProperty('cardBar.x') + (8 * 3), (crochet / 1000 * playbackRate) * 1.1)
		runTimer('endIntroCard', crochet / (1000 / 6) / playbackRate)
	end

	if getVar('rings') == 0 then
		setProperty('ringsText-alt.visible', curBeat % 2 == 0)
		setProperty('ringsText.visible', curBeat % 2 == 1)
	end
end

function onEvent(n,v1)
	if n == 'preyEvent' and songPath == 'prey' then
		if v1 == 'starvedappears' then
			setHealth(1)
			updateHUD()
		end
	end
end

function onTimerCompleted(t)
	if t == 'endIntroCard' then
		doTweenY('cardBar', 'cardBar', -getProperty('cardBar.height'), ((crochet / 1000) * playbackRate) * 0.5)
		doTweenX('cardText', 'cardText', screenWidth, ((crochet / 1000 * playbackRate) * 1.1) * 0.5)
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000)
	return string.format('%01d:%02d;%02d', (s/60)%60, s%60, (math.floor(ms/10))%100)
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