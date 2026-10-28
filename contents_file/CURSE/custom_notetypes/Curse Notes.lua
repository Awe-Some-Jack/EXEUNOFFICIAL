local dachain = 0
function onCreate()
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if getProperty('unspawnNotes['..i..'].noteType') == 'Curse Notes' then
			setProperty('unspawnNotes['..i..'].texture', 'noteSkins/cursenotes')
			setProperty('unspawnNotes['..i..'].ignoreNote', true)
			setProperty('unspawnNotes['..i..'].earlyHitMult', 0.65)
			setProperty('unspawnNotes['..i..'].lateHitMult', 0.65)
			setProperty('unspawnNotes['..i..'].noAnimation', true)
		end
	end

	for i = 0,5 do
		makeLuaSprite('chain'..i, 'chains/'..(i + 1))
		setObjectCamera('chain'..i, 'other')
		addLuaSprite('chain'..i)
		setProperty('chain'..i..'.alpha', 0)
	end
end

function goodNoteHit(id,nd,nt,isn)
	if nt == 'Curse Notes' then
		addHealth(-0.45)
		dachain = (dachain + 1) % 6

		local canKill = true
		for i = 0,5 do if getProperty('chain'..dachain..'.alpha') < 1 then canKill = false break end end
		if canKill then setHealth(-2) return end

		playSound('hitWire')
		setProperty('chain'..dachain..'.alpha', 1)
		setProperty('chain'..dachain..'.y', 0)
		runTimer('chain'..dachain, 8)

		cameraShake('game', 0.01, 0.1)
		cameraShake('hud', 0.007, 0.1)
		cameraShake('other', 0.007, 0.1)
	end
end

function onTimerCompleted(t)
	if stringStartsWith(t, 'chain') then
		doTweenAlpha(t, t, 0, 0.4)
		doTweenY(t..'y', t, 20, 0.4, 'cubeIn')
	end
end