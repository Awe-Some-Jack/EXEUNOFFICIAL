function onCreatePost()
    setProperty('scoreTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('timeTxt.visible', false)

    local statsY = downscroll and 15 or 565
    local timeY = downscroll and 668 or 140
    local vhsY = downscroll and 0 or screenHeight - 100

    makeLuaText('statsTxt', '', 400, 15, statsY)
    setTextSize('statsTxt', 36)
    setTextAlignment('statsTxt', 'left')
    setTextFont('statsTxt', 'vcr.ttf')
    addLuaText('statsTxt')

    makeLuaText('songTimeTxt', '', 200, screenWidth - 215, timeY)
    setTextSize('songTimeTxt', 58)
    setTextAlignment('songTimeTxt', 'right')
    setTextFont('songTimeTxt', 'vcr.ttf')
    addLuaText('songTimeTxt')

    makeLuaText('vhsTxt', '', 600, screenWidth - 610, vhsY)
    setTextSize('vhsTxt', 50)
    setTextAlignment('vhsTxt', 'right')
    setTextFont('vhsTxt', 'vcr.ttf')
    addLuaText('vhsTxt')

	makeLuaSprite("shaderHolder")
	setSpriteShader("shaderHolder", "tvcrt")
	
	runHaxeCode([[
        FlxG.camera.filters = [new ShaderFilter(game.getLuaObject("shaderHolder").shader)];
        game.camHUD.filters = [new ShaderFilter(game.getLuaObject("shaderHolder").shader)];
	]])
end
function onUpdate()
    local hp = math.floor(getProperty('health') * 50)
    local rating = ratingName ~= nil and ratingName or '...'
    setTextString(
        'statsTxt',
        'Health: ' .. hp .. '%\n' ..
        'Score: ' .. score .. '\n' ..
        'Misses: ' .. misses .. '\n' ..
        'Rating: ' .. rating
    )
    local songPos = math.floor(getSongPosition() / 1000)
    local min = math.floor(songPos / 60)
    local sec = songPos % 60
    if sec < 10 then sec = '0' .. sec end
    setTextString('songTimeTxt', min .. ':' .. sec)

    local hour = tonumber(os.date("%H"))
    local minute = os.date("%M")
    local ampm = "A.M."

    if hour >= 12 then ampm = "P.M." end
    if hour > 12 then hour = hour - 12 end
    if hour == 0 then hour = 12 end
    if hour < 10 then hour = "0" .. hour end

    local month = string.upper(os.date("%b"))
    local day = os.date("%d")
    local year = 1995

    if downscroll then
    setTextString('vhsTxt',month .. ", " .. day .. ", " .. year .. "\n" ..hour .. ":" .. minute .. " " .. ampm)
     else
     setTextString('vhsTxt',hour .. ":" .. minute .. " " .. ampm .. "\n" ..month .. ". " .. day .. " " .. year)
     end
end