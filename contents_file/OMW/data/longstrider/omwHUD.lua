local function killMainHUD()
	callMethod('healthBar.kill')
	callMethod('iconP1.kill')
	callMethod('iconP2.kill')
	callMethod('scoreTxt.kill')
end

local postCreate = false
function onCreatePost()
	postCreate = true
	if not middlescroll then for i = 0,3 do setProperty('playerStrums.members['..i..'].x', _G['defaultOpponentStrumX'..i]) setProperty('opponentStrums.members['..i..'].x', -2000) end end
	killMainHUD()

	--sonic hud

	makeHUDSprite('scoreText', 'score', 20)
	makeHUDSprite('timeText', 'time', 20)
	makeHUDSprite('missesText', 'misses-normal', 20) makeHUDSprite('missesText-alt', 'misses-alt', 20) setProperty('missesText-alt.visible', false)

	initialY = 6 * 3
	setProperty('scoreText.y', downscroll and initialY or (screenHeight - getProperty('scoreText.height') - initialY - ((getProperty('scoreText.height') * 2) + initialY)))
	setProperty('timeText.y', downscroll and (initialY + (getProperty('timeText.height') + (initialY / 2))) or (screenHeight - getProperty('timeText.height') - initialY - (getProperty('timeText.height') + (initialY / 2))))
	setProperty('missesText.y', downscroll and (initialY + ((getProperty('missesText.height') * 2) + initialY)) or (screenHeight - getProperty('missesText.height') - initialY))
	setProperty('missesText-alt.y', getProperty('missesText.y'))

	makeHUDSprite('healthbaromw', 'healthbar')
	setProperty('healthbaromw.x', screenWidth - getProperty('healthbaromw.width') - 50)
	setProperty('healthbaromw.y', downscroll and 0 or (screenHeight - getProperty('healthbaromw.height')))

	makeLuaSprite('hbHealth', nil, 0, getProperty('healthbaromw.y') + (29 * 3))
    setObjectCamera('hbHealth', 'hud')
    makeGraphic('hbHealth', (160 * 3), (7 * 3) + 1, 'FFFFFF')
    setProperty('hbHealth.x', getProperty('healthbaromw.x') + (19 * 3))

    makeLuaSprite('hbHealth2', nil, 0, getProperty('healthbaromw.y') + (29 * 3))
    setObjectCamera('hbHealth2', 'hud')
    makeGraphic('hbHealth2', (160 * 3) / 2, (7 * 3) + 1, 'FFFFFF')
    setProperty('hbHealth2.x', getProperty('healthbaromw.x') + (19 * 3))

    makeLuaSprite('separatorHealth', nil, 0, getProperty('healthbaromw.y') + (29 * 3))
    makeGraphic('separatorHealth', 4, (7 * 3) + 1, 'FFFFFF')
    setObjectCamera('separatorHealth', 'hud')

    createInstance('iconBF', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), true})
    setObjectCamera('iconBF', 'hud')
    scaleObject('iconBF', 1, 1, false)

    createInstance('iconOpp', 'objects.HealthIcon', {getProperty('dad.healthIcon'), false})
    setObjectCamera('iconOpp', 'hud')
    scaleObject('iconOpp', 1, 1, false)

	setProperty('hbHealth.color', getColorFromHex(getHealthColor('boyfriend')))
    setProperty('hbHealth2.color', getColorFromHex(getHealthColor('dad')))

    addLuaSprite('hbHealth')
    addLuaSprite('hbHealth2')
    addLuaSprite('separatorHealth')
	setObjectOrder('healthbaromw', getObjectOrder('separatorHealth'))
    addInstance('iconBF')
    addInstance('iconOpp')

	updateHUD()

	--intro card

	makeHUDSprite('cardBar', 'card/cardBar')
	setProperty('cardBar.y', -getProperty('cardBar.height'))
	screenCenter('cardBar', 'x')
	setObjectCamera('cardBar', 'other')

	makeHUDSprite('cardText', 'card/cardText', screenWidth, 72 * 3)
	setObjectCamera('cardText', 'other')
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
function onUpdatePost(e)
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

	setProperty('iconOpp.x', getProperty('healthbaromw.x') + (19 * 3) - 75)
    setProperty('iconOpp.y', getProperty('healthbaromw.y') + (29 * 3) + ((7 * 3) / 2) - 75)
    setProperty('iconBF.x', getProperty('healthbaromw.x') + (19 * 3) + (160 * 3) - 75)
    setProperty('iconBF.y', getProperty('healthbaromw.y') + (29 * 3) + ((7 * 3) / 2) - 75)

    setGraphicSize('hbHealth2', bound(lerp((160 * 3), 1, getHealth() / 2), 1, (160 * 3)), (7 * 3) + 1)
    setProperty('separatorHealth.x', getProperty('hbHealth.x') + bound(lerp(getProperty('hbHealth.width') - 4, 0, getHealth() / 2), 0, getProperty('hbHealth.width') - 4))

    setProperty('iconBF.animation.curAnim.curFrame', getHealth() < 0.4 and 1 or 0)
	setProperty('iconOpp.animation.curAnim.curFrame', getHealth() > 1.6 and 1 or 0)
    local mult = lerp(1, getProperty('iconOpp.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconOpp', mult, mult, false)
    local mult = lerp(1, getProperty('iconBF.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconBF', mult, mult, false)
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
	addLuaSprite(tag)
end

function onBeatHit()
	scaleObject('iconBF', 1.2, 1.2, false)
    scaleObject('iconOpp', 1.2, 1.2, false)

	if curBeat == 36 then
		doTweenY('cardBar', 'cardBar', 0, (crochet / 1000) * playbackRate)
		doTweenX('cardText', 'cardText', getProperty('cardBar.x') + (8 * 3), (crochet / 1000 * playbackRate) * 1.1)
		runTimer('endIntroCard', crochet / (1000 / 6) / playbackRate)
	end

	if misses >= 1 then
		setProperty('missesText.visible', curBeat % 2 == 0)
		setProperty('missesText-alt.visible', curBeat % 2 == 1)
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
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

function getHealthColor(arg)
	return string.format("%02x%02x%02x", math.floor(getProperty(arg..'.healthColorArray[0]')), math.floor(getProperty(arg..'.healthColorArray[1]')), math.floor(getProperty(arg..'.healthColorArray[2]')))
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