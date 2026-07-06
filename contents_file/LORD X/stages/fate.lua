-- Todo:

-- Remake the entire code. Make arrays, local functions, state better the events, make a better looking code, etc. ✅

-- Use another shader script from another song so the one i used before doesn't lag or stop working. ✅

-- Recode the "give up" lyrics if anything?

-- Redo camera events. fuck that shit was ASS.

-- Make a more appealing dodge mechanic.

-- Ask someone to make a "LET'S BEGIN" text type thing. ✅

-- Hermano me pica el culo vastísimo

runHaxeCode("var trail:Character;")

local fateAssets = {
    ['BG1'] = {
        {name =       'nieblia', path =                 'fate/niebla', x =  -400, y = -600, animated =  true, animName = 'idle', animPrefix = 'Símbolo 29', fps = 24, loop = true, scaleX = 2.3, scaleY = 2.3, alpha = 0,                                                     lq = false, front = false},
        {name =         'cells', path =        'fate/YOUR-FATE/cells', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = false},
        {name =     'fakerEyes', path =    'fate/YOUR-FATE/faker-eye', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = false},
        {name =       'cuadros', path =       'fate/YOUR-FATE/covers', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = false},
        {name = 'cuadrosArriba', path =     'fate/YOUR-FATE/upCovers', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = false},
        {name =        'ground', path =  'fate/YOUR-FATE/ground-dark', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = false},
        {name =          'land', path =         'fate/YOUR-FATE/land', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = false},
        {name =  'overlayStage', path = 'fate/YOUR-FATE/overlayStage', x =  -400, y = -600, animated = false,                                                                      scaleX = 1, scaleY = 1, alpha = 0,                                                     lq = false, front = true},
        {name =    'redOverlay', path =                'fate/overlay', x =  -400, y = -600, animated = false,                                                                      scaleX =   1, scaleY =   2, alpha = 0, behind = 'nieblia', flipY = true, color = 'FF0000', lq = false, front = false},
    },
    ['BG2'] = {
        {name = 'niebliaFinal', path =    'fate/niebla 2', x =  80, y = 20, animated = true, animName = 'idle', animPrefix =  'Símbolo 34', fps = 24, loop = true, scaleX =  1.8, scaleY =   1, alpha = 0, lq = false, front = false},
        {name =    'fateFinal', path = 'fate/finalGround', x =  80, y = 20,                                                                                        scaleX =  1.2, scaleY = 1.2, alpha = 0, lq = false, front = false},
    },
    ['Misc'] = {
        {name = 'spaceBar',    path =      'fate/spacebar',  x =  380, y =   360, scaleX = 1, scaleY = 1,               animated =  true, animName = 'idle',  animPrefix =   'Símbolo 8',              fps = 24, loop = true, camera = 'camHUD', alpha = 0,                                  front = false},
        {name = 'lordXBite',   path = 'characters/mordida',  x = 1350, y =  1200, scaleX = 0, scaleY = 0,               animated =  true, animName = 'idle',  animPrefix = 'Símbolo 403', index = '0', fps = 24, loop = true,                    alpha = 1,                                  front = false},
        {name = 'bfFALL',      path = 'characters/bf void',  x =  600, y =  1900, scaleX = 3, scaleY = 3,               animated =  true, animName = 'idle',  animPrefix =  'Símbolo 71',              fps = 24, loop = true,                    alpha = 1,                                  front = false},
        {name = 'transition',  path =       'fate/overlay',  x = -550, y = -1500, scaleX = 1, scaleY = 3,               animated = false,                                                                                     camera = 'camHUD', alpha = 0, color = '000000',                front = false},
        {name = 'fog',         path =           'fate/fog',  x =    0, y =     0, scaleX = 1, scaleY = 1,               animated = false,                                                                                     camera = 'camHUD', alpha = 0,                   blend = 'add', front = false},
        {name = 'transition2', path =       'fate/overlay',  x = -550, y = -3560, scaleX = 1, scaleY = 3, flipY = true, animated = false,                                                                                     camera = 'camHUD', alpha = 0, color = '000000',                front = false},
    },
    ['Lets-Begin'] = {
        {name = 'lets-pixel',   path =   'fate/lets-begin/lets_pixel', x = 200, y = -90, scaleX = 0.4, scaleY = 0.4, camera = 'camOther', alpha = 0, front = false},
        {name = 'lets-normal',  path =  'fate/lets-begin/lets_normal', x = 200, y = -90, scaleX = 0.4, scaleY = 0.4, camera = 'camOther', alpha = 0, front = false},
        {name = 'begin-pixel',  path =  'fate/lets-begin/begin_pixel', x = 200, y = -90, scaleX = 0.4, scaleY = 0.4, camera = 'camOther', alpha = 0, front = false},
        {name = 'begin-normal', path = 'fate/lets-begin/begin_normal', x = 200, y = -90, scaleX = 0.4, scaleY = 0.4, camera = 'camOther', alpha = 0, front = false},
    }
}

local function setFateConfig()
    setProperty('gf.visible', false)
    setScrollFactor('gfGroup', 1, 1)
    setProperty('boyfriend.visible', false)

    for i = 0,3 do setProperty('opponentStrums.members['..i..'].x', -500) end

    for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(stuff..'.alpha', 0) end

    for i = 0, 7 do setPropertyFromGroup('strumLineNotes', i, 'y', (downscroll and 770 or -250)) end

    makeLuaSprite('healthShit')

    setProperty('BlackGraphicGame.alpha', 1)
end

local function prepareCharacters()
    addCharacterToList('lord x podrido', 'dad')
    addCharacterToList('lord x p3corto', 'dad')
    addCharacterToList('lord x p3largo', 'dad')
    --addCharacterToList('lord x p3scream', 'dad')
    addCharacterToList('bfo', 'bf')
    addCharacterToList('bf-perspective-right', 'bf')
end

local fakerEyesPos = {}
local function createSprite(spr)
    if not spr.lq then
        if spr.animated then
            makeAnimatedLuaSprite(spr.name, spr.path, spr.x, spr.y)
            if spr.index then
                addAnimationByIndices(spr.name, spr.animName, spr.animPrefix, spr.index, spr.fps, spr.loop)
            else
                addAnimationByPrefix(spr.name, spr.animName, spr.animPrefix, spr.fps, spr.loop)
            end
        else
            makeLuaSprite(spr.name, spr.path, spr.x, spr.y)
        end
        if spr.scaleX or spr.scaleY then scaleObject(spr.name, spr.scaleX, spr.scaleY) end
        if spr.camera then setObjectCamera(spr.name, spr.camera) end
        setProperty(spr.name..'.alpha', spr.alpha)
        addLuaSprite(spr.name, spr.front)
        if spr.center then screenCenter(spr) end
        if spr.color  then setProperty(spr.name..'.color', getColorFromHex(spr.color)) end
        if spr.behind then setObjectOrder(spr.name, getObjectOrder(spr.behind)) end
        if spr.blend  then setBlendMode(spr.name, spr.blend) end
        if spr.flipY  then setProperty(spr.name..'.flipY', true) end
    end
end

local function createAtlasSprite(spr)
    makeFlxAnimateSprite(spr, -400, -400, "fate/fate")
    addAnimationBySymbol(spr, 'exes!', "fate")
    setObjectOrder(spr, getObjectOrder('bfFALL') - 1)
    setProperty(spr..'.alpha', 0)
    addLuaSprite(spr)
end

local function createIllegalInstruction()
    math.randomseed(os.clock())
    for i = 1, math.random(4, 5) do
        makeLuaSprite('illegal'..i, 'fate/illegalinstruction', math.random(50, 860), math.random(30, 750))
        setProperty('illegal'..i..'.alpha', 0)
        setObjectCamera('illegal'..i, 'camHUD')
        addLuaSprite('illegal'..i, false)
    end
end

local trailExists = false

local function pumpCloneBF()
    runHaxeCode([[
        trail = new Character(0, 0, boyfriend.curCharacter, boyfriend.isPlayer);
        trail.updateHitbox();
        trail.setPosition(boyfriend.x, boyfriend.y);
        trail.scale.set(boyfriend.scale.x, boyfriend.scale.x);
        trail.alpha = 0.8;
        trail.playAnim(boyfriend.animation.curAnim.name);
        game.add(trail);

        FlxTween.tween(trail.scale, {x: boyfriend.scale.x + 0.4, y: boyfriend.scale.y + 0.4}, 1);
        FlxTween.tween(trail, {alpha: 0}, 1, {ease: FlxEase.circOut, onComplete: (_) -> {
            remove(trail);
            trail.destroy();
        }});
    ]])
    trailExists = true cancelTimer('itdoesntexist') runTimer('itdoesntexist', 1)
end

local function addCountDown(sprite)
    makeLuaSprite('CountDown'..sprite, sprite, 350, 200)
    setObjectCamera('CountDown'..sprite, 'camHUD')
    addLuaSprite('CountDown'..sprite, true)
    scaleObject('CountDown'..sprite, 0.8, 0.8)
    doTweenScale('CountDown'..sprite, 'CountDown'..sprite, 0.6, 0.6, 'circOut')
    startTween(sprite..'Tween', 'CountDown'..sprite, {x = getProperty('CountDown'..sprite..'.x') + getRandomFloat(-20, 20), y = getProperty('CountDown'..sprite..'.y') + 80, alpha = 0, angle = getRandomFloat(-5, 5)}, 0.6, {ease = 'smootherStepOut'})
end

local separation = 50
local waveNotes  = false
local shakeNotes = false
local shakeIntensity = 2
local zoomingStage = false
local fateStrumEvents = {
    ['bfStrums'] = function(mode)
        if mode == 'return' then
            for i = 0, 3 do startTween(i..'BF', 'playerStrums.members['..i..']', {x = _G['defaultPlayerStrumX'..i], y = _G['defaultPlayerStrumY'..i], angle = 0}, 1.3 + (i * math.random(0.1, 0.2)) / playbackRate, {ease = 'backOut'}) end
        end
        if mode == 'center' then
            for i = 0, 3 do setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i) end
        end
        if mode == 'tweenCenter' then
            for i = 0, 3 do doTweenX(i..'BFCenterX', 'playerStrums.members['..i..']', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i, 3 / playbackRate, 'backInOut') end
            for i = 0, 3 do doTweenAlpha(i..'DADCenterAlpha', 'opponentStrums.members['..i..']', 0, 2 / playbackRate, 'backInOut') end
        end
        if mode == 'fall' then
            for i = 4, 7 do
                noteTweenY(i..'BFFall',      i, 850, 1.3 + (i * math.random(0.1, 0.2)) / playbackRate, 'backIn')
                noteTweenAngle(i..'BFAngle', i, math.random(15, -15), 1.3 + (i * math.random(0.1, 0.2)) / playbackRate)
            end
        end
    end,
    ['dadStrums'] = function(mode)
        if mode == 'show' then
            for i = 0, 3 do
                noteTweenY(i..'DAD', i, (downscroll and 570 or 50), 0.9 + (i * 0.1) / playbackRate, 'smootherStepOut')
                noteTweenAlpha(i..'Tween', i, 1, 0.4 / playbackRate)


                setProperty('transition.alpha', 0)
                setProperty('transition.y', -2500)
                setProperty('transition2.y', getProperty('transition.y') - 1000)
                setProperty('transition.scale.y', 6)
                setProperty('transition2.scale.y', 6.6)
            end
        end
        if mode == 'return' then
            for i = 0, 3 do startTween(i..'DAD', 'opponentStrums.members['..i..']', {x = _G['defaultOpponentStrumX'..i], y = _G['defaultOpponentStrumY'..i], angle = 0}, 0.9 + (i * 0.1) / playbackRate, {ease = 'smootherStepOut'}) end
        end
    end,
    ['general'] = function(mode)
        if mode == 'return' then
            for i = 4, 7 do cancelTween(i..'BFAngle') cancelTween(i..'BFFall') end
            for i = 0, 3 do
                startTween(i..'NoteBFTween',    'playerStrums.members['..i..']', {x =   _G['defaultPlayerStrumX'..i], y =   _G['defaultPlayerStrumY'..i], angle = 360, alpha = 1}, 1 + (i * 0.2) / playbackRate, {ease = 'backOut'})
                startTween(i..'NoteDADTween', 'opponentStrums.members['..i..']', {x = _G['defaultOpponentStrumX'..i], y = _G['defaultOpponentStrumY'..i], angle = 360, alpha = 1}, 1 + (i * 0.2) / playbackRate, {ease = 'backOut'})
            end
        end
    end,
    ['generalSmoother'] = function (mode)
        if mode == 'return' then
            for i = 4, 7 do cancelTween(i..'BFAngle') cancelTween(i..'BFFall') end
            for i = 0, 3 do
                startTween(i..'NoteBFTween',    'playerStrums.members['..i..']', {x =   _G['defaultPlayerStrumX'..i], y =   _G['defaultPlayerStrumY'..i], angle = 360, alpha = 1}, 3 + (i * 0.2) / playbackRate, {ease = 'backInOut'})
                startTween(i..'NoteDADTween', 'opponentStrums.members['..i..']', {x = _G['defaultOpponentStrumX'..i], y = _G['defaultOpponentStrumY'..i], angle = 360, alpha = 1}, 3 + (i * 0.2) / playbackRate, {ease = 'backInOut'})
            end
        end
    end,
    ['wave'] =  function(wave)   waveNotes  = wave  == 'true' and true or false end,
    ['shake'] = function (shake) shakeNotes = shake == 'true' and true or false end,
    ['fadeBFStrums'] = function(alpha, time)
        if time then
            for i = 0, 3 do cancelTween(i..'FADEBF') doTweenAlpha(i..'FADEBF', 'playerStrums.members['..i..']', alpha, time / playbackRate) end
        else
            for i = 0, 3 do cancelTween(i..'FADEBF') setProperty('playerStrums.members['..i..'].alpha', alpha) end
        end
    end,
    ['fadeDADStrums'] = function(alpha, time)
        if time then
            for i = 0, 3 do doTweenAlpha(i..'FADEDAD', 'opponentStrums.members['..i..']', alpha, time / playbackRate) end
        else
            for i = 0, 3 do cancelTween(i..'FADEDAD') setProperty('opponentStrums.members['..i..'].alpha', alpha) end
        end
    end,
    ['fadeStrum'] = function(strum, alpha) cancelTween(tonumber(strum)..'FADEBF') cancelTween(tonumber(strum)..'FADEDAD') setPropertyFromGroup('strumLineNotes', tonumber(strum), 'alpha', alpha) end
}
local fateStageEvents = {
    ['1'] = function ()
        removeLuaSprite('fateExes') cancelTween('BlackGraphicGameAlpha') setProperty('BlackGraphicGame.alpha', 0)
        scaleObject('boyfriend', 0.85, 0.85)

        for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do doTweenAlpha(stuff..'Alpha', stuff, 1, 3 / playbackRate) end
        for _, shit in ipairs(fateAssets['BG1']) do
            setProperty(shit.name..'.alpha', shit.name == 'redOverlay' and 0 or 1)
            if shit.name == 'nieblia' then setProperty(shit.name..'.alpha', 0.2) end
        end
        for i = 1, 5 do setProperty('illegal'..i..'.alpha', 0) end

        removeLuaSprite('bfFALL', true)
        removeLuaSprite('lordXBite', true)
        triggerEvent('Change Character', 'dad', 'lord x podrido')
        setProperty('gf.visible', true)
        setProperty('boyfriend.visible', true)
        setProperty('dad.alpha', 1)

        for _, chars in ipairs({'dad', 'boyfriend'}) do setProperty(chars..'.y', getProperty(chars..'.y') + 60) end

        triggerEvent('Set customCamera Position', 'bf', '2190, 1350')
        triggerEvent('Set customCamera Position', 'dad', '1470, 1350')
        --triggerEvent('Set customCamera Position', 'middle', '1830, 940')
        triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.3')
    end,
    ['2'] = function ()
        for _, bg1 in ipairs(fateAssets['BG1']) do removeLuaSprite(bg1.name, true) end

        for _, chars in ipairs({'dad', 'boyfriend'}) do setProperty(chars..'.y', getProperty(chars..'.y') - 60) end

        removeSpriteShader('boyfriend')
        triggerEvent('Change Character', 'bf', 'bfo')
        setProperty('gf.visible', false)
        setProperty('dad.visible', false)
        scaleObject('boyfriend', 1.1, 1.1)
    end,
    ['3'] = function ()
        for _, trans in ipairs({'transition', 'transition2'}) do if luaSpriteExists(trans) then removeLuaSprite(trans, true) end end
        for _, hola in ipairs(fateAssets['BG2']) do setProperty(hola.name..'.alpha', 1) end

        triggerEvent('Change Character', 'dad', 'lord x p3largo')
        triggerEvent('Change Character', 'bf', 'bf-perspective-right')

        setProperty('dad.alpha', 1)

        callMethod('boyfriend.setPosition', {getProperty('boyfriend.x') - 500, getProperty('boyfriend.y') - 620 })
        callMethod('dad.setPosition', {getProperty('dad.x') - 500, getProperty('dad.y') - 840})

        triggerEvent('Set customCamera Position', 'bf', '1620, 850')
        triggerEvent('Set customCamera Position', 'dad', '870, 450')
        triggerEvent('Set customCamera Position', 'middle', '1280, 740')
        triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.55')

        zoomingStage = true
    end,
    ['fadeStage'] = function(sprite) doTweenAlpha(sprite..'Alpha', sprite, 0, 2) end
}
local fateSongEvents  = {
    ['tweenGraphAlpha'] = function (alpha, time) doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', alpha, time) end,
    ['lets-begin'] = function(type)
        if type == 'pixel' then
            for _, pixel  in ipairs({'lets-pixel', 'begin-pixel'})   do  setProperty(pixel..'.alpha', 1) end
            for _, normal in ipairs({'lets-normal', 'begin-normal'}) do setProperty(normal..'.alpha', 0) end
        end
        if type == 'normal' then
            for _, normal in ipairs({'lets-normal', 'begin-normal'}) do setProperty(normal..'.alpha', 1) end
            for _, pixel  in ipairs({'lets-pixel', 'begin-pixel'})   do  setProperty(pixel..'.alpha', 0) end
        end
        if type == 'none' then for _, letsend in ipairs({'lets-normal', 'begin-normal', 'lets-pixel', 'begin-pixel'}) do removeLuaSprite(letsend, true) end end
    end,
    ['hideDADPart1'] = function ()
        setProperty('fateExes.alpha', 1)
        playAnim('fateExes', 'exes!', true)
        doTweenAlpha('dadAlpha', 'dad', 0, 1)

        for i = 0, 3 do noteTweenAlpha(i..'Tween', i, 0, 0.6 + (i * 0.2) / playbackRate) noteTweenX(i..'Tween', i, -500, 0.6 + (i * 0.2) / playbackRate, 'backInOut') doTweenX(i..'BFX', 'playerStrums.members['..i..']', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i, 2 + (i * 0.3) / playbackRate, 'backInOut') end
    end,
    ['showFallingBF'] = function ()
        doTweenY('bfFALLTweenY', 'bfFALL', 600, 0.9, 'circOut')
        doTweenScale('bfFALL', 'bfFALL', 1, 1.2, 'smootherStepOut')
    end,
    ['eatingBF'] = function ()
        doTweenScale('lordXBite', 'lordXBite', 1, 1, 'smootherStepOut')
        doTweenScale('bfFALL', 'bfFALL', 0, 1.3, 'smootherStepOut')
        startTween('bfFALLTween', 'bfFALL', {x = 550, y = 570}, 1.3, {ease = 'smootherStepOut'})
    end,
    ['bite'] = function ()
        addAnimationByPrefix('lordXBite', 'bite', 'humgry', 24, false)
        playAnim('lordXBite', 'bite', true)
    end,
    ['illegalinstruction'] = function () for i = 1, 5 do setProperty('illegal'..i..'.alpha', 1) end end,
    ['transition'] = function ()
        setProperty('transition.alpha', 1) setProperty('transition2.alpha', 1)
        setProperty('transition.velocity.y', 1100) setProperty('transition2.velocity.y', 1100)
        runTimer('removeTransition', 5)
    end,
    ['redOverlayTime'] = function () cancelTween('redOverlayAlpha') startTween('redOverlayAlpha', 'redOverlay', {alpha = 1}, 1.4, {ease = 'smootherStepOut', type = 'PINGPONG'}) end,
    ['redOverlayEnd']  = function ()
        cancelTween('redOverlayAlpha')
        startTween('redOverlayAlphaEnd', 'redOverlay', {alpha = 0}, 1.4, {ease = 'smootherStepOut', onComplete = 'fucku'})
    end,
    ['cloneBF'] = function () pumpCloneBF() end,
    ['setCountDown'] = function(count)
        addCountDown(count)
    end,
    ['in his world'] = function()
        triggerEvent('Change Character', 'dad', 'lord x p3corto')

        callMethod('dad.setPosition', {getProperty('dad.x') - 500, getProperty('dad.y') - 840})

        doTweenAlpha('fogAlpha', 'fog', 1, 2)
        setSpriteShader('fog', 'wavyDistortion')
        setShaderFloat('fog', 'amount', 0.5)
    end
}
local fateHUDEvents   = {
    ['hideHUD']    = function(hide) doTweenAlpha('camHUDAlpha', 'camHUD', hide == 'true' and 0 or 1, 1) end,
    ['hideHealth'] = function(hide) for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do doTweenAlpha(stuff..'Alpha', stuff, hide == 'true' and 0 or 1, 1.5 / playbackRate) end end,
    ['setHealthAlpha'] = function(alpha) for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(stuff..'.alpha', alpha) end end
}

local holdMove = 0
local loseHealthBitch = false
local function onUpdateFate(elapsed)
    holdMove = holdMove + elapsed / (crochet / 450)
    if luaSpriteExists('cuadros') and getProperty('cuadros.alpha') >= 0.1   then
        callMethod('cuadros.setPosition', { getProperty('cuadros.x') + math.cos(holdMove +  0.5) * 0.2, getProperty('cuadros.y') + math.sin(holdMove + 0.2) * 0.5})
        setProperty('cuadros.angle', getProperty('cuadros.angle') + math.cos(holdMove + 0.05) * 0.05)
    end

    if luaSpriteExists('fakerEyes') and getProperty('fakerEyes.alpha') >= 0.1 then callMethod('fakerEyes.setPosition', { fakerEyesPos[1] + math.random(-shakeIntensity, shakeIntensity), fakerEyesPos[2] + math.random(-shakeIntensity, shakeIntensity)}) end

    if luaSpriteExists('bfFALL') then
        callMethod('bfFALL.setPosition', {getProperty('bfFALL.x') + math.cos(holdMove + 0.2) * 0.9, getProperty('bfFALL.y') + math.sin(holdMove + 0.4) * 0.6})
        setProperty('bfFALL.angle', getProperty('bfFALL.angle') + math.cos(holdMove + 0.05) * 0.05)
    end

    if luaSpriteExists('fateExes') and getProperty('fateExes.alpha') == 1 and getProperty('fateExes.animation.curAnim.name') == 'exes!' and getProperty('fateExes.animation.curAnim.finished') then removeLuaSprite('fateExes', true) end

    if getProperty('fog.alpha') >= 0.001 then setShaderFloat('fog', 'iTime', holdMove) end

    if loseHealthBitch then setProperty('health', getProperty('healthShit.x')) end

    if trailExists then
        runHaxeCode([[
            trail.playAnim(boyfriend.animation.curAnim.name);
            trail.animation.curAnim.curFrame = boyfriend.animation.curAnim.curFrame;
        ]])
    end

    if waveNotes then
        for i = 0, 7 do
            callMethod('strumLineNotes.members['..i..'].setPosition', {
                getProperty('strumLineNotes.members['..i..'].x') + math.cos(holdMove + (i * 0.4) + 0.5) * 0.1,
                getProperty('strumLineNotes.members['..i..'].y') + math.cos(holdMove + (i * 0.3) + 0.5) * 0.1
            })
        end
    end
    if shakeNotes then
        for i = 0, 7 do
            callMethod('strumLineNotes.members['..i..'].setPosition', {
                _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)] + math.random(shakeIntensity, -shakeIntensity),
                _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)] + math.random(shakeIntensity, -shakeIntensity)
            })
        end
    end
end

local DODGE_CONFIG = {
    START = false,
    BEATS = 0,
    CANDODGE = false,
    HASDODGED = false,
}

local function popUpSpace()
    cancelTween('dodgeTextAngle') cancelTween('spaceBarScale')
    scaleObject('spaceBar', 0.8, 0.8) scaleObject('dodgeText', 1.1, 1.1)
    setProperty('dodgeText.angle', getRandomFloat(-5, 5)) setProperty('spaceBar.alpha', 1)
    doTweenScale('spaceBar', 'spaceBar', 1, 0.5, 'circOut') doTweenScale('dodgeText', 'dodgeText', 1, 0.5, 'circOut') doTweenAngle('dodgeTextAngle', 'dodgeText', 0, 0.5, 'circOut')
end

local function dodgeMechanic()
    DODGE_CONFIG.BEATS = DODGE_CONFIG.BEATS - 1

    if not DODGE_CONFIG.HASDODGED then popUpSpace() end

    playSound('Metronome_Tick', 0.5)

    if luaTextExists('dodgeText') then setTextString('dodgeText', DODGE_CONFIG.BEATS) end

    runTimer('activateCanDodge', 0.001)

    if DODGE_CONFIG.BEATS == 0 then
        playSound('fatewhip')
        runTimer('dodgeTextDissapear', 1)
        playAnim('dad', 'hey', true) setProperty('dad.specialAnim', true)

        setProperty('dodgeText.color', getColorFromHex('FF0000')) doTweenColor('dodgeTextColor', 'dodgeText', 'FFFFFF', 0.5, 'circOut')
        setTextString('dodgeText', 'NOW')
        if DODGE_CONFIG.HASDODGED then
            playAnim('boyfriend', 'dodge', true) setProperty('boyfriend.specialAnim', true)
        else
            loseHealthBitch = true
            setProperty('healthShit.x', getProperty('health')) doTweenX('healthLose', 'healthShit', getProperty('healthShit.x') - 2, 0.6, 'circOut')
            runTimer('stopLosingShit', 0.6)
        end
        DODGE_CONFIG.CANDODGE = false DODGE_CONFIG.START = false
        setProperty('spaceBar.alpha', 0)
    end
end

function onCreate() prepareCharacters() end

function onCreatePost()
    setFateConfig()

    for _,    fate1 in ipairs(fateAssets['BG1'])         do     createSprite(fate1) end
    for _,    fate2 in ipairs(fateAssets['BG2'])         do     createSprite(fate2) end
    for _, fateMisc in ipairs(fateAssets['Misc'])        do  createSprite(fateMisc) end
    for _, fateBegin in ipairs(fateAssets['Lets-Begin']) do createSprite(fateBegin) end

    createAtlasSprite('fateExes')
    createIllegalInstruction()

    fakerEyesPos = {getProperty('fakerEyes.x'), getProperty('fakerEyes.y')}
end

function onUpdatePost(elapsed) onUpdateFate(elapsed) end

function onEvent(eventName, value1, value2)
    if eventName == 'fateEvents' then
        local  split = stringSplit(value2, ', ')
        if     value1 == 'strums'     then fateStrumEvents[split[1]](split[2], split[3])
        elseif value1 == 'stageMode'  then fateStageEvents[split[1]](split[2])
        elseif value1 == 'songEvents' then fateSongEvents[split[1]](split[2], split[3])
        elseif value1 == 'HUD'        then fateHUDEvents[split[1]](split[2])
        end
    end
    if eventName == 'fateDodge' then
        DODGE_CONFIG.START = true
        DODGE_CONFIG.BEATS = value1

        if not luaTextExists('dodgeText') then
            makeLuaText('dodgeText', DODGE_CONFIG.BEATS, 0, 550, 250)
            setObjectCamera('dodgeText', 'camHUD')
            setTextSize('dodgeText', 40)
            setTextFont('dodgeText', 'sonic-roco.ttf')
            addLuaSprite('dodgeText')
        end
    end
end

function onBeatHit()
    if DODGE_CONFIG.START then dodgeMechanic() end
end

function goodNoteHitPre(id)
	if getProperty('boyfriend.animation.curAnim.name') == 'dodge' then setPropertyFromGroup('notes', id, 'noAnimation', true) end
end

function opponentNoteHitPre(id)
	if getProperty('dad.animation.curAnim.name')       ==   'hey' then setPropertyFromGroup('notes', id, 'noAnimation', true) end
end

function onTweenCompleted(tag)
    if tag == 'healthLose' then loseHealthBitch = false end
    if tag == 'fucku'      then removeLuaSprite('redOverlay', true) end
    if stringStartsWith('CountDown') then removeLuaSprite(tag, true) end
end

function onTimerCompleted(t)
    if t == 'activateCanDodge'   then DODGE_CONFIG.CANDODGE = true end
    if t == 'dodgeTextDissapear' then removeLuaText('dodgeText', true) DODGE_CONFIG.HASDODGED = false end
    if t == 'itdoesntexist'      then trailExists = false end
    if t == 'removeTransition'   then for _, trans in ipairs({'transition', 'transition2'}) do removeLuaSprite(trans, true) end end
end

function onUpdate()
    if DODGE_CONFIG.CANDODGE then
        if keyboardJustPressed('SPACE') or getProperty('cpuControlled') then
            DODGE_CONFIG.HASDODGED = true DODGE_CONFIG.CANDODGE  = false
            setProperty('spaceBar.alpha', 0)
        end
    end
end

function onSectionHit()
    if not getProperty('gameplayCam.settings.MiddleCamera') and zoomingStage then
		if curSection % 2 == 0 then setProperty('gameplayCam.settings.OverrideZoom', false) end
		setProperty('gameplayCam.settings.OGZoom', mustHitSection and 0.7 or 0.9)
	end
end

function doTweenScale(tag, obj, target, time, ease)
	doTweenX(tag..'scaleX', obj..'.scale', target, time, ease) doTweenY(tag..'scaleY', obj..'.scale', target, time, ease)
end