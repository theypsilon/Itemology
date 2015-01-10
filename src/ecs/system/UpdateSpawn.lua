local System; import 'ecs'
local UpdateSpawn = class(System)

function UpdateSpawn:requires()    return {'spawn', 'level', 'ticks', 'pos'}      end
function UpdateSpawn:update(e, dt, spawn, level, ticks, pos) 
    if spawn.offset then
        spawn.offset = spawn.offset - 1
        if spawn.offset < 0 then spawn.offset = nil end
    elseif ticks % spawn.rate == 0 and spawn.num > 0 then
        level:add(spawn.entity(level, spawn.definition, pos))
        spawn.num = spawn.num - 1
    end
end

return UpdateSpawn