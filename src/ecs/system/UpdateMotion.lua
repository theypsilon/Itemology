local System; import 'ecs'
local UpdateMotion = class(System)

function UpdateMotion:requires()
	return {'move', 'motion'}
end

function UpdateMotion:update(e, _, move, motion)
    for _, v in move:get() do
        motion[v](e)
    end
end


return UpdateMotion