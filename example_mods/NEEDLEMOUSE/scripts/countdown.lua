function onCountdownTick(counter)
    if counter == 1 then
        setProperty('countdownReady.x', -5000)
    elseif counter == 2 then
        setProperty('countdownSet.x', -5000)
    elseif counter == 3 then
        setProperty('countdownGo.x', -5000)
    end
end