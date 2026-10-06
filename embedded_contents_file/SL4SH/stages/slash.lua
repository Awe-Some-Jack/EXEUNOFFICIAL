function onCreatePost()
	addCharacterToList('sl4shfront', 'dad')

	setProperty('hbBG.alpha', 0)
	setProperty('hbHealth.alpha', 0)
	setProperty('hbHealth2.alpha', 0)
	setProperty('healthBG.alpha', 0)
	
	makeLuaSprite('bghb',  'pixelUI/hud/hbBG', 0, 0)
	setObjectCamera('bghb', 'camHUD')
	scaleObject('bghb', 2.5, 2.5)
	makeLuaSprite('leftBar',  'pixelUI/hud/bar1', 0, 0)
	makeLuaSprite('rightBar', 'pixelUI/hud/bar2', 0, 0)
	setObjectCamera('leftBar', 'camHUD') setObjectCamera('rightBar', 'camHUD')
	setObjectOrder('leftBar', getObjectOrder('separatorHealth')) setObjectOrder('rightBar', getObjectOrder('separatorHealth'))
	callMethod('leftBar.setPosition',  {getProperty('hbHealth.x'), getProperty('hbHealth.y')})
	callMethod('bghb.setPosition',  {getProperty('hbHealth.x') - 4, getProperty('hbHealth.y') - 42.5})
	callMethod('rightBar.setPosition', {getProperty('hbHealth2.x'), getProperty('hbHealth2.y')})
	setProperty('leftBar.antialiasing', false)
	setProperty('bghb.antialiasing', false)
	setProperty('rightBar.antialiasing', false)
	addLuaSprite('leftBar') addLuaSprite('rightBar')
	setObjectOrder('bghb', getObjectOrder('leftBar') - 1)
end

function onEvent(n)
	if n ~= 'slashchangeBG' then return end

	setProperty('boyfriend.visible', false)
	setProperty('dad.y', getProperty('dad.y') - 150)
	triggerEvent('Change Character', 'dad', 'sl4shfront')
end


local lerpHealth = 1
function onUpdatePost(e)
	lerpHealth = lerp(getHealth(), lerpHealth, math.exp(-e * 12 * playbackRate))
	setGraphicSize('rightBar', bound(lerpHealth, 0, 2) * ((601 - 10) / 2), 25 - 10)
	setGraphicSize('leftBar',  bound(2 - lerpHealth, 0.1, 2) * ((601 - 10) / 2), 25 - 10)
	setProperty('rightBar.x', getProperty('leftBar.x') + getProperty('leftBar.width'))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end