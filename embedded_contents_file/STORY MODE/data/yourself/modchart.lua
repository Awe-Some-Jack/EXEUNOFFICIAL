local movingNotes = {}

local function usesMobileLayout()
	if buildTarget ~= 'ios' and buildTarget ~= 'android' then return false end
	if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then return false end
	return getPropertyFromClass('backend.ClientPrefs', 'data.middlescrollType') == 'mobile' or getPropertyFromClass('backend.ClientPrefs', 'data.mobileOpponentNotes') == true
end

local function swapOpponentX(i)
	if usesMobileLayout() then
		return (screenWidth / 2) - (100 + (5 + getPropertyFromClass('objects.Note', 'swagWidth')) * (4 - i))
	end
	return _G['defaultOpponentStrumX'..i]
end

local function swapPlayerX(i)
	if usesMobileLayout() then
		return (screenWidth / 2) + (100 + (5 + getPropertyFromClass('objects.Note', 'swagWidth')) * i)
	end
	return _G['defaultPlayerStrumX'..i]
end

function onEvent(n,v1)
	if n == 'yourselfEvents' then
		if v1 == 'modchart1' then
			if usesMobileLayout() then
				for i = 0,3 do
					noteTweenY('noteoy'..i, i, _G['defaultPlayerStrumY'..i], crochet / 250, 'cubeIn')
					if i < 2 then noteTweenX('noteox'..i, i, swapOpponentX(i), crochet / 250, 'cubeIn') end
				end
			end
			for i = 0,3 do
				if i < 2 then
					noteTweenX('notep'..i, i + 4, swapOpponentX(i + 2), crochet / 250, 'cubeIn')
				else
					noteTweenX('notep'..i, i + 4, swapPlayerX(i - 2), crochet / 250, 'cubeIn')
					noteTweenX('noteo'..i, i, swapPlayerX(i), crochet / 250, 'cubeIn')
				end
			end
		end
		if v1 == 'modchart1dot5' then
			for i = 0,3 do
				if i < 2 then
					noteTweenX('noteo'..i, i, swapPlayerX(i + 2), crochet / 250, 'cubeIn')
					noteTweenX('notep'..i, i + 4, swapPlayerX(i), crochet / 250, 'cubeIn')
				else
					noteTweenX('noteo'..i, i, swapOpponentX(i), crochet / 250, 'cubeIn')
					noteTweenX('notep'..i, i + 4, swapOpponentX(i - 2), crochet / 250, 'cubeIn')
				end
			end
		end
		if v1 == 'modchart2' then
			for i = 0,7 do
				
				noteTweenX('notex'..i, i, getRandomBool() and screenWidth or (-getProperty('strumLineNotes.members['..i..'].width')), crochet / 260, 'cubeIn')
				noteTweenY('notey'..i, i, getRandomInt(downscroll and screenHeight or screenHeight/2, downscroll and screenHeight/2 or -getProperty('strumLineNotes.members['..i..'].height')), crochet / 260, 'cubeIn')
			end
		end
		if v1 == 'modchartstart' then
			for i = 0,7 do
				setProperty('strumLineNotes.members['..i..'].y',
					downscroll and (getRandomInt(screenHeight / 2, screenHeight - getProperty('strumLineNotes.members['..i..'].height')))
					or (getRandomInt(0, (screenHeight / 2) - getProperty('strumLineNotes.members['..i..'].height')))
				)
				if i < 4 then setProperty('strumLineNotes.members['..i..'].alpha', 0.3) end
			end
			runTimer('nextnote', crochet / 1000, 0)
			noteTweenAlpha('note'..i..'OP', i, 0.3, crochet / 250, 'cubeIn')
		end
		if v1 == 'endmodchart' then
			cancelTimer('nextnote')
			for i = 0,7 do
				cancelTween('xd'..i)
				setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)])
				setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)])
				if i < 4 then setProperty('strumLineNotes.members['..i..'].alpha', 1) end
			end
		end
	end
end

function onTimerCompleted(t)
	if t == 'nextnote' then
		local danote = getRandomInt(4,7)
		local danote2 = getRandomInt(0,3)
		if movingNotes[danote] ~= true then
			movingNotes[danote] = true

			local noteisleft = getProperty('strumLineNotes.members['..danote..'].x') < (screenWidth / 2)
			noteTweenX('xd'..danote, danote, noteisleft and screenWidth or (-getProperty('strumLineNotes.members['..danote..'].width')), getRandomFloat(2,2.4))
			local noteisleft = getProperty('strumLineNotes.members['..danote2..'].x') < (screenWidth / 2)
			noteTweenX('xd'..danote2, danote2, noteisleft and screenWidth or (-getProperty('strumLineNotes.members['..danote2..'].width')), getRandomFloat(2,2.4))
		end
	end
end

function onTweenCompleted(t)
	if stringStartsWith(t, 'xd') then
		local noteisleft = getProperty('strumLineNotes.members['..tonumber(t:sub(3))..'].x') < (screenWidth / 2)
		noteTweenX('xd'..tonumber(t:sub(3)), tonumber(t:sub(3)), noteisleft and screenWidth or (-getProperty('strumLineNotes.members['..tonumber(t:sub(3))..'].width')), getRandomFloat(2,2.4))

		setProperty('strumLineNotes.members['..t:sub(3)..'].y',
			downscroll and (getRandomInt(screenHeight / 2, screenHeight - getProperty('strumLineNotes.members['..t:sub(3)..'].height')))
			or (getRandomInt(0, (screenHeight / 2) - getProperty('strumLineNotes.members['..t:sub(3)..'].height')))
		)
	end
end