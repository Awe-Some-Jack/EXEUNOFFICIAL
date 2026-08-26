local activated = false;
local enabled = false;
local invertRN = false;
local invertRN2 = false;
local dadFrame = 0;

-- luaDebugMode = true;

function updateCameraFilters()
    --debugPrint('updated');

    runHaxeCode([[
        var sexoShader = game.getLuaObject('sexo').shader;
        var glitchShader = game.getLuaObject('glitch').shader;
        var chromShader = game.getLuaObject('chromGraphic').shader;
        var invertShader = game.getLuaObject('invertGraphic').shader;
        var invertShader2 = game.getLuaObject('invertGraphic2').shader;
        var pixelShader = game.getLuaObject('pixel').shader;
        var glihShader = game.getLuaObject('glih').shader;

        var gameFilters = [new ShaderFilter(sexoShader), new ShaderFilter(glitchShader), new ShaderFilter(pixelShader), new ShaderFilter(glihShader), new ShaderFilter(chromShader)];
        if (]] .. tostring(enabled) .. [[) {
            
        }
        if (]] .. tostring(invertRN) .. [[) {
            gameFilters.push(new ShaderFilter(invertShader));
        }
        game.camGame.filters = gameFilters;

        var hudFilters = [new ShaderFilter(game.getLuaObject('sexo2').shader), new ShaderFilter(glitchShader), new ShaderFilter(pixelShader), new ShaderFilter(glihShader)];
        if (]] .. tostring(invertRN2) .. [[) {
            hudFilters.push(new ShaderFilter(invertShader2));
        }
        game.camHUD.filters = hudFilters;
    ]])
end

-- function onStepHit()
--     if curStep == 80 then
--         updateCameraFilters()
--     end
-- end

function invertToggle()
    invertRN = not invertRN
    invertRN2 = invertRN
    updateCameraFilters()
end

function onCreate()
    initLuaShader('individualGlitches')
    initLuaShader('invert')
    initLuaShader('ChromaticAbberation')
    initLuaShader('pixel')
    initLuaShader('pseudo')
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

	makeLuaSprite('glih')
	setSpriteShader('glih', 'pseudo')
	setShaderFloat('glih', 'sort', 0)

    makeLuaSprite('glitch')
    setSpriteShader('glitch', 'individualGlitches')
    setShaderFloat('glitch', 'binaryIntensity', 0.0000001)

    makeLuaSprite('invertGraphic')
    setSpriteShader('invertGraphic', 'invert')

    makeLuaSprite('invertGraphic2')
    setSpriteShader('invertGraphic2', 'invert')

    makeLuaSprite('chromGraphic')
    setSpriteShader('chromGraphic', 'ChromaticAbberation')

    makeLuaSprite('pixel', nil, 0)
	setSpriteShader('pixel', 'pixel')
	setShaderFloat('pixel', 'pixelsize', 0)

    setProperty('sexo.y', 1);
    setProperty('sexo2.y', 1);
    setProperty('glitch.x', 0.0000001);
end

local tweening = false
local tweening2 = false
local tweening3 = false
local tweening4 = false

function onGameOver()
    pixelChange = true;
    enabled = true;
end

function onUpdate(e)
    dadFrame = getProperty('dad.animation.curAnim.curFrame');
    if dadName == 'lord x p3scream' then
        if dadFrame == 0 then
            if not enabled then
                enabled = true;
                updateCameraFilters()
            end
            doTweenX('glihT', 'glih', 0.5, 0.3, 'smootherStepOut');
            doTweenX('glitchT', 'glitch', 2, 0.3, 'smootherStepOut');
        elseif dadFrame == 25 then
            setProperty('glih.x', 0);
            setProperty('glitch.x', 0.00001);
        elseif dadFrame == 55 then
            setProperty('glih.x', 0.5);
            setProperty('glitch.x', 2);
            doTweenX('chromT', 'chromGraphic', 0.45, 2.1, 'smootherStepIn')
        elseif dadFrame == 92 then
            doTweenX('glihT', 'glih', 1.5, 0.78, 'linear')
            doTweenX('pixelT', 'pixel', 15, 0.78, 'linear')
            doTweenColor('dadColor', 'dad', 'FF0000', 0.78, 'linear')
        elseif dadFrame == 117 then
            doTweenColor('dadColor', 'dad', 'FFFFFF', 0.00001, 'linear')
            setProperty('glih.x', 0.3);
            setProperty('pixel.x', 0.1);
        elseif dadFrame == 125 then
            setProperty('glitch.x', 4)
        elseif dadFrame == 131 then
            setProperty('glitch.x', 2)
        elseif dadFrame == 139 then
            setProperty('glitch.x', 6)
        elseif dadFrame == 144 then
            setProperty('glitch.x', 4)
        elseif dadFrame == 161 then
            setProperty('glitch.x', 3)
            doTweenColor('dadColor', 'dad', 'FF0000', 0.00001, 'linear')
            if not activated then
                activated = true;
                invertToggle();
            end
        elseif dadFrame == 185 then
            setProperty('glitch.x', 2)
            doTweenColor('dadColor', 'dad', 'FFFFFF', 0.00001, 'linear')
            if activated then
                activated = false;
                invertToggle();
            end
        elseif dadFrame == 256 then
            setProperty('glitch.x', 0.3)
        elseif dadFrame == 282 then
            doTweenX('glihT', 'glih', 1.2, 0.3, 'smootherStepIn')
        elseif dadFrame == 292 then
            setProperty('glih.x', 0.3)
            doTweenX('chromT', 'chromGraphic', 2, 1.3, 'smootherStepIn')
            doTweenX('pixelT', 'pixel', 10, 1.3, 'smootherStepIn')
        elseif dadFrame == 326 then
            setProperty('chromGraphic.x', 0.3);
            setProperty('pixel.x', 0.000001);
            setProperty('glitch.x', 0.05)
        elseif dadFrame == 363 then
            -- doTweenX('pixelT', 'pixel', 10, 3.5, 'smootherStepOut')
            doTweenX('glih', 'glih', 2, 6, 'smootherStepInOut')
            doTweenAlpha('dadA', 'dad', 0, 3, 'smootherStepInOut')
        end
    end

    setShaderFloat("invertGraphic", "iTime", os.clock())
    setShaderFloat("invertGraphic2", "iTime", os.clock())
    
    setShaderFloat('chromGraphic', "amount", getProperty('chromGraphic.x'))
    setShaderFloat('glitch', "binaryIntensity", getProperty('glitch.x'))
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

    setShaderFloat('glih', 'sort', getProperty('glih.x'))

    setShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
end