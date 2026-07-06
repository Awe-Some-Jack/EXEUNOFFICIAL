local size = 50
local font = ""



function onEvent(name, value1, value2)
    if name == 'Lyrics' then
        local split = stringSplit(value1, ',')
        local text = stringTrim(split[1])
        local alpha = tonumber(stringTrim(split[2]))
        local color = (stringTrim(split[3]))

        -- Making the text --  
        makeLuaText('LyricsTextEvent', text, 800, 250, 550)

        -- Adjusting the text --  
        setTextFont("LyricsTextEvent", font)
        setTextSize("LyricsTextEvent", size)
        setObjectCamera('LyricsTextEvent', 'camOther')
        setTextAlignment("LyricsTextEvent", 'center')
        setTextColor("LyricsTextEvent", color)
        setProperty('LyricsTextEvent.alpha', 0)
        doTweenAlpha('textop', 'LyricsTextEvent', alpha, 0.6)
        runTimer('text is DONE', value2)


        -- Adding the text --
        addLuaText('LyricsTextEvent')

    end
    function onTimerCompleted(tag)
        if tag == 'text is DONE' then
            doTweenAlpha('textop', 'LyricsTextEvent', 0, 0.6)
        end
    end
end