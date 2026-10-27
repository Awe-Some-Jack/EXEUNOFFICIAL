local yourselfNormal = {
    {name = 'back0',    path = 'eye/yourself/back/0-bg',                 x =    0, y = -100, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'back1',    path = 'eye/yourself/back/1-azul',               x =   80, y = -160, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'norm1',    path = 'eye/yourself/normal/1-black',            x = -200, y = 220, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'broken4',  path = 'eye/yourself/broken/4-azulBroken',       x = -200, y = 200, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'norm2',    path = 'eye/yourself/normal/2-azul',             x = -200, y = 200, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'norm3',    path = 'eye/yourself/normal/3-reflection',       x =  120, y = 320, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'norm4',    path = 'eye/yourself/normal/4-glass',            x =  450, y = 440, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'norm5',    path = 'eye/yourself/normal/5-shading',          x = -200, y = 360, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'broken5',  path = 'eye/yourself/broken/5-shadingBroken',    x = -200, y = 360, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'norm6',    path = 'eye/yourself/normal/6-glass',            x = -200, y = 380, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'broken1',  path = 'eye/yourself/broken/1-glassBroken',      x = -200, y = -250, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'broken2',  path = 'eye/yourself/broken/2-sharpBroken',      x =  480, y =  445, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'broken3',  path = 'eye/yourself/broken/3-reflectionBroken', x =  120, y = 320, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'norm7',    path = 'eye/yourself/normal/7-structure',        x = -200, y =  40, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'potinas',  path = 'eye/tinas',                              x =   85, y = -100, animated = true, animName = 'close', animPrefix = 'tinas', fps = 24, loop = false, scaleX = 2, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, front = true},
    {name = 'cortinas', path = 'eye/cor',                                x =   85, y = -400,                                                                                    scaleX = 2.5, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, front = true},
    {name = 'luces',    path = 'eye/xcxc',                               x =   45, y =  200,                                                                                    scaleX = 0.85, scaleY = 0.85, scrollX = 1, scrollY = 1, alpha = 1, front = true},
}

local yourselfBuddies = {
    {name = 'buddie1', path =      'eye/yourself/buddies/1-og', x = 1650, y =  850, scaleX =  0.2, scaleY =  0.2, scrollX = 1, scrollY = 1, alpha = 1, front = false},
    {name = 'buddie2', path =    'eye/yourself/buddies/3-damn', x = 2040, y =  880, scaleX = 0.25, scaleY = 0.25, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'buddie3', path =      'eye/yourself/buddies/6-uh', x = 1470, y =  940, scaleX = 0.26, scaleY = 0.26, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'buddie4', path =   'eye/yourself/buddies/4-small', x = 1780, y =  960, scaleX = 0.28, scaleY = 0.28, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'buddie5', path =    'eye/yourself/buddies/5-horn', x = 1210, y =  990, scaleX =  0.3, scaleY =  0.3, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name = 'buddie6', path =   'eye/yourself/buddies/7-white', x = 2090, y = 1000, scaleX = 0.35, scaleY = 0.35, scrollX = 1, scrollY = 1, alpha = 0, front = false, flipX = true},
    {name = 'buddie7', path =  'eye/yourself/buddies/2-jacket', x = 1640, y = 1050, scaleX = 0.35, scaleY = 0.35, scrollX = 1, scrollY = 1, alpha = 0, front = false},
}

local spotlights = {
    {name = 'spotlight1', path = 'eye/spotlight', x = getProperty('dad.x') + 450, y = 220, scaleX = 1, scaleY = 3, scrollX = 1, scrollY = 1, alpha = 0, blend = 'add', front = true},
}

local yourselfBG2 = {
    {name = 'oberlai1', path = 'eye/lyer', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, blend = 'normal', front = false},
    {name =   'build1', path = 'eye/edificio_fondo', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name =   'build2', path = 'eye/edificio_de_adelante', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name =     'piso', path = 'eye/bg', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, front = false},
    {name =  'oberlai', path = 'eye/lyer', x = 395, y = 160, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, blend = 'multiply', front = true},
}

local sillyBFsInstances = {
    {name = 'sillybg1', x = 1640, y = 610, sprite =       'sillybg', idk = false, alpha = 0},
    {name = 'sillybg2', x = 1470, y = 610, sprite =       'sillybg', idk = false, alpha = 0},
    {name = 'sillybg4', x = 1810, y = 610, sprite =       'sillybg', idk = false, alpha = 0},
    {name = 'sillybg3', x = 1040, y = 720, sprite = 'mirror lookbg', idk = false, alpha = 0},
}

local function createSprite(you)
    if you.animated then
        makeAnimatedLuaSprite(you.name, you.path, you.x, you.y)
        addAnimationByPrefix(you.name, you.animName, you.animPrefix, you.fps, you.loop)
    else
        makeLuaSprite(you.name, you.path, you.x, you.y)
    end
    if you.scaleX or you.scaleY   then scaleObject(you.name, you.scaleX, you.scaleY) end
    if you.scrollX or you.scrollY then setScrollFactor(you.name, you.scrollX, you.scrollY) end
    setProperty(you.name..'.alpha', you.alpha)
    addLuaSprite(you.name, you.front)
    if you.flipX then setProperty(you.name..'.flipX', you.flipX) end
    if you.aboveFakeBF then setObjectOrder(you.name, getObjectOrder('boyfriendGroup') - 1) end
    if you.blend then setBlendMode(you.name, you.blend) end
end

function onCreate()
    startVideo("EYE_TO_EYE intro", false, true, false, false)
    callMethod("remove", {instanceArg("videoCutscene")})

    for _, you   in ipairs(yourselfNormal)  do createSprite(you)   end
    for _, you   in ipairs(yourselfBuddies) do createSprite(you)   end
    for _, spot  in ipairs(spotlights)      do createSprite(spot)  end
    for _, rself in ipairs(yourselfBG2)     do createSprite(rself) end

    setProperty('gf.visible', false)

    makeLuaSprite('blackscreen')
    makeGraphic('blackscreen', 3000, 2000, '000000')
    addLuaSprite('blackscreen', true)

    for _, inst in ipairs(sillyBFsInstances) do
        createInstance(inst.name, 'objects.Character', {inst.x, inst.y, inst.sprite, inst.idk})
        setProperty(inst.name..'.alpha', inst.alpha)
        setObjectOrder(inst.name, getObjectOrder('norm6'))
        addInstance(inst.name)
    end

    --Buddies shaders
    for _, you in ipairs(yourselfBuddies) do setProperty(you.name..'.visible', false) end
end

function onSongStart() setObjectOrder('dadGroup', getObjectOrder('norm3')) end

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

    if curBeat < 191 then
		playAnim('dad', getProperty('boyfriend.animation.curAnim.name'), true)
		setProperty('dad.animation.curAnim.curFrame', getProperty('boyfriend.animation.curAnim.curFrame'))
		setProperty('dad.holdTimer', 0)
	end
end

function onEvent(eventName, value1, value2)
    if eventName == 'Change Character' then
        if value1 == 'dad' then setObjectOrder('dadGroup', getObjectOrder('boyfriendGroup')) end
    end
    if eventName == 'yourselfEvents' then
        local split = stringSplit(value2, ',')
        if value1 == 'fuckyoublackscreen' then
            removeLuaSprite('blackscreen', true)
        elseif value1 == 'destroyVideo' then
            if getProperty('videoCutscene') == nil then return end
            callMethod('remove', {instanceArg('videoCutscene')})
        elseif value1 == 'brokenStage' then
            for _, norms in ipairs({'norm2', 'norm3', 'norm4', 'norm5', 'norm6', 'luces'}) do  triggerEvent('yourselfEvents', 'removeSprite', norms) end
            for _, broken in ipairs({'broken1', 'broken2', 'broken3', 'broken4', 'broken5'}) do setProperty(broken..'.alpha', 1) end
            if getProperty('videoCutscene') == nil then return end
            callMethod('remove', {instanceArg('videoCutscene')})
        elseif value1 == 'showBuddies' then
            for _, you in ipairs(yourselfBuddies) do setProperty(you.name..'.visible', true)  end
            setProperty(value2..'.alpha', 1)
        elseif value1 == 'tweenInstancesAlpha' then
            if curBeat < 272 then cameraShake('game', 0.01, 0.1) cameraShake('hud', 0.005, 0.1)
            else
                for _, instances in ipairs({'sillybg1', 'sillybg2', 'sillybg3', 'sillybg4'}) do doTweenAlpha(instances..'Alpha', instances, value2, 2) end
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
            for _, hideYour in ipairs(yourselfNormal) do
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
            for _, showYour in ipairs(yourselfNormal) do
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

local seenVideo = false

function onEndSong()
    if seenVideo == false then
        cancelTween('BlackGraphicOtherAlpha')
        setProperty('BlackGraphicOther.alpha', 0)
        startVideo('soundtestcodes')
        setProperty('camGame.visible', false)  setProperty('camHUD.visible', false)
        seenVideo = true
        return Function_Stop
    end

    return Function_Continue
end

function onEndVideo()
    setProperty('BlackGraphicOther.alpha', 1)
    endSong()
end