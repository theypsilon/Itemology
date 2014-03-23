local System; import 'ecs'
local UpdateLevelScript = class(System)

function UpdateLevelScript:requires()
	return {'script', 'map'}
end

function UpdateLevelScript:update(_, _, script)
    script()
end


return UpdateLevelScript