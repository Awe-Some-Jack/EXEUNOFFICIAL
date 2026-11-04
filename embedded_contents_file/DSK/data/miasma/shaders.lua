-- Shader by Kophy232, Remember to credit if use! it took me months xd

local shadersOn = (shadersEnabled ~= false)
local shaderName = shadersOn and "TVtime" or "CameraStuff"
local shaderTime = 0
local shaderBase = {}
local shaderSent = {}
local shaderPulses = {}
local flashOutTime = 0.5
local cameraToShaderSprite = {
    camGame = "shaderSprite_camGame",
    camHUD = "shaderSprite_camHUD"
}
local cameraOnlyParams = {	-- Estos parametros los maneja CameraStuff, el resto TVtime
    cangle = true,
    brightness = true,
    contrast = true
}
local cameraParams = {
    czoom = true, cangle = true, cx = true, cy = true,
    cwarph = true, cwarpv = true, cuwarph = true, cuwarpv = true
}
local cameraDefaults = {	-- DEFAULT SHADER EFFECTS FOR EACH CAMERA
    camGame = {
	contrast = 2,
	chromAbRadial = 2,
	desaturation = 0,
    },
    camHUD = {
	contrast = 1.4,
	desaturation = 1,
	chromAblineal = 2
    }
}
local function sendShaderFloat(sprite, param, value)
    local sent = shaderSent[sprite]
    if sent == nil then
        sent = {}
        shaderSent[sprite] = sent
    end
    if sent[param] ~= value then
        sent[param] = value
        setShaderFloat(sprite, param, value)
    end
end
local function getShaderSprites(camera, param)
    if not shadersOn and not cameraOnlyParams[param] then return {} end
    if camera == "all" then
        return { cameraToShaderSprite.camGame, cameraToShaderSprite.camHUD }
    elseif type(camera) == "string" then
        return { cameraToShaderSprite[camera] }
    elseif type(camera) == "table" then
        local sprites = {}
        for _, cam in ipairs(camera) do
            table.insert(sprites, cameraToShaderSprite[cam])
        end
        return sprites
    end
    return {}
end
function initShaderValues(camera)  -- DEFAULT SHADER EFFECTS FOR ALL THE CAMERAS
    local baseDefaults = {
	sharpness = 0,

        desaturation = 0,      -- Blanco y negro = 1
			-- Nitidez def = 1.5, MaskLight 3, Mask 3.5, Gamma 3.5, GammaLight 2.3, Light 1, Halation 0

-- 1.35 BRILLO def 1, Nitidez 0.8, Light 0.8, NitLight 0.6, MaskNit 1.2, all 1.4, Mask 1.3, Gamma 2, Gammalight 1.2
        brightness = 0.5,


        crtGammaEnabled = 0,   -- 0 = off, 1 = CRT
        lcdGammaEnabled = 0,   -- 0 = off, 1 = LCD
        crtGammaValue = 1,     -- def 1, Contraste Negro 4.5, Light 1, halation 1.2
        lcdGammaValue = 1,     -- def 1, Balanceado 0.9

        contrast = 1,   -- def 1, 1.05

-- Efecto 3D

-- Iluminacion Neon
	halationAmount = 0,    -- Neon 0.7, mask 2

-- Iluminacion Blanca
        lightingEnabled = 0,   -- 0 = off, 1 = light
        lightingIntensity = 2, -- def 2

-- Efecto de Calor
	waveDistortion = 0,  -- 1 = default

-- Extra Effects
	horizontalGlitchAmount = 0,  -- 2 = Default
	waveBarGlitch = 0,  -- 1.4 = Max or breaks
	chromAblineal = 0,
	chromAbRadial = 0,
	pixelateAmount = 0,

-- Default Values
	czoom = 1,
	cangle = 0,
	cx = 0,
	cy = 0,
	cwarph = 0,
	cwarpv = 0,
	cuwarph = 0, -- test = -0.4
	cuwarpv = 0, -- -0.4
    }
    local function cameraMatches(camName)
        if camera == nil or camera == "all" then return true end
        if type(camera) == "string" then return camera == camName end
        if type(camera) == "table" then
            for _, c in ipairs(camera) do
                if c == camName then return true end
            end
        end
        return false
    end
    local function buildDefaults(cameraName)
        local defaults = {}
        for k,v in pairs(baseDefaults) do
            defaults[k] = v
        end
        if cameraName and cameraDefaults[cameraName] then
            for k,v in pairs(cameraDefaults[cameraName]) do
                defaults[k] = v
            end
        end
        return defaults
    end
    for camName, spriteName in pairs(cameraToShaderSprite) do
        if cameraMatches(camName) then
            shaderBase[spriteName] = {}
            for k, v in pairs(buildDefaults(camName)) do
                if shadersOn or cameraOnlyParams[k] then
                    shaderBase[spriteName][k] = v
                    sendShaderFloat(spriteName, k, v)
                end
            end
        end
    end
end

--	SHADER TOOLS :hot_face:
--		pulseShaderFlash("name", Intensity, exit, entry, camera) or ("name", Intensity, exit, camera)
--		TweenShadersin("name", Value, time, linear, camera)
--		ShaderInst("name", Value, camera)
--              flashentuano(Intensity, entry, exit, "#FFFFFF")

--	If you dont specify the camera, it applies to all of them

function onStepHit()
	if curStep == 2 then
	TweenShadersin("chromAbRadial", 0.4, 1.3, cubeOut, "camGame")
	TweenShadersin("chromAblineal", 0.2, 1.3, cubeOut, "camHUD")
	TweenShadersin("contrast", 1.05, 1.2, cubeOut, "camGame")
	TweenShadersin("contrast", 1.1, 1.2, cubeOut, "camHUD")
	TweenShadersin("halationAmount", 0.1, 1.2, cubeOut, "camGame")
	TweenShadersin("halationAmount", 0.1, 1.2, cubeOut, "camHUD")
	TweenShadersin("brightness", 1, 1, cubeOut)
	TweenShadersin("desaturation", 0, 1.2, linear, "camHUD")
	TweenShadersin("desaturation", 1, 1.8, linear, "camGame")
	end

-- Specific Flashes
	if curStep == 128 or curStep == 132 or curStep == 136 then
	flashentuano(0.6, 0, 0.4, "#FFFFFF")
	pulseShaderFlash("horizontalGlitchAmount", 1, 0.4)
	pulseShaderFlash("halationAmount", 0.6, 0.4)
	pulseShaderFlash("brightness", 0.6, 0.4)
	end
	if curStep == 264 or curStep == 268 then
	flashentuano(0.6, 0, 0.4, "#FFFFFF")
	pulseShaderFlash("pixelateAmount", 1, 0.4)
	pulseShaderFlash("horizontalGlitchAmount", 1, 0.4)
	pulseShaderFlash("halationAmount", 0.6, 0.4)
	pulseShaderFlash("brightness", 0.6, 0.4)
	end
-- Specific flashes

-- Contrast shit
	if curStep == 150 or curStep == 288 then
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camHUD")
	end
	if curStep == 166 or curStep == 304 then
	TweenShadersin("contrast", 1.1, 0.5, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.1, 0.5, smoothStepInOut, "camHUD")
	end
	if curStep == 214 or curStep == 352 then
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camHUD")
	end
	if curStep == 230 or curStep == 368 then
	TweenShadersin("contrast", 1.1, 0.5, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.1, 0.5, smoothStepInOut, "camHUD")
	end

	if curStep == 544 or curStep == 688 then
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camHUD")
	end
	if curStep == 560 or curStep == 720 then
	TweenShadersin("contrast", 1.1, 0.6, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.1, 0.6, smoothStepInOut, "camHUD")
	end
	if curStep == 608 or curStep == 736 then
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.3, 0.3, smoothStepInOut, "camHUD")
	end
	if curStep == 624 or curStep == 752 then
	TweenShadersin("contrast", 1.1, 0.6, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 1.1, 0.6, smoothStepInOut, "camHUD")
	end
-- Contrast shit

-- Only angles
	if curStep == 142 then
	TweenShadersin("cangle", -5, 0.25, cubeIn)
	end
	if curStep == 146 then
	TweenShadersin("cangle", 0, 0.2, cubeOut)
	end
	if curStep == 149 then
	TweenShadersin("cy", -0.05, 0.16, cubeIn) -- 0.15
	TweenShadersin("czoom", 0.98, 0.22, cubeIn)
	end
	if curStep == 153 then
	TweenShadersin("cy", 0, 0.17, cubeOut)
	TweenShadersin("czoom", 1, 0.2, cubeOut)
	end
	if curStep == 165 then -- 166
	TweenShadersin("cy", 0.05, 0.16, cubeIn) -- 0.13
	TweenShadersin("czoom", 0.98, 0.22, cubeIn)
	end
	if curStep == 169 then
	TweenShadersin("cy", 0, 0.16, cubeOut)
	TweenShadersin("czoom", 1, 0.2, cubeOut)
	end

	if curStep == 208 then
	TweenShadersin("cangle", 2, 0.2, cubeIn)
	end
	if curStep == 211 then
	TweenShadersin("cangle", 0, 0.2, cubeOut)
	end
	if curStep == 213 then
	TweenShadersin("cy", 0.03, 0.16, cubeIn) -- 0.17
	TweenShadersin("czoom", 0.99, 0.21, cubeIn)
	end
	if curStep == 217 then
	TweenShadersin("cy", 0, 0.2, cubeOut)
	TweenShadersin("czoom", 1, 0.2, cubeOut)
	end
	if curStep == 229 then
	TweenShadersin("cx", -0.025, 0.16, cubeIn)
	TweenShadersin("czoom", 0.98, 0.21, cubeIn) -- 0.18
	end
	if curStep == 233 then
	TweenShadersin("cx", 0, 0.14, cubeOut)
	TweenShadersin("czoom", 1, 0.14, cubeOut)
	end
-- Only angles

	if curStep == 16 or curStep == 80 or curStep == 112 or curStep == 120 or curStep == 144 then
	-- Strong flash
	flashentuano(0.6, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("horizontalGlitchAmount", 1.5, 0.6)
	pulseShaderFlash("halationAmount", 0.7, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	end

	if curStep == 208 or curStep == 336 then
	-- second Strong flash
	pulseShaderFlash("pixelateAmount", 1, 0.6)
	pulseShaderFlash("chromAbRadial", 0.3, 0.6, "camGame")
	pulseShaderFlash("halationAmount", 0.7, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	flashentuano(0.6, 0, 0.6, "#FFFFFF")
	end

	if curStep == 32 or curStep == 48 or curStep == 64 or curStep == 96 then
	-- basic flash
	pulseShaderFlash("horizontalGlitchAmount", 0.6, 0.6)
	pulseShaderFlash("halationAmount", 0.4, 0.6)
	pulseShaderFlash("brightness", 0.3, 0.6)
	end
	
	if curStep == 160 or curStep == 192 or curStep == 224 or curStep == 256 or curStep == 272 then
	-- third basic flash (+)
	pulseShaderFlash("contrast", 0.1, 0.6)
	pulseShaderFlash("halationAmount", 0.6, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 0.8, 0.6)
	pulseShaderFlash("brightness", 0.3, 0.6)
	end

	if curStep == 144 or curStep == 176 or curStep == 240 or curStep == 352 or curStep == 368 then
	-- second basic flash (++)
	pulseShaderFlash("pixelateAmount", 1, 0.5)
	pulseShaderFlash("halationAmount", 0.5, 0.5)
	pulseShaderFlash("brightness", 0.5, 0.6)
	pulseShaderFlash("chromAbRadial", 0.3, 0.6, "camGame")
	end

	-- Camera peak 1
	if curStep == 135 then
	TweenShadersin("czoom", 2, 0.8, smoothStepInOut)
	TweenShadersin("cuwarph", -0.25, 0.8, smoothStepInOut)
	TweenShadersin("cuwarpv", -0.25, 0.8, smoothStepInOut)
	TweenShadersin("contrast", 2, 0.8, cubeIn, "camGame")
	TweenShadersin("contrast", 2, 0.8, cubeIn, "camHUD")
	TweenShadersin("chromAblineal", 0.7, 0.8, cubeIn, "camHUD")
	TweenShadersin("chromAbRadial", 0.6, 0.8, cubeIn, "camGame")
	TweenShadersin("cangle", 3, 0.65, smoothStepInOut)
	end
	if curStep == 143 then
	TweenShadersin("czoom", 1, 0.2, smoothStepInOut)
	TweenShadersin("cuwarph", 0, 0.2, smoothStepInOut)
	TweenShadersin("cuwarpv", 0, 0.2, smoothStepInOut)
	TweenShadersin("contrast", 1.1, 0.2, cubeOut, "camGame")
	TweenShadersin("contrast", 1.1, 0.2, cubeOut, "camHUD")
	TweenShadersin("chromAblineal", 0.2, 0.2, cubeOut, "camHUD")
	TweenShadersin("chromAbRadial", 0.4, 0.2, cubeOut, "camGame")
	end
	-- Camera peak 1

	-- Camera peak 2
	if curStep == 384 then
	TweenShadersin("czoom", 2, 1.2, smoothStepInOut)
	TweenShadersin("cuwarph", -0.3, 1.2, smoothStepInOut)
	TweenShadersin("cuwarpv", -0.3, 1.2, smoothStepInOut)
	TweenShadersin("contrast", 4, 1.2, cubeIn, "camGame")
	TweenShadersin("contrast", 4, 1.2, cubeIn, "camHUD")
	TweenShadersin("chromAblineal", 1.2, 1.2, cubeIn, "camHUD")
	TweenShadersin("chromAbRadial", 1, 1.2, cubeIn, "camGame")
	TweenShadersin("cangle", 3, 1.05, smoothStepInOut)

	pulseShaderFlash("chromAblineal", 0.5, 0.6, "camHUD")
	pulseShaderFlash("halationAmount", 0.7, 0.5)
	pulseShaderFlash("brightness", 0.7, 0.5)
	pulseShaderFlash("waveBarGlitch", 1, 0.6, "camHUD")
	pulseShaderFlash("horizontalGlitchAmount", 0.7, 0.6)
	end
	if curStep == 398 then
	TweenShadersin("czoom", 1, 0.2, smoothStepInOut)
	TweenShadersin("cuwarph", 0, 0.2, smoothStepInOut)
	TweenShadersin("cuwarpv", 0, 0.2, smoothStepInOut)
	TweenShadersin("contrast", 1.15, 0.2, cubeOut, "camGame")
	TweenShadersin("contrast", 1.16, 0.2, cubeOut, "camHUD")
	TweenShadersin("chromAblineal", 0.3, 0.2, cubeOut, "camHUD")
	TweenShadersin("chromAbRadial", 0.4, 0.2, cubeOut, "camGame")
	end
	if curStep == 390 then
	TweenShadersin("cx", 0.05, 0.16, cubeIn)
	end
	if curStep == 394 then
	TweenShadersin("cx", -0.05, 0.16, cubeIn)
	end
	if curStep == 398 then
	TweenShadersin("cx", 0, 0.14, cubeOut)
	end
	if curStep == 397 then
	TweenShadersin("cangle", -3, 0.2, cubeIn)
	end
	if curStep == 400 then
	TweenShadersin("cangle", 0, 0.2, cubeOut)
	end
	if curStep == 392 or curStep == 396 then
	pulseShaderFlash("pixelateAmount", 2, 0.4)
	pulseShaderFlash("halationAmount", 0.7, 0.4)
	flashentuano(0.8, 0, 0.4, "#FFFFFF")
	end
	if curStep == 392 then
	ShaderInst("waveBarGlitch", 0.4)
	ShaderInst("desaturation", 1)
	end
	if curStep == 464 then
	ShaderInst("waveBarGlitch", 0.8)
	ShaderInst("contrast", 1.4)
	end
	-- Camera peak 2
	
	if curStep == 288 or curStep == 192 or curStep == 304 or curStep == 320 then
	-- fourth basic flash
	pulseShaderFlash("chromAblineal", 0.5, 0.6, "camHUD")
	pulseShaderFlash("halationAmount", 0.9, 0.6)
	pulseShaderFlash("brightness", 0.7, 0.6)
	pulseShaderFlash("pixelateAmount", 0.8, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 0.7, 0.6)
	end

	if curStep == 400 or curStep == 724 then
	flashentuano(0.6, 0, 0.6, "#FFFFFF")
	end
	if curStep == 416 or curStep == 432 or curStep == 448 or curStep == 448 or curStep == 464 or curStep == 480 then
	-- Ink
	pulseShaderFlash("chromAblineal", 0.5, 0.6, "camHUD")
	pulseShaderFlash("halationAmount", 0.8, 0.5)
	flashentuano(0.4, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("contrast", -0.1, 0.5)
	pulseShaderFlash("waveBarGlitch", 1, 0.6, "camHUD")
	pulseShaderFlash("horizontalGlitchAmount", 0.8, 0.6)
	end
	if curStep == 496 or curStep == 504 or curStep == 512 then
	-- Ink 2
	pulseShaderFlash("chromAblineal", 0.5, 0.45, "camHUD")
	pulseShaderFlash("halationAmount", 0.8, 0.45)
	flashentuano(0.6, 0, 0.45, "#FFFFFF")
	pulseShaderFlash("contrast", -0.1, 0.45)
	pulseShaderFlash("waveBarGlitch", 1, 0.45, "camHUD")
	pulseShaderFlash("pixelateAmount", 0.8, 0.45)
	end
	if curStep == 516 then
	-- Ink 3
	pulseShaderFlash("chromAblineal", 0.5, 0.45, "camHUD")
	pulseShaderFlash("halationAmount", 0.8, 0.45)
	flashentuano(0.6, 0, 0.45, "#FFFFFF")
	pulseShaderFlash("pixelateAmount", 0.8, 0.45)
	pulseShaderFlash("horizontalGlitchAmount", 0.8, 0.6)
	end
	-- Volverse Negro
	if curStep == 520 then
	TweenShadersin("cuwarph", 0.5, 0.4, smoothStepInOut)
	TweenShadersin("cuwarpv", 0.5, 0.4, smoothStepInOut)
	TweenShadersin("contrast", 2, 0.4, cubeOut, "camGame")
	TweenShadersin("contrast", 2, 0.4, cubeOut, "camHUD")
	TweenShadersin("chromAblineal", 0.7, 0.4, cubeOut, "camHUD")
	TweenShadersin("chromAbRadial", 0.7, 0.4, cubeOut, "camGame")
	TweenShadersin("waveBarGlitch", 0, 0.4, cubeOut)
	flashentuano(0.6, 0, 0.4, "#FFFFFF")
	end
	-- Volverse Blanco
	if curStep == 528 then
	ShaderInst("desaturation", 0, "camHUD")
	ShaderInst("desaturation", 1, "camGame")
	ShaderInst("cuwarph", 0)
	ShaderInst("cuwarpv", 0)
	ShaderInst("contrast", 1.1, "camGame")
	ShaderInst("contrast", 1.1, "camHUD")
	ShaderInst("halationAmount", 0.2)
	ShaderInst("chromAblineal", 0.2, "camHUD")
	ShaderInst("chromAbRadial", 0.4, "camGame")
	
	pulseShaderFlash("brightness", 0.3, 0.6)
	pulseShaderFlash("sharpness", 7, 0.6)
	flashentuano(1, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("pixelateAmount", 0.3, 0.6)
	end

-- SEGUNDA SECCION PEAK

	if curStep == 544 or curStep == 608 then
	-- basic flash
	pulseShaderFlash("horizontalGlitchAmount", 0.6, 0.6)
	pulseShaderFlash("halationAmount", 0.4, 0.6)
	pulseShaderFlash("brightness", 0.3, 0.6)
	end

	if curStep == 560 or curStep == 624 or curStep == 640 or curStep == 736 then
	-- third basic flash (+)
	pulseShaderFlash("halationAmount", 0.6, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 0.8, 0.6)
	pulseShaderFlash("brightness", 0.3, 0.6)
	end

	if curStep == 576 or curStep == 672 or curStep == 672 then
	-- second basic flash (++)
	pulseShaderFlash("pixelateAmount", 1, 0.5)
	pulseShaderFlash("halationAmount", 0.5, 0.5)
	pulseShaderFlash("brightness", 0.5, 0.6)
	pulseShaderFlash("chromAbRadial", 0.3, 0.6, "camGame")
	end

	if curStep == 688 or curStep == 704 or curStep == 720 then
	-- fourth basic flash
	pulseShaderFlash("chromAblineal", 0.5, 0.6, "camHUD")
	pulseShaderFlash("halationAmount", 0.9, 0.6)
	pulseShaderFlash("brightness", 0.7, 0.6)
	pulseShaderFlash("pixelateAmount", 0.8, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 0.7, 0.6)
	end

	if curStep == 656 then
	-- sharpness
	pulseShaderFlash("contrast", 0.1, 0.6)
	pulseShaderFlash("halationAmount", 0.6, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 0.8, 0.6)
	pulseShaderFlash("sharpness", 4, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	flashentuano(0.6, 0, 0.6, "#FFFFFF")
	end

	if curStep == 592 or curStep == 752 or curStep == 760 then
	-- Strong flash
	flashentuano(0.6, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("horizontalGlitchAmount", 1.5, 0.6)
	pulseShaderFlash("halationAmount", 0.7, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	end

	if curStep == 768 or curStep == 772 or curStep == 776 then
	-- second Strong flash
	pulseShaderFlash("pixelateAmount", 1, 0.45)
	pulseShaderFlash("chromAbRadial", 0.3, 0.45, "camGame")
	pulseShaderFlash("halationAmount", 0.7, 0.45)
	pulseShaderFlash("brightness", 0.6, 0.45)
	flashentuano(0.6, 0, 0.45, "#FFFFFF")
	end

	if curStep == 784 then
	-- sharpness Volverse Negro
	pulseShaderFlash("sharpness", 4, 0.6)
	pulseShaderFlash("pixelateAmount", 1, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 1.5, 0.6)
	pulseShaderFlash("chromAbRadial", 0.3, 0.6, "camGame")
	pulseShaderFlash("halationAmount", 0.8, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	flashentuano(0.7, 0, 0.6, "#FFFFFF")

	TweenShadersin("desaturation", 1, 0.3, cubeOut, "camHUD")
	TweenShadersin("contrast", 2, 0.5, cubeOut, "camGame")
	TweenShadersin("contrast", 2, 0.5, cubeOut, "camHUD")
	end

	if curStep == 797 then
	ShaderInst("waveDistortion", 0.8, "camHUD")
	ShaderInst("waveDistortion", 1, "camGame")
	end

	if curStep == 816 then
	-- Volverse Blanco
	ShaderInst("contrast", 1.2, "camGame")
	ShaderInst("contrast", 1.2, "camHUD")
	ShaderInst("halationAmount", 0.3)

	pulseShaderFlash("brightness", 0.5, 0.6)
	flashentuano(1, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("pixelateAmount", 0.6, 0.6)
	end

-- TERCERA SECCION PEAK
	if curStep == 880 or curStep == 1008 then
	-- Strong flash
	flashentuano(0.6, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("horizontalGlitchAmount", 1.5, 0.6)
	pulseShaderFlash("halationAmount", 0.7, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	pulseShaderFlash("waveDistortion", 0.5, 0.6)
	end

	if curStep == 832 or curStep == 848 or curStep == 896 or curStep == 912 or curStep == 960 or curStep == 976 or curStep == 1040 then
	-- third basic flash (+)
	pulseShaderFlash("sharpness", 0.3, 0.6)
	pulseShaderFlash("halationAmount", 0.5, 0.6)
	pulseShaderFlash("horizontalGlitchAmount", 1, 0.6)
	pulseShaderFlash("brightness", 0.3, 0.6)
	pulseShaderFlash("waveDistortion", 0.4, 0.6)
	end

	if curStep == 864 or curStep == 928 or curStep == 992 or curStep == 1024 or curStep == 1056 then
	-- second basic flash (++)
	pulseShaderFlash("pixelateAmount", 1, 0.5)
	pulseShaderFlash("halationAmount", 0.5, 0.5)
	pulseShaderFlash("brightness", 0.5, 0.6)
	pulseShaderFlash("chromAbRadial", 0.3, 0.6, "camGame")
	pulseShaderFlash("waveDistortion", 0.4, 0.6)
	end

	if curStep == 944 then
	-- Black in
	ShaderInst("sharpness", 2.5)
	ShaderInst("pixelateAmount", 0.2)
	ShaderInst("crtGammaEnabled", 1)
	ShaderInst("lcdGammaEnabled", 1)
	ShaderInst("crtGammaValue", 3.8)
	ShaderInst("lcdGammaValue", 0.9)
	ShaderInst("lightingEnabled", 1)
	ShaderInst("lightingIntensity", 4)
	end

	if curStep == 948 then
	-- Black Out flash
	ShaderInst("sharpness", 0)
	ShaderInst("pixelateAmount", 0)
	pulseShaderFlash("pixelateAmount", 1, 0.6)
	pulseShaderFlash("halationAmount", 0.7, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	pulseShaderFlash("waveDistortion", 0.4, 0.6)
	flashentuano(0.6, 0, 0.6, "#FFFFFF")

	ShaderInst("crtGammaEnabled", 0)
	ShaderInst("lcdGammaEnabled", 0)
	ShaderInst("lightingEnabled", 0)
	end

	if curStep == 1072 then
	-- sharpness flash
	pulseShaderFlash("sharpness", 2, 0.6)
	pulseShaderFlash("pixelateAmount", 1, 0.6)
	pulseShaderFlash("waveDistortion", 0.4, 0.6)
	pulseShaderFlash("chromAbRadial", 0.3, 0.6, "camGame")
	pulseShaderFlash("halationAmount", 0.8, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	flashentuano(0.7, 0, 0.6, "#FFFFFF")
	end

-- Black and White Flashes
	if curStep == 1088 or curStep == 928 or curStep == 1104 or curStep == 1120 or curStep == 1152 or curStep == 1168 then
	pulseShaderFlash("horizontalGlitchAmount", 1.7, 0.7)
	end
	if curStep == 1136 then
	pulseShaderFlash("horizontalGlitchAmount", 2, 0.8)
	flashentuano(1, 0, 0.8, "#FFFFFF")
	end
	if curStep == 1184 then
	pulseShaderFlash("horizontalGlitchAmount", 1.8, 0.8)
	flashentuano(0.7, 0, 0.8, "#FFFFFF")
	end
-- Black and White Flashes

-- CAMERA GO CRAZYYYY
	if curStep == 1192 then -- 10
	TweenShadersin("czoom", 1.5, 1.025, circIn, "camGame")
	TweenShadersin("cx", -1, 1.025, smoothStepInOut, "camGame")
	TweenShadersin("cy", -0.2, 1.025, smoothStepInOut, "camGame")
	end
	if curStep == 1202 then
	TweenShadersin("cx", -5.5, 6.4, smoothStepInOut, "camGame")
	TweenShadersin("cy", -1, 6.4, smoothStepInOut, "camGame")
	TweenShadersin("czoom", 3, 6.4, smoothStepInOut, "camGame")
	end
	if curStep == 1264 then
	TweenShadersin("cx", 0, 4.8, smoothStepInOut, "camGame")
	TweenShadersin("cy", -2, 5, smoothStepInOut, "camGame")
	end
	if curStep == 1266 then
	TweenShadersin("czoom", 1, 4.5, circOut, "camGame")
	end
-- CAMERA GO CRAZYYYY

	if curStep == 1200 or curStep == 1264 then
	-- sharpness flash 2.0
	pulseShaderFlash("brightness", 0.4, 0.8)
	pulseShaderFlash("sharpness", 5, 0.7)
	flashentuano(1, 0, 1, "#FFFFFF")
	pulseShaderFlash("pixelateAmount", 0.3, 0.7)
	end

	if curStep == 1296 then
	TweenShadersin("contrast", 5, 1, cubeOut, "camGame")
	TweenShadersin("contrast", 3, 1, cubeOut, "camHUD")
	end

	if curStep == 1312 then
	-- sharpness flash
	pulseShaderFlash("sharpness", 2, 0.6)
	pulseShaderFlash("pixelateAmount", 1, 0.6)
	pulseShaderFlash("waveDistortion", 0.5, 0.6)
	pulseShaderFlash("halationAmount", 0.8, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	flashentuano(0.8, 0, 0.6, "#FFFFFF")

	ShaderInst("contrast", 1.1)
	end

	if curStep == 1324 then
	pulseShaderFlash("pixelateAmount", 1, 0.4)
	pulseShaderFlash("horizontalGlitchAmount", 1, 0.4)
	end

	if curStep == 1328 then
	flashentuano(0.8, 0, 0.6, "#FFFFFF")
	pulseShaderFlash("sharpness", 2, 0.6)
	pulseShaderFlash("waveDistortion", 0.5, 0.6)
	pulseShaderFlash("brightness", 0.6, 0.6)
	end

	if curStep == 1346 then
	TweenShadersin("cwarph", -0.5, 1.5, smoothStepInOut, "camGame")
	TweenShadersin("cwarpv", -1.2, 1.5, smoothStepInOut, "camGame")
	TweenShadersin("brightness", 0.3, 1.5, smoothStepInOut, "camGame")
	TweenShadersin("contrast", 5, 2, cubeOut, "camGame")
	TweenShadersin("contrast", 3, 1.5, cubeOut, "camHUD")
	TweenShadersin("chromAblineal", 1, 1.5, cubeOut, "camHUD")
	TweenShadersin("chromAbRadial", 2, 1.5, cubeOut, "camGame")
	end
end
local function ease(t, easeType)
    if easeType == 'quadIn' then return t * t
    elseif easeType == 'quadOut' then return 1 - (1 - t) * (1 - t)
    elseif easeType == 'quadInOut' then
        if t < 0.5 then return 2 * t * t end
        return 1 - math.pow(-2 * t + 2, 2) / 2
    elseif easeType == 'cubicIn' then return t * t * t
    elseif easeType == 'cubicOut' then return 1 - math.pow(1 - t, 3)
    elseif easeType == 'cubicInOut' then
        if t < 0.5 then return 4 * t * t * t end
        return 1 - math.pow(-2 * t + 2, 3) / 2
    elseif easeType == 'elasticOut' then
        if t == 0 or t == 1 then return t end
        return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi / 3)) + 1
    elseif easeType == 'smoothStepInOut' then
        return 3 * t * t - 2 * t * t * t
    end
    return t
end
function flashentuano(alpha, timeIn, timeOut, color)
	local hexColor = (color or "FFFFFF"):gsub("#", "")
	setProperty('flashentuanito.color', getColorFromHex(hexColor))
	cancelTween('nFlash1')
	cancelTween('mFlashIn')
	setProperty('flashentuanito.alpha', 0)
	if timeIn and timeIn > 0 then
		doTweenAlpha('mFlashIn', 'flashentuanito', alpha, timeIn, 'linear')
		runTimer('flashOutTimer', timeIn)
	else
		setProperty('flashentuanito.alpha', alpha)
		doTweenAlpha('nFlash1', 'flashentuanito', 0, timeOut, 'linear')
	end
	flashOutTime = timeOut or 0.5
end
function onTimerCompleted(tag)
	if tag == 'flashOutTimer' then
		doTweenAlpha('nFlash1', 'flashentuanito', 0, flashOutTime, 'linear')
	end
end
function pulseShaderFlash(param, amount, fadeOut, fadeIn, camera)
    if not param or type(amount) ~= "number" then return end
    fadeOut = (type(fadeOut) == "number") and fadeOut or 0.5
    fadeIn = (type(fadeIn) == "number") and fadeIn or 0
    camera = camera or "all"
    for _, sprite in ipairs(getShaderSprites(camera, param)) do
        local baseValue = shaderBase[sprite][param] or 0
        table.insert(shaderPulses, {
            type = "tween",
            param = param,
            start = baseValue,
            target = baseValue + amount,
            diff = amount,
            duration = math.max(0.0001, fadeIn),
            elapsed = 0,
            easeType = "smoothStepInOut",
            sprite = sprite,
            isTemporary = true
        })
        table.insert(shaderPulses, {
            type = "tween",
            param = param,
            start = baseValue + amount,
            target = baseValue,
            diff = -amount,
            duration = math.max(0.0001, fadeOut),
            elapsed = 0,
            easeType = "smoothStepInOut",
            sprite = sprite,
            delay = fadeIn,
            isTemporary = true
        })
        if cameraParams[param] then
            table.insert(shaderPulses, {
                type = "callback",
                elapsed = 0,
                delay = fadeIn + fadeOut,
                callback = function()
                    TweenShadersin(param, baseValue, 0.4, "smoothStepInOut", camera)
                end
            })
        end
    end
end
function ShaderInst(param, value, camera)
    if not param or type(value) ~= "number" then return end
    camera = camera or "all"
    for _, sprite in ipairs(getShaderSprites(camera, param)) do
        shaderBase[sprite][param] = value
        sendShaderFloat(sprite, param, value)
    end
end
function TweenShadersin(param, targetValue, duration, easeType, camera)
    if not param or type(targetValue) ~= "number" or type(duration) ~= "number" then return end
    camera = camera or "all"
    for _, sprite in ipairs(getShaderSprites(camera, param)) do
        local startValue = shaderBase[sprite][param] or 0
        table.insert(shaderPulses, {
            type = "tween",
            param = param,
            start = startValue,
            target = targetValue,
            diff = targetValue - startValue,
            duration = duration,
            elapsed = 0,
            easeType = easeType or 'linear',
            sprite = sprite
        })
    end
end
function onUpdate(elapsed)
    shaderTime = shaderTime + elapsed
    local pending = {}
    for _, sprite in pairs(cameraToShaderSprite) do
        pending[sprite] = shadersOn and { time = shaderTime } or {}
    end
    for i = #shaderPulses, 1, -1 do
        local p = shaderPulses[i]
        p.elapsed = p.elapsed + elapsed
        local delay = p.delay or 0
        if p.type == "callback" then
            if p.elapsed >= delay then
                table.remove(shaderPulses, i)
                p.callback()
            end
        elseif p.elapsed >= p.duration + delay then
            if not p.isTemporary then
                shaderBase[p.sprite][p.param] = p.target
            end
            pending[p.sprite][p.param] = p.target
            table.remove(shaderPulses, i)
        elseif p.elapsed >= delay then
            local t = math.min(1, (p.elapsed - delay) / math.max(0.0001, p.duration))
            pending[p.sprite][p.param] = p.start + p.diff * ease(t, p.easeType)
        end
    end
    for sprite, params in pairs(pending) do
        for param, value in pairs(params) do
            sendShaderFloat(sprite, param, value)
        end
    end
end
local function parseCamera(str)
    local camera = "all"
    local params = str or ""
    local startBrace = string.find(params, "<")
    local endBrace = string.find(params, ">")
    if startBrace and endBrace and endBrace > startBrace then
        camera = string.sub(params, startBrace + 1, endBrace - 1)
        params = string.sub(params, 1, startBrace - 1)
    end
    local cameraList = {}
    if camera ~= "all" then
        for cam in string.gmatch(camera, "([^,]+)") do
            table.insert(cameraList, cam)
        end
    end
    return params, (next(cameraList) and cameraList or "all")
end
local function parseArgs(str)
    local args = {}
    for value in string.gmatch(str or "", "([^,]+)") do
        table.insert(args, tonumber(value) or value)
    end
    return args
end
function onEvent(name, v1, v2)
    if name == "pulseShaderFlash" then
        local params, camera = parseCamera(v2)
        local args = parseArgs(params)
        pulseShaderFlash(v1, args[1] or 1, args[2] or 0.5, args[3] or 0, camera)
    elseif name == "TweenShadersin" then
        local params, camera = parseCamera(v2)
        local args = parseArgs(params)
        TweenShadersin(v1, args[1] or 0, args[2] or 1, args[3] or "linear", camera)
    elseif name == "ShaderInst" then
        local params, camera = parseCamera(v2)
        ShaderInst(v1, parseArgs(params)[1] or 0, camera)
    elseif name == "flashentuano" then
        local args = parseArgs(v1)
        flashentuano(args[1] or 1, args[2] or 0, args[3] or 0.5, (v2 ~= nil and v2 ~= "") and v2 or nil)
    end
end
function onCreate()
    shaderCoordFix()
    for camName, spriteName in pairs(cameraToShaderSprite) do
        makeLuaSprite(spriteName)
        setSpriteShader(spriteName, shaderName, true)
        addStaticFilter(camName, spriteName)
    end
    makeLuaSprite('flashentuanito', '', -960, -790)
    makeGraphic('flashentuanito', 1, 1, 'FFFFFF')
    scaleObject('flashentuanito', 3840, 2160)
    setLuaSpriteScrollFactor('flashentuanito', 0, 0)
    setProperty('flashentuanito.alpha', 0)
    setObjectCamera('flashentuanito', 'camOther')
    setBlendMode('flashentuanito', 'add')
    addLuaSprite('flashentuanito', true)
    initShaderValues()
end
function shaderCoordFix()
    runHaxeCode([[
        resetCamCache = function(?spr) {
            if (spr == null || spr.filters == null) return;
            spr.__cacheBitmap = null;
            spr.__cacheBitmapData = null;
        }
        fixShaderCoordFix = function(?_) {
            if (game.camGame != null) resetCamCache(game.camGame.flashSprite);
            if (game.camHUD != null) resetCamCache(game.camHUD.flashSprite);
        }
        game.variables.set('fixShaderCoordFix', fixShaderCoordFix);
        FlxG.signals.gameResized.add(fixShaderCoordFix);
        fixShaderCoordFix();
    ]])
    local temp = onDestroy
    function onDestroy()
        runHaxeCode([[
            var fix = game.variables.get('fixShaderCoordFix');
            if (fix != null) FlxG.signals.gameResized.remove(fix);
            game.variables.remove('fixShaderCoordFix');
        ]])
        if temp then temp() end
    end
end