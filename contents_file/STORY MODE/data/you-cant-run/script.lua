function onCreatePost()
    setProperty('camHUD.alpha', 0)
    triggerEvent('Tweening Camera', '-500, 0', '0.001, linear')
    triggerEvent('Tween Camera Zoom', '1.4, true', '0.001, linear')
end

function onStepHit()
    if curStep == 140 then
        doTweenAlpha('camHUDAlpha', 'camHUD', 1, 0.8)
    end
    if curStep == 1440 then
        doTweenAlpha('camHUDAlpha', 'camHUD', 0, 1)
    end
    if curStep == 1472 then
        setProperty('camGame.alpha', 0)
    end
end