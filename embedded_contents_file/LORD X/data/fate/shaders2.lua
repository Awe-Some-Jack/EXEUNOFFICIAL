local activated = false;
local invertRN = false;
local dadFrame = 0;

-- luaDebugMode = true;

local shaderSent = {}
local function sendShaderFloat(obj, uniform, value)
    local key = obj..'.'..uniform
    if shaderSent[key] ~= value then
        shaderSent[key] = value
        setShaderFloat(obj, uniform, value)
    end
end

function invertToggle()
    if shadersEnabled then 
        invertRN = not invertRN
        setStaticFilterActive('camGame', 'invertGraphic', invertRN)
        setStaticFilterActive('camHUD', 'invertGraphic2', invertRN)
    end
end

function onCreate()
    if shadersEnabled then 
        initLuaShader('individualGlitches')
        initLuaShader('invert')
        initLuaShader('ChromaticAbberation')
        initLuaShader('pixel')
        initLuaShader('pseudo')
    end
end

function onCreatePost()
    if shadersEnabled then
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

        local neutrals = {
            sexo = {brightness = 0, contrast = 1, saturation = 1},
            sexo2 = {brightness = 0, contrast = 1, saturation = 1},
            glitch = {binaryIntensity = 0},
            pixel = {pixelsize = 0},
            glih = {sort = 0},
            chromGraphic = {amount = 0},
        }
        local cameraFilters = {
            {'camGame', {'sexo', 'glitch', 'pixel', 'glih', 'chromGraphic', 'invertGraphic'}},
            {'camHUD', {'sexo2', 'glitch', 'pixel', 'glih', 'invertGraphic2'}},
        }
        for _, entry in ipairs(cameraFilters) do
            for _, name in ipairs(entry[2]) do
                if neutrals[name] then
                    for uniform, neutral in pairs(neutrals[name]) do
                        addPrunedFilter(entry[1], name, uniform, neutral)
                    end
                else
                    addStaticFilter(entry[1], name, false)
                end
            end
        end
    end
end

local tweening = false
local tweening2 = false
local tweening3 = false
local tweening4 = false

function onGameOver()
    pixelChange = true;
end

function onUpdate(e)
    dadFrame = getProperty('dad.animation.curAnim.curFrame');
    if shadersEnabled then
        
        if dadName == 'lord x p3scream' then
            if dadFrame == 0 then
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

        local glitchX = getProperty('glitch.x')
        sendShaderFloat('chromGraphic', "amount", getProperty('chromGraphic.x'))
        sendShaderFloat('glitch', "binaryIntensity", glitchX > 0.001 and glitchX or 0)
    end
end

local thing = 0;
function onUpdatePost(e)
    thing = thing + e
    if shadersEnabled then
        sendShaderFloat('sexo', 'brightness', getProperty('sexo.x') * 2)
        sendShaderFloat('sexo', 'contrast', 1 + (getProperty('sexo.x') * 4))

        sendShaderFloat('sexo2', 'brightness', getProperty('sexo2.x') * 2)
        sendShaderFloat('sexo2', 'contrast', 1 + (getProperty('sexo2.x') * 4))

        sendShaderFloat('sexo', 'saturation', getProperty('sexo.y'))
        sendShaderFloat('sexo2', 'saturation', getProperty('sexo2.y'))

        sendShaderFloat('glih', 'sort', getProperty('glih.x'))

        sendShaderFloat('pixel', 'pixelsize', getProperty('pixel.x'))
    end
end