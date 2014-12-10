local System; import 'ecs'
local UpdateGroundDetector = class(System)

function UpdateGroundDetector:requires()
	return {'ground', 'body'}
end

function UpdateGroundDetector:update(e, _, ground, body)
    ground.on = body.groundCount ~= 0
end


return UpdateGroundDetector