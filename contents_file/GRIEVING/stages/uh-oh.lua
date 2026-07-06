local uhOhBG = {
    {name = 'bg', path = 'grieving/uh-oh/new/sky', x = -1150, y = -1600, scrollX = 0.3, scrollY = 0.3, front = false, lowQualityHide = true},
    {name = 'trees3', path = 'grieving/uh-oh/new/trees3', x = -1200, y = -1600, scrollX = 0.5, scrollY = 0.5, front = false, lowQualityHide = true},
    {name = 'trees2', path = 'grieving/uh-oh/new/trees2', x = -1350, y = -1600, scrollX = 0.7, scrollY = 0.7, front = false, lowQualityHide = true},
    {name = 'trees', path = 'grieving/uh-oh/new/trees', x = -1400, y = -1600, scrollX = 0.9, scrollY = 0.9, front = false, lowQualityHide = true},
    {name = 'floor', path = 'grieving/uh-oh/new/floor', x = -1400, y = -1700, scrollX = 1, scrollY = 1, front = false},
    {name = 'fore', path = 'grieving/uh-oh/new/fore', x = -1500, y = -1800, scrollX = 1.1, scrollY = 1.1, front = false, lowQualityHide = true}
}

local graphics = {
    {name = 'BlackGraphicBehind', color = '000000', scaleX = 5, scaleY = 5, behind = true, camera = 'camGame', alpha = 0, front = false},

    {name = 'RedGraphicGameBlendADD', color = 'FF0000', scaleX = 5, scaleY = 5, camera = 'camGame', blend = 'ADD', alpha = 0, front = false},
}

function onCreatePost()
    for _, pepe in ipairs(uhOhBG) do
        if not (lowQuality and pepe.lowQualityHide) then
            makeLuaSprite(pepe.name, pepe.path, pepe.x, pepe.y)
            setScrollFactor(pepe.name, pepe.scrollX, pepe.scrollY)
            addLuaSprite(pepe.name, pepe.front)
            setProperty(pepe.name..'.antialiasing', not lowQuality)
        end
    end

    makeLuaSprite('overlay', 'grieving/uh-oh/Overlay', 0, 0)
    setObjectCamera('overlay', 'camOther')
    setProperty('overlay.alpha', 0)
    addLuaSprite('overlay', false)

    for _, urmom in ipairs(graphics) do
        makeLuaSprite(urmom.name)
        makeGraphic(urmom.name, screenWidth * 2, screenHeight * 2, urmom.color)
        scaleObject(urmom.name, urmom.scaleX, urmom.scaleY)
        setObjectCamera(urmom.name, urmom.camera)
        setProperty(urmom.name..'.alpha', urmom.alpha)
        screenCenter(urmom.name)
        if urmom.behind then
            setObjectOrder(urmom.name, getObjectOrder('floor') + 1)
        end
        if urmom.blend then
            setBlendMode(urmom.name, urmom.blend)
        end
        addLuaSprite(urmom.name, urmom.front)
    end
end