local System; import 'ecs'
local SenseGround = class(System)

function SenseGround:requires()
	return {'ground', 'body'}
end

function SenseGround:update(e, _, ground, body)
    ground.on = body.groundCount ~= 0
end


return SenseGround