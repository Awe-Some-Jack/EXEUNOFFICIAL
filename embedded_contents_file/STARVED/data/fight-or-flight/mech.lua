local fear = 0

function onCreatePost()
	makeLuaSprite('fearBar', 'starved/fearbar', 1194, 213.5)
	setObjectCamera('fearBar', 'hud')
	
	makeLuaSprite('fear', nil, 1230, 233.5)
	makeGraphic('fear', 12, 254, 'FF0000')
	setObjectCamera('fear', 'hud')

	makeLuaSprite('fearBarBG', 'starved/fearbarBG', 1194, 213.5)
	setObjectCamera('fearBarBG', 'hud')

	addLuaSprite('fearBarBG')
	addLuaSprite('fear')
	addLuaSprite('fearBar')
end

function onUpdatePost(e)
	setGraphicSize('fear', 12, lerp(1, 254, bound(fear / 100, 0, 1))) setProperty('fear.y', 213.5 + lerp(274, 20, bound(fear / 100, 0, 1)))
	if getHealth() >= 0.1 then addHealth(-((fear / 100) * 0.2) * e) end
end

function opponentNoteHit(id,nd,nt,isn) if isn then return end fear = fear + 0.15 end
function noteMiss(id,nd,nt,isn) if isn then return end fear = fear + 5 end
function noteMissPress() fear = fear + 5 end
function goodNoteHit(id,nd,nt,isn) if isn then return end fear = fear - 0.1 end

function lerp(a, b, t)
	return a + t * (b - a)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end