local existingSound = false
function onCreatePost()
    makeAnimatedLuaSprite('dastatic', 'daSTAT')
    addAnimationByPrefix('dastatic', 'idle', 'staticFLASH', 24, true)
    setGraphicSize('dastatic', screenWidth, screenHeight)
    setProperty('dastatic.antialiasing', false)
    setObjectCamera('dastatic', 'other')
    addLuaSprite('dastatic', true)
    setProperty('dastatic.visible', false)
    setProperty('dastatic.alpha', 0.45)
end

function onEvent(n, v1)
    if n == 'static' and flashingLights then
        cancelTimer('byeee')
        runTimer('byeee', 0.15)
        if not existingSound then
            existingSound = true
            setProperty('dastatic.visible', true)
            playSound('staticSound', 0.05, 'staticc')
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