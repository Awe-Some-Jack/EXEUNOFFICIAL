local StageConfig = {
    background = {
        {name = 'bg',           path = 'SS/bg',               x = -1500, y = -1500, scaleX = 1.2,  scaleY = 1.2,  scrollX = 0.8, scrollY = 0.8},
        {name = 'floor',        path = 'SS/floor',            x = -1500, y = 500,   scaleX = 1.2,  scaleY = 1.6,  scrollX = 1, scrollY = 1},
        {name = 'arch',         path = 'SS/arch',             x = -1000, y = -730,  scaleX = 1.2,  scaleY = 1.2,  scrollX = 1, scrollY = 1},
        {name = 'pillars',      path = 'SS/pillars',          x = -1500, y = -1050, scaleX = 1.2,  scaleY = 1.2,  scrollX = 1, scrollY = 1},
        {name = 'tv',           path = 'SS/tv',               x = -150,  y = -700,  scaleX = 1.2,  scaleY = 1.2,  scrollX = 1, scrollY = 1},
        {name = 'errorScreen',  path = 'SS/error',            x = -1100, y = -800,  scaleX = 1,    scaleY = 1,    scrollX = 1, scrollY = 1},
        {name = 'crystalWalls', path = 'SS/crystal-walls',    x = -1500, y = -1100, scaleX = 1.2,  scaleY = 1.25, scrollX = 1, scrollY = 1, front = true},
        {name = 'crystalWalls', path = 'SS/crystal-walls',    x = -1500, y = -1100, scaleX = 1.2,  scaleY = 1.25, scrollX = 1, scrollY = 1, front = true},
        {name = 'spotlight2',   path = 'SS/2nd/spotlight-2',  x = -1100, y = -2000, scaleX = 0.68, scaleY = 1.2,                               alpha = 0},
        {name = 'spotlight',    path = 'SS/2nd/spotlight-1',  x = -2300, y = -1900, scaleX = 1.2,  scaleY = 1.2,                               alpha = 0},
        {name = 'lights',       path = 'SS/2nd/lights',       x = -1100, y = -1500, scaleX = 0.7,  scaleY = 0.8,                blend = 'add', alpha = 0},
    },
    animated = {
        {name = 'eggman',  path = 'characters/eggman',  x = -930, y =  -170,   scaleX = 1.35, scaleY = 1.35, animName = 'idle', animPrefix = 'eggman',     fps = 24, loop = false,                       alpha = 1},
        {name = 'knux',    path = 'characters/k',       x = -1200, y = -750,   scaleX = 1,    scaleY = 1,    animName = 'idle', animPrefix = 'knux',       fps = 24, behindPillars = true, loop = false, alpha = 1},
        {name = 'tails',   path = 'characters/tails',   x = 1200,  y = -750,   scaleX = 1,    scaleY = 1,    animName = 'idle', animPrefix = 'tails',      fps = 24, loop = false,                       alpha = 1},
        {name = 'exeeye',  path = 'characters/exe1',    x = -100,  y = -150,   scaleX = 0.8,  scaleY = 0.8,  animName = 'idle', animPrefix = 'idle',       fps = 24, loop = false, behindLights = true,  alpha = 0},
        {name = 'exelerr', path = 'characters/exeller', x = 1300,  y =  150,   scaleX = 1.2,  scaleY = 1.2,  animName = 'idle', animPrefix = 'Símbolo 23', fps = 24, loop = false,                       alpha = 0, scrollX = 0.3, scrollY = 0.3, front = true},
        {name = 'sark',    path = 'characters/sark',    x = -1600, y =  90,    scaleX = 1.2,  scaleY = 1.2,  animName = 'idle', animPrefix = 'sark',       fps = 24, loop = false,                       alpha = 0, scrollX = 0.3, scrollY = 0.3, front = true}
    },
    overlays = {
        {name = 'blackVG', path = 'VG',                 x = 0,     y = 0,    scaleX = 1,   scaleY = 1}
    }
}

local SpriteGroups = {
    phase1 = {'bg', 'floor', 'arch', 'pillars', 'tv', 'errorScreen', 'crystalWalls', 'eggman', 'knux', 'tails', 'gfEXE'},
    phase2 = {'exetiorEyes', 'spotlight', 'spotlight2', 'lights', 'exelerr', 'sark', 'exeeye', 'ojoexe'},
    hideable = {'exetiorEyes', 'spotlight', 'spotlight2', 'lights', 'exelerr', 'sark', 'exeeye', 'dad', 'boyfriend', 'gfEXE', 'ojoexe'},
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
    setProperty('blackVG.color', getColorFromHex('000000'))

    makeLuaSprite('blackStage', nil, -1400, -860)
    makeGraphic('blackStage', screenWidth * 4, screenHeight * 4, '000000')
    setProperty('blackStage.alpha', 0)
    addLuaSprite('blackStage', true)

    makeLuaSprite('ojoexe', 'characters/ojo-exe1', getProperty('exeeye.x') + 280, getProperty('exeeye.y') + 170)
    setObjectOrder('ojoexe', getObjectOrder('exeeye') + 1)
    scaleObject('ojoexe', 0.22, 0.22)
    setProperty('ojoexe.alpha', 0)
    addLuaSprite('ojoexe', true)

    makeAnimatedLuaSprite('bfX', 'characters/bfx', getProperty('boyfriend.x') + 260, getProperty('boyfriend.y') - 160)
    addAnimationByPrefix('bfX', 'idle', 'idle', 24, false)
    addAnimationByPrefix('bfX', 'yeah', 'singUp', 24, true)
    addAnimationByPrefix('bfX', 'yeahMISS', 'missUp', 24, true)
    setObjectOrder('bfX', getObjectOrder('blackStage') + 1)
    scaleObject('bfX', 0.72, 0.72)
    setProperty('bfX.alpha', 0)
    addLuaSprite('bfX', true)

    makeAnimatedLuaSprite('gfEXE', 'characters/gf', 0, -80)
    addAnimationByPrefix('gfEXE', 'danceLeft', 'dance left')
    addAnimationByPrefix('gfEXE', 'danceRight', 'dance right')
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
        setProperty('boyfriend.x', getProperty('boyfriend.x') + 120)
    end,

    ['hide'] = function()
        setSpriteAlpha(SpriteGroups.hideable, 0)
    end,

    ['si'] = function()
        setProperty('blackStage.alpha', 1)
    end,

    ['hideHUD'] = function(back)
        for _, HUD in ipairs({'exeScoreTxt', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp'}) do doTweenAlpha(HUD..'Alpha', HUD, back == 'true' and 1 or 0, 1.2, 1) end
        for i = 0, 7  do noteTweenAlpha(i..'Alpha', i, back == 'true' and 1 or 0, 1.2, 1) end
    end,

    ['noteTween'] = function(note)
        noteTweenAlpha(note..'Alpha', note, 0.5, 1.2, 1)
    end,

    ['tweenCharacter'] = function(character)
        if character == 'dad' then
            doTweenAlpha('dadAlpha', 'dad', 1, 0.5)
        elseif character == 'bfX' then
            setProperty('boyfriend.x', getProperty('boyfriend.x') - 120)
            doTweenAlpha('bfXAlpha', 'bfX', 1, 1)
            doTweenX('bfXTween', 'bfX', getProperty('boyfriend.x') + 61, 1.5, 'circOut')
            doTweenY('bfXYTween', 'bfX', getProperty('boyfriend.y') + 42, 1.5, 'circOut')
        elseif character == 'bf' then
            doTweenAlpha('bfAlpha', 'boyfriend', 1, 1)
            doTweenAlpha('bfXAlpha', 'bfX', 0, 1)
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
    if eventName == 'ssStageEvents' then
        if value1 == "tweenObject" then
			local split = stringSplit(value2, ', ')
			doTweenAlpha(split[1]..'OP', split[1], split[2], split[3])
		end
    end
end

function onBeatHit()
    playAnim('gfEXE', curBeat %2 == 1 and 'danceRight' or 'danceLeft')
    if curBeat % 2 == 0 then
        for _, spriteName in ipairs(SpriteGroups.beatAnimated) do
            if getProperty(spriteName .. '.alpha') > 0 then
                playAnim(spriteName, 'idle', true)
            end
        end
    end
end



local holdMove = 0
function onUpdatePost(elapsed)
    holdMove = holdMove + elapsed
    if getProperty('exeeye.alpha') == 1 then
        callMethod('exeeye.setPosition', {
            getProperty('exeeye.x') + math.cos(holdMove + 0.1) * 0.4,
            getProperty('exeeye.y') + math.sin(holdMove + 0.5) * 0.3
        })

        callMethod('ojoexe.setPosition', {
            getProperty('ojoexe.x') + math.cos(holdMove + 0.1) * 0.4,
            getProperty('ojoexe.y') + math.sin(holdMove + 0.5) * 0.3
        })
    end
end

function onSectionHit()
    doTweenX('ojotween', 'ojoexe', mustHitSection and getProperty('exeeye.x') + 190 or getProperty('exeeye.x') + 140, 0.8, 'smootherStepInOut')
end

function goodNoteHit()
    if getProperty('bfX.alpha') == 1 then
        playAnim('bfX', 'yeah', true)
        setProperty('bfX.y', getProperty('bfX.y') - 50)
        runTimer('returnBFX', 0.31)
    end
end

function noteMiss()
    if getProperty('bfX.alpha') == 1 then
        playAnim('bfX', 'yeahMISS', true)
        setProperty('bfX.y', getProperty('bfX.y') - 50)
        runTimer('returnBFX', 0.31)
    end
end

function opponentNoteHitPre(id)
    if getProperty('dad.animation.curAnim.name') == 'laugh' then setPropertyFromGroup('notes', id, 'noAnimation', true) end
end

function onTimerCompleted(t)
    if t == 'returnBFX' then setProperty('bfX.y', getProperty('bfX.y') + 50) end
end