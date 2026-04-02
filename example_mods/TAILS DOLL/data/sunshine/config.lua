local intensity = 50
local velocity = 2

function onBeatHit()
	if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
		playAnim('boyfriend', 'idle', true)
	end
end

local dadX, dadY = 0, 0
function onCreatePost()
	dadX, dadY = getProperty('dad.x'), getProperty('dad.y')
end

local floatTime = 0
function onUpdate(e)
	floatTime = floatTime + e
	callMethod('dad.setPosition', {
		dadX + math.cos(floatTime * (velocity / 2)) * (intensity * 2),
		dadY + math.sin(floatTime * velocity) * intensity
	})
end