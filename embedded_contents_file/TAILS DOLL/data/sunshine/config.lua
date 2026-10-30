local intensity = 50
local velocity = 2

local neutrals = {
	bloom = {brightness = 0, contrast = 1, saturation = 1},
}
local function addCameraFilters(camera)
	for _, name in ipairs({'bloom', 'VHS'}) do
		if neutrals[name] then
			for uniform, neutral in pairs(neutrals[name]) do
				addPrunedFilter(camera, name, uniform, neutral)
			end
		else
			addStaticFilter(camera, name)
		end
	end
end

local dadX, dadY = 0, 0
function onCreatePost()
	dadX, dadY = getProperty('dad.x'), getProperty('dad.y')

	if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then
		for i = 0, 3 do
			local strumW = getProperty('opponentStrums.members[' .. i .. '].width')
			setProperty('opponentStrums.members[' .. i .. '].x', 10 + (strumW * i))
			setProperty('playerStrums.members[' .. i .. '].x', (screenWidth - 10 - (strumW * 4)) + (strumW * i))
		end
	end
	if shadersEnabled then
		makeLuaSprite("creepy")
		makeLuaSprite("VHS")
		setSpriteShader("VHS", "tvcrt")

		makeLuaSprite('bloom')
		setSpriteShader('bloom', 'brightness')
		setShaderFloat('bloom', 'brightness', 0)
		setShaderFloat('bloom', 'contrast', 1)
		setShaderFloat('bloom', 'saturation', 1)
	end

	if shadersEnabled then
		addCameraFilters('camGame')
		addCameraFilters('camHUD')
	end
end

local videoFilters = false
local function addVideoFilters()
	if shadersEnabled and not videoFilters then
		videoFilters = true
		addCameraFilters('camVideo')
	end
end

function onGameOverStart()
	addVideoFilters()
end

local canFloat = true
local floatTime = 0
local _sat = 1
local bloomSent = {}
local function sendBloom(uniform, value)
	if bloomSent[uniform] ~= value then
		bloomSent[uniform] = value
		setShaderFloat('bloom', uniform, value)
	end
end
function onUpdate(e)
	floatTime = floatTime + e
	if canFloat then
		callMethod('dad.setPosition', {
			dadX + math.cos(floatTime * (velocity / 2)) * (intensity * 2),
			dadY + math.sin(floatTime * velocity) * intensity
		})
	end

	if shadersEnabled then
		local bloomX, creepyX = getProperty('bloom.x'), getProperty('creepy.x')
		sendBloom('brightness', bloomX * 2)
		sendBloom('contrast', 1 + (bloomX * 4) + (creepyX * 1.25))
		sendBloom('saturation', _sat + (creepyX / 2))
	end
end

function onEvent(n,v1,v2)
	if shadersEnabled then
		if n == 'bright zoom' and flashingLights then
			local divide = v2 == '' and 4 or tonumber(v2)
			local amount = v1 == '' and 0.1 or tonumber(v1)
			cancelTween('bloom')
			setProperty('bloom.x', amount * 3)
			doTweenX('bloom', 'bloom', 0, crochet / (1000 / divide), 'cubeOut')
		end
		if n == 'saturation' then
			_sat = tonumber(v1)
		end
	end
	if n == 'sunshinEvent' then
		if v1 == 'startdark' then
			doTweenX('creepy', 'creepy', 1, crochet / (1000 / 3), 'expoIn')
		end
		if v1 == 'creepy' then
			cancelTween('creepy')
			setProperty('creepy.x', 0)
			canFloat = false
		end
		if v1 == 'back' then canFloat = true end
		if v1 == 'videoend' then addVideoFilters() end
	end
end