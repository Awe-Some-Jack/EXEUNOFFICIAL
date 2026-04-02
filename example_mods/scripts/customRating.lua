local CONFIG = {
    RATING_Y_DOWNSCROLL = 616,
    RATING_Y_UPSCROLL = 92,
    DESCENT_OFFSET = 30,
    FADE_SPEED = 250,
    DESCENT_SPEED = 250,
    FADE_OUT_SPEED = 3,
    ZOOM_SPEED = 12,
    FADE_DELAY = 0.2,
    BOUNCE_DURATION = 0.08,
    BOUNCE_HEIGHT = 5,
    ZOOM_SCALE = 1.2,
    FONT = 'sonic4.ttf',
    PIXEL_FONT = "visitor1.ttf",
    SIZE = 60,
    PIXEL_SIZE = 70,
    BORDER = 3
}

local state = {
    hitCounter = 0,
    ratingY = 0,
    ratingAlpha = 0,
    lastHitTime = 0,
    isHoldingNote = false,
    fadeProgress = 0,
    zoomScale = 1,
    currentY = 0,
    isDescending = false,
    bounceOffset = 0
}

local scrWidth = 1280
local swapped = false
local isPixelCombo = false

local function formatCounter(num)
    if num >= 10000 then
        num = 9999
    end

    if num >= 1000 then
        local str = string.format('%04d', num)
        return str:sub(1,1) .. str:sub(2,2) .. str:sub(3,3) .. str:sub(4,4)
    else
        local str = string.format('%03d', num)
        return str:sub(1,1) .. str:sub(2,2) .. str:sub(3,3)
    end
end

local function centerTextX()
    local textWidth = getProperty('hitCounterText.width')
    setProperty('hitCounterText.x', math.floor(((scrWidth / 2) - (songPath == 'triple-trouble' and (swapped and -25 or 30) or 0)) - (textWidth / 2)))
end

local function resetAnimationState()
    state.fadeProgress = 0
    state.bounceOffset = 0
    state.isDescending = false
end

local function updateZoom(elapsed)
    if state.zoomScale > 1 then
        state.zoomScale = math.max(1, state.zoomScale - (CONFIG.ZOOM_SPEED * elapsed))
    end
    setProperty('hitCounterText.scale.x', state.zoomScale)
    setProperty('hitCounterText.scale.y', state.zoomScale)
end

local function updateDescent(elapsed)
    if state.isDescending then
        state.currentY = state.currentY + (CONFIG.DESCENT_SPEED * elapsed)
        if state.currentY >= state.ratingY then
            state.currentY = state.ratingY
            state.isDescending = false
        end
    end
end

local function updateFadeOut(elapsed)
    if state.hitCounter <= 0 or state.ratingAlpha <= 0 then return end

    local currentTime = getSongPosition() / 1000
    local timeSinceHit = currentTime - state.lastHitTime

    if timeSinceHit > CONFIG.FADE_DELAY and not state.isHoldingNote and not state.isDescending then
        state.fadeProgress = state.fadeProgress + elapsed

        if state.fadeProgress < CONFIG.BOUNCE_DURATION then
            local bounceProgress = state.fadeProgress / CONFIG.BOUNCE_DURATION
            state.bounceOffset = math.sin(bounceProgress * math.pi) * CONFIG.BOUNCE_HEIGHT * (downscroll and -1 or 1)
        else
            state.bounceOffset = 0
        end

        if state.fadeProgress > CONFIG.BOUNCE_DURATION then
            local easeOut = 1 - math.pow(1 - math.min((state.fadeProgress - CONFIG.BOUNCE_DURATION) / 1, 1), 2)
            state.currentY = state.currentY - (CONFIG.FADE_SPEED * elapsed * (1 + easeOut * 0.5)) * (downscroll and -1 or 1)
        end

        local fadeEase = math.pow(state.fadeProgress * 0.5, 2)
        state.ratingAlpha = state.ratingAlpha - (CONFIG.FADE_OUT_SPEED * elapsed * (1 + fadeEase))
        state.ratingAlpha = math.max(0, state.ratingAlpha)

        setProperty('hitCounterText.alpha', state.ratingAlpha)
    end
end

local function checkHoldingNotes()
    for i = 0, 3 do
        if keyPressed(getPropertyFromGroup('strumLineNotes', i + 4, 'noteData')) then
            return true
        end
    end
    return false
end

local squaresong = {'chocolate-milk', 'vanilla-milk', 'fatality'}
function onCreatePost()
    setPropertyFromClass('backend.ClientPrefs', 'data.hideHud', false)

    for i = 1,#squaresong do if songPath == squaresong[i] then scrWidth = 960 end end

    state.ratingY = getPropertyFromClass('backend.ClientPrefs', 'data.downScroll')
        and CONFIG.RATING_Y_DOWNSCROLL
        or CONFIG.RATING_Y_UPSCROLL

    state.currentY = state.ratingY

    makeLuaText('hitCounterText', '000', 0, 0, state.ratingY)
    setTextFont('hitCounterText', (isPixelCombo and CONFIG.PIXEL_FONT or CONFIG.FONT))
    setTextSize('hitCounterText', (isPixelCombo and CONFIG.PIXEL_SIZE or CONFIG.SIZE))
    setTextAlignment('hitCounterText', 'center')
    setTextBorder('hitCounterText', CONFIG.BORDER, '000000')
    setProperty('hitCounterText.alpha', 0)
    setProperty('hitCounterText.scale.x', 1)
    setProperty('hitCounterText.scale.y', 1)
    addLuaText('hitCounterText')

    centerTextX()
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not isSustainNote then
        state.hitCounter = state.hitCounter + 1
        state.lastHitTime = getSongPosition() / 1000

        setTextString('hitCounterText', formatCounter(state.hitCounter))

        state.currentY = state.ratingY - CONFIG.DESCENT_OFFSET
        state.isDescending = true
        state.ratingAlpha = 1
        state.zoomScale = CONFIG.ZOOM_SCALE

        resetAnimationState()
        setProperty('hitCounterText.alpha', 1)

        setProperty('showComboNum', false)
        setProperty('showRating', false)
    else
        state.isHoldingNote = true
        state.lastHitTime = getSongPosition() / 1000
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if not isSustainNote then
        setProperty('showComboNum', false)
        setProperty('showRating', false)
    end
end

function noteMiss(id, direction, noteType, isSustainNote)
    state.hitCounter = 0
    state.ratingAlpha = 0
    state.currentY = state.ratingY
    resetAnimationState()
    setProperty('hitCounterText.alpha', 0)
end

function onUpdatePost(elapsed)
    state.isHoldingNote = checkHoldingNotes()

    updateZoom(elapsed)
    updateDescent(elapsed)
    updateFadeOut(elapsed)

    setProperty('hitCounterText.y', state.currentY + state.bounceOffset)
    centerTextX()

    setProperty('showComboNum', false)
    setProperty('showRating', false)

    for i = 0, 3 do
        local ratingName = 'rating' .. i
        if getProperty(ratingName .. '.alpha') ~= nil then
            setProperty(ratingName .. '.alpha', 0)
        end

        local comboName = 'combo' .. i
        if getProperty(comboName .. '.alpha') ~= nil then
            setProperty(comboName .. '.alpha', 0)
        end
    end
end

function onEvent(n,v1,v2)
	if n == 'Knux' then swapped = not swapped end
    if n == 'Swap Pixel Combo' then
        isPixelCombo = not isPixelCombo
        setTextFont('hitCounterText', (isPixelCombo and CONFIG.PIXEL_FONT or CONFIG.FONT))
        setTextSize('hitCounterText', (isPixelCombo and CONFIG.PIXEL_SIZE or CONFIG.SIZE))
    end
end

function onDestroy()
    removeLuaText('hitCounterText')
end
