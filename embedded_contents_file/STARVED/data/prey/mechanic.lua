local isJumping = false
local canJump = false
local airTime = 0

local isInvulnerable = false
local invulnerableTimer = 0
local INVULN_DURATION = 2.0

local RUSH_LANE = 20

function onCreatePost()
	makeAnimatedLuaSprite('sonic-jump', 'prey/sonic-jump')
	addAnimationByPrefix('sonic-jump', 'jump', 'jump', 24, true)
	scaleObject('sonic-jump', 6, 6)
	setProperty('sonic-jump.antialiasing', false)
	addLuaSprite('sonic-jump', true)
	setObjectOrder('sonic-jump', getObjectOrder('boyfriendGroup') + 1)

	setProperty('sonic-jump.visible', false)

	makeLuaSprite('sonicHitboxFix', nil, 0, 0)
	makeGraphic('sonicHitboxFix', 160, 170, '0000FF')
	setProperty('sonicHitboxFix.alpha', 0)
	addLuaSprite('sonicHitboxFix', true)

	setVar('isJumping', false)

	for _, snd in ipairs({'badnickfast', 'breakbadnik', 'dropbox', 'hit', 'warning'}) do precacheSound('minigame/preymini/'..snd) end
	precacheImage('prey/spike')

	for i = 1, RUSH_LANE do
		local tag = 'rushLane'..i
		makeLuaSprite(tag, 'minigame/preymini/hud/warning/chevron')
		scaleObject(tag, 3, 3)
		setProperty(tag..'.antialiasing', false)
		setProperty(tag..'.flipX', true)
		setObjectCamera(tag, 'other')
		setProperty(tag..'.visible', false)
		addLuaSprite(tag, true)
	end
end

local spikeGroups = {}
local brokenSpikes = {}
local ringGroup = {}
local missedRings = {}
local jumpAmount = 2340
local jumpRelease = 1440
local gravity = 4725
local holdTimer = 0
local triggerOnce = false
local canceledJump = false

local function hurtSonic()
	if getVar('rings') > 0 then
		isInvulnerable = true
		invulnerableTimer = INVULN_DURATION

		for j = 1, getVar('rings') do
			local missedRing = 'missedRing'..j
			makeAnimatedLuaSprite(missedRing, 'prey/ring', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
			addAnimationByPrefix(missedRing, 'idle', 'ring', 8, true)
			scaleObject(missedRing, 6, 6)
			setProperty(missedRing..'.antialiasing', false)
			setProperty(missedRing..'.velocity.x', getRandomInt(-500, 500))
			setProperty(missedRing..'.acceleration.x', getProperty('floorGroup[0].velocity.x'))
			setProperty(missedRing..'.maxVelocity.x', math.abs(getProperty('floorGroup[0].velocity.x')))
			setProperty(missedRing..'.velocity.y', -getRandomInt(1500, 2000))
			setProperty(missedRing..'.acceleration.y', gravity)
			addLuaSprite(missedRing, true)
			table.insert(missedRings, missedRing)
		end
		runTimer('removeMissedRings', 1)

		cameraShake('game', 0.01, 0.1)
		setProperty('sonic-jump.visible', false)

		playSound('hit')
		playSound('loseRings', 0.4)
		setVar('rings', 0)
		callOnScripts('updateRings')
		playAnim('boyfriend', 'hit'..getProperty('boyfriend.idleSuffix'), true)
		setProperty('boyfriend.specialAnim', true)
		triggerOnce = true
		canceledJump = true

		for j = 0, getProperty('notes.length')-1 do
			setProperty('notes.members['..j..'].noAnimation', true)
			setProperty('notes.members['..j..'].noMissAnimation', true)
		end
	else
		playSound('hit')
		setProperty('instakillOnMiss', true)
		callMethod('doDeathCheck', {true})
	end
end

local function autoJump()
	isJumping = true
	setProperty('sonic-jump.visible', true)
	setProperty('boyfriend.alpha', 0)
	playAnim('sonic-jump', 'jump', true)
	playSound('sonicJump')
	setProperty('boyfriend.acceleration.y', gravity)
	setProperty('boyfriend.maxVelocity.y', 5760)
	setProperty('boyfriend.velocity.y', -jumpAmount)
end

local BOX_AT_Y = {38, 38, 37, 36, 37}
local HOOK_BOTTOM = {65, 66, 67, 63, 58}
local badniks = {}
local badnikId = 0
local breakSound = 0

local function sonicCenterX()
	return getProperty('sonicHitboxFix.x') + getProperty('sonicHitboxFix.width') / 2
end

local function floorSpeed()
	return math.abs(getProperty('floorGroup[0].velocity.x'))
end

local function touchesSonic(tag, x0, y0, x1, y1)
	local x, y = getProperty(tag..'.x'), getProperty(tag..'.y')
	local sx, sy = getProperty('sonicHitboxFix.x'), getProperty('sonicHitboxFix.y')
	return sx < x + x1 and sx + getProperty('sonicHitboxFix.width') > x + x0
		and sy < y + y1 and sy + getProperty('sonicHitboxFix.height') > y + y0
end

local function findFloor(start, width, clear)
	for step = 0, 30 do
		local x = start + step * 48
		local surf = callOnHScript('floorSpot', {x, x + width, clear})
		if type(surf) == 'number' and surf > 0 then return x, surf end
	end
	return nil, nil
end

local function badnikBoom(cx, cy)
	badnikId = badnikId + 1
	local tag = 'badnikBoom'..badnikId
	makeAnimatedLuaSprite(tag, 'minigame/preymini/characters/enemys/Explosion', cx - 58 * 6, cy - 60 * 6)
	addAnimationByPrefix(tag, 'boom', 'Explosion', 12.5, false)
	playAnim(tag, 'boom', true)
	scaleObject(tag, 6, 6)
	setProperty(tag..'.antialiasing', false)
	setProperty(tag..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
	addLuaSprite(tag, true)
	runTimer(tag, 0.5)
end

local function spawnAnimal(cx, cy)
	badnikId = badnikId + 1
	local tag = 'burningAnimal'..badnikId
	local name = getRandomBool(50) and 'Animal_Burning' or 'Animal_Burning2'
	makeAnimatedLuaSprite(tag, 'minigame/preymini/characters/enemys/'..name, cx - 25 * 6, cy - 22 * 6)
	addAnimationByPrefix(tag, 'burn', name, 10, true)
	playAnim(tag, 'burn', true)
	scaleObject(tag, 6, 6)
	setProperty(tag..'.antialiasing', false)
	setProperty(tag..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
	setProperty(tag..'.velocity.y', -720)
	setProperty(tag..'.acceleration.y', 4725)
	addLuaSprite(tag, true)
	table.insert(badniks, {kind = 'animal', tag = tag, t = 0, floor = getVar('floorY') + 164})
end

local function killBadnik(tag, cx, cy)
	badnikBoom(cx, cy)
	spawnAnimal(cx, cy)
	playSound('minigame/preymini/breakbadnik', 0.8)
	local vy = getProperty('boyfriend.velocity.y')
	if vy >= 0 then
		if getProperty('sonicHitboxFix.y') + 85 < cy then vy = -vy else vy = vy - 360 end
	else
		vy = vy + 360
	end
	setProperty('boyfriend.velocity.y', vy)
	removeLuaSprite(tag, true)
end

local function showWarning(tag, withSound)
	makeAnimatedLuaSprite(tag, 'prey/warning', 500, (getVar('floorY') - 420))
	scaleObject(tag, 2, 2)
	addAnimationByPrefix(tag, '1', '1', 12, false)
	addAnimationByPrefix(tag, '2', '2', 12, false)
	playAnim(tag, '1', true)
	setProperty(tag..'.antialiasing', false)
	addLuaSprite(tag, true)
	if withSound then playSound('warnin', 0.8) end
	runTimer(tag, crochet / 1000)
end

local function breakSpike(tag)
	setProperty(tag..'.velocity.x', getProperty('floorGroup[0].velocity.x') + getRandomInt(500, 1100))
	setProperty(tag..'.velocity.y', -getRandomInt(900, 1500))
	setProperty(tag..'.acceleration.y', 4000)
	setProperty(tag..'.angularVelocity', getRandomInt(-720, 720))
	setObjectOrder(tag, math.max(getObjectOrder('floorGroup[0]'), getObjectOrder('floorGroup[1]')) + 1)
	if breakSound <= 0 then
		playSound('minigame/preymini/hit', 0.45)
		breakSound = 0.08
	end
	table.insert(brokenSpikes, {tag = tag, t = 0})
end

local function updateSpikes(e)
	breakSound = breakSound - e
	local body = callOnHScript('opponentBody', {})
	if type(body) ~= 'table' or body[4] == nil then body = nil end

	for i = #spikeGroups, 1, -1 do
		local g = spikeGroups[i]
		for k = #g.spikes, 1, -1 do
			local tag = g.spikes[k]
			local x, y = getProperty(tag..'.x'), getProperty(tag..'.y')
			if body and x < body[3] and x + 48 > body[1] and y < body[4] and y + 192 > body[2] then
				breakSpike(tag)
				table.remove(g.spikes, k)
			elseif g.detect and not isInvulnerable and not isJumping and overlaps('sonicHitboxFix', tag) then
				g.detect = false
				hurtSonic()
			elseif x < -1400 then
				removeLuaSprite(tag, true)
				table.remove(g.spikes, k)
			end
		end
		if #g.spikes == 0 then table.remove(spikeGroups, i) end
	end

	for i = #brokenSpikes, 1, -1 do
		local b = brokenSpikes[i]
		b.t = b.t + e
		if b.t > 2 then
			removeLuaSprite(b.tag, true)
			table.remove(brokenSpikes, i)
		end
	end
end

local function updateRushLane(b)
	local zoom = getProperty('camGame.zoom')
	local midY = (getProperty(b.tag..'.y') + 105 - getProperty('camFollow.y')) * zoom + screenHeight / 2
	local stop = (sonicCenterX() + 160 - getProperty('camFollow.x')) * zoom + screenWidth / 2
	local march = (b.t * 140) % 36
	local pulse = 0.55 + 0.45 * math.abs(math.sin(b.t * 12))
	for i = 1, RUSH_LANE do
		local tag = 'rushLane'..i
		local along = (i - 1) * 36 + march
		local x = screenWidth - 30 - along
		local reveal = math.max(0, math.min(1, b.t * 3500 / math.max(1, along) - 1))
		setProperty(tag..'.visible', x > stop)
		setProperty(tag..'.x', math.floor(x - 10.5 + 0.5))
		setProperty(tag..'.y', math.floor(midY - 13.5 + 0.5))
		setProperty(tag..'.alpha', pulse * reveal * b.lane)
	end
end

local function updateRush(b, e)
	local beat = crochet / 1000
	local tag = b.tag
	b.t = b.t + e
	setProperty(tag..'.y', lerp(getProperty(tag..'.y'), getVar('floorY') - 45, math.min(1, e * 10)))

	if not b.launched then
		b.lane = math.min(1, b.lane + e / 0.15)
		updateRushLane(b)
		if b.t >= beat * 2 then
			b.launched = true
			setProperty(tag..'.velocity.x', -(getProperty(tag..'.x') + 129 - sonicCenterX()) / beat)
			setProperty(tag..'.animation.curAnim.frameRate', 20)
			playSound('minigame/preymini/badnickfast', 0.8)
		end
		return
	end

	if b.lane > 0 then
		b.lane = math.max(0, b.lane - e / 0.2)
		updateRushLane(b)
		if b.lane <= 0 then
			for i = 1, RUSH_LANE do setProperty('rushLane'..i..'.visible', false) end
		end
	end

	if touchesSonic(tag, 7 * 6, 6 * 6, 36 * 6, 29 * 6) then
		if isJumping then
			killBadnik(tag, getProperty(tag..'.x') + 129, getProperty(tag..'.y') + 105)
			for i = 1, RUSH_LANE do setProperty('rushLane'..i..'.visible', false) end
			b.done = true
			return
		elseif not isInvulnerable then
			hurtSonic()
		end
	end

	if getProperty(tag..'.x') < -1800 then
		removeLuaSprite(tag, true)
		b.done = true
	end
end

local function updateBee(b, e)
	local beat = crochet / 1000
	local tag, box = b.tag, b.box
	b.t = b.t + e

	if b.state == 'carry' then
		local p = math.min(1, b.t / (beat * 1.5))
		local ease = 1 - (1 - p) ^ 3
		local x = 1600 + (b.hoverX - 1600) * ease
		local y = b.hoverY - 300 * (1 - ease) + math.sin(b.t * math.pi) * 36
		local f = getProperty(tag..'.animation.curAnim.curFrame') % 5
		setProperty(tag..'.x', x)
		setProperty(tag..'.y', y)
		setProperty(box..'.x', x - 57 * 6)
		setProperty(box..'.y', y + (BOX_AT_Y[f + 1] - 46) * 6)
		setProperty(box..'.animation.curAnim.curFrame', f)

		if b.t >= b.drop then
			b.state = 'fall'
			b.leaveX, b.leaveY, b.leaveT = x, y, b.t
			b.passT = math.max(0.2, (x + 39 * 6 - sonicCenterX()) / 1600)
			local fall = math.max(1, b.surf - (getProperty(box..'.y') + 77 * 6))
			setProperty(box..'.acceleration.y', 2 * fall / (beat * beat))
			playSound('minigame/preymini/dropbox', 0.8)
			if b.warn then showWarning(b.warn, true) end
		end
	elseif not b.beeGone then
		local tau = b.t - b.leaveT
		local x = b.leaveX - 1600 * tau
		local y = b.leaveY - 700 * tau - 1600 * math.max(0, tau - b.passT) ^ 2
		setProperty(tag..'.x', x)
		setProperty(tag..'.y', y)
		if isJumping and touchesSonic(tag, 15 * 6, 6 * 6, 63 * 6, 38 * 6) then
			killBadnik(tag, x + 39 * 6, y + 22 * 6)
			b.beeGone = true
		elseif x < -2000 or y < -2200 then
			removeLuaSprite(tag, true)
			b.beeGone = true
		end
	end

	if b.state == 'fall' then
		if getProperty(box..'.y') + 77 * 6 >= b.surf then
			b.state = 'fire'
			setProperty(box..'.y', b.surf - 77 * 6)
			setProperty(box..'.acceleration.y', 0)
			setProperty(box..'.velocity.y', 0)
			setProperty(box..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
			setObjectOrder(box, getObjectOrder('floorGroup[0]'))
			playAnim(box, 'explosion', true)
			playSound('minigame/preymini/hit', 0.8)
			cameraShake('game', 0.005, 0.15)
		end
	elseif b.state == 'fire' then
		if getProperty(box..'.animation.curAnim.name') == 'explosion' and getProperty(box..'.animation.curAnim.finished') then
			playAnim(box, 'burned', true)
		end
		if b.detect and not isJumping and not isInvulnerable and touchesSonic(box, 85 * 6, 50 * 6, 140 * 6, 77 * 6) then
			b.detect = false
			hurtSonic()
		end
		if getProperty(box..'.x') < -2400 then
			removeLuaSprite(box, true)
			b.state = 'gone'
		end
	end

	if b.state == 'gone' and b.beeGone then b.done = true end
end

local function updateBird(b, e)
	local beat = crochet / 1000
	local tag = b.tag
	b.t = b.t + e
	local s = b.t / (beat * 3)
	local f = getProperty(tag..'.animation.curAnim.curFrame') % 5
	local tx = sonicCenterX() - 47 * 6
	if s <= 1 then
		local ty = getVar('floorY') + 15 - HOOK_BOTTOM[f + 1] * 6
		setProperty(tag..'.x', 1600 + (tx - 1600) * s)
		setProperty(tag..'.y', b.y0 + (ty - b.y0) * (1 - (1 - s) ^ 2))
	else
		setProperty(tag..'.x', getProperty(tag..'.x') - (1600 - tx) / (beat * 3) * e)
		setProperty(tag..'.y', getProperty(tag..'.y') - 700 * e)
	end

	if touchesSonic(tag, 24 * 6, 20 * 6, 64 * 6, 66 * 6) then
		if isJumping then
			killBadnik(tag, getProperty(tag..'.x') + 44 * 6, getProperty(tag..'.y') + 42 * 6)
			b.done = true
			return
		elseif b.detect and not isInvulnerable then
			b.detect = false
			hurtSonic()
		end
	end

	if s > 1 and (getProperty(tag..'.x') < -1500 or getProperty(tag..'.y') < -2200) then
		removeLuaSprite(tag, true)
		b.done = true
	end
end

local function updateAnimal(b, e)
	local tag = b.tag
	b.t = b.t + e
	if getProperty(tag..'.y') + 44 * 6 >= b.floor and getProperty(tag..'.velocity.y') > 0 then
		setProperty(tag..'.y', b.floor - 44 * 6)
		setProperty(tag..'.velocity.y', 0)
		setProperty(tag..'.acceleration.y', 0)
	end
	setProperty(tag..'.visible', b.t < 2.4 or math.floor(b.t / 0.08) % 2 == 0)
	if b.t >= 3 or getProperty(tag..'.x') < -1500 then
		removeLuaSprite(tag, true)
		b.done = true
	end
end

local function updateHazards(e)
	updateSpikes(e)
	for i = #badniks, 1, -1 do
		local b = badniks[i]
		if b.kind == 'rush' then updateRush(b, e)
		elseif b.kind == 'bee' then updateBee(b, e)
		elseif b.kind == 'bird' then updateBird(b, e)
		else updateAnimal(b, e) end
		if b.done then table.remove(badniks, i) end
	end
end

function onUpdatePost(e)
	if inGameOver or getVar('preyDead') then return end

	if isJumping then
		airTime = airTime + e
	end

	callMethod('sonicHitboxFix.setPosition', {getProperty('boyfriend.x') + 10, getProperty('boyfriend.y') - 25})

	if getProperty('boyfriend.velocity.x') < 0 then
		setProperty('boyfriend.acceleration.x', 0)
		setProperty('boyfriend.velocity.x', 0)
	end

	if canceledJump == true and not stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'hit') then
		canceledJump = false
	end

	setProperty('sonic-jump.x', getProperty('boyfriend.x') - 100)
	setProperty('sonic-jump.y', getProperty('boyfriend.y') - 100)

	if isInvulnerable then
		invulnerableTimer = invulnerableTimer - e
		local alphaVal = (math.floor(invulnerableTimer * 15) % 2 == 0) and 0.3 or 1.0
		if not getProperty('sonic-jump.visible') then
			setProperty('boyfriend.alpha', alphaVal)
		end

		if invulnerableTimer <= 0 then
			isInvulnerable = false
			if not isJumping then
				setProperty('boyfriend.alpha', 1.0)
			end
		end
	end

	if not getProperty('cpuControlled') or not stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'hit') then
		if not canceledJump then
			if keyboardJustPressed('SPACE') then holdTimer = 0 end
			if keyboardPressed('SPACE') then holdTimer = holdTimer + e end

			if keyboardPressed('SPACE') and not isJumping and canJump and holdTimer < 0.15 then
				isJumping = true
				setVar('isJumping', isJumping)
				airTime = 0

				setProperty('sonic-jump.visible', true)
				setProperty('boyfriend.alpha', 0)
				playAnim('sonic-jump', 'jump', true)
				playSound('sonicJump')

				setProperty('boyfriend.acceleration.y', gravity)
				setProperty('boyfriend.maxVelocity.y', 5760)
				setProperty('boyfriend.velocity.y', -jumpAmount)
			end
		end
	end

	if isJumping and not getProperty('cpuControlled') and not keyboardPressed('SPACE') and getProperty('boyfriend.velocity.y') < -jumpRelease then
		setProperty('boyfriend.velocity.y', -jumpRelease)
	end

	if getProperty('boyfriend.y') >= getVar('floorY') and isJumping and airTime > 0.1 and getProperty('boyfriend.velocity.y') >= 0 then
		isJumping = false
		setVar('isJumping', isJumping)
		airTime = 0

		setProperty('sonic-jump.visible', false)
		if not isInvulnerable then
			setProperty('boyfriend.alpha', 1)
		end

		setProperty('boyfriend.y', getVar('floorY'))
		setProperty('boyfriend.velocity.y', 0)
		setProperty('boyfriend.acceleration.y', 0)
	end

	if stringStartsWith(getProperty('boyfriend.animation.curAnim.name'), 'idle') and triggerOnce then
		triggerOnce = false
		for i = 0, getProperty('notes.length')-1 do
			setProperty('notes.members['..i..'].noAnimation', false)
			setProperty('notes.members['..i..'].noMissAnimation', false)
		end
	end

	updateHazards(e)

	for i = #ringGroup, 1, -1 do
		local ring = ringGroup[i].sprite
		if overlaps('sonicHitboxFix', ring) then
			setVar('rings', math.min(getVar('rings') + 1, 150))
			callOnScripts('updateRings')
			playSound('Ringer', 0.3)
			playAnim(ring, 'sparkle', true)
			runTimer(ring, 0.4)
			table.remove(ringGroup, i)
		elseif getProperty(ring..'.x') < -1200 - getProperty(ring..'.width') then
			removeLuaSprite(ring, true)
			table.remove(ringGroup, i)
		end
	end
end

function onBeatHit()
	canJump = false
	if (curBeat >= 96 and curBeat < 379) or (curBeat >= 448 and curBeat < 823) then canJump = true end
end

local mech = false
function onEvent(n, v1)
	if n == 'preyEvent' and v1 == 'mech' then
		mech = not mech
	end
end

local playSoundOnce = true
local id = 0
local ringId = 0
local skipSections = 0
local firstRush = true
local firstBee = true
local firstBird = true

local function hazardWindow(beats)
	return (curBeat >= 96 and curBeat + beats < 379) or (curBeat >= 448 and curBeat + beats < 823)
end

local function spawnRings()
	local speed = floorSpeed()
	if speed < 500 then return end
	local count = getRandomInt(3, 5, '4')
	local start, surf = findFloor(sonicCenterX() + speed * (crochet / 1000) * 3, count * 192, false)
	if not start then return end

	ringId = ringId + 1
	local ringOffset = getRandomBool(50) and 0 or 500
	for i = 1, count do
		local ring = 'ring'..ringId..'_'..i

		makeAnimatedLuaSprite(ring, 'prey/ring', start + ((i - 1) * (32 * 6)) + (8 * 6), surf - 192 - ringOffset)
		addAnimationByPrefix(ring, 'idle', 'ring', 8, true)
		addAnimationByPrefix(ring, 'sparkle', 'sparkle', 8, true)
		playAnim(ring, 'idle', true)
		scaleObject(ring, 6, 6)
		setProperty(ring..'.antialiasing', false)
		setProperty(ring..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
		setObjectOrder(ring, getObjectOrder('floorGroup[0]'))

		table.insert(ringGroup, {id = ringId, sprite = ring})
	end
end

local function spawnSpikes()
	local speed = floorSpeed()
	if speed < 500 then return end
	local count = getRandomInt(3, 9)
	local start, surf = findFloor(sonicCenterX() + speed * (crochet / 1000) * 3, count * 48, true)
	if not start then return end

	id = id + 1
	local group = {spikes = {}, detect = true}
	for i = 1, count do
		local spike = 'spike'..id..'_'..i
		makeLuaSprite(spike, 'prey/spike', start + (i - 1) * 48, surf - 192)
		scaleObject(spike, 6, 6)
		setProperty(spike..'.antialiasing', false)
		setProperty(spike..'.velocity.x', getProperty('floorGroup[0].velocity.x'))
		setObjectOrder(spike, getObjectOrder('floorGroup[0]'))
		table.insert(group.spikes, spike)
	end
	table.insert(spikeGroups, group)

	showWarning('warning'..id, playSoundOnce)
	if getProperty('cpuControlled') then
		runTimer('botJump'..id..'spikes', math.max(0.05, (start - getProperty('sonicHitboxFix.x') - 160) / speed - 0.12))
	end
end

local function spawnRush()
	badnikId = badnikId + 1
	local tag = 'rushBadnik'..badnikId
	makeAnimatedLuaSprite(tag, 'minigame/preymini/characters/enemys/Badnik_3', 1700, getVar('floorY') - 45)
	addAnimationByPrefix(tag, 'spin', 'Badnik_3', 10, true)
	playAnim(tag, 'spin', true)
	scaleObject(tag, 6, 6)
	setProperty(tag..'.antialiasing', false)
	addLuaSprite(tag, true)
	table.insert(badniks, {kind = 'rush', tag = tag, t = 0, launched = false, lane = 0})

	showWarning('warningRush'..badnikId, firstRush)
	playSound('minigame/preymini/warning', 0.7)
	firstRush = false
	if getProperty('cpuControlled') then runTimer('botJump'..badnikId, crochet / 1000 * 2) end
end

local function spawnBee()
	local beat = crochet / 1000
	local speed = floorSpeed()
	if speed < 500 then return false end

	local sonicX = sonicCenterX()
	local arrive = beat * 5
	local landX, land, surf
	for _, x in ipairs({1150, 1050, 1250, 950}) do
		local t = arrive - (x - sonicX) / speed
		local spot = callOnHScript('floorSpot', {x + speed * t - 300, x + speed * t + 300, false})
		if t - beat >= beat * 1.75 and type(spot) == 'number' and spot > 0 then
			landX, land, surf = x, t, spot
			break
		end
	end
	if not landX then return false end

	badnikId = badnikId + 1
	local tag = 'fireBee'..badnikId
	local box = 'fireBeeBox'..badnikId
	local hoverY = math.max(surf - 652, getVar('floorY') - 770)

	makeAnimatedLuaSprite(box, 'minigame/preymini/characters/enemys/Fire_Box', 1600, hoverY)
	addAnimationByPrefix(box, 'box', 'box', 10, true)
	addAnimationByPrefix(box, 'explosion', 'explosion', 10, false)
	addAnimationByPrefix(box, 'burned', 'burned', 10, true)
	playAnim(box, 'box', true)
	scaleObject(box, 6, 6)
	setProperty(box..'.antialiasing', false)
	addLuaSprite(box, true)

	makeAnimatedLuaSprite(tag, 'minigame/preymini/characters/enemys/Badnik_2', 1600, hoverY)
	addAnimationByPrefix(tag, 'fly', 'Badnik_2', 10, true)
	playAnim(tag, 'fly', true)
	scaleObject(tag, 6, 6)
	setProperty(tag..'.antialiasing', false)
	addLuaSprite(tag, true)

	table.insert(badniks, {kind = 'bee', tag = tag, box = box, t = 0, state = 'carry', detect = true, surf = surf,
		hoverX = landX - 333, hoverY = hoverY, drop = land - beat, warn = firstBee and 'badWarn'..badnikId or nil})
	firstBee = false

	if getProperty('cpuControlled') then runTimer('botJump'..badnikId, arrive - 0.25) end
	return true
end

local function spawnBird()
	badnikId = badnikId + 1
	local tag = 'hookBadnik'..badnikId
	local y0 = getVar('floorY') - 1100
	makeAnimatedLuaSprite(tag, 'minigame/preymini/characters/enemys/Badnik_1', 1600, y0)
	addAnimationByPrefix(tag, 'fly', 'Badnik_1', 10, true)
	playAnim(tag, 'fly', true)
	scaleObject(tag, 6, 6)
	setProperty(tag..'.antialiasing', false)
	addLuaSprite(tag, true)
	table.insert(badniks, {kind = 'bird', tag = tag, t = 0, y0 = y0, detect = true})

	showWarning('badWarn'..badnikId, firstBird)
	firstBird = false
	if getProperty('cpuControlled') then runTimer('botJump'..badnikId, crochet / 1000 * 3 - 0.18) end
end

function onSectionHit()
	if not (mech and canJump) then return end

	if skipSections > 0 then
		skipSections = skipSections - 1
		return
	end

	if getRandomBool(75) then
		local roll = getRandomInt(1, 100)
		if roll > 64 and roll <= 70 and hazardWindow(4) then
			spawnBird()
			return
		end
		if roll > 70 and roll <= 78 and hazardWindow(4) then
			spawnRush()
			return
		end
		if roll > 78 and hazardWindow(6) and spawnBee() then
			skipSections = 1
			return
		end
		if roll <= 22 then spawnRings() else spawnSpikes() end
	end
end

local mrid = 0
function noteMiss(_, _, _, isn)
	if isn and isInvulnerable then return end
	if getVar('rings') > 0 then
		mrid = mrid + 1
		local missedRing = 'missedRing'..mrid
		makeAnimatedLuaSprite(missedRing, 'prey/ring', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
		addAnimationByPrefix(missedRing, 'idle', 'ring', 8, true)
		scaleObject(missedRing, 6, 6)
		setProperty(missedRing..'.antialiasing', false)
		setProperty(missedRing..'.velocity.x', getRandomInt(-500, 500))
		setProperty(missedRing..'.acceleration.x', getProperty('floorGroup[0].velocity.x'))
		setProperty(missedRing..'.maxVelocity.x', math.abs(getProperty('floorGroup[0].velocity.x')))
		setProperty(missedRing..'.velocity.y', -getRandomInt(1500, 2000))
		setProperty(missedRing..'.acceleration.y', gravity)
		addLuaSprite(missedRing, true)
		runTimer(missedRing, 1)

		playSound('loseRings', 0.15)
		setVar('rings', getVar('rings') - 1)
		callOnScripts('updateRings')
	else
		setProperty('instakillOnMiss', true)
		callMethod('doDeathCheck', {true})
	end
end

function noteMissPress(id)
	if isInvulnerable then return end
	if getVar('rings') > 0 then
		mrid = mrid + 1
		local missedRing = 'missedRing'..mrid
		makeAnimatedLuaSprite(missedRing, 'prey/ring', getProperty('boyfriend.x'), getProperty('boyfriend.y'))
		addAnimationByPrefix(missedRing, 'idle', 'ring', 8, true)
		scaleObject(missedRing, 6, 6)
		setProperty(missedRing..'.antialiasing', false)
		setProperty(missedRing..'.velocity.x', getRandomInt(-500, 500))
		setProperty(missedRing..'.acceleration.x', getProperty('floorGroup[0].velocity.x'))
		setProperty(missedRing..'.maxVelocity.x', math.abs(getProperty('floorGroup[0].velocity.x')))
		setProperty(missedRing..'.velocity.y', -getRandomInt(1500, 2000))
		setProperty(missedRing..'.acceleration.y', gravity)
		addLuaSprite(missedRing, true)
		runTimer(missedRing, 1)

		playSound('loseRings', 0.15)
		setVar('rings', getVar('rings') - 1)
		callOnScripts('updateRings')
	else
		setProperty('instakillOnMiss', true)
		callMethod('doDeathCheck', {true})
	end
end

function onTimerCompleted(t)
	if stringStartsWith(t, 'warning') or stringStartsWith(t, 'badWarn') then
		playAnim(t, '2', true)
		if playSoundOnce and stringStartsWith(t, 'warning') then playSound('warnin', 0.8) end
		if stringStartsWith(t, 'warning') then playSoundOnce = false end
		runTimer('2'..t, crochet / 1000)
	end
	if stringStartsWith(t, '2warning') or stringStartsWith(t, '2badWarn') then removeLuaSprite(t:sub(2), true) end

	if stringStartsWith(t, 'botJump') and getProperty('cpuControlled') and not isJumping then autoJump() end
	if stringStartsWith(t, 'badnikBoom') then removeLuaSprite(t, true) end

	if stringStartsWith(t, 'ring') then removeLuaSprite(t, true) end

	if t == 'removeMissedRings' then
		for _, r in ipairs(missedRings) do
			removeLuaSprite(r, true)
		end
		missedRings = {}
	end
	if stringStartsWith(t, 'missedRing') then removeLuaSprite(t, true) end
end

function freezeHazards()
	local function stop(tag)
		if not luaSpriteExists(tag) then return end
		setProperty(tag..'.velocity.x', 0)
		setProperty(tag..'.velocity.y', 0)
		setProperty(tag..'.acceleration.x', 0)
		setProperty(tag..'.acceleration.y', 0)
		setProperty(tag..'.angularVelocity', 0)
	end
	for _, g in ipairs(spikeGroups) do
		for _, tag in ipairs(g.spikes) do stop(tag) end
	end
	for _, b in ipairs(brokenSpikes) do stop(b.tag) end
	for _, r in ipairs(ringGroup) do stop(r.sprite) end
	for _, b in ipairs(badniks) do
		stop(b.tag)
		if b.box then stop(b.box) end
	end
	for i = 1, RUSH_LANE do setProperty('rushLane'..i..'.visible', false) end
	setProperty('sonic-jump.visible', false)
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function overlaps(obj1, obj2)
    return getProperty(obj1..'.x') < getProperty(obj2..'.x') + getProperty(obj2..'.width')
       and getProperty(obj1..'.x') + getProperty(obj1..'.width') > getProperty(obj2..'.x')
       and getProperty(obj1..'.y') < getProperty(obj2..'.y') + getProperty(obj2..'.height')
       and getProperty(obj1..'.y') + getProperty(obj1..'.height') > getProperty(obj2..'.y')
end
