function onCreatePost()
	setProperty('boyfriend.alpha', 0)

	makeAnimatedLuaSprite('starvHit', 'characters/starvfinal', getProperty('dad.x') + 20, getProperty('dad.y') - 100)
	addAnimationByPrefix('starvHit', 'idle', 'idle', 12, false)
	scaleObject('starvHit', 6, 6, false)
	setProperty('starvHit.antialiasing', false)
	addLuaSprite('starvHit')
	setProperty('starvHit.alpha', 0)

	makeAnimatedLuaSprite('sonicintro', 'characters/sonicpreyintro')
	setObjectCamera('sonicintro', 'video')
	addAnimationByPrefix('sonicintro', 'idle', 'idle', 12, true)
	scaleObject('sonicintro', 8, 8, true)
	screenCenter('sonicintro') setProperty('sonicintro.y', screenHeight - getProperty('sonicintro.height'))
	setProperty('sonicintro.antialiasing', false)
	addLuaSprite('sonicintro', true)
	setProperty('sonicintro.alpha', 0)
end

function onSongStart() doTweenAlpha('sonicintro', 'sonicintro', 1, crochet / 500) end

function onUpdatePost(e)
	if curBeat < 388 then
		setProperty('furnaceHit.x', getProperty('dad.x') - 20)
		setProperty('furnaceHit.y', getProperty('dad.y') + 51)
		setProperty('furnaceHit.angle', getProperty('dad.angle'))
	end

	if curBeat < 832 then
		setProperty('starvHit.x', getProperty('dad.x') - 424)
		setProperty('starvHit.y', getProperty('dad.y') - 78)
		setProperty('starvHit.angle', getProperty('dad.angle'))
	end
end