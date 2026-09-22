local separation = 0
local notePos = {0,0,0,0}
local baseScale = {}

local function baseOf(group, i)
	return baseScale[group..i] or {0.7, 0.7}
end

local function homeY(group, i)
	return _G['default'..group..'StrumY'..i]
end

local function awayY(group, i)
	if homeY(group, i) < screenHeight / 2 then
		return screenHeight - getProperty(group:lower()..'Strums.members['..i..'].height') - 50
	end
	return 50
end

function onCreatePost()
	makeLuaSprite('separation')
end

function onCountdownStarted()
	for i = 0,3 do
		baseScale['opponent'..i] = {getProperty('opponentStrums.members['..i..'].scale.x'), getProperty('opponentStrums.members['..i..'].scale.y')}
		baseScale['player'..i] = {getProperty('playerStrums.members['..i..'].scale.x'), getProperty('playerStrums.members['..i..'].scale.y')}
	end
end

function onStartCountdown()
	if isMobile and getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') and (getPropertyFromClass('backend.ClientPrefs', 'data.middlescrollType') == 'mobile' or getPropertyFromClass('backend.ClientPrefs', 'data.mobileOpponentNotes')) then
		for i = 0,3 do
			setProperty('ooponentStrums.members['..i..'].visible',false);
		end
	end	
end

function onBeatHit()
	if (curBeat >= 228 and curBeat < 292) or (curBeat >= 356 and curBeat < 484) then
		cancelTween('separation')
		setProperty('separation.x', 50)
		doTweenX('separation', 'separation', 0, 0.5, 'cubeOut')
		for i = 0,3 do
			local pBase, oBase = baseOf('player', i), baseOf('opponent', i)
			cancelTween('jajajax'..i) cancelTween('jajajay'..i)
			scaleObject('playerStrums.members['..i..']', pBase[1] * ((curBeat % 2 == 0) and 1.25 or 0.7), pBase[2] * ((curBeat % 2 == 0) and 0.7 or 1.25), false)
			doTweenX('jajajax'..i, 'playerStrums.members['..i..'].scale', pBase[1], 0.5, 'cubeOut')
			doTweenY('jajajay'..i, 'playerStrums.members['..i..'].scale', pBase[2], 0.5, 'cubeOut')

			cancelTween('jajaja2x'..i) cancelTween('jajaja2y'..i)
			scaleObject('opponentStrums.members['..i..']', oBase[1] * ((curBeat % 2 == 0) and 1.25 or 0.7), oBase[2] * ((curBeat % 2 == 0) and 0.7 or 1.25), false)
			doTweenX('jajaja2x'..i, 'opponentStrums.members['..i..'].scale', oBase[1], 0.5, 'cubeOut')
			doTweenY('jajaja2y'..i, 'opponentStrums.members['..i..'].scale', oBase[2], 0.5, 'cubeOut')

			cancelTween('sjdasjd'..i) cancelTween('dasda'..i)
			setProperty('opponentStrums.members['..i..'].angle', (curBeat % 2 == 0) and -15 or 15)
			noteTweenAngle('sjdasjd'..i, i, 0, crochet / 1000, 'cubeOut')

			setProperty('playerStrums.members['..i..'].angle', (curBeat % 2 == 0) and -15 or 15)
			noteTweenAngle('dasda'..i, i + 4, 0, crochet / 1000, 'cubeOut')
		end
	end
end

function onEvent(n,v1)
	if n == 'mazinEvents' then
		if v1 == 'modchart1' then
			changeDirection('dad')
			for i = 0,3 do
				setProperty('opponentStrums.members['..i..'].y', awayY('Opponent', i))
				setProperty('opponentStrums.members['..i..'].alpha', 0.5)
			end
		end
		if v1 == 'modchart2' then
			revertDirection('bf')
			revertDirection('dad')
			for i = 0,3 do
				setProperty('opponentStrums.members['..i..'].y', homeY('Opponent', i))
				setProperty('opponentStrums.members['..i..'].alpha', 1)
				
				noteTweenX('oppnx'..i, i, _G['defaultOpponentStrumX'..i], 1, 'cubeOut')
				noteTweenX('plynx'..i, i + 4, _G['defaultPlayerStrumX'..i], 1, 'cubeOut')
			end
		end
		if v1 == 'swapnotes' then
			changeDirection('bf')
			revertDirection('dad')

			for i = 0,3 do
				noteTweenY('oppny'..i, i, homeY('Opponent', i), 0.2, 'cubeOut')
				noteTweenY('plyny'..i, i + 4, awayY('Player', i), 0.2, 'cubeOut')
			end
		end
		if v1 == 'swapnotestwo' then
			changeDirection('dad')
			revertDirection('bf')

			for i = 0,3 do
				noteTweenY('oppny'..i, i, awayY('Opponent', i), 0.2, 'cubeOut')
				noteTweenY('plyny'..i, i + 4, homeY('Player', i), 0.2, 'cubeOut')
			end
		end
	end
end

function onUpdatePost(e)
	if (curBeat >= 228 and curBeat < 292) or (curBeat >= 356 and curBeat < 484) then
		for i = 0,3 do
			setProperty('playerStrums.members['..i..'].x', lerp(getProperty('playerStrums.members['..i..'].x'),
				(screenWidth * (0.8 - (0.2 * (curBeat % 4)))) + (getProperty('separation.x') / 2) - (((getProperty('playerStrums.members['..i..'].width') + (getProperty('separation.x') * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + getProperty('separation.x') * 2.33) * i,
			e * 10))

			setProperty('opponentStrums.members['..i..'].x', lerp(getProperty('opponentStrums.members['..i..'].x'),
				(screenWidth * (0.8 - (0.2 * (3 - curBeat % 4)))) + (getProperty('separation.x') / 2) - (((getProperty('opponentStrums.members['..i..'].width') + (getProperty('separation.x') * 2)) * 4) / 2) + ((getProperty('opponentStrums.members['..i..'].width')) + getProperty('separation.x') * 2.33) * i,
			e * 10))
		end
	end
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function changeDirection(target)
	if target == 'dad' then
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
	elseif target == 'bf' then
		for i = 0,3 do setPropertyFromGroup('playerStrums', i, 'downScroll', not downscroll) end
		for i = 0,getProperty('notes.length')-1 do
			if getPropertyFromGroup('notes',i,'mustPress') then
				if getPropertyFromGroup('notes',i,'isSustainNote') then
					setPropertyFromGroup('notes',i,'flipY', not downscroll)
					setPropertyFromGroup('notes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
				end
				updateHitbox('notes.members['..i..']')
			end
		end
		for i = 0,getProperty('unspawnNotes.length')-1 do
			if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
				if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
					setPropertyFromGroup('unspawnNotes',i,'flipY', not downscroll)
					setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 56.204081 * (downscroll and 1 or 0))
				end
				updateHitbox('unspawnNotes['..i..']')
			end
		end
	end
end

function revertDirection(target)
	if target == 'dad' then
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
	elseif target == 'bf' then
		for i = 0,3 do setPropertyFromGroup('playerStrums', i, 'downScroll', downscroll) end
		for i = 0,getProperty('notes.length')-1 do
			if getPropertyFromGroup('notes',i,'mustPress') then
				if getPropertyFromGroup('notes',i,'isSustainNote') then
					setPropertyFromGroup('notes',i,'flipY', downscroll)
					setPropertyFromGroup('notes', i, 'correctionOffset', 56.204081 * (downscroll and 0 or 1))
				end
				updateHitbox('notes.members['..i..']')
			end
		end
		for i = 0,getProperty('unspawnNotes.length')-1 do
			if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
				if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
					setPropertyFromGroup('unspawnNotes',i,'flipY', downscroll)
					setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 56.204081 * (downscroll and 0 or 1))
				end
				updateHitbox('unspawnNotes['..i..']')
			end
		end
	end
end