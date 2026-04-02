
local CutsceneBG = {
	{name = 'bg3', path = 'fate/cutscene/3', x = -3450, y = -1500, scaleX = 5, scaleY = 5, antialiasing = false, alpha = 1, front = false},
	{name = 'bg2', path = 'fate/cutscene/2', x = -3450, y = -1500, scaleX = 5, scaleY = 5, antialiasing = false, alpha = 1, front = false},
	{name = 'bg1', path = 'fate/cutscene/1', x = -3450, y = -1500, scaleX = 5, scaleY = 5, antialiasing = false, alpha = 1, front = false},
}

local lordxCount = 5
local centerX = 1220
local centerY = 1140
local jumpHeight = 70
local bounceDuration = 0.2
local fallDuration = 0.15
local elapsed = 0
local started = false
local fading = false
local fadeTimer = 0.2
local fadeDuration = 0.6

local circles = {
	{radius = 250, layer = 'bg3', scl = 0.4, fallDist = 160},
	{radius = 390, layer = 'bg2', scl = 0.4, fallDist = 110},
	{radius = 480, layer = 'bg1', scl = 0.6, fallDist = 120},
}

local lordxData = {}

local function isAngleOccupied(angle)
	for j = 0, lordxCount - 1 do
		local other = lordxData[j]
		if other and other.alive then
			local angleDiff = math.abs(angle - other.angle)
			if angleDiff > math.pi then angleDiff = 2 * math.pi - angleDiff end
			if angleDiff < 0.6 then
				return true
			end
		end
	end
	return false
end

local function spawnLordX(i)
	if fading then return end

	local angle
	local circle
	local attempts = 0

	repeat
		angle = math.random() * math.pi * 2
		circle = circles[math.random(1, #circles)]
		attempts = attempts + 1
		if not isAngleOccupied(angle) or attempts > 30 then break end
	until false

	lordxData[i] = {
		angle = angle,
		radius = circle.radius,
		layer = circle.layer,
		scl = circle.scl,
		fallDist = circle.fallDist,
		alive = true,
		progress = 0,
		phase = 'bounce',
		fallProgress = 0,
	}

	local tag = 'lordx' .. i
	local x = centerX + math.cos(angle) * circle.radius
	local y = centerY + math.sin(angle) * circle.radius

	setProperty(tag .. '.x', x)
	setProperty(tag .. '.y', y)
	setProperty(tag .. '.alpha', 1)
	setProperty(tag .. '.flipY', true)
	setProperty(tag .. '.angle', math.deg(angle) + 90)
	scaleObject(tag, circle.scl, circle.scl)
	objectPlayAnimation(tag, 'idle', true)

	setObjectOrder(tag, getObjectOrder(circle.layer) + 1)
end

function onCreate()
	for _, bg in ipairs(CutsceneBG) do
		makeLuaSprite(bg.name, bg.path, bg.x, bg.y)
		scaleObject(bg.name, bg.scaleX, bg.scaleY)
		setProperty(bg.name ..'.antialiasing', bg.antialiasing)
		setProperty(bg.name ..'.alpha', 0)
		addLuaSprite(bg.name, bg.front)
	end

	for i = 0, lordxCount - 1 do
		local tag = 'lordx' .. i
		makeAnimatedLuaSprite(tag, 'fate/cutscene/FATELORDX', 0, 0)
		addAnimationByPrefix(tag, 'idle', 'idle instancia 1', 24, false)
		scaleObject(tag, 1.5, 1.5)
		setProperty(tag ..'.antialiasing', false)
		setProperty(tag ..'.alpha', 0)
		addLuaSprite(tag, false)
	end

	for i = 0, lordxCount - 1 do
		lordxData[i] = {
			angle = 0, radius = 0, layer = 'bg3', scl = 0.5,
			alive = false, timer = math.random() * 1.5,
			progress = 0, phase = 'bounce', fallProgress = 0,
		}
	end
end

function onEvent(e, v1, v2)
	if e == 'fateEvents' then
		if v1 == 'moveCircle'  then
			if v2 == '' then
				for no , circle in ipairs(CutsceneBG) do
					doTweenScale(circle.name, circle.name, 1.2, 1.2 + (no * 0.6), 'circOut')
					setProperty(circle.name ..'.alpha', circle.alpha)
				end
			elseif v2 == 'start' then
				started = true
			elseif v2 == 'eat' then
				for no , circle in ipairs(CutsceneBG) do
					doTweenScale(circle.name, circle.name, 5, 1.2 + (no * 0.6), 'smootherStepIn')
				end
			elseif v2 == 'remove' then
				started = false
				fading = true
				for _,circle in ipairs(CutsceneBG) do
					removeLuaSprite(circle.name, true)
				end
			end
		end
	end
end

function doTweenScale(tag, obj, target, time, ease)
	doTweenX(tag..'scaleX', obj..'.scale', target, time, ease)
	doTweenY(tag..'scaleY', obj..'.scale', target, time, ease)
end

function onUpdatePost(dt)
	if not started then return end

	if fading then
		fadeTimer = fadeTimer + dt
		local alpha = 1 - (fadeTimer / fadeDuration)
		if alpha < 0 then alpha = 0 end

		for _, bg in ipairs(CutsceneBG) do
			setProperty(bg.name ..'.alpha', alpha)
		end
		for i = 0, lordxCount - 1 do
			local data = lordxData[i]
			if data.alive then
				setProperty('lordx' .. i .. '.alpha', alpha)
			end
		end

		if alpha <= 0 then
			started = false
			return
		end
	end

	elapsed = elapsed + dt

	for i = 0, lordxCount - 1 do
		local data = lordxData[i]
		local tag = 'lordx' .. i

		if not data.alive then
			if not data.timer then data.timer = 1 end
			data.timer = data.timer - dt
			if data.timer <= 0 then
				spawnLordX(i)
			end
		else
			local baseX = centerX + math.cos(data.angle) * data.radius
			local baseY = centerY + math.sin(data.angle) * data.radius
			local dirX = math.cos(data.angle)
			local dirY = math.sin(data.angle)

			if data.phase == 'bounce' then
				data.progress = data.progress + dt / bounceDuration

				local t = data.progress
				if t > 1 then t = 1 end

				local bounce = math.sin(t * math.pi) * jumpHeight
				if t > 0.75 then
					local rb = (t - 0.75) / 0.25
					bounce = bounce + math.sin(rb * math.pi) * (jumpHeight * 0.15)
				end

				local x = baseX - dirX * bounce
				local y = baseY - dirY * bounce

				setProperty(tag .. '.x', x)
				setProperty(tag .. '.y', y)

				if data.progress >= 1 then
					data.phase = 'fall'
					data.fallProgress = 0
				end

			elseif data.phase == 'fall' then
				data.fallProgress = data.fallProgress + dt / fallDuration

				local t = data.fallProgress
				if t > 1 then t = 1 end

				local eased
				if t < 0.5 then
					eased = 2 * t * t
				else
					eased = 1 - (-2 * t + 2) * (-2 * t + 2) / 2
				end
				local offset = eased * data.fallDist

				local x = baseX + dirX * offset
				local y = baseY + dirY * offset

				setProperty(tag .. '.x', x)
				setProperty(tag .. '.y', y)

				if data.fallProgress >= 1 then
					setProperty(tag .. '.alpha', 0)
					data.alive = false
					data.phase = 'bounce'
					data.timer = math.random() * 1.0 + 0.2
				end
			end
		end
	end
end
