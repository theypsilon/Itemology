local System; import 'system'
local UpdateObject = class(System)

local Mob = require 'entity.Mob'

function UpdateObject:requires()
	return {'isobject'}
end

function UpdateObject:update(object, dt)
    object:tick(dt)
end


return UpdateObject