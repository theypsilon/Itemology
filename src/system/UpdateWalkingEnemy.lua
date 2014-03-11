local System; import 'system'
local UpdateWalkingEnemy = class(System)

local Mob = require 'entity.Mob'

function UpdateWalkingEnemy:requires()
	return {'walkingenemy'}
end

function UpdateWalkingEnemy:update(enemy, dt)
    enemy:move(dt)

    enemy.x, enemy.y = enemy.pos:get()

    if enemy.y > enemy.limit_map_y then
        enemy.pos:set(enemy.initial_x, enemy.initial_y)
        enemy.body:setLinearVelocity(0, 0)
    end

    Mob.tick(enemy)
end


return UpdateWalkingEnemy