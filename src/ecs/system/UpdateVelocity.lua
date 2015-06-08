local System; import 'ecs'
local updateVelocity = class(System)

function updateVelocity:requires()
	return {'body', 'velocity'}
end

function updateVelocity:update(e, dt, body, v)
	local x, y = body:getLinearVelocity()
	if (e.physical_change) then
		x, y = e.physical_change.vx, e.physical_change.vy
	end
    e.vx, e.vy = x, y
    v.x,  v.y  = x, y
end


return updateVelocity