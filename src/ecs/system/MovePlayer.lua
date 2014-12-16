local Data; import()
local System; import 'ecs'
local MovePlayer = class(System)

function MovePlayer:requires()
	return {'action', 'moveDef'}
end

local function to(bool) return bool and 1 or 0 end

function MovePlayer:update(e, dt, action, def)
    e.dx           = -1 * to(action.left) + to(action.right)
    e.dy           = -1 * to(action.up  ) + to(action.down )
    e.dt           = 1 / (dt * def.timeFactor)
end

return MovePlayer