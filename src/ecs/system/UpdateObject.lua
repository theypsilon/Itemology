local System; import 'ecs'
local UpdateObject = class(System)

local Mob = require 'entity.Mob'

function UpdateObject:requires()
	return {'isobject'}
end

function UpdateObject:update(e, dt)
    e:tick(dt)
end


return UpdateObject