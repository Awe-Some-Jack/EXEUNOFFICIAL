function onCreatePost()
    setProperty('scoreTxt.visible', false)
    setProperty('healthBar.visible', false)
    setProperty('iconP1.visible', false) 
    setProperty('iconP2.visible', false)

    makeLuaSprite('healthBG', 'hud/hud_fight-or-flight')
    setObjectCamera('healthBG', 'hud')
    screenCenter('healthBG', 'Y')
    setProperty('healthBG.x', screenWidth - getProperty('healthBG.width') - 60)

    makeLuaSprite('hbHealth', nil, getProperty('healthBG.x') + 60, getProperty('healthBG.y') + 162)
    setObjectCamera('hbHealth', 'hud')
    makeGraphic('hbHealth', 16, 464, 'FFFFFF')
    setProperty('hbHealth.color', getColorFromHex(getHealthColor('boyfriend')))

    makeLuaSprite('hbHealth2', nil, getProperty('healthBG.x') + 60, getProperty('healthBG.y') + 162)
    setObjectCamera('hbHealth2', 'hud')
    makeGraphic('hbHealth2', 16, 232, 'FFFFFF')
    setProperty('hbHealth2.color', getColorFromHex(getHealthColor('dad')))

    makeLuaSprite('separatorHealth', nil, getProperty('healthBG.x') + 60)
    makeGraphic('separatorHealth', 16, 4, 'FFFFFF')
    setObjectCamera('separatorHealth', 'hud')

    createInstance('iconBF', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), true})
    setObjectCamera('iconBF', 'hud')

    createInstance('iconOpp', 'objects.HealthIcon', {getProperty('dad.healthIcon'), false})
    setObjectCamera('iconOpp', 'hud')

    makeLuaText('exeScoreTxt', 'Score: 0 | Sacrifices: 0', screenWidth * 0.9)
    setTextSize('exeScoreTxt', 22)
    setTextAlignment('exeScoreTxt', 'center')
    setTextBorder('exeScoreTxt', 1, '000000')
    screenCenter('exeScoreTxt', 'x')
    setProperty('exeScoreTxt.x', math.floor(getProperty('exeScoreTxt.x')))
    setProperty('exeScoreTxt.y', downscroll and (screenHeight - getProperty('exeScoreTxt.height') - 10) or 10)

    addLuaSprite('hbHealth')
    addLuaSprite('hbHealth2')
    addLuaSprite('separatorHealth')
    addLuaSprite('healthBG')
    addInstance('iconBF')
    addInstance('iconOpp')
    addLuaText('exeScoreTxt')
end

local oldScoreTxt = ''
local lerpHealth = 1

function onUpdatePost(e)
    lerpHealth = lerp(getHealth(), lerpHealth, math.exp(-e * 12 * playbackRate))

    setProperty('iconOpp.x', getProperty('healthBG.x') + (getProperty('healthBG.width') - 150) / 2)
    setProperty('iconOpp.y', getProperty('healthBG.y') + 162 - 75 - 20)
    setProperty('iconBF.x', getProperty('healthBG.x') + (getProperty('healthBG.width') - 150) / 2)
    setProperty('iconBF.y', getProperty('healthBG.y') + 162 + 464 - 75 + 20)

    setGraphicSize('hbHealth2', 16, bound(lerp(464, 1, lerpHealth / 2), 1, 464))
    setProperty('separatorHealth.y', getProperty('healthBG.y') + 162 + bound(lerp(460, 0, lerpHealth / 2), 0, 460))
    
    setTextString('exeScoreTxt', capitalize(getTranslationPhrase("freeplay.score", "SCORE")) 
					.. ': ' .. formatScore(score) .. ' | ' .. capitalize(getTranslationPhrase("starved_sacrifices", "Sacrifices")) .. ': ' .. misses)

    if oldScoreTxt ~= getTextString('exeScoreTxt') then 
        scaleObject('exeScoreTxt', 1.1, 1.1, false) 
    end
    oldScoreTxt = getTextString('exeScoreTxt')
    
    scaleObject('exeScoreTxt', lerp(getProperty('exeScoreTxt.scale.x'), 1, e * 10), lerp(getProperty('exeScoreTxt.scale.y'), 1, e * 10), false)

    setProperty('iconBF.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
    setProperty('iconOpp.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
    
    local multOpp = lerp(1, getProperty('iconOpp.scale.x'), math.exp(-e * 9 * playbackRate)) 
    scaleObject('iconOpp', multOpp, multOpp, false)
    
    local multBf = lerp(1, getProperty('iconBF.scale.x'), math.exp(-e * 9 * playbackRate)) 
    scaleObject('iconBF', multBf, multBf, false)
end

function onBeatHit()
    scaleObject('iconBF', 1.2, 1.2, false)
    scaleObject('iconOpp', 1.2, 1.2, false)
end

function getHealthColor(arg)
    return string.format("%02x%02x%02x", math.floor(getProperty(arg..'.healthColorArray[0]')), math.floor(getProperty(arg..'.healthColorArray[1]')), math.floor(getProperty(arg..'.healthColorArray[2]')))
end

function lerp(a, b, t)
    return a + t * (b - a)
end

function bound(number, min, max)
    return math.max(min, math.min(max, number))
end

function formatScore(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

function capitalize(str)
    if str == nil or str == '' then return '' end
    
    local success, res = pcall(function()
        return runHaxeCode([[
            var s:String = "]] .. tostring(str) .. [[";
            return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
        ]])
    end)
    
    if success and res ~= nil and res ~= '' then
        return res
    end

    str = tostring(str):lower()
    return (str:gsub("^%a", string.upper))
end