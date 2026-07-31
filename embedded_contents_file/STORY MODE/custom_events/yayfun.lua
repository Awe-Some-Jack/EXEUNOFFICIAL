local bruhhh = false

function onUpdatePost(e)
	if bruhhh then
		setProperty('camHUD.y', -math.abs(math.sin(curDecBeat * math.pi)) * 5)
		setProperty('camHUD.x', math.cos(curDecBeat * math.pi + (math.pi / 4)) * 10)
		setProperty('camHUD.angle', math.cos(curDecBeat * math.pi + (math.pi / 4)) / 2)
	end
end

function onEvent(n)
	if n == 'yayfun' then
		if bruhhh == true then 
			setProperty('camHUD.y', 0)
			setProperty('camHUD.angle', 0)
		end
		bruhhh = not bruhhh
	end
end