--[==[local modcharts = {
	[1] = function()
			for i = 0,3 do
				noteTweenX('noteX'..i, i, _G['defaultOpponentStrumX'..(3 - i)], 0.1, 'cubeOut')
				noteTweenY('noteY'..i, i, downscroll and 50 or 570, 0.1, 'cubeOut')
				changeDirection()
			end
		end,
	[2] = function()
			for i = 0,3 do
				noteTweenX('noteX'..i, i, _G['defaultPlayerStrumX'..(3 - i)], 0.1, 'cubeOut')
				noteTweenX('noteXP'..(i + 4), i + 4, _G['defaultOpponentStrumX'..(3 - i)], 0.1, 'cubeOut')
			end
		end,
	[3] = function()
			for i = 0,3 do
				noteTweenX('noteX'..i, i, _G['defaultOpponentStrumX'..(3 - i)], 0.1, 'cubeOut')
			end
		end,
	[4] = function()
			for i = 0,3 do
				noteTweenX('noteX'..i, i, _G['defaultOpponentStrumX'..i] + getRandomFloat(200, -200), 3, 'cubeOut')
				noteTweenY('noteY'..i, i, _G['defaultOpponentStrumY'..i] + getRandomFloat(200, -200), 3, 'cubeOut')
				noteTweenAngle('noteA'..i, i, getRandomFloat(50, -50), 3, 'cubeOut')
			end
		end,
	
	[5] = function()
			for i = 0,3 do
				cancelTween('noteX'..i)
				cancelTween('noteY'..i)
				cancelTween('noteA'..i)
				cancelTween('noteXP'..i)
				cancelTween('noteYP'..i)
				cancelTween('noteAP'..i)

				noteTweenX('noteX'..i, i, _G['defaultOpponentStrumX'..i], 0.1, 'cubeOut')
				noteTweenY('noteY'..i, i, _G['defaultOpponentStrumY'..i], 0.1, 'cubeOut')
				noteTweenAngle('noteA'..i, i, 0, 0.1, 'cubeOut')

				noteTweenY('noteYP'..(i + 4), i + 4, _G['defaultPlayerStrumY'..i], 0.1, 'cubeOut')
				noteTweenX('noteXP'..(i + 4), i + 4, _G['defaultPlayerStrumX'..i], 0.1, 'cubeOut')
				noteTweenAngle('noteAP'..(i + 4), i + 4, 0, 0.1, 'cubeOut')
				revertDirection()
			end
		end
}

local appear = false
local modchartstyle = 0
function onEvent(n)
	if n == 'ghhcselol' then
		appear = not appear
		if appear then
			modchartstyle = modchartstyle + 1
			modcharts[modchartstyle]()
		else modcharts[5]() end
	end
end

function changeDirection()
	for i = 0,3 do setPropertyFromGroup('opponentStrums', i, 'downScroll', not downscroll) end
	for i = 0,getProperty('notes.length')-1 do
		if not getPropertyFromGroup('notes',i,'mustPress') then
			if getPropertyFromGroup('notes',i,'isSustainNote') then
				setPropertyFromGroup('notes',i,'flipY', not downscroll)
				setPropertyFromGroup('notes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
			end
			updateHitbox('notes.members['..i..']')
		end
	end
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
				setPropertyFromGroup('unspawnNotes',i,'flipY', not downscroll)
				setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
			end
			updateHitbox('unspawnNotes['..i..']')
		end
	end
end

function revertDirection()
	for i = 0,3 do setPropertyFromGroup('opponentStrums', i, 'downScroll', downscroll) end
	for i = 0,getProperty('notes.length')-1 do
		if not getPropertyFromGroup('notes',i,'mustPress') then
			if getPropertyFromGroup('notes',i,'isSustainNote') then
				setPropertyFromGroup('notes',i,'flipY', downscroll)
				setPropertyFromGroup('notes', i, 'correctionOffset', 56.204081 * (downscroll and 0 or 1))
			end
			updateHitbox('notes.members['..i..']')
		end
	end
	for i = 0,getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
				setPropertyFromGroup('unspawnNotes',i,'flipY', downscroll)
				setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 56.204081 * (downscroll and 0 or 1))
			end
			updateHitbox('unspawnNotes['..i..']')
		end
	end
end]==]