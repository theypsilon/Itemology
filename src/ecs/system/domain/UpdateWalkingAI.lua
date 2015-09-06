local System; import 'ecs'
local UpdateWalkingAI = class(System)

function UpdateWalkingAI:requires()
	return {'walkingai', 'ground', 'velocity', 'direction'}
end

local function there_is_more_ground_to_walk(e, vx)
    return e[vx > 0 and 'gRight' or 'gLeft'] ~= 0
end

local abs = math.abs
function UpdateWalkingAI:update(e, _, _, ground, v, dir)
    if ground.on then
        if (abs(v.x) < 5 or not there_is_more_ground_to_walk(e, v.x)) then
    		if   dir.x == 0 then dir.x = 1
    		else dir.x = dir.x * -1 end
        end
    end
end


return UpdateWalkingAI