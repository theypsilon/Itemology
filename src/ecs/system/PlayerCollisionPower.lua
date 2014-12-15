local System; import 'ecs'
local PlayerCollisionPower = class(System)

function PlayerCollisionPower:requires()
    return {'collision_power'}
end

function PlayerCollisionPower:update(e, _, o)
    print('object.Power '..o.power)
    e:findPower(o)

    local remove = tonumber(o.remove) or 1

    if remove <= 1 
    then o:remove()
    else o.remove = remove - 1 end
    e.collision_power = nil
end

return PlayerCollisionPower