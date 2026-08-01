local postCreate = false
function onCreatePost()
	postCreate = true

	--sonic hud

	makeHUDSprite('HUD', 'HUD', 20)

	initialY = 6 * 3
	local iconOffset = 75 * 0.5
	createInstance('iconSonic', 'objects.HealthIcon', {'bfburning', false})
	setObjectCamera('iconSonic', 'hud')
	setProperty('iconSonic.antialiasing', false)
	scaleObject('iconSonic', 0.5, 0.5)
	callMethod('iconSonic.setPosition', {-iconOffset + initialY, -iconOffset + (downscroll and (-initialY + (screenHeight - 75)) or initialY)})
	addInstance('iconSonic')
	makeHUDSprite('futureHealthSonic', 'healthFuture', getProperty('iconSonic.x') + iconOffset + 72, getProperty('iconSonic.y') + iconOffset + 18)

	createInstance('iconFurn', 'objects.HealthIcon', {'burning', false})
	setObjectCamera('iconFurn', 'hud')
	setProperty('iconFurn.antialiasing', false)
	scaleObject('iconFurn', 0.5, 0.5)
	callMethod('iconFurn.setPosition', {-iconOffset + initialY, -iconOffset + (downscroll and (-(initialY / 2) + (screenHeight - 75) - (75 + (initialY / 2))) or initialY)})
	addInstance('iconFurn')
	makeHUDSprite('futureHealthFurn', 'healthFuture', getProperty('iconFurn.x') + iconOffset + 72, getProperty('iconFurn.y') + iconOffset + 18)

	updateHUD()
end

function onUpdateScore() if postCreate then updateHUD() end end

local oldScore = {0, 0, 0, 0}
function updateHUD()
	--score
	local splittedScore = splitShit(score)
	for i = 1,math.max(#splittedScore, 1) do
		local tag = 'scoreNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedScore[i], 308 - ((i - 1) * 24), getProperty('HUD.y') + (4 * 3), true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedScore[i] == '-' and 12 or splittedScore[i]))
	end
	if #splittedScore ~= oldScore[1] then for i = 1,oldScore[1] do if i > #splittedScore and luaSpriteExists('scoreNum'..i) then removeLuaSprite('scoreNum'..i) end end end
	oldScore[1] = #splittedScore

	--misses
	local splittedMisses = splitShit(misses)
	for i = 1,math.max(#splittedMisses, 1) do
		local tag = 'missesNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedMisses[i], 308 - ((i - 1) * 24), getProperty('HUD.y') + (34 * 3), true) end
		setProperty(tag..'.animation.curAnim.curFrame', splittedMisses[i])
	end
	if #splittedMisses ~= oldScore[2] then for i = 1,oldScore[2] do if i > #splittedMisses and luaSpriteExists('missesNum'..i) then removeLuaSprite('missesNum'..i) end end end
	oldScore[2] = #splittedMisses

	--health player
	local splittedHealth = splitShit(tostring(math.floor(bound(getHealth() * 50, 0, 100)))..'%', false)
	for i = 1,math.max(#splittedHealth, 1) do
		local tag = 'healthNum'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealth[i], 117 + ((i - 1) * 24), getProperty('futureHealthSonic.y') + 15, true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedHealth[i] == '-' and 12 or (splittedHealth[i] == '%' and 13 or splittedHealth[i])))
	end
	if #splittedHealth ~= oldScore[3] then for i = 1,oldScore[3] do if i > #splittedHealth and luaSpriteExists('healthNum'..i) then removeLuaSprite('healthNum'..i) end end end
	oldScore[3] = #splittedHealth

	--health opp
	local splittedHealthOpp = splitShit(tostring(math.floor(bound((2 - getHealth()) * 50, 0, 100) + 0.5))..'%', false)
	for i = 1,math.max(#splittedHealthOpp, 1) do
		local tag = 'health2Num'..i
		if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedHealthOpp[i], 117 + ((i - 1) * 24), getProperty('futureHealthFurn.y') + 15, true) end
		setProperty(tag..'.animation.curAnim.curFrame', (splittedHealthOpp[i] == '-' and 12 or (splittedHealthOpp[i] == '%' and 13 or splittedHealthOpp[i])))
	end
	if #splittedHealthOpp ~= oldScore[4] then for i = 1,oldScore[4] do if i > #splittedHealthOpp and luaSpriteExists('health2Num'..i) then removeLuaSprite('health2Num'..i) end end end
	oldScore[4] = #splittedHealthOpp

	setProperty('iconSonic.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconFurn.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
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
				if not luaSpriteExists(tag) then makeHUDSprite(tag, splittedTime[i], 164 + ((i - 1) * 24), getProperty('HUD.y') + (19 * 3), true) end
				setProperty(tag..'.animation.curAnim.curFrame', (splittedTime[i] == ':' and 10 or (splittedTime[i] == ';' and 11 or splittedTime[i])))
			end
			oldTime = daTime
		end
	end
end

function makeHUDSprite(tag, path, x, y, num)
	makeLuaSprite(tag, (num and 'pixelUI/numbers' or ('pixelUI/'..path)), x or 0, y or 0)
	if num then
		loadGraphic(tag, 'pixelUI/numbers', 98 / 14, 11)
		addAnimation(tag, 'danums', {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, 0, false)
		setProperty(tag..'.animation.curAnim.curFrame', tonumber(path))
	end
	scaleObject(tag, 3, 3)
	setObjectCamera(tag, 'hud')
	setProperty(tag..'.antialiasing', false)
	setProperty(tag..'.moves', false)
	addLuaSprite(tag)
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