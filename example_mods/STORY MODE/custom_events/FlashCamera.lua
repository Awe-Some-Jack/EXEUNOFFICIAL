
function onEvent(eventName, value1, value2)
    local flashStuff1 = stringSplit(value1, ',')
    local color = flashStuff1[1]
    local alphaStart = flashStuff1[2]

    local flashStuff2 = stringSplit(value2, ',')
    local time = flashStuff2[1]
    local blend = flashStuff2[2]

    if eventName == "FlashCamera" and flashingLights then
        if not luaSpriteExists('flashEvent') then
            makeLuaSprite('flashEvent')
            makeGraphic('flashEvent', 1980, 720, color)
            setObjectCamera('flashEvent', 'camOther')
            addLuaSprite('flashEvent')
        end
        cancelTween('flashEventAlphaEnd')
        setProperty('flashEvent.alpha', alphaStart)
        if blend then
            setBlendMode('flashEvent', blend)
        else
            setBlendMode('flashEvent', "NORMAL")
        end
        doTweenAlpha('flashEventAlphaEnd', 'flashEvent', 0, time)
    end
end