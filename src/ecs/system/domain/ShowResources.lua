local System; import 'ecs'

local ShowResources = class(System)

function ShowResources:requires()
	return {'jumpResource'}
end

function ShowResources:update(e, _, res)
    local i = 1
    local new_texts = {}
    for k, v in pairs(res) do
        local string = k .. " = " .. v
        local uiEntry = debugUI.ui[k]
        if not uiEntry then
            uiEntry = {}
            debugUI.ui[k] = uiEntry
        end
        uiEntry.type = "text"
        uiEntry.text = k .. " = " .. v
        uiEntry.x = 200
        uiEntry.y = 20 + 20*i
        i = i + 1
    end
end


return ShowResources