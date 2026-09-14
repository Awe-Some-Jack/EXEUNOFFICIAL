local INITIAL_HEALTH = 2
local MAX_HEALTH = 2
local MIN_HEALTH = 0

local DAMAGE = {
    NOTE_MISS = 10 / 50,
    KNIFE_HIT = 45 / 50,
    SHOOT_DAMAGE = 1 / 50,
    SHOOT_HEAL = 5 / 50
}

local UI_CONFIG = {
    ICON_SCALE = 0.5,
    ICON_OFFSET = 28,
    HEALTH_OFFSET = -1,
    TEXT_SIZE = 40,
    TEXT_SHADOW_OFFSET = 3,
    FONT = 'sonichud.ttf'
}

local KNIFE_CONFIG = {
    BF_ANGLE = 170,
    PICO_ANGLE = 160,
    VELOCITY_X = -20000,
    VELOCITY_Y_BF = 3500,
    VELOCITY_Y_PICO = 6000,
    SPRITE = 'characters/cuter',
    OFFSET_X = -50,
    OFFSET_Y = 350,
    HIT_DELAY = 0.1
}

local DODGE_CONFIG = {
    TIME_WINDOW = 120,
    CHECK_DELAY = 0.13
}

local health = {
    bf = INITIAL_HEALTH,
    pico = INITIAL_HEALTH,
    requital = INITIAL_HEALTH
}

local dodging = {
    bf = false,
    pico = false
}

local dodgeNoteHits = {
    bf = {},
    pico = {}
}

local dodgeCheckTimers = {
    bf = {},
    pico = {}
}

local dodgeTimerIds = {
    bf = {},
    pico = {}
}

local lastStrumTime = 0
local currentBeat = 0

local hudPositions = {
    BFIcon = {x = 0, y = 0},
    PicoIcon = {x = 0, y = 0},
    ReqIcon = {x = 0, y = 0},
    BFHealth = {x = 0, y = 0},
    PicoHealth = {x = 0, y = 0},
    ReqHealth = {x = 0, y = 0},
    BFText0 = {x = 0, y = 0},
    BFText1 = {x = 0, y = 0},
    PicoText0 = {x = 0, y = 0},
    PicoText1 = {x = 0, y = 0},
    ReqText0 = {x = 0, y = 0},
    ReqText1 = {x = 0, y = 0}
}

function setObjectPosition(obj, x, y)
    callMethod(obj..'.setPosition', {x, y})
end

function getFixedScale(obj, typ)
    typ = typ or 'height'
    return getProperty(obj..'.'..typ) * getProperty(obj..'.scale.'..(typ == 'height' and 'y' or 'x'))
end

function updateHealthText()
    for i = 0, 1 do
        setTextString('BFText'..i, math.floor(health.bf * 50 + 0.5))
        setTextString('PicoText'..i, math.floor(health.pico * 50 + 0.5))
        setTextString('ReqText'..i, math.floor(health.requital * 50 + 0.5))
    end
end

function clampHealth(value)
    return math.max(MIN_HEALTH, math.min(MAX_HEALTH, value))
end

function hideDefaultHUD()
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('healthBar.visible', false)
    setProperty('scoreTxt.visible', false)
end

function swapStrumPositions()
    for i = 0, 3 do
        setProperty('playerStrums.members['..i..'].x', _G['defaultOpponentStrumX'..i])
        setProperty('opponentStrums.members['..i..'].x', _G['defaultPlayerStrumX'..i])
    end
end

function createHealthIcon(name, characterIcon, flipX, xPos, yPos)
    createInstance(name, 'objects.HealthIcon', {characterIcon, flipX})
    setObjectCamera(name, 'hud')
    scaleObject(name, UI_CONFIG.ICON_SCALE, UI_CONFIG.ICON_SCALE, false)
    setObjectPosition(name, xPos, yPos)
    addInstance(name)
end

function createHealthBar(name, imagePath, xPos, yPos)
    makeLuaSprite(name, imagePath)
    setObjectCamera(name, 'hud')
    scaleObject(name, UI_CONFIG.ICON_SCALE, UI_CONFIG.ICON_SCALE)
    setObjectPosition(name, xPos, yPos)
    addLuaSprite(name)
end

function createHealthText(baseName, initialText, xPos, yPos, alignment, orderObj)
    for i = 0, 1 do
        local textName = baseName..i
        local offset = (i == 0) and UI_CONFIG.TEXT_SHADOW_OFFSET or 0

        makeLuaText(textName, initialText, screenWidth, xPos + offset, yPos + offset)
        setTextFont(textName, UI_CONFIG.FONT)
        setTextAlignment(textName, alignment)
        setObjectOrder(textName, getObjectOrder(orderObj))
        setTextBorder(textName, 0)
        setTextSize(textName, UI_CONFIG.TEXT_SIZE)

        if i == 0 then
            setTextColor(textName, '000000')
        end

        addLuaText(textName)
    end
end

function setupCustomHUD()
    local isDownscroll = downscroll

    createHealthIcon('BFIcon', getProperty('boyfriend.healthIcon'), false, -UI_CONFIG.ICON_OFFSET, 0)
    createHealthIcon('PicoIcon', getProperty('gf.healthIcon'), false, -UI_CONFIG.ICON_OFFSET, 0)
    createHealthIcon('ReqIcon', getProperty('dad.healthIcon'), true, 0, 0)

    local bfIconY = isDownscroll and -UI_CONFIG.ICON_OFFSET or (screenHeight - getProperty('BFIcon.height') + UI_CONFIG.ICON_OFFSET)
    setObjectPosition('BFIcon', -UI_CONFIG.ICON_OFFSET, bfIconY)
    hudPositions.BFIcon.x = -UI_CONFIG.ICON_OFFSET
    hudPositions.BFIcon.y = bfIconY

    local picoIconY = isDownscroll and (-18 + getFixedScale('BFIcon')) or (screenHeight - getFixedScale('PicoIcon') + 18 - getProperty('BFIcon.height'))
    setObjectPosition('PicoIcon', -UI_CONFIG.ICON_OFFSET, picoIconY)
    hudPositions.PicoIcon.x = -UI_CONFIG.ICON_OFFSET
    hudPositions.PicoIcon.y = picoIconY

    local reqIconX = screenWidth - getProperty('ReqIcon.width') + UI_CONFIG.ICON_OFFSET
    local reqIconY = isDownscroll and -UI_CONFIG.ICON_OFFSET or (screenHeight - getProperty('ReqIcon.height') + UI_CONFIG.ICON_OFFSET)
    setObjectPosition('ReqIcon', reqIconX, reqIconY)
    hudPositions.ReqIcon.x = reqIconX
    hudPositions.ReqIcon.y = reqIconY

    createHealthBar('BFHealth', 'ui/boyfriend', 0, 0)
    createHealthBar('PicoHealth', 'ui/pico', 0, 0)
    createHealthBar('ReqHealth', 'ui/requital', 0, 0)

    local bfHealthX = 20 + getFixedScale('BFIcon', 'width') + UI_CONFIG.HEALTH_OFFSET
    local bfHealthY = isDownscroll and 10 or (screenHeight - getProperty('BFHealth.height') - 37)
    setObjectPosition('BFHealth', bfHealthX, bfHealthY)
    hudPositions.BFHealth.x = bfHealthX
    hudPositions.BFHealth.y = bfHealthY

    local picoHealthX = 20 + getFixedScale('PicoIcon', 'width') + UI_CONFIG.HEALTH_OFFSET
    local picoHealthY = isDownscroll and (19 + getFixedScale('BFIcon')) or (screenHeight - getProperty('PicoHealth.height') - 47 - getFixedScale('BFIcon'))
    setObjectPosition('PicoHealth', picoHealthX, picoHealthY)
    hudPositions.PicoHealth.x = picoHealthX
    hudPositions.PicoHealth.y = picoHealthY

    local reqHealthX = screenWidth - getProperty('ReqHealth.width') - getFixedScale('ReqIcon', 'width') - 19
    local reqHealthY = isDownscroll and 10 or (screenHeight - getProperty('ReqHealth.height') - 37)
    setObjectPosition('ReqHealth', reqHealthX, reqHealthY)
    hudPositions.ReqHealth.x = reqHealthX
    hudPositions.ReqHealth.y = reqHealthY

    local bfTextY = isDownscroll and 37 or 663
    createHealthText('BFText', '100', 140, bfTextY, 'Left', 'BFHealth')

    local picoTextY = isDownscroll and 123 or 577
    createHealthText('PicoText', '100', 140, picoTextY, 'Left', 'PicoHealth')

    local reqTextY = isDownscroll and 37 or 663
    createHealthText('ReqText', '100', -140, reqTextY, 'Right', 'ReqHealth')

    for i = 0, 1 do
        local bfOffset = (i == 0) and UI_CONFIG.TEXT_SHADOW_OFFSET or 0
        hudPositions['BFText'..i].x = 140 + bfOffset
        hudPositions['BFText'..i].y = bfTextY + bfOffset

        local picoOffset = (i == 0) and UI_CONFIG.TEXT_SHADOW_OFFSET or 0
        hudPositions['PicoText'..i].x = 140 + picoOffset
        hudPositions['PicoText'..i].y = picoTextY + picoOffset

        local reqOffset = (i == 0) and UI_CONFIG.TEXT_SHADOW_OFFSET or 0
        hudPositions['ReqText'..i].x = -140 + reqOffset
        hudPositions['ReqText'..i].y = reqTextY + reqOffset
    end
end

function createKnife(target, strumTime)
    local config = {
        bf = {
            angle = KNIFE_CONFIG.BF_ANGLE,
            velocityY = KNIFE_CONFIG.VELOCITY_Y_BF,
            order = getObjectOrder('gfGroup')
        },
        pico = {
            angle = KNIFE_CONFIG.PICO_ANGLE,
            velocityY = KNIFE_CONFIG.VELOCITY_Y_PICO,
            order = getObjectOrder('gfGroup') + 1
        }
    }

    local targetConfig = config[target]
    if not targetConfig then return end

    playAnim('dad', 'attack', true)
    playSound('dodge', 0.7)
    setProperty('dad.specialAnim', true)

    local knifeName = 'knife'..math.floor(strumTime)
    makeLuaSprite(knifeName, KNIFE_CONFIG.SPRITE,
        getProperty('dad.x') + KNIFE_CONFIG.OFFSET_X,
        getProperty('dad.y') + KNIFE_CONFIG.OFFSET_Y)

    setProperty(knifeName..'.angle', targetConfig.angle)
    setProperty(knifeName..'.velocity.x', KNIFE_CONFIG.VELOCITY_X)
    setProperty(knifeName..'.velocity.y', targetConfig.velocityY)
    setObjectOrder(knifeName, targetConfig.order)
    addLuaSprite(knifeName)

    runTimer(knifeName..target, KNIFE_CONFIG.HIT_DELAY)
end

function handleKnifeHit(timerTag)
    local target = nil
    local character = nil
    local healthKey = nil
    local otherHealthKey = nil

    if stringEndsWith(timerTag, 'bf') then
        target = 'bf'
        character = 'boyfriend'
        healthKey = 'bf'
        otherHealthKey = 'pico'
    elseif stringEndsWith(timerTag, 'pico') then
        target = 'pico'
        character = 'gf'
        healthKey = 'pico'
        otherHealthKey = 'bf'
    else
        return
    end

    local dodgeSuccess = checkDodgeSuccess(target)

    if dodgeSuccess then
        playAnim(character, 'dodge', true)
        setProperty(character..'.specialAnim', true)
        dodgeNoteHits[target] = {}
    else
        if health[healthKey] > 0 then
            health[healthKey] = math.max(0, health[healthKey] - DAMAGE.KNIFE_HIT)
        elseif health[otherHealthKey] > 0 then
            health[otherHealthKey] = math.max(0, health[otherHealthKey] - DAMAGE.KNIFE_HIT)
        end
        playSound('knife', 0.7)
        playAnim(character, 'hit', true)
        setProperty(character..'.specialAnim', true)
    end

    updateHealthText()
    removeLuaSprite(timerTag:gsub(target, ''), true)
end

function processAttackNotes()
    for i = 0, getProperty('notes.length') - 1 do
        local noteType = getProperty('notes.members['..i..'].noteType')
        local noteDistance = getProperty('notes.members['..i..'].distance')
        local noteStrumTime = getProperty('notes.members['..i..'].strumTime')

        if noteType == 'BFdodge' or noteType == 'PICOdodge' or noteType == 'NoteShoot' then
            setProperty('notes.members['..i..'].ignoreNote', not getProperty('cpuControlled'))
        end

        local shouldTrigger = (downscroll and noteDistance > -100) or (not downscroll and noteDistance < 100)

        if shouldTrigger and lastStrumTime ~= noteStrumTime then
            local hasAnim = getProperty('notes.members['..i..'].extraData.requitalAnim', true)

            if noteType == 'BFdodge' and hasAnim == nil then
                setProperty('notes.members['..i..'].extraData.requitalAnim', true, true)
                createKnife('bf', noteStrumTime)
                lastStrumTime = noteStrumTime
            elseif noteType == 'PICOdodge' and hasAnim == nil then
                setProperty('notes.members['..i..'].extraData.requitalAnim', true, true)
                createKnife('pico', noteStrumTime)
                lastStrumTime = noteStrumTime
            end
        end
    end
end

function onCreatePost()
    hideDefaultHUD()
    swapStrumPositions()
    setupCustomHUD()
end

function onUpdateScore()
    setHealth(2)
end

function onUpdate(elapsed)
    if health.bf <= 0.01 and health.pico <= 0.01 then
        setHealth(-2)
    end

    updateHUDPositions()
    cleanDodgeHits()
    processAttackNotes()
end

function onEvent(n)
    if n == 'Change Character' then
        callMethod('BFIcon.changeIcon', {getProperty('boyfriend.healthIcon')})
        callMethod('PicoIcon.changeIcon', {getProperty('gf.healthIcon')})
        callMethod('ReqIcon.changeIcon', {getProperty('dad.healthIcon')})
    end
end

function updateHUDPositions()
    setProperty('BFIcon.x', hudPositions.BFIcon.x)
    setProperty('BFIcon.y', hudPositions.BFIcon.y)
    setProperty('PicoIcon.x', hudPositions.PicoIcon.x)
    setProperty('PicoIcon.y', hudPositions.PicoIcon.y)
    setProperty('ReqIcon.x', hudPositions.ReqIcon.x)
    setProperty('ReqIcon.y', hudPositions.ReqIcon.y)

    setProperty('BFHealth.x', hudPositions.BFHealth.x)
    setProperty('BFHealth.y', hudPositions.BFHealth.y)
    setProperty('PicoHealth.x', hudPositions.PicoHealth.x)
    setProperty('PicoHealth.y', hudPositions.PicoHealth.y)
    setProperty('ReqHealth.x', hudPositions.ReqHealth.x)
    setProperty('ReqHealth.y', hudPositions.ReqHealth.y)

    for i = 0, 1 do
        setProperty('BFText'..i..'.x', hudPositions['BFText'..i].x)
        setProperty('BFText'..i..'.y', hudPositions['BFText'..i].y)
        setProperty('PicoText'..i..'.x', hudPositions['PicoText'..i].x)
        setProperty('PicoText'..i..'.y', hudPositions['PicoText'..i].y)
        setProperty('ReqText'..i..'.x', hudPositions['ReqText'..i].x)
        setProperty('ReqText'..i..'.y', hudPositions['ReqText'..i].y)
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    if isSustainNote then return end

    if noteType == 'BFdodge' or noteType == 'PICOdodge' or noteType == 'NoteShoot' then
        return
    end

    if noteType == 'GF Sing' then
        if health.pico > 0 then
            health.pico = math.max(0, health.pico - DAMAGE.NOTE_MISS)
        elseif health.bf > 0 then
            health.bf = math.max(0, health.bf - DAMAGE.NOTE_MISS)
        end
    else
        if health.bf > 0 then
            health.bf = math.max(0, health.bf - DAMAGE.NOTE_MISS)
        elseif health.pico > 0 then
            health.pico = math.max(0, health.pico - DAMAGE.NOTE_MISS)
        end
    end

    updateHealthText()
end

function noteMissPress(direction)
    if noteType == 'GF Sing' then
        if health.pico > 0 then
            health.pico = math.max(0, health.pico - DAMAGE.NOTE_MISS * 0.5)
        elseif health.bf > 0 then
            health.bf = math.max(0, health.bf - DAMAGE.NOTE_MISS * 0.5)
        end
    else
        if health.bf > 0 then
            health.bf = math.max(0, health.bf - DAMAGE.NOTE_MISS * 0.5)
        elseif health.pico > 0 then
            health.pico = math.max(0, health.pico - DAMAGE.NOTE_MISS * 0.5)
        end
    end

    updateHealthText()
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then return end

    if noteType == 'NoteShoot' then
        health.requital = math.max(MIN_HEALTH, health.requital - DAMAGE.SHOOT_DAMAGE)
        health.bf = clampHealth(health.bf + DAMAGE.SHOOT_HEAL)
        health.pico = clampHealth(health.pico + DAMAGE.SHOOT_HEAL)
        updateHealthText()
    elseif noteType == 'BFdodge' then
        table.insert(dodgeNoteHits.bf, {time = getSongPosition(), direction = direction, id = id})

        local timerId = 'checkDodgeFail_bf_'..id
        table.insert(dodgeTimerIds.bf, timerId)
        runTimer(timerId, DODGE_CONFIG.CHECK_DELAY)

        if checkDodgeSuccess('bf') then
            cancelAllDodgeTimers('bf')
        end
    elseif noteType == 'PICOdodge' then
        table.insert(dodgeNoteHits.pico, {time = getSongPosition(), direction = direction, id = id})

        local timerId = 'checkDodgeFail_pico_'..id
        table.insert(dodgeTimerIds.pico, timerId)
        runTimer(timerId, DODGE_CONFIG.CHECK_DELAY)

        if checkDodgeSuccess('pico') then
            cancelAllDodgeTimers('pico')
        end
    end
end

function cancelAllDodgeTimers(target)
    for i, timerId in ipairs(dodgeTimerIds[target]) do
        cancelTimer(timerId)
    end
    dodgeTimerIds[target] = {}
end

function checkDodgeSuccess(target)
    local hits = dodgeNoteHits[target]
    local validHits = {}
    local currentTime = getSongPosition()

    for i, hit in ipairs(hits) do
        if currentTime - hit.time < DODGE_CONFIG.TIME_WINDOW then
            table.insert(validHits, hit)
        end
    end

    if #validHits >= 2 then
        local uniqueDirections = {}
        for i, hit in ipairs(validHits) do
            uniqueDirections[hit.direction] = true
        end

        if getTableLength(uniqueDirections) >= 2 then
            return true
        end
    end

    return false
end

function getTableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function cleanDodgeHits()
    local currentTime = getSongPosition()

    for target, hits in pairs(dodgeNoteHits) do
        local newHits = {}
        for i, hit in ipairs(hits) do
            if currentTime - hit.time < (DODGE_CONFIG.TIME_WINDOW + 50) then
                table.insert(newHits, hit)
            end
        end
        dodgeNoteHits[target] = newHits
    end
end

function onTimerCompleted(tag)
    if stringStartsWith(tag, 'checkDodgeFail_') then
        local parts = stringSplit(tag, '_')
        local target = parts[2]
        local noteId = tonumber(parts[3])

        if not checkDodgeSuccess(target) then
            local character = (target == 'bf') and 'boyfriend' or 'gf'
            local healthKey = target
            local otherHealthKey = (target == 'bf') and 'pico' or 'bf'

            if health[healthKey] > 0 then
                health[healthKey] = math.max(0, health[healthKey] - DAMAGE.NOTE_MISS)
            elseif health[otherHealthKey] > 0 then
                health[otherHealthKey] = math.max(0, health[otherHealthKey] - DAMAGE.NOTE_MISS)
            end

            playSound('knife', 0.7)
            playAnim(character, 'hit', true)
            setProperty(character..'.specialAnim', true)
            updateHealthText()
        end

        dodgeNoteHits[target] = {}
    else
        handleKnifeHit(tag)
    end
end

function stringSplit(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from, true)

    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from, true)
    end

    table.insert(result, string.sub(str, from))
    return result
end

function stringStartsWith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end
