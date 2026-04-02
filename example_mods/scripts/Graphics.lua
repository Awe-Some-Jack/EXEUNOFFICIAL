-- A scirpt that creates graphics for the mod so you don't create them every song

local graphics = {
    {name = 'BlackGraphicGame', color = '000000', scaleX = 4, scaleY = 4, camera = 'camGame', alpha = 0, front = true},
    {name = 'BlackGraphicHUD', color = '000000', scaleX = 4, scaleY = 4, camera = 'camHUD', alpha = 0, front = true},
    {name = 'BlackGraphicOther', color = '000000', scaleX = 4, scaleY = 4, camera = 'camOther', alpha = 0, front = false},

    {name = 'BlackGraphicBehind', color = '000000', scaleX = 5, scaleY = 5, behind = true, camera = 'camGame', alpha = 0, front = false},

    {name = 'RedGraphicGameBlendADD', color = 'FF0000', scaleX = 5, scaleY = 5, camera = 'camGame', blend = 'ADD', alpha = 0, front = false},
}

function onCreatePost()
    for _, urmom in ipairs(graphics) do
        makeLuaSprite(urmom.name)
        makeGraphic(urmom.name, screenWidth, screenHeight, urmom.color)
        scaleObject(urmom.name, urmom.scaleX, urmom.scaleY)
        setObjectCamera(urmom.name, urmom.camera)
        setProperty(urmom.name..'.alpha', urmom.alpha)
        screenCenter(urmom.name)
        if urmom.behind then
            setObjectOrder(urmom.name, getObjectOrder('dadGroup'))
        end
        if urmom.blend then
            setBlendMode(urmom.name, urmom.blend)
        end
        addLuaSprite(urmom.name, urmom.front)
    end
end