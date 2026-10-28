local hazeBGAssets = {
    ['phase1'] = {
        {name = 'redSun', path = 'grieving/haze/1st/sol rojo', x = 0, y = 0, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, animName = 'idle', animPrefix = 'sun', fps = 12, loop = true, alpha = 1, front = false},
    },
    ['phase2'] = {
        {name =     'bg', path =       'grieving/uh-oh/new/sky', x = -1150, y = -1600,                                                                            scrollX = 0.3, scrollY = 0.3, front = false, lowQualityHide = true},
        {name =    'ola', path = 'grieving/uh-oh/new/sebasolas', x =   190, y =  -140, animName = 'idle', animPrefix = 'olas instancia 1', fps = 24, loop = true, scrollX = 0.3, scrollY = 0.3, front = false, lowQualityHide = true},
        {name = 'trees3', path =    'grieving/uh-oh/new/trees3', x = -1500, y =  -600,                                                                            scrollX = 0.5, scrollY = 0.5, front = false, lowQualityHide = true},
        {name = 'trees2', path =    'grieving/uh-oh/new/trees2', x = -1350, y = -1400,                                                                            scrollX = 0.7, scrollY = 0.7, front = false, lowQualityHide = true},
        {name =  'trees', path =     'grieving/uh-oh/new/trees', x = -1400, y = -1400,                                                                            scrollX = 0.9, scrollY = 0.9, front = false, lowQualityHide = true},
        {name =  'floor', path =     'grieving/uh-oh/new/floor', x = -1300, y =   -50,                                                                            scrollX =   1, scrollY =   1, front = false},
        {name =   'fore', path =      'grieving/uh-oh/new/fore', x = -1500, y = -1800,                                                                            scrollX = 1.1, scrollY = 1.1, front = false, lowQualityHide = true}
    },
    ['phase3'] = {
        {name =      'sky3', path =       'grieving/uh-oh/new/sky', x = -1680, y = -2080, scaleX = 1.1, scaleY = 1.1, scrollX =  0.8, scrollY =  0.8, front = false},
        {name =  'montains', path =  'grieving/haze/2nd/mountains', x = -1600, y = -1780, scaleX = 0.7, scaleY = 0.7, scrollX = 0.85, scrollY = 0.85, front = false},
        {name =       'lol', path =        'grieving/haze/2nd/idk', x = -1600, y =  -180, scaleX = 0.7, scaleY = 0.7, scrollX =  0.9, scrollY =  0.9, front = false},
        {name =     'suelo', path =    'grieving/haze/2nd/ground3', x = -1600, y =   180, scaleX = 0.7, scaleY = 0.7, scrollX =    1, scrollY =    1, front = false},
        {name =     'totem', path =     'grieving/haze/2nd/totems', x = -1300, y = -1650, scaleX = 0.7, scaleY = 0.7, scrollX =    1, scrollY =    1, front = false},
        --{name =     'water', path = 'grieving/haze/2nd/reflection', x = -1600, y = -1880, scaleX = 0.7, scaleY = 0.7, scrollX =    1, scrollY =    1, front = false},
    },
    ['phase4'] = {
        { name = 'sun-clouds', path = 'grieving/haze/3rd/sun-clouds',  x = -1500,  y = -1600,  scaleX = 1, scaleY = 1, scrollX =  0.7, scrollY =  0.7,                                                                 alpha = 1, front = false},
        { name = 'cloudFront', path = 'grieving/haze/3rd/cloudFront',  x = -1500,  y = -1600,  scaleX = 1, scaleY = 1, scrollX =  0.7, scrollY =  0.7,                                                                 alpha = 1, front = false},
        { name = 'water2',     path = 'grieving/haze/3rd/water',       x = -1600,  y =  -300,  scaleX = 1, scaleY = 1, scrollX = 0.85, scrollY = 0.85,                                                                 alpha = 1, front = false},
        { name = 'waterfall1', path = 'grieving/haze/3rd/waterfall1',  x = -1600,  y = -1000,  scaleX = 1, scaleY = 1, scrollX =  0.9, scrollY =  0.9, animName = 'idle', animPrefix = 'water', fps = 12, loop = true, alpha = 1, front = false},
        { name = 'waterfall2', path = 'grieving/haze/3rd/waterfall2',  x =   720,  y = -1300,  scaleX = 1, scaleY = 1, scrollX =  0.9, scrollY =  0.9, animName = 'idle', animPrefix = 'water', fps = 12, loop = true, alpha = 1, front = false},
        { name = 'groundShit', path = 'grieving/haze/3rd/ground',      x = -1600,  y = -1300,  scaleX = 1, scaleY = 1, scrollX =    1, scrollY =    1,                                                                 alpha = 1, front = false},
    },
    ['phase5'] = {
        { name = 'sky',              path = 'grieving/haze/4th/6', x = -1000, y = -1000,                  scrollX =    1, scrollY =    1,                 alpha = 1, front = false},
        { name = 'clouds1',          path = 'grieving/haze/4th/5', x =  -500, y = -1000, instance = true, scrollX =    1, scrollY =    1, velocityX = 20, alpha = 1, front = false},
        { name = 'clouds2',          path = 'grieving/haze/4th/4', x = -1000, y = -1000,                  scrollX =    1, scrollY =    1,                 alpha = 1, front = false},
        { name = 'clouds-mountains', path = 'grieving/haze/4th/3', x = -1000, y = -1000,                  scrollX =    1, scrollY =    1,                 alpha = 1, front = false},
        { name = 'clouds3',          path = 'grieving/haze/4th/2', x = -1000, y =   200,                  scrollX = 0.95, scrollY = 0.95,                 alpha = 1, front = true},
        { name = 'ground',           path = 'grieving/haze/4th/1', x = -1000, y =     0,                  scrollX =    1, scrollY =    1,                 alpha = 1, front = true},
    },
    ['atlases'] = {
        { name =      'k', path = 'characters/k', x =  100, y = -700, scale = 0.2, animSymbol =     'knux',  alpha = 1, front = false},
        { name =      'm', path = 'characters/m', x =  600, y = -400, scale =   1, animSymbol =     'momi',  alpha = 1, front = false},
        { name =      't', path = 'characters/t', x =  300, y = -100, scale = 0.2, animSymbol =     'tails', alpha = 1, front = false},
    },
    ['theBoys'] = {
        { name =   'kyle', path = 'characters/locos de haze', x =  400, y = -300, scaleX = 0.8, scaleY = 0.8, animName = 'idle', animPrefix = '1', fps = 12, loop = true, alpha = 0, front = false, flipX = true},
        { name = 'thomas', path =             'characters/2', x = -200, y = -600, scaleX = 0.8, scaleY = 0.8, animName = 'idle', animPrefix = '3', fps = 12, loop = true, alpha = 0, front = false, flipX = true},
    }
}

local spriteGroups = {
    phase1 = {'redSun'},
    phase2 = {'bg', 'ola', 'trees3', 'trees2', 'trees', 'floor', 'fore'},
    phase3 = {'sky3', 'montains', 'lol', 'suelo', 'totem', 'm', 't'},
    phase4 = {'overlay', 'sun-clouds', 'cloudFront', 'water2', 'waterfall1', 'waterfall2', 'groundShit', 'dedplants', 'k'},
    phase5 = {'sky', 'clouds1', 'clouds2', 'clouds-mountains', 'clouds3', 'ground', 'thomas', 'kyle'}
}

local function addSprite(yea)
    if yea.instance then
        createInstance(yea.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
        loadGraphic(yea.name, yea.path)
        callMethod(yea.name..'.setPosition', {yea.x, yea.y})
        setProperty(yea.name..'.velocity.x', yea.velocityX)
    else
        if yea.animName ~= nil then
            makeAnimatedLuaSprite(yea.name, yea.path, yea.x, yea.y)
            addAnimationByPrefix(yea.name, yea.animName, yea.animPrefix, yea.fps, yea.loop)
        else
            makeLuaSprite(yea.name, yea.path, yea.x, yea.y)
        end
    end
    if yea.flipX then setProperty(yea.name..'.flipX', yea.flipX) end
    if yea.scaleX or yea.scaleY then scaleObject(yea.name, yea.scaleX, yea.scaleY) end
    setScrollFactor(yea.name, yea.scrollX or 1, yea.scrollY or 1)
    if yea.alpha then setProperty(yea.name..'.alpha', yea.alpha) end
    if yea.antialiasing then setProperty(yea.name..'.antialiasing', yea.antialiasing) end
    addLuaSprite(yea.name, yea.front)
end

local function addAtlas(e)
    makeFlxAnimateSprite(e.name, e.x, e.y, e.path)
    addAnimationBySymbol(e.name, 'idle', e.animSymbol, 24, true)
    scaleObject(e.name, e.scale, e.scale)
    setProperty(e.name..'.alpha', e.alpha)
    addLuaSprite(e.name, e.front)
end

function onCreate()
    --Let's try separately
    if not lowQuality then
        addCharacterToList('griatos', 'dad') addCharacterToList('griatos 2', 'dad')
        addCharacterToList('bf-red', 'bf')   addCharacterToList('bf', 'bf-uhoh') addCharacterToList('bf2', 'bf')

        for _, phase1 in ipairs(hazeBGAssets['phase1'])  do precacheImage(phase1.path) end
        for _, phase2 in ipairs(hazeBGAssets['phase2'])  do precacheImage(phase2.path) end
        for _, phase3 in ipairs(hazeBGAssets['phase3'])  do precacheImage(phase3.path) end
        for _, phase4 in ipairs(hazeBGAssets['phase4'])  do precacheImage(phase4.path) end
        for _, phase5 in ipairs(hazeBGAssets['phase5'])  do precacheImage(phase5.path) end

        for _, atlas in ipairs(hazeBGAssets['atlases']) do precacheImage(atlas.path) end

        for _, theBoys in ipairs(hazeBGAssets['theBoys']) do precacheImage(theBoys.path) end
    end
end

local separation = 50
function onCreatePost()
    for _, spr in ipairs(hazeBGAssets['phase1']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase2']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase3']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase4']) do addSprite(spr) end
    for _, spr in ipairs(hazeBGAssets['phase5']) do addSprite(spr) end

    for _, spr in ipairs(hazeBGAssets['atlases']) do addAtlas(spr) end

    for _, theBoys in ipairs(hazeBGAssets['theBoys']) do addSprite(theBoys) end

    for _, phase1 in ipairs(hazeBGAssets['phase1']) do setProperty(phase1.name..'.visible', true) end
    for _, phase2 in ipairs(hazeBGAssets['phase2']) do setProperty(phase2.name..'.visible', false) end
    for _, phase3 in ipairs(hazeBGAssets['phase3']) do setProperty(phase3.name..'.visible', false) end
    for _, phase4 in ipairs(hazeBGAssets['phase4']) do setProperty(phase4.name..'.visible', false) end
    for _, phase5 in ipairs(hazeBGAssets['phase5']) do setProperty(phase5.name..'.visible', false) end

    for _, atlas in ipairs(hazeBGAssets['atlases']) do setProperty(atlas.name..'.visible', false) end

    for _, theBoys in ipairs(hazeBGAssets['theBoys']) do setProperty(theBoys.name..'.visible', false) end
    --THAT bf anim
    makeAnimatedLuaSprite('bfTransition', 'characters/atlas', 210, -10)
    addAnimationByIndices('bfTransition', 'idle', 'atlas instancia 1', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, 24, true)
    addAnimationByPrefix('bfTransition', 'anim', 'atlas', 24, false)
    addAnimationByIndices('bfTransition', 'still', 'atlas', {108}, 24, true)
    setObjectCamera('bfTransition', 'camHUD')
    scaleObject('bfTransition', 1, 1)
    setProperty('bfTransition.alpha', 0)
    setBlendMode('bfTransition', 'add')
    addLuaSprite('bfTransition')

    --The Missing Poster
    makeLuaSprite('missingPoster', 'grieving/haze/missing_wip', -800, -1050)
    setProperty('missingPoster.alpha', 0)
    setObjectOrder('missingPoster', getObjectOrder('BlackGraphicGame') + 1)
    addLuaSprite('missingPoster')

    --Other Stuff
    setProperty('dad.visible', false)
    setObjectOrder('clouds3', getObjectOrder('dadGroup') + 1)
    setObjectOrder('ground', getObjectOrder('boyfriendGroup'))
    for i = 0,3 do setProperty('opponentStrums.members['..i..'].alpha', 0) setProperty('opponentStrums.members['..i..'].x', getProperty('opponentStrums.members['..i..'].x') - 1000) setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i) end
    for i = 0, getProperty('notes.length') - 1 do setPropertyFromGroup('notes', i, 'texture', "noteSkins/redNotes") end
    for i = 0, getProperty('unspawnNotes.length') - 1 do setPropertyFromGroup('unspawnNotes', i, 'texture', "noteSkins/redNotes") end
    for i = 0, 7 do setProperty('strumLineNotes.members['..i..'].texture', 'noteSkins/redNotes') end
    for _, hudStuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hudStuff..'.alpha', 0) end

    setSpriteShader('thomas', 'wavyDistortion')
    setSpriteShader('kyle', 'wavyDistortion')

    for _, bois in ipairs({'thomas', 'kyle'}) do setShaderFloat(bois, 'amount', 0.8) end
end

local canShakeGriatos = false
local stageMode = {
    ['1'] = function () --Phase 1 (This one just in case).

        for _, phase1 in ipairs(spriteGroups.phase1) do setProperty(phase1..'.visible', true) end
        for _, phase2 in ipairs(spriteGroups.phase2) do setProperty(phase2..'.visible', false) end
        for _, phase3 in ipairs(spriteGroups.phase3) do setProperty(phase3..'.visible', false) end
        for _, phase4 in ipairs(spriteGroups.phase4) do setProperty(phase4..'.visible', false) end
        for _, phase5 in ipairs(spriteGroups.phase5) do setProperty(phase5..'.visible', false) end

        triggerEvent('Change Character', 'bf', 'bf-red')

        for _, hudStuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do setProperty(hudStuff..'.visible', false) end
    end,
    ['2'] = function () -- Phase 2
        for i = 0, getProperty('notes.length') - 1 do setPropertyFromGroup('notes', i, 'texture', "noteSkins/NOTE_assets") end
        for i = 0, getProperty('unspawnNotes.length') - 1 do setPropertyFromGroup('unspawnNotes', i, 'texture', "noteSkins/NOTE_assets") end
        for i = 0, 7 do setProperty('strumLineNotes.members['..i..'].texture', 'noteSkins/NOTE_assets') end
        cancelTween('BlackGraphicGameOP') setProperty('BlackGraphicGame.alpha', 0)
        for _, phase1 in ipairs(spriteGroups.phase1) do setProperty(phase1..'.visible', false) end
        for _, phase1 in ipairs(spriteGroups.phase1) do          removeLuaSprite(phase1, true) end
        for _, phase2 in ipairs(spriteGroups.phase2) do  setProperty(phase2..'.visible', true) end
        for _, phase3 in ipairs(spriteGroups.phase3) do setProperty(phase3..'.visible', false) end
        for _, phase4 in ipairs(spriteGroups.phase4) do setProperty(phase4..'.visible', false) end
        for _, phase5 in ipairs(spriteGroups.phase5) do setProperty(phase5..'.visible', false) end

        triggerEvent('Set customCamera Position', 'bf', '600, 130')
        triggerEvent('Change Character', 'bf', 'bf-uhoh')
        triggerEvent('Change Character', 'dad', 'griatos')
        callMethod('boyfriend.setPosition', {getProperty('boyfriend.x') - 20, getProperty('boyfriend.y') + 260})
        callMethod('dad.setPosition', {getProperty('dad.x') - 80, getProperty('dad.y') - 30})
        setProperty('dad.visible', true)
        if shadersEnabled then
            runHaxeCode([[
                import shaders.AdjustColorShader;
                var playerColor = new AdjustColorShader();
                playerColor.brightness = -27;
                playerColor.contrast = -19;
                playerColor.hue = -10;
                playerColor.saturation = -9;    
                game.boyfriend.shader = playerColor; 
            ]])
        end
    end,
    ['3'] = function () --Phase 3
        for _, phase2 in ipairs(spriteGroups.phase2) do setProperty(phase2..'.visible', false) end
        for _, phase2 in ipairs(spriteGroups.phase2) do          removeLuaSprite(phase2, true) end
        for _, phase3 in ipairs(spriteGroups.phase3) do  setProperty(phase3..'.visible', true) end
        for _, phase4 in ipairs(spriteGroups.phase4) do setProperty(phase4..'.visible', false) end
        for _, phase5 in ipairs(spriteGroups.phase5) do setProperty(phase5..'.visible', false) end

        setProperty('dad.y', getProperty('dad.y') - 70)

        triggerEvent('Set customCamera Position', 'middle', '100, -250')
        triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.4')
    end,
    ['4'] = function ()
        for _, phase3 in ipairs(spriteGroups.phase3) do setProperty(phase3..'.visible', false) end
        for _, phase3 in ipairs(spriteGroups.phase3) do          removeLuaSprite(phase3, true) end
        for _, phase4 in ipairs(spriteGroups.phase4) do  setProperty(phase4..'.visible', true) end
        for _, phase5 in ipairs(spriteGroups.phase5) do setProperty(phase5..'.visible', false) end

        triggerEvent('Set customCamera Position', 'middle', '420, -250')
        triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.35')

        setProperty('boyfriend.y', getProperty('boyfriend.y') - 40)
    end,
    ['5'] = function () -- Phase 4
        for _, phase4 in ipairs(spriteGroups.phase4) do setProperty(phase4..'.visible', false) end
        for _, phase4 in ipairs(spriteGroups.phase4) do          removeLuaSprite(phase4, true) end
        for _, phase5 in ipairs(spriteGroups.phase5) do  setProperty(phase5..'.visible', true) end

        triggerEvent('Change Character', 'dad', 'griatos 2')
        triggerEvent('Change Character',  'bf',       'bf2')

        canShakeGriatos = true

        callMethod('boyfriend.setPosition', {getProperty('boyfriend.x') - 120, getProperty('boyfriend.y') + 730})
        callMethod('dad.setPosition', {getProperty('dad.x') + 2020, getProperty('dad.y') - 30})

        --setProperty('thomas.alpha', 1) setProperty('kyle.alpha', 1)

        runTimer('thomasGhost', math.random(3, 10))
        runTimer('kyleGhost',   math.random(2, 10))

        triggerEvent('Set customCamera Position', 'bf',     '800, 550')
        triggerEvent('Set customCamera Position', 'dad',  '1100,   50')
        triggerEvent('Set customCamera Position', 'middle', '870, 120')
        triggerEvent('Set Character Offset',  'bf', '5')
        triggerEvent('Set Character Offset', 'dad', '5')
        triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.35')

        setProperty('iconOpp.flipX', true)
    end
}

local hudMode = {
    ['healthStuff'] = function(hide, time)
        for _, hudStuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do doTweenAlpha(hudStuff..'Alpha', hudStuff, hide == 'true' and 0 or 1, time and time or 1) end
    end,
    ['Notes'] = function(strum, hide, time)
        for i = 0, 3 do
            if strum == 'bf' then
                doTweenAlpha(i..'BFAlpha',    'playerStrums.members['..i..']', hide == 'true' and 0 or 1, time and time or 1)
            elseif strum == 'dad' then
                doTweenAlpha(i..'DADAlpha', 'opponentStrums.members['..i..']', hide == 'true' and 0 or 1, time and time or 1)
            end
        end
    end,
    ['zoomIn'] = function ()
        setProperty('camZoomingMult', 0)
        setProperty('camZoomingDecay', 0)
        doTweenZoom('hudZoom', 'camHUD', 1.4, 3, 'sineInOut')
        doTweenY('hudYTween',  'camHUD', downscroll and -140 or 140, 3, 'sineInOut')
        for i = 0, 3 do doTweenY(i..'YTween', 'playerStrums.members['..i..']', downscroll and getProperty('playerStrums.members['..i..'].y') - 60 or getProperty('playerStrums.members['..i..'].y') + 60, 3, 'sineInOut') end
    end,
    ['changeNotesColor'] = function ()
        for i = 0, 3 do
            setProperty('playerStrums.members['..i..'].color', getColorFromHex('FF0000'))
            doTweenAngle(i..'Angle', 'playerStrums.members['..i..']', 360, 0.6, 'backOut')
        end
        for i = 0,getProperty('unspawnNotes.length')-1 do setPropertyFromGroup('unspawnNotes', i, 'color', getColorFromHex('FF0000')) end
        for i = 0,getProperty('notes.length')-1 do setPropertyFromGroup('notes', i, 'color', getColorFromHex('FF0000')) end
    end,
    ['returnNotesColor'] = function ()
        for i = 0, 3 do setProperty('playerStrums.members['..i..'].color', getColorFromHex('FFFFFF')) end
    end,
    ['returnUnspawnNotesColor'] = function ()
        for i = 0,getProperty('unspawnNotes.length')-1 do setPropertyFromGroup('unspawnNotes', i, 'color', getColorFromHex('FFFFFF')) end
        for i = 0,getProperty('notes.length')-1 do setPropertyFromGroup('notes', i, 'color', getColorFromHex('FFFFFF')) end
    end,
    ['zoomBack'] = function ()
        cancelTween('hudZoom')
        cancelTween('hudYTween')
        for i = 0, 3 do doTweenY(i..'YTween', 'playerStrums.members['..i..']', downscroll and getProperty('playerStrums.members['..i..'].y') + 60 or getProperty('playerStrums.members['..i..'].y') - 60, 0.6, 'circInOut') end
        doTweenZoom('hudZoomBack', 'camHUD', 1, 0.6, 'circInOut')
        doTweenY('hudYTween',  'camHUD', 0, 0.6, 'circInOut')
    end
}


local notesDance = false
local healthDance = false
local canAngleDance = false

local modchart = {
    ['middle'] = function()
        for i = 0,3 do
            setProperty('opponentStrums.members['..i..'].alpha', 0) setProperty('opponentStrums.members['..i..'].x', getProperty('opponentStrums.members['..i..'].x') - 1000)
            setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
        end
    end,
    ['returnMiddle'] = function ()
        for i = 0,3 do
            setProperty('opponentStrums.members['..i..'].x', getProperty('opponentStrums.members['..i..'].x') + 1000)
            doTweenAlpha(i..'DADAlpha', 'opponentStrums.members['..i..']', 1, 1)
            setProperty('playerStrums.members['..i..'].x', _G['defaultPlayerStrumX'..i])
        end
    end,
    ['dance'] = function(dance)
        notesDance = dance == 'true' and true or false
        healthDance = dance == 'true' and true or false
        canAngleDance = dance == 'true' and true or false
    end,
    ['spinNotes'] = function ()
        for i = 0, 7 do
            canAngleDance = false
            doTweenAngle(i..'Angle', 'strumLineNotes.members['..i..']', 360, 0.6, 'backOut')
        end
    end,
    ['reverseNotesPosition'] = function ()
        if middlescroll then return end
        for i = 0, 3 do
            noteTweenX(i..'X' , i , (screenWidth / 1.3)--[[Offset]]+(115 * (i - 2))--[[NotesSeparation]], 2, 'circOut')
            noteTweenAlpha(i..'AlphaBack', i, 1, 1)
        end
        for i = 4, 7 do
            noteTweenX(i..'X' , i , (screenWidth / 4)--[[Offset]]+(115 * (i - 6))--[[NotesSeparation]], 2, 'circOut')
        end
    end
}

luaDebugMode = true
function onEvent(e, v1, v2)
    if e == 'hazeEvents' then
        if v1 == 'stageMode' then
            stageMode[v2]()
        end
        if v1 == 'hudMode' then
            local split = stringSplit(v2, ', ')
            hudMode[split[1]](split[2], split[3], split[4])
        end
        if v1 == 'modchart' then
            local split = stringSplit(v2, ', ')
            modchart[split[1]](split[2])
        end
        if v1 == 'tweenObject' then
            local split = stringSplit(v2, ',')
            doTweenAlpha(split[1]..'OP', split[1], split[2], split[3])
        end
        if v1 == 'bfAnims' then
            playAnim('bfTransition', v2, true)
        end
    end
end

local someHold = 0
local holdWave = 0

function onUpdatePost(e)
    someHold = math.min(someHold + e, 1)
    holdWave = holdWave + e
    for i = 0, 7 do
        if notesDance then
            if canAngleDance then setProperty('strumLineNotes.members['..i..'].angle', math.sin((curDecBeat + 1) * math.pi + 0.5) * someHold * 5) end
            callMethod('strumLineNotes.members['..i..'].setPosition',{
                getProperty('strumLineNotes.members['..i..'].x') + math.cos((curDecBeat + 1) * math.pi) * someHold * 3,
                downscroll and getProperty('strumLineNotes.members['..i..'].y') + math.cos(curDecBeat * math.pi * 2) * someHold or getProperty('strumLineNotes.members['..i..'].y') - math.cos(curDecBeat * math.pi * 2) * someHold
            })
        end
    end

    if healthDance then
        for _, move in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'healthBG', 'exeScoreTxt', 'separatorHealth'}) do
            callMethod(move..'.setPosition',{
                getProperty(move..'.x') - math.cos((curDecBeat + 1) * math.pi) * someHold * 3,
                downcsroll and getProperty(move..'.y') + math.cos(curDecBeat * math.pi * 2) * someHold or getProperty(move..'.y') - math.cos(curDecBeat * math.pi * 2) * someHold
            })
        end
    end

    for i, bois in ipairs({'thomas', 'kyle'}) do
        if luaSpriteExists(bois) then
            setShaderFloat(bois, 'iTime', holdWave)
            callMethod(bois..'.setPosition', {
                getProperty(bois..'.x') + math.cos(holdWave + (i * math.random(-0.2, 0.2))) * 0.1,
                getProperty(bois..'.y') + math.sin(holdWave + (i * math.random(-0.4, 0.7))) * 0.4
            })
        end
    end
end

function onTweenCompleted(tag)
    if tag == 'hudZoomBack' then
        setProperty('camZoomingMult',  1) setProperty('camZoomingDecay', 1)
    end
    if tag == '0Angle' then canAngleDance = true end
    if tag == 'KyleGhost1'   then doTweenAlpha('KyleGhost2',     'kyle', 0, 0.4) runTimer('kyleGhost',   math.random(2, 10)) end
    if tag == 'ThomasGhost1' then doTweenAlpha('ThomasGhost2', 'thomas', 0, 0.4) runTimer('thomasGhost', math.random(3, 10)) end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'thomasGhost' then
        doTweenAlpha('ThomasGhost1', 'thomas', math.random(0.1, 0.35), 0.7)
    elseif tag == 'kyleGhost' then
        doTweenAlpha('KyleGhost1', 'kyle', math.random(0.1, 0.3), 0.7)
    end
end

function opponentNoteHit()
    if canShakeGriatos then cameraShake('camGame', 0.004, 0.2) cameraShake('camHUD', 0.004, 0.2) end
end