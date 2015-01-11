local System; import 'ecs'
local PlayerCollisionPower = class(System)

function PlayerCollisionPower:requires()
    return {'collision_power', 'power_type'}
end

function PlayerCollisionPower:update(e, _, o, power_type)
    print('PlayerCollisionPower object.Power '..o.power)

    local ptype = power_type[o.power][1]
    if ptype and not e[ptype] then 
        e[ptype]   = o.power 
    end
    if o.charges == 'huge' or o.charges == 'inf'then o.charges = math.huge end
    e.power[o.power] = o.charges + (o.add and e.power[o.power] or 0)

    e.jumpResource[power_type[o.power][3]] = e.power[o.power]

    local remove = tonumber(o.remove) or 1

    if remove <= 1 then 
        o.removed = true
    else 
        o.remove = remove - 1 
    end
    e.collision_power = nil
end

return PlayerCollisionPower