local shadows = {
	{name = 'bfShadow',  path = 'bg/shadow',  target = 'boyfriend', offsetX = 10,   offsetY = 255, alpha = 0.7},
	{name = 'dadShadow', path = 'bg/shadow2', target = 'dad',       offsetX = 92,  offsetY = 354, alpha = 0},
}

function onCreatePost()
	makeLuaSprite('bg', 'bg/bg', -270, -230)
	addLuaSprite('bg')

	for i = 1,2 do
		makeLuaSprite('char'..i, 'bg/char'..i, 610, 320)
		addLuaSprite('char'..i)
	end setProperty('char2.x', 780)

	makeLuaSprite('bg2', 'bg/bg2', 535, 215)
	addLuaSprite('bg2')

	makeAnimatedLuaSprite('door', 'bg/doorbangin', -110, -525)
	addAnimationByPrefix('door', 'doorbangin', 'doorbangin', 24, false)
	playAnim('door', 'doorbangin', true)
	addLuaSprite('door')

	makeAnimatedLuaSprite('pc', 'bg/tv', 1400, 400)
	addAnimationByPrefix('pc', 'idle', 'Símbolo 12', 24, true)
	playAnim('pc', 'idle', true)
	addLuaSprite('pc')

	for _, s in ipairs(shadows) do
		makeLuaSprite(s.name, s.path)
		callMethod(s.name .. '.setPosition', {getProperty(s.target .. '.x') + s.offsetX, getProperty(s.target .. '.y') + s.offsetY})
		setProperty(s.name .. '.alpha', s.alpha)
		addLuaSprite(s.name)
	end

	setProperty('dad.alpha', 0)

	makeLuaSprite('glow', 'bg/glow', 50)
	setBlendMode('glow', 'add')
	setProperty('glow.alpha', 0.75)
	addLuaSprite('glow', true)

	makeAnimatedLuaSprite('outro', 'characters/Normal-Outro', getProperty('dad.x') - 170, getProperty('dad.y') + 18)
	addAnimationByPrefix('outro', 'idle', 'Animation', 24, false)
	setProperty('outro.alpha', 0)
	scaleObject('outro', 0.552, 0.552)
	addLuaSprite('outro', true)
	setObjectOrder('outro', getObjectOrder('dadGroup') + 1)

	setProperty('camHUD.alpha', 0)
end

local thing = 0
function onUpdatePost(e)
	thing = thing + e * playbackRate
	for i = 1,2 do
		setProperty('char'..i..'.y', 320 + math.sin(thing + i) * 8)
	end
end

local hudRevealed = false

function onBeatHit()
	if not hudRevealed and curBeat >= 36 then
		hudRevealed = true
		doTweenAlpha('camHudFade', 'camHUD', 1, crochet / 250)
	end
end

function onEvent(n, v1)
	if n == 'animation' then
		if v1 == 'intro' then
			playAnim('door', 'doorbangin', true)
			setProperty('door.animation.curAnim.curFrame', 5)
		elseif v1 == 'end' then
			playAnim('outro', 'idle', true)
			setProperty('outro.alpha', 1)
			setProperty('dad.alpha', 0)
			setProperty('boyfriend.alpha', 0)
		end

	elseif n == 'Play Animation' then
		doTweenAlpha('dadShadowFade', 'dadShadow', 0.7, 4)
	end
end