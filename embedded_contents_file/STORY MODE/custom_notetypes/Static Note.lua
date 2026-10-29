function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Static Note' then
			setProperty('unspawnNotes['..i..'].texture', 'noteSkins/static nouts')
		end
	end

	makeAnimatedLuaSprite('staticnotething', 'slow/hitStatic')
	addAnimationByPrefix('staticnotething', 'static', 'staticANIMATION', 24, true)
	playAnim('staticnotething', 'static', true)
	setObjectCamera('staticnotething', 'hud')
	addLuaSprite('staticnotething')
	setProperty('staticnotething.visible', false)
end

function noteMiss(id,nd,nt,isn)
	if not isn and nt == 'Static Note' then
		if getVar('rings') > 0 then updateRingCounter(-1) return end
		setProperty('staticnotething.visible', true)
		runTimer('staticbyelol', 0.35)
		playSound('hitStatic1', getRandomFloat(0.4,0.8))
		cameraShake('game', 0.005, 0.005)
	end
end

function onTimerCompleted(t)
	if t == 'staticbyelol' then
		setProperty('staticnotething.visible', false)
	end
end