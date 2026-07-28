local existingSound = false
function onCreatePost()
    makeAnimatedLuaSprite('dastatic', 'daSTAT')
    addAnimationByPrefix('dastatic', 'idle', 'staticFLASH', 24, true)
    setGraphicSize('dastatic', screenWidth, screenHeight)
    setProperty('dastatic.antialiasing', false)
    setObjectCamera('dastatic', 'other')
    addLuaSprite('dastatic', true)
   -- scaleObject('dastatic', 4, 4)
    setProperty('dastatic.visible', false)
   -- setProperty('dastatic.alpha', 0.9)
    --setProperty('dastatic.color', getColorFromHex('442121'))
end

function onEvent(n, v1)
    if n == 'static' and flashingLights then
        cancelTimer('byeee')
        runTimer('byeee', 0.15)
        if not existingSound then
            existingSound = true
            setProperty('dastatic.visible', true)
            playSound('staticSound', 0.075, 'staticc')
        end
    end
end

function onTimerCompleted(t)
    if t == 'byeee' then
        existingSound = false
        setProperty('dastatic.visible', false)
        stopSound('staticc')
    end
end