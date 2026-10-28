local first = true

local introSubs = {
    {1.21, 3.56, "Who are you supposed to be?"},
    {6.50, 8.30, "You want to what?"},
    {9.25, 10.70, "Ugh.... Fine."},
    {11.00, 13.30, "Let's have some fun."},
}
local shownSub = 0

function introSubFont()
    local lang = getLanguage()
    if lang == 'ja-JP' then return 'japanese.ttf' end
    if lang == 'zh-CN' then return 'chinese.ttf' end
    if lang == 'ko-KR' then return 'korean.ttf' end
    if lang == 'pl-PL' or lang == 'hu-HU' or lang == 'tr-TR' then return 'ari-w9500-bold.ttf' end
    return 'vcr.ttf'
end

function hideIntroSub()
    if shownSub == 0 then return end
    removeLuaText('introSub', true)
    removeLuaSprite('introSubBG', true)
    shownSub = 0
end

function showIntroSub(i)
    hideIntroSub()
    local y = math.floor(screenHeight * 0.74)
    makeLuaText('introSub', getSongLyric('lyrics.sharpyshowdown.intro'..i, introSubs[i][3]), 0, 0, y)
    setTextFont('introSub', introSubFont())
    setTextSize('introSub', 25)
    setTextBorder('introSub', 2, '000000')
    setObjectCamera('introSub', 'other')
    setProperty('introSub.antialiasing', false)
    local w = getProperty('introSub.width')
    local h = getProperty('introSub.height')
    local x = math.floor((screenWidth - w) / 2)
    setProperty('introSub.x', x)
    makeLuaSprite('introSubBG', nil, x - 8, y - 4)
    makeGraphic('introSubBG', w + 16, h + 8, '000000')
    setProperty('introSubBG.alpha', 0.6)
    setObjectCamera('introSubBG', 'other')
    addLuaSprite('introSubBG')
    addLuaText('introSub')
    shownSub = i
end


function onCreate()
    if seenCutscene or not isStoryMode then return end

    precacheSound('introSong')
    addCharacterToList('exetior-intro', 'dad')

end

local _cut = false
function onSongStart() setProperty('cameraSpeed', 1) end
function onStartCountdown()
    if seenCutscene or not isStoryMode then return end
    if first then
        _cut = true
        playAnim('gf', 'danceRight', true)
        -- PROPERTIES --
        setProperty('camHUD.alpha', 0)
        setProperty('cameraSpeed', 999)
        callMethod('camGame.targetOffset.set', {-140, 140})
        setProperty('camGame.zoom', 0.8)
        -- TIMERS --
        runTimer('startIntro', 0.01)

        runTimer('tweenCamToBF', 3)

        runTimer('u!', 4.72)

        runTimer('tweenBackToExetior', 6.5)

        runTimer('tweenToExetior2', 9.5)

        runTimer('tweenToExetior3', 12.5)

        runTimer('startCountdown', 13.5)

        first = false
        return Function_Stop
    end
    _cut = false
end

function onUpdatePost()
    if _cut then
        if getProperty('gf.animation.curAnim.name') == 'danceLeft' and getProperty('gf.animation.curAnim.finished') then
            playAnim('gf', 'danceRight', true)
            if getProperty('boyfriend.animation.curAnim.name') == 'idle' then playAnim('boyfriend', 'idle', true) end
            runHaxeCode([[
                for (obj in PlayState.instance.members)
                {
                    if (obj != null && obj.ID != null && obj.ID == 123)
                    {
                        obj.animation.play('eggman', true);
                        break;
                    }
                }
            ]])
        end
        if getProperty('gf.animation.curAnim.name') == 'danceRight' and getProperty('gf.animation.curAnim.finished') then
            playAnim('gf', 'danceLeft', true)
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    local subOn = tag:match('^introSubOn(%d+)$')
    if subOn then showIntroSub(tonumber(subOn)) end
    local subOff = tag:match('^introSubOff(%d+)$')
    if subOff and shownSub == tonumber(subOff) then hideIntroSub() end
    if tag == 'startIntro' then
        playSound('introSong', 1, 'intro')
        for i, sub in ipairs(introSubs) do
            runTimer('introSubOn'..i, sub[1])
            runTimer('introSubOff'..i, sub[2])
        end
        triggerEvent('Change Character', 'dad', 'exetior-intro')
        playAnim('dad', 'intro')
    end
    if tag == 'tweenCamToBF' then
        doTweenX('camXTween', 'camGame.targetOffset', 450, 2, 'cubeInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 160, 2, 'cubeInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 1, 2, 'cubeInOut')
    end
    if tag == 'u!' then
        playAnim('boyfriend', 'singDOWN')
    end
    if tag == 'tweenBackToExetior' then
        doTweenX('camXTween', 'camGame.targetOffset', -140, 1.3, 'sineInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 120, 1.3, 'sineInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 0.85, 1.3, 'sineInOut')
    end
    if tag == 'tweenToExetior2' then
        doTweenX('camXTween', 'camGame.targetOffset', -140, 1, 'sineInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 150, 1, 'sineInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 1, 1, 'sineInOut')
    end

    if tag == 'tweenToExetior3' then
        doTweenX('camXTween', 'camGame.targetOffset', 0, 2, 'sineInOut')
        doTweenY('camYTween', 'camGame.targetOffset', 0, 2, 'sineInOut')
        doTweenZoom('camZoomCutscene', 'camGame', 0.85, 2, 'sineInOut')
    end
    if tag == 'startCountdown' then
        startCountdown()
        doTweenAlpha('HUDTween', 'camHUD', 1, 1)
    end
end

function onSoundFinished(tag)
    if tag == 'intro' then
        triggerEvent('Change Character', 'dad', 'exetior')
    end
end