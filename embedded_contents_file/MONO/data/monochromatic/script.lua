local ogNotesScale = {}
local scalesCaptured = false
local startMessingAround = false
local insaneModchart1 = false
local insaneModchart2 = false

function onCountdownStarted()
    --This doesn't work on the cutscene
    for i = 0, 3 do
		setPropertyFromGroup('opponentStrums', i, 'x', -500)
		setPropertyFromGroup('playerStrums', i, 'x', 1300)
	end
end

local function captureScales()
    if scalesCaptured then return end
    scalesCaptured = true
    for i = 0, 7 do
        ogNotesScale[i] = {getPropertyFromGroup('strumLineNotes', i, 'scale.x'), getPropertyFromGroup('strumLineNotes', i, 'scale.y')}
    end
end

local function restoreScales()
    if not scalesCaptured then return end
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'scale.x', ogNotesScale[i][1])
        setPropertyFromGroup('strumLineNotes', i, 'scale.y', ogNotesScale[i][2])
    end
end

function onEvent(eventName, value1)
    if eventName == 'monoEvents' then
        if value1 == 'monoNotesStart' then
            for i = 0, 3 do
                noteTweenX(i..'X' , i , _G['defaultOpponentStrumX'..i], 1 + (i * 0.2), 'backOut')
            end
        end
        if value1 == 'bfNotesStart' then
            for i = 4, 7 do
                noteTweenX(i..'X' , i , _G['defaultPlayerStrumX'..(i - 4)], 1 + ((i - 4) * 0.2), 'backOut')
            end
        end
        if value1 == 'messyModchart' then
            captureScales()
        end
        if value1 == 'messyModchart' and flashingLights then
            startMessingAround = true
            for _, e in ipairs({'iconBF', 'iconOpp', 'healthBar', 'healthBarBG'}) do
                setProperty(e..'.alpha', 0)
            end
        end
        if value1 == 'insaneModchart1' then
            captureScales()
            startMessingAround = false
            for _, e in ipairs({'iconBF', 'iconOpp', 'healthBar', 'healthBarBG'}) do
                setProperty(e..'.alpha', 1)
            end
            restoreScales()
            for i = 0,7 do
                setPropertyFromGroup('strumLineNotes', i, 'x', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumX'..(i % 4)])
                setPropertyFromGroup('strumLineNotes', i, 'y', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(i % 4)])
            end
            insaneModchart1 = true
        end
        if value1 == 'insaneModchart2' then
            startMessingAround = false
            insaneModchart2 = true
        end
        if value1 == 'stopModchart' then
            startMessingAround = false
            insaneModchart1 = false
            insaneModchart2 = false
            restoreScales()
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'x', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumX'..(i % 4)])
                setPropertyFromGroup('strumLineNotes', i, 'y', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(i % 4)])
            end
        end
    end
end


function onStepHit()
    if startMessingAround then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', getRandomInt(0, screenWidth * 2))
            setPropertyFromGroup('strumLineNotes', i, 'y', getRandomInt(50, 300))
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', getRandomFloat(0.5, 2))
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', getRandomFloat(0.5, 2))
        end
    end
    if insaneModchart2 then
        for i = 0, 7 do
            if curStep % 2 == 0 then
                setPropertyFromGroup('strumLineNotes', i, 'x', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] - 40)
                setPropertyFromGroup('strumLineNotes', i, 'y', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(i % 4)] + 40)
            else
                setPropertyFromGroup('strumLineNotes', i, 'x', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] + 40)
                setPropertyFromGroup('strumLineNotes', i, 'y', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(i % 4)] - 40)
            end
        end
    end
end

function onBeatHit()
    if insaneModchart1 then
        insaneModchart2 = false

        local notes = {0, 2, 4, 6}
        for _, i in ipairs(notes) do
            local n = i + (curBeat % 2 == 0 and 0 or 1)
            local n2 = i + (curBeat % 2 == 0 and 1 or 0)
            setPropertyFromGroup('strumLineNotes', n, 'y', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(n % 4)] + (downscroll and 20 or -20))
            noteTweenY('lolnote'..n, n, _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(n % 4)], 0.3 / playbackRate, 'circOut')
            setPropertyFromGroup('strumLineNotes', n2, 'y', _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(n2 % 4)] - (downscroll and 20 or -20))
            noteTweenY('lolnote'..n2, n2, _G['default'..(i > 3 and 'Player' or 'Opponent')..'StrumY'..(n2 % 4)], 0.3 / playbackRate, 'circOut')
        end
    end
end
