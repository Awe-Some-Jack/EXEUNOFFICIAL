function onCreatePost()
	makeLuaSprite('sky', 'bg/4', -1200, -650)
	setScrollFactor('sky', 0.7, 0.7)
	addLuaSprite('sky')

	createInstance('clouds', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('clouds', 'bg/3')
	setScrollFactor('clouds', 0.7, 0.7)
	setProperty('clouds.y', -600)
	setProperty('clouds.velocity.x', 15)
	addInstance('clouds')

	makeLuaSprite('ground', 'bg/2', -1400, -750)
	addLuaSprite('ground')

	makeLuaSprite('fore', 'bg/1', -1550, -800)
	setScrollFactor('fore', 1.2, 1.2)
	addLuaSprite('fore')

	makeLuaSprite('overlay', 'bg/5', -1550, -800)
	setScrollFactor('overlay', 1.2, 1.2)
	addLuaSprite('overlay', true)
	setProperty('overlay.alpha', 0.3)
	setBlendMode('overlay', 'add')

	setScrollFactor('gf', 1, 1)
	createInstance('rosechu', 'objects.Character', {148, -156, 'rosechu', false})
	setObjectOrder('rosechu', getObjectOrder('gfGroup') + 1)
end

function onEvent(n,v1) 
	if n == 'Play Animation' then 
		if v1 == 'gf' then 
			playAnim('rosechu', 'anim', true) 
			setProperty('rosechu.specialAnim', true) 
			setProperty('dad.specialAnim', true)
			setProperty('dad.skipDance', true)
		end 
	end 
end

function onUpdate()
	callMethod('rosechu.update')
end

function onCountdownTick(t)
	rosechuDance(t)
end

function onBeatHit()
	rosechuDance(curBeat)
end

function rosechuDance(beat)
	if beat % math.floor(getProperty('gfSpeed') * getProperty('rosechu.danceEveryNumBeats')) == 0 and not getProperty('rosechu.stunned') and not stringStartsWith(getProperty('rosechu.animation.curAnim.name'), 'sing') then
		callMethod('rosechu.dance')
	end
end