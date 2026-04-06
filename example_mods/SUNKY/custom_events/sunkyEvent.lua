local renders = {'cereal', 'Ilustracion23', 'SunkyGiveYouCereal', 'sunkyMunch', 'sunkyPose', 'jajaxd', 'SunkehTake1', 'sunkyrender', 'SUNKYYYYSYSYSYSYSYSY', 'sunkasd', 'sunkehhh'}
local oldRender = 0
local canRendersAppear = false

function onCreatePost()
	makeLuaSprite('sunkdance', 'sonido')
	addLuaSprite('sunkdance', true)
	setObjectCamera('sunkdance', 'other')
	screenCenter('sunkdance')
	setProperty('sunkdance.alpha', 0)

	for i = 1,#renders do
		makeLuaSprite(renders[i], 'chocolate/renders/'..renders[i])
		setObjectCamera(renders[i], 'other')
		addLuaSprite(renders[i], true)
		scaleObjectByScreen(renders[i], 0.75)
		setProperty(renders[i]..'.x', (i % 4) < 3 and (-getProperty(renders[i]..'.width')) or screenWidth)
		setProperty(renders[i]..'.y', (i % 2) < 1 and (-getProperty(renders[i]..'.height')) or screenHeight)
	end

	makeAnimatedLuaSprite('tras', 'chocolate/milk trasition')
	addAnimationByPrefix('tras', 'falls', 'milk falls', 24, false)
	addAnimationByPrefix('tras', 'go', 'milk go', 24, false)
	addAnimationByPrefix('tras', 'static', 'milk static', 24, false)
	setProperty('tras.alpha', 0)
	setObjectCamera('tras', 'hud')
	addLuaSprite('tras')

	makeLuaSprite('blackscr')
	makeGraphic('blackscr', 960, 720, '000000')
	addLuaSprite('blackscr', true)
	setObjectCamera('blackscr', 'other')
	setProperty('blackscr.alpha', 0)

	makeLuaSprite('sunkage', 'risa')
	addLuaSprite('sunkage', true)
	setObjectCamera('sunkage', 'other')
	screenCenter('sunkage')
	setProperty('sunkage.alpha', 0)

	makeLuaSprite('blackscr2', nil, -500, -400)
	makeGraphic('blackscr2', 2400, 1800, '000000')
	addLuaSprite('blackscr2', true)
	setObjectOrder('blackscr2', getObjectOrder('boyfriendGroup'))
	setProperty('blackscr2.alpha', 0)

	makeLuaSprite('spotlight', 'chocolate/light', getProperty('boyfriend.x') - 300, getProperty('boyfriend.y') - 700)
	addLuaSprite('spotlight', true)
	setObjectOrder('spotlight', getObjectOrder('boyfriendGroup') + 1)
	setProperty('spotlight.alpha', 0)
end

function onEvent(n,v1,v2)
	if n == 'sunkyEvent' then
		if v1 == 'sunkympeg' then
			doTweenAlpha('sunkdance', 'sunkdance', 1, 1)
		end
		if v1 == 'bolita' then
			cancelTween('sunkdance') removeLuaSprite('sunkdance', true)
			setProperty('disco.animation.paused', false)
			canRendersAppear = true
		end
		if v1 == 'transIn' then
			setProperty('tras.alpha', 1)
			playAnim('tras', 'falls', true)
			canRendersAppear = false
		end
		if v1 == 'transOut' then
			playAnim('tras', 'go', true)

			for i = 1,2 do setProperty('icon'..i..'.alpha', 1) setProperty('secondbg'..i..'.alpha', 1) setProperty('floot.alpha', 1) end
			for _,obj in ipairs({'bg', 'floor', 'speakerL', 'speakerR', 'disco'}) do setProperty(obj..'.alpha', 0) end
		end

		if v1 == 'blackscreen' then setProperty('blackscr.alpha', 1) end
		if v1 == 'bobrisa' then doTweenAlpha('sunkage', 'sunkage', 1, crochet / (1000 / 3.9)) end
		if v1 == 'back' then
			for i = 1,2 do removeLuaSprite('icon'..i, true) removeLuaSprite('secondbg'..i, true) removeLuaSprite('floot', true) end
			for _,obj in ipairs({'bg', 'floor', 'speakerL', 'speakerR', 'disco'}) do setProperty(obj..'.alpha', 1) end
			removeLuaSprite('sunkage', true) setProperty('blackscr.alpha', 0)

			triggerEvent('Change Character', 'dad', 'sunky') triggerEvent('Change Character', 'bf', 'bf-sunkeh')
			setProperty('gf.alpha', 1)
			canRendersAppear = true
		end

		if v1 == 'spotlight' then
			doTweenAlpha('spotlight', 'spotlight', 0.4, 2) doTweenAlpha('blackscr2', 'blackscr2', 0.6, 2)
		end
		if v1 == 'lightspot' then
			doTweenAlpha('spotlight', 'spotlight', 0, 0.8) doTweenAlpha('blackscr2', 'blackscr2', 0, 0.8)
		end

		if v1 == 'endsongg' then doTweenAlpha('blackscr', 'blackscr', 1, crochet / 500) end
	end
end

function onSectionHit()
	if curSection % 16 == 1 and canRendersAppear then
		local render = getRandomInt(1,#renders,oldRender)

		if getRandomBool(35) then
			if getRandomBool() then
				setProperty(renders[render]..'.y', (screenHeight - getProperty(renders[render]..'.height')) / 2)
				setProperty(renders[render]..'.x', (render % 4) < 3 and (-getProperty(renders[render]..'.width')) or screenWidth)
				doTweenX(renders[render]..'x', renders[render], (render % 4) < 3 and screenWidth or (-getProperty(renders[render]..'.width')), crochet / (1000 / 16))
			else
				setProperty(renders[render]..'.x', (screenWidth - getProperty(renders[render]..'.width')) / 2)
				setProperty(renders[render]..'.y', (render % 2) < 1 and (-getProperty(renders[render]..'.height')) or screenHeight)
				doTweenY(renders[render]..'y', renders[render], (render % 2) < 1 and screenHeight or (-getProperty(renders[render]..'.height')), crochet / (1000 / 16))
			end
		else
			setProperty(renders[render]..'.x', (render % 4) < 3 and (-getProperty(renders[render]..'.width')) or screenWidth)
			setProperty(renders[render]..'.y', (render % 2) < 1 and (-getProperty(renders[render]..'.height')) or screenHeight)

			doTweenX(renders[render]..'x', renders[render], (render % 4) < 3 and screenWidth or (-getProperty(renders[render]..'.width')), crochet / (1000 / 16))
			doTweenY(renders[render]..'y', renders[render], (render % 2) < 1 and screenHeight or (-getProperty(renders[render]..'.height')), crochet / (1000 / 16))
		end
		oldRender = render
	end
end

function onUpdatePost(e)
	if getProperty('disco.animation.curAnim.name') == 'drop' and getProperty('disco.animation.curAnim.finished') then
		playAnim('disco', 'idle', true)
	end
end

function scaleObjectByScreen(obj, offset)
	offset = offset or 1
	local scaleFactor = math.min(screenWidth / getProperty(obj..'.width'), screenHeight / getProperty(obj..'.height'))

	local newWidth = getProperty(obj..'.width') * scaleFactor
	local newHeight = getProperty(obj..'.height') * scaleFactor
	
	setGraphicSize(obj, math.floor(newWidth * offset), math.floor(newHeight * offset))
end