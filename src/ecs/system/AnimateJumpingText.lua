local System; import 'ecs'
local AnimateJumper = class(System)

function AnimateJumper:requires()
    return {'animation_jumping_text', 'prop', 'jumping_values', 'pos'}
end

local abs = math.abs
function AnimateJumper:update(e, dt, animation, prop, val, pos)
    if e.ticks > 60 then e.removed = true end

    pos.x, pos.y, val.z = pos.x + val.xa, pos.y + val.ya, val.z + val.za
    
    if val.z < 0 then
        val.z = 0
        val.za = val.za * -.5
        val.xa = val.xa *  .6
        val.ya = val.ya *  .6
    end
    val.za = val.za - .15
    prop:setLoc(pos.x, pos.y - val.z)
end

return AnimateJumper