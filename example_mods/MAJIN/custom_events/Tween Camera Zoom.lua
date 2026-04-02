-- Annotations here
-- I want to make two camera zoom types: One that only defaults camera, and other that tweens the zoom to the default's camera zoom.
-- I should make variables for the stringSplit and the value1 and 2, then i should use startTween onEvent
-- Script by Raimbowcore12

function onEvent(eventName, value1, value2)
    if eventName == "Tween Camera Zoom" then
        local boolDefault = stringSplit(value1, ',')
        local zoom = tonumber(boolDefault[1])
        local tweenZoom = boolDefault[2]
        local valueZoom = stringSplit(value2, ',')
        local steps = valueZoom[1]
        local ease = valueZoom[2]

            if tweenZoom then
                doTweenZoom('TweenZoomEvent', 'camGame', zoom, steps, ease)
                --debugPrint(steps)
                --debugPrint('Tweening camera zoom')
            else
                setProperty('defaultCamZoom', zoom)
                --debugPrint('Default camera zoom!')
        end
    end
end

function onTweenCompleted(tag)
    if tag == "TweenZoomEvent" then
        setProperty('defaultCamZoom', getProperty('camGame.zoom'))
        --debugPrint('Zoom finished!')
    end
end