-- El código base por Raimbowcore12. Fue más fácil de lo que pensaba LOL, aunque esto ya lo hice hace mucho antes que esto.

local CustomCamera = true -- Activa la custom cámara. Desactívalo si prefieres la normal de siempre.

local jsonCameraSettings = { -- Todo lo que tienes que poner en el JSON.

    mustHitSection = true,

    BFx = 0,
    BFy = 0,

    DADx = 0,
    DADy = 0,

    GFx = 0,
    GFy = 0,

    MiddleCamera = true,
    MiddleX = 0,
    MiddleY = 0,

    OverrideZoom = false,

    OGZoom = 0.7,
    MiddleZoom = 0.6,

    OffsetsBF = 25,
    OffsetsDAD = 25,
    OffsetsGF = 25,

    Angle = 0,
	DADAngle = 0
}


function onCreate()
    if checkFileExists('data/'..songPath..'/cameraSettings.json') then
        local Json = callMethodFromClass('tjson.TJSON', 'parse', {getTextFromFile('data/'..songPath..'/cameraSettings.json')})
        for si, no in pairs(Json) do
            if no ~= nil then jsonCameraSettings[si] = no end
        end
    end

	if songPath == 'prey' then
		CustomCamera = false
		close()
	end
	if curStage == 'stage' then
		Stage()
	end
end

function onCreatePost()
	if songName == 'Uh-Oh' then
		triggerEvent('Tweening Camera', '-320, 0', '0.001, linear')
		triggerEvent('Tween Camera Zoom', '1.4, true', '0.001, linear')
		setProperty('cameraSpeed', 1000000)
	end
end

function Stage()
	jsonCameraSettings.mustHitSection = false

    jsonCameraSettings.BFx = 850
    jsonCameraSettings.BFy = 520

    jsonCameraSettings.DADx = 500
    jsonCameraSettings.DADy = 380

    jsonCameraSettings.GFx = 0
    jsonCameraSettings.GFy = 0

    jsonCameraSettings.MiddleCamera = false
    jsonCameraSettings.MiddleX = 620
    jsonCameraSettings.MiddleY = 400

    jsonCameraSettings.OverrideZoom = false

    jsonCameraSettings.OGZoom = 0.9
    jsonCameraSettings.MiddleZoom = 0.7

    jsonCameraSettings.OffsetsBF = 25
    jsonCameraSettings.OffsetsDAD = 25
    jsonCameraSettings.OffsetsGF = 25

    jsonCameraSettings.Angle = 0
	jsonCameraSettings.DADAngle = 0
end



-- Cosas de cámara. No tocar si no sabes lo que ves. --
function onUpdate()
    -- Esto lo ponía yo para los cutscenes de mi proyecto. Por si acaso los dejo aquí.
            setProperty('camFollow.x', BFx)
            setProperty('camFollow.y', BFy)
            setProperty('cameraFollowPos.x', BFx)
            setProperty('cameraFollowPos.y', BFy)
    if CustomCamera then
		if gfSection then
			local gfTarget = (getProperty('gf.isAnimateAtlas') and getProperty('gf._lastPlayedAnimation') or getProperty('gf.animation.curAnim.name'))
			if gfTarget == 'singLEFT' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.GFx - jsonCameraSettings.OffsetsGF, jsonCameraSettings.GFy)
                doTweenAngle('camGameAngleMovement', 'camGame', - jsonCameraSettings.Angle, 0.6, 'quadOut')

			elseif gfTarget == 'singRIGHT' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.GFx + jsonCameraSettings.OffsetsGF, jsonCameraSettings.GFy)
                doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.Angle, 0.6, 'quadOut')

			elseif gfTarget == 'singUP' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.GFx, jsonCameraSettings.GFy - jsonCameraSettings.OffsetsGF)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

			elseif gfTarget == 'singDOWN' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.GFx, jsonCameraSettings.GFy + jsonCameraSettings.OffsetsGF)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

			elseif gfTarget == 'idle' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.GFx, jsonCameraSettings.GFy)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
			else
				triggerEvent('Camera Follow Pos', jsonCameraSettings.GFx, jsonCameraSettings.GFy)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
			end
		else
			if mustHitSection == false then
				local dadTarget = (getProperty('dad.isAnimateAtlas') and getProperty('dad._lastPlayedAnimation') or getProperty('dad.animation.curAnim.name'))
				if dadTarget == 'singLEFT' or dadTarget == 'singLEFT-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx - jsonCameraSettings.OffsetsDAD, jsonCameraSettings.DADy)
                    doTweenAngle('camGameAngleMovement', 'camGame', - jsonCameraSettings.DADAngle, 0.6, 'quadOut')

				elseif dadTarget == 'singRIGHT' or dadTarget == 'singRIGHT-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx + jsonCameraSettings.OffsetsDAD, jsonCameraSettings.DADy)
                    doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.DADAngle, 0.6, 'quadOut')

				elseif dadTarget == 'singUP' or dadTarget == 'singUP-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx, jsonCameraSettings.DADy - jsonCameraSettings.OffsetsDAD)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif dadTarget == 'singDOWN' or dadTarget == 'singDOWN-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx, jsonCameraSettings.DADy + jsonCameraSettings.OffsetsDAD)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif dadTarget == 'idle' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx, jsonCameraSettings.DADy)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				else
					triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx, jsonCameraSettings.DADy)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
				end
			else
				local bfTarget = (getProperty('boyfriend.isAnimateAtlas') and getProperty('boyfriend._lastPlayedAnimation') or getProperty('boyfriend.animation.curAnim.name'))
				if bfTarget == 'singLEFT' or bfTarget == 'singLEFT-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx - jsonCameraSettings.OffsetsBF, jsonCameraSettings.BFy)
                    doTweenAngle('camGameAngleMovement', 'camGame', - jsonCameraSettings.Angle, 0.6, 'quadOut')


				elseif bfTarget == 'singRIGHT' or bfTarget == 'singRIGHT-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx + jsonCameraSettings.OffsetsBF, jsonCameraSettings.BFy)
                    doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.Angle, 0.6, 'quadOut')


				elseif bfTarget == 'singUP' or bfTarget == 'singUP-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx , jsonCameraSettings.BFy - jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')


				elseif bfTarget == 'singDOWN' or bfTarget == 'singDOWN-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx , jsonCameraSettings.BFy + jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')


				elseif bfTarget == 'singLEFTmiss' or bfTarget == 'singLEFTmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx - jsonCameraSettings.OffsetsBF, jsonCameraSettings.BFy)
                    doTweenAngle('camGameAngleMovement', 'camGame', - jsonCameraSettings.Angle, 0.6, 'quadOut')


				elseif bfTarget == 'singRIGHTmiss' or bfTarget == 'singRIGHTmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx + jsonCameraSettings.OffsetsBF, jsonCameraSettings.BFy)
                    doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.Angle, 0.6, 'quadOut')


				elseif bfTarget == 'singUPmiss' or bfTarget == 'singUPmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx, jsonCameraSettings.BFy - jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')


				elseif bfTarget == 'singDOWNmiss' or bfTarget == 'singDOWNmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx, jsonCameraSettings.BFy + jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')


				elseif bfTarget == 'idle' or bfTarget == 'idle-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx, jsonCameraSettings.BFy)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
				else
					triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx, jsonCameraSettings.BFy)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
				end
			end
		end

	if jsonCameraSettings.MiddleCamera then
		if gfSection then
			local gfTarget = (getProperty('gf.isAnimateAtlas') and getProperty('gf._lastPlayedAnimation') or getProperty('gf.animation.curAnim.name'))
			if gfTarget == 'singLEFT' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX - jsonCameraSettings.OffsetsGF, jsonCameraSettings.MiddleY)
                doTweenAngle('camGameAngleMovement', 'camGame', -jsonCameraSettings.Angle, 0.6, 'quadOut')
			
			elseif gfTarget == 'singRIGHT' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX + jsonCameraSettings.OffsetsGF, jsonCameraSettings.MiddleY)
                doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.Angle, 0.6, 'quadOut')
			
			elseif gfTarget == 'singUP' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX,jsonCameraSettings. MiddleY -jsonCameraSettings. OffsetsGF)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
			
			elseif gfTarget == 'singDOWN' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY + jsonCameraSettings.OffsetsGF)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
			
			elseif gfTarget == 'idle' then
				triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

			else

				triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX,jsonCameraSettings.MiddleY)
                doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
			end
		else
			if mustHitSection == false then
				local dadTarget = (getProperty('dad.isAnimateAtlas') and getProperty('dad._lastPlayedAnimation') or getProperty('dad.animation.curAnim.name'))
				if dadTarget == 'singLEFT' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX - jsonCameraSettings.OffsetsDAD, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', -jsonCameraSettings.DADAngle, 0.6, 'quadOut')

				elseif dadTarget == 'singRIGHT' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX + jsonCameraSettings.OffsetsDAD, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.DADAngle, 0.6, 'quadOut')

				elseif dadTarget == 'singUP' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY - jsonCameraSettings.OffsetsDAD)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif dadTarget == 'singDOWN' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY + jsonCameraSettings.OffsetsDAD)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif dadTarget == 'idle' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
				else
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')
				end
			else
				local bfTarget = (getProperty('boyfriend.isAnimateAtlas') and getProperty('boyfriend._lastPlayedAnimation') or getProperty('boyfriend.animation.curAnim.name'))
				if bfTarget == 'singLEFT' or bfTarget == 'singLEFT-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX - jsonCameraSettings.OffsetsBF, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', -jsonCameraSettings.Angle, 0.6, 'quadOut')

				elseif bfTarget == 'singRIGHT' or bfTarget == 'singRIGHT-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX + jsonCameraSettings.OffsetsBF, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', jsonCameraSettings.Angle, 0.6, 'quadOut')

				elseif bfTarget == 'singUP' or bfTarget == 'singUP-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX , jsonCameraSettings.MiddleY - jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif bfTarget == 'singDOWN' or bfTarget == 'singDOWN-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX , jsonCameraSettings.MiddleY + jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif bfTarget == 'singLEFTmiss' or bfTarget == 'singLEFTmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX -jsonCameraSettings.OffsetsBF, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', -jsonCameraSettings.Angle, 0.6, 'quadOut')

				elseif bfTarget == 'singRIGHTmiss' or bfTarget == 'singRIGHTmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX + jsonCameraSettings.OffsetsBF, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif bfTarget == 'singUPmiss' or bfTarget == 'singUPmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY - jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif bfTarget == 'singDOWNmiss' or bfTarget == 'singDOWNmiss-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY + jsonCameraSettings.OffsetsBF)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut')

				elseif bfTarget == 'idle' or bfTarget == 'idle-alt' then
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut') 
				else
					triggerEvent('Camera Follow Pos', jsonCameraSettings.MiddleX, jsonCameraSettings.MiddleY)
                    doTweenAngle('camGameAngleMovement', 'camGame', 0, 0.6, 'quadOut') 
				end
			end
		end
			if not jsonCameraSettings.OverrideZoom then
				setProperty('defaultCamZoom', jsonCameraSettings.MiddleZoom)
			end
		else
			if not jsonCameraSettings.OverrideZoom then
				--OverrideZoom = false
				setProperty('defaultCamZoom', jsonCameraSettings.OGZoom) -- your normal zoom
			end
		end
	end

	if curStage == 'starved' then setProperty('boyfriend.alpha', lerp(getProperty('boyfriend.alpha'), targetAlpha, 0.1 * playbackRate)) end
end

local xeno = false
local sectionZoom = false
function onEvent(name, v1, v2)
	if name == 'Tween Camera Zoom' then
		jsonCameraSettings.OverrideZoom = true -- Permite que se puedan hacer cámara zooms sin que vuelva a su sitio con este evento.
	end
	if name == 'Set customCamera Zoom' then
        --v1: OGZoom o MiddleZoom
        v1 = v2
        jsonCameraSettings.OverrideZoom = false
    end
    if name == 'Set Camera Position' then
        local split = stringSplit(v2, ', ')
        if v1 == 'bf' then
            jsonCameraSettings.BFx = split[1]
            jsonCameraSettings.BFy = split[2]
        elseif v1 == 'dad' then
            jsonCameraSettings.DADx = split[1]
            jsonCameraSettings.DADy = split[2]
        elseif v1 == 'gf' then
            jsonCameraSettings.GFx = split[1]
            jsonCameraSettings.GFy = split[2]
        end
    end
	if name == 'cameracenter' then
		local damiddl = 'false'
		if v1 == 'true' then damiddl = true elseif v1 == 'false' then damiddl = false end
		jsonCameraSettings.MiddleCamera = damiddl
		jsonCameraSettings.OverrideZoom = false
	end

	if name == 'tripletroublebgchange' then
		if v1 == 'xeno' then
			jsonCameraSettings.OverrideZoom = false
			xeno = true

			jsonCameraSettings.BFx = 1250
			jsonCameraSettings.BFy = 1000

			jsonCameraSettings.DADx = 850
			jsonCameraSettings.DADy = 850
		end
		if v1 == 'xeno2' then
			jsonCameraSettings.OverrideZoom = false
			xeno = true

			jsonCameraSettings.BFx = 650
			jsonCameraSettings.BFy = 1000

			jsonCameraSettings.DADx = 1200
			jsonCameraSettings.DADy = 850
		end
		if v1 == 'xeno3' then
			jsonCameraSettings.OverrideZoom = false
			xeno = true

			jsonCameraSettings.BFx = 1250
			jsonCameraSettings.BFy = 1000

			jsonCameraSettings.DADx = 850
			jsonCameraSettings.DADy = 850
		end
		if v1 == 'knux' then
			jsonCameraSettings.OverrideZoom = false
			xeno = false

			jsonCameraSettings.BFx = 650
			jsonCameraSettings.BFy = 850

			jsonCameraSettings.DADx = 1150
			jsonCameraSettings.DADy = 850
		end
		if v1 == 'egg' then
			jsonCameraSettings.OverrideZoom = false
			xeno = false

			jsonCameraSettings.BFx = 1200
			jsonCameraSettings.BFy = 850

			jsonCameraSettings.DADx = 700
			jsonCameraSettings.DADy = 850
		end
	end

	if name == 'yourselfEvents' then
		if v1 == 'yourselfTime' then
			jsonCameraSettings.DADx = 1350
			jsonCameraSettings.DADy = 1000

			jsonCameraSettings.BFx = 2200
			jsonCameraSettings.BFy = 1150

			jsonCameraSettings.OffsetsBF = 10
			jsonCameraSettings.OffsetsDAD = 10
		end
		if v1 == 'showOffNewStage' then
			jsonCameraSettings.MiddleX = 1730
			jsonCameraSettings.MiddleY = 950

			jsonCameraSettings.DADx = 1350
			jsonCameraSettings.DADy = 890

			jsonCameraSettings.BFx = 2090
			jsonCameraSettings.BFy = 1200

			jsonCameraSettings.OGZoom = 1.05
		end
		if v1 == 'changeMiddlePos' then
			jsonCameraSettings.MiddleX = 1730
			jsonCameraSettings.MiddleY = 1100

			jsonCameraSettings.DADx = 1350
			jsonCameraSettings.DADy = 1000

			jsonCameraSettings.BFx = 2200
			jsonCameraSettings.BFy = 1150

			jsonCameraSettings.OGZoom = 1
		end
	end
	if name == 'sexxxxxx' then
		if v1 == 'newbg' then
			jsonCameraSettings.DADy = 110
			jsonCameraSettings.MiddleY = 305
		end
	end
	if name == 'OverrideZoom' then jsonCameraSettings.OverrideZoom = false end

	if name == 'cameraZooming' then
		local damiddlzoom = 'false'
		if v1 == 'true' then damiddlzoom = true elseif v1 == 'false' then damiddlzoom = false end
		setProperty('camZooming', damiddlzoom)
	end
	if name == 'hellbentEvents' then
		if v1 == 'changeBG' then
			jsonCameraSettings.BFx = 500
			jsonCameraSettings.BFy = 1100

			jsonCameraSettings.DADx = -80
			jsonCameraSettings.DADy = 1100

  			jsonCameraSettings.MiddleY = 1000

			jsonCameraSettings.OGZoom = 0.75

			doTweenX("coolCamX", "camGame.targetOffset", 350, 0.0001)
        	doTweenY("coolCamY", "camGame.targetOffset", 80, 0.0001)
			triggerEvent('Camera Follow Pos', jsonCameraSettings.BFx + 350, jsonCameraSettings.BFy)
			setProperty('camGame.zoom', 0.75)
			callMethod('camGame.snapToTarget')
		end
	end
	if name == 'fateEvents' then
		if v1 == 'part2' and v2 == '' then
			jsonCameraSettings.BFx = 2100
			jsonCameraSettings.BFy = 1300

			jsonCameraSettings.DADx = 1650
			jsonCameraSettings.DADy = 1300

			jsonCameraSettings.GFx = 250 -- No se LOL
			jsonCameraSettings.GFy = 590

			jsonCameraSettings.MiddleCamera = true
			jsonCameraSettings.MiddleX = 1830
			jsonCameraSettings.MiddleY = 1230

			jsonCameraSettings.OverrideZoom = false

			jsonCameraSettings.OGZoom = 0.5
			jsonCameraSettings.MiddleZoom = 0.45

			jsonCameraSettings.OffsetsBF = 25
			jsonCameraSettings.OffsetsDAD = 25
			jsonCameraSettings.OffsetsGF = 25
		elseif v2 == 'sad' then
			jsonCameraSettings.BFx = 2250
			jsonCameraSettings.BFy = 1450

			jsonCameraSettings.DADx = 1450
			jsonCameraSettings.DADy = 1250
		end
		if v1 == 'part4' and v2 == '' then
			sectionZoom = true
			jsonCameraSettings.BFx = 1400
			jsonCameraSettings.BFy = 800

			jsonCameraSettings.DADx = 850
			jsonCameraSettings.DADy = 500

			jsonCameraSettings.GFx = 250 -- No se LOL
			jsonCameraSettings.GFy = 590

			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.MiddleX = 1200
			jsonCameraSettings.MiddleY = 720

			jsonCameraSettings.OverrideZoom = false

			jsonCameraSettings.OGZoom = 0.7
			jsonCameraSettings.MiddleZoom = 0.58

			jsonCameraSettings.OffsetsBF = 25
			jsonCameraSettings.OffsetsDAD = 25
			jsonCameraSettings.OffsetsGF = 25
		end
	end
	if name == 'slashchangeBG' then
		triggerEvent('Change Character', 'dad', 'sl4shfront')

		jsonCameraSettings.BFx = 330
		jsonCameraSettings.BFy = 250

		jsonCameraSettings.DADx = 330
		jsonCameraSettings.DADy = 250

		jsonCameraSettings.OGZoom = 0.71
		runTimer('xfd', 0.01)
		setProperty('camGame.zoom', 0.7)
	end

	if name == 'soullesEvents' then
		if v1 == 'startcam' then
			setProperty('camZooming', true)
			jsonCameraSettings.MiddleY = 600
		end
	end
	if name == 'BGchange' then
		if v1 == 'blackout' then
			jsonCameraSettings.BFx = 1400
			jsonCameraSettings.BFy = 1500

			jsonCameraSettings.DADx = 1600
			jsonCameraSettings.DADy = 1100

			jsonCameraSettings.GFx = 1800 -- No se LOL
			jsonCameraSettings.GFy = 1500
			runTimer('xfd', 0.05)
		end

		if v1 == 'blackin' then
			jsonCameraSettings.BFx = 1400
			jsonCameraSettings.BFy = 1000

			jsonCameraSettings.DADx = 2100
			jsonCameraSettings.DADy = 650

			jsonCameraSettings.GFx = 1400 -- No se LOL
			jsonCameraSettings.GFy = 1000
			runTimer('xfd', 0.05)
		end

		if v1 == 'jajaja' then
			jsonCameraSettings.OGZoom = 0.83
			jsonCameraSettings.BFx = 1300
			jsonCameraSettings.BFy = 1300

			jsonCameraSettings.DADx = 1630
			jsonCameraSettings.DADy = 1200

			triggerEvent('Camera Follow Pos', jsonCameraSettings.DADx, jsonCameraSettings.DADy)
			setProperty('camGame.zoom', 1.25)
			callMethod('camGame.snapToTarget')
		end
	end
	if name == 'chaosEvent' then
		if v1 == 'bftransform' then
			jsonCameraSettings.BFx = 2900
			jsonCameraSettings.BFy = 1400
		end
	end
end

function onTimerCompleted(t) if t == 'xfd' then callMethod('camGame.snapToTarget') end end

local oldHitSection = false
function onSectionHit()
	if xeno == true then
		if mustHitSection then
			jsonCameraSettings.OGZoom = 0.75
		else
			jsonCameraSettings.OGZoom = 0.6
		end
	end

	if curStage == 'exe' then
		jsonCameraSettings.OverrideZoom = false
		if mustHitSection then
			if jsonCameraSettings.MiddleCamera then
				jsonCameraSettings.MiddleZoom = 0.6
			else
				jsonCameraSettings.OGZoom = 0.65
			end
		else
			if jsonCameraSettings.MiddleCamera then
				jsonCameraSettings.MiddleZoom = 0.5
			else
				jsonCameraSettings.OGZoom = 0.45
			end
		end
	end

	if curStage == 'god' then
		if oldHitSection ~= mustHitSection then
			jsonCameraSettings.OverrideZoom = false
			oldHitSection = mustHitSection
		end
		if mustHitSection then
			jsonCameraSettings.OGZoom = 0.6
		else
			jsonCameraSettings.OGZoom = 0.45
		end
	end

	if curStage == 'deception' and curBeat >= 128 then
		if oldHitSection ~= mustHitSection then
			jsonCameraSettings.OverrideZoom = false
			oldHitSection = mustHitSection
		end
		if mustHitSection then
			jsonCameraSettings.OGZoom = 0.83
		else
			jsonCameraSettings.OGZoom = 1.25
		end
	end


	if sectionZoom then
		jsonCameraSettings.OGZoom = (mustHitSection and 0.7 or 0.9)
		jsonCameraSettings.OverrideZoom = false
	end

	if curStage == 'forestall' then
		if mustHitSection then
			jsonCameraSettings.OGZoom = 0.55
		else
			jsonCameraSettings.OGZoom = 0.67
		end
	end

	if curStage == 'starved' then
		if mustHitSection then
			jsonCameraSettings.OGZoom = 0.83
			targetAlpha = 1
		else
			jsonCameraSettings.OGZoom = 1
			targetAlpha = 0.5
		end
	end
end

local firstone = true
function opponentNoteHit()
	if curStage == 'triple-trouble' and firstone then
		firstone = false
		jsonCameraSettings.MiddleCamera = false
	end
end

function onSongStart()
	if curStage == 'tooslow' then
		setProperty('cameraSpeed', 10000)
		jsonCameraSettings.OffsetsBF = 0
		jsonCameraSettings.OffsetsDAD = 0
		jsonCameraSettings.OffsetsGF = 0
		jsonCameraSettings.Angle = 0
 	end

	if curStage == 'triple-trouble' then jsonCameraSettings.OverrideZoom = false end

	if songName == 'Chaos' then
		jsonCameraSettings.MiddleCamera = false
	end
end

function onBeatHit()
	if curStage == 'ncd' then
		if curBeat >= 40 and jsonCameraSettings.MiddleZoom ~= 0.75 then
			jsonCameraSettings.MiddleZoom = 0.75
			jsonCameraSettings.MiddleX = 950
			jsonCameraSettings.MiddleY = 570
		end
	end
end

local sexogratisputocom = false
local sexitosxd2 = false
function onStepHit()
    -- STORY MODE --
	if curStage == 'tooslow' then
		if curStep == 1 then
			setProperty('cameraSpeed', 10000)
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 256 then
			setProperty('camZooming', false)
		end
		if curStep == 796 then
			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.OverrideZoom = false
			jsonCameraSettings.OffsetsBF = 25
			jsonCameraSettings.OffsetsDAD = 25
			jsonCameraSettings.OffsetsGF = 25
		end
		if curStep == 1184 or curStep == 1472 or curStep == 1536 or curStep == 2112 or curStep == 2176 then
			jsonCameraSettings.MiddleCamera = true
			jsonCameraSettings.OverrideZoom = false
		end
		if curStep == 796 or curStep == 1248 or curStep == 1504 or curStep == 1568 or curStep == 2144 or curStep == 2208 then
			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.OverrideZoom = false
		end
		if curStep == 1952 then
			jsonCameraSettings.BFx = 2070
			jsonCameraSettings.BFy = 1390

			jsonCameraSettings.DADx = 1050
			jsonCameraSettings.DADy = 1340
		end
		if curStep == 2080 then
			jsonCameraSettings.BFx = 1970
			jsonCameraSettings.BFy = 1290

			jsonCameraSettings.DADx = 1250
			jsonCameraSettings.DADy = 1290
		end
 	end
    if curStage == 'you-cant-run' then -- El nombre del stage
		-- Camera Speed
		if curStep == 0 or curStep == 80 or curStep == 528 or curStep == 800 or curStep == 1176 then
			setProperty('cameraSpeed', 1000000)
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 128 then
			jsonCameraSettings.MiddleCamera = false
		end
		if curStep == 144 then
			jsonCameraSettings.OverrideZoom = false
		end
		-- Middle Camera Moment
		if curStep == 432 or curStep == 896 or curStep == 1056 or curStep == 1440 then
			jsonCameraSettings.MiddleCamera = true
			jsonCameraSettings.OverrideZoom = false
		end
		if curStep == 464 or curStep == 928 or curStep == 1120 then
			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.OverrideZoom = false
		end
		-- Pixel Moment
		if curStep == 528 then
			jsonCameraSettings.DADx =  800
			jsonCameraSettings.DADy = 120

			jsonCameraSettings.BFx = 900
			jsonCameraSettings.BFy = 120

			jsonCameraSettings.MiddleX = 450
			jsonCameraSettings.MiddleY = 100

			jsonCameraSettings.OverrideZoom = false

			jsonCameraSettings.OGZoom = 2.2
			jsonCameraSettings.MiddleZoom = 2
			jsonCameraSettings.OffsetsBF = 5
			jsonCameraSettings.OffsetsDAD = 5
		end
		if curStep == 800 then
			jsonCameraSettings.BFx = 1200
			jsonCameraSettings.BFy = 590

			jsonCameraSettings.DADx = 650
			jsonCameraSettings.DADy = 590

			jsonCameraSettings.MiddleX = 930
			jsonCameraSettings.MiddleY = 530

			jsonCameraSettings.OverrideZoom = false

			jsonCameraSettings.OGZoom = 0.7
			jsonCameraSettings.MiddleZoom = 0.65
			jsonCameraSettings.OffsetsBF = 25
			jsonCameraSettings.OffsetsDAD = 25
        end
    end
	if curStage == 'triple-trouble' then
		if curStep >= 1168 and curStep < 1264 then
			setProperty('cameraSpeed', 10)
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 1296 or curStep == 2828 or curStep == 2912 or curStep == 2928 or curStep == 2944 or curStep == 3232 or curStep == 3236 or curStep == 3240 or curStep == 3244 or curStep == 3296 or curStep == 3300 or curStep == 3304 or curStep == 3308 then
			setProperty('cameraSpeed', 100000)
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 1296 then

			--DADx = 1150 OG
			--DADy = 850

			jsonCameraSettings.BFx = 650
			jsonCameraSettings.BFy = 850
			jsonCameraSettings.DADx = 650
			jsonCameraSettings.DADy = 850
		end
		if curStep == 1360 then
			jsonCameraSettings.DADx = 1150
			jsonCameraSettings.DADy = 850
		end
		if curStep == 448 then
			jsonCameraSettings.BFy = 950
		end
	end
	if curStage == 'yourself' then
		if curStep == 768 then
			setProperty('cameraSpeed', 1000000)
			jsonCameraSettings.OGZoom = 0.65
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 1344 then
			jsonCameraSettings.BFx = getMidpointX('boyfriend')
			jsonCameraSettings.BFy = 1250
		end
		if curStep == 1472 then
			jsonCameraSettings.BFx = 2090
			jsonCameraSettings.BFy = 1190
		end
		if curStep == 1984 then
			jsonCameraSettings.DADx = getMidpointX('dad')
			jsonCameraSettings.DADy = getMidpointY('dad')
		end
		if curStep == 2048 then
			jsonCameraSettings.DADx = 1350
			jsonCameraSettings.DADy = 1150
		end
	end

    -- DEVOID --
	if curStage == 'hollow' then
		if curStep == 1 or curStep == 2096 or curStep == 2104 or curStep == 2112 or curStep == 2128 then
			setProperty('cameraSpeed', 1000000)
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 1056 or curStep == 2064 or curStep == 2128 then
			jsonCameraSettings.MiddleCamera = true
			jsonCameraSettings.OverrideZoom = false
		end
		if curStep == 1312 or curStep == 2096 then
			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.OverrideZoom = false
		end
		if curStep == 2104 then
			jsonCameraSettings.BFx = 2270
			jsonCameraSettings.BFy = 1250

			jsonCameraSettings.DADx = 2270
			jsonCameraSettings.DADy = 1250
		end
		if curStep == 2112 then
			jsonCameraSettings.BFx = 2270
			jsonCameraSettings.BFy = 1250

			jsonCameraSettings.DADx = 1450
			jsonCameraSettings.DADy = 1190
		end
	end

    -- FLEETWAY --
	if curStage == 'fleetw' then
		if curStep == 192 or curStep == 198 or curStep == 204 or curStep == 536 or curStep == 544 or curStep == 552 or curStep == 560 or curStep == 568 or curStep == 568 or curStep == 576 or curStep == 592 or curStep == 600 or curStep == 608 or curStep == 616 or curStep == 624 or curStep == 632 
		or curStep == 1624 or curStep == 1632 or curStep == 1640 or curStep == 1648 or curStep == 1656 or curStep == 1664 or curStep == 1680 or curStep == 1688 or curStep == 1696 or curStep == 1704 or curStep == 1712 or curStep == 1720  then
			setProperty('cameraSpeed', 10000)
		else
			setProperty('cameraSpeed', 1)
		end
	end

    -- DEMOGRI/GRIEVING --
	if curStage == 'uh-oh' then
		if curStep == 600 then
			setProperty('cameraSpeed', 1000000)
		else
			setProperty('cameraSpeed', 1)
		end
		if curStep == 408 or curStep == 1176 or curStep == 1704 or curStep == 1960 or curStep == 2088 then
			jsonCameraSettings.MiddleCamera = true
			jsonCameraSettings.OverrideZoom = false
		elseif curStep == 504 or curStep == 1240 or curStep == 1800 or curStep == 2024 then
			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.OverrideZoom = false
		end
		if curStep == 1312 then
			setProperty('cameraSpeed', 100)
		end
	end

    -- HOG --
	if curStage == 'hog' then
		if curBeat >= 188 and songPath == 'manual-blast' and sexitosxd2 == false then
			sexitosxd2 = true
			jsonCameraSettings.DADAngle = 1.5
		end
		if curBeat >= 1040 and songPath == 'manual-blast' then
			jsonCameraSettings.MiddleZoom = 0.42
		end
		if curBeat >= 1238 and sexogratisputocom == false and songPath == 'manual-blast' then
			sexogratisputocom = true
			setProperty('camZoomingMult', 0)
		end
	end

    -- MAJIN US --
	if curStage == 'majin' then
		-- Middle Camera Momento
		if curStep == 784 or curStep == 1184 or curStep == 1312 or curStep == 2464 or curStep == 2592 or curStep == 2736 then
			jsonCameraSettings.MiddleCamera = true
			jsonCameraSettings.OverrideZoom = false
		elseif curStep == 912 or curStep == 1248 or curStep == 1376 or curStep == 2528 or curStep == 2656 then
			jsonCameraSettings.MiddleCamera = false
			jsonCameraSettings.OverrideZoom = false
		end
    end
end

function lerp(a, b, t)
	return a + t * (b - a)
end