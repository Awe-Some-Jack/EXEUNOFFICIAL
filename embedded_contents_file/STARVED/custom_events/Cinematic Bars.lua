local barsHeight = 100

function onCreatePost()
	makeLuaSprite('topbar', nil, -50, 0)
	makeGraphic('topbar', screenWidth + 100, barsHeight + 50, '000000')
	setObjectCamera('topbar', 'other')
	setProperty('topbar.y', -(barsHeight + 50))
	addLuaSprite('topbar')

	makeLuaSprite('botbar', nil, -50, 0)
	makeGraphic('botbar', screenWidth + 100, barsHeight + 50, '000000')
	setObjectCamera('botbar', 'other')
	setProperty('botbar.y', screenHeight)
	addLuaSprite('botbar')
end

function onEvent(n, v1, v2)
	if n == 'Cinematic Bars' then
		cancelTween('topBar') cancelTween('bottomBar')
		if v1 == 'ON' then
			doTweenY('topBar', 'topbar', -50, (v2 == '' and 1 or tonumber(v2)), 'cubeOut')
			doTweenY('bottomBar', 'botbar', screenHeight - (barsHeight), (v2 == '' and 1 or tonumber(v2)), 'cubeOut')
		else
			doTweenY('topBar', 'topbar', -(barsHeight + 50), (v2 == '' and 1 or tonumber(v2)), 'expoIn')
			doTweenY('bottomBar', 'botbar', screenHeight, (v2 == '' and 1 or tonumber(v2)), 'expoIn')
		end
	end
end

function onUpdatePost()
	setProperty('mytext.y', getProperty('botbar.y') + 50 - getTextGraphicHeight('mytext') / 2)
end

function getTextGraphicHeight(text)
	return getProperty(text..'.textField.textHeight') * getProperty(text..'.scale.y')
end