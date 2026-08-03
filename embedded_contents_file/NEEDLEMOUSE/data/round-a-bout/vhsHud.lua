function onCreatePost()
    makeLuaText('statsTxt', 'Score: 0\nMisses: 0', screenWidth / 2 - 40)
    setTextSize('statsTxt', 36)
    callMethod('statsTxt.setPosition', {20, downscroll and 20 or (screenHeight - getProperty('statsTxt.height') - 20)})
    setTextAlignment('statsTxt', 'left')
    setTextFont('statsTxt', 'vcr.ttf')
    addLuaText('statsTxt')

    makeLuaText('vhsTxt', 'Score: 0\nMisses: 0', screenWidth / 2 - 40)
    setTextSize('vhsTxt', 36)
    callMethod('vhsTxt.setPosition', {screenWidth - getProperty('vhsTxt.width') - 20, downscroll and 20 or (screenHeight - getProperty('vhsTxt.height') - 20)})
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

function onUpdatePost(e)
    setTextString('statsTxt', 'Score: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatMoney', {score, false})..'\nMisses: '..misses)

    local hour = tonumber(os.date("%H"))
    local ampm = hour >= 12 and "P.M." or "A.M."

    hour = hour % 12
    if hour == 0 then hour = 12 end

    setTextString('vhsTxt', downscroll and string.format("%s, %s, 1995\n%02d:%s %s", os.date("%b"):upper(), os.date("%d"),  hour, os.date("%M"), ampm) or string.format("%02d:%s %s\n%s. %s 1995", hour, os.date("%M"), ampm, os.date("%b"):upper(), os.date("%d"))
    )

    setShaderFloat('brightness', 'saturation', lerp(getShaderFloat('brightness', 'saturation'), (getHealth() < 0.4 and 1.25 or 1), e * 5))
    setShaderFloat('brightness', 'brightness', lerp(getShaderFloat('brightness', 'brightness'), (getHealth() < 0.4 and -0.08 or 0), e * 5))
	setShaderFloat('brightness', 'contrast', lerp(getShaderFloat('brightness', 'contrast'), (getHealth() < 0.4 and 1.2 or 1), e * 5))
    setShaderFloat('chromatic', 'amount', lerp(getShaderFloat('chromatic', 'amount'), (getHealth() < 0.4 and 1.5 or 0), e * 5))
end

function lerp(a, b, t)
	return a + t * (b - a)
end