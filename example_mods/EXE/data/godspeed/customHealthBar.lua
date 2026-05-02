local iconProps = {
    playerIcon = {
        scale = 1,
        offsetX = 0,
        offsetY = 0,
        bopAmount = 1.2
    },
    opponentIcon = {
        scale = 1.1,
        offsetX = 0,
        offsetY = -15,
        bopAmount = 1
    }
}

local oldScoreTxt = ''
local startX = 0
function onCreatePost()
    if songPath ~= 'godspeed' then return end

    setProperty('scoreTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('healthBar.visible', false)

    makeLuaSprite('hbBG', nil, 0, screenHeight * (downscroll and 0.11 or 0.89))
    setObjectCamera('hbBG', 'hud')
    makeGraphic('hbBG', 601, 25, '000000')
    screenCenter('hbBG', 'x')
    startX = getProperty('hbBG.x')

    makeLuaSprite('hbHealth', nil, 0, screenHeight * (downscroll and 0.11 or 0.89) + 5)
    setObjectCamera('hbHealth', 'hud')
    makeGraphic('hbHealth', getProperty('hbBG.width') - 10, getProperty('hbBG.height') - 10, 'FFFFFF')
    setProperty('hbHealth.x', getProperty('hbBG.x') + 4)

    createInstance('iconBF', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), true})
    setObjectCamera('iconBF', 'hud')

    createInstance('iconOpp', 'objects.HealthIcon', {getProperty('dad.healthIcon'), false})
    setObjectCamera('iconOpp', 'hud')

    makeLuaText('exeScoreTxt', 'Score: 0 | Misses: 0', screenWidth / 0.75, 0, getProperty('hbBG.y') + (downscroll and 30 or -30))
    setTextSize('exeScoreTxt', 22)
    setTextBorder('exeScoreTxt', 1, '000000')
    screenCenter('exeScoreTxt', 'x')
    setProperty('exeScoreTxt.x', math.floor(getProperty('exeScoreTxt.x')))
    setObjectOrder('exeScoreTxt', getObjectOrder('iconOpp') + 1)

    setProperty('hbHealth.color', getColorFromHex(getHealthColor('boyfriend')))
    setProperty('hbHealth2.color', getColorFromHex(getHealthColor('dad')))

    addLuaSprite('hbBG')
    addLuaSprite('hbHealth')
    addLuaSprite('hbHealth2')
    addLuaSprite('separatorHealth')
    addInstance('iconBF')
    addInstance('iconOpp')
    addLuaText('exeScoreTxt')

    setProperty('healthGain', 0)
    setHealth(2)

    setProperty('iconP1.visible', false) setProperty('iconP2.visible', false)

    makeAnimatedLuaSprite('tentacles_black', 'black sun/tentacles')
	addAnimationByPrefix('tentacles_black', 'idle', 'Símbolo', 24, true)
	setObjectCamera('tentacles_black', 'other')
	scaleObject('tentacles_black', 0.7, 0.7)
	screenCenter('tentacles_black')
	addLuaSprite('tentacles_black', true)

	makeLuaSprite('BlackVG', 'VG')
    setProperty('BlackVG.color', getColorFromHex('000000'))
	setObjectCamera('BlackVG', 'other')
	addLuaSprite('BlackVG', true)
end

function onEvent(n)
    if n == 'Change Character' then
        setProperty('hbHealth.color', getColorFromHex(getHealthColor('boyfriend')))
        setProperty('hbHealth2.color', getColorFromHex(getHealthColor('dad')))
        callMethod('iconBF.changeIcon', {getProperty('boyfriend.healthIcon')})
        callMethod('iconOpp.changeIcon', {getProperty('dad.healthIcon')})
    end
end

function onUpdatePost(e)
    if songPath ~= 'godspeed' then return end
    addHealth(-0.0025 * e)
    setProperty('hbBG.x', lerp(startX + 500, startX, bound(getHealth(), 0, 2) / 2))
    setGraphicSize('hbBG', lerp(100, 601, bound(getHealth(), 0, 2) / 2), 25)

    setProperty('iconOpp.x', getProperty('hbBG.x') - 75 + iconProps.opponentIcon.offsetX + getRandomFloat(-1, 1))
    setProperty('iconOpp.y', getProperty('hbBG.y') + (getProperty('hbBG.height') / 2) - 75 + iconProps.opponentIcon.offsetY + getRandomFloat(-1, 1))
    setProperty('iconOpp.angle', getRandomFloat(-1, 1))
    setProperty('iconBF.x', getProperty('hbBG.x') + (getProperty('hbBG.width') - 75) + iconProps.playerIcon.offsetX)
    setProperty('iconBF.y', getProperty('hbBG.y') + (getProperty('hbBG.height') / 2) - 75 + iconProps.playerIcon.offsetY)

    setProperty('hbHealth.x', getProperty('hbBG.x') + 4)
    setGraphicSize('hbHealth', getProperty('hbBG.width') - 10, getProperty('hbBG.height') - 10)
    setProperty('separatorHealth.x', getProperty('hbHealth.x') + bound(lerp(getProperty('hbHealth.width') - 4, 0, math.abs(0 + getHealth() / 2)), 0, getProperty('hbHealth.width') - 4))
    
    setTextString('exeScoreTxt', 'Score: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatMoney', {score, false})..' | Misses: '..misses)
    if oldScoreTxt ~= getTextString('exeScoreTxt') then scaleObject('exeScoreTxt', 1.1, 1.1, false) end
    oldScoreTxt = getTextString('exeScoreTxt')
    scaleObject('exeScoreTxt', lerp(getProperty('exeScoreTxt.scale.x'), 1, e * 10), lerp(getProperty('exeScoreTxt.scale.y'), 1, e * 10), false)

    setProperty('iconBF.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconOpp.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
    local mult = lerp(iconProps.opponentIcon.scale, getProperty('iconOpp.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconOpp', mult, mult, false)
    local mult = lerp(iconProps.playerIcon.scale, getProperty('iconBF.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconBF', mult, mult, false)

    setProperty('BlackVG.alpha', 1.2 - getHealth() / 2)
	setProperty('tentacles_black.alpha', 1.2 - getHealth() / 2)
end

function onBeatHit()
    scaleObject('iconBF', iconProps.playerIcon.scale * iconProps.playerIcon.bopAmount, iconProps.playerIcon.scale * iconProps.playerIcon.bopAmount, false)
    scaleObject('iconOpp', iconProps.opponentIcon.scale * iconProps.opponentIcon.bopAmount, iconProps.opponentIcon.scale * iconProps.opponentIcon.bopAmount, false)
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