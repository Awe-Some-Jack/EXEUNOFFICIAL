function onCreatePost()
    makeLuaSprite('darkOverlay', '', 0, 0)
    makeGraphic('darkOverlay', 9000, 9000, '000000')
    setObjectCamera('darkOverlay', 'camGame')
    setProperty('darkOverlay.alpha', 0) 
    addLuaSprite('darkOverlay', false)
    screenCenter('darkOverlay', 'xy')
end
function onStepHit()
    if curStep == 742 then
        doTweenAlpha('darkIn', 'darkOverlay', 0.5, 0.5, 'linear')
        doTweenZoom('zoomIn', 'camGame', 0.85, 1.5, 'quadOut')
    end
    if curStep == 770 then
        doTweenAlpha('darkOut', 'darkOverlay', 0, 0.5, 'linear')
    end
end