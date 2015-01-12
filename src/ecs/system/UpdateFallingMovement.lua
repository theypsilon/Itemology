local System; import 'ecs'
local UpdateFallingMovement = class(System)

function UpdateFallingMovement:requires()
	return {'moveDef', 'velocity', 'body'}
end

function UpdateFallingMovement:update(e, _, def, v, body)
    local apply = def.addGravity
    body:applyLinearImpulse(0, apply)
end


return UpdateFallingMovement
