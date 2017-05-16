local System; import 'ecs'
local DEBUGFallingMovement = class(System)

function DEBUGFallingMovement:requires()
	return {'moveDef', 'physic_change', 'player'}
end

function DEBUGFallingMovement:update(e, _, def, physic_change)
    print('vy', physic_change.vy)
end


return DEBUGFallingMovement
