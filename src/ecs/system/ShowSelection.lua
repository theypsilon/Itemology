local System; import 'ecs'
local Text; import()

local ShowSelection = class(System)
function ShowSelection:requires()
	return {'jumpSelector'}
end

function ShowSelection:update(e, _, selector)
    Text:debug(selector, 'double_jump', 'double_jump : ')
end


return ShowSelection