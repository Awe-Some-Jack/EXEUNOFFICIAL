local damage = 0.007

local blacklistenedSongs = {'black-sun', 'godspeed', 'soulless', 'prey', 'forestall-desire', 'deception'}
function opponentNoteHit(id,nd,nt,isn)
    for i = 1,#blacklistenedSongs do if songPath == blacklistenedSongs[i] then return end end
    if isn then return end

    if getHealth() >= (damage * 2) then addHealth(-damage) end
end

function onEvent(n,v1) if n == 'Change Health Damage' then damage = tonumber(v1) end end