-- Shader by Kophy232, Remember to credit if use! it took me months xd

local tvShaderName = "TVtime"
local shaderName = tvShaderName
local cameraShaderName = "CameraStuff"
local shadersOn = (shadersEnabled ~= false)
local shaderTime = 0
local shaderBase = {}
local shaderState = {}
local shaderPulses = {}
local shaderObjectPulses = {}
local shaderObjectTweens = {}
local shaderObjectBase = {}
local cameraToShaderSprite = {	-- CameraStuff (siempre activo)
    camGame = "shaderSprite_camGame",
    camHUD = "shaderSprite_camHUD"
}
local cameraToTVSprite = {	-- TVtime (solo si los shaders estan activados)
    camGame = "shaderSpriteTV_camGame",
    camHUD = "shaderSpriteTV_camHUD"
}
local cameraOnlyParams = {	-- Estos parametros los maneja CameraStuff, el resto TVtime
    cangle = true,
    brightness = true,
    contrast = true
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

--   Direccion: 1 = Normal, 2 = Radial Centro, 3 = Isq o Der, 4 = Arriba o Abajo, 5 = Centro Claro
--		6 = Centro Isq, 7 = Centro Der, 8 = Diagonal Abajo Isq, 9 = Diagonal Abajo Der
--						10 = Diagonal Arriba Isq, 11 = Diagonal Arriba Der
	halationPosition = 1,
	halationClone = 1,	-- 1 min.

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
    local function applyDefaults(sprite, defaults, onlyCameraParams)
        shaderBase[sprite] = {}
        shaderState[sprite] = {}
        for k,v in pairs(defaults) do
            local isCameraParam = cameraOnlyParams[k] == true
            if (onlyCameraParams and isCameraParam) or (not onlyCameraParams and not isCameraParam) then
                setShaderFloat(sprite, k, v)
                shaderBase[sprite][k] = v
                shaderState[sprite][k] = v
            end
        end
    end
    for camName, spriteName in pairs(cameraToShaderSprite) do
        if cameraMatches(camName) then
            applyDefaults(spriteName, buildDefaults(camName), true)
        end
    end
    if shadersOn then
        for camName, spriteName in pairs(cameraToTVSprite) do
            if cameraMatches(camName) then
                applyDefaults(spriteName, buildDefaults(camName), false)
            end
        end
    end
end

--	SHADER TOOLS :hot_face:
--		pulseShaderFlash("name", Intensity, exit, entry, camera) or ("name", Intensity, exit, camera)
--		TweenShadersin("name", Value, time, linear, camera)
--		ShaderInst("name", Value, camera)
--              flashentuano(Intensity, entry, exit, "#FFFFFF")

--		pulseShaderObject({"bg6","bg7"}, "brightness", 0.1, 1, 0, camera)
--		pulseShaderObject(Objects, Shader, Intensity, exit, entry, camera)
--		ObjectSInst(Objects, Shader, Value, camera)
--		TweenObjShader(Objects, Shader, Value, Time, linear, camera)

--		pulseColorSwap(hue, sat, brt, exit, entry, camera)
--		ColorFillInst(r, g, b, Inverse Intensity, camera)
--		ColorOverrideInst(r, g, b, camera)
--		pulseColorOverride(r, g, b, exit, entry, camera)	kinda bad/bugged idk

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
function getShaderSprites(camera)
    if camera == "all" then
        return {
            "shaderSprite_camGame",
            "shaderSprite_camHUD"
        }
    elseif type(camera) == "string" then
        return { cameraToShaderSprite[camera] }
    elseif type(camera) == "table" then
        local sprites = {}
        for _, cam in ipairs(camera) do
            table.insert(sprites, cameraToShaderSprite[cam])
        end
        return sprites
    else
        return {}
    end
end
function getTVSprites(camera)
    if not shadersOn then return {} end
    if camera == "all" then
        return {
            "shaderSpriteTV_camGame",
            "shaderSpriteTV_camHUD"
        }
    elseif type(camera) == "string" then
        return { cameraToTVSprite[camera] }
    elseif type(camera) == "table" then
        local sprites = {}
        for _, cam in ipairs(camera) do
            table.insert(sprites, cameraToTVSprite[cam])
        end
        return sprites
    else
        return {}
    end
end
function getSpritesForParam(camera, param)
    if cameraOnlyParams[param] then
        return getShaderSprites(camera)
    end
    return getTVSprites(camera)
end
function flashentuano(alpha, timeIn, timeOut, color)
	local hexColor = color or "FFFFFF"

	if hexColor:sub(1, 1) == "#" then
		hexColor = hexColor:sub(2, 7)
	end
	hexColor = string.format("%06s", hexColor)
	runHaxeCode([[
		var spr = game.getLuaObject("flashentuanito");
		if (spr != null) {
			spr.color = 0xFF]] .. hexColor:upper() .. [[;
		}
	]])
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
	_G.flashOutAlpha = alpha
	_G.flashOutTime = timeOut
end
function onTimerCompleted(tag)
	if tag == 'flashOutTimer' then
		doTweenAlpha('nFlash1', 'flashentuanito', 0, _G.flashOutTime or 0.5, 'linear')
	end
end
function ObjectSInst(objectNames, param, value, camera)
    if not objectNames or not param or type(value) ~= "number" then return end
    if type(objectNames) == "string" then objectNames = {objectNames} end
    camera = camera or "all"
    local sprites = getShaderSprites(camera)
    for _, obj in ipairs(objectNames) do
        for _, sprite in ipairs(sprites) do
            runHaxeCode([[
                var spr = game.getLuaObject("]]..obj..[[");
                if (spr != null) {
                    if (spr.shader == null) spr.shader = game.createRuntimeShader("]]..shaderName..[[");
                    spr.shader.data.]]..param..[[.value = [ ]]..value..[[ ];
                }
            ]])
            shaderObjectBase[obj] = shaderObjectBase[obj] or {}
            shaderObjectBase[obj][sprite] = shaderObjectBase[obj][sprite] or {}
            shaderObjectBase[obj][sprite][param] = value
        end
    end
end
function TweenObjShader(objectNames, param, targetValue, duration, easeType, camera)
    if not objectNames or not param or type(targetValue) ~= "number" or type(duration) ~= "number" then return end
    if type(objectNames) == "string" then objectNames = {objectNames} end
    easeType = easeType or 'linear'
    camera = camera or "all"
    local sprites = getShaderSprites(camera)
    for _, obj in ipairs(objectNames) do
        for _, sprite in ipairs(sprites) do
            runHaxeCode([[
                var spr = game.getLuaObject("]]..obj..[[");
                if (spr != null) {
                    if (spr.shader == null) spr.shader = game.createRuntimeShader("]]..shaderName..[[");
                }
            ]])
            shaderObjectBase[obj] = shaderObjectBase[obj] or {}
            shaderObjectBase[obj][sprite] = shaderObjectBase[obj][sprite] or {}
            local startValue = shaderObjectBase[obj][sprite][param] or (shaderBase[sprite][param] or 0)
            local tween = {
                type = "tweenObj",
                objects = {obj},
                sprite = sprite,
                param = param,
                start = startValue,
                target = targetValue,
                diff = targetValue - startValue,
                duration = duration,
                elapsed = 0,
                easeType = easeType
            }
            table.insert(shaderObjectTweens, tween)
        end
    end
end
function pulseShaderSum(param, amount, totalDuration, camera)
    if not param or type(amount) ~= "number" then return end
    totalDuration = totalDuration or 2
    if totalDuration <= 0 then totalDuration = 0.001 end
    camera = camera or "all"
    local sprites = getSpritesForParam(camera, param)
    for _, sprite in ipairs(sprites) do
        local pulse = {
            type = "pulse",
            param = param,
            amount = amount,
            fadeIn = totalDuration / 2,
            fadeOut = totalDuration / 2,
            total = totalDuration,
            elapsed = 0,
            sprite = sprite
        }
        table.insert(shaderPulses, pulse)
    end
end
local function contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end
function pulseShaderFlash(param, amount, fadeOut, fadeIn, camera)
    if not param or type(amount) ~= "number" then return end
    fadeOut = (type(fadeOut) == "number") and fadeOut or 0.5
    fadeIn = (type(fadeIn) == "number") and fadeIn or 0
    camera = camera or "all"
    local cameraParams = {"czoom", "cangle", "cx", "cy", "cwarph", "cwarpv", "cuwarph", "cuwarpv"}
    local isCameraParam = contains(cameraParams, param)
    local sprites = getSpritesForParam(camera, param)
    for _, sprite in ipairs(sprites) do
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
        if isCameraParam then
            local callbackDelay = fadeIn + fadeOut
            table.insert(shaderPulses, {
                type = "callback",
                elapsed = 0,
                delay = callbackDelay,
                callback = (function(pSprite, pParam, pBase, pCamera)
                    return function()
                        TweenShadersin(pParam, pBase, 0.4, "smoothStepInOut", pCamera)
                    end
                end)(sprite, param, baseValue, camera)
            })
        end
    end
end
function pulseShaderObject(objectNames, param, amount, fadeOut, fadeIn, camera)
    if not objectNames or not param or type(amount) ~= "number" then return end
    if type(objectNames) == "string" then objectNames = {objectNames} end
    fadeOut = fadeOut or 0.5
    fadeIn = fadeIn or 0
    camera = camera or "all"
    local sprites = getShaderSprites(camera)
    for _, obj in ipairs(objectNames) do
        for _, sprite in ipairs(sprites) do
            runHaxeCode([[
                var spr = game.getLuaObject("]]..obj..[[");
                if (spr != null) {
                    if (spr.shader == null) {
                        var sh = game.createRuntimeShader("]]..shaderName..[[");
                        spr.shader = sh;
                    }
                }
            ]])
            shaderObjectBase[obj] = shaderObjectBase[obj] or {}
            shaderObjectBase[obj][sprite] = shaderObjectBase[obj][sprite] or {}
            if shaderObjectBase[obj][sprite][param] == nil then
                shaderObjectBase[obj][sprite][param] = shaderBase[sprite][param] or 0
            end
        end
    end
    local sprites = getShaderSprites(camera)
    for _, sprite in ipairs(sprites) do
        local pulse = {
            objects = objectNames,
            param = param,
            amount = amount,
            fadeIn = fadeIn,
            fadeOut = fadeOut,
            total = fadeIn + fadeOut,
            elapsed = 0,
            sprite = sprite
        }
        table.insert(shaderObjectPulses, pulse)
    end
end
function ShaderInst(param, value, camera)
    if not param or type(value) ~= "number" then return end
    camera = camera or "all"
    
    local sprites = getSpritesForParam(camera, param)
    for _, sprite in ipairs(sprites) do
        shaderBase[sprite][param] = value
        setShaderFloat(sprite, param, value)
    end
end
function TweenShadersin(param, targetValue, duration, easeType, camera)
    if not param or type(targetValue) ~= "number" or type(duration) ~= "number" then return end
    camera = camera or "all"
    local sprites = getSpritesForParam(camera, param)
    for _, sprite in ipairs(sprites) do
        local startValue = shaderBase[sprite][param] or 0
        local tween = {
            type = "tween",
            param = param,
            start = startValue,
            target = targetValue,
            diff = targetValue - startValue,
            duration = duration,
            elapsed = 0,
            easeType = easeType or 'linear',
            sprite = sprite
        }
        table.insert(shaderPulses, tween)
    end
end
function setHalationMode(mode, camera)
    ShaderInst("halationPosition", mode or 1, camera)
end
function setHalationClones(count, camera)
    ShaderInst("halationClone", count or 1, camera)
end
function ColorFillInst(r, g, b, fade, camera)
    ShaderInst("colorFillR", r or 255, camera)
    ShaderInst("colorFillG", g or 255, camera)
    ShaderInst("colorFillB", b or 255, camera)
    ShaderInst("colorFillFade", fade or 1.0, camera)
end
function TweenColorFill(r, g, b, fade, duration, easeType, camera)
    TweenShadersin("colorFillR", r or (shaderBase["colorFillR"] or 255), duration, easeType, camera)
    TweenShadersin("colorFillG", g or (shaderBase["colorFillG"] or 255), duration, easeType, camera)
    TweenShadersin("colorFillB", b or (shaderBase["colorFillB"] or 255), duration, easeType, camera)
    TweenShadersin("colorFillFade", fade or (shaderBase["colorFillFade"] or 1.0), duration, easeType, camera)
end
function pulseColorFill(r, g, b, fade, fadeOut, fadeIn, camera)
    pulseShaderFlash("colorFillR", (r or 255) - (shaderBase["colorFillR"] or 255), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorFillG", (g or 255) - (shaderBase["colorFillG"] or 255), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorFillB", (b or 255) - (shaderBase["colorFillB"] or 255), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorFillFade", (fade or 1.0) - (shaderBase["colorFillFade"] or 1.0), fadeOut, fadeIn, camera)
end
function ColorOverrideInst(r, g, b, camera)
    ShaderInst("colorOverrideR", r or 1.0, camera)
    ShaderInst("colorOverrideG", g or 1.0, camera)
    ShaderInst("colorOverrideB", b or 1.0, camera)
end
function TweenColorOverride(r, g, b, duration, easeType, camera)
    TweenShadersin("colorOverrideR", r or (shaderBase["colorOverrideR"] or 1.0), duration, easeType, camera)
    TweenShadersin("colorOverrideG", g or (shaderBase["colorOverrideG"] or 1.0), duration, easeType, camera)
    TweenShadersin("colorOverrideB", b or (shaderBase["colorOverrideB"] or 1.0), duration, easeType, camera)
end
function pulseColorOverride(r, g, b, fadeOut, fadeIn, camera)
    pulseShaderFlash("colorOverrideR", (r or 1.0) - (shaderBase["colorOverrideR"] or 1.0), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorOverrideG", (g or 1.0) - (shaderBase["colorOverrideG"] or 1.0), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorOverrideB", (b or 1.0) - (shaderBase["colorOverrideB"] or 1.0), fadeOut, fadeIn, camera)
end
function ColorSwapInst(hue, sat, brt, camera)
    ShaderInst("colorSwapHue", hue or 0.0, camera)
    ShaderInst("colorSwapSat", sat or 0.0, camera)
    ShaderInst("colorSwapBrt", brt or 0.0, camera)
end
function TweenColorSwap(hue, sat, brt, duration, easeType, camera)
    TweenShadersin("colorSwapHue", hue or (shaderBase["colorSwapHue"] or 0.0), duration, easeType, camera)
    TweenShadersin("colorSwapSat", sat or (shaderBase["colorSwapSat"] or 0.0), duration, easeType, camera)
    TweenShadersin("colorSwapBrt", brt or (shaderBase["colorSwapBrt"] or 0.0), duration, easeType, camera)
end
function pulseColorSwap(hue, sat, brt, fadeOut, fadeIn, camera)
    pulseShaderFlash("colorSwapHue", (hue or 0.0) - (shaderBase["colorSwapHue"] or 0.0), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorSwapSat", (sat or 0.0) - (shaderBase["colorSwapSat"] or 0.0), fadeOut, fadeIn, camera)
    pulseShaderFlash("colorSwapBrt", (brt or 0.0) - (shaderBase["colorSwapBrt"] or 0.0), fadeOut, fadeIn, camera)
end
function ColorFillObjectInst(objs, r, g, b, fade, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    
    for _, obj in ipairs(objs) do
        ObjectSInst({obj}, "colorFillR", r or 255, camera)
        ObjectSInst({obj}, "colorFillG", g or 255, camera)
        ObjectSInst({obj}, "colorFillB", b or 255, camera)
        ObjectSInst({obj}, "colorFillFade", fade or 1.0, camera)
    end
end
function TweenColorFillObject(objs, r, g, b, fade, duration, easeType, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        TweenObjShader({obj}, "colorFillR", r or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorFillR"] or shaderBase["colorFillR"] or 255), duration, easeType, camera)
        TweenObjShader({obj}, "colorFillG", g or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorFillG"] or shaderBase["colorFillG"] or 255), duration, easeType, camera)
        TweenObjShader({obj}, "colorFillB", b or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorFillB"] or shaderBase["colorFillB"] or 255), duration, easeType, camera)
        TweenObjShader({obj}, "colorFillFade", fade or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorFillFade"] or shaderBase["colorFillFade"] or 1.0), duration, easeType, camera)
    end
end
function pulseColorFillObject(objs, r, g, b, fade, fadeOut, fadeIn, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        for _, sprite in ipairs(getShaderSprites(camera)) do
            local baseR = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorFillR"] or shaderBase[sprite]["colorFillR"] or 255
            local baseG = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorFillG"] or shaderBase[sprite]["colorFillG"] or 255
            local baseB = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorFillB"] or shaderBase[sprite]["colorFillB"] or 255
            local baseFade = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorFillFade"] or shaderBase[sprite]["colorFillFade"] or 1.0
            pulseShaderObject({obj}, "colorFillR", (r or 255) - baseR, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorFillG", (g or 255) - baseG, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorFillB", (b or 255) - baseB, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorFillFade", (fade or 1.0) - baseFade, fadeOut, fadeIn, camera)
        end
    end
end
function ColorOverrideObjectInst(objs, r, g, b, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        ObjectSInst({obj}, "colorOverrideR", r or 1.0, camera)
        ObjectSInst({obj}, "colorOverrideG", g or 1.0, camera)
        ObjectSInst({obj}, "colorOverrideB", b or 1.0, camera)
    end
end
function TweenColorOverrideObject(objs, r, g, b, duration, easeType, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        TweenObjShader({obj}, "colorOverrideR", r or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorOverrideR"] or shaderBase["colorOverrideR"] or 1.0), duration, easeType, camera)
        TweenObjShader({obj}, "colorOverrideG", g or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorOverrideG"] or shaderBase["colorOverrideG"] or 1.0), duration, easeType, camera)
        TweenObjShader({obj}, "colorOverrideB", b or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorOverrideB"] or shaderBase["colorOverrideB"] or 1.0), duration, easeType, camera)
    end
end
function pulseColorOverrideObject(objs, r, g, b, fadeOut, fadeIn, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        for _, sprite in ipairs(getShaderSprites(camera)) do
            local baseR = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorOverrideR"] or shaderBase[sprite]["colorOverrideR"] or 1.0
            local baseG = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorOverrideG"] or shaderBase[sprite]["colorOverrideG"] or 1.0
            local baseB = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorOverrideB"] or shaderBase[sprite]["colorOverrideB"] or 1.0
            pulseShaderObject({obj}, "colorOverrideR", (r or 1.0) - baseR, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorOverrideG", (g or 1.0) - baseG, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorOverrideB", (b or 1.0) - baseB, fadeOut, fadeIn, camera)
        end
    end
end
function ColorSwapObjectInst(objs, hue, sat, brt, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        ObjectSInst({obj}, "colorSwapHue", hue or 0.0, camera)
        ObjectSInst({obj}, "colorSwapSat", sat or 0.0, camera)
        ObjectSInst({obj}, "colorSwapBrt", brt or 0.0, camera)
    end
end
function TweenColorSwapObject(objs, hue, sat, brt, duration, easeType, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        TweenObjShader({obj}, "colorSwapHue", hue or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorSwapHue"] or shaderBase["colorSwapHue"] or 0.0), duration, easeType, camera)
        TweenObjShader({obj}, "colorSwapSat", sat or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorSwapSat"] or shaderBase["colorSwapSat"] or 0.0), duration, easeType, camera)
        TweenObjShader({obj}, "colorSwapBrt", brt or (shaderObjectBase[obj] and shaderObjectBase[obj]["colorSwapBrt"] or shaderBase["colorSwapBrt"] or 0.0), duration, easeType, camera)
    end
end
function pulseColorSwapObject(objs, hue, sat, brt, fadeOut, fadeIn, camera)
    if type(objs) == "string" then objs = {objs} end
    camera = camera or "all"
    for _, obj in ipairs(objs) do
        for _, sprite in ipairs(getShaderSprites(camera)) do
            local baseHue = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorSwapHue"] or shaderBase[sprite]["colorSwapHue"] or 0.0
            local baseSat = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorSwapSat"] or shaderBase[sprite]["colorSwapSat"] or 0.0
            local baseBrt = shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite]["colorSwapBrt"] or shaderBase[sprite]["colorSwapBrt"] or 0.0
            pulseShaderObject({obj}, "colorSwapHue", (hue or 0.0) - baseHue, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorSwapSat", (sat or 0.0) - baseSat, fadeOut, fadeIn, camera)
            pulseShaderObject({obj}, "colorSwapBrt", (brt or 0.0) - baseBrt, fadeOut, fadeIn, camera)
        end
    end
end
function onUpdate(elapsed)
    shaderTime = shaderTime + elapsed
    local sprites = getTVSprites("all")
    for _, sprite in ipairs(sprites) do
        setShaderFloat(sprite, "time", shaderTime)
    end
    if #shaderPulses > 0 then
        local pulseAccumulators = {}
        for _, sprite in ipairs(sprites) do
            pulseAccumulators[sprite] = {}
        end
        for i = #shaderPulses, 1, -1 do
            local p = shaderPulses[i]
            p.elapsed = (p.elapsed or 0) + elapsed
            if p.type == "callback" then
                if (p.elapsed >= (p.delay or 0)) then
                    if type(p.callback) == "function" then
                        p.callback()
                    end
                    table.remove(shaderPulses, i)
                end
                goto continue_pulses
            end
            if p.type == "tween" then
                local delay = p.delay or 0
                local totalTime = (p.duration or 0) + delay
                if p.elapsed >= totalTime then
                    if not p.isTemporary then
                        shaderBase[p.sprite][p.param] = p.target
                    end
                    setShaderFloat(p.sprite, p.param, p.target)
                    table.remove(shaderPulses, i)
                    goto continue_pulses
                end
                if p.elapsed < delay then
                    goto continue_pulses
                end
                local effectiveElapsed = p.elapsed - delay
                local dur = math.max(0.0001, p.duration or 0.0001)
                local t = math.min(1, math.max(0, effectiveElapsed / dur))
                local easedT = t
                local et = p.easeType
                if et == 'quadIn' then easedT = t * t
                elseif et == 'quadOut' then easedT = 1 - (1 - t) * (1 - t)
                elseif et == 'quadInOut' then
                    if t < 0.5 then easedT = 2 * t * t else easedT = 1 - math.pow(-2 * t + 2, 2) / 2 end
                elseif et == 'cubicIn' then easedT = t * t * t
                elseif et == 'cubicOut' then easedT = 1 - math.pow(1 - t, 3)
                elseif et == 'cubicInOut' then
                    if t < 0.5 then easedT = 4 * t * t * t else easedT = 1 - math.pow(-2 * t + 2, 3) / 2 end
                elseif et == 'elasticOut' then
                    if t == 0 then easedT = 0 elseif t == 1 then easedT = 1 else easedT = math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi / 3)) + 1 end
                elseif et == 'smoothStepInOut' then
                    easedT = 3 * t * t - 2 * t * t * t
                end
                local startV = p.start or (shaderBase[p.sprite] and shaderBase[p.sprite][p.param]) or 0
                local diff = p.diff or ((p.target or 0) - startV)
                local value = startV + diff * easedT
                setShaderFloat(p.sprite, p.param, value)
                goto continue_pulses
            end
            if p.type == "pulse" then
                local contrib = 0
                if p.elapsed < (p.fadeIn or 0) then
                    local fi = p.fadeIn or 0
                    local t = (fi > 0) and (p.elapsed / fi) or 1
                    contrib = p.amount * t
                elseif p.elapsed < (p.total or 0) then
                    local fo = p.fadeOut or 0.0001
                    local t = (p.elapsed - (p.fadeIn or 0)) / fo
                    contrib = p.amount * (1 - t)
                else
                    table.remove(shaderPulses, i)
                    goto continue_pulses
                end
                if contrib ~= 0 then
                    pulseAccumulators[p.sprite][p.param] = (pulseAccumulators[p.sprite][p.param] or 0) + contrib
                end
            end
            ::continue_pulses::
        end
        for sprite, params in pairs(pulseAccumulators) do
            for param, totalContrib in pairs(params) do
                local base = shaderBase[sprite] and shaderBase[sprite][param] or 0
                setShaderFloat(sprite, param, base + totalContrib)
            end
        end
    end
    if #shaderObjectPulses > 0 then
        for i = #shaderObjectPulses, 1, -1 do
            local p = shaderObjectPulses[i]
            p.elapsed = p.elapsed + elapsed
            local contrib = 0
            if p.elapsed < p.fadeIn then
                local t = (p.fadeIn > 0) and (p.elapsed / p.fadeIn) or 1
                contrib = p.amount * t
            elseif p.elapsed < p.total then
                local t = (p.elapsed - p.fadeIn) / p.fadeOut
                contrib = p.amount * (1 - t)
            else
                table.remove(shaderObjectPulses, i)
            end
            if contrib ~= 0 then
                for _, obj in ipairs(p.objects) do
                    for _, sprite in ipairs(getShaderSprites("all")) do
                        local base = (shaderObjectBase[obj] and shaderObjectBase[obj][sprite] and shaderObjectBase[obj][sprite][p.param]) or (shaderBase[sprite][p.param] or 0)
                        runHaxeCode([[
                            var spr = game.getLuaObject("]]..obj..[[");
                            if (spr != null && spr.shader != null) {
                                spr.shader.data.]]..p.param..[[.value = [ ]]..(base + contrib)..[[ ];
                            }
                        ]])
                    end
                end
            end
        end
    end
    if #shaderObjectTweens > 0 then
        for i = #shaderObjectTweens, 1, -1 do
            local tw = shaderObjectTweens[i]
            tw.elapsed = tw.elapsed + elapsed
            if tw.elapsed >= tw.duration then
                for _, obj in ipairs(tw.objects) do
                    runHaxeCode([[
                        var spr = game.getLuaObject("]]..obj..[[");
                        if (spr != null && spr.shader != null) {
                            spr.shader.data.]]..tw.param..[[.value = [ ]]..tw.target..[[ ];
                        }
                    ]])
                    shaderObjectBase[obj] = shaderObjectBase[obj] or {}
                    shaderObjectBase[obj][tw.sprite] = shaderObjectBase[obj][tw.sprite] or {}
                    shaderObjectBase[obj][tw.sprite][tw.param] = tw.target
                end
                table.remove(shaderObjectTweens, i)
            else
                local t = tw.elapsed / tw.duration
                local easedT = t
                if tw.easeType == 'quadIn' then
                    easedT = t * t
                elseif tw.easeType == 'quadOut' then
                    easedT = 1 - (1 - t) * (1 - t)
                elseif tw.easeType == 'quadInOut' then
                    if t < 0.5 then
                        easedT = 2 * t * t
                    else
                        easedT = 1 - math.pow(-2 * t + 2, 2) / 2
                    end
                elseif tw.easeType == 'cubicIn' then
                    easedT = t * t * t
                elseif tw.easeType == 'cubicOut' then
                    easedT = 1 - math.pow(1 - t, 3)
                elseif tw.easeType == 'cubicInOut' then
                    if t < 0.5 then
                        easedT = 4 * t * t * t
                    else
                        easedT = 1 - math.pow(-2 * t + 2, 3) / 2
                    end
                elseif tw.easeType == 'elasticOut' then
                    if t == 0 then
                        easedT = 0
                    elseif t == 1 then
                        easedT = 1
                    else
                        easedT = math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi / 3)) + 1
                    end
                end
                local value = tw.start + tw.diff * easedT
                for _, obj in ipairs(tw.objects) do
                    runHaxeCode([[
                        var spr = game.getLuaObject("]]..obj..[[");
                        if (spr != null && spr.shader != null) {
                            spr.shader.data.]]..tw.param..[[.value = [ ]]..value..[[ ];
                        }
                    ]])
                end
            end
        end
    end
    if #flashObjectPulses > 0 then
        local acc = {}
        for i = #flashObjectPulses, 1, -1 do
            local f = flashObjectPulses[i]
            f.elapsed = f.elapsed + elapsed
            local contrib = 0
            if f.elapsed < f.fadeIn then
                local t = (f.fadeIn > 0) and (f.elapsed / f.fadeIn) or 1
                contrib = f.amount * t
            elseif f.elapsed < f.total then
                local t = (f.elapsed - f.fadeIn) / f.fadeOut
                contrib = f.amount * (1 - t)
            else
                table.remove(flashObjectPulses, i)
                local still = false
                for j = 1, #flashObjectPulses do
                    if flashObjectPulses[j].obj == f.obj then still = true; break end
                end
                if not still then
                    flashActiveObjects[f.obj] = nil
                    setProperty(f.obj .. ".alpha", 0)
                    setBlendMode(f.obj, "normal")
                end
            end
            if contrib > 0 then
                acc[f.obj] = (acc[f.obj] or 0) + contrib
            end
        end
        for obj, a in pairs(acc) do
            if getProperty(obj .. ".visible") == false then
                setProperty(obj .. ".alpha", 0)
            else
                if a > 1 then a = 1 end
                setProperty(obj .. ".alpha", a)
            end
        end
    end
end
function onEvent(name, v1, v2)
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
    local function parseObjects(str)
        local objects = {}
        if not str or str == "" then return objects end
        if string.sub(str, 1, 1) == "<" and string.sub(str, -1) == ">" then
            local content = string.sub(str, 2, -2)
            for obj in string.gmatch(content, "([^,]+)") do
                table.insert(objects, obj)
            end
        else
            for obj in string.gmatch(str, "([^,]+)") do
                table.insert(objects, obj)
            end
        end
        return objects
    end
    if name == "pulseShaderFlash" then
        local params, camera = parseCamera(v2)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        pulseShaderFlash(
            v1,
            args[1] or 1,
            args[2] or 0.5,
            args[3] or 0,
            camera
        )
    elseif name == "TweenShadersin" then
        local params, camera = parseCamera(v2)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        TweenShadersin(
            v1,
            args[1] or 0,
            args[2] or 1,
            args[3] or "linear",
            camera
        )
    elseif name == "ShaderInst" then
        local params, camera = parseCamera(v2)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        ShaderInst(
            v1,
            args[1] or 0,
            camera
        )
    elseif name == "flashentuano" then
        local args = {}
        for str in string.gmatch(v1 or "", "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        local color = v2 or ""
        if color == "" then
            color = "#FFFFFF"
        elseif color:sub(1, 1) ~= "#" then
            color = "#" .. color
        end
        flashentuano(
            args[1] or 1,
            args[2] or 0,
            args[3] or 0.5,
            color
        )
    elseif name == "pulseShaderObject" then
        local objects = parseObjects(v1)
        local params, camera = parseCamera(v2)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        pulseShaderObject(
            objects,
            args[1] or "brightness",
            args[2] or 1,
            args[3] or 0.5,
            args[4] or 0,
            camera
        )
    elseif name == "ObjectSInst" then
        local objects = parseObjects(v1)
        local params, camera = parseCamera(v2)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        ObjectSInst(
            objects,
            args[1] or "brightness",
            args[2] or 0,
            camera
        )
    elseif name == "TweenObjShader" then
        local objects = parseObjects(v1)
        local params, camera = parseCamera(v2)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        TweenObjShader(
            objects,
            args[1] or "brightness",
            args[2] or 0,
            args[3] or 1,
            args[4] or "linear",
            camera
        )
    elseif name == "pulseColorSwap" then
        local args1 = {}
        for str in string.gmatch(v1 or "", "([^,]+)") do
            table.insert(args1, tonumber(str) or str)
        end
        local params, camera = parseCamera(v2)
        local args2 = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args2, tonumber(str) or str)
        end
        pulseColorSwap(
            args1[1] or 0,
            args1[2] or 0,
            args1[3] or 0,
            args2[1] or 0.5,
            args2[2] or 0,
            camera
        )
    elseif name == "ColorFillInst" then
        local params, camera = parseCamera(v1)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        ColorFillInst(
            args[1] or 255,
            args[2] or 255,
            args[3] or 255,
            args[4] or 1,
            camera
        )
    elseif name == "ColorOverrideInst" then
        local params, camera = parseCamera(v1)
        local args = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args, tonumber(str) or str)
        end
        ColorOverrideInst(
            args[1] or 1,
            args[2] or 1,
            args[3] or 1,
            camera
        )
    elseif name == "pulseColorOverride" then
        local args1 = {}
        for str in string.gmatch(v1 or "", "([^,]+)") do
            table.insert(args1, tonumber(str) or str)
        end
        local params, camera = parseCamera(v2)
        local args2 = {}
        for str in string.gmatch(params, "([^,]+)") do
            table.insert(args2, tonumber(str) or str)
        end
        pulseColorOverride(
            args1[1] or 1,
            args1[2] or 1,
            args1[3] or 1,
            args2[1] or 0.5,
            args2[2] or 0,
            camera
        )
    end
end
function setShaderBaseFloat(param, value, camera)
    camera = camera or "all"
    local sprites = getSpritesForParam(camera, param)
    for _, sprite in ipairs(sprites) do
        shaderBase[sprite][param] = value or 0
        setShaderFloat(sprite, param, shaderBase[sprite][param])
    end
end
function onCreate()
    shaderCoordFix()
    local filterCode = 'game.camGame.filters = ['
    local hudCode    = 'game.camHUD.filters = ['
    local firstGame  = true
    local firstHUD   = true
    local function addFilter(spriteName, shader, force)
        makeLuaSprite(spriteName)
        makeGraphic(spriteName, screenWidth, screenHeight)
        setSpriteShader(spriteName, shader, force)
        return 'new ShaderFilter(game.getLuaObject("' .. spriteName .. '").shader)'
    end
    local function pushFilter(camName, filterEntry)
        if camName == 'camGame' then
            if not firstGame then filterCode = filterCode .. ', ' end
            filterCode = filterCode .. filterEntry
            firstGame = false
        elseif camName == 'camHUD' then
            if not firstHUD then hudCode = hudCode .. ', ' end
            hudCode = hudCode .. filterEntry
            firstHUD = false
        end
    end
    for camName, spriteName in pairs(cameraToShaderSprite) do
        pushFilter(camName, addFilter(spriteName, cameraShaderName, true))
    end
    if shadersOn then
        for camName, spriteName in pairs(cameraToTVSprite) do
            pushFilter(camName, addFilter(spriteName, tvShaderName, false))
        end
    end
    filterCode = filterCode .. ']; return;'
    hudCode    = hudCode    .. ']; return;'
    runHaxeCode(filterCode)
    runHaxeCode(hudCode)
    makeLuaSprite('flashentuanito', '', 0, -250);
    makeGraphic('flashentuanito',1920,1080,'FFFFFF')
    setLuaSpriteScrollFactor('flashentuanito',0,0)
    setProperty('flashentuanito.scale.x',2)
    setProperty('flashentuanito.scale.y',2)
    setProperty('flashentuanito.alpha',0)
    setObjectCamera('flashentuanito', 'camOther')
    setBlendMode('flashentuanito', 'add');
    addLuaSprite('flashentuanito', true);
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
        FlxG.signals.gameResized.add(fixShaderCoordFix);
        fixShaderCoordFix();
    ]])
    local temp = onDestroy
    function onDestroy()
        runHaxeCode([[ FlxG.signals.gameResized.remove(fixShaderCoordFix); ]])
        if temp then temp() end
    end
end