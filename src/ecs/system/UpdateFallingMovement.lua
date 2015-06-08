local System; import 'ecs'
local UpdateFallingMovement = class(System)

function UpdateFallingMovement:requires()
	return {'moveDef', 'physic_change'}
end

function UpdateFallingMovement:update(e, _, def, physic_change)
    local vy = physic_change.vy or 0
    physic_change.vy = vy + def.addGravity
    if physic_change.vy > def.maxVyFall then
    	physic_change.vy = def.maxVyFall
    end
end


return UpdateFallingMovement
