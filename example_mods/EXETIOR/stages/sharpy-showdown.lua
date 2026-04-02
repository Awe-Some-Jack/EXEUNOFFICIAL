local StageConfig = {
    background = {
        {name = 'bg', path = 'SS/bg', x = -1500, y = -1500, scaleX = 1.2, scaleY = 1.2, scrollX = 0.8, scrollY = 0.8},
        {name = 'floor', path = 'SS/floor', x = -1500, y = 500, scaleX = 1.2, scaleY = 1.6, scrollX = 1, scrollY = 1},
        {name = 'arch', path = 'SS/arch', x = -1000, y = -730, scaleX = 1.2, scaleY = 1.2, scrollX = 1, scrollY = 1},
        {name = 'pillars', path = 'SS/pillars', x = -1500, y = -1050, scaleX = 1.2, scaleY = 1.2, scrollX = 1, scrollY = 1},
        {name = 'tv', path = 'SS/tv', x = -150, y = -700, scaleX = 1.2, scaleY = 1.2, scrollX = 1, scrollY = 1},
        {name = 'errorScreen', path = 'SS/error', x = -1100, y = -800, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1},
        {name = 'crystalWalls', path = 'SS/crystal-walls', x = -1500, y = -1100, scaleX = 1.2, scaleY = 1.25, scrollX = 1, scrollY = 1, front = true}
    },
    animated = {
        {name = 'exetiorEyes', path = 'SS/exetior-eyes', x = -1500, y = -1500, scaleX = 1.2, scaleY = 1.2, animName = 'idle', animPrefix = 'exetior-eyes', fps = 24, loop = false, alpha = 0},
        {name = 'spotlight2', path = 'SS/2nd/spotlight-2', x = -900, y = -2000, scaleX = 0.6, scaleY = 1.2, alpha = 0},
        {name = 'lights', path = 'SS/2nd/lights', x = -1100, y = -1500, scaleX = 0.7, scaleY = 0.8, blend = 'add', alpha = 0},
        {name = 'firstCharacter', path = 'SS/2nd/first', x = 1300, y = 0, scaleX = 1, scaleY = 1, animName = 'idle', animPrefix = '1', fps = 24, loop = false, alpha = 0, front = true},
        {name = 'thirdCharacter', path = 'SS/2nd/third', x = -1700, y = -320, scaleX = 1, scaleY = 1, animName = 'idle', animPrefix = '3', fps = 24, loop = false, alpha = 0, front = true}
    },
    overlays = {
        {name = 'blackVG', path = 'SS/overlays/BlackVG', x = 0, y = 0, scaleX = 1, scaleY = 1}
    }
}

local SpriteGroups = {
    phase1 = {'bg', 'floor', 'arch', 'pillars', 'tv', 'errorScreen', 'crystalWalls'},
    phase2 = {'exetiorEyes', 'spotlight2', 'lights', 'firstCharacter', 'thirdCharacter'},
    hideable = {'exetiorEyes', 'spotlight2', 'lights', 'firstCharacter', 'thirdCharacter', 'dad', 'boyfriend'},
    beatAnimated = {'firstCharacter', 'thirdCharacter', 'bfX'}
}

local function createSprite(config, isAnimated)
    if isAnimated then
        makeAnimatedLuaSprite(config.name, config.path, config.x, config.y)
        addAnimationByPrefix(config.name, config.animName, config.animPrefix, config.fps, config.loop)
    else
        makeLuaSprite(config.name, config.path, config.x, config.y)
    end

    scaleObject(config.name, config.scaleX or 1, config.scaleY or 1)
    setScrollFactor(config.name, config.scrollX or 1, config.scrollY or 1)
    setProperty(config.name .. '.antialiasing', true)
    setProperty(config.name .. '.alpha', config.alpha or 1)

    if config.blend then
        setBlendMode(config.name, config.blend)
    end

    addLuaSprite(config.name, config.front or false)
end

local function setSpriteAlpha(spriteList, alpha)
    for _, spriteName in ipairs(spriteList) do
        setProperty(spriteName .. '.alpha', alpha)
    end
end

local function parseEventParams(params)
    local result = {}
    for param in string.gmatch(params, '([^,]+)') do
        table.insert(result, string.gsub(param, '^%s*(.-)%s*$', '%1'))
    end
    return result
end

function onCreatePost()
    for _, config in ipairs(StageConfig.background) do
        createSprite(config, false)
    end

    for _, config in ipairs(StageConfig.animated) do
        createSprite(config, true)
    end

    for _, config in ipairs(StageConfig.overlays) do
        makeLuaSprite(config.name, config.path, config.x, config.y)
        scaleObject(config.name, config.scaleX, config.scaleY)
        setScrollFactor(config.name, config.scrollX or 1, config.scrollY or 1)
        setObjectCamera(config.name, 'camHUD')
        setProperty(config.name .. '.antialiasing', true)
        setProperty(config.name .. '.alpha', config.alpha or 0)
        addLuaSprite(config.name, config.front or false)
    end

    makeLuaSprite('blackStage', nil, -1400, -860)
    makeGraphic('blackStage', screenWidth * 4, screenHeight * 4, '000000')
    setProperty('blackStage.alpha', 0)
    addLuaSprite('blackStage', true)

    makeAnimatedLuaSprite('bfX', 'characters/bfx', getProperty('boyfriend.x') + 260, getProperty('boyfriend.y') - 160)
    addAnimationByPrefix('bfX', 'idle', 'idle', 24, false)
    addAnimationByPrefix('bfX', 'yeah', 'up', 24, true)
    setObjectOrder('bfX', getObjectOrder('blackStage') + 1)
    scaleObject('bfX', 0.7, 0.7)
    setProperty('bfX.alpha', 0)
    addLuaSprite('bfX', true)
end

local EventHandlers = {
    ['useOverlay'] = function(params)
        local splitParams = parseEventParams(params)
        if splitParams[1] == 'tween' and #splitParams >= 3 then
            doTweenAlpha('overlayAlpha', 'blackVG', tonumber(splitParams[2]) or 0, tonumber(splitParams[3]) or 1)
        elseif #splitParams >= 1 then
            setProperty('blackVG.alpha', tonumber(splitParams[1]) or 0)
        end
    end,

    ['part2'] = function()
        setSpriteAlpha(SpriteGroups.phase1, 0)
        setSpriteAlpha(SpriteGroups.phase2, 1)
    end,

    ['hide'] = function()
        setSpriteAlpha(SpriteGroups.hideable, 0)
    end,

    ['si'] = function()
        setProperty('blackStage.alpha', 1)
    end,

    ['tweenCharacter'] = function(character)
        if character == 'dad' then
            doTweenAlpha('dadAlpha', 'dad', 1, 0.5)
        elseif character == 'bfX' then
            doTweenAlpha('bfXAlpha', 'bfX', 1, 1)
            doTweenX('bfXTween', 'bfX', getProperty('boyfriend.x') + 87, 1.5, 'circOut')
            doTweenY('bfXYTween', 'bfX', getProperty('boyfriend.y') + 34, 1.5, 'circOut')
        elseif character == 'bf' then
            doTweenAlpha('bfAlpha', 'boyfriend', 1, 1)
            doTweenAlpha('bfXAlpha', 'bfX', 0, 0.6)
        end
    end,

    ['part1'] = function()
        doTweenAlpha('blackStageAlpha', 'blackStage', 0, 1)
        setSpriteAlpha(SpriteGroups.phase1, 1)
    end
}

function onEvent(eventName, value1, value2)
    if eventName == 'ssStageEvents' and EventHandlers[value1] then
        EventHandlers[value1](value2)
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
        for _, spriteName in ipairs(SpriteGroups.beatAnimated) do
            if getProperty(spriteName .. '.alpha') > 0 then
                playAnim(spriteName, 'idle', true)
            end
        end
    end
end

function goodNoteHit()
    if getProperty('bfX.alpha') == 1 then
        playAnim('bfX', 'yeah', true)
    end
end

function opponentNoteHitPre(id)
    if getProperty('dad.animation.curAnim.name') == 'laugh' then
        setPropertyFromGroup('notes', id, 'noAnimation', true)
    end
end