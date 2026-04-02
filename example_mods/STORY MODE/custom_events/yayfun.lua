local bruhhh = false

function onUpdatePost(e)
	if bruhhh then
		setProperty('camHUD.y', -math.abs(math.sin(curDecBeat * math.pi) * e * 60) * 20)
		setProperty('camHUD.angle', math.sin((curDecBeat + 1) * math.pi + 0.5) * e * 60)
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