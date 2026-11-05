local uhOhBG = {
    {name =     'bg', path =       'grieving/uh-oh/new/sky',        x = -1150, y = -1600,                                                                            scrollX = 0.3, scrollY = 0.3, front = false, lowQualityHide = true},
    {name =    'ola', path = 'grieving/uh-oh/new/sebasolas',        x =   190, y =  -140, animName = 'idle', animPrefix = 'olas instancia 1', fps = 24, loop = true, scrollX = 0.3, scrollY = 0.3, front = false, lowQualityHide = true},
    {name = 'trees3', path =    'grieving/uh-oh/new/trees3',        x = -1500, y =  -600,                                                                            scrollX = 0.5, scrollY = 0.5, front = false, lowQualityHide = true},
    {name = 'trees2', path =    'grieving/uh-oh/new/trees2',        x = -1350, y = -1400,                                                                            scrollX = 0.7, scrollY = 0.7, front = false, lowQualityHide = true},
    {name =  'trees', path =     'grieving/uh-oh/new/trees',        x = -1400, y = -1400,                                                                            scrollX = 0.9, scrollY = 0.9, front = false, lowQualityHide = true},
    {name =  'floor', path =     'grieving/uh-oh/new/floor',        x = -1300, y =   -50,                                                                            scrollX = 1, scrollY = 1, front = false},
    {name =   'fore', path =      'grieving/uh-oh/new/fore',        x = -1500, y = -1800,                                                                            scrollX = 1.1, scrollY = 1.1, front = false, lowQualityHide = true}
}

local graphics = {
    {name = 'BlackGraphicBehind', color = '000000', scaleX = 5, scaleY = 5, behind = true, camera = 'camGame', alpha = 0, front = false},

    {name = 'RedGraphicGameBlendADD', color = 'FF0000', scaleX = 5, scaleY = 5, camera = 'camGame', blend = 'ADD', alpha = 0, front = false},
}

function onCreatePost()
    for _, pepe in ipairs(uhOhBG) do
        if not (lowQuality and pepe.lowQualityHide) then
            if pepe.animName then
                makeAnimatedLuaSprite(pepe.name, pepe.path, pepe.x, pepe.y)
                addAnimationByPrefix(pepe.name, pepe.animName, pepe.animPrefix, pepe.fps, pepe.loop)
            else
                makeLuaSprite(pepe.name, pepe.path, pepe.x, pepe.y)
            end
            setScrollFactor(pepe.name, pepe.scrollX, pepe.scrollY)
            addLuaSprite(pepe.name, pepe.front)
        end
    end

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

    local spiralSource = getTextFromFile('shaders/uhOh.frag')
    if shadersEnabled and not lowQuality and spiralSource and string.find(spiralSource, 'spiralFade', 1, true) then
        makeLuaSprite('spiralBG')
        makeGraphic('spiralBG', screenWidth, screenHeight, 'FFFFFF')
        scaleObject('spiralBG', 3, 3)
        setScrollFactor('spiralBG', 0, 0)
        screenCenter('spiralBG')
        setSpriteShader('spiralBG', 'uhOh')
        addLuaSprite('spiralBG', false)
        setObjectOrder('spiralBG', getObjectOrder('trees'))
        setProperty('spiralBG.alpha', 0)
        spiralReady = true
    end
end

local spiralTime = 0
local spiralScroll = 0
local spiralShown = false
function onUpdate(elapsed)
    if spiralReady then
        local inRange = curStep >= 792 and curStep < 1048
        if inRange ~= spiralShown then
            spiralShown = inRange
            cancelTween('spiralFade')
            doTweenAlpha('spiralFade', 'spiralBG', inRange and 1 or 0, 1.5, 'linear')
        end

        local progress = math.max(0, math.min(1, (curStep - 792) / (1048 - 792)))
        local speed = 1 + 2 * progress

        spiralTime = spiralTime + elapsed * speed
        if inRange then
            spiralScroll = spiralScroll + elapsed * 0.5 * speed
        end

        setShaderFloat('spiralBG', 'iTime', spiralTime)
        setShaderFloat('spiralBG', 'spiralScroll', spiralScroll)
        setShaderFloat('spiralBG', 'spiralFade', getProperty('spiralBG.alpha'))
    end
end