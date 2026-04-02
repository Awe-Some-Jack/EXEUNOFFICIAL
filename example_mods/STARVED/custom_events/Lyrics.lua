function onCreatePost()
	makeLuaText('mytext', '', 860)
	screenCenter('mytext', 'x')
	setTextSize('mytext', 40)
	setTextFont('mytext', 'sonichud.ttf')
	setObjectCamera('mytext', 'other')
	addLuaText('mytext')
end

function onEvent(n, val1, val2)
	if n == 'Lyrics' then
		setTextString('mytext', val1)
		setTextColor('mytext', val2)

		cancelTween('Noo')
		cancelTimer('goodbye')
		setProperty('mytext.alpha', 1)
		runTimer('goodbye', 1)
	end
end

function onTimerCompleted(t)
	if t == 'goodbye' then
		doTweenAlpha('Noo', 'mytext', 0, 1)
	end
end