local System; import 'ecs'
local updateVelocity = class(System)

function updateVelocity:requires()
	return {'body', 'velocity'}
end

function updateVelocity:update(e, dt, body, v)
    e.vx, e.vy = body:getLinearVelocity()
    v.x,  v.y  = body:getLinearVelocity()
end


return updateVelocity