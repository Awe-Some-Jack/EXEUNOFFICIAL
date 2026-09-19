--[=[local SANIC_ANIMS = {'idle', 'left', 'down', 'up', 'right'}

local sentimentalActive = false

local function createBackdropClone(name, velocity, scale)
	createInstance(name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01, -200})
	loadFrames(name, 'characters/Sanic')
	for i, anim in ipairs(SANIC_ANIMS) do
		addAnimationByPrefix(name, (i > 1 and getProperty('singAnimations['..(i - 2)..']') or 'idle'), anim, 24, false)
	end
	addInstance(name)
	if scale then scaleObject(name, scale, scale, false) end
	setProperty(name .. '.visible', false)
	setProperty(name .. '.velocity.x', velocity)
end

local function syncToCharacter(clone, source, copyOffset)
	local anim = getProperty(source .. '.animation.curAnim.name')
	local frame = getProperty(source .. '.animation.curAnim.curFrame')
	playAnim(clone, anim, true)
	setProperty(clone .. '.animation.curAnim.curFrame', frame)
	if copyOffset then
		setProperty(clone .. '.offset.x', getProperty(source .. '.offset.x'))
		setProperty(clone .. '.offset.y', getProperty(source .. '.offset.y'))
	end
end

function onCreate()
	createInstance('bgFront', 'hxvlc.flixel.FlxVideoSprite', {nil, -900, -800})
    callMethod('bgFront.load', {callMethodFromClass('backend.Paths', 'video', {'bg'..getRandomInt(1,2)})})
    addInstance('bgFront')
    setProperty('bgFront.videoSprite.antialiasing', false)
    runHaxeCode([[
        game.getLuaObject('bgFront').bitmap.onFormatSetup.add(() -> {
			game.getLuaObject('bgFront').scale.set(2, 2);
            game.getLuaObject('bgFront').updateHitbox();
        });
        game.getLuaObject('bgFront').bitmap.onEndReached.add(() -> game.getLuaObject('bgFront').destroy());
    ]])

	makeLuaSprite('darkOverlay', nil, -700, -700)
	makeGraphic('darkOverlay', 3500, 2000, '000000')
	addLuaSprite('darkOverlay')
	setProperty('darkOverlay.alpha', 0)

	local spotlightData = {
		{name = 'spotlight1', target = 'dad',       offsetX = -350, offsetY = -400},
		{name = 'spotlight2', target = 'boyfriend',  offsetX = -600, offsetY = -700},
	}
	for _, sp in ipairs(spotlightData) do
		makeLuaSprite(sp.name, 'spotlight', getProperty(sp.target .. '.x') + sp.offsetX, getProperty(sp.target .. '.y') + sp.offsetY)
		scaleObject(sp.name, 2, 2.5)
		addLuaSprite(sp.name, true)
		setProperty(sp.name .. '.alpha', 0)
		setBlendMode(sp.name, 'add')
	end

	local sentinelData = {
		{name = 'bfSentinel',    x = 1700,  sprite = 'sanic-bf', isPlayer = true},
		{name = 'sanicSentinel', x = -1300, sprite = 'sanic',    isPlayer = false},
	}
	for _, s in ipairs(sentinelData) do
		createInstance(s.name, 'objects.Character', {s.x, 400, s.sprite, s.isPlayer})
		scaleObject(s.name, 2.5, 2.5)
		setObjectCamera(s.name, 'hud')
		addInstance(s.name)
		setProperty(s.name .. '.alpha', 0)
	end

	createBackdropClone('sanicClone1', 2000)
	setObjectOrder('sanicClone1', getObjectOrder('dadGroup') - 1)
	createBackdropClone('sanicClone2', 1500, 0.7)
	setObjectOrder('sanicClone2', getObjectOrder('sanicClone1') - 1)

	makeLuaSprite('topBar', nil, 0, -100)
	makeGraphic('topBar', screenWidth, 100, '000000')
	setObjectCamera('topBar', 'hud')
	addLuaSprite('topBar')

	makeLuaSprite('botBar', nil, 0, screenHeight)
	makeGraphic('botBar', screenWidth, 100, '000000')
	setObjectCamera('botBar', 'hud')
	addLuaSprite('botBar')
end

function onGameOverStart()
	callMethod('bgFront.destroy')
end

function onSongStart()
	callMethod('bgFront.play')
end

function onCreatePost()
	setTextFont('hitCounterText', 'Comic Sans MS.ttf')
	setTextFont('exeScoreTxt', 'Comic Sans MS.ttf')

	makeLuaSprite('bandimark', 'bandimark', 0, 5)
	setObjectCamera('bandimark', 'other')
	scaleObject('bandimark', 1.2, 1.2)
	setProperty('bandimark.alpha', 0.5)
	screenCenter('bandimark', 'x')
	addLuaSprite('bandimark', true)
end

function onUpdatePost()
	syncToCharacter('bfSentinel', 'boyfriend', false)
	syncToCharacter('sanicSentinel', 'dad', false)
	syncToCharacter('sanicClone1', 'dad', true)
	syncToCharacter('sanicClone2', 'dad', true)
end

function onEvent(n)
	if n == 'mierdaactivador' then
		setProperty('sanicClone1.visible', not getProperty('sanicClone1.visible'))
		setProperty('sanicClone2.visible', not getProperty('sanicClone2.visible'))

	elseif n == 'sentimental' then
		sentimentalActive = not sentimentalActive
		if sentimentalActive then
			doTweenAlpha('spotFade1', 'spotlight1', 0.3, 5)
			doTweenAlpha('spotFade2', 'spotlight2', 0.3, 5)
			doTweenY('topBarMove', 'topBar', 0, 1, 'cubeOut')
			doTweenY('botBarMove', 'botBar', screenHeight - 100, 1, 'cubeOut')
		else
			doTweenAlpha('spotFade1', 'spotlight1', 0, 1)
			doTweenAlpha('spotFade2', 'spotlight2', 0, 1)
			doTweenAlpha('bfSentFade', 'bfSentinel', 0, 1)
			doTweenAlpha('sanicSentFade', 'sanicSentinel', 0, 1)
			doTweenX('bfSentMove', 'bfSentinel', 1700, 1, 'cubeIn')
			doTweenX('sanicSentMove', 'sanicSentinel', -1300, 1, 'cubeIn')
			doTweenY('topBarMove', 'topBar', -100, 1, 'cubeIn')
			doTweenY('botBarMove', 'botBar', screenHeight, 1, 'cubeIn')
		end
		doTweenAlpha('darkFade', 'darkOverlay', sentimentalActive and 0.6 or 0, 1)

	elseif n == 'bfsent' then
		doTweenAlpha('bfSentFade', 'bfSentinel', 0.5, 6)
		doTweenX('bfSentMove', 'bfSentinel', 1000, 6, 'cubeOut')
		doTweenAlpha('sanicSentFade', 'sanicSentinel', 0.5, 6)
		doTweenX('sanicSentMove', 'sanicSentinel', -300, 6, 'cubeOut')
	end
end

function onPause() callMethod('bgFront.pause') end
function onResume() callMethod('bgFront.resume') end]=]