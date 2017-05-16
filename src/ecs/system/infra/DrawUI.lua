local Text, Layer; import()
local System; import 'ecs'

local DrawUI = class(System)

function DrawUI:requires()
    return {'ui'}
end

function DrawUI:update(e, _, ui)
    for key, value in pairs(ui) do
        if value.type == "text" then
            if not value.prop then
                value.prop = Text:print('', 0, 0, nil, nil, nil, Layer.Debug)
                Layer.Debug:insertProp(value.prop)
            end
            value.prop:setString(value.text)
            value.prop:setLoc(value.x, value.y)
        end
    end
end


return DrawUI