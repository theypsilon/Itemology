local function Object(level, definition, p, layer)

    local class  = p.properties.class or p.properties.object
    local loader = require('entity.object.' .. class)
    local o      = loader (definition, p)

    if o.body then 
        o.layer = layer
        o._name = 'Object'
        o.body.parent = o
    end

    if not o.tick then o.tick = nothing end

    return o
end

return Object