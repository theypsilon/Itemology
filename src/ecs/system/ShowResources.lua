local System; import 'ecs'
local Text; import()

local ShowResources = class(System)
function ShowResources:requires()
	return {'jumpResource'}
end

function ShowResources:update(e, _, res)
    local x, y = 10, 10
    for k, v in pairs(res) do
        if v ~= math.huge then
            Text:debug(res, k, k .. ' = ')
        end
    end
end


return ShowResources