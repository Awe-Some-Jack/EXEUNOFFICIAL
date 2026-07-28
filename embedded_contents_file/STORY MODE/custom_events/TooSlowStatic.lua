precacheImage('slow/screenstatic')

function onCreatePost()
    makeAnimatedLuaSprite('staticamierda', "slow/screenstatic", 0, 0)
    addAnimationByPrefix('staticamierda', 'idle', 'screenSTATIC', 24, true)
    setProperty('staticamierda.alpha', 0)
    setObjectCamera('staticamierda', 'camOther')
    addLuaSprite('staticamierda', true)
end

function onEvent(eventName)
    if eventName == "TooSlowStatic" and flashingLights then
        setProperty('staticamierda.alpha', 0.5)
        playSound('staticBUZZ', 1, 'TooSlowStatic')
    end
end

function onSoundFinished(tag)
    if tag == 'TooSlowStatic' then
        setProperty('staticamierda.alpha', 0)
    end
end