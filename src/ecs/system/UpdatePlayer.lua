local System; import 'ecs'
local UpdatePlayer = class(System)

local Mob = require 'entity.Mob'
local Text = require 'Text'

function UpdatePlayer:requires()
	return {'player', 'action'}
end

local function to(bool) return bool and 1 or 0 end

function UpdatePlayer:update(e, dt, player, action)

    e.dx           = -1 * to(action.left) + to(action.right)
    e.dy           = -1 * to(action.up  ) + to(action.down )
    e.dt           = 1 / (dt * e.moveDef.timeFactor)

    e:monitorTasks()
    e.tasks()
    e:applyDamage()
end


return UpdatePlayer