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

    makeLuaText('songTimeTxt', '', 200, 10, 10)
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

    makeLuaSprite("brightness")
	setSpriteShader("brightness", "brightness")
    setShaderFloat('brightness', 'saturation', 1.25)
    setShaderFloat('brightness', 'brightness', -0.08)
	setShaderFloat('brightness', 'contrast', 1.2)

    makeLuaSprite("chromatic")
	setSpriteShader("chromatic", "chromatic")
    setShaderFloat('chromatic', 'amount', 1.5)
	
	runHaxeCode([[
        FlxG.camera.filters = [new ShaderFilter(game.getLuaObject("shaderHolder").shader), new ShaderFilter(game.getLuaObject("brightness").shader), new ShaderFilter(game.getLuaObject("chromatic").shader)];
        game.camHUD.filters = [new ShaderFilter(game.getLuaObject("shaderHolder").shader), new ShaderFilter(game.getLuaObject("brightness").shader), new ShaderFilter(game.getLuaObject("chromatic").shader)];
	]])
end

function onUpdate(e)
    local hp = math.floor(getProperty('health') * 50)
    local rating = ratingName ~= nil and ratingName or '...'
    setTextString(
        'statsTxt',
        'Health: ' .. hp .. '%\n' ..
        'Score: ' .. score .. '\n' ..
        'Misses: ' .. misses .. '\n' ..
        'Rating: ' .. rating
    )
    local songPos = math.floor(math.max(getSongPosition() / 1000, 0))
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
    
    setShaderFloat('brightness', 'saturation', lerp(getShaderFloat('brightness', 'saturation'), (getHealth() < 0.4 and 1.25 or 1), e * 5))
    setShaderFloat('brightness', 'brightness', lerp(getShaderFloat('brightness', 'brightness'), (getHealth() < 0.4 and -0.08 or 0), e * 5))
	setShaderFloat('brightness', 'contrast', lerp(getShaderFloat('brightness', 'contrast'), (getHealth() < 0.4 and 1.2 or 1), e * 5))
    setShaderFloat('chromatic', 'amount', lerp(getShaderFloat('chromatic', 'amount'), (getHealth() < 0.4 and 1.5 or 0), e * 5))
end

function lerp(a, b, t)
	return a + t * (b - a)
end