-- Tweens the camera's current position.
-- Event by Raimbowcore12

function onEvent(name, v1, v2)
    if name == "Tweening Camera" then
        -- Split and validate v1
        local split = stringSplit(v1, ',')
        if #split < 2 then
            debugPrint("Invalid v1 format. Expected 'x, y'.")
            return
        end

        local camx = tonumber(stringTrim(split[1])) or 0
        local camy = tonumber(stringTrim(split[2])) or 0

        -- Split and validate v2
        local split2 = stringSplit(v2, ',')
        if #split2 < 2 then
            debugPrint("Invalid v2 format. Expected 'steps, tween'.")
            return
        end

        local time = tonumber(stringTrim(split2[1]))
        local tween = stringTrim(split2[2])

        doTweenX("coolCamX", "camGame.targetOffset", camx, time, tween)
        doTweenY("coolCamY", "camGame.targetOffset", camy, time, tween)

        -- Debug information
        --debugPrint("Tweening Camera: camx=" .. camx .. ", camy=" .. camy .. ", steps=" .. steps .. ", tween=" .. tween)
    end
end