local System; import 'ecs'
local SetLinearVelocity = class(System)

function SetLinearVelocity:requires()
    return {'physic_change', 'body'}
end

function SetLinearVelocity:update(e, _, change, body)
    if change.vx or change.vy then
        body:setLinearVelocity(change.vx or e.vx, change.vy or e.vy)
        change.vx = nil
        change.vy = nil
    end
end


return SetLinearVelocity