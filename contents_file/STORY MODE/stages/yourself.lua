local yourselfBG1Old = { -- This bg is scrapped. Damn
    {name = 'fondo', path = 'eye/bg_fondo', x = 85, y = 200, scaleX = 0.85, scaleY = 0.85, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'piso1', path = 'eye/piso-1', x = 85, y = 200, scaleX = 0.85, scaleY = 0.85, scrollX = 1, scrollY = 1, aboveFakeBF = true, alpha = 1, front = false},
    {name = 'piso2', path = 'eye/piso-1 2', x = 85, y = 200, scaleX = 0.85, scaleY = 0.85, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'pico', path = 'eye/pico-del-frente', x = 85, y = 200, scaleX = 0.85, scaleY = 0.85, scrollX = 1, scrollY = 1, alpha = 1, front = true},
    {name = 'luces', path = 'eye/xcxc', x = 85, y = 200, scaleX = 0.85, scaleY = 0.85, scrollX = 1, scrollY = 1, alpha = 1, front = true},
    {name = 'potinas', path = 'eye/tinas', x = 85, y = 0, animated = true, animName = 'close', animPrefix = 'tinas', fps = 24, loop = false, scaleX = 2, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, front = true},
    {name = 'cortinas', path = 'eye/cor', x = 85, y = -300, scaleX = 2.5, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, front = true},
}

local yourselfBG1 = {
    {name = 'bgBack',       path =           'eye/new bg yoursefl/back', x = -150, y = -250,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'layer2',       path =        'eye/new bg yoursefl/layers2', x =  300, y =  400,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'blue2',        path =    'eye/new bg yoursefl/blue-thing2', x = -150, y =  100,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'layer1',       path =        'eye/new bg yoursefl/layers1', x = -150, y =  300,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'blue',         path =     'eye/new bg yoursefl/blue-thing', x = -150, y =  100,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'bgUp',         path =             'eye/new bg yoursefl/up', x =  350, y =   50,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'mirrorStuff',  path =   'eye/new bg yoursefl/mirror-stuff', x =  150, y =  350,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'mirrorStuff2', path =  'eye/new bg yoursefl/mirror-stuff2', x = -150, y =  400,                                                                                    scaleX =   1, scaleY =   1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    --{name = 'mirrorStuff3', path =      'eye/new bg yoursefl/mirror-up', x = -150, y =  300,                                                                                    scaleX = 0.9, scaleY = 0.9, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    --{name = 'mirrorDown',   path =    'eye/new bg yoursefl/mirror-down', x = -150, y =  300,                                                                                    scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    --{name = 'mirrorShit',   path =    'eye/new bg yoursefl/mirror-shit', x =  450, y =    0,                                                                                    scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'bgDown',       path =           'eye/new bg yoursefl/down', x = -150, y =   50,                                                                                    scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    --{name = 'bgDownBroken', path =    'eye/new bg yoursefl/down-broken', x = -150, y =   50,                                                                                    scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'potinas',      path =                          'eye/tinas', x =   85, y =    0, animated = true, animName = 'close', animPrefix = 'tinas', fps = 24, loop = false, scaleX = 2, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, front = true},
    {name = 'cortinas',     path =                            'eye/cor', x =   85, y = -300,                                                                                    scaleX = 2.5, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, front = true},
}

local cristales = {
    {name = 'cristal1', path = 'eye/espejos/1', x = getProperty('dad.x') + 80, y = getProperty('dad.y') - 230, scaleX = 0.65, scaleY = 0.6, scrollX = 0.95, scrollY = 0.95, behindFakeBF = true, alpha = 1, front = false},
    {name = 'cristal2', path = 'eye/espejos/2', x = 2600, y = 480, scaleX = 0.6, scaleY = 0.6, scrollX = 0.95, scrollY = 0.95, alpha = 1, front = false},
    {name = 'cristal3', path = 'eye/espejos/3', x = 2230, y = 480, scaleX = 0.8, scaleY = 0.8, scrollX = 0.98, scrollY = 0.98, alpha = 1, front = false},
    {name = 'cristal4', path = 'eye/espejos/4', x = 2000, y = 620, scaleX = 0.6, scaleY = 0.6, scrollX = 0.98, scrollY = 0.98, alpha = 1, front = false},
    {name = 'cristal5', path = 'eye/espejos/5', x = 1650, y = 600, scaleX = 0.75, scaleY = 0.75, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'cristal6', path = 'eye/espejos/5', x = 1300, y = 600, scaleX = 0.75, scaleY = 0.75, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'cristal7', path = 'eye/espejos/6', x = 1150, y = 620, scaleX = 0.75, scaleY = 0.75, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'cristal8', path = 'eye/espejos/7', x = 800, y = 680, scaleX = 0.75, scaleY = 0.75, scrollX = 1, scrollY = 1, alpha = 1, front = false},
}

local spotlights = {
    {name = 'spotlight1', path = 'eye/spotlight', x = getProperty('dad.x') + 450, y = 220, scaleX = 1, scaleY = 3, scrollX = 1, scrollY = 1, alpha = 0, blend = 'add', front = true},
}

local yourselfBG2 = {
    {name = 'oberlai1', path = 'eye/lyer', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, blend = 'normal', front = false},
    {name = 'build1', path = 'eye/edificio_fondo', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'build2', path = 'eye/edificio_de_adelante', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'piso', path = 'eye/bg', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'oberlai', path = 'eye/lyer', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, blend = 'multiply', front = true},
}

local sillyBFsInstances = {
    {name = 'sillybg1', x = 1640, y = 600, sprite = 'sillybg', idk = false, alpha = 0},
    {name = 'sillybg2', x = 1270, y = 600, sprite = 'sillybg', idk = false, alpha = 0},
    {name = 'sillybg4', x = 2010, y = 600, sprite = 'sillybg', idk = false, alpha = 0},
    {name = 'sillybg3', x = 1020, y = 630, sprite = 'mirror lookbg', idk = false, alpha = 0},
}

function onCreate()
    startVideo("EYE_TO_EYE intro", false, true, false, false)
    callMethod("remove", {instanceArg("videoCutscene")})

    for _, you in ipairs(yourselfBG1) do
        if you.animated then
            makeAnimatedLuaSprite(you.name, you.path, you.x, you.y)
            addAnimationByPrefix(you.name, you.animName, you.animPrefix, you.fps, you.loop)
        else
            makeLuaSprite(you.name, you.path, you.x, you.y)
        end
        scaleObject(you.name, you.scaleX, you.scaleY)
        setScrollFactor(you.name, you.scrollX, you.scrollY)
        setProperty(you.name..'.alpha', you.alpha)
        addLuaSprite(you.name, you.front)
        if you.aboveFakeBF then
            setObjectOrder(you.name, getObjectOrder('boyfriendGroup') - 1)
        end
    end

    --[[
    makeLuaSprite('graphFix', nil, 500, 1720)
    makeGraphic('graphFix', screenHeight * 2, screenHeight * 2, '171616')
    setProperty('graphFix.scale.x', 4)
    addLuaSprite('graphFix', false)
    ]]

    for _, spot in ipairs(spotlights) do
        makeLuaSprite(spot.name, spot.path, spot.x, spot.y)
        scaleObject(spot.name, spot.scaleX, spot.scaleY)
        setScrollFactor(spot.name, spot.scrollX, spot.scrollY)
        setProperty(spot.name..'.alpha', spot.alpha)
        if spot.blend then
            setBlendMode(spot.name, spot.blend)
        end
        addLuaSprite(spot.name, spot.front)
    end

    --[[
    for _, yes in ipairs(cristales) do
        makeLuaSprite(yes.name, yes.path, yes.x, yes.y)
        scaleObject(yes.name, yes.scaleX, yes.scaleY)
        setScrollFactor(yes.name, yes.scrollX, yes.scrollY)
        setProperty(yes.name..'.alpha', yes.alpha)
        setProperty(yes.name..'.antialiasing', yes.antialiasing)
        if yes.behindFakeBF then
            setObjectOrder(yes.name, getObjectOrder('dadGroup'))
        else
            setObjectOrder(yes.name, getObjectOrder('piso2'))
        end
        addLuaSprite(yes.name, yes.front)
    end
    ]]

    for _, rself in ipairs(yourselfBG2) do
        makeLuaSprite(rself.name, rself.path, rself.x, rself.y)
        scaleObject(rself.name, rself.scaleX, rself.scaleY)
        setScrollFactor(rself.name, rself.scrollX, rself.scrollY)
        setProperty(rself.name..'.alpha', rself.alpha)
        addLuaSprite(rself.name, rself.front)
        if rself.blend then
            setBlendMode(rself.name, rself.blend)
        end
    end
    setProperty('gf.visible', false)
    setScrollFactor('gfGroup', 1, 1)

    makeLuaSprite('blackscreen')
    makeGraphic('blackscreen', 3000, 2000, '000000')
    addLuaSprite('blackscreen', true)

    for _, inst in ipairs(sillyBFsInstances) do
        createInstance(inst.name, 'objects.Character', {inst.x, inst.y, inst.sprite, inst.idk})
        addInstance(inst.name)
        setProperty(inst.name..'.alpha', inst.alpha)
        --setObjectOrder(inst.name, getObjectOrder('piso2'))
    end
end


function onUpdatePost()
    playAnim('sillybg1', getProperty('dad.animation.curAnim.name'):gsub('-mini', ''), true)
	setProperty('sillybg1.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))

    playAnim('sillybg2', getProperty('dad.animation.curAnim.name'):gsub('-mini', ''), true)
	setProperty('sillybg2.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))

    playAnim('sillybg4', getProperty('dad.animation.curAnim.name'):gsub('-mini', ''), true)
	setProperty('sillybg4.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))

    playAnim('sillybg3', getProperty('dad.animation.curAnim.name'):gsub('-mini', '')..'-alt', true)
	setProperty('sillybg3.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame'))

    setProperty('healthBGYourself.alpha', getProperty('hbBG.alpha'))
end

function onEvent(eventName, value1, value2)
    if eventName == 'yourselfEvents' then
        if value1 == 'fuckyoublackscreen' then
            removeLuaSprite('blackscreen', true)
        elseif value1 == 'fadeLights' then
            local split = stringSplit(value2, ',')
            doTweenAlpha('lucesAlpha', 'luces', split[1], split[2])
        elseif value1 == 'tweenInstancesAlpha' then
            if curBeat < 272 then cameraShake('game', 0.01, 0.1) cameraShake('hud', 0.005, 0.1) 
            else
                for _, instances in ipairs({'sillybg1', 'sillybg2', 'sillybg3', 'sillybg4'}) do
                    doTweenAlpha(instances..'Alpha', instances, value2, 2)
                end
            end
        elseif value1 == 'removeSprite' then
            removeLuaSprite(value2, true)
        elseif value1 == 'lightsInteraction' then
            setObjectOrder('spotlight1', getObjectOrder('BlackGraphicGame') + 1)
            if value2 == 'dad' then
                doTweenX('spotlight1ScaleX', 'spotlight1.scale', 1, 0.6, 'circOut')
            elseif value2 == 'dadAgain' then
                setProperty('spotlight1.x', getProperty('spotlight1.x') - 1000)
                doTweenX('spotlight1ScaleX', 'spotlight1.scale', 1, 0.6, 'circOut')
            elseif value2 == 'fade' then
                doTweenX('spotlight1ScaleX', 'spotlight1.scale', 0, 0.6, 'circIn')
            elseif value2 == 'bf' then
                setProperty('spotlight1.x', getProperty('spotlight1.x') + 1000)
                doTweenX('spotlight1ScaleX', 'spotlight1.scale', 1, 0.6, 'circOut')
            elseif value2 == 'tweenToBF' then
                doTweenX('spotlight1X', 'spotlight1', getProperty('spotlight1.x') + 1000, 0.6, 'circOut')
            end
        elseif value1 == 'showOffNewStage' then
            for _, hideYour in ipairs(yourselfBG1) do
                setProperty(hideYour.name..'.alpha', 0)
            end

            for _, showSelf in ipairs(yourselfBG2) do
                setProperty(showSelf.name..'.alpha',  showSelf.name == 'oberlai1' and 0.5 or 1)
            end
            setProperty('gf.visible', true)
            setProperty('BlackGraphicGame.alpha', 0)
            removeLuaSprite('spotlight1', true)
    elseif value1 == 'fadeBG' then
            for _, hideSelf in ipairs(yourselfBG2) do
                doTweenAlpha(hideSelf.name..'Alpha', hideSelf.name, 0, 10)
            end
            doTweenAlpha('gfAlpha', 'gf', 0, 10)
            for _, showYour in ipairs(yourselfBG1) do
                doTweenAlpha(showYour.name..'Alpha', showYour.name, 1, 10)
                if showYour.name == 'potinas' then
                    doTweenAlpha(showYour.name..'Alpha', showYour.name, 0, 10)
                end
            end
        elseif value1 == 'cortinasBro' then
            setProperty('potinas.alpha', 1)
            playAnim('potinas', 'close', true)
        end
    end
end

--video functions, ignore

function onGameOver()
	if getProperty('videoCutscene') == nil then return end
    callMethod('videoCutscene.destroy')
    callMethod('remove', {instanceArg('videoCutscene')})
end

function onDestroy()
	if getProperty('videoCutscene') == nil then return end
    callMethod('remove', {instanceArg('videoCutscene')})
end

function onPause()
    if getProperty('videoCutscene') == nil then return end
    callMethod('videoCutscene.pause')
    if callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('videoCutscene.videoSprite.pause')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusLost.remove', {instanceArg('videoCutscene.videoSprite.pause')})
    end
    if callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('videoCutscene.videoSprite.resume')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusGained.remove', {instanceArg('videoCutscene.videoSprite.resume')})
    end
end

function onResume()
    if getProperty('videoCutscene') == nil then return end
    callMethod('videoCutscene.resume')
    if not callMethodFromClass('flixel.FlxG', 'signals.focusLost.has', {instanceArg('videoCutscene.videoSprite.pause')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusLost.add', {instanceArg('videoCutscene.videoSprite.pause')})
    end
    if not callMethodFromClass('flixel.FlxG', 'signals.focusGained.has', {instanceArg('videoCutscene.videoSprite.resume')}) then
        callMethodFromClass('flixel.FlxG', 'signals.focusGained.add', {instanceArg('videoCutscene.videoSprite.resume')})
    end
end