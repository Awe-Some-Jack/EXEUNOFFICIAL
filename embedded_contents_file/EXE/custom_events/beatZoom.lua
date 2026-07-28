local canbeat = false
function onEvent(n) if n == 'beatZoom' then canbeat = not canbeat end end
function onBeatHit() if canbeat and (curBeat % 4) > 0 then triggerEvent('Add Camera Zoom', '', '') end end