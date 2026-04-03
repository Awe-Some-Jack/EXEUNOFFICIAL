function onCreatePost()
    makeLuaSprite('darkOverlay', '', 0, 0)
    makeGraphic('darkOverlay', 9000, 9000, '000000')
    setObjectCamera('darkOverlay', 'camGame')
    setProperty('darkOverlay.alpha', 0) 
    addLuaSprite('darkOverlay', false)
    screenCenter('darkOverlay', 'xy')
end

function onEvent(n,v1)
	if n == 'sarahevent' then
		if v1 == 'blackbg' then
            doTweenAlpha('darkIn', 'darkOverlay', 0.5, 0.5, 'linear')
            doTweenZoom('zoomIn', 'camGame', 0.85, 1.5, 'quadOut')
		end
        if v1 == 'blackbgout' then
            doTweenAlpha('darkOut', 'darkOverlay', 0, 0.5, 'linear')
		end
    end
end