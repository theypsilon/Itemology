local System; import 'system'
local UpdatePlayer = class(System)

local Mob = require 'entity.Mob'

function UpdatePlayer:requires()
	return {'player'}
end

function UpdatePlayer:update(player, dt)

    player.dx           = -1 * player.dir.left + player.dir.right
    player.dy           = -1 * player.dir.up   + player.dir.down
    player.dt           = 1 / (dt * player.moveDef.timeFactor)

    player.tasks()
    player:monitorTasks()
    player:move()

    if player.y > player.limit_map_y + 100 then player:remove() end

    player:applyDamage()

	Mob.tick(player)
end


return UpdatePlayer