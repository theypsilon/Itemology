local System; import 'ecs'
local Callback = class(System)

function Callback:requires()
	return {'script'}
end

function Callback:update(_, _, script)
    script()
end


return Callback