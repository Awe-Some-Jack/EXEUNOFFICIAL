local nativeToolsDisabled = (buildTarget == 'ios' or buildTarget == 'android')
local isFatalitySong = false
local lastSentSquares = -1

local barImage = 'fatality/healthbar/bar'
local lifeImage = 'fatality/healthbar/life'
local handImage = 'fatality/healthbar/hand'
local barWidth = 462
local barHeight = 50
local lifeWidth = 394
local lifeHeight = 15
local lifeOffsetX = 10
local lifeOffsetY = 29
local squareCount = 22
local barMargin = 24
local handDistance = 140
local handInset = 9
local handSlideTime = 0.45
local minButtonX = 372
local closeButtonX = 390
local buttonY = 4
local barClosed = false
local iconWinImage = 'fatality/healthbar/icon_win'
local iconLoseImage = 'fatality/healthbar/icon_lose'
local iconOffsetX = 419
local iconOffsetY = 12
local losingPercent = 20
local iconLosing = false

local spriteBar = false
local barX = 0
local barY = 0
local hands = {}
local handCount = 0
local edges = {'top', 'bottom', 'left', 'right'}

local function setLifeSquares(squares)
	local clipWidth = math.floor(squares * lifeWidth / squareCount + 0.5)
	runHaxeCode([[
		import flixel.math.FlxRect;
		var life = game.getLuaObject('fatalLife');
		if (life != null) life.clipRect = new FlxRect(0, 0, ]]..clipWidth..[[, ]]..lifeHeight..[[);
	]])
end

local function overlapsPopupCam(tag)
	return callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(tag), instanceArg('barCam')})
end

local function makeButton(tag, image, x, y)
	makeLuaSprite(tag, image, x, y)
	loadGraphic(tag, image, 15, 15)
	addAnimation(tag, 'up', {0}, 1, false)
	addAnimation(tag, 'down', {1}, 1, false)
	playAnim(tag, 'up', true)
	setProperty(tag..'.x', x)
	setProperty(tag..'.y', y)
	setObjectCamera(tag, 'barCam')
	setProperty(tag..'.antialiasing', false)
	addLuaSprite(tag, true)
end

local function buildSpriteBar()
	barX = (screenWidth - barWidth) / 2
	barY = barMargin

	makeLuaSprite('fatalBar', barImage, barX, barY)
	setObjectCamera('fatalBar', 'barCam')
	setProperty('fatalBar.antialiasing', false)
	addLuaSprite('fatalBar', true)

	makeLuaSprite('fatalLife', lifeImage, barX + lifeOffsetX, barY + lifeOffsetY)
	setObjectCamera('fatalLife', 'barCam')
	setProperty('fatalLife.antialiasing', false)
	addLuaSprite('fatalLife', true)
	setLifeSquares(squareCount)

	makeLuaSprite('fatalIconWin', iconWinImage, barX + iconOffsetX, barY + iconOffsetY)
	setObjectCamera('fatalIconWin', 'barCam')
	setProperty('fatalIconWin.antialiasing', false)
	addLuaSprite('fatalIconWin', true)

	makeLuaSprite('fatalIconLose', iconLoseImage, barX + iconOffsetX, barY + iconOffsetY)
	setObjectCamera('fatalIconLose', 'barCam')
	setProperty('fatalIconLose.antialiasing', false)
	setProperty('fatalIconLose.visible', false)
	addLuaSprite('fatalIconLose', true)

	makeButton('fatalMinButton', 'fatality/healthbar/MButton', barX + minButtonX, barY + buttonY)
	makeButton('fatalCloseButton', 'fatality/healthbar/XButton', barX + closeButtonX, barY + buttonY)

	setProperty('healthBar.visible', false)
	setProperty('healthBarBG.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	spriteBar = true
end

local function closeSpriteBar()
	barClosed = true
	for _, tag in ipairs({'fatalBar', 'fatalLife', 'fatalIconWin', 'fatalIconLose', 'fatalMinButton', 'fatalCloseButton'}) do
		setProperty(tag..'.visible', false)
	end
end

local function updateButtons()
	for _, tag in ipairs({'fatalMinButton', 'fatalCloseButton'}) do
		local over = overlapsPopupCam(tag)
		playAnim(tag, (over and mousePressed()) and 'down' or 'up', true)
		if over and mouseReleased() then
			closeSpriteBar()
			return
		end
	end
end

local function handTarget(edge, position)
	local boxX = getProperty('fatalBoxX')
	local boxY = getProperty('fatalBoxY')
	local boxW = getProperty('fatalBoxW')
	local boxH = getProperty('fatalBoxH')
	if edge == 'top' then return boxX + position * boxW, boxY, 0 end
	if edge == 'bottom' then return boxX + position * boxW, boxY + boxH, 180 end
	if edge == 'left' then return boxX, boxY + position * boxH, 270 end
	return boxX + boxW, boxY + position * boxH, 90
end

local function outwardOffset(edge, distance)
	if edge == 'top' then return 0, -distance end
	if edge == 'bottom' then return 0, distance end
	if edge == 'left' then return -distance, 0 end
	return distance, 0
end

local function spawnHand(edge, position)
	if edge == 'random' then edge = edges[getRandomInt(1, #edges)] end
	if position == nil then position = getRandomFloat(0.1, 0.9) end

	handCount = handCount + 1
	local tag = 'fatalHand'..handCount
	local targetX, targetY, angle = handTarget(edge, position)
	local outX, outY = outwardOffset(edge, -handInset)
	local awayX, awayY = outwardOffset(edge, handDistance)

	makeAnimatedLuaSprite(tag, handImage, 0, 0)
	addAnimationByPrefix(tag, 'up', 'hand up', 12, false)
	addAnimationByPrefix(tag, 'grab', 'hand grab ', 8, false)
	playAnim(tag, 'up', true)
	setObjectCamera(tag, 'handCam')
	setProperty(tag..'.antialiasing', false)
	setProperty(tag..'.angle', angle)
	addLuaSprite(tag, true)

	hands[#hands + 1] = {
		tag = tag,
		x = targetX + outX - getProperty(tag..'.width') / 2,
		y = targetY + outY - getProperty(tag..'.height') / 2,
		awayX = awayX,
		awayY = awayY,
		phase = 'in',
		time = 0
	}
end

local function releaseHands()
	for i = 1, #hands do
		hands[i].phase = 'out'
		hands[i].time = 0
	end
end

local function updateHands(elapsed)
	local dx = getProperty('camGame.x') - getProperty('fatalCamBaseX')
	local dy = getProperty('camGame.y') - getProperty('fatalCamBaseY')
	for i = #hands, 1, -1 do
		local hand = hands[i]
		hand.time = hand.time + elapsed
		local away = 0
		if hand.phase == 'in' then
			local t = math.min(1, hand.time / handSlideTime)
			away = 1 - (1 - (1 - t) * (1 - t))
			if t >= 1 then
				hand.phase = 'held'
				playAnim(hand.tag, 'grab', true)
			end
		elseif hand.phase == 'out' then
			local t = math.min(1, hand.time / handSlideTime)
			away = t * t
			if t >= 1 then
				removeLuaSprite(hand.tag, true)
				table.remove(hands, i)
				hand = nil
			end
		end
		if hand ~= nil then
			setProperty(hand.tag..'.x', hand.x + dx + hand.awayX * away)
			setProperty(hand.tag..'.y', hand.y + dy + hand.awayY * away)
		end
	end
end

local function splitList(text)
	if text == nil or text == '' then return {} end
	local parts = stringSplit(text, ',')
	for i = 1, #parts do parts[i] = stringTrim(parts[i]) end
	return parts
end

function onEvent(name, value1, value2)
	if not isFatalitySong or not nativeToolsDisabled then return end

	if name == 'FatalityFlashin' and value1 == 'flash' and not spriteBar then
		buildSpriteBar()
		return
	end

	if not spriteBar or name ~= 'Fatal Hand' then return end

	local command = stringTrim(string.lower(value1 or ''))
	if command == 'release' or command == 'soltar' then
		releaseHands()
		return
	end

	local edgeList = splitList(command)
	local positionList = splitList(value2)
	for i = 1, #edgeList do
		local position = tonumber(positionList[math.min(i, #positionList)])
		spawnHand(edgeList[i], position)
	end
end

function onCreatePost()
	isFatalitySong = (songName == 'Fatality' or songName:lower() == 'fatality')
	lastSentSquares = -1
	if not isFatalitySong then return end
	setProperty('healthBar.visible', false)
	setProperty('healthBarBG.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	if nativeToolsDisabled then return end

	runTimer('fatalHealthBarInit', 0.15)
end

function onTimerCompleted(tag)
	if tag ~= 'fatalHealthBarInit' then return end
	if not isFatalitySong then return end

	setPropertyFromClass('openfl.Lib', 'application.window.borderless', true)

	setProperty('healthBar.visible', false)
	setProperty('healthBarBG.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)

	runHaxeCode([[
		var processClass = Type.resolveClass('backend.LineProcess');
		if (processClass != null) {
			try {
				var exeName = switch (Sys.systemName()) {
					case 'Windows': 'HealthBar.exe';
					case 'Mac': 'HealthBar-mac';
					default: 'HealthBar-linux';
				}
				var noArgs:Array<String> = [];
				var proc = Type.createInstance(processClass, ['contents/FATAL/tools/' + exeName, noArgs, false]);
				setVar('healthBarProcess', proc);
			} catch (e:Dynamic) {
			}
		}
	]]);

	-- callMethodFromClass('openfl.Lib', 'application.window.focus', {})
end

local function closeHealthBar()
	setPropertyFromClass('openfl.Lib', 'application.window.borderless', false)

	setProperty('healthBar.visible', not hideHud)
	setProperty('healthBarBG.visible', not hideHud)
	setProperty('iconP1.visible', not hideHud)
	setProperty('iconP2.visible', not hideHud)

	runHaxeCode([[
		var proc = getVar('healthBarProcess');
		if (proc != null) {
			try {
				proc.stdin.writeString('close\n');
				proc.stdin.flush();
			} catch (e:Dynamic) {
			}
			setVar('healthBarProcess', null);
		}
	]]);
end

function onStepHit()
	if not isFatalitySong then return end

	-- callMethodFromClass('openfl.Lib', 'application.window.focus', {})

	if curStep == 255 then
		runHaxeCode([[
			var proc = getVar('healthBarProcess');
			if (proc != null) {
				try {
					proc.stdin.writeString('slide\n');
					proc.stdin.flush();
				} catch (e:Dynamic) {
				}
			}
		]]);
	end
end

function onUpdatePost(elapsed)
	if not isFatalitySong then return end

	if spriteBar then
		updateHands(elapsed)
		if barClosed then return end
		updateButtons()
		local barHealth = getProperty('health')
		if barHealth == nil then return end
		local barPercent = math.max(0, math.min(100, (barHealth / 2) * 100))
		local losing = barPercent < losingPercent
		if losing ~= iconLosing then
			iconLosing = losing
			setProperty('fatalIconWin.visible', not losing)
			setProperty('fatalIconLose.visible', losing)
		end
		local barSquares = math.floor((barPercent / 100) * squareCount + 0.5)
		if barSquares ~= lastSentSquares then
			lastSentSquares = barSquares
			setLifeSquares(barSquares)
		end
		return
	end

	local currentHealth = getProperty('health')
	if currentHealth == nil then return end

	local healthPercent = (currentHealth / 2) * 100
	if healthPercent < 0 then healthPercent = 0 end
	if healthPercent > 100 then healthPercent = 100 end

	local squares = math.floor((healthPercent / 100) * 22 + 0.5)
	if squares == lastSentSquares then return end
	lastSentSquares = squares

	runHaxeCode('var proc = getVar("healthBarProcess"); if (proc != null) { try { proc.stdin.writeString("health:' .. healthPercent .. '\\n"); proc.stdin.flush(); } catch (e:Dynamic) {} }')
end

function onEndSong()
	cancelTimer('fatalHealthBarInit')
	if isFatalitySong then closeHealthBar() end
	return Function_Continue
end

function onGameOver()
	cancelTimer('fatalHealthBarInit')
	if isFatalitySong then closeHealthBar() end
	return Function_Continue
end

function onDestroy()
	cancelTimer('fatalHealthBarInit')
	if isFatalitySong then closeHealthBar() end
end
