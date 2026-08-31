local frozenHealth = 1

local currentAngle = 0
local rotationSpeed = 0
local isSpinning = false
local isFastSpin = false
local stopAllRotation = false

local zoomPulse = false
local zoomTime = 0
local baseZoom = 0.7

function onCreate()
	setProperty('skipCountdown', true)
	frozenHealth = getProperty('health')
end

local function setRandomNoteAngles()
	local randomAngle = math.random(0, 360)

	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'angle', randomAngle)
	end

	for i = 0, 3 do
		setPropertyFromGroup('playerStrums', i, 'angle', randomAngle)
	end
end

local function rotateNotes(speed)
	currentAngle = currentAngle + speed

	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'angle', currentAngle)
	end

	for i = 0, 3 do
		setPropertyFromGroup('playerStrums', i, 'angle', currentAngle)
	end
end

local function resetNoteAngles()
	for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'angle', 0)
		setPropertyFromGroup('playerStrums', i, 'angle', 0)
	end
	currentAngle = 0
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
	if curStep >= 0 and curStep <= 38 then
		setProperty('health', frozenHealth)
	end
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
	if curStep >= 0 and curStep <= 38 then
		setProperty('health', frozenHealth)
	end
end

function onCreatePost()
	addCharacterToList('coldsteelanims1', 'dad')
	addCharacterToList('coldsteelanims2', 'dad')
	addCharacterToList('coldsteelanims3', 'dad')
	addCharacterToList('coldsteelanims4', 'dad')
end

local hudElements = {'iconBF', 'iconOpp', 'exeScoreTxt', 'healthBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'hbBG', 'strumLineNotes.members[0]', 'strumLineNotes.members[1]', 'strumLineNotes.members[2]', 'strumLineNotes.members[3]', 'strumLineNotes.members[3]', 'strumLineNotes.members[4]', 'strumLineNotes.members[5]', 'strumLineNotes.members[6]', 'strumLineNotes.members[7]'}
local startGravity = false
function onStepHit()
	if curStep == 528 then
		triggerEvent('Change Character', 'dad', 'coldsteelanims1')
		triggerEvent('Play Animation', 'steel', 'dad')
	end

	if curStep == 544 then
		triggerEvent('Change Character', 'dad', 'coldsteel')
	end

	if curStep == 1024 then
		triggerEvent('Change Character', 'dad', 'coldsteelanims2')
		triggerEvent('Play Animation', 'mother', 'dad')
	end

	if curStep == 1056 then
		triggerEvent('Change Character', 'dad', 'coldsteel')
	end

	if curStep == 1070 or curStep == 1087 or curStep == 1103 or
	   curStep == 1135 or curStep == 1153 or curStep == 1167 then
		setRandomNoteAngles()
	end

	if curStep == 1137 then
		triggerEvent('Change Character', 'dad', 'coldsteelanims1')
		triggerEvent('Play Animation', 'devianart', 'dad')
	end

	if curStep == 1184 then
		triggerEvent('Change Character', 'dad', 'coldsteel')
	end

	if curStep == 1293 then
		triggerEvent('Change Character', 'dad', 'coldsteelanims3')
		triggerEvent('Play Animation', 'toyoumom', 'dad')
	end

	if curStep == 1312 then
		triggerEvent('Change Character', 'dad', 'coldsteel')
	end

	if curStep == 1190 then
		stopAllRotation = false
		isSpinning = true
		rotationSpeed = 0.5
	end

	if curStep == 1264 then
		isSpinning = false
		resetNoteAngles()
	end


	if curStep == 1311 then
		stopAllRotation = false
		setProperty('dad.angle', 0)
		isFastSpin = true
		rotationSpeed = 8
	end

	if curStep == 1312 then
		zoomPulse = true
		zoomTime = 0
	end

	if curStep == 1403 then
		setProperty('dad.angle', 0)
		triggerEvent('Change Character', 'dad', 'coldsteelanims4')
		triggerEvent('Play Animation', 'whatsthat', 'dad')
	end

	if curStep == 1696 then
		triggerEvent('Change Character', 'dad', 'coldsteel')
		setProperty('dad.angle', 0)
	end

	if curStep == 1407 then
		setProperty('dad.angle', 0)
		stopAllRotation = true
		isFastSpin = false
		isSpinning = false
		rotationSpeed = 0
		zoomPulse = false
		resetNoteAngles()
		setProperty('boyfriend.angle', 0)
		setProperty('defaultCamZoom', baseZoom)
	end

	if curStep == 1984 then
		triggerEvent('Change Character', 'dad', 'coldsteelanims3')
		triggerEvent('Play Animation', 'newgrounds', 'dad')
		setProperty('dad.angle', 0)
	end

	if curStep == 1976 then
		startGravity = true
	end
end

function onUpdate(elapsed)

	if zoomPulse then
		zoomTime = zoomTime + elapsed
		local zoomOffset = math.sin(zoomTime * 2) * 0.15
		setProperty('defaultCamZoom', baseZoom + zoomOffset)
	end

	if stopAllRotation then
		return
	end

	if isSpinning then
		rotateNotes(rotationSpeed)
		rotationSpeed = rotationSpeed + 0.01
	end

	if isFastSpin then
		rotateNotes(rotationSpeed)
		setProperty('boyfriend.angle', getProperty('boyfriend.angle') + 5)
		setProperty('dad.angle', getProperty('dad.angle') + 5)
	end
end

function onCountdownStarted()
	return Function_Stop
end
