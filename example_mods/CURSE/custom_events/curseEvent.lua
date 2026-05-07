local sad = false
local happy = false

function onEvent(n,v1)
	if n == 'curseEvent' then
		if v1 == 'tails' then
			playAnim('tails', 'anim', true)
			setProperty('tails.visible', true)
			playAnim('fuente', 'anim', true)
		end
		if v1 == 'noteeffect' then
			cancelTween('blehh')
			setProperty('songSpeed', scrollSpeed * 0.75)
			startTween('tween_blehh', 'game', {songSpeed = scrollSpeed}, crochet / 2000, {ease = 'cubeOut'})
		end
		if v1 == 'evil' then
			setSpriteShader('sky', 'wavyDistortion')
			setShaderFloat('sky', 'amount', 0.1)
			setSpriteShader('city', 'wavyDistortion')
			setShaderFloat('city', 'amount', 0.1)
			setSpriteShader('floor', 'wavyDistortion')
			setShaderFloat('floor', 'amount', 0.1)
			setSpriteShader('trees2', 'wavyDistortion')
			setShaderFloat('trees2', 'amount', 0.1)
			setSpriteShader('trees1', 'wavyDistortion')
			setShaderFloat('trees1', 'amount', 0.1)
			setProperty('menuSTATIC.alpha', 0.4)

			cameraFlash('game', '5D4493', 1, true)
		end
		if v1 == 'normal' then
			removeLuaSprite('menuSTATIC', true)
			removeSpriteShader('sky')
			removeSpriteShader('city')
			removeSpriteShader('floor')
			removeSpriteShader('trees2')
			removeSpriteShader('trees1')

			cameraFlash('game', '5D4493', 1, true)
		end
	end
end

function onUpdatePost()
	if getProperty('tails.animation.curAnim.finished') and getProperty('tails.visible') then removeLuaSprite('tails', true) end
	if getProperty('fuente.animation.curAnim.finished') and getProperty('fuente.animation.curAnim.name') == 'anim' then playAnim('fuente', 'idle', true) end

	if curBeat >= 180 and curBeat < 244 and not sad then
		sad = true
		setProperty('boyfriend.idleSuffix', '-sad')
		for i = 0,getProperty('unspawnNotes.length')-1 do
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then setPropertyFromGroup('unspawnNotes', i, 'animSuffix', '-sad') end
		end
		for i = 0,getProperty('notes.length')-1 do
			if getPropertyFromGroup('notes', i, 'mustPress') then setPropertyFromGroup('notes', i, 'animSuffix', '-sad') end
		end
	end
	if curBeat >= 244 and not happy then
		happy = true sad = false
		setProperty('boyfriend.idleSuffix', '-happy')
		for i = 0,getProperty('unspawnNotes.length')-1 do
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then setPropertyFromGroup('unspawnNotes', i, 'animSuffix', '-happy') end
		end
		for i = 0,getProperty('notes.length')-1 do
			if getPropertyFromGroup('notes', i, 'mustPress') then setPropertyFromGroup('notes', i, 'animSuffix', '-happy') end
		end
	end

	if sad and getProperty('boyfriend.animation.curAnim.name') == 'idle' and getProperty('boyfriend.animation.curAnim.curFrame') == 0 then playAnim('boyfriend', 'idle-sad') end
	if happy and getProperty('boyfriend.animation.curAnim.name') == 'idle' and getProperty('boyfriend.animation.curAnim.curFrame') == 0 then playAnim('boyfriend', 'idle-happy') end
end