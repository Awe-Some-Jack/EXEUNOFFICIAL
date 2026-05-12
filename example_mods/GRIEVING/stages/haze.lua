local hazeBGAssets = {
    ['phase1'] = {
        { name = 'redSun', path = 'grieving/haze/1st/sol rojo', x = 0,  y = 0, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, animName = 'idle', animPrefix = 'sun', fps = 12, loop = true, alpha = 1, antialiasing = true, front = false},
    },
    ['phase2'] = {
        {name = 'bg',     path = 'grieving/uh-oh/new/sky',    x = -1150, y = -1600, scrollX = 0.3, scrollY = 0.3, front = false, lowQualityHide = true},
        {name = 'trees3', path = 'grieving/uh-oh/new/trees3', x = -1200, y = -1600, scrollX = 0.5, scrollY = 0.5, front = false, lowQualityHide = true},
        {name = 'trees2', path = 'grieving/uh-oh/new/trees2', x = -1350, y = -1600, scrollX = 0.7, scrollY = 0.7, front = false, lowQualityHide = true},
        {name = 'trees',  path = 'grieving/uh-oh/new/trees',  x = -1400, y = -1600, scrollX = 0.9, scrollY = 0.9, front = false, lowQualityHide = true},
        {name = 'floor',  path = 'grieving/uh-oh/new/floor',  x = -1400, y = -1700, scrollX = 1,   scrollY = 1,   front = false},
        {name = 'fore',   path = 'grieving/uh-oh/new/fore',   x = -1500, y = -1800, scrollX = 1.1, scrollY = 1.1, front = false, lowQualityHide = true}
    },
    ['phase3'] = {
        { name = 'sun-clouds', path = 'grieving/haze/2nd/sun-clouds',  x = -1600,  y = -1700,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'cloudFront', path = 'grieving/haze/2nd/cloudFront',  x = -1600,  y = -1700,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'water',      path = 'grieving/haze/2nd/water',       x = -1600,  y =  -300,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
        { name = 'waterfall1', path = 'grieving/haze/2nd/waterfall1',  x = -1600,  y = -1000,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1, animName = 'idle', animPrefix = 'water', fps = 12, loop = true, alpha = 1, antialiasing = true,     front = false},
        { name = 'waterfall2', path = 'grieving/haze/2nd/waterfall2',  x =   720,  y = -1300,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1, animName = 'idle', animPrefix = 'water', fps = 12, loop = true, alpha = 1, antialiasing = true,     front = false},
        { name = 'groundShit', path = 'grieving/haze/2nd/ground',      x = -1600,  y = -1300,  scaleX = 1, scaleY = 1, scrollX = 1,    scrollY = 1,                                                                 alpha = 1, antialiasing = true,     front = false},
    },
    ['phase4'] = {
        { name = 'sky',                   path = 'grieving/haze/3rd/6',       x = -1000,  y = -1300,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds1',               path = 'grieving/haze/3rd/5',       x =  -500,  y = -1000,     instance = true,    scrollX = 1,    scrollY = 1,  velocityX = 50,  alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds2',               path = 'grieving/haze/3rd/4',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds-mountains',      path = 'grieving/haze/3rd/3',       x = -1000,  y = -1000,                         scrollX = 1,    scrollY = 1,                   alpha = 0, antialiasing = true,     front = false},
        { name = 'clouds3',               path = 'grieving/haze/3rd/2',       x = -1000,  y =     0,                         scrollX = 0.95, scrollY = 0.95,                alpha = 0, antialiasing = true,     front = true},
        { name = 'ground',                path = 'grieving/haze/3rd/1',       x = -1000,  y =     0,                         scrollX = 0.95, scrollY = 0.95,                alpha = 0, antialiasing = true,     front = true},
    }
}

local spriteGroups = {
    phase1 = {'redSun'},
    phase2 = {'bg', 'trees3', 'trees2', 'trees', 'floor', 'fore'},
    phase3 = {'overlay', 'sun-clouds', 'cloudFront', 'water', 'waterfall1', 'waterfall2', 'ground', 'dedplants'},
    phase4 = {'sky', 'clouds1', 'clouds2', 'clouds-mountains', 'clouds3', 'ground'}
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
    if yea.scaleX or yea.scaleY then scaleObject(yea.name, yea.scaleX, yea.scaleY) end
    setScrollFactor(yea.name, yea.scrollX, yea.scrollY)
    if yea.alpha then setProperty(yea.name..'.alpha', yea.alpha) end
    if yea.antialiasing then setProperty(yea.name..'.antialiasing', yea.antialiasing) end
    addLuaSprite(yea.name, yea.front)
end

local function setSpriteAlpha(spriteList, alpha) -- Lo siento Kazu esto funciona pero se está bugeadito 😭
    for _, spriteName in ipairs(spriteList) do
        setProperty(spriteName .. '.alpha', alpha)
    end
end

function onCreatePost()
    for _, spr in ipairs(hazeBGAssets['phase1']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase2']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase3']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase4']) do addSprite(spr) end


    for _, phase1 in ipairs(hazeBGAssets['phase1']) do setProperty(phase1.name..'.alpha', 1) end
    for _, phase2 in ipairs(hazeBGAssets['phase2']) do setProperty(phase2.name..'.alpha', 0) end
    for _, phase3 in ipairs(hazeBGAssets['phase3']) do setProperty(phase3.name..'.alpha', 0) end
    for _, phase4 in ipairs(hazeBGAssets['phase4']) do setProperty(phase4.name..'.alpha', 0) end

    setProperty('dad.visible', false)
    setObjectOrder('clouds3', getObjectOrder('dadGroup') + 1)
end