local StageConfig = {
    background = {
        {name = 'bg', path = 'SS/bg', x = -1500, y = -1500, scaleX = 1.2, scaleY = 1.2, scrollX = 0.8, scrollY = 0.8},
        {name = 'floor', path = 'SS/floor', x = -1500, y = 500, scaleX = 1.2, scaleY = 1.6, scrollX = 1, scrollY = 1},
        {name = 'arch', path = 'SS/arch', x = -1000, y = -730, scaleX = 1.2, scaleY = 1.2, scrollX = 1, scrollY = 1},
        {name = 'pillars', path = 'SS/pillars', x = -1500, y = -1050, scaleX = 1.2, scaleY = 1.2, scrollX = 1, scrollY = 1},
        {name = 'tv', path = 'SS/tv', x = -150, y = -700, scaleX = 1.2, scaleY = 1.2, scrollX = 1, scrollY = 1},
        {name = 'errorScreen', path = 'SS/error', x = -1100, y = -800, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1},
        {name = 'crystalWalls', path = 'SS/crystal-walls', x = -1500, y = -1100, scaleX = 1.2, scaleY = 1.25, scrollX = 1, scrollY = 1, front = true},
        {name = 'crystalWalls', path = 'SS/crystal-walls', x = -1500, y = -1100, scaleX = 1.2, scaleY = 1.25, scrollX = 1, scrollY = 1, front = true},
        {name = 'spotlight2', path = 'SS/2nd/spotlight-2', x = -1100, y = -2000, scaleX = 0.68, scaleY = 1.2, alpha = 0},
        {name = 'spotlight', path = 'SS/2nd/spotlight-1',  x = -2300, y = -1900, scaleX = 1.2, scaleY = 1.2, alpha = 0},
        {name = 'lights', path = 'SS/2nd/lights', x = -1100, y = -1500, scaleX = 0.7, scaleY = 0.8, blend = 'add', alpha = 0},
    },
    animated = {
        {name = 'eggman', path = 'characters/eggman', x = -1000, y = -140, scaleX = 1.2, scaleY = 1.2, animName = 'idle', animPrefix = 'eggman', fps = 24, loop = false, alpha = 1},
        {name = 'knux', path = 'characters/k', x = -1200, y = -750, scaleX = 1, scaleY = 1, animName = 'idle', animPrefix = 'knux', fps = 24, behindPillars = true, loop = false, alpha = 1},
        {name = 'tails', path = 'characters/tails', x = 1200, y = -750, scaleX = 1, scaleY = 1, animName = 'idle', animPrefix = 'tails', fps = 24, loop = false, alpha = 1},
        {name = 'exeeye', path = 'characters/exe1', x = -100, y = -150, scaleX = 0.8, scaleY = 0.8, animName = 'idle', animPrefix = 'idle', fps = 24, loop = false, behindLights = true, alpha = 0},
        {name = 'exelerr', path = 'characters/exeller', x = 1300, y = 190, scaleX = 1.2, scaleY = 1.2, animName = 'idle', animPrefix = 'Símbolo 23', fps = 24, loop = false, alpha = 0, front = true},
        {name = 'sark', path = 'characters/sark', x = -1700, y = 120, scaleX = 1.2, scaleY = 1.2, animName = 'idle', animPrefix = 'sark', fps = 24, loop = false, alpha = 0, front = true}
    },
    overlays = {
        {name = 'blackVG', path = 'VG', x = 0, y = 0, scaleX = 1, scaleY = 1}
    }
}

local SpriteGroups = {
    phase1 = {'bg', 'floor', 'arch', 'pillars', 'tv', 'errorScreen', 'crystalWalls', 'eggman', 'knux', 'tails', 'gfEXE'},
    phase2 = {'exetiorEyes', 'spotlight', 'spotlight2', 'lights', 'exelerr', 'sark', 'exeeye'},
    hideable = {'exetiorEyes', 'spotlight', 'spotlight2', 'lights', 'exelerr', 'sark', 'exeeye', 'dad', 'boyfriend', 'gfEXE'},
    beatAnimated = {'exelerr', 'sark', 'bfX', 'eggman', 'knux', 'tails', 'exeeye'},
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

    if config.behindPillars ~= nil then setObjectOrder(config.name, getObjectOrder('pillars')) end
    if config.behindLights  ~= nil then setObjectOrder(config.name, getObjectOrder('lights'))  end
    if config.blend then setBlendMode(config.name, config.blend) end

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
        table.insert(result, tonumber(string.gsub(param, '^%s*(.-)%s*$', '%1')))
    end
    return result
end

luaDebugMode = true
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
    setProperty('blackVG.color', getColorFromHex('000000'))

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

    makeAnimatedLuaSprite('gfEXE', 'characters/gf', 0, -80)
    addAnimationByIndices('gfEXE', 'danceLeft', 'gf idle instancia',  {0,1,2,3,4,5,6,7,8,9})
    addAnimationByIndices('gfEXE', 'danceRight', 'gf idle instancia', {10,11,12,13,14,15,16,17,18,19})
    addLuaSprite('gfEXE')
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
    playAnim('gfEXE', curBeat %2 == 1 and 'danceRight' or 'danceLeft')
    --debugPrint(getProperty('gfEXE.animation.curAnim.name'))
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
    if getProperty('dad.animation.curAnim.name') == 'laugh' then setPropertyFromGroup('notes', id, 'noAnimation', true) end
end