local function Object(level, definition, p, layer, k)

    local class  = p.properties.class or p.properties.object
    local loader = require('entity.object.' .. class)
    local o      = loader (definition, p, k)

    if o.body then 
        o.layer = layer
        if not o._name then o._name = 'Object' end
        o.body.parent = o
    end

    if not o.pos then o.pos = {x = o.x, y = o.y} end

    o.isobject = true

    if not o.tick then o.tick = nothing end

    return o
end

return Object