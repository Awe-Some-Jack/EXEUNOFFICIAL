local function setupTrigs()
	makeLuaSprite('bftrig', 'bg/sonictrig', - 700)
	setObjectCamera('bftrig', 'hud')
	scaleObject('bftrig', 0.5, 0.5)
	setProperty('bftrig.y', screenHeight - getProperty('bftrig.height') + 1)
	addLuaSprite('bftrig')

	createInstance('bftrigchar', 'objects.Character', {-250 - 700, -30, 'bf2-mania-small', true})
	setObjectCamera('bftrigchar', 'hud')
	addInstance('bftrigchar')

	makeLuaSprite('tailstrig', 'bg/maniatrig')
	setObjectCamera('tailstrig', 'hud')
	scaleObject('tailstrig', 0.5, 0.5)
	setProperty('tailstrig.x', screenWidth - getProperty('tailstrig.width') + 700)
	setProperty('tailstrig.y', screenHeight - getProperty('tailstrig.height') + 1)
	addLuaSprite('tailstrig')

	createInstance('tailstrigchar', 'objects.Character', {750 + 700, -250, 'mania2-small', false})
	setObjectCamera('tailstrigchar', 'hud')
	addInstance('tailstrigchar')

	setProperty('bftrig.visible', false) setProperty('bftrigchar.visible', false)
	setProperty('tailstrig.visible', false) setProperty('tailstrigchar.visible', false)
end

local function setupAnims()
	--anim1
	makeFlxAnimateSprite('bestfriend', 400, 200, 'characters/mania2')
	addAnimationBySymbol('bestfriend', 'bestfriend', 'sonic', 24, false)
	scaleObject('bestfriend', 2.4, 2.4)
	addLuaSprite('bestfriend', true)
	setProperty('bestfriend.alpha', 0.0001)

	makeFlxAnimateSprite('bestfriend2', getProperty('bestfriend.x') + 80, getProperty('bestfriend.y') - 25, 'characters/mania1')
	addAnimationBySymbol('bestfriend2', 'bestfriend', 'sonic2', 24, false)
	scaleObject('bestfriend2', 2.4, 2.4)
	addLuaSprite('bestfriend2', true)
	setProperty('bestfriend2.alpha', 0.0001)

	--anim2

	makeLuaSprite('bg-amy', 'bg/amy', -300, -250)
	scaleObject('bg-amy', 0.55, 0.55)
	addLuaSprite('bg-amy')
	setProperty('bg-amy.alpha', 0.0001)

	makeLuaSprite('bg-never', 'bg/never', -300, -300)
	scaleObject('bg-never', 0.55, 0.55)
	addLuaSprite('bg-never')
	setProperty('bg-never.alpha', 0.0001)

	makeFlxAnimateSprite('final', 500, 50, 'characters/final1')
	addAnimationBySymbol('final', 'final', 'final', 24, false)
	scaleObject('final', 2.4, 2.4)
	addLuaSprite('final', true)
	setProperty('final.alpha', 0.0001)

	makeFlxAnimateSprite('final2', 400, 200, 'characters/final2')
	addAnimationBySymbol('final2', 'final', 'SMoicandmay', 24, false)
	scaleObject('final2', 1.6, 1.6)
	addLuaSprite('final2', true)
	setProperty('final2.alpha', 0.0001)

	makeFlxAnimateSprite('final3', 600, 50, 'characters/final3')
	addAnimationBySymbol('final3', 'final', 'final3', 24, false)
	scaleObject('final3', 2.42, 2.42)
	addLuaSprite('final3', true)
	setProperty('final3.alpha', 0.0001)

	makeFlxAnimateSprite('final4', 475, -95, 'characters/final4')
	addAnimationBySymbol('final4', 'final', 'final4', 24, false)
	scaleObject('final4', 2.4, 2.4)
	addLuaSprite('final4', true)
	setProperty('final4.alpha', 0.0001)

	makeFlxAnimateSprite('final5', getProperty("final4.x"), getProperty("final4.y"), 'characters/final4')
	addAnimationBySymbolIndices('final5', 'final', 'final4', {60,61}, 24, true)
	playAnim('final5', 'final', true)
	scaleObject('final5', 2.4, 2.4)
	addLuaSprite('final5', true)
	setProperty('final5.alpha', 0.0001)
end

function onCreatePost()
	makeLuaSprite('bg', 'bg/bg', -440, -310)
	scaleObject('bg', 0.7, 0.7)
	addLuaSprite('bg')

	makeAnimatedLuaSprite('papis', 'characters/mispapas', 1274, 252)
	addAnimationByPrefix('papis', 'idle', 'Símbolo 243', 24, false)
	addLuaSprite('papis')

	makeLuaSprite('esencia', 'bg/esencia')
	scaleObject('esencia', 0.7, 0.7)
	addLuaSprite('esencia', true)
	callMethod('esencia.setPosition', {-440 + getProperty('bg.width') - getProperty('esencia.width'), -310 + getProperty('bg.height') - getProperty('esencia.height')})

	--new bg

	makeLuaSprite('bg-tails', 'bg/maniapov', -900, -350)
	scaleObject('bg-tails', 1, 1.1)
	addLuaSprite('bg-tails')
	setProperty('bg-tails.alpha', 0.0001)

	makeLuaSprite('bg-bf', 'bg/sonicpov', -700, -250)
	scaleObject('bg-bf', 0.82, 0.82)
	addLuaSprite('bg-bf')
	setProperty('bg-bf.alpha', 0.0001)

	makeLuaSprite('bg-bf1', 'bg/estre', -730, 200)
	scaleObject('bg-bf1', 2.5, 2.5)
	addLuaSprite('bg-bf1')
	setProperty('bg-bf1.alpha', 0.0001)
	makeLuaSprite('bg-bf2', 'bg/estre2', -730, 200)
	scaleObject('bg-bf2', 2.5, 2.5)
	addLuaSprite('bg-bf2')
	setProperty('bg-bf2.alpha', 0.0001)
	makeLuaSprite('bg-bf3', 'bg/estre3', -730, 200)
	scaleObject('bg-bf3', 2.5, 2.5)
	addLuaSprite('bg-bf3')
	setProperty('bg-bf3.alpha', 0.0001)

	makeAnimatedLuaSprite('papis2', 'characters/mispapas2', 900, 350)
	addAnimationByPrefix('papis2', 'idle', 'sonamy2', 24, true)
	scaleObject('papis2', 0.8, 0.8)
	addLuaSprite('papis2')
	setProperty('papis2.alpha', 0.0001)

	setupTrigs()
	setupAnims()

	makeLuaSprite('overlay', 'bg/overlay-cinematico')
	scaleObject('overlay', 1.9, 1.9)
	setObjectCamera('overlay', 'other')
	screenCenter('overlay', 'y')
	setObjectOrder('overlay', getObjectOrder('BlackGraphicOther'))
	addLuaSprite('overlay')
	
	makeLuaSprite('overlayroto', 'bg/rota')
	scaleObject('overlayroto', 1.75, 1.75)
	setObjectCamera('overlayroto', 'other')
	screenCenter('overlayroto')
	setProperty('overlayroto.alpha', 0.0001)
	setObjectOrder('overlayroto', getObjectOrder('BlackGraphicOther'))
	addLuaSprite('overlayroto')
end

local anim = ''
function onCountdownTick(c)
	if c % 2 == 0 then
		playAnim('papis', 'idle', true)
	end
end

local changedBG = false
function opponentNoteHitPre(id,nd,nt,isn)
	if not changedBG or nt == 'No Animation' then return end
	if nd == 0 then
		triggerEvent('Set Character Offset', 'dad', '250')
	elseif nd == 1 then
		triggerEvent('Set Character Offset', 'dad', '100')
	elseif nd == 2 then
		triggerEvent('Set Character Offset', 'dad', '150')
	elseif nd == 3 then
		triggerEvent('Set Character Offset', 'dad', '220')
	end
end

local playerHold = 0
function goodNoteHit()
	if not changedBG then return end
	if not mustHitSection then
		if playerHold <= 0 then
			cancelTween('bftrig') cancelTween('bftrigchar')
			doTweenX('bftrig', 'bftrig', 0, crochet / 500, 'cubeOut')
			doTweenX('bftrigchar', 'bftrigchar', -250, crochet / 500, 'cubeOut')
		end
		playerHold = 1
	end
end

local oppHold = 0
function opponentNoteHit()
	if not changedBG then return end
	if mustHitSection then
		if oppHold <= 0 then
			cancelTween('tailstrig') cancelTween('tailstrigchar')
			doTweenX('tailstrig', 'tailstrig', screenWidth - getProperty('tailstrig.width'), crochet / 500, 'cubeOut')
			doTweenX('tailstrigchar', 'tailstrigchar', 750, crochet / 500, 'cubeOut')
		end
		oppHold = 1
	end
end

function onBeatHit()
	if curBeat % 2 == 0 and not changedBG then
		playAnim('papis', 'idle', true)
	end
end

local status = 0
local starSine = 0
function onUpdatePost(e)
	if anim == 'final' then
		if getProperty('final.anim.frameIndex') >= 38 and getProperty('bg-amy.alpha') ~= 1 then
			setProperty('bg-bf.alpha', 0)
			setProperty('bg-amy.alpha', 1)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
		end
	elseif anim == 'final3' then
		if getProperty('final3.anim.frameIndex') >= 60 and status == 0 then
			status = 1
			scaleObject('bg-never', 0.5, 0.5)
			setProperty('bg-never.x', -100)
			setProperty('bg-never.y', -200)
		end
		if getProperty('final3.anim.frameIndex') >= 81 and status == 1 then
			status = 2
			setProperty('bg-never.angle', 10)
			scaleObject('bg-never', 0.65, 0.65)
			setProperty('bg-never.x', -400)
			setProperty('bg-never.y', -400)
		end
		if getProperty('final3.anim.frameIndex') >= 100 and status == 2 then
			status = 3
			setProperty('bg-never.angle', 0)
			scaleObject('bg-never', 0.85, 0.85)
			setProperty('bg-never.x', -700)
			setProperty('bg-never.y', -450)
		end
	elseif anim == 'final4' then
		if getProperty('final4.anim.frameIndex') >= 32 and luaSpriteExists('bg-tails') then
			removeLuaSprite('bg-tails', true)
			setProperty('bg-bf.alpha', 1)
		end
	end

	if not changedBG then return end
	starSine = starSine + e * 3
	setProperty('bg-bf1.alpha', 0.4 + (((math.sin(starSine) / 2) + 0.5) * 0.6))
	setProperty('bg-bf2.alpha', 0.4 + (((math.sin(starSine + 1) / 2) + 0.5) * 0.6))
	setProperty('bg-bf3.alpha', 0.4 + (((math.sin(starSine + 2) / 2) + 0.5) * 0.6))

	playAnim('bftrigchar', getProperty('boyfriend.animation.curAnim.name'), true)
	setProperty('bftrigchar.animation.curAnim.curFrame', getProperty('boyfriend.animation.curAnim.curFrame'))
	playAnim('tailstrigchar', getProperty('dad.animation.curAnim.name'), true)
	setProperty('tailstrigchar.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))

	playerHold = playerHold - e
	if playerHold < 0 then
		playerHold = 0
		doTweenX('bftrig', 'bftrig', - 700, crochet / 500, 'cubeOut')
		doTweenX('bftrigchar', 'bftrigchar', -250 - 700, crochet / 500, 'cubeOut')
	end

	oppHold = oppHold - e
	if oppHold < 0 then
		oppHold = 0
		doTweenX('tailstrig', 'tailstrig', screenWidth - getProperty('tailstrig.width') + 700, crochet / 500, 'cubeOut')
		doTweenX('tailstrigchar', 'tailstrigchar', 750 + 700, crochet / 500, 'cubeOut')
	end
end

local omhs = false
function onSectionHit()
	if not changedBG then return end
	if omhs ~= mustHitSection then
		triggerEvent('bright zoom')
		if mustHitSection then
			cancelTween('bftrig') cancelTween('bftrigchar')
			setProperty('bftrig.x', - 700) setProperty('bftrigchar.x', -250 - 700)
	
			setProperty('boyfriend.alpha', 1)
			setProperty('dad.alpha', 0)

			setProperty('bg-bf.alpha', 1)
			setProperty('bg-bf1.visible', true)
			setProperty('bg-bf2.visible', true)
			setProperty('bg-bf3.visible', true)
			setProperty('papis2.alpha', 1)
			setProperty('bg-tails.alpha', 0)
		else
			cancelTween('tailstrig') cancelTween('tailstrigchar')
			setProperty('tailstrig.x', screenWidth - getProperty('tailstrig.width') + 700) setProperty('tailstrigchar.x', 750 + 700)
	
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 1)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('papis2.alpha', 0)
			setProperty('bg-tails.alpha', 1)
		end

		runTimer('xdxd', 0.0001)
	end
	omhs = mustHitSection
end

function onTimerCompleted(t)
	if t == 'xdxd' then
		callMethod('camGame.snapToTarget')
	end
end

function onEvent(n,v1)
	if n == 'maniaevents' then
		if v1 == 'changebg' then
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 1)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('papis2.alpha', 0)
			setProperty('bg-tails.alpha', 1)

			callMethod('boyfriend.setPosition', {0, -70})
			callMethod('dad.setPosition', {600, -150})

			changedBG = true

			setProperty('bg.visible', false)
			setProperty('papis.visible', false)
			setProperty('esencia.visible', false)

			triggerEvent('cameracenter', 'true', '')
			callMethod('camGame.snapToTarget')
		end
		if v1 == 'bestfriend' then
			setProperty('boyfriend.alpha', 0)
			setProperty('dad.alpha', 0)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('papis2.alpha', 0)
			setProperty('bg-tails.alpha', 1)

			playAnim('bestfriend', 'bestfriend', true)
			setProperty('bestfriend.alpha', 1)

			setProperty('bg-tails.x', -200)
		end
		if v1 == 'bestfriend2' then
			removeLuaSprite('bestfriend', true)
			playAnim('bestfriend2', 'bestfriend', true)
			setProperty('bestfriend2.alpha', 1)
		end
		if v1 == 'endcine' then
			removeLuaSprite('bestfriend2', true)
			setProperty('bg-tails.x', -900)

			setProperty('boyfriend.alpha', 1)
			setProperty('dad.alpha', 0)

			setProperty('bg-bf.alpha', 1)
			setProperty('bg-bf1.visible', true)
			setProperty('bg-bf2.visible', true)
			setProperty('bg-bf3.visible', true)
			setProperty('papis2.alpha', 1)
			setProperty('bg-tails.alpha', 0)

			setProperty('bftrig.visible', true) setProperty('bftrigchar.visible', true)
			setProperty('tailstrig.visible', true) setProperty('tailstrigchar.visible', true)
		end
		if v1 == 'originalbg' then
			setProperty('boyfriend.alpha', 1)
			setProperty('dad.alpha', 1)

			callMethod('boyfriend.setPosition', {870, 40})
			callMethod('dad.setPosition', {30, 20})

			changedBG = false
			setProperty('bg-tails.alpha', 0)
			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			removeLuaSprite('papis2', true)

			setProperty('bg.visible', true)
			setProperty('papis.visible', true)
			setProperty('esencia.visible', true)

			triggerEvent('cameracenter', 'true', '')
			callMethod('camGame.snapToTarget')
			triggerEvent('Set Character Offset', 'dad', '25')

			removeLuaSprite('bftrig', true) removeLuaSprite('bftrigchar', true)
			removeLuaSprite('tailstrig', true) removeLuaSprite('tailstrigchar', true)
		end
		if v1 == 'fadeout' then
			doTweenAlpha('BlackGraphicOther', 'BlackGraphicOther', 1, 3)
		end
		if v1 == 'finalanim' then
			cancelTween('BlackGraphicOther')
			setProperty('BlackGraphicOther.alpha', 0)

			anim = 'final'
			setProperty('camZoomingMult', 0)
			setProperty('camHUD.alpha', 0)
			playAnim('final', 'final', true)
			setProperty('final.alpha', 1)
			setProperty('bg-bf.alpha', 1)
			scaleObject('bg-bf', 1.5, 1.5)
			setProperty('bg-bf.x', -500)
			setProperty('bg-bf.y', -1500)

			removeLuaSprite('bg', true)
			removeLuaSprite('esencia', true)

			setProperty('dad.alpha', 0)
			setProperty('boyfriend.alpha', 0)
			removeLuaSprite('papis', true)
			removeLuaSprite('papis', true)
		end
		if v1 == 'finalanim2' then
			anim = 'final2'
			removeLuaSprite('final', true)
			playAnim('final2', 'final', true)
			setProperty('final2.alpha', 1)

			removeLuaSprite('bg-amy', true)
			setProperty('bg-bf.alpha', 1)
			setProperty('bg-bf1.visible', true)
			setProperty('bg-bf2.visible', true)
			setProperty('bg-bf3.visible', true)
			scaleObject('bg-bf', 0.82, 0.82)
			setProperty('bg-bf.x', -700)
			setProperty('bg-bf.y', -250)
		end
		if v1 == 'finalanim3' then
			anim = 'final3'
			removeLuaSprite('final2', true)
			playAnim('final3', 'final', true)
			setProperty('final3.alpha', 1)

			setProperty('bg-bf.alpha', 0)
			setProperty('bg-bf1.visible', false)
			setProperty('bg-bf2.visible', false)
			setProperty('bg-bf3.visible', false)
			setProperty('bg-never.alpha', 1)
			scaleObject('bg-never', 0.6, 0.6)

			setProperty('bg-never.x', -600) setProperty('final3.x', 200)
			doTweenX('xd', 'bg-never', -300, 0.6, 'backOut')
			doTweenX('xd2', 'final3', 500, 0.6, 'backOut')
		end
		if v1 == 'finalanim4' then
			anim = 'final4'
			removeLuaSprite('final3', true)
			playAnim('final4', 'final', true)
			setProperty('final4.alpha', 1)

			removeLuaSprite('bg-never', true)
			setProperty('bg-tails.alpha', 1)
			scaleObject('bg-tails', 0.85, 0.85)
			setProperty('bg-tails.x', -380)
			setProperty('bg-tails.y', -215)
		end
		if v1 == 'shake' then
			cameraShake('game', 0.02, 0.3)
			runTimer('pzox', 0.3)
		end
		if v1 == 'ending' then
			removeLuaSprite('final4', true)
			playAnim('final5', 'final', true)
			setProperty('final5.alpha', 1)
			doTweenAlpha('BlackGraphicOther', 'BlackGraphicOther', 1, 4)
		end
	end
end

function onTimerCompleted(t)
	if t == 'pzox' then
		setProperty('overlayroto.alpha', 1)
	end
end