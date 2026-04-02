local barsHeight = 100

function onCreatePost()
	makeLuaSprite('topbar', nil, -50, 0)
	makeGraphic('topbar', screenWidth+100, barsHeight+50, '000000')
	setObjectCamera('topbar', 'other')
	addLuaSprite('topbar', true)
	setProperty('topbar.y', -(barsHeight+50))

	makeLuaSprite('botbar', nil, -50, 0)
	makeGraphic('botbar', screenWidth+100, barsHeight+50, '000000')
	setObjectCamera('botbar', 'other')
	addLuaSprite('botbar', true)
	setProperty('botbar.y', screenHeight)
end

function onEvent(n, val1, val2)
	if n == 'Cinematic Bars' then
		tween = tonumber(val2)
		if val1 == 'ON' then
			doTweenY('activateTop', 'topbar', -50, tween, 'expoOut')
			doTweenY('activateBot', 'botbar', screenHeight-barsHeight, tween, 'expoOut')
		else
			doTweenY('desactivateTop', 'topbar', -(barsHeight+50), tween, 'expoIn')
			doTweenY('desactivateBot', 'botbar', screenHeight, tween, 'expoIn')
		end
	end
end

function onUpdatePost()
	setProperty('mytext.y', getProperty('botbar.y') + 50 - getTextGraphicHeight('mytext') / 2)
end

function getTextGraphicHeight(text)
	return getProperty(text..'.textField.textHeight') * getProperty(text..'.scale.y')
end