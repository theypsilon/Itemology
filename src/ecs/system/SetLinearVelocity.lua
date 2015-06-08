local System; import 'ecs'
local SetLinearVelocity = class(System)

function SetLinearVelocity:requires()
    return {'physic_change', 'body'}
end

function SetLinearVelocity:update(e, _, change, body)
    if change.vx or change.vy then
        body:setLinearVelocity(change.vx or 0, change.vy or 0)
    end
end


return SetLinearVelocity