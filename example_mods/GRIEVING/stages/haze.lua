local hazeBG2 = {
    { name = 'sky',     path = 'grieving/haze/2nd/21',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,     alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds1',     path = 'grieving/haze/2nd/20',  x = -1000,  y = -1000, instance = true,    scrollX = 1, scrollY = 1,   velocityX = 5,     alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds2',     path = 'grieving/haze/2nd/19',  x = -1000,  y = -1000, instance = true,    scrollX = 1, scrollY = 1,   velocityX = 9,    alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds3',     path = 'grieving/haze/2nd/18',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds4',     path = 'grieving/haze/2nd/17',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds5',     path = 'grieving/haze/2nd/16',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'mountains1',     path = 'grieving/haze/2nd/15',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'mountains2',     path = 'grieving/haze/2nd/14',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds6',     path = 'grieving/haze/2nd/13',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,        alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds7',     path = 'grieving/haze/2nd/12',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,        alpha = 1, antialiasing = true,     front = false},
    { name = 'mountains3',     path = 'grieving/haze/2nd/11',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds8',     path = 'grieving/haze/2nd/10',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,        alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds9',     path = 'grieving/haze/2nd/9',  x = -1000,  y = -1000,   scrollX = 1, scrollY = 1,        alpha = 1, antialiasing = true,     front = false},
    { name = 'pillars1',     path = 'grieving/haze/2nd/8',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds10',     path = 'grieving/haze/2nd/7',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,        alpha = 1, antialiasing = true,     front = false},
    { name = 'pillars2',     path = 'grieving/haze/2nd/6',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'ground',     path = 'grieving/haze/2nd/3',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,      alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds11',     path = 'grieving/haze/2nd/5',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,        alpha = 1, antialiasing = true,     front = false},
    { name = 'clouds12',     path = 'grieving/haze/2nd/4',  x = -1000,  y = -1000,    scrollX = 1, scrollY = 1,   velocityX = 50,      alpha = 1, antialiasing = true,     front = false},
    { name = 'smth1',     path = 'grieving/haze/2nd/2',  x = -1000,  y = -1000,    scrollX = 0.95, scrollY = 0.95,      alpha = 1, antialiasing = true,     front = true},
    { name = 'smth2',     path = 'grieving/haze/2nd/1',  x = -1000,  y = -1000,    scrollX = 0.95, scrollY = 0.95,      alpha = 1, antialiasing = true,     front = true},
}

local function addSprite(yea)
    if yea.instance then
        createInstance(yea.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
        loadGraphic(yea.name, yea.path)
        callMethod(yea.name..'.setPosition', {yea.x, yea.y})
        setProperty(yea.name..'.velocity.x', yea.velocityX)
    else
        makeLuaSprite(yea.name, yea.path, yea.x, yea.y)
    end
    setScrollFactor(yea.name, yea.scrollX, yea.scrollY)
    setProperty(yea.name..'.alpha', yea.alpha)
    setProperty(yea.name..'.antialiasing', yea.antialiasing)
    addLuaSprite(yea.name, yea.front)
end

function onCreatePost()
    for _, spr in ipairs(hazeBG2) do
        addSprite(spr)
    end

    setObjectOrder('dadGroup', getObjectOrder('clouds9'))
end