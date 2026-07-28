local barsHeight = 100

function onCreatePost()
	makeLuaSprite('topbar', nil, -50, 0)
	makeGraphic('topbar', screenWidth + 100, barsHeight + 50, '000000')
	setObjectCamera('topbar', 'hud')
	setObjectOrder('topbar', getObjectOrder('hbBG') - 1)
	setProperty('topbar.y', -(barsHeight + 50))

	makeLuaSprite('botbar', nil, -50, 0)
	makeGraphic('botbar', screenWidth + 100, barsHeight + 50, '000000')
	setObjectCamera('botbar', 'hud')
	setObjectOrder('botbar', getObjectOrder('hbBG') - 1)
	setProperty('botbar.y', screenHeight)
end

function onEvent(n, v1, v2)
	if n == 'ScreenBorders' then
		cancelTween('topBar') cancelTween('bottomBar')
		if tonumber(v1) == 1 then
			doTweenY('topBar', 'topbar', -50, (v2 == '' and 1 or tonumber(v2)), 'cubeOut')
			doTweenY('bottomBar', 'botbar', screenHeight - (barsHeight), (v2 == '' and 1 or tonumber(v2)), 'cubeOut')
		else
			doTweenY('topBar', 'topbar', -(barsHeight + 50), (v2 == '' and 1 or tonumber(v2)), 'cubeOut')
			doTweenY('bottomBar', 'botbar', screenHeight, (v2 == '' and 1 or tonumber(v2)), 'cubeOut')
		end
	end
end