local System; import 'ecs'
local UpdateWalkingEnemy = class(System)

local Mob = require 'entity.Mob'

function UpdateWalkingEnemy:requires()
	return {'dnoononoºººº'}
end

function UpdateWalkingEnemy:update(e, dt)
    e:move(dt)

    e.x, e.y = e.pos.x, e.pos.y

    if e.y > e.limit_map_y then
        e.body:setTransform(e.initial_x, e.initial_y)
        e.body:setLinearVelocity(0, 0)
    end
end


return UpdateWalkingEnemy