local System; import 'ecs'
local updateVelocity = class(System)

function updateVelocity:requires()
	return {'body', 'pos'}
end

function updateVelocity:update(e, dt, body)
    e.vx, e.vy = body:getLinearVelocity()
end


return updateVelocity