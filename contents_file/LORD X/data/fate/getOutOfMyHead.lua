local voices = {'g', 'i', 'v', 'e', '', 'u', 'p'}
local startMoving = false
function onEvent(n, v1, v2)
    if n == 'fateEvents' then
        if v1 == 'theVoices' then
            startMoving = true
            for i = 1, #voices do
                for letraIndex in ipairs(voices) do
                    local customTag = 'letra_'..letraIndex..'_'..i
                    doTweenAlpha(customTag..'Alpha', customTag, 0.5, 1 + (i * letraIndex) * 0.5)
                    doTweenX(customTag..'TweenX', customTag, getProperty(customTag..'.x') + 500, 20 + (i * 5))
                    if v2 == 'remove' then
                        doTweenAlpha(customTag..'AlphaEnd', customTag, 0, 1 + (i * letraIndex) * 0.2)
                    end
                end
            end
        end
    end
end

local baseequis = {}

function onCreatePost()
    for i = 1, #voices + 2 do
        if baseequis[i] == nil then
            baseequis[i] = getRandomInt(-300, 800)
        end

        for letraIndex, letraChar in ipairs(voices) do
            local spacing = 60
            local customTag = 'letra_'..letraIndex..'_'..i

            makeLuaText(customTag, letraChar, 0, baseequis[i] + (letraIndex - 1) * spacing, -550 + (i * 230))

            setTextSize(customTag, 50)
            setObjectCamera(customTag, 'camGame')
            setObjectOrder(customTag, getObjectOrder('boyfriendGroup'))
            setTextFont(customTag, 'sonic-roco.ttf')
            setProperty(customTag..'.alpha', 0)
            addLuaText(customTag)
        end
    end
end


local holdShit = 0
function onUpdate(elapsed)
    holdShit = holdShit + elapsed
    for i = 1, #voices do
        for letraIndex in pairs(voices) do
            local customTag = 'letra_'..letraIndex..'_'..i
            if startMoving and luaTextExists(customTag) then
                setProperty(customTag..'.y', getProperty(customTag..'.y') + math.sin(holdShit + letraIndex) * 0.1)
                setProperty(customTag..'.x', getProperty(customTag..'.x') + math.sin(holdShit + 0.5) * 0.1)
            end
        end
    end
end

function onTweenCompleted(tag)
    for i = 1, #voices do
        for letraIndex in ipairs(voices) do
            local customTag = 'letra_'..letraIndex..'_'..i
            if tag == customTag..'AlphaEnd' then
                removeLuaSprite(customTag, true)
            end
            if tag == 'letra_7_7AlphaEnd' then
                startMoving = false
            end
        end
    end
end