local System; import 'ecs'
local Text; import()

local ShowSelection = class(System)
function ShowSelection:requires()
	return {'jumpSelector'}
end

function ShowSelection:update(e, _, selector)
    local jump_selector = debugUI.ui['jump_selector']
    if not jump_selector then
        jump_selector = {}
        debugUI.ui['jump_selector'] = jump_selector
    end

    jump_selector.type = 'text'
    jump_selector.text = 'double_jump : ' .. selector.double_jump
    jump_selector.x = 200
    jump_selector.y = 0
end


return ShowSelection