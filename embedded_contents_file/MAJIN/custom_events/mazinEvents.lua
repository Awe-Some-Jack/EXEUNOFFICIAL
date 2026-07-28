function onEvent(n,v1)
	if n == 'mazinEvents' and songPath == 'endless-jp' then
		if v1 == 'cfbg' then
			setProperty('sky.alpha', 0)
			setProperty('city.alpha', 0)
			setProperty('ground.alpha', 0)
			setProperty('commercial.alpha', 1)
			setProperty('bg-2.alpha', 1)
			playAnim('commercial', 'idle', true)
		end
		if v1 == 'cpbg' then
			setProperty('sky.alpha', 1)
			setProperty('city.alpha', 1)
			setProperty('ground.alpha', 1)
			setProperty('commercial.alpha', 0)
			setProperty('bg-2.alpha', 0)
		end
	end
end