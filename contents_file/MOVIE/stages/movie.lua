local sprites = {
    {name = 'bg3', path = 'bg/3', x = -230, y = -300, scale = 1},
    {name = 'bg2', path = 'bg/2', x = -230, y = -300, scale = 1, front = true},
    {name = 'bg1', path = 'bg/1', x = -230, y = -300, scale = 1, front = true},
}

local function addSprite(def)
    makeLuaSprite(def.name, def.path, def.x, def.y)
    scaleObject(def.name, def.scale or 1, def.scale or 1)
    setScrollFactor(def.name, 1, 1)
    setProperty(def.name .. '.antialiasing', not lowQuality)
    addLuaSprite(def.name, def.front or false)
end

local videoPlayed = false

function onCreate()
    for _, spr in ipairs(sprites) do
        addSprite(spr)
    end
end

function onSongStart()
    doTweenAlpha('graphAlpha', 'BlackGraphicHUD', 0, crochet / (1000 / 32))
end

function onStartCountdown()
    if not videoPlayed and not seenCutscene then
        startVideo('cutscene')
        videoPlayed = true
        return Function_Stop
    end
end

function onCountdownStarted()
    for i = 0, 7 do
        setProperty('strumLineNotes.members[' .. i .. '].x', _G['default' .. (i < 4 and 'Player' or 'Opponent') .. 'StrumX' .. (i % 4)])
    end
    triggerEvent('Flip Health Bar')
    setProperty('BlackGraphicHUD.alpha', 1)
end
