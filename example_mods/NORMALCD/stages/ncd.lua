local OUTRO_SCALE = 0.666 * 0.83
local HUD_FADE_BEAT = 36

local shadows = {
	{name = 'bfShadow',  path = 'bg/shadow',  target = 'boyfriend', offsetX = 10,   offsetY = 255, alpha = 0.7},
	{name = 'dadShadow', path = 'bg/shadow2', target = 'dad',       offsetX = -70,  offsetY = 230, alpha = 0},
}

function onCreatePost()
	makeLuaSprite('bg', 'bg/bg')
	addLuaSprite('bg')

	makeAnimatedLuaSprite('door', 'bg/doorbangin', -110, -525)
	addAnimationByPrefix('door', 'doorbangin', 'doorbangin', 24, false)
	playAnim('door', 'doorbangin', true)
	addLuaSprite('door')

	makeAnimatedLuaSprite('pc', 'bg/pc', 1441, 364)
	addAnimationByPrefix('pc', 'idle', 'pc exe', 24, true)
	addAnimationByPrefix('pc', 'loopidle', 'loop', 24, true)
	playAnim('pc', 'loopidle', true)
	addLuaSprite('pc')

	for _, s in ipairs(shadows) do
		makeLuaSprite(s.name, s.path)
		callMethod(s.name .. '.setPosition', {getProperty(s.target .. '.x') + s.offsetX, getProperty(s.target .. '.y') + s.offsetY})
		setProperty(s.name .. '.alpha', s.alpha)
		addLuaSprite(s.name)
	end

	setProperty('dad.alpha', 0)

	makeLuaSprite('glow', 'bg/glow')
	setBlendMode('glow', 'add')
	setProperty('glow.alpha', 0.75)
	addLuaSprite('glow', true)

	makeAnimatedLuaSprite('outro', 'characters/Normal-Outro', getProperty('dad.x') - 302, getProperty('dad.y') - 106)
	addAnimationByPrefix('outro', 'idle', 'Animation', 24, false)
	setProperty('outro.alpha', 0)
	scaleObject('outro', OUTRO_SCALE, OUTRO_SCALE)
	addLuaSprite('outro', true)
	setObjectOrder('outro', getObjectOrder('dadGroup') + 1)

	setProperty('camHUD.alpha', 0)
end

local hudRevealed = false

function onBeatHit()
	if not hudRevealed and curBeat >= HUD_FADE_BEAT then
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