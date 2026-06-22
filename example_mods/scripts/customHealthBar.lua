local healthProps = {
    healthBar = {
		width = 601,
		height = 25,
		gapSize = 5,
		separatorWidth = 4,
        textBopAmount = 1.1,
        hideScore = false,
        offsetX = 0,
        offsetY = 0
	},
    playerIcon = {
        scale = 1,
        offsetX = 0,
        offsetY = 0,
        bopAmount = 1.2
    },
    opponentIcon = {
        scale = 1,
        offsetX = 0,
        offsetY = 0,
        bopAmount = 1.2
    }
}

local lerpHealth = 1

local healthBarsBG = {
    ["hud_majin"] = {
        songs = {'endless-us', 'endless-jp'},
        x = - 190,
        y = - 70
    },
    ["hud_fakebaby"] = {
        songs = {'fakebaby'},
        x = - 190,
        y = - 75
    },
    ["hud_lookalike"] = {
        songs = {'yourself'},
        x = - 190,
        y = - 75
    },
    ["hud_chaos"] = {
        songs = {'chaos'},
        x = - 190,
        y = - 75
    },
    ["hud_too-fest"] = {
        songs = {'too-fest'},
        x = - 190,
        y = - 65
    },
    ["hud_needlemouse"] = {
        songs = {'round-a-bout', 'her-world'},
        x = - 190,
        y = - 65
    },
    ["hud_lord_x"] = {
        songs = {'cycles', 'hellbent', 'fate', 'gotta-go'},
        x = - 190,
        y = - 75
    },
    ["hud_faker"] = {
        songs = {'faker', 'black-sun', 'godspeed'},
        x = - 190,
        y = - 80
    },
    ["hud_hedge"] = {
        songs = {'hedge', 'manual-blast'},
        x = - 190,
        y = - 70
    },
    ["hud_shocker"] = {
        songs = {'shocker'},
        x = - 190,
        y = - 70
    },
}
local blacklistenedSongs = {'prey', 'godspeed', 'forestall-desire', 'deception', 'fatality', 'longstrider', 'universal-collapse'}

local flipped = false
local oldScoreTxt = ''
function onCreatePost()
    if checkFileExists('data/'..songPath..'/healthProps.json') then
		json = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('data/'..songPath..'/healthProps.json')})
		for i,v in pairs(json) do
			if v ~= nil then healthProps[i] = v end
		end
	end

    for i = 1,#blacklistenedSongs do if songPath == blacklistenedSongs[i] then close() return end end

    setProperty('scoreTxt.visible', false)
    setProperty('healthBar.visible', false)

    makeLuaSprite('hbBG', nil, 0, screenHeight * (downscroll and 0.11 or 0.89) + healthProps.healthBar.offsetY)
    setObjectCamera('hbBG', 'hud')
    makeGraphic('hbBG', healthProps.healthBar.width, healthProps.healthBar.height, 'FFFFFF')
    setProperty('hbBG.color', getColorFromHex('000000'))
    screenCenter('hbBG', 'x')
    setProperty('hbBG.x', getProperty('hbBG.x') + healthProps.healthBar.offsetX)

    makeLuaSprite('hbHealth', nil, 0, screenHeight * (downscroll and 0.11 or 0.89) + healthProps.healthBar.gapSize + healthProps.healthBar.offsetY)
    setObjectCamera('hbHealth', 'hud')
    makeGraphic('hbHealth', getProperty('hbBG.width') - (healthProps.healthBar.gapSize * 2), getProperty('hbBG.height') - (healthProps.healthBar.gapSize * 2), 'FFFFFF')
    setProperty('hbHealth.x', getProperty('hbBG.x') + healthProps.healthBar.separatorWidth)

    makeLuaSprite('hbHealth2', nil, 0, screenHeight * (downscroll and 0.11 or 0.89) + healthProps.healthBar.gapSize + healthProps.healthBar.offsetY)
    setObjectCamera('hbHealth2', 'hud')
    makeGraphic('hbHealth2', getProperty('hbBG.width') / 2 - (healthProps.healthBar.gapSize * 2), getProperty('hbBG.height') - (healthProps.healthBar.gapSize * 2), 'FFFFFF')
    setProperty('hbHealth2.x', getProperty('hbBG.x') + healthProps.healthBar.separatorWidth)

    makeLuaSprite('separatorHealth', nil, 0, screenHeight * (downscroll and 0.11 or 0.89) + healthProps.healthBar.gapSize + healthProps.healthBar.offsetY)
    makeGraphic('separatorHealth', healthProps.healthBar.separatorWidth, getProperty('hbBG.height') - (healthProps.healthBar.gapSize * 2), 'FFFFFF')
    setObjectCamera('separatorHealth', 'hud')

    createInstance('iconBF', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), true})
    setObjectCamera('iconBF', 'hud')
    scaleObject('iconBF', healthProps.playerIcon.scale, healthProps.playerIcon.scale, false)

    createInstance('iconOpp', 'objects.HealthIcon', {getProperty('dad.healthIcon'), false})
    setObjectCamera('iconOpp', 'hud')
    scaleObject('iconOpp', healthProps.opponentIcon.scale, healthProps.opponentIcon.scale, false)

    setProperty('hbHealth.color', getColorFromHex(getHealthColor('boyfriend')))
    setProperty('hbHealth2.color', getColorFromHex(getHealthColor('dad')))

    addLuaSprite('hbBG')
    addLuaSprite('hbHealth')
    addLuaSprite('hbHealth2')
    addLuaSprite('separatorHealth')
    addInstance('iconBF')
    addInstance('iconOpp')
    if not healthProps.healthBar.hideScore then addLuaText('exeScoreTxt') end

    setProperty('iconP1.visible', false) setProperty('iconP2.visible', false)

    if flipped then
        setProperty('hbHealth.color', getColorFromHex(getHealthColor((flipped and 'dad' or 'boyfriend'))))
        setProperty('hbHealth2.color', getColorFromHex(getHealthColor((flipped and 'boyfriend' or 'dad'))))
        setProperty('iconBF.flipX', not getProperty('iconBF.flipX'))
        setProperty('iconOpp.flipX', not getProperty('iconOpp.flipX'))
    end

    local healthPos = {getProperty('hbBG.x'), getProperty('hbBG.y')}
    local found = false
    for hud, songList in pairs(healthBarsBG) do
        for _, name in ipairs(songList.songs) do
            if name == songPath then
                found = true
                makeLuaSprite('healthBG', 'hud/'..hud, healthPos[1] + songList.x, healthPos[2] + songList.y)
                setObjectCamera('healthBG', 'camHUD')
                setObjectOrder('healthBG', getObjectOrder('separatorHealth') + 1)
                scaleObject('healthBG', 0.32, 0.3)
                addLuaSprite('healthBG')
                break
            end
            if found then break end
        end
    end

    if not found then
        makeLuaSprite('healthBG', 'hud/hud_general', healthPos[1] - 190, healthPos[2] - 65)
        setObjectCamera('healthBG', 'camHUD')
        setObjectOrder('healthBG', getObjectOrder('separatorHealth') + 1)
        scaleObject('healthBG', 0.32, 0.3)
        addLuaSprite('healthBG')
    end

    if songPath == 'chocolate-milk' or songPath == 'vanilla-milk' or songPath == 'b4cksl4sh' then setProperty('healthBG.visible', false) end

    if not healthProps.healthBar.hideScore then
        makeLuaText('exeScoreTxt', 'Score: 0 | Misses: 0', screenWidth / 0.75, 0, getProperty('hbBG.y') + (downscroll and 40 or -40))
        setTextSize('exeScoreTxt', 22)
        setTextBorder('exeScoreTxt', 1, '000000')
        screenCenter('exeScoreTxt', 'x')
        setProperty('exeScoreTxt.x', math.floor(getProperty('exeScoreTxt.x') + healthProps.healthBar.offsetX))
        setObjectOrder('exeScoreTxt', getObjectOrder('iconOpp') + 1)
    end
end

function onEvent(n, v1)
    if n == 'Change Character' then
        setProperty('hbHealth.color', getColorFromHex(getHealthColor((flipped and 'dad' or 'boyfriend'))))
        setProperty('hbHealth2.color', getColorFromHex(getHealthColor((flipped and 'boyfriend' or 'dad'))))
        callMethod('iconBF.changeIcon', {getProperty('boyfriend.healthIcon')})
        callMethod('iconOpp.changeIcon', {getProperty('dad.healthIcon')})
    end

    if n == 'Flip Health Bar' then
        flipped = not flipped
        setProperty('hbHealth.color', getColorFromHex(getHealthColor((flipped and 'dad' or 'boyfriend'))))
        setProperty('hbHealth2.color', getColorFromHex(getHealthColor((flipped and 'boyfriend' or 'dad'))))
        setProperty('iconBF.flipX', not getProperty('iconBF.flipX'))
        setProperty('iconOpp.flipX', not getProperty('iconOpp.flipX'))
    end

    if n == 'Change HealthBG' then
        loadGraphic('healthBG', 'hud/'..v1)
    end
end

function onUpdatePost(e)
    lerpHealth = lerp(getHealth(), lerpHealth, math.exp(-e * 12 * playbackRate))

    setProperty('iconOpp.x', getProperty('hbBG.x') + (flipped and (getProperty('hbBG.width') - 75) or (-75)) + healthProps.opponentIcon.offsetX)
    setProperty('iconOpp.y', getProperty('hbBG.y') + (getProperty('hbBG.height') / 2) - 75 + healthProps.opponentIcon.offsetY)
    setProperty('iconBF.x', getProperty('hbBG.x') + (flipped and (-75) or (getProperty('hbBG.width') - 75)) + healthProps.playerIcon.offsetX)
    setProperty('iconBF.y', getProperty('hbBG.y') + (getProperty('hbBG.height') / 2) - 75 + healthProps.playerIcon.offsetY)

    setGraphicSize('hbHealth2', bound(lerp(getProperty('hbBG.width') - (healthProps.healthBar.gapSize * 2), 1, math.abs((flipped and (-1) or 0) + lerpHealth / 2)), 1, getProperty('hbBG.width') - (healthProps.healthBar.gapSize * 2)), getProperty('hbBG.height') - (healthProps.healthBar.gapSize * 2))
    setProperty('separatorHealth.x', getProperty('hbHealth.x') + bound(lerp(getProperty('hbHealth.width') - healthProps.healthBar.separatorWidth, 0, math.abs((flipped and (-1) or 0) + lerpHealth / 2)), 0, getProperty('hbHealth.width') - healthProps.healthBar.separatorWidth))

    for _, songList in pairs(healthBarsBG) do
        for _, name in ipairs(songList.songs) do
            if name == songPath then
                callMethod('healthBG.setPosition', {getProperty('hbBG.x') + songList.x, getProperty('hbBG.y') + songList.y})
            end
        end
    end

    if not healthProps.healthBar.hideScore then
        setTextString('exeScoreTxt', 'Score: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatMoney', {score, false})..' | Misses: '..misses)
        if oldScoreTxt ~= getTextString('exeScoreTxt') then scaleObject('exeScoreTxt', healthProps.healthBar.textBopAmount, healthProps.healthBar.textBopAmount, false) end
        oldScoreTxt = getTextString('exeScoreTxt')
        scaleObject('exeScoreTxt', lerp(getProperty('exeScoreTxt.scale.x'), 1, e * 10), lerp(getProperty('exeScoreTxt.scale.y'), 1, e * 10), false)
    end

    setProperty('iconBF.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconOpp.animation.curAnim.curFrame', (songPath == 'black-sun' and (getHealth() < 0.4 and 1 or 0) or (getHealth() > 1.6 and 1 or 0)))
    local mult = lerp(healthProps.opponentIcon.scale, getProperty('iconOpp.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconOpp', mult, mult, false)
    local mult = lerp(healthProps.playerIcon.scale, getProperty('iconBF.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconBF', mult, mult, false)

    setProperty('healthBG.alpha', getProperty('hbBG.alpha'))
end

function onBeatHit()
    scaleObject('iconBF', healthProps.playerIcon.scale * healthProps.playerIcon.bopAmount, healthProps.playerIcon.scale * healthProps.playerIcon.bopAmount, false)
    scaleObject('iconOpp', healthProps.opponentIcon.scale * healthProps.opponentIcon.bopAmount, healthProps.opponentIcon.scale * healthProps.opponentIcon.bopAmount, false)
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