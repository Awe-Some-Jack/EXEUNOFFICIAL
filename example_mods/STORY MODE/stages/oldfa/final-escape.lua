local BGAssets = {
    ['introBG'] = {
        {name = 'ojos', path = 'final/eyes', x = 0, y = 0, angle = 5, scaleX = 0.5, scaleY = 0.5, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = true},
        {name = 'sky', path = 'final/escapebg/sky', x = -200, y = -100, scaleX = 1, scaleY = 1, scrollX = 0.3, scrollY = 0.3, alpha = 1, front = false},
        {name = 'lightning', path = 'final/escapebg/lightnings', x = -150, y = -100, animated = true, fps = 24, loop = false, scaleX = 0.5, scaleY = 0.5, scrollX = 0.4, scrollY = 0.4, alpha = 0, front = false},
        {name = 'cloudsbg', path = 'final/escapebg/cloudsbg', x = -150, y = -100, scaleX = 1, scaleY = 1, scrollX = 0.4, scrollY = 0.4, alpha = 1, front = false},
        {name = 'clouds2', path = 'final/escapebg/clouds2', x = -100, y = -100, scaleX = 1, scaleY = 1, scrollX = 0.5, scrollY = 0.5, alpha = 1, front = false},
        {name = 'clouds1', path = 'final/escapebg/clouds1', x = -50, y = -100, scaleX = 1, scaleY = 1, scrollX = 0.6, scrollY = 0.6, alpha = 1, front = false},
        {name = 'objects3', path = 'final/escapebg/objects3', x = 300, y = 30, scaleX = 1, scaleY = 1, scrollX = 0.6, scrollY = 0.6, alpha = 1, front = false, floatable = true},
        {name = 'objects2', path = 'final/escapebg/objects2', x = 450, y = -30, scaleX = 1, scaleY = 1, scrollX = 0.6, scrollY = 0.6, alpha = 1, front = false, floatable = true},
        {name = 'objects1', path = 'final/escapebg/objects1', x = 250, y = 20, scaleX = 1, scaleY = 1, scrollX = 0.6, scrollY = 0.6, alpha = 1, front = false, floatable = true},
        {name = 'lake', path = 'final/escapebg/lake', x = -50, y = -100, scaleX = 1, scaleY = 1, scrollX = 0.7, scrollY = 0.7, alpha = 1, front = false},
        {name = 'ground', path = 'final/escapebg/floor', x = 50, y = 600, scaleX = 1, scaleY = 1, alpha = 1, front = false}
    },

    ['firstBG'] = {
        {name = 'bgFirstSection', path = 'final/mbg', x = -800, y = -300, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.3, scrollY = 0.3, antialiasing = true, alpha = 0, front = false},
        {name = 'dirt', path = 'final/dirt-1', x = -150, y = -150, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.75, scrollY = 0.75, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'sega666', path = 'final/sega 666', x = 700, y = -20, animated = true, animName = 'idle', animPrefix = 'Símbolo 138', fps = 16, loop = true, scaleX = 1, scaleY = 1, scrollX = 0.3, scrollY = 0.3, antialiasing = true, alpha = 0, front = false},
        {name = 'farol', path = 'final/farol', x = 1350, y = 180, animated = true, animName = 'idle', animPrefix = 'Símbolo 82', fps = 24, loop = true, scaleX = 1, scaleY = 1, scrollX = 0.7, scrollY = 0.7, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'eggshit', path = 'final/egg', x = 650, y = -170, animated = true, animName = 'idle', animPrefix = 'egg', fps = 24, loop = true, scaleX = 0.5, scaleY = 0.5, scrollX = 0.85, scrollY = 0.85, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 's', path = 'final/s', x = -300, y = 350, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, antialiasing = true, alpha = 0, front = true, floatable = true},
        {name = 'o', path = 'final/o', x = 0, y = 550, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, antialiasing = true, alpha = 0, front = true, floatable = true},
        {name = 'n', path = 'final/n', x = 720, y = 120, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'i', path = 'final/i', x = 1020, y = 240, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'c', path = 'final/c', x = 1220, y = 320, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.9, scrollY = 0.9, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'vida', path = 'final/life', x = 1280, y = -140, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.85, scrollY = 0.85, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'sega', path = 'final/sega', x = 830, y = -140, animated = false, scaleX = 1, scaleY = 1, scrollX = 0.7, scrollY = 0.7, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'rock', path = 'final/rock', x = 1450, y = 500, animated = false, scaleX = 1, scaleY = 1, scrollX = 1.1, scrollY = 1.1, antialiasing = true, alpha = 0, front = false, floatable = true},
        {name = 'groundFirstSection', path = 'final/piso 1', x = 0, y = 400, animated = true, animName = 'idle', animPrefix = 'Símbolo 83', fps = 24, loop = true, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false}
    },

    ['secondBG'] = {
        {name = 'groundSecondSection', path = 'final/piso 2', x = 610, y = 550, animated = true, animName = 'idle', animPrefix = 'Símbolo 148', fps = 24, loop = true, scaleX = 0.5, scaleY = 0.5, scrollX = 1, scrollY = 1, antialiasing = true, frontXeno = true, alpha = 0, front = false},
    },

    ['thirdBG'] = {
        {name = 'groundThirdSection', path = 'final/floor', x = 0, y = 200, animated = true, animName = 'idle', animPrefix = 'Símbolo 2071', fps = 24, loop = true, scaleX = 1, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false},
    },

    ['fourthBG'] = {
        {name = 'groundFourthSection', path = 'final/piso loop', x = 0, y = 200, animated = true, animName = 'idle', animPrefix = 'Símbolo 149', fps = 24, loop = true, scaleX = 2, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false},
    },

    ['fifthBG'] = {
        {name = 'bgShit', path = 'final/piso loop', x = 0, y = 200, animated = true, animName = 'idle', animPrefix = 'Símbolo 149', fps = 24, loop = true, scaleX = 2, scaleY = 1, scrollX = 1, scrollY = 1, antialiasing = true, alpha = 0, front = false},
    },

    ['loopSprites'] = {
        {name = 'bgLoop', path = 'final/mbg', velocityX = -1500, x = nil, y = 0, scaleX = 1, scaleY = 1, alpha = 0},
        {name = 'idkLoop', path = 'final/bg-lol', velocityX = -2500, x = nil, y = 700, scaleX = 1, scaleY = 1, alpha = 0},
        {name = 'spikeDownLoop', path = 'final/pinchos', velocityX = -500, x = nil,  y = 1700, scaleX = 1, scaleY = 1, alpha = 0},
        {name = 'spikeUpLoop', path = 'final/pinchos', velocityX = 500, flipY = true, x = nil, y =  850, scaleX = 1, scaleY = 1, alpha = 0},
    }
}


local function addSprite(spr)
    if spr.animated then
        makeAnimatedLuaSprite(spr.name, spr.path, spr.x, spr.y)
        if spr.name == 'lightning' then
            addAnimationByPrefix(spr.name, 'variant1', 'variant1', spr.fps, spr.loop)
            addAnimationByPrefix(spr.name, 'variant2', 'variant2', spr.fps, spr.loop)
            addAnimationByPrefix(spr.name, 'variant3', 'variant3', spr.fps, spr.loop)
        else
            addAnimationByPrefix(spr.name, spr.animName, spr.animPrefix, spr.fps, spr.loop)
        end
    else makeLuaSprite(spr.name, spr.path, spr.x, spr.y) end
    scaleObject(spr.name, spr.scaleX, spr.scaleY)
    if spr.angle then setProperty(spr.name..'.angle', spr.angle) end
    if spr.scrollX or spr.scrollY then setScrollFactor(spr.name, spr.scrollX, spr.scrollY) end
    if spr.antialiasing then setProperty(spr.name..'.antialiasing', spr.antialiasing) end
    if spr.frontXeno then setObjectOrder(spr.name, getObjectOrder('boyfriendGroup')) end
    setProperty(spr.name..'.alpha', spr.alpha)
    addLuaSprite(spr.name, spr.front)
end

local function createLoopSprite(spr)
    createInstance(spr.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
    loadGraphic(spr.name, spr.path)
    setProperty(spr.name..'.velocity.x', spr.velocityX)
    setProperty(spr.name..'.y', spr.name == 'bgLoop' and getProperty('bgLoop.y') - 500 or spr.y)
    setProperty(spr.name..'.alpha', spr.alpha)
    if spr.flipY then setProperty(spr.name..'.flipY', spr.flipY) end
    addInstance(spr.name, false)
end

function onCreate()
    startVideo("fake intro", false, true, false, false)
    callMethod("remove", {instanceArg("videoCutscene")})
end

luaDebugMode = true
function onCreatePost()
    for _, feIntro   in ipairs(BGAssets['introBG'])     do   addSprite(feIntro)         end
    for _, feFirst   in ipairs(BGAssets['firstBG'])     do   addSprite(feFirst)         end
    for _, feSecond  in ipairs(BGAssets['secondBG'])    do   addSprite(feSecond)        end
    for _, feThird   in ipairs(BGAssets['thirdBG'])     do   addSprite(feThird)         end
    for _, feLoops   in ipairs(BGAssets['loopSprites']) do   createLoopSprite(feLoops)  end
    for _, feFourth  in ipairs(BGAssets['fourthBG'])    do   addSprite(feFourth)        end
    --for _, feFifth   in ipairs(BGAssets['fifthBG']) do   addSprite(feFifth)  end

    makeLuaSprite('whiteout', 'final/transition', -800, 400)
    scaleObject('whiteout', 10000, 1)
    setProperty('whiteout.alpha', 0)
    addLuaSprite('whiteout', true)

    makeLuaSprite('blackgraphic')
    makeGraphic('blackgraphic', 1280, 720, '000000')
    setScrollFactor('blackgraphic', 0, 0)
    setProperty('blackgraphic.alpha', 0)
    screenCenter('blackgraphic')
    addLuaSprite('blackgraphic', true)

    setObjectOrder('ojos', getObjectOrder('blackgraphic') + 1)

    setProperty('cpuAssist', true)
end

function onSongStart()
    startVideo("fake intro", false, true)
    setProperty('inCutscene', false)
    setProperty('videoCutscene.videoSprite.volumeAdjust', 0)
end

local bgLoopFading = false
local bgLoopFadeSpeed = 0.8

function onEvent(n, v1)
    if n == 'finalescapeEvent' and v1 == 'startwhiteout' then
        bgLoopFading = true
    end
    if n == 'finalescapeEvent' and v1 == 'lightning' then
        playAnim('lightning', 'variant'..getRandomInt(1,3), true)
        setProperty('lightning.alpha', 1)
        triggerEvent('bloomFlash', '0.15, 0', '0.5')
    end
end

local floathold = 0
function onUpdatePost(e)
    if bgLoopFading then
        local a = getProperty('bgLoop.alpha') - bgLoopFadeSpeed * e
        setProperty('bgLoop.alpha', math.max(a, 0))
        if a <= 0 then bgLoopFading = false end
    end
    floathold = floathold + e
    for num,feIntro in ipairs(BGAssets['introBG']) do
        if feIntro.floatable == true then
            callMethod(feIntro.name..'.setPosition', {
                feIntro.x + math.sin(floathold + 0.5 * (num - 1)) * 3, --X + el sin de elapsed + 0.5 multiplicado por el numero menos 1 y todo ese math se multiplica por cinco
                feIntro.y + math.cos(floathold + 0.5 * (num - 1)) * 10
            })
            setProperty(feIntro.name..'.angle', math.cos(floathold + 0.5 * (num - 1)) * 2)
        end
    end

    for num,feFirst in ipairs(BGAssets['firstBG']) do
        if feFirst.floatable == true then
            callMethod(feFirst.name..'.setPosition', {
                feFirst.x + math.sin(floathold + 0.5 * (num - 1)) * 5, --X + el sin de elapsed + 0.5 multiplicado por el numero menos 1 y todo ese math se multiplica por cinco
                feFirst.y + math.cos(floathold + 0.5 * (num - 1)) * 20
            })
            setProperty(feFirst.name..'.angle', math.cos(floathold + 0.5 * (num - 1)) * 5)
        end
    end

    scaleObject('blackgraphic', 1 / getProperty('camGame.zoom'), 1 / getProperty('camGame.zoom'), false)
    callMethod('ojos.setPosition', {getProperty('dad.x') + 300, getProperty('dad.y') + 190})

     if getProperty('lightning.animation.curAnim.finished') then setProperty('lightning.alpha', 0) end
end

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