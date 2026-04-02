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
    
    setProperty('gf.visible', false)
end

function onStartCountdown()
    if not videoPlayed then
        startVideo('cutscene')
        videoPlayed = true
        return Function_Stop
    end
end

function onCountdownTick(tick)
    return Function_Stop
end

function onSongStart()
    for i = 0,3 do
        noteTweenX('swapPlayer'..i, i + 4, _G['defaultOpponentStrumX'..i], 0.001, 'linear')
        noteTweenX('swapOpp'..i, i, _G['defaultPlayerStrumX'..i], 0.001, 'linear')
    end
    triggerEvent('Flip Health Bar', '', '')
end
