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
    makeLuaSprite('blackScreen', '', -900, -700)
    makeGraphic('blackScreen', screenWidth * 4, screenHeight * 4, '000000')
    setObjectCamera('blackScreen', 'game')
    addLuaSprite('blackScreen', true)
    setProperty('blackScreen.alpha', 1)

    addCharacterToList('coldsteel_bfmeme', 'bf')
    addCharacterToList('coldsteel_meme', 'dad')
end

function onStepHit()
    if curStep >= 32 and luaSpriteExists('blackScreen') then
        removeLuaSprite('blackScreen', true)
    end

    if curStep == 1070 or curStep == 1087 or curStep == 1103 or
       curStep == 1135 or curStep == 1153 or curStep == 1167 then
        setRandomNoteAngles()
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

    if curStep == 1056 then
        triggerEvent('Change Character', 'bf', 'coldsteel_bfmeme')
        triggerEvent('Change Character', 'dad', 'coldsteel_meme')
    end

    if curStep == 1264 then
        triggerEvent('Change Character', 'bf', 'coldsteel_bf')
    end

    if curStep == 1311 then
        triggerEvent('Change Character', 'bf', 'coldsteel_bfmeme')
        stopAllRotation = false
        isFastSpin = true
        rotationSpeed = 8
    end

    if curStep == 1312 then
        zoomPulse = true
        zoomTime = 0
    end

    if curStep == 1407 then
        stopAllRotation = true
        isFastSpin = false
        isSpinning = false
        rotationSpeed = 0
        zoomPulse = false
        resetNoteAngles()
        setProperty('boyfriend.angle', 0)
        setProperty('dad.angle', 0)
        setProperty('defaultCamZoom', baseZoom)
    end

    if curStep == 1423 then
        triggerEvent('Change Character', 'bf', 'coldsteel_bf')
        triggerEvent('Change Character', 'dad', 'coldsteel')
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
