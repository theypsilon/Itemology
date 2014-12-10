local System; import 'ecs'
local UpdateFallingMovement = class(System)

function UpdateFallingMovement:requires()
	return {'moveDef', 'velocity', 'body'}
end

function UpdateFallingMovement:update(e, _, def, v, body)
    if def.addGravity + v.y > def.maxVyFall 
    then body:applyLinearImpulse(0, def.maxVyFall - v.y - def.addGravity)
    else body:applyLinearImpulse(0, def.addGravity) end

    if v.y < -400 then body:applyLinearImpulse(0, -v.y - 400) end
end


return UpdateFallingMovement
