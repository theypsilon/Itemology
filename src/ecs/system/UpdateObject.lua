local System; import 'ecs'
local UpdateObject = class(System)

function UpdateObject:requires()
	return {'isobject'}
end

function UpdateObject:update(e, dt)
    e:tick(dt)
end


return UpdateObject