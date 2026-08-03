--Script by Raimbowcore12

local byeByeActivated = false

--CurStep doesn't work, so i'll repeat the event here with the byeByeActivated variable (Event script by Dudu)
local curText = {}
local curStringText = ''


function onEvent(e, v1, v2)
    if e == "triggerByeByeChance" then
        if byeByeActivated then
            setProperty("opponentVocals.volume", 0)
            playSound("DIGA-BYE-BYE", 1, "yes")
            runTimer("setVocalsBack", 8)
			triggerEvent('Play Animation', 'mispulmones', 'dad')

			runHaxeCode([[
				backend.EXEAchievements.unlock('byebye');
				backend.EXEAchievements.checkFinale();
				backend.EXEAchievements.save();
			]])
        end
    end
    if e == 'Normal Lyrics Bye-Bye' then
        if byeByeActivated then
            if v1 ~= '' then
                sepVar = stringSplit(v2, ',')
                if curStringText ~= v1 then
                    if curText[1] ~= nil then clearLyrics() end
                    for word in v1:gmatch("[^;]+") do table.insert(curText, word) end

                    local totalWidth = 0
                    local totalHeight = 0
				for i,word in ipairs(curText) do
					makeLuaText('__temp', word)
					setTextFont('__temp', (songPath == 'too-fest' and 'Comic Sans MS.ttf' or 'vcr.ttf'))
					setTextSize('__temp', 25)
					totalWidth = totalWidth + getProperty('__temp.width') - 2
					totalHeight = getProperty('__temp.height') + 8
					removeLuaText('__temp', true)
				end
				local curX = screenWidth / 2 - totalWidth / 2

				local bgtag = curText[1]:gsub('.', '')
				makeLuaSprite('lyricBG_'..bgtag, nil, curX, math.floor(screenHeight * 0.73))
				makeGraphic('lyricBG_'..bgtag, totalWidth, totalHeight, '000000')
				setProperty('lyricBG_'..bgtag..'.alpha', 0.6)
				setObjectCamera('lyricBG_'..bgtag, 'other')
				addLuaSprite('lyricBG_'..bgtag)

				for i,word in ipairs(curText) do
					local tag = 'lyric_'..(word:gsub('.', ''))..i
					makeLuaText(tag, word, 0, math.floor(curX))
					setTextSize(tag, 25)
					setTextFont(tag, (songPath == 'too-fest' and 'Comic Sans MS.ttf' or 'vcr.ttf'))
					setObjectCamera(tag, 'other')
					setProperty(tag..'.antialiasing', false)
					addLuaText(tag)
					setObjectOrder(tag, 100)
					curX = curX + getProperty(tag..'.width') - 2
					setObjectOrder(tag, getObjectOrder('lyricBG_'..curText[1]:gsub('.', '')) + i)
				end
			end

			for i,word in ipairs(curText) do
				local tag = 'lyric_'..(word:gsub('.', ''))..i
				setTextColor(tag, 'FFFFFF')
				setTextBorder(tag, 2, '000000')
				setProperty(tag..'.y',  math.floor(screenHeight * 0.74))
				if i == tonumber(sepVar[1]) then
					setTextColor(tag, (sepVar[2] == nil and getHealthColor('dad') or sepVar[2]))
					setTextBorder(tag, 2, darkColor(getHealthColor('dad')) and 'FFFFFF' or '000000')
					setProperty(tag..'.y', math.floor(screenHeight * 0.73))
				end
			end
			curStringText = v1
		else clearLyrics() end
        end
	end
end

local curKey = 1
local code = 'byebye'
function onUpdatePost(e)
    if curBeat < 272 then
        if keyboardJustPressed(code:sub(curKey, curKey):upper()) then
            curKey = curKey + 1
        end
        if curKey >= 7 then
            curKey = 0
            playSound('ringSound')
            byeByeActivated = true
        end
    end
end

function clearLyrics()
	removeLuaSprite('lyricBG_'..curText[1]:gsub('.', ''))
	for i,word in ipairs(curText) do
		removeLuaText('lyric_'..word:gsub('.', '')..i)
	end
	curText = {}
	curStringText = ''
end

function darkColor(hex) --thank to chat gpt ig??? sorry for using AI as a TOOL
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)

	local brightness = 0.299 * r + 0.587 * g + 0.114 * b

	return brightness < 128
end

function getHealthColor(arg)
	return string.format("%02x%02x%02x", math.floor(getProperty(arg..'.healthColorArray[0]')), math.floor(getProperty(arg..'.healthColorArray[1]')), math.floor(getProperty(arg..'.healthColorArray[2]')))
end

function onTimerCompleted(t)
    if t == "setVocalsBack" then byeByeActivated = false setProperty("opponentVocals.volume", 1) end
end


function onPause()   pauseSound("yes")  end

function onResume()  resumeSound("yes") end

function onDestroy() stopSound("yes")   end
