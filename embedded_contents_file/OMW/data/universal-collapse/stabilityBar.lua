local activeBar = false
function onCreatePost()
	makeLuaSprite('daBarUI', 'ui/stability')
	screenCenter('daBarUI', 'y')
	setProperty('daBarUI.x', screenWidth - getProperty('daBarUI.width') - 20)
	setObjectCamera('daBarUI', 'hud')

	makeLuaSprite('daBarBG')
	makeGraphic('daBarBG', 10, 418, '221164')
	callMethod('daBarBG.setPosition', {getProperty('daBarUI.x') + 28, getProperty('daBarUI.y') + 46})
	setObjectCamera('daBarBG', 'hud')

	makeLuaSprite('daBar')
	makeGraphic('daBar', 10, 418, '7474FF')
	callMethod('daBar.setPosition', {getProperty('daBarUI.x') + 28, getProperty('daBarUI.y') + 46})
	setObjectCamera('daBar', 'hud')
end

local savedNotesPos = {}
local target = 1
local thing = 0
function onUpdatePost(e)
	if activeBar then
		target = target - (e / 100)
		setGraphicSize('daBar', 10, lerp(1, 418, bound(target, 0, 1))) setProperty('daBar.y', getProperty('daBarUI.y') + 46 + lerp(418, 1, bound(target, 0, 1)))

		thing = thing + e * 2
		for i = 0,3 do
			callMethod('playerStrums.members['..i..'].setPosition', {
				savedNotesPos[i + 1].x + (math.sin(thing + i) * (1 - target) * 80) + getRandomFloat(-1,1) * (1 - target) * 5,
				savedNotesPos[i + 1].y + (math.cos(thing + i) * (1 - target) * 40) + getRandomFloat(-1,1) * (1 - target) * 5
			})
			setProperty('playerStrums.members['..i..'].angle', getRandomFloat(-1,1) * (1 - target) * 3)
			setProperty('playerStrums.members['..i..'].alpha', 1 - getRandomFloat(-0.5,0.5) * (1 - target))
		end
		setProperty('camHUD.alpha', 1 - getRandomFloat(0,0.85) * (1 - target))
		callMethod('camHUD.setPosition', {
			getRandomFloat(-1,1) * (1 - target) * 3,
			getRandomFloat(-1,1) * (1 - target) * 3
		})
		callMethod('camGame.setPosition', {
			getRandomFloat(-1,1) * (1 - target) * 3,
			getRandomFloat(-1,1) * (1 - target) * 3
		})
		setShaderFloat('cab', 'amount', 0.1 + (1 - target) * 0.5)
		setShaderFloat('ca2', 'amount', 0.15 + (1 - target) * 0.5)

		if target < 0 then setHealth(-2) end
	end
end

function opponentNoteHit(id,nd,nt,isn) if isn then return end if not activeBar then return end target = target - 0.0015 end
function noteMiss(id,nd,nt,isn) if isn then return end if not activeBar then return end target = target - 0.075 end
function noteMissPress() if activeBar then target = target - 0.005 end end
function goodNoteHit(id,nd,nt,isn) if isn then return end if not activeBar then return end target = target + 0.0015 end

function onEvent(n,v1)
	if n == 'omwEvents' then
		if v1 == 'xddd' then
			for i = 0,3 do savedNotesPos[i + 1] = {} savedNotesPos[i + 1].x = getProperty('playerStrums.members['..i..'].x') savedNotesPos[i + 1].y = getProperty('playerStrums.members['..i..'].y') end
			activeBar = true

			addLuaSprite('daBarBG', true)
			addLuaSprite('daBar', true)
			addLuaSprite('daBarUI', true)
		end
		if v1 == 'finalFlash' then activeBar = false end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function bound(number, min, max)
	return math.max(min, math.min(max, number))
end