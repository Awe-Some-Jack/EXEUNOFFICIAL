local sprites = {
    {name = 'bush',  path = 'bg/bush',  x = 0, y = 0, scale = 1},
    {name = 'floor', path = 'bg/floor', x = 0, y = 0, scale = 1},
    {name = 'house', path = 'bg/house', x = 0, y = 0, scale = 1},
    {name = 'desk',  path = 'bg/desk',  x = 0, y = 0, scale = 1, front = true},
}

local function addSprite(def)
    makeLuaSprite(def.name, def.path, def.x, def.y)
    scaleObject(def.name, def.scaleX or def.scale or 1, def.scaleY or def.scale or 1)
    setScrollFactor(def.name, def.scrollX or 1, def.scrollY or 1)
    setProperty(def.name .. '.antialiasing', not lowQuality)
    addLuaSprite(def.name, def.front or false)
end

local videoPlayed = false

function onCreate()
    for _, spr in ipairs(sprites) do
        addSprite(spr)
    end
end

function onSongStart() doTweenAlpha('graphAlpha', 'BlackGraphicHUD', 0, crochet / (1000 / 32)) end

function onStartCountdown()
    if not videoPlayed and not seenCutscene then
        startVideo('cutscene')
        videoPlayed = true
        return Function_Stop
    end
end

function onCountdownStarted()
    for i = 0,7 do setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)]) end
    triggerEvent('Flip Health Bar')

    setProperty('BlackGraphicHUD.alpha', 1)
end