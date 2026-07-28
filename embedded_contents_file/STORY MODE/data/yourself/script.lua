function onCreatePost()
    for i = 0, 7 do setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') and 800 or -500) end

    local separation = 50
    for i = 0, 3 do
        setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('playerStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
        setProperty('opponentStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('opponentStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + ((getProperty('opponentStrums.members['..i..'].width')) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
    end
    for _, healthStuff in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do setProperty(healthStuff..'.alpha', 0) end
end

function onSongStart()
    for i = 0, 3 do
       noteTweenAlpha(i..'Alpha', i, 0, 0.001)
    end
    setProperty('BlackGraphicGame.alpha', 1)
end

function onUpdatePost()
    if curStep < 800 then
        for i = 0, getProperty('notes.length') - 1 do
            if getPropertyFromGroup('notes', i, 'mustPress') == false then
                setPropertyFromGroup('notes', i, 'alpha', 0)
            end
        end
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'yourselfEvents' then
        if value1 == 'startMiddleScroll' then
            for i = 0, 3 do
                noteTweenAlpha(i..'Alpha', i, 0, 0.001)
                if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') then
                    noteTweenY(i..'Tween', i, 570, 5 + (i * 0.5), 'smootherStepOut')
                else
                    noteTweenY(i..'Tween', i, 50, 5 + (i * 0.5), 'smootherStepOut')
                end
            end
            for i = 4, 7 do
                if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') then
                    noteTweenY(i..'Tween', i, 570, 3 + (i * 0.5), 'smootherStepOut')
                else
                    noteTweenY(i..'Tween', i, 50, 3 + (i * 0.5), 'smootherStepOut')
                end
            end
        end
        if value1 == 'revealYourself' then
            doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 0, 0.7)
            doTweenAlpha('dasdasd', 'camLeft', 1, 0.7)
            doTweenAlpha('sasdsas', 'camRight', 1, 0.7)

			if getProperty('videoCutscene') ~= nil then callMethod('remove', {instanceArg('videoCutscene')}) end
        end
        if value1 == 'fadeHUD' then
            if value2 == 'appear' then
                doTweenAlpha('camHUDAlpha', 'camHUD', 1, 1)
                for _, healthStuff in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do
                    doTweenAlpha(healthStuff..'Alpha', healthStuff, 1, 3)
                end
            elseif value2 == 'fuckyou' then
                for _, healthStuff in ipairs({'iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'exeScoreTxt'}) do
                    doTweenAlpha(healthStuff..'Alpha', healthStuff, 0, 1)
                end
            end
        end
        if value1 == 'fadeNotes' then
            for i = 4, 7 do
                noteTweenAlpha(i..'Alpha', i, 1, 3 + ((i - 4) * 0.5), 'smootherStepOut')
            end
        end
        if value1 == 'separateNotes' then
            for i = 0, 3 do
                noteTweenAlpha(i..'Alpha', i, 1, 3 + (i * 0.5), 'smootherStepOut')
                noteTweenX(i..'X' , i , _G['defaultOpponentStrumX'..i], 6 + (i * 0.2), 'backOut')
            end
            for i = 4, 7 do
                noteTweenX(i..'X' , i , _G['defaultPlayerStrumX'..(i - 4)], 6 + ((i - 4) * 0.2), 'backOut')
            end
        end
        if value1 == 'changeIcon' then runHaxeCode("game.getLuaObject('iconOpp').changeIcon('minilook');") end
        if value1 == 'setCamHUDAlpha' then setProperty('camHUD.alpha', value2) end -- literalmente hay un evento para esto en el chart editor. en qué coño piensas raimbow 😒
        if value1 == 'tweenCamHUDAlphaDown' then doTweenAlpha('camHUDAlpha', 'camHUD', value2, 0.65) end
        if value1 == 'fadeGameBro' then doTweenAlpha('BlackGraphicOtherAlpha', 'BlackGraphicOther', 1, 2) end
    end
end