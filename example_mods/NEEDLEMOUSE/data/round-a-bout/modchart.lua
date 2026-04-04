function onCreatePost()
    makeLuaSprite('darkOverlay')
    makeGraphic('darkOverlay', 1280, 720, '000000')
    setProperty('darkOverlay.alpha', 0.0001)
    setScrollFactor('darkOverlay', 0, 0)
    screenCenter('darkOverlay')
    addLuaSprite('darkOverlay')
end

function onUpdatePost(e)
    scaleObject('darkOverlay', 1 / getProperty('camGame.zoom'), 1 / getProperty('camGame.zoom'), false)
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