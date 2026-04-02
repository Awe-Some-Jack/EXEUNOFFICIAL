local fateBG1 = {
    {name = 'feiker', path = 'fate/fakrt', x = 500, y = 520, animated = false, scaleX = 0.7, scaleY = 0.7, scrollX = 1, scrollY = 1, alpha = 0, antialiasing = true, lq = false, front = false},
    {name = 'nieblia', path = 'fate/niebla', x = 217, y = 620, animated = true, animName = 'idle', animPrefix = 'Símbolo 29', fps = 24, loop = true, scaleX = 2.7, scaleY = 2.3, scrollX = 1, scrollY = 1, alpha = 0, antialiasing = true, lq = false, front = false},
    {name = 'cuadros', path = 'fate/c', x = 1100, y = 320, animated = false, scaleX = 0.8, scaleY = 0.8, scrollX = 1, scrollY = 1, alpha = 0, antialiasing = true, lq = false, front = false},
    {name = 'ground', path = 'fate/sd', x = 210, y = 250, animated = false, scaleX = 0.8, scaleY = 0.8, scrollX = 1, scrollY = 1, alpha = 0, antialiasing = true, lq = false, front = false},
}

local fateBG2 = {
    {name = 'niebliaFinal', path = 'fate/niebla 2', x = 0, y = 20, animated = true, animName = 'idle', animPrefix = 'Símbolo 34', fps = 24, loop = true, scaleX = 1.75, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 0, antialiasing = true, lq = false, front = false},
    {name = 'fateFinal', path = 'fate/FATE LORDX', x = 0, y = 20, animated = true, animName = 'idle', animPrefix = 'Símbolo 409', fps = 24, loop = true, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, alpha = 0, antialiasing = true, lq = false, front = false},
}

local glitches = {
    [1] = function()
        triggerEvent('chromFlash', '0, 5', '3, linear')
    end
}

function onCreatePost()
    setProperty('gf.visible', false)
    setScrollFactor('gfGroup', 1, 1)
    setProperty('boyfriend.visible', false)

    -- Character Lists
    addCharacterToList('lord x podrido', 'dad')
    addCharacterToList('lord x p3corto', 'dad')
    addCharacterToList('lord x p3largo', 'dad')
    --addCharacterToList('lord x p3scream', 'dad')
    addCharacterToList('bfo', 'bf')
    addCharacterToList('bf-perspective-right', 'bf')


    --Sprites
    makeAnimatedLuaSprite('spaceBar', 'fate/spacebar', 450, 400)
    addAnimationByPrefix('spaceBar', 'idle', 'Símbolo 8', 24, true)
    playAnim('spaceBar', 'idle', true)
    setObjectCamera('spaceBar', 'camHUD')
    setProperty('spaceBar.alpha', 0)
    scaleObject('spaceBar', 0.5, 0.5)
    addLuaSprite('spaceBar', false)


    makeAnimatedLuaSprite('lordXBite', 'characters/mordida', 1350, 1200)
    addAnimationByIndices('lordXBite', 'idle', 'Símbolo 403', '0', 24, true)
    playAnim('lordXBite', 'idle', true)
    scaleObject('lordXBite', 0, 0)
    addLuaSprite('lordXBite', false)

    makeAnimatedLuaSprite('bfFALL', 'characters/bf void', 600, 1900)
    addAnimationByPrefix('bfFALL', 'idle', 'Símbolo 71', 24, true)
    scaleObject('bfFALL', 3, 3)
    addLuaSprite('bfFALL', false)

    makeAnimatedLuaSprite('bfClone', 'characters/bfo', 0, 0)
    addAnimationByPrefix('bfClone', 'idle', 'idle', 24, true)
    addAnimationByPrefix('bfClone', 'singUP', 'up', 24, false)
    addAnimationByPrefix('bfClone', 'singDOWN', 'down', 24, false)
    addAnimationByPrefix('bfClone', 'singLEFT', 'left', 24, false)
    addAnimationByPrefix('bfClone', 'singRIGHT', 'right', 24, false)
    setProperty('bfClone.alpha', 0)
    addLuaSprite('bfClone', true)


    math.randomseed(os.clock())
    for i = 1, math.random(4, 5) do
        makeLuaSprite('illegal'..i, 'fate/illegalinstruction', math.random(50, 860), math.random(30, 750))
        setProperty('illegal'..i..'.alpha', 0)
        setObjectCamera('illegal'..i, 'camHUD')
        addLuaSprite('illegal'..i, false)
    end

    makeLuaSprite('transition', 'fate/overlay', -550, 0)
    setObjectCamera('transition', 'camHUD')
    setProperty('transition.color', '000000')
    addLuaSprite('transition')

    makeLuaSprite('fog', 'fate/fog', 0, 0)
    setObjectCamera('fog', 'camHUD')
    screenCenter('fog')
    setProperty('fog.alpha', 0)
    setBlendMode('fog', 'ADD')
    addLuaSprite('fog', true)

    makeLuaSprite('transition2', 'fate/overlay', -550, getProperty('transition.y') - 1000)
    setObjectCamera('transition2', 'camHUD')
    setProperty('transition2.color', '000000')
    setProperty('transition2.flipY', true)
    addLuaSprite('transition2')

    makeLuaSprite('healthShit')

    -- Notes Shit
    for i = 0,3 do
        if getProperty('opponentStrums.members['..i..'].alpha') >= 0.0001 then
            setProperty('opponentStrums.members['..i..'].alpha', 0)
        end
    end

    for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do
        setProperty(stuff..'.alpha', 0)
    end

    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'y', (downscroll and 770 or -250))
    end

    for _, puta in ipairs(fateBG1) do
        if not puta.lq then
            if puta.animated then
                makeAnimatedLuaSprite(puta.name, puta.path, puta.x, puta.y)
                addAnimationByPrefix(puta.name, puta.animName, puta.animPrefix, puta.fps, puta.loop)
            else
                makeLuaSprite(puta.name, puta.path, puta.x, puta.y)
            end
            scaleObject(puta.name, puta.scaleX, puta.scaleY)
            setScrollFactor(puta.name, puta.scrollX, puta.scrollY)
            setProperty(puta.name..'.alpha', puta.alpha)
            setProperty(puta.name..'.antialiasing', puta.antialiasing)
            addLuaSprite(puta.name, puta.front)
        end
    end
    for _, puta in ipairs(fateBG2) do
        if not puta.lq then
            if puta.animated then
                makeAnimatedLuaSprite(puta.name, puta.path, puta.x, puta.y)
                addAnimationByPrefix(puta.name, puta.animName, puta.animPrefix, puta.fps, puta.loop)
            else
                makeLuaSprite(puta.name, puta.path, puta.x, puta.y)
            end
            scaleObject(puta.name, puta.scaleX, puta.scaleY)
            setScrollFactor(puta.name, puta.scrollX, puta.scrollY)
            setProperty(puta.name..'.alpha', puta.alpha)
            setProperty(puta.name..'.antialiasing', puta.antialiasing)
            addLuaSprite(puta.name, puta.front)
        end
    end

    makeLuaSprite('redOverlay', 'fate/overlay', -1500, 500)
    scaleObject('redOverlay', 2, 2)
    setObjectOrder('redOverlay', getObjectOrder('nieblia'))
    setProperty('redOverlay.color', getColorFromHex('FF0000'))
    setProperty('redOverlay.flipY', true)
    setProperty('redOverlay.alpha', 0)
    addLuaSprite('redOverlay', false)
end

local holdMove = 0
local loseHealthBitch = false
function onUpdatePost(elapsed)
    holdMove = holdMove + elapsed / (crochet / 750)
    if luaSpriteExists('cuadros') and getProperty('cuadros.alpha') >= 0.1   then
        callMethod('cuadros.setPosition', {
            getProperty('cuadros.x') + math.cos(holdMove +  0.5) * 0.2,
            getProperty('cuadros.y') + math.sin(holdMove + 0.2) * 0.5
        })
        setProperty('cuadros.angle', getProperty('cuadros.angle') + math.cos(holdMove + 0.05) * 0.05)
    end

    if luaSpriteExists('bfFALL') then
        callMethod('bfFALL.setPosition', {
            getProperty('bfFALL.x') + math.cos(holdMove + 0.2) * 0.9,
            getProperty('bfFALL.y') + math.sin(holdMove + 0.4) * 0.6
        })
        setProperty('bfFALL.angle', getProperty('bfFALL.angle') + math.cos(holdMove + 0.05) * 0.05)
    end

    if getProperty('fog.alpha') >= 0.001 then
        setShaderFloat('fog', 'iTime', holdMove)
    end

    if loseHealthBitch then
        setProperty('health', getProperty('healthShit.x'))
    end
end

local startMechanic = false
local canDodge = false
local hasDodged = false
local beats = 0
function onEvent(eventName, value1, value2)
    if eventName == 'fateEvents' then
        if value1 == 'moveStrums' then
            if value2 == 'bf' then
                for i = 4, 7 do
                    noteTweenY(i..'BF', i, (downscroll and 570 or 50), 0.9 + (i * 0.1), 'smootherStepOut')
                end
            end
            if value2 == 'bfCenter' then
                for i = 4, 7 do
                    noteTweenX(i..'X' , i , (screenWidth/2)--[[Offset]]+(115*(i-6))--[[NotesSeparation]], 0.8 + (i * 0.3), 'backInOut')
                end
            elseif value2 == 'lord x' then
                for i = 0, 3 do
                    noteTweenY(i..'DAD', i, (downscroll and 570 or 50), 0.9 + (i * 0.1), 'smootherStepOut')
                    noteTweenAlpha(i..'Tween', i, 1, 0.4)


                    setProperty('transition.alpha', 0)
                    setProperty('transition.y', -2500)
                    setProperty('transition2.y', getProperty('transition.y') - 1000)
                    setProperty('transition.scale.y', 6)
                    setProperty('transition2.scale.y', 6.6)
                end
            elseif value2 == 'bffall' then
                for i = 4, 7 do
                    noteTweenY(i..'BF', i, 850, 1.3 + (i * math.random(0.1, 0.2)), 'backIn')
                    noteTweenAngle(i..'BFAngle', i, math.random(15, -15), 1.3 + (i * math.random(0.1, 0.2)))
                end
            elseif value2 == 'bfback' then
                for i = 0, 3 do
                    setPropertyFromGroup('playerStrums', i, 'y', (downscroll and 770 or -250))
                end
                for i = 4, 7 do
                    noteTweenY(i..'BF', i, (downscroll and 570 or 50), 1.2 + (i * 0.1), 'backOut')
                    noteTweenAngle(i..'BFAngle', i, 0, 1.3 + (i * math.random(0.1, 0.2)))
                end
            elseif value2 == 'restore' then
                for i = 4, 7 do
                    noteTweenX(i..'X' , i , (screenWidth / 1.35)--[[Offset]]+(115*(i-6))--[[NotesSeparation]], 1.2 + (i * 0.2), 'backInOut')
                    noteTweenAngle(i..'BFAngle', i, 360, 1.2 + (i * 0.2), 'backInOut')
                end
                for i = 0, 3 do
                    noteTweenAlpha(i..'Tween', i, 1, 1)
                end
            end
        end
        if value1 == 'fadeStrums' then
            local split = stringSplit(value2, ', ')
            if value2 == '' then 
                for i = 4, 7 do
                    noteTweenAlpha(i..'Tween', i, 0, 0.6 + (i * 0.2))
                end
            elseif value2 == 'dad' then 
                for i = 0, 3 do
                    noteTweenAlpha(i..'Tween', i, 0, 0.6 + (i * 0.2))
                end
            elseif value2 == 'back' then
                for i = 4, 7 do
                    noteTweenAlpha(i..'Tween', i, 1, 0.3)
                end
            elseif value2 == 'instFadeBF' then
                for i = 4, 7 do
                    noteTweenAlpha(i..'Tween', i, 0, 0.001)
                end
            elseif split[1] == 'setBFNoteAlphaBack' then
                setProperty('playerStrums.members['..split[2]..'].alpha', 1)
            end
        end
        if value1 == 'part1' then
            if value2 == 'moveBF' then
                doTweenY('bfFALLTweenY', 'bfFALL', 600, 0.9, 'circOut')
                doTweenScale('bfFALL', 'bfFALL', 1, 1.2, 'smootherStepOut')
            elseif value2 == 'eatBF' then
                doTweenScale('lordXBite', 'lordXBite', 1, 1, 'smootherStepOut')
                doTweenScale('bfFALL', 'bfFALL', 0, 1.3, 'smootherStepOut')
                doTweenX('bfFALLTweenX', 'bfFALL', getProperty('bfFALL.x') - 50, 1.3, 'smootherStepOut')
                doTweenY('bfFALLTweenY', 'bfFALL', getProperty('bfFALL.y') - 20, 1.3, 'smootherStepOut')
            elseif value2 == 'bite' then
                addAnimationByPrefix('lordXBite', 'bite', 'humgry', 24, false)
                playAnim('lordXBite', 'bite', true)
            elseif value2 == 'ilegal' then
                for i = 1, 5 do
                    setProperty('illegal'..i..'.alpha', 1)
                end
            else
                doTweenAlpha('dadAlpha', 'dad', 0, 1)

                for i = 0, 3 do
                    noteTweenAlpha(i..'Tween', i, 0, 0.6 + (i * 0.2))
                end

                for i = 4, 7 do
                    noteTweenX(i..'X' , i , (screenWidth/2)--[[Offset]]+(115*(i-6))--[[NotesSeparation]], 0.3 + (i * 0.3), 'backInOut')
                end
            end
        end
        if value1 == 'part2' then
            local split = stringSplit(value2, ', ')
            if split[1] == 'transition' then
                setProperty('transition.alpha', 1)
                doTweenY('transitionYTween', 'transition', 2800, 2.35)
                doTweenY('transition2YTween', 'transition2', 2000, 8.9)
            elseif split[1] == 'sad' then
                for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do
                    doTweenAlpha(stuff..'Alpha', stuff, 0, 2)
                end
            elseif split[1] == 'fade' then
                doTweenAlpha(split[2]..'Fade', split[2], 0, 4)
            elseif split[1] == 'getRed' then
                if split[2] == '' then
                    startTween('redOverlayAlpha', 'redOverlay', {alpha = 1}, 1.4, {ease = 'smootherStepOut', type = 'PINGPONG'})
                elseif split[2] == 'end' then
                    cancelTween('redOverlayAlpha')
                    startTween('redOverlayAlphaEnd', 'redOverlay', {alpha = 0}, 1.4, {ease = 'smootherStepOut', onComplete = 'fucku'})
                end
            else
                scaleObject('boyfriend', 0.9, 0.9)

                for i = 1, 5 do
                    setProperty('illegal'..i..'.alpha', 0)
                end
                for _, shit in ipairs(fateBG1) do
                    setProperty(shit.name..'.alpha', 1)
                    if shit.name == 'nieblia' then
                        setProperty(shit.name..'.alpha', 0.2)
                    end
                end
                for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do
                    doTweenAlpha(stuff..'Alpha', stuff, 1, 3)
                end

                removeLuaSprite('bfFALL', true)
                removeLuaSprite('lordXBite', true)
                triggerEvent('Change Character', 'dad', 'lord x podrido')
                setProperty('gf.visible', true)
                setProperty('boyfriend.visible', true)
                setProperty('dad.alpha', 1)

                for i = 4, 7 do
                    noteTweenX(i..'X' , i , (screenWidth / 1.35)--[[Offset]]+(115*(i-6))--[[NotesSeparation]], 2 + (i * 0.2), 'backOut')
                end
                for i = 0, 3 do
                    noteTweenAlpha(i..'Tween', i, 1, 3)
                end
            end
        end
        if value1 == 'part3' then
            for _, bg1 in ipairs(fateBG1) do
                removeLuaSprite(bg1.name, true)
            end

            removeSpriteShader('boyfriend')
            triggerEvent('Change Character', 'bf', 'bfo')
            setProperty('gf.visible', false)
            setProperty('dad.visible', false)
            scaleObject('boyfriend', 1.1, 1.1)
        end
        if value1 == 'part4' then
            local split = stringSplit(value2, ', ')
            if value2 == '' then
                for _, hola in ipairs(fateBG2) do
                    setProperty(hola.name..'.alpha', 1)
                end

                triggerEvent('Change Character', 'dad', 'lord x p3largo')
                triggerEvent('Change Character', 'bf', 'bf-perspective-right')

                setProperty('dad.alpha', 1)

                callMethod('boyfriend.setPosition',{
                    getProperty('boyfriend.x') - 500, getProperty('boyfriend.y') - 620
                })
                callMethod('dad.setPosition',{
                    getProperty('dad.x') - 500, getProperty('dad.y') - 840
                })
            elseif value2 == 'showHUD' then
                for _, stuff in ipairs({'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'iconBF', 'iconOpp', 'exeScoreTxt'}) do
                    doTweenAlpha(stuff..'Alpha', stuff, 1, 3)
                end
            elseif value2 == 'in his world' then
                triggerEvent('Change Character', 'dad', 'lord x p3corto')

                callMethod('dad.setPosition',{
                    getProperty('dad.x') - 500, getProperty('dad.y') - 840
                })

                doTweenAlpha('fogAlpha', 'fog', 1, 2)
                setSpriteShader('fog', 'wavyDistortion')
                setShaderFloat('fog', 'amount', 0.5)
            elseif split[1] == 'startGlitching' then
                if split[2] == '' then
                    triggerEvent('Change Character', 'dad', 'lord x p3scream')
            elseif split[2] == 'static' then
                    setProperty('dad._lastPlayedAnimation.paused', true)
            elseif split[2] == 'bug' then
                    setProperty('dad._lastPlayedAnimation.paused', false)
                    triggerEvent('chromFlash', '0, 2')
                    -- SHADERS QUE USAR:
                    -- * 
                end
            end
        end

        if value1 == 'bfClone' then
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                callMethod('bfClone.setPosition',{
                    getProperty('boyfriend.x') - 650, getProperty('boyfriend.y') - 250
                })
            elseif getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                callMethod('bfClone.setPosition',{
                    getProperty('boyfriend.x') - 850, getProperty('boyfriend.y') - 250
                })
            elseif getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                callMethod('bfClone.setPosition',{
                    getProperty('boyfriend.x') - 690, getProperty('boyfriend.y') - 50
                })
            end
            playAnim('bfClone', getProperty('boyfriend.animation.curAnim.name'), true)
            scaleObject('bfClone', 1, 1)
            doTweenScale('bfClone', 'bfClone', 1.4, 1)
            cancelTween('bfCloneAlpha')
            setProperty('bfClone.alpha', 0.3)
            doTweenAlpha('bfCloneAlpha', 'bfClone', 0, 1)
            if value2 == 'remove' then
                removeLuaSprite('bfClone', true)
            end
        end
    end
    if eventName == 'fateDodge' then
        startMechanic = true
        beats = value1

        makeLuaText('dodgeText', beats, 0, 550, 250)
        setObjectCamera('dodgeText', 'camHUD')
        setTextSize('dodgeText', 40)
        setTextFont('dodgeText', 'sonic-roco.ttf')
        addLuaSprite('dodgeText')
    end
end

function onBeatHit()
    if startMechanic then

        beats = beats - 1

        if not hasDodged then
            setProperty('spaceBar.alpha', 1)
            playAnim('spaceBar', 'idle', true)
        end

        playSound('Metronome_Tick', 0.5)

        if luaTextExists('dodgeText') then setTextString('dodgeText', beats) end

        runTimer('activateCanDodge', 0.001)

        if beats == 1 then
            playSound('fatewhip')
        end

        if beats == 0 then
            runTimer('dodgeTextDissapear', 1)
            playAnim('dad', 'hey', true)
            setProperty('dad.specialAnim', true)

            setTextString('dodgeText', 'NOW')
            if hasDodged then
                playAnim('boyfriend', 'dodge', true)
                setProperty('boyfriend.specialAnim', true)
            else
                loseHealthBitch = true
                setProperty('healthShit.x', getProperty('health'))
                doTweenX('healthLose', 'healthShit', getProperty('healthShit.x') - 2, 0.6, 'circOut')
                runTimer('stopLosingShit', 0.6)
            end
            canDodge = false
            startMechanic = false
            setProperty('spaceBar.alpha', 0)
        end
    end
end

function goodNoteHitPre(id)
	if getProperty('boyfriend.animation.curAnim.name') == 'dodge' then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end

function opponentNoteHitPre(id)
	if getProperty('dad.animation.curAnim.name') == 'hey' then
		setPropertyFromGroup('notes', id, 'noAnimation', true)
	end
end

function onTweenCompleted(tag)
    if tag == 'healthLose' then loseHealthBitch = false end
    if tag == 'redOverlayAlphaEnd' then removeLuaSprite('redOverlay', true) end
end

function onTimerCompleted(t)
    if t == 'activateCanDodge' then
        canDodge = true
    end
    if t == 'dodgeTextDissapear' then
        removeLuaText('dodgeText', true)
        hasDodged = false
    end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onUpdate()
    if canDodge then
        if keyboardJustPressed('SPACE') or getProperty('cpuControlled') then
            hasDodged = true
            setProperty('spaceBar.alpha', 0)
            canDodge = false
        end
    end
end

--From Dudu
--Tweens the scale of an object
function doTweenScale(tag, obj, target, time, ease)
	doTweenX(tag..'scaleX', obj..'.scale', target, time, ease)
	doTweenY(tag..'scaleY', obj..'.scale', target, time, ease)
end