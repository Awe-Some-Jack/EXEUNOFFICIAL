-- Script by Kophy232, Remember to credit if use!

local barsCreated = false
local downscrollBool = false
local layerShit = 0
local pulseActive = false
local pulsePrevTopY = 0
local pulsePrevBottomY = 0
local pulseOffset = 0
local pulseEntryTime = 0.5
local pulseEase = 'quadOut'
local pulseMode = 0
function onCreate()
    downscrollBool = getPropertyFromClass('ClientPrefs', 'downScroll')
end
function onEvent(name, value1, value2)
    if string.lower(name) ~= "blackbars" then return end
    local height = tonumber(value1) or 200
    if not barsCreated then
        makeLuaSprite('topBar', '', 0, -720)
        makeGraphic('topBar', 4000, 720, '000000')
        setObjectCamera('topBar', 'camHUD')
        screenCenter('topBar', 'x')
        addLuaSprite('topBar', false)
        makeLuaSprite('bottomBar', '', 0, 720)
        makeGraphic('bottomBar', 4000, 720, '000000')
        setObjectCamera('bottomBar', 'camHUD')
        screenCenter('bottomBar', 'x')
        addLuaSprite('bottomBar', false)
        barsCreated = true
        layerShit = getObjectOrder('topBar')
    end
    local params = {}
    for v in string.gmatch(value2 or "", "([^,]+)") do
        table.insert(params, v)
    end
    local mode = tonumber(params[1]) or 0
    local entryTime = tonumber(params[2]) or 0.5
    local easeType = params[3] or 'quadOut'
    local pulse = tonumber(params[4]) or 0
    pulseMode = mode
    if mode == 2 then
        setObjectOrder('topBar', 0)
        setObjectOrder('bottomBar', 0)
    else
        setObjectOrder('topBar', layerShit)
        setObjectOrder('bottomBar', layerShit)
    end
    if pulse == 1 then
        if pulseActive then
            cancelTween('topBarPulseIn')
            cancelTween('bottomBarPulseIn')
            cancelTween('topBarPulseOut')
            cancelTween('bottomBarPulseOut')
            pulseActive = false
        end
        local topY = getProperty('topBar.y')
        local bottomY = getProperty('bottomBar.y')
        pulseActive = true
        pulsePrevTopY = topY
        pulsePrevBottomY = bottomY
        pulseOffset = height
        pulseEntryTime = entryTime
        pulseEase = easeType
        doTweenY('topBarPulseIn', 'topBar', topY + height, 0.2, easeType)
        doTweenY('bottomBarPulseIn', 'bottomBar', bottomY - height, 0.2, easeType)
        if mode == 1 then
            for i = 0, 7 do
                local noteY = getPropertyFromGroup('strumLineNotes', i, 'y')
                local targetY = downscrollBool and (noteY - height) or (noteY + height)
                noteTweenY('pulseNoteIn'..i, i, targetY, 0.2, easeType)
            end
        end
    else
        doTweenY('topBarMove', 'topBar', height - 720, entryTime, easeType)
        doTweenY('bottomBarMove', 'bottomBar', -height + 720, entryTime, easeType)
        if mode == 1 then
            for i = 0, 7 do
                local pos = 0
                local defaultY = getPropertyFromGroup('strumLineNotes', i, 'y')
                if downscrollBool then
                    pos = 720 - height - 112
                    if pos >= defaultY - 56 then pos = defaultY - 56 end
                else
                    pos = height
                    if pos <= defaultY - 56 then pos = defaultY - 56 end
                end
                noteTweenY('moveStrumY'..i, i, pos, entryTime, easeType)
            end
        end
    end
end
function onTweenCompleted(tag)
    if tag == 'topBarPulseIn' and pulseActive then
        local topY = getProperty('topBar.y')
        local bottomY = getProperty('bottomBar.y')
        local topReturnY = topY - pulseOffset
        local bottomReturnY = bottomY + pulseOffset
        doTweenY('topBarPulseOut', 'topBar', topReturnY, pulseEntryTime, pulseEase)
        doTweenY('bottomBarPulseOut', 'bottomBar', bottomReturnY, pulseEntryTime, pulseEase)
        if pulseMode == 1 then
            for i = 0, 7 do
                local noteY = getPropertyFromGroup('strumLineNotes', i, 'y')
                local returnY = downscrollBool and (noteY + pulseOffset) or (noteY - pulseOffset)
                noteTweenY('pulseNoteOut'..i, i, returnY, pulseEntryTime, pulseEase)
            end
        end
    end
    if tag == 'topBarPulseOut' and pulseActive then
        pulseActive = false
    end
end