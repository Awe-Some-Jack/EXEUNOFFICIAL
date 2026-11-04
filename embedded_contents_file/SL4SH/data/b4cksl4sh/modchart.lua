local FLIP_SPEED = 0.5
local SUSTAIN_UPSCROLL_OFFSET = 56.204081

local triggerChangeNotesOnce = false
local triggerChangeNotesTwice = false
local restY = {}
local sl4shModchart = {
    ['beginModchart'] = function()
        for i = 0,3 do
            restY[i] = getPropertyFromGroup('playerStrums', i, 'y')
            doTweenX('notePlayer'..i..'TweenStart', 'playerStrums.members['..i..']', (screenWidth / 2) + (50 / 2) - (((getProperty('playerStrums.members['..i..'].width') + (50 * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + 50 * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i, 2 / playbackRate, 'circInOut')
        end
    end,
    ['goDown'] = function()
        triggerChangeNotesOnce = true
        for i = 0,3 do
            doTweenY('notePlayer'..i..'DownScroll1', 'playerStrums.members['..i..']', 330, 0.5 / playbackRate, 'circOut')
        end
    end,
    ['restore'] = function()
        triggerChangeNotesTwice = true
        if downscroll then setDownscroll() else setUpscroll() end
        for i = 0,3 do
            if restY[i] ~= nil then
                doTweenY('notePlayer'..i..'Restore', 'playerStrums.members['..i..']', restY[i], 0.5 / playbackRate, 'circInOut')
            end
        end
    end,
    ['goUp'] = function()
        triggerChangeNotesOnce = true
        for i = 0,3 do
            doTweenY('notePlayer'..i..'UpScroll1', 'playerStrums.members['..i..']', 150, 0.5 / playbackRate, 'circOut')
        end
    end,
}

function onUpdatePost(e)
    if triggerChangeNotesOnce then
        triggerChangeNotesOnce = false
        --[[
        for i = 4, 7 do
            setPropertyFromGroup('notes', i, 'multSpeed', lerp(getPropertyFromGroup('notes', i, 'multSpeed'), -0.5, 0.5))
            setPropertyFromGroup('unspawnNotes', i, 'multSpeed', lerp(getPropertyFromGroup('unspawnNotes', i, 'multSpeed'), -0.5, 0.5))
        end
        ]]

        triggerEvent('Change Scroll Speed', tostring(FLIP_SPEED), tostring(0.5 / playbackRate))
    end
    if triggerChangeNotesTwice then
        triggerChangeNotesTwice = false
        --[[
        for i = 4, 7 do
            setPropertyFromGroup('notes', i, 'multSpeed', lerpOut(getPropertyFromGroup('notes', i, 'multSpeed'), 1, 0.5))
            setPropertyFromGroup('unspawnNotes', i, 'multSpeed', lerpOut(getPropertyFromGroup('unspawnNotes', i, 'multSpeed'), 1, 0.5))
        end
        ]]
        triggerEvent('Change Scroll Speed', "1", tostring(0.5 / playbackRate))
    end
end

function onTweenCompleted(tag)
    if tag:find("UpScroll1") then
        triggerChangeNotesTwice = true
        setUpscroll()
        for i = 0,3 do
            doTweenY('notePlayer'..i..'UpScroll2', 'playerStrums.members['..i..']', 50, 0.5 / playbackRate, 'circInOut')
        end
    end
    if tag:find("DownScroll1") then
        triggerChangeNotesTwice = true
        setDownscroll()
        for i = 0,3 do
            doTweenY('notePlayer'..i..'DownScroll2', 'playerStrums.members['..i..']', 450, 0.5 / playbackRate, 'circInOut')
        end
    end
end

function lerp(s, e, t)
    return s + (e - s) * math.min(t, 1)
end

function lerpOut(s, e, t)
    t = math.max(0, math.min(t, 1))
    t = t * t * (3 - 2 * t)
    return s + (e - s) * t
end

function onEvent(e, v1)
    if e == 'sl4shModchart' then
        sl4shModchart[v1]()
    end
end

function setUpscroll()
	for i = 0, 3 do setPropertyFromGroup('playerStrums', i, 'downScroll', false) end
	for i = 0, getProperty('notes.length')-1 do
		if getPropertyFromGroup('notes',i,'mustPress') then
			if getPropertyFromGroup('notes',i,'isSustainNote') then
				setPropertyFromGroup('notes', i, 'flipY', false)
				setPropertyFromGroup('notes', i, 'correctionOffset', SUSTAIN_UPSCROLL_OFFSET)
			end
			updateHitbox('notes.members['..i..']')
		end
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
				setPropertyFromGroup('unspawnNotes',i,'flipY', false)
				setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', SUSTAIN_UPSCROLL_OFFSET)
			end
			updateHitbox('unspawnNotes['..i..']')
		end
	end
end

function setDownscroll()
	for i = 0, 3 do setPropertyFromGroup('playerStrums', i, 'downScroll', true) end
	for i = 0, getProperty('notes.length')-1 do
		if getPropertyFromGroup('notes',i,'mustPress') then
			if getPropertyFromGroup('notes',i,'isSustainNote') then
				setPropertyFromGroup('notes', i, 'flipY', true)
				setPropertyFromGroup('notes', i, 'correctionOffset', 0)
			end
			updateHitbox('notes.members['..i..']')
		end
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
			if getPropertyFromGroup('unspawnNotes',i,'isSustainNote') then
				setPropertyFromGroup('unspawnNotes',i,'flipY', true)
				setPropertyFromGroup('unspawnNotes', i, 'correctionOffset', 0)
			end
			updateHitbox('unspawnNotes['..i..']')
		end
	end
end