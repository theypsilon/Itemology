local System; import 'ecs'
local UpdateWalkingAI = class(System)

function UpdateWalkingAI:requires()
	return {'walkingai', 'ground', 'velocity', 'direction'}
end

local abs = math.abs

function UpdateWalkingAI:update(e, _, _, ground, v, dir)
    if ground.on then
        if (abs(v.x) < 5 or not e:morePath(v.x)) then
    		if   dir.x == 0 then dir.x = 1
    		else dir.x = dir.x * -1 end
        end
    end
end


return UpdateWalkingAI