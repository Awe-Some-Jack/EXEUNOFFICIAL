function onEvent(n)
	if n == 'blackscreen' then
		makeLuaSprite('dasdasdafjf')
		makeGraphic('dasdasdafjf', screenWidth, screenHeight, '000000')
		setObjectCamera('dasdasdafjf', 'other')
		addLuaSprite('dasdasdafjf')
	end
end