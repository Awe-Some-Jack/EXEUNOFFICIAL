local function killMainHUD()
	callMethod('healthBar.kill')
	callMethod('iconP1.kill')
	callMethod('iconP2.kill')
	callMethod('scoreTxt.kill')
end

function onCreatePost()
	killMainHUD()
	
	makeLuaSprite('healthbaromw', 'ui/omwhealth')
	setObjectCamera('healthbaromw', 'hud')
	setProperty('healthbaromw.x', 100)
	screenCenter('healthbaromw', 'y')
	setProperty('healthbaromw.y', getProperty('healthbaromw.y') - 20)
	addLuaSprite('healthbaromw')

	makeLuaSprite('hbHealth', nil, getProperty('healthbaromw.x') + 16, getProperty('healthbaromw.y') + 94)
    setObjectCamera('hbHealth', 'hud')
    makeGraphic('hbHealth', 14, 468, 'FFFFFF')

    makeLuaSprite('hbHealth2', nil, getProperty('healthbaromw.x') + 16, getProperty('healthbaromw.y') + 94)
    setObjectCamera('hbHealth2', 'hud')
    makeGraphic('hbHealth2', 14, 468 / 2, 'FFFFFF')

	makeLuaSprite('separatorHealth', nil, getProperty('healthbaromw.x') + 16, getProperty('healthbaromw.y') + 17)
    makeGraphic('separatorHealth', 14, 4, 'FFFFFF')
    setObjectCamera('separatorHealth', 'hud')

	createInstance('iconBF', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), true})
    setObjectCamera('iconBF', 'hud')

    createInstance('iconOpp', 'objects.HealthIcon', {getProperty('dad.healthIcon'), false})
    setObjectCamera('iconOpp', 'hud')

	setProperty('hbHealth.color', getColorFromHex(getHealthColor('boyfriend')))
    setProperty('hbHealth2.color', getColorFromHex(getHealthColor('dad')))

	addLuaSprite('hbHealth')
    addLuaSprite('hbHealth2')
    addLuaSprite('separatorHealth')
	setObjectOrder('healthbaromw', getObjectOrder('separatorHealth'))
    addInstance('iconBF')
    addInstance('iconOpp')

    setProperty('iconBF.alpha', 0)
	setProperty('iconOpp.alpha', 0)
	setProperty('hbHealth.alpha', 0)
	setProperty('hbHealth2.alpha', 0)
	setProperty('separatorHealth.alpha', 0)
	setProperty('healthbaromw.alpha', 0)
end

local lerpHealth = 1
function onUpdatePost(e)
    lerpHealth = lerp(getHealth(), lerpHealth, math.exp(-e * 12 * playbackRate))

    setProperty('iconOpp.x', getProperty('healthbaromw.x') + (getProperty('healthbaromw.width') - 150) / 2)
    setProperty('iconOpp.y', getProperty('healthbaromw.y') + 92 - 75 - 20)
    setProperty('iconBF.x', getProperty('healthbaromw.x') + (getProperty('healthbaromw.width') - 150) / 2 - 15)
    setProperty('iconBF.y', getProperty('healthbaromw.y') + 92 + 468 - 75 + 20)

    setGraphicSize('hbHealth2', 14, bound(lerp(468, 1, lerpHealth / 2), 1, 468))
    setProperty('separatorHealth.y', getProperty('healthbaromw.y') + 94 + bound(lerp(464, 0, lerpHealth / 2), 0, 464))

    setProperty('iconBF.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconOpp.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
    local mult = lerp(1, getProperty('iconOpp.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconOpp', mult, mult, false)
    local mult = lerp(1, getProperty('iconBF.scale.x'), math.exp(-e * 9 * playbackRate)) scaleObject('iconBF', mult, mult, false)
end

function onBeatHit()
	scaleObject('iconBF', 1.2, 1.2, false)
    scaleObject('iconOpp', 1.2, 1.2, false)
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function getHealthColor(arg)
	return string.format("%02x%02x%02x", math.floor(getProperty(arg..'.healthColorArray[0]')), math.floor(getProperty(arg..'.healthColorArray[1]')), math.floor(getProperty(arg..'.healthColorArray[2]')))
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end