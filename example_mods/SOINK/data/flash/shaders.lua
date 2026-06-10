local chromFreq = 2;
local chromAmount = 0.65;
local glitchIntensity = 0.4;
local activated = false;
local enabled = false;
local invertRN = false;
local invertRN2 = false;
local pixelChange = false;

-- luaDebugMode = true;

function updateCameraFilters()
    runHaxeCode([[
        var sexoShader = game.getLuaObject('sexo').shader;
        var glitchShader = game.getLuaObject('glitch').shader;
        var chromShader = game.getLuaObject('chromGraphic').shader;
        var invertShader = game.getLuaObject('invertGraphic').shader;
        var invertShader2 = game.getLuaObject('invertGraphic2').shader;
        var pixelShader = game.getLuaObject('pixel').shader;

        var gameFilters = [new ShaderFilter(sexoShader), new ShaderFilter(glitchShader), new ShaderFilter(pixelShader)];
        if (]] .. tostring(enabled) .. [[) {
            gameFilters.push(new ShaderFilter(chromShader));
        }
        if (]] .. tostring(invertRN) .. [[) {
            gameFilters.push(new ShaderFilter(invertShader));
        }
        game.camGame.filters = gameFilters;

        var hudFilters = [new ShaderFilter(game.getLuaObject('sexo2').shader), new ShaderFilter(glitchShader), new ShaderFilter(pixelShader)];
        if (]] .. tostring(invertRN2) .. [[) {
            hudFilters.push(new ShaderFilter(invertShader2));
        }
        game.camHUD.filters = hudFilters;
    ]])
end

function chromToggle(ye)
    if ye then
        if not activated then
            enabled = true
            activated = true
            updateCameraFilters()
        end
    else
        if activated then
            doTweenX('chromLol', 'chromX', 0, 0.25, 'linear')
			doTweenX('glitchLol', 'glitch', 0, 0.25, 'linear')
            activated = false
        end
    end
end

function doTheCoolChromEffect(v1, v2, v3)
    if v1 ~= '' and v1 ~= nil then
        chromAmount = tonumber(v1)
    end
    if v2 ~= '' and v2 ~= nil then
        chromFreq = tonumber(v2)
    end
	if v3 ~= '' and v3 ~= nil then
		glitchIntensity = tonumber(v3)
	end
    
    if chromAmount ~= 0 and chromAmount ~= nil and chromFreq ~= nil and chromFreq ~= 0 then
        chromToggle(true)
        setProperty('chromX.x', chromAmount)
		setProperty('glitch.x', glitchIntensity)
        doTweenX('chromLol', 'chromX', 0, 0.45, 'linear')
		doTweenX('glitchLol', 'glitch', 0, 0.45, 'linear')
    else
        chromToggle(false)
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if curStep >= 1276 and curStep < 1408 and noteType == 'Bug Note' then
    	doTheCoolChromEffect(2, 2, 0.2);
	elseif curStep >= 1408 and curStep < 1536 and noteType == 'Bug Note' then
    	doTheCoolChromEffect(3, 3, 0.6);
        triggerEvent('Screen Shake', '0.1, 0.005', '0.1, 0.005');
	end
end

function onStepHit()
    if curStep % 4 == 0 then
    end

	if curStep == 1308 or curStep == 1312 or curStep == 1340 or curStep == 1344 or curStep == 1372 or curStep == 1376  or curStep == 1442 or curStep == 1506 then
		invertToggle();
	end

	if curStep % 4 == 0 and curStep ~= 1468 then
		if curStep >= 1412 and curStep <= 1436 then
			invertToggle();
		end

		if curStep >= 1444 and curStep < 1504 then
			invertToggle();
		end

		if curStep >= 1508 and curStep < 1536 then
			invertToggle();
		end
	end

    if curStep == 1536 then
		-- invertToggle();
		setShaderFloat('glitch', "binaryIntensity", 0)
        enabled = false
        invertRN = false
        invertRN2 = false
		updateCameraFilters()
    end

    if curStep == 1720 then
        setShaderFloat('glitch', "binaryIntensity", 0.6);
    end

    if curStep == 1728 then
        setShaderFloat('glitch', "binaryIntensity", 0);
    end
end

function invertToggle()
    invertRN = not invertRN
    if curStep >= 1412 then
        invertRN2 = not invertRN
    else
        invertRN2 = invertRN
    end
    updateCameraFilters()
end

function onCreate()
    initLuaShader('glow')
    initLuaShader('individualGlitches')
    initLuaShader('invert')
    initLuaShader('ChromaticAbberation')
    initLuaShader('pixel')

    precacheImage('exeSplashes/noteSplashes-flash');
    precacheImage('exeSplashes/noteSplashes-flash2');
    precacheImage('exeSplashes/noteSplashes-flash3');
    precacheImage('exeSplashes/noteSplashesHOLD-flash');
    precacheImage('exeSplashes/noteSplashesHOLD-flash2');
    precacheImage('exeSplashes/noteSplashesHOLD-flash3');
    precacheImage('noteSkins/NOTE_assets_FLASH');
    precacheImage('noteSkins/NOTE_assets_FLASH2');
    precacheImage('noteSkins/NOTE_assets_FLASH3');
end

function onCreatePost()
    makeLuaSprite('sexo')
    setSpriteShader('sexo', 'brightness')
    setShaderFloat('sexo', 'saturation', 1)
    setShaderFloat('sexo', 'contrast', 1)

    makeLuaSprite('sexo2')
    setSpriteShader('sexo2', 'brightness')
    setShaderFloat('sexo2', 'saturation', 1)
    setShaderFloat('sexo2', 'contrast', 1)

    makeLuaSprite('glitch')
    setSpriteShader('glitch', 'individualGlitches')
    setShaderFloat('glitch', 'binaryIntensity', 0)

    makeLuaSprite('invertGraphic')
    setSpriteShader('invertGraphic', 'invert')

    makeLuaSprite('invertGraphic2')
    setSpriteShader('invertGraphic2', 'invert')

    makeLuaSprite('chromGraphic')
    setSpriteShader('chromGraphic', 'ChromaticAbberation')

    makeLuaSprite('pixel', nil, 0)
	setSpriteShader('pixel', 'pixel')
	setShaderFloat('pixel', 'pixelsize', 0)
    
    makeLuaSprite('chromX', nil, 0, 0)

    setProperty('sexo.y', 1);
    setProperty('sexo2.y', 1);
    setProperty('glitch.y', 1);
    
    if shadersEnabled and not lowQuality then
        updateCameraFilters()
    end
end

local tweening = false
local tweening2 = false
local tweening3 = false
local tweening4 = false

function onEvent(eventName, value1, value2)
    if eventName == "Change Character" then
        if value2 == 'bf-falling' or value2 == 'soink-falling' then
            setSpriteShader("dad", "glow")
            setShaderFloat("dad", "glowSize", 15.0)
            setShaderFloat("dad", "glowIntensity", 1)
            setShaderFloatArray("dad", 'glowColor', {0.0, 0.7, 0.0})

            setSpriteShader("boyfriend", "glow")
            setShaderFloat("boyfriend", "glowSize", 15.0)
            setShaderFloat("boyfriend", "glowIntensity", 1)
            setShaderFloatArray("boyfriend", 'glowColor', {0.0, 0.7, 0.0})
        end
    end

    if eventName == "bloomFlash" and flashingLights then
        local bloomValues = stringSplit(value1, ',')
        local tweenSettings = stringSplit(value2, ',')
        cancelTween('sexoX')
        cancelTween('sexoX2')
        setProperty('sexo.x', tonumber(bloomValues[1]))
        setProperty('sexo2.x', tonumber(bloomValues[1]))
        doTweenX('sexoX', 'sexo', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        doTweenX('sexoX2', 'sexo2', tonumber(bloomValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        tweening = true
    end

    if eventName == 'pixelshadertween' then
		pixelChange = true
        local boolDefault = stringSplit(value1, ',')
        local set = boolDefault[1]
        local fin = boolDefault[2]
        local valueZoom = stringSplit(value2, ',')
        local steps = valueZoom[1]
        local ease = valueZoom[2]
        cancelTween('pixel')
        setProperty('pixel.x', set)
        doTweenX('pixel', 'pixel', fin, steps, ease);
	end

    if eventName == "saturationFlash" and flashingLights then
        local satValues = stringSplit(value1, ',')
        local tweenSettings = stringSplit(value2, ',')
        cancelTween('sexoY')
        cancelTween('sexoY2')
        setProperty('sexo.y', tonumber(satValues[1]))
        setProperty('sexo2.y', tonumber(satValues[1]))
        doTweenY('sexoY', 'sexo', tonumber(satValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        doTweenY('sexoY2', 'sexo2', tonumber(satValues[2]), tonumber(tweenSettings[1]), tweenSettings[2])
        tweening4 = true
    end
end

function onUpdate(e)
    setShaderFloat("invertGraphic", "iTime", os.clock())
    setShaderFloat("invertGraphic2", "iTime", os.clock())
    
    if enabled then
        setShaderFloat('chromGraphic', "amount", getProperty('chromX.x'))
		setShaderFloat('glitch', "binaryIntensity", getProperty('glitch.x'))
        if not activated and chromAmount == 0 and getProperty('chromX.x') <= 0 then
            enabled = false
            updateCameraFilters()
        end
    end
end

local thing = 0;
function onUpdatePost(e)
    thing = thing + e
    setShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
    setShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))

    setShaderFloat('sexo2', 'brightness', getProperty('sexo2.x') * 2)
    setShaderFloat('sexo2', 'contrast', 1 + (getProperty('sexo2.x') * 4))

    setShaderFloat('sexo', 'saturation', getProperty('sexo.y'))
    setShaderFloat('sexo2', 'saturation', getProperty('sexo2.y'))

    if pixelChange then
		setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
	end
end

function onTweenCompleted(t)
    if t == 'sexoX' then
        tweening = false
    end
    if t == 'sexoY' then
        tweening4 = false;
    end
    if t == 'pixel' then
        pixelChange = false
    end
end