--[[Ideas de eventos
 - Al principio, se oscurecerá el juego, poco a poco se ira subiendo, y la camara estará centrada en devoid.
 - Con el beat, se irá quitando la oscuridad poco a poco.
]]
local hollowBG = {
    {name = 'cielo', path = 'hollow/cielo_hollow', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 0.95, scrollY = 0.95, alpha = 1, antialiasing = true, front = false},
    {name = 'luna', path = 'hollow/luna_hollow', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, alpha = 1, antialiasing = true, front = false},
    {name = 'ciudad', path = 'hollow/ciudad (4)', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, alpha = 1, antialiasing = true, front = false},
    {name = 'suelo', path = 'hollow/suelo con rocas (3)', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, antialiasing = true, front = false},
    {name = 'arboles', path = 'hollow/arboles (2)', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, antialiasing = true, front = false},
    {name = 'arbustos', path = 'hollow/arbustos (1)', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, antialiasing = true, front = false},
}

local cloudsLoop = {
    {name = 'clouds1', path = 'hollow/nubes', velocity = 50, x = -1950, spacingX = 0},
    {name = 'clouds2', path = 'hollow/nubes2', velocity = 50, x = -1450, spacingX = 0},
    {name = 'clouds3', path = 'hollow/nubes3', velocity = 50, x = -2650, spacingX = 0},
}

function onCreate()
    for _, e in ipairs(hollowBG) do
        makeLuaSprite(e.name, e.path, e.x, e.y)
        scaleObject(e.name, e.scaleX, e.scaleY)
        setScrollFactor(e.name, e.scrollX, e.scrollY)
        setProperty(e.name..'.alpha', e.alpha)
        setProperty(e.name..'.antialiasing', e.antialiasing)
        addLuaSprite(e.name, e.front)
    end

    for _, o in ipairs(cloudsLoop) do
        createInstance(o.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
        loadGraphic(o.name, o.path)
        callMethod(o.name..'.setPosition', {o.x, o.y})
        setProperty(o.name..'.velocity.x', 50)
        addInstance(o.name)
    end

    makeLuaSprite('night', nil, 0, 0)
    makeGraphic('night', screenWidth * 2, screenHeight * 2, '060d94')
    setProperty('night.alpha', 0.3)
    scaleObject('night', 3, 3)
    addLuaSprite('night', true)
end