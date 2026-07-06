local speakerBeatInterval = 2
local colors = {'ff2323', '4dff23', '2332ff', 'ff2483', 'ffbd24', '24ffc1'}

local function getColor()
	return colors[(curSection % 6) + 1]
end

local function applyColorTheme()
	local c = getColor()
	setProperty('hbBG.color', getColorFromHex(c))
	setProperty('separatorHealth.color', getColorFromHex(c))
	setTextBorder('exeScoreTxt', 1, c)
	setTextBorder('hitCounterText', 2, c)
end

function onCreatePost()
	makeLuaSprite('bg', 'bg/bg', -1200, -800)
	addLuaSprite('bg')

	makeLuaSprite('floor', 'bg/floor', -650, -650)
	scaleObject('floor', 0.9, 0.9)
	addLuaSprite('floor')

	local speakerData = {
		{name = 'speakerL', x = -150},
		{name = 'speakerR', x = 1300, flipX = true},
	}
	for _, sp in ipairs(speakerData) do
		makeAnimatedLuaSprite(sp.name, 'bg/speaker', sp.x, -260)
		addAnimationByPrefix(sp.name, 'idle', 'dance lol', 24, false)
		scaleObject(sp.name, 0.9, 0.9)
		if sp.flipX then setProperty(sp.name .. '.flipX', true) end
		addLuaSprite(sp.name)
	end

	makeAnimatedLuaSprite('disco', 'bg/disco-ball', 650, -800)
	addAnimationByPrefix('disco', 'idle', 'dance', 24, true)
	addOffset('disco', 'idle', 0, 0)
	addAnimationByPrefix('disco', 'drop', 'drop', 24, false)
	addOffset('disco', 'drop', 290, 335)
	playAnim('disco', 'drop', true)
	setProperty('disco.animation.paused', true)
	addLuaSprite('disco')

	local iconNames = {'cereal', 'milk'}
	for i = 1, 2 do
		makeLuaSprite('secondbg' .. i, 'chocolate/bg/bg' .. i)
		addLuaSprite('secondbg' .. i)
		setScrollFactor('secondbg' .. i, 0, 0)
		setProperty('secondbg' .. i .. '.alpha', 0)

		makeLuaSprite('icon' .. i, 'chocolate/bg/' .. iconNames[i])
		addLuaSprite('icon' .. i)
		setScrollFactor('icon' .. i, 0, 0)
		setProperty('icon' .. i .. '.visible', i == 1)
		setProperty('icon' .. i .. '.alpha', 0)
	end
	setProperty('secondbg2.visible', false)

	makeLuaSprite('floot', 'chocolate/bg/floot', -420, -420)
	scaleObject('floot', 2, 2)
	addLuaSprite('floot')
	setProperty('floot.alpha', 0)

	for i = 0, 3 do
		local strumW = getProperty('opponentStrums.members[' .. i .. '].width')
		setProperty('opponentStrums.members[' .. i .. '].x', 10 + (strumW * i))
		setProperty('playerStrums.members[' .. i .. '].x', (screenWidth - 10 - (strumW * 4)) + (strumW * i))
	end

	applyColorTheme()
end

function onUpdatePost()
	local zoom = getProperty('camGame.zoom')
	local invZoom = 1 / zoom
	local iconScale = 0.7 * invZoom
	for i = 1, 2 do
		scaleObject('secondbg' .. i, invZoom, invZoom)
		callMethod('secondbg' .. i .. '.setPosition', {(screenWidth - getProperty('secondbg' .. i .. '.width')) / 2, (screenHeight - getProperty('secondbg' .. i .. '.height')) / 2})

		scaleObject('icon' .. i, iconScale, iconScale)
		callMethod('icon' .. i .. '.setPosition', {(screenWidth - getProperty('icon' .. i .. '.width')) / 2, (screenHeight - getProperty('icon' .. i .. '.height')) / 2})
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		local newAngle = getProperty('icon2.angle') == 0 and 30 or 0
		setProperty('icon1.angle', newAngle)
		setProperty('icon2.angle', newAngle)
	else
		setProperty('secondbg2.visible', not getProperty('secondbg2.visible'))
		setProperty('icon1.visible', not getProperty('icon1.visible'))
		setProperty('icon2.visible', not getProperty('icon2.visible'))
	end

	if curBeat % speakerBeatInterval == 0 then
		playAnim('speakerL', 'idle', true)
		playAnim('speakerR', 'idle', true)
	end
end

function onSectionHit()
	applyColorTheme()
end
