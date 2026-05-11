local hazeBGAssets = {
    ['phase1'] = {
        { name = 'redSun',          path = 'grieving/haze/1st/sol rojo',  x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1, animName = 'idle', animPrefix = 'sun', fps = 12, loop = true, alpha = 1, antialiasing = true,     front = false},
    },
    ['phase2'] = {
        { name = 'overlay',         path = 'grieving/haze/2nd/redSky',      x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'sun-clouds',      path = 'grieving/haze/2nd/sun-clouds',  x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'cloudFront',      path = 'grieving/haze/2nd/cloudFront',  x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'water',           path = 'grieving/haze/2nd/water',       x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'waterfall1',      path = 'grieving/haze/2nd/waterfall1',  x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1, animName = 'idle', animPrefix = 'water', fps = 12, loop = true, alpha = 1, antialiasing = true,     front = false},
        { name = 'waterfall2',      path = 'grieving/haze/2nd/waterfall2',  x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1, animName = 'idle', animPrefix = 'water', fps = 12, loop = true, alpha = 1, antialiasing = true,     front = false},
        { name = 'groundShit',      path = 'grieving/haze/2nd/ground',      x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'dedplants',       path = 'grieving/haze/2nd/dedplants',   x = -1000,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
    },
    ['phase3'] = {
        { name = 'sky',         path = 'grieving/haze/3rd/21',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds1',     path = 'grieving/haze/3rd/20',      x = -1000,  y = -1000,    instance = true,     scrollX = 1,    scrollY = 1,   velocityX = 5,  alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds2',     path = 'grieving/haze/3rd/19',      x = -1000,  y = -1000,    instance = true,     scrollX = 1,    scrollY = 1,   velocityX = 9,  alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds3',     path = 'grieving/haze/3rd/18',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds4',     path = 'grieving/haze/3rd/17',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds5',     path = 'grieving/haze/3rd/16',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'mountains1',  path = 'grieving/haze/3rd/15',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'mountains2',  path = 'grieving/haze/3rd/14',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds6',     path = 'grieving/haze/3rd/13',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds7',     path = 'grieving/haze/3rd/12',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'mountains3',  path = 'grieving/haze/3rd/11',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds8',     path = 'grieving/haze/3rd/10',      x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds9',     path = 'grieving/haze/3rd/9',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'pillars1',    path = 'grieving/haze/3rd/8',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds10',    path = 'grieving/haze/3rd/7',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'pillars2',    path = 'grieving/haze/3rd/6',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'ground',      path = 'grieving/haze/3rd/3',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds11',    path = 'grieving/haze/3rd/5',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds12',    path = 'grieving/haze/3rd/4',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,   velocityX = 50, alpha = 0, antialiasing = true,     front = false},
        { name = 'smth1',       path = 'grieving/haze/3rd/2',       x = -1000,  y = -1000,                         scrollX = 0.95, scrollY = 0.95,                alpha = 0, antialiasing = true,     front = true},
        { name = 'smth2',       path = 'grieving/haze/3rd/1',       x = -1000,  y = -1000,                         scrollX = 0.95, scrollY = 0.95,                alpha = 0, antialiasing = true,     front = true},
    }
}

local spriteGroups = {
    phase1 = {'redSun'},
    phase2 = {'overlay', 'sun-clouds', 'cloudFront', 'water', 'waterfall1', 'waterfall2', 'ground', 'dedplants'},
    phase3 = {'sky', 'clouds1', 'clouds2', 'clouds3', 'clouds4', 'clouds5', 'mountains1', 'mountains2', 'clouds6', 'clouds7', 'mountains3', 'clouds8', 'clouds9', 'pillars1', 'clouds10', 'pillars2', 'ground', 'clouds11', 'clouds12', 'smth1', 'smth2'}
}

local function addSprite(yea)
    if yea.instance then
        createInstance(yea.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
        loadGraphic(yea.name, yea.path)
        callMethod(yea.name..'.setPosition', {yea.x, yea.y})
        setProperty(yea.name..'.velocity.x', yea.velocityX)
    else
        if yea.animName ~= nil then
            makeAnimatedLuaSprite(yea.name, yea.path, yea.x, yea.y)
            addAnimationByPrefix(yea.name, yea.animName, yea.animPrefix, yea.fps, yea.loop)
        else
            makeLuaSprite(yea.name, yea.path, yea.x, yea.y)
        end
    end
    setScrollFactor(yea.name, yea.scrollX, yea.scrollY)
    setProperty(yea.name..'.alpha', yea.alpha)
    setProperty(yea.name..'.antialiasing', yea.antialiasing)
    addLuaSprite(yea.name, yea.front)
end

local function setSpriteAlpha(spriteList, alpha)
    for _, spriteName in ipairs(spriteList) do
        setProperty(spriteName .. '.alpha', alpha)
    end
end

function onCreatePost()
    for _, spr in ipairs(hazeBGAssets['phase1']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase2']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase3']) do addSprite(spr) end

    setSpriteAlpha(spriteGroups.phase1, 1)
    setSpriteAlpha(spriteGroups.phase2, 0)
    setSpriteAlpha(spriteGroups.phase3, 0)
    setObjectOrder('dadGroup', getObjectOrder('clouds9'))
end