local function Spawn(level, definition, p)
    local e = {}
    e.pos = {x = p.x, y = p.y}
    e.ticks  = 0
    e.level  = level
    e.map    = level.map

    local pref  = definition.preferenceData

    local spawn = {}
    if pref then
        spawn.entity = definition.entity
        spawn.num    = definition.total
        spawn.rate   = definition.rate
        spawn.offset = definition.offset
    else
        p = p.properties
        spawn.entity = p.entity or p.class
        spawn.num    = p.total
        spawn.rate   = p.rate
        spawn.offset = p.offset
    end

    spawn.definition = require('data.entity.' .. spawn.entity)
    spawn.entity     = require(spawn.definition.class)

    e.spawn = spawn
    e._name = "Spawn"
    return e
end

return Spawn